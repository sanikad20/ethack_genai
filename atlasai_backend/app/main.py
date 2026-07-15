import uuid

from fastapi import FastAPI, UploadFile, File, Form, HTTPException
from fastapi.middleware.cors import CORSMiddleware

from app.orchestrator import orchestrator
from app.models.schemas import (
    OrchestratorRequest,
    OrchestratorResponse,
    IngestResponse,
)
from app.services import ingestion
from app.services import embeddings
from app.services.chroma_client import get_documents_collection

app = FastAPI(title="AtlasAI Backend")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.get("/ping")
async def ping():
    return "pong"


@app.post("/query", response_model=OrchestratorResponse)
async def query(request: OrchestratorRequest):
    return await orchestrator.handle(request)


@app.post("/ingest", response_model=IngestResponse)
async def ingest(
    file: UploadFile = File(...),
    equipment_id: str = Form(None),
):
    if not file.filename.lower().endswith(".pdf"):
        raise HTTPException(400, "Only PDF supported for Day 2 ingestion.")

    file_bytes = await file.read()
    doc_id = str(uuid.uuid4())

    try:
        pages = ingestion.extract_pages(file_bytes)
    except Exception as e:
        raise HTTPException(422, f"Could not parse PDF: {e}")

    full_text = "\n".join(pages)
    equipment_tags = ingestion.extract_equipment_tags(full_text)
    graph_edges = ingestion.build_graph_edges(doc_id, equipment_tags)

    collection = get_documents_collection()
    ids, docs, metadatas = [], [], []
    for page_num, page_text in enumerate(pages, start=1):
        for chunk in ingestion.chunk_text(page_text):
            chunk_id = f"{doc_id}_p{page_num}_{uuid.uuid4().hex[:8]}"
            ids.append(chunk_id)
            docs.append(chunk)
            metadatas.append({
                "doc_id": doc_id,
                "equipment_id": equipment_id or "",
                "page": page_num,
                "file_name": file.filename,
            })

    if ids:
        vectors = embeddings.embed_batch(docs)
        collection.add(ids=ids, documents=docs, metadatas=metadatas, embeddings=vectors)

    return IngestResponse(
        docId=doc_id,
        fileName=file.filename,
        status="ingested" if ids else "failed",
        pageCount=len(pages),
        chunkCount=len(ids),
        equipmentTags=equipment_tags,
        graphEdges=graph_edges,
    )
