import os
import chromadb

_client = None
_documents_collection = None


def get_client():
    global _client
    if _client is None:
        host = os.getenv("CHROMA_HOST", "chromadb")
        port = int(os.getenv("CHROMA_PORT", "8000"))
        _client = chromadb.HttpClient(host=host, port=port)
    return _client


def get_documents_collection():
    global _documents_collection
    if _documents_collection is None:
        _documents_collection = get_client().get_or_create_collection(
            name="documents"
        )
    return _documents_collection
