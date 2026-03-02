"""Reusable MongoDB connection helpers for the products API."""

from __future__ import annotations

import os
from functools import lru_cache

from pymongo import MongoClient
from pymongo.collection import Collection

DB_NAME = "products_db"
COLLECTION_NAME = "products"


@lru_cache(maxsize=1)
def get_mongo_client() -> MongoClient:
    """Return a cached MongoClient using MONGODB_URI from environment."""
    mongo_uri = os.getenv("MONGODB_URI")
    if not mongo_uri:
        raise RuntimeError("MONGODB_URI is required")

    client = MongoClient(
        mongo_uri,
        appname="tola-products-api",
        serverSelectionTimeoutMS=5000,
        connectTimeoutMS=5000,
        socketTimeoutMS=10000,
        retryWrites=True,
    )

    client.admin.command("ping")
    return client


@lru_cache(maxsize=1)
def get_products_collection() -> Collection:
    """Return products collection and ensure recommended indexes exist."""
    collection = get_mongo_client()[DB_NAME][COLLECTION_NAME]

    # Geospatial indexes.
    collection.create_index([("location.geometry", "2dsphere")], name="idx_products_location_geometry_2dsphere")
    collection.create_index([("location.centroid", "2dsphere")], name="idx_products_location_centroid_2dsphere")
    # Filter indexes for GET /products.
    collection.create_index([("sector.name", 1)], name="idx_products_sector_name")
    collection.create_index([("price.amount", 1)], name="idx_products_price_amount")
    collection.create_index([("price.negotiable", 1)], name="idx_products_price_negotiable")
    collection.create_index(
        [("sector.name", 1), ("price.amount", 1), ("price.negotiable", 1), ("_id", -1)],
        name="idx_products_filters_cursor",
    )

    return collection
