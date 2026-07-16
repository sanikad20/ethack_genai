import hashlib
import math
import os
import re
from typing import List

import httpx

DIM = 384
HF_API_URL = "https://router.huggingface.co/hf-inference/models/sentence-transformers/all-MiniLM-L6-v2/pipeline/feature-extraction"


def _normalize(vec: List[float]) -> List[float]:
    norm = math.sqrt(sum(v * v for v in vec))
    if norm > 0:
        return [v / norm for v in vec]
    return vec


def _hash_embed(text: str) -> List[float]:
    vec = [0.0] * DIM
    tokens = re.findall(r"[a-z0-9]+", text.lower())
    for tok in tokens:
        h = int(hashlib.md5(tok.encode()).hexdigest(), 16)
        idx = h % DIM
        sign = 1.0 if (h // DIM) % 2 == 0 else -1.0
        vec[idx] += sign
    return _normalize(vec)


async def embed_batch(texts: List[str]) -> List[List[float]]:
    token = os.getenv("HF_API_TOKEN")
    if not token:
        return [_hash_embed(t) for t in texts]

    try:
        async with httpx.AsyncClient(timeout=30.0) as client:
            res = await client.post(
                HF_API_URL,
                headers={"Authorization": f"Bearer {token}"},
                json={"inputs": texts, "options": {"wait_for_model": True}},
            )
            res.raise_for_status()
            data = res.json()
            return [_normalize(vec) for vec in data]
    except Exception:
        return [_hash_embed(t) for t in texts]


async def embed(text: str) -> List[float]:
    result = await embed_batch([text])
    return result[0]
