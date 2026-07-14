from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.orchestrator import orchestrator
from app.models.schemas import OrchestratorRequest, OrchestratorResponse

app = FastAPI(title="AtlasAI Backend", version="0.1.0")

# Wide open for hackathon dev — tighten before final submission
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.get("/")
async def root():
    return {"service": "AtlasAI Backend", "status": "running"}


@app.get("/ping")
async def ping():
    """Day 1 deliverable check: Flutter app hits this through Docker."""
    return {"message": "pong from AtlasAI orchestrator"}


@app.get("/health")
async def health():
    return {"status": "ok"}


@app.post("/query", response_model=OrchestratorResponse)
async def query(request: OrchestratorRequest):
    """Main entrypoint — routes to the Multi-Agent Orchestrator."""
    return await orchestrator.handle(request)
