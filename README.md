cd ~/ethack_genai
cat > README.md << 'MDEOF'
# 🤖 AtlasAI

### **Transforming Industrial Maintenance with Generative AI**

> *"Stop searching through hundreds of manuals. Start asking AtlasAI."*

AtlasAI is an **AI-powered industrial maintenance assistant** that helps engineers, technicians, plant managers, and auditors instantly retrieve equipment knowledge, diagnose issues, and generate maintenance documents using **Retrieval-Augmented Generation (RAG)**, **Knowledge Graphs**, and **Large Language Models**.

Instead of spending hours searching through SOPs, maintenance logs, and equipment manuals, users can simply ask AtlasAI and receive **accurate, explainable, and source-backed answers in seconds.**

---

## 🔗 Live Demo

**Backend API:** [https://ethack-genai.onrender.com/](https://ethack-genai.onrender.com/)

> ⏳ Hosted on Render's free tier — the first request after a period of inactivity can take **30–60 seconds** to wake the service up. Subsequent requests are fast. Try `GET /ping` first to warm it up before a live demo.

---

## 🌟 Why AtlasAI?

Industrial maintenance teams deal with thousands of pages of documentation.

Finding the right information during a critical equipment failure is often slow, manual, and error-prone.

**AtlasAI changes that.**

Using AI-powered semantic search and Retrieval-Augmented Generation (RAG), AtlasAI understands maintenance documents like a domain expert and delivers equipment-specific insights grounded in your organization's knowledge.

---

## 🚀 What Makes AtlasAI Different?

✨ **AI Knowledge Assistant**
- Chat naturally with your maintenance documents
- Equipment-aware semantic search
- Context-aware AI responses
- Source-backed recommendations

🧠 **Retrieval-Augmented Generation (RAG)**
- Eliminates hallucinations
- Uses only uploaded maintenance documents
- Grounded and explainable answers

📄 **AI Action Engine**
Generate professional maintenance documents within seconds:

- Root Cause Analysis (RCA)
- Maintenance Checklists
- Inspection Reports
- Preventive Maintenance Plans
- Corrective Action Reports
- Audit Reports

👥 **Role-Based Intelligence**

AtlasAI adapts responses based on the user's role.

👨‍🔧 **Engineer**
- Technical troubleshooting
- Repair recommendations
- Inspection guidance

👨‍💼 **Plant Manager**
- Maintenance planning
- Compliance monitoring
- Resource optimization

👷 **Technician**
- Step-by-step repair assistance
- Equipment-specific procedures

📋 **Auditor**
- Compliance verification
- Documentation review
- Audit summaries

---

## ⚡ How AtlasAI Works

```text
             📄 Maintenance Documents
                      │
                      ▼
          AI Document Processing & Embeddings
                      │
                      ▼
              Chroma Vector Database
                      │
                      ▼
         🔍 Semantic Search + Knowledge Graph
                      │
                      ▼
            🧠 Groq Llama 3.3 70B
                      │
                      ▼
         💡 Explainable AI Recommendations
                      │
                      ▼
       📋 Action Engine + Knowledge Assistant
                      │
                      ▼
              👤 Role-Based Responses
```

### Architecture Diagram

![AtlasAI Architecture](docs/architecture-diagram.jpg)

The system is split into a **Flutter client**, a **FastAPI backend** with five core services (Auth, Document, Knowledge Agent, Action Engine, Graph), an **AI/ML pipeline** (ingestion → chunking → embeddings → ChromaDB → RAG retrieval → Groq generation → response formatting), and external services (Groq API, embeddings model, Firebase).

---

## 🛠 Tech Stack

### 🎨 Frontend
- Flutter
- Dart
- Firebase Authentication
- Cloud Firestore
- Firebase Storage

### ⚙️ Backend
- FastAPI
- Python

### 🤖 Artificial Intelligence
- Groq Llama 3.3 70B
- Retrieval-Augmented Generation (RAG)
- ChromaDB
- Sentence Transformers
- Knowledge Graph

### ☁️ Database
- Firebase Firestore
- Chroma Vector Database

---

## 🎯 Key Features

✅ AI Knowledge Assistant
✅ AI Action Engine
✅ Retrieval-Augmented Generation (RAG)
✅ Semantic Search
✅ Knowledge Graph
✅ Explainable AI
✅ Role-Based AI
✅ Source Citations
✅ Confidence Scoring
✅ Equipment-Centric Search

---

## 🚦 Getting Started

### Backend
```bash
cd atlasai_backend
cp .env.example .env   # fill in GROQ_API_KEY, HF_API_TOKEN, etc.
docker compose up --build
```

Verify it's running:
```bash
curl http://localhost:8000/ping
```

### Frontend
```bash
cd atlasai_app
flutter pub get
flutter run
```

---

## 💡 Future Vision

AtlasAI aims to become an intelligent maintenance copilot by integrating:

- 📡 IoT Sensors
- 📈 Predictive Maintenance
- 🎤 Voice Commands
- 🌐 ERP/SAP Integration
- 🔔 Smart Notifications
- 🌍 Multi-language Support
- 📱 Mobile-first Maintenance

---

## 👥 Meet the Team

### 🚀 Team GenAI

| Role | Name | GitHub |
|------|------|--------|
| 👑 Team Leader | **Sanika Deshmukh** | [@sanikad20](https://github.com/sanikad20) |
| 💻 Team Member | **Pragati Kharat** | [@pragatikharat17](https://github.com/pragatikharat17) |
| 🤖 Team Member | **Divya Addagatla** | [@adivya15](https://github.com/adivya15) |

---

## 🌟 Our Mission

> **Empowering industrial teams with trustworthy, explainable, and intelligent AI — turning maintenance knowledge into actionable insights, one query at a time.**

---

⭐ **If you found AtlasAI interesting, don't forget to star the repository!**
MDEOF
