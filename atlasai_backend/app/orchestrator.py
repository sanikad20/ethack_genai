"""
Multi-Agent Orchestrator — routes an incoming query to the right agent(s),
merges their outputs, and returns a single response the Flutter client
(and later, the AI Action Engine) can consume.

Day 1: routing is naive (keyword-based) and agents are stubs.
This gets smarter as each agent is built out through the week —
the routing/merge logic itself doesn't need to change shape.
"""
from typing import Dict, List

from app.agents import (
    KnowledgeAgent,
    MaintenanceAgent,
    ComplianceAgent,
    LessonsLearnedAgent,
    KnowledgeCaptureAgent,
)
from app.models.schemas import OrchestratorRequest, OrchestratorResponse, AgentResult


class Orchestrator:
    def __init__(self):
        self.agents = {
            "knowledge_agent": KnowledgeAgent(),
            "maintenance_agent": MaintenanceAgent(),
            "compliance_agent": ComplianceAgent(),
            "lessons_learned_agent": LessonsLearnedAgent(),
            "knowledge_capture_agent": KnowledgeCaptureAgent(),
        }

    def _route(self, request: OrchestratorRequest) -> List[str]:
        """Decide which agent(s) should handle this request.
        Day 1: if the caller doesn't force specific agents, default to
        the Knowledge Agent. Keyword routing gets refined per-agent as
        each one comes online (Day 3, 5, 6)."""
        if request.agents:
            return request.agents

        q = request.query.lower()
        selected = []
        if any(w in q for w in ["fail", "vibrat", "breakdown", "root cause", "rca"]):
            selected.append("maintenance_agent")
        if any(w in q for w in ["compliance", "audit", "regulation", "oisd"]):
            selected.append("compliance_agent")
        if any(w in q for w in ["incident", "near miss", "similar"]):
            selected.append("lessons_learned_agent")
        if any(w in q for w in ["capture", "interview", "record my experience"]):
            selected.append("knowledge_capture_agent")

        if not selected:
            selected.append("knowledge_agent")
        return selected

    async def handle(self, request: OrchestratorRequest) -> OrchestratorResponse:
        agent_names = self._route(request)
        results: List[AgentResult] = []

        for name in agent_names:
            agent = self.agents.get(name)
            if not agent:
                continue
            raw = await agent.handle({
                "query": request.query,
                "context": {
                    "user_role": request.user_role,
                    "equipment_id": request.equipment_id,
                    "doc_ids": request.doc_ids,
                },
            })
            results.append(AgentResult(**raw))

        if results:
            merged_answer = " | ".join(r.answer for r in results)
            overall_confidence = sum(r.confidence for r in results) / len(results)
        else:
            merged_answer = "No agent could handle this request."
            overall_confidence = 0.0

        return OrchestratorResponse(
            query=request.query,
            results=results,
            merged_answer=merged_answer,
            overall_confidence=overall_confidence,
        )


orchestrator = Orchestrator()
