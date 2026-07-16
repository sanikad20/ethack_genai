FROM python:3.11-slim

WORKDIR /code

RUN apt-get update && apt-get install -y tesseract-ocr && rm -rf /var/lib/apt/lists/*

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Pre-download the embedding model into the image at build time.
# This means the model download happens once, during `docker-compose
# build` (needs internet then), but NEVER at runtime — so query/ingest
# requests during your actual demo have zero network dependency and
# can't fail from a flaky HF API call or bad WiFi.
RUN python -c "from sentence_transformers import SentenceTransformer; SentenceTransformer('sentence-transformers/multi-qa-MiniLM-L6-cos-v1')"

COPY ./app ./app

EXPOSE 8000

CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]