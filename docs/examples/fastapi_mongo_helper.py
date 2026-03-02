"""Minimal FastAPI + pymongo helper using MONGO_URI from environment."""

import os

from fastapi import FastAPI
from pymongo import MongoClient


def get_mongo_client() -> MongoClient:
    mongo_uri = os.getenv("MONGO_URI")
    if not mongo_uri:
        raise RuntimeError("MONGO_URI is required")

    return MongoClient(mongo_uri, serverSelectionTimeoutMS=5000)


app = FastAPI()


@app.get("/health/mongo")
def mongo_health() -> dict:
    client = get_mongo_client()
    client.admin.command("ping")
    return {"status": "ok"}
