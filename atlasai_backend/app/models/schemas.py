from typing import Any, Dict, List, Optional
from pydantic import BaseModel


class OrchestratorRequest(BaseModel):
    query: str
    user_role: Optional[str] = "technician"   # technician | engineer | manager | auditor
    equipment_id: Optional[str] = None
    doc_ids: Optional[List[str]] = None
    agents: Optional[List[str]] = None        # force specific agents; None = auto-route


class AgentResult(BaseModel):
    agent: str
    answer: str
    confidence: float
    sources: List[str] = []
    reasoning: str = ""


class OrchestratorResponse(BaseModel):
    query: str
    results: List[AgentResult]
    merged_answer: str
    overall_confidence: float


class GraphEdgeOut(BaseModel):
    edgeId: str
    fromType: str
    fromId: str
    toType: str
    toId: str
    relation: str


class IngestResponse(BaseModel):
    docId: str
    fileName: str
    status: str
    pageCount: int
    chunkCount: int
    equipmentTags: List[str]
    graphEdges: List[GraphEdgeOut]
