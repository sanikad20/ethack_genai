from typing import Any, Dict

from app.agents.base import BaseAgent
from app.services import groq_client, retrieval

SYSTEM_PROMPT = (
    "You are the Lessons Learned Agent for AtlasAI. You compare the "
    "current situation against past documented incidents, near-misses, "
    "and inspection findings to surface transferable lessons. Using "
    "ONLY the provided context entries, identify which past entries are "
    "genuinely similar to the current situation, and summarize the "
    "lesson(s) or precaution(s) that apply. Cite entries inline as "
    "[1], [2] etc. If nothing in the context is meaningfully similar, "
    "say so plainly rather than forcing a connection."
)


class LessonsLearnedAgent(BaseAgent):
    name = "lessons_learned_agent"

    async def handle(self, request: Dict[str, Any]) -> Dict[str, Any]:
        query = request.get("query", "")
        context = request.get("context", {})
        equipment_id = context.get("equipment_id")

        r = await retrieval.retrieve(query, equipment_id=equipment_id, n_results=8, top_k=5)

        if not r["top"]:
            return {
                "agent": self.name,
                "answer": "No historical documents ingested yet — nothing to compare against.",
                "confidence": 0.0,
                "sources": [],
                "reasoning": "Chroma `documents` collection is empty.",
            }

        user_prompt = f"Past documented entries:\n{r['context_block']}\n\nCurrent situation: {query}"

        try:
            answer = await groq_client.chat_completion(SYSTEM_PROMPT, user_prompt)
            reasoning = (
                f"Searched {len(r['top'])} past entries via open semantic similarity "
                "(not equipment-filtered, to catch cross-equipment pattern matches). "
                "Lessons summarized by Llama 3.3 70B (Groq), grounded in retrieved entries."
            )
        except Exception as e:
            answer = "Groq generation unavailable (" + str(e) + "). Closest matching entry: " + r["top"][0][0][:400]
            reasoning = f"Retrieved {len(r['top'])} entries; LLM generation failed, showing extractive fallback."

        return {
            "agent": self.name,
            "answer": answer,
            "confidence": r["confidence"],
            "sources": r["sources"],
            "reasoning": reasoning,
        }
