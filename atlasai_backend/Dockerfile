# syntax=docker/dockerfile:1
FROM python:3.11-slim
WORKDIR /code
RUN apt-get update && apt-get install -y tesseract-ocr && rm -rf /var/lib/apt/lists/*
COPY requirements.txt .
RUN --mount=type=cache,target=/root/.cache/pip \
    pip install --timeout=120 --retries 5 -r requirements.txt
# Pre-download the embedding model into the image at build time.
RUN python -c "from sentence_transformers import SentenceTransformer; SentenceTransformer('sentence-transformers/multi-qa-MiniLM-L6-cos-v1')"
COPY ./app ./app
EXPOSE 8000
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
