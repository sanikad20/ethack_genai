# AtlasAI – AI-Powered Industrial Knowledge & Maintenance Assistant

AtlasAI is an AI-powered industrial maintenance platform that transforms scattered maintenance documents into an intelligent knowledge system. It empowers engineers, plant managers, technicians, and auditors with equipment-specific insights, AI-generated operational documents, and explainable recommendations through Retrieval-Augmented Generation (RAG).

---

## 🚀 Features

### 🤖 AI Knowledge Assistant
- Equipment-specific semantic search
- Retrieval-Augmented Generation (RAG)
- Context-aware AI responses
- Source citations with confidence scores
- Knowledge Graph integration
- Explainable AI outputs

### 📄 AI Action Engine
Generate operational documents instantly, including:
- Root Cause Analysis (RCA)
- Maintenance Checklists
- Preventive Maintenance Plans
- Inspection Reports
- Audit Reports
- Corrective Action Plans

### 👥 Role-Based AI Assistance

AtlasAI customizes responses based on the selected role:

#### 👨‍🔧 Engineer
- Equipment troubleshooting
- Repair guidance
- Inspection procedures
- Technical recommendations

#### 👨‍💼 Plant Manager
- Maintenance planning
- Resource allocation
- Compliance monitoring
- KPI-based recommendations

#### 👷 Technician
- Step-by-step maintenance guidance
- Equipment-specific instructions
- Operational assistance

#### 📋 Auditor
- Compliance verification
- Audit documentation
- Inspection summaries

### 📚 Knowledge Management
Upload and organize:
- Equipment Manuals
- SOPs
- Maintenance Logs
- Incident Reports
- Inspection Reports
- Sensor Reports

Documents are automatically indexed for semantic retrieval using vector embeddings.

### 🔍 Explainable AI
Every AI-generated response includes:
- Confidence Score
- Source Citations
- Retrieved Context
- Grounded Responses
- Transparent Decision Support

---

## 🛠️ Tech Stack

### Frontend
- Flutter
- Dart
- Firebase Authentication
- Cloud Firestore
- Firebase Storage

### Backend
- FastAPI
- Python

### AI & Machine Learning
- Groq API (Llama 3.3 70B)
- ChromaDB
- Sentence Transformers
- Retrieval-Augmented Generation (RAG)
- Knowledge Graph

### Database
- Firebase Firestore
- Chroma Vector Database

---

## 📂 Project Structure

```text
AtlasAI/
│
├── atlasai_app/                 # Flutter Application
│   ├── screens/
│   ├── services/
│   ├── models/
│   └── widgets/
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

## ⚙️ Workflow

```text
User Login
      │
      ▼
Select Equipment
      │
      ▼
Choose AI Feature
      │
      ▼
Retrieve Relevant Documents
      │
      ▼
Knowledge Graph Context
      │
      ▼
Groq LLM
      │
      ▼
Role-Based AI Response
      │
      ▼
Explainable Output with Citations
```

---

## 🧠 AI Pipeline

```text
User Query
      │
      ▼
Equipment Detection
      │
      ▼
Semantic Search (ChromaDB)
      │
      ▼
Relevant Documents
      │
      ▼
Knowledge Graph Context
      │
      ▼
Groq LLM
      │
      ▼
Role-Aware AI Response
      │
      ▼
Grounded Recommendation
```

---

## ⭐ Key Highlights

- Retrieval-Augmented Generation (RAG)
- AI-Powered Knowledge Assistant
- Semantic Search
- Role-Based AI
- Explainable AI
- Knowledge Graph Integration
- Equipment-Centric Search
- AI Document Generation
- Confidence Scoring
- Source Attribution
- Industrial Maintenance Automation

---

## 🚀 Future Enhancements

- Predictive Maintenance
- IoT Sensor Integration
- Real-Time Equipment Monitoring
- Voice-Based Maintenance Assistant
- SAP/ERP Integration
- Mobile Notifications
- Multi-language Support
- Offline Knowledge Access

---

## 💻 Installation

### Clone the Repository

```bash
git clone https://github.com/<username>/AtlasAI.git
```

### Backend Setup

```bash
cd backend
pip install -r requirements.txt
uvicorn app:app --reload
```

### Flutter Setup

```bash
cd atlasai_app
flutter pub get
flutter run
```

---

## 📸 Screenshots

> Add screenshots of:
- Login Screen
- Dashboard
- Knowledge Assistant
- AI Action Engine
- RCA Generation
- Maintenance Checklist
- Knowledge Graph
- Manager Dashboard

---

## 👥 Team

### 🚀 Team: GenAI

| Role | Name | GitHub |
|------|------|--------|
| **Team Leader** | **Sanika Deshmukh** | [@sanikad20](https://github.com/sanikad20) |
| **Team Member** | **Pragati Kharat** | [@pragatikharat17](https://github.com/pragatikharat17) |
| **Team Member** | **Divya Addagatla** | [@adivya15](https://github.com/adivya15) |

---

## 📄 License

This project was developed as part of an AI Hackathon for educational and demonstration purposes.

---

## ⭐ Acknowledgements

- Groq
- FastAPI
- Flutter
- Firebase
- ChromaDB
- Sentence Transformers
- Open Source Community

---

If you found this project interesting, consider giving it a ⭐ on GitHub!
