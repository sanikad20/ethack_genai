# AtlasAI 🤖

> **An AI-Powered Industrial Knowledge & Maintenance Assistant**
>
> Built using **Flutter, FastAPI, Firebase, ChromaDB, Groq Llama 3.3 70B, and Retrieval-Augmented Generation (RAG)** to help engineers, plant managers, technicians, and auditors make smarter maintenance decisions through AI-powered knowledge retrieval and document generation.

![Flutter](https://img.shields.io/badge/Flutter-3.x-blue?logo=flutter)
![FastAPI](https://img.shields.io/badge/FastAPI-Backend-green?logo=fastapi)
![Python](https://img.shields.io/badge/Python-3.11-blue?logo=python)
![Firebase](https://img.shields.io/badge/Firebase-Authentication-orange?logo=firebase)
![ChromaDB](https://img.shields.io/badge/ChromaDB-VectorDB-purple)
![License](https://img.shields.io/badge/License-MIT-blue)

---

# 📖 Overview

AtlasAI is an AI-powered industrial maintenance assistant that centralizes organizational knowledge into an intelligent system. It enables engineers, technicians, plant managers, and auditors to retrieve equipment-specific information, generate operational documents, and receive explainable AI recommendations grounded in enterprise maintenance documentation.

The platform combines **Retrieval-Augmented Generation (RAG)**, **semantic search**, **knowledge graphs**, and **role-aware AI** to deliver accurate, context-aware responses while minimizing hallucinations.

---

# ✨ Features

## 🤖 AI Knowledge Assistant

- Equipment-specific semantic search
- Context-aware question answering
- Retrieval-Augmented Generation (RAG)
- Knowledge Graph integration
- AI-powered maintenance recommendations
- Source citations for every response
- Confidence scoring

---

## 📄 AI Action Engine

Generate industrial documents instantly:

- Root Cause Analysis (RCA)
- Maintenance Checklists
- Preventive Maintenance Plans
- Corrective Action Reports
- Inspection Reports
- Audit Reports
- Equipment Recommendations

---

## 👥 Role-Based AI

AtlasAI adapts responses based on the user's selected role.

### 👨‍🔧 Engineer
- Technical troubleshooting
- Repair recommendations
- Inspection procedures
- Maintenance execution

### 👷 Technician
- Step-by-step maintenance guidance
- Equipment handling
- Safety checks

### 👨‍💼 Plant Manager
- Resource planning
- Maintenance scheduling
- Compliance tracking
- Operational recommendations

### 📋 Auditor
- Compliance validation
- Inspection summaries
- Documentation review

---

## 📚 Knowledge Management

Supports uploading and indexing:

- Equipment Manuals
- Standard Operating Procedures (SOPs)
- Incident Reports
- Maintenance Logs
- Inspection Reports
- Sensor Reports
- Safety Documents

Uploaded documents are automatically embedded and indexed for semantic retrieval.

---

## 🔍 Explainable AI

Every response includes:

- Retrieved Sources
- Confidence Score
- Supporting Context
- Equipment References
- Transparent AI Reasoning

---

# 🛠 Tech Stack

## Frontend

- Flutter
- Dart
- Firebase Authentication
- Cloud Firestore
- Firebase Storage

---

## Backend

- FastAPI
- Python

---

## Artificial Intelligence

- Groq API
- Llama 3.3 70B
- ChromaDB
- Sentence Transformers
- Retrieval-Augmented Generation (RAG)
- Knowledge Graph

---

## Database

- Firebase Firestore
- Chroma Vector Database

---

# 🏗 Architecture

```
                    +----------------+
                    | Flutter Client |
                    +--------+-------+
                             |
                             |
                  Firebase Authentication
                             |
                             ▼
                    +----------------+
                    |   FastAPI API  |
                    +--------+-------+
                             |
      --------------------------------------------------
      |                    |                           |
      ▼                    ▼                           ▼
Knowledge Agent     AI Action Engine         Knowledge Graph
      |                    |                           |
      --------------------------------------------------
                             |
                             ▼
                    Chroma Vector Database
                             |
                             ▼
                    Maintenance Documents
```

---

# 📂 Project Structure

```
ethack_genai/
│
├── atlasai_app/
│   ├── lib/
│   ├── assets/
│   └── pubspec.yaml
│
├── backend/
│   ├── api/
│   ├── services/
│   ├── routes/
│   ├── models/
│   ├── knowledge_agent.py
│   ├── action_engine.py
│   ├── graph_service.py
│   ├── groq_client.py
│   └── app.py
│
├── requirements.txt
└── README.md
```

---

# ⚙ Workflow

```
User Login
      │
      ▼
Select Equipment
      │
      ▼
Choose AI Module
      │
      ▼
Retrieve Relevant Documents
      │
      ▼
Semantic Search
      │
      ▼
Knowledge Graph
      │
      ▼
Groq LLM
      │
      ▼
Role-Based AI Response
      │
      ▼
Explainable AI Output
```

---

# 🧠 AI Pipeline

```
User Query
      │
      ▼
Equipment Detection
      │
      ▼
Semantic Search
      │
      ▼
Relevant Chunks
      │
      ▼
Knowledge Graph Context
      │
      ▼
Groq LLM
      │
      ▼
Role-Based Prompt
      │
      ▼
Grounded AI Response
```

---

# 🚀 Installation

## Clone Repository

```bash
git clone https://github.com/sanikad20/ethack_genai.git
cd ethack_genai
```

---

## Backend Setup

```bash
cd backend

python -m venv venv

# Windows
venv\Scripts\activate

# Linux/macOS
source venv/bin/activate

pip install -r requirements.txt

uvicorn app:app --reload
```

Backend runs on:

```
http://localhost:8000
```

---

## Flutter Setup

```bash
cd ../atlasai_app

flutter pub get

flutter run
```

---

# 📱 Screenshots

Add screenshots here.

Suggested screenshots:

- Login Screen
- Dashboard
- AI Knowledge Assistant
- AI Action Engine
- RCA Generation
- Maintenance Checklist
- Knowledge Graph
- Manager Dashboard

---

# ⭐ Key Highlights

- Retrieval-Augmented Generation (RAG)
- Semantic Search
- Knowledge Graph
- Role-Based AI
- Explainable AI
- AI Document Generation
- Equipment-Centric Search
- Confidence Scoring
- Grounded Responses
- Industrial Maintenance Automation

---

# 🔮 Future Scope

- Predictive Maintenance
- IoT Sensor Integration
- Voice Assistant
- Offline Knowledge Base
- SAP/ERP Integration
- Mobile Push Notifications
- Multi-language Support
- Real-Time Equipment Monitoring

---

# 👥 Team

## 🚀 Team: GenAI

| Role | Name | GitHub |
|------|------|--------|
| **Team Leader** | **Sanika Deshmukh** | [@sanikad20](https://github.com/sanikad20) |
| **Team Member** | **Pragati Kharat** | [@pragatikharat17](https://github.com/pragatikharat17) |
| **Team Member** | **Divya Addagatla** | [@adivya15](https://github.com/adivya15) |

---

# 🙏 Acknowledgements

This project leverages several outstanding open-source technologies:

- Flutter
- FastAPI
- Firebase
- Groq
- ChromaDB
- Sentence Transformers
- Python
- Open Source Community

---

# 📄 License

This project was developed as part of an AI Hackathon for educational and demonstration purposes.

---

## ⭐ If you found this project interesting, consider giving it a star!

Repository:

**https://github.com/sanikad20/ethack_genai**
