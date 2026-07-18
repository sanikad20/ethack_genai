from typing import Any, Dict, Optional

from app.services import embeddings, ingestion
from app.services.chroma_client import get_documents_collection


def _distance_to_confidence(distance: float) -> float:
    cos_sim = 1 - distance / 2
    return max(0.0, min(1.0, cos_sim))


async def retrieve(
    query: str,
    equipment_id: Optional[str] = None,
    n_results: int = 8,
    top_k: int = 5,
    require_equipment_match: bool = False,
) -> Dict[str, Any]:
    collection = get_documents_collection()
    count = collection.count()
    if count == 0:
        return {"top": [], "context_block": "", "sources": [], "confidence": 0.0, "tags": set()}

    query_vec = await embeddings.embed(query)
    n = min(n_results, count)
    results = collection.query(
        query_embeddings=[query_vec],
        n_results=n,
        include=["documents", "metadatas", "distances"],
    )
    docs = results["documents"][0]
    metas = results["metadatas"][0]
    dists = results["distances"][0]

    tags = set(ingestion.extract_equipment_tags(query))
    if equipment_id:
        tags.add(equipment_id.upper())

    ranked = list(zip(docs, metas, dists))
    if tags:
        matched = [item for item in ranked if item[1].get("equipment_id", "") in tags]
        if require_equipment_match and matched:
            ranked = matched
        else:
            ranked.sort(key=lambda item: 0 if item[1].get("equipment_id", "") in tags else 1)

    top = ranked[:top_k]

    context_lines, sources = [], []
    for i, (doc_text, meta, _d) in enumerate(top, start=1):
        context_lines.append(f"[{i}] {doc_text}")
        sources.append(f"{meta.get('file_name', 'unknown')} (page {meta.get('page', '?')})")

    confidence = (
        sum(_distance_to_confidence(d) for _, _, d in top) / len(top) if top else 0.0
    )

    return {
        "top": top,
        "context_block": "\n\n".join(context_lines),
        "sources": sources,
        "confidence": round(confidence, 2),
        "tags": tags,
    }
