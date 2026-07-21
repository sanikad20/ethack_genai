# AtlasAI – AI-Powered Industrial Knowledge & Maintenance Assistant

AtlasAI is an AI-powered industrial maintenance platform that transforms scattered maintenance documents into an intelligent knowledge system. It enables engineers, plant managers, technicians, and auditors to retrieve equipment-specific information, generate operational documents, and make faster, data-driven maintenance decisions using Generative AI.

## Features

### AI Knowledge Assistant
- Equipment-specific semantic search
- Retrieval-Augmented Generation (RAG)
- Context-aware answers grounded in uploaded documents
- Source citations with confidence scores
- Knowledge Graph integration for equipment relationships

### AI Action Engine
Generate operational documents instantly:
- Root Cause Analysis (RCA) Reports
- Maintenance Checklists
- Inspection Schedules
- Preventive Maintenance Plans
- Audit Reports

All outputs are generated strictly from retrieved knowledge and include source citations.

### Role-Based AI
AtlasAI adapts responses based on the user's role:

- 👨‍🔧 Engineer
  - Execution-focused maintenance guidance
  - Hands-on repair procedures
  - Inspection and troubleshooting

- 👨‍💼 Plant Manager
  - Planning and scheduling
  - Compliance monitoring
  - Resource allocation
  - Maintenance strategy

- 👷 Technician
  - Equipment-specific operational assistance

- 📋 Auditor
  - Compliance-oriented reporting

### Knowledge Management
- Upload SOPs
- Maintenance Logs
- Incident Reports
- Sensor Reports
- Equipment Manuals
- Inspection Reports

Documents are automatically embedded and indexed for semantic retrieval.

### Explainable AI
Every generated response includes:
- Confidence Score
- Source Documents
- Inline Citations
- Grounded Responses (No Hallucinations)

---

## Tech Stack

### Frontend
- Flutter
- Firebase Authentication
- Cloud Firestore
- Firebase Storage

### Backend
- FastAPI
- Python

### AI & ML
- Groq LLM (Llama 3.3 70B)
- ChromaDB
- Sentence Transformers
- Retrieval-Augmented Generation (RAG)

### Database
- Firebase Firestore
- Chroma Vector Database

---

## Project Structure

```
atlasai/
│
├── atlasai_app/          # Flutter Application
│
├── backend/
│   ├── api/
│   ├── services/
│   ├── models/
│   ├── routes/
│   ├── embeddings/
│   ├── knowledge_agent.py
│   ├── action_engine.py
│   ├── graph_service.py
│   └── groq_client.py
│
└── README.md
```

---

## Workflow

1. User uploads maintenance documents.
2. Documents are embedded and stored in ChromaDB.
3. User asks equipment-specific questions.
4. AtlasAI retrieves the most relevant document chunks.
5. Groq LLM generates grounded responses.
6. Action Engine creates operational documents.
7. Results include citations, confidence score, and supporting sources.

---

## AI Pipeline

```
User Query
      │
      ▼
Equipment Detection
      │
      ▼
Semantic Retrieval (ChromaDB)
      │
      ▼
Knowledge Graph Context
      │
      ▼
Groq LLM
      │
      ▼
Role-Aware Response
      │
      ▼
Explainable AI Output
```

---

## Key Highlights

- Retrieval-Augmented Generation (RAG)
- Semantic Search
- Role-Aware AI
- Explainable AI
- Knowledge Graph Integration
- AI Document Generation
- Equipment-Centric Knowledge Base
- Confidence Scoring
- Source Attribution

---

## Future Improvements

- Predictive Maintenance
- IoT Sensor Integration
- Real-time Equipment Monitoring
- Voice-based Maintenance Assistant
- SAP/ERP Integration
- Mobile Notifications
- Multi-language Support

---

## Installation

### Clone Repository

```bash
git clone https://github.com/<username>/AtlasAI.git
```

### Backend

```bash
cd backend
pip install -r requirements.txt
uvicorn app.main:app --reload
```

### Flutter

```bash
cd atlasai_app
flutter pub get
flutter run
```

---

## Team

Built as part of an AI Hackathon to modernize industrial maintenance using Generative AI, Retrieval-Augmented Generation, and Explainable AI.
