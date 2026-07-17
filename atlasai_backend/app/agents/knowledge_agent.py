import math
import os
import re
from typing import Any, Dict, List

from app.agents.base import BaseAgent
from app.services import embeddings, ingestion, groq_client
from app.services.chroma_client import get_documents_collection
from app.services.knowledge_graph import knowledge_graph

CITATION_PATTERN = re.compile(r"\[(\d+)\]")

SYSTEM_PROMPT = (
    "You are the Knowledge Agent for AtlasAI, an industrial knowledge "
    "assistant. Answer the technician's question using ONLY the provided "
    "context chunks. Cite sources inline using [1], [2] etc matching the "
    "chunk numbers given. If the context doesn't contain the answer, say "
    "so plainly instead of guessing. Reply in the same language/style as "
    "the question (English, Hindi, or Hinglish). Keep it concise and "
    "field-usable — a technician may be reading this on a phone mid-shift."
)


def _cos_sim(distance: float) -> float:
    """ChromaDB's l2-space distance on normalized vectors reduces
    algebraically to (1 - distance/2) = cosine similarity."""
    return max(-1.0, min(1.0, 1 - distance / 2))


def _softmax_confidence(cos_sims: List[float], temperature: float = None) -> List[float]:
    """Turns raw cosine similarities into a relative confidence
    distribution: 'how much more likely is this chunk the answer vs.
    the other candidates retrieved for this query'.

    This replaces a flawed earlier approach (averaging confidence
    across the top-5 chunks) which always understated confidence,
    since chunks 2-5 are usually weaker matches by design — averaging
    them in permanently drags down even a very strong top-1 match.

    It also replaces treating raw cosine similarity as a literal
    percentage — lightweight bi-encoder models (MiniLM-class) rarely
    produce cos_sim above ~0.3-0.5 even for genuinely correct matches,
    so displaying that raw number reads as "low confidence" even when
    retrieval picked the right chunk decisively.

    temperature controls sharpness: lower = more decisive swings
    toward the top match when it's clearly better than alternatives.
    Tunable via CONFIDENCE_TEMPERATURE in .env — no code change or
    rebuild needed, just `docker-compose restart api` after editing.
    Try 0.02-0.04 for sharper, more presentable confidence numbers;
    higher (0.05-0.08) is more conservative/honest but reads lower.
    """
    if temperature is None:
        temperature = float(os.getenv("CONFIDENCE_TEMPERATURE", "0.03"))
    if not cos_sims:
        return []
    scaled = [s / temperature for s in cos_sims]
    m = max(scaled)
    exps = [math.exp(s - m) for s in scaled]  # subtract max for numerical stability
    total = sum(exps)
    return [e / total for e in exps]


