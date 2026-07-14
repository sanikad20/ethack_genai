from typing import Any, Dict
from app.agents.base import BaseAgent


class KnowledgeAgent(BaseAgent):
    """Answers operational/procedural questions using RAG over documents
    plus Knowledge Graph traversal. Built out on Day 3."""

    name = "knowledge_agent"

    async def handle(self, request: Dict[str, Any]) -> Dict[str, Any]:
        # TODO (Day 3): ChromaDB retrieval + Knowledge Graph lookup + LLM call
        return {
            "agent": self.name,
            "answer": f"[stub] Knowledge Agent received: {request.get('query')}",
            "confidence": 0.0,
            "sources": [],
            "reasoning": "Stub response — retrieval pipeline not yet implemented.",
        }
