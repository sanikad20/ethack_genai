# AtlasAI – Day 2: Document Ingestion Pipeline

## Overview

Day 2 implements the complete document ingestion pipeline for **AtlasAI**. Users can upload maintenance manuals in PDF format through the Flutter application. The backend processes the uploaded document by extracting text, splitting it into chunks, generating embeddings, storing them in ChromaDB, and returning metadata such as equipment tags and graph relationships.

---

## Features

- Upload PDF documents from the Flutter application
- Optional Equipment ID association
- FastAPI document ingestion endpoint
- PDF text extraction
- Intelligent document chunking
- Embedding generation
- Vector storage in ChromaDB
- Equipment tag extraction
- Knowledge graph edge generation
- Upload status and metadata displayed in the app

---

## Architecture

```text
Flutter App
      │
      ▼
Upload PDF
      │
      ▼
FastAPI (/ingest)
      │
      ├── Extract PDF Text
      ├── Split into Chunks
      ├── Generate Embeddings
      ├── Store in ChromaDB
      ├── Extract Equipment Tags
      └── Build Graph Edges
      │
      ▼
JSON Response
      │
      ▼
Flutter Success Screen
```

---

## Backend API

### POST `/ingest`

Processes an uploaded PDF document and stores its embeddings.

### Request

**Multipart Form Data**

| Field | Type | Required |
|-------|------|----------|
| file | PDF | Yes |
| equipment_id | String | No |

---

## Sample Response

```json
{
  "docId": "46753e84-01bc-48cb-a789-a6071497b664",
  "fileName": "manual.pdf",
  "status": "ingested",
  "pageCount": 1,
  "chunkCount": 5,
  "equipmentTags": [],
  "graphEdges": []
}
```

---

## Document Processing Flow

1. User uploads a PDF from the Flutter application.
2. FastAPI receives the document.
3. Text is extracted from every page.
4. The document is divided into smaller chunks.
5. Embeddings are generated for each chunk.
6. Embeddings are stored in ChromaDB.
7. Equipment tags are extracted.
8. Graph relationships are generated.
9. The ingestion result is returned to the Flutter application.

---

## Tech Stack

### Frontend

- Flutter
- Dart
- File Picker
- HTTP

### Backend

- FastAPI
- Python

### AI & Data

- ChromaDB
- Embedding Model
- Document Chunking

### Infrastructure

- Docker
- Docker Compose

---

## Project Structure

```text
atlasai_backend/
│
├── app/
│   ├── main.py
│   ├── orchestrator/
│   ├── services/
│   │   ├── ingestion.py
│   │   ├── embeddings.py
│   │   └── chroma_client.py
│   └── models/
│
atlasai_app/
│
├── lib/
│   ├── screens/
│   │   └── upload_document_screen.dart
│   └── services/
│       ├── storage_service.dart
│       └── orchestrator_service.dart
```

---

## Day 2 Deliverables

- ✅ Flutter PDF upload interface
- ✅ FastAPI `/ingest` endpoint
- ✅ PDF text extraction
- ✅ Document chunking
- ✅ Embedding generation
- ✅ ChromaDB vector storage
- ✅ Equipment tag extraction
- ✅ Knowledge graph edge generation
- ✅ Upload status displayed in Flutter

---

## Sample Output

```text
Upload Successful

Status: ingested

Pages: 1

Chunks: 5

Equipment Tags:
[]

Document ID:
46753e84-01bc-48cb-a789-a6071497b664
```