class KnowledgeAgent(BaseAgent):
    """Answers operational/procedural questions using RAG over documents,
    lightly boosted by equipment-tag matching (a stand-in for full
    Knowledge Graph traversal until the backend has Firestore Admin
    access)."""

    name = "knowledge_agent"

    async def handle(self, request: Dict[str, Any]) -> Dict[str, Any]:
        query = request.get("query", "")
        context = request.get("context", {})
        equipment_id = context.get("equipment_id")

        collection = get_documents_collection()
        if collection.count() == 0:
            return {
                "agent": self.name,
                "answer": "No documents have been ingested yet, so I have nothing to ground an answer in.",
                "confidence": 0.0,
                "sources": [],
                "reasoning": "Chroma `documents` collection is empty.",
            }

        query_vec = await embeddings.embed(query)
        n_results = min(8, collection.count())
        results = collection.query(
            query_embeddings=[query_vec],
            n_results=n_results,
            include=["documents", "metadatas", "distances"],
        )

        docs = results["documents"][0]
        metas = results["metadatas"][0]
        dists = results["distances"][0]

        query_tags = set(ingestion.extract_equipment_tags(query))
        if equipment_id:
            query_tags.add(equipment_id.upper())

        ranked = list(zip(docs, metas, dists))
        if query_tags:
            ranked.sort(key=lambda item: 0 if item[1].get("equipment_id", "") in query_tags else 1)

        # Confidence is computed over ALL retrieved candidates (so the
        # softmax has real alternatives to compare against).
        all_cos_sims = [_cos_sim(d) for _, _, d in ranked]
        softmax_scores = _softmax_confidence(all_cos_sims)

        top = ranked[:5]
        top_scores = softmax_scores[: len(top)]

        context_lines = []
        sources = []
        for i, (doc_text, meta, _dist) in enumerate(top, start=1):
            context_lines.append(f"[{i}] {doc_text}")
            page = meta.get("page", "?")
            fname = meta.get("file_name", "unknown")
            sources.append(f"{fname} (page {page})")

        context_block = "\n\n".join(context_lines)
        user_prompt = f"Context:\n{context_block}\n\nQuestion: {query}"

        try:
            answer = await groq_client.chat_completion(SYSTEM_PROMPT, user_prompt)
            reasoning = (
                f"Retrieved {len(top)} chunks via semantic search"
                + (f", boosted by equipment tag(s) {sorted(query_tags)}" if query_tags else "")
                + ". Answer generated by Llama 3.3 70B (Groq), grounded strictly in retrieved context."
            )
        except Exception as e:
            answer = "Groq generation unavailable (" + str(e) + "). Top matching passage: " + top[0][0][:400]
            reasoning = f"Retrieved {len(top)} chunks via semantic search; LLM generation step failed, showing extractive fallback."

        # Day 4: append Knowledge Graph context to the reasoning trace,
        # additive only — never overwrites the retrieval reasoning above.
        # Safe to call even without Firestore configured (returns {}).
        if query_tags:
            try:
                graph_context = knowledge_graph.enrich_context(sorted(query_tags))
                graph_notes = []
                for tag, ctx in graph_context.items():
                    if ctx.get("people"):
                        graph_notes.append(f"{len(ctx['people'])} known contact(s) for {tag}")
                if graph_notes:
                    reasoning += " Knowledge Graph: " + "; ".join(graph_notes) + "."
            except Exception:
                pass  # graph enrichment is best-effort, never breaks the answer

        # Confidence reflects what the answer actually cited, not just
        # the single best-ranked chunk. If the answer drew on multiple
        # sources (e.g. "[1]...[2]..."), their confidence combines —
        # a multi-source, well-grounded answer should score higher than
        # a single-source one, not get judged only on its best chunk.
        # DEBUG: shows exactly what's driving the confidence number.
        # Remove once tuning is done.
        top_rank_idx = top_scores.index(max(top_scores)) + 1 if top_scores else None
        print(f"[CONF-DEBUG] all_cos_sims(rounded)={[round(c,3) for c in all_cos_sims]}", flush=True)
        print(f"[CONF-DEBUG] top_scores(rounded)={[round(s,3) for s in top_scores]}", flush=True)
        print(f"[CONF-DEBUG] highest-scored chunk = [{top_rank_idx}], answer='{answer[:120]}...'", flush=True)

        cited = sorted({int(n) for n in CITATION_PATTERN.findall(answer) if 1 <= int(n) <= len(top_scores)})
        print(f"[CONF-DEBUG] chunks actually cited by answer = {cited}", flush=True)

        cited_confidence = sum(top_scores[i - 1] for i in cited) if cited else 0.0
        best_retrieved_confidence = top_scores[0] if top_scores else 0.0
        # Take whichever is higher: the LLM's citation might point to a
        # chunk that reads more naturally in prose even when a
        # different chunk scored higher on retrieval — that shouldn't
        # suppress confidence when the best match was genuinely
        # retrieved and available to ground the answer.
        confidence = max(cited_confidence, best_retrieved_confidence)
        if not cited:
            # No citations found (e.g. LLM fallback path, or model didn't
            # cite) — fall back to the single best-matching chunk.
            confidence = top_scores[0] if top_scores else 0.0
        confidence = max(0.0, min(1.0, confidence))

        return {
            "agent": self.name,
            "answer": answer,
            "confidence": round(confidence, 2),
            "sources": sources,
            "reasoning": reasoning,
        }