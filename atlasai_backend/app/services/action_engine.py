"""
Day 6: AI Action Engine.

Generates structured operational documents (RCA report, maintenance
checklist, inspection schedule, audit report) grounded in whatever's
actually been ingested for the equipment in question — same retrieval
approach as knowledge_agent.py (broad semantic retrieval, no ChromaDB
where-clause dependency), then a template-specific system prompt tells
Groq what structure/sections to produce.

Deliberately reuses retrieval rather than introducing a new pipeline:
the whole point of the Action Engine per the plan is "generate an
action from the same context" the Knowledge Agent already grounded its
answer in — not a separate, disconnected feature.
"""
from typing import Any, Dict, List, Optional

from app.services import embeddings, groq_client
from app.services.chroma_client import get_documents_collection
from app.services import graph_service

ACTION_TYPES = {
    "rca_report": {
        "title": "Root Cause Analysis Report",
        "instructions": (
            "Produce a structured Root Cause Analysis report with these exact sections, "
            "each as a markdown heading: 'Incident Summary', 'Timeline', 'Suspected Root Cause', "
            "'Contributing Factors', 'Corrective Actions Taken', 'Preventive Recommendations'. "
            "Base every claim strictly on the provided context. If a section has no supporting "
            "evidence in the context, write 'Not documented in available records' for that "
            "section rather than inventing detail."
        ),
    },
    "maintenance_checklist": {
        "title": "Maintenance Checklist",
        "instructions": (
            "Produce a maintenance checklist as a numbered list of concrete, checkable steps "
            "(e.g. '1. Inspect drive-end bearing for wear'), grounded in the provided context. "
            "Group steps under markdown headings by category if the context supports more than "
            "one category (e.g. 'Mechanical', 'Lubrication', 'Electrical'). Keep each step short "
            "and field-usable — a technician should be able to check it off without re-reading it."
        ),
    },
    "inspection_schedule": {
        "title": "Inspection Schedule",
        "instructions": (
            "Produce an inspection schedule as a markdown table with columns: Item, Frequency, "
            "Last Recorded Date (if known from context, else 'Unknown'), Next Due (state 'Cannot "
            "calculate — last date unknown' if the last date isn't in the context rather than "
            "guessing one). Base frequencies on what the context states; if none is stated, note "
            "'No frequency documented — recommend establishing one' instead of inventing a number."
        ),
    },
    "audit_report": {
        "title": "Audit Report",
        "instructions": (
            "Produce an audit report with sections: 'Scope', 'Records Reviewed', 'Findings', "
            "'Compliance Status', 'Recommendations'. List each source document reviewed under "
            "'Records Reviewed' by filename. Under 'Findings', separate confirmed facts (from "
            "context) from gaps (information the context doesn't cover) explicitly."
        ),
    },
}


async def _retrieve_context(query: str, equipment_id: Optional[str], n_results: int = 8) -> List[Dict[str, Any]]:
    """Same broad-retrieve-then-filter pattern as maintenance_agent.py —
    no ChromaDB where-clause, since that's proven unreliable in this
    environment's ChromaDB version across several rounds of testing."""
    collection = get_documents_collection()
    if collection.count() == 0:
        return []

    query_vec = await embeddings.embed(query)
    n = min(n_results, collection.count())
    results = collection.query(query_embeddings=[query_vec], n_results=n)

    docs = results.get("documents", [[]])[0]
    metas = results.get("metadatas", [[]])[0]

    chunks = [{"text": d, "meta": m} for d, m in zip(docs, metas)]
    if equipment_id:
        scoped = [c for c in chunks if c["meta"].get("equipment_id") == equipment_id]
        if scoped:
            return scoped
    return chunks


async def generate_action(
    action_type: str,
    query: str,
    equipment_id: Optional[str] = None,
    user_role: str = "technician",
) -> Dict[str, Any]:
    if action_type not in ACTION_TYPES:
        raise ValueError(f"Unknown action_type '{action_type}'. Valid: {sorted(ACTION_TYPES)}")

    spec = ACTION_TYPES[action_type]
    search_query = query or f"{spec['title']} for {equipment_id or 'this equipment'}"
    chunks = await _retrieve_context(search_query, equipment_id)

    if not chunks:
        return {
            "actionType": action_type,
            "title": spec["title"],
            "content": (
                f"No documents have been ingested yet for "
                f"{equipment_id or 'this equipment'} — nothing to ground a "
                f"{spec['title'].lower()} in. Ingest a maintenance log, incident "
                f"report, or SOP first."
            ),
            "sources": [],
            "confidence": 0.0,
        }

    context_lines = []
    sources = []
    for i, chunk in enumerate(chunks[:6], start=1):
        context_lines.append(f"[{i}] {chunk['text']}")
        fname = chunk["meta"].get("file_name", "unknown")
        sources.append(fname)
    context_block = "\n\n".join(context_lines)

    graph_note = ""
    if equipment_id:
        try:
            graph_note = graph_service.graph_context_summary(equipment_id.upper())
        except Exception:
            graph_note = ""

    system_prompt = (
        "You are the AI Action Engine for AtlasAI, an industrial knowledge assistant. "
        f"{spec['instructions']} "
        "Use ONLY the provided context — do not invent equipment history, dates, or names "
        "that aren't in it. Cite sources inline using [1], [2] etc matching the context "
        f"numbers given. Write for a {user_role}: adjust technical depth accordingly, but "
        "keep every factual claim traceable to the context."
    )
    user_prompt = (
        f"Equipment: {equipment_id or 'not specified'}\n"
        f"{'Knowledge Graph: ' + graph_note if graph_note else ''}\n\n"
        f"Context:\n{context_block}\n\n"
        f"Generate the {spec['title']}."
    )

    try:
        content = await groq_client.chat_completion(system_prompt, user_prompt)
        confidence = min(1.0, 0.5 + 0.05 * len(chunks[:6]))
    except Exception as e:
        content = (
            f"Groq generation unavailable ({e}). Raw retrieved context follows instead:\n\n"
            + context_block
        )
        confidence = 0.2

    return {
        "actionType": action_type,
        "title": spec["title"],
        "content": content,
        "sources": sorted(set(sources)),
        "confidence": round(confidence, 2),
    }