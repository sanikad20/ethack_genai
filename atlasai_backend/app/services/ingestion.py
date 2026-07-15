import re
import uuid
from typing import List, Dict, Any

import fitz  # PyMuPDF
import pytesseract
from PIL import Image
import io


def extract_pages(file_bytes: bytes) -> List[str]:
    doc = fitz.open(stream=file_bytes, filetype="pdf")
    pages_text = []
    for page in doc:
        text = page.get_text("text").strip()
        if len(text) < 20:
            pix = page.get_pixmap(dpi=200)
            img = Image.open(io.BytesIO(pix.tobytes("png")))
            text = pytesseract.image_to_string(img).strip()
        pages_text.append(text)
    doc.close()
    return pages_text


def chunk_text(text: str, chunk_size: int = 800, overlap: int = 150) -> List[str]:
    text = re.sub(r"\s+", " ", text).strip()
    if not text:
        return []
    chunks = []
    start = 0
    while start < len(text):
        end = min(start + chunk_size, len(text))
        chunks.append(text[start:end])
        if end == len(text):
            break
        start = end - overlap
    return chunks


EQUIPMENT_PATTERN = re.compile(
    r"\b(PUMP|VALVE|COMPRESSOR|TANK|MOTOR|BOILER|TURBINE|CONVEYOR)[\s-]?(\d{1,3})\b",
    re.IGNORECASE,
)


def extract_equipment_tags(full_text: str) -> List[str]:
    tags = set()
    for match in EQUIPMENT_PATTERN.finditer(full_text):
        kind, num = match.groups()
        tag = f"{kind.upper()}-{int(num):02d}"
        tags.add(tag)
    return sorted(tags)


def build_graph_edges(doc_id: str, equipment_tags: List[str]) -> List[Dict[str, Any]]:
    edges = []
    for tag in equipment_tags:
        edges.append({
            "edgeId": str(uuid.uuid4()),
            "fromType": "equipment",
            "fromId": tag,
            "toType": "document",
            "toId": doc_id,
            "relation": "documented_by",
        })
    return edges
