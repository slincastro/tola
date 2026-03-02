"""GET /products endpoint with cursor pagination and optional geospatial search."""

from __future__ import annotations

import base64
import json
import logging
from datetime import datetime
from typing import Any

from bson import ObjectId
from fastapi import HTTPException, Query, status
from pydantic import BaseModel, ConfigDict, Field
from pymongo.errors import PyMongoError

try:
    from .mongo import get_products_collection
    from .router import router
except ImportError:
    from mongo import get_products_collection
    from router import router

logger = logging.getLogger(__name__)


class Surface(BaseModel):
    value: float
    unit: str


class Price(BaseModel):
    amount: float
    currency: str
    negotiable: bool


class Sector(BaseModel):
    name: str
    city: str
    province: str
    country: str


class PolygonGeometry(BaseModel):
    type: str
    coordinates: list[list[list[float]]]


class PointGeometry(BaseModel):
    type: str
    coordinates: list[float]


class Location(BaseModel):
    geometry: PolygonGeometry
    centroid: PointGeometry


class Media(BaseModel):
    photos: list[str] = Field(default_factory=list)


class ProductItem(BaseModel):
    model_config = ConfigDict(extra="allow")

    id: str
    mid: str
    name: str
    description: str
    surface: Surface
    services: list[str]
    price: Price
    sector: Sector
    location: Location
    media: Media
    createdAt: datetime
    updatedAt: datetime


class PageInfo(BaseModel):
    limit: int
    nextCursor: str | None


class GetProductsResponse(BaseModel):
    items: list[ProductItem]
    page: PageInfo


def _build_base_filter(
    sector: str | None,
    min_price: float | None,
    max_price: float | None,
    negotiable: bool | None,
) -> dict[str, Any]:
    filters: dict[str, Any] = {}

    if sector:
        filters["sector.name"] = sector

    if min_price is not None or max_price is not None:
        price_filter: dict[str, Any] = {}
        if min_price is not None:
            price_filter["$gte"] = min_price
        if max_price is not None:
            price_filter["$lte"] = max_price
        filters["price.amount"] = price_filter

    if negotiable is not None:
        filters["price.negotiable"] = negotiable

    return filters


def _encode_default_cursor(last_id: ObjectId) -> str:
    return str(last_id)


def _decode_default_cursor(cursor: str) -> ObjectId:
    try:
        return ObjectId(cursor)
    except Exception as exc:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Invalid cursor",
        ) from exc


def _encode_geo_cursor(last_id: ObjectId, distance_meters: float) -> str:
    payload = {"id": str(last_id), "d": distance_meters}
    raw = json.dumps(payload, separators=(",", ":")).encode("utf-8")
    return base64.urlsafe_b64encode(raw).decode("utf-8")


def _decode_geo_cursor(cursor: str) -> tuple[ObjectId, float]:
    try:
        decoded = base64.urlsafe_b64decode(cursor.encode("utf-8")).decode("utf-8")
        payload = json.loads(decoded)
        return ObjectId(payload["id"]), float(payload["d"])
    except Exception as exc:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Invalid geo cursor",
        ) from exc


def _serialize_product(document: dict[str, Any]) -> dict[str, Any]:
    output = dict(document)
    output["id"] = str(output.pop("_id"))
    output.pop("distanceMeters", None)
    return output


@router.get("/products", response_model=GetProductsResponse)
def get_products(
    limit: int = Query(20, ge=1, le=100),
    cursor: str | None = Query(None),
    sector: str | None = Query(None),
    min_price: float | None = Query(None, ge=0),
    max_price: float | None = Query(None, ge=0),
    negotiable: bool | None = Query(None),
    near_lng: float | None = Query(None),
    near_lat: float | None = Query(None),
    radius_meters: int | None = Query(None, ge=1),
) -> GetProductsResponse:
    if min_price is not None and max_price is not None and min_price > max_price:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="min_price cannot be greater than max_price",
        )

    has_geo = near_lng is not None or near_lat is not None
    if has_geo and (near_lng is None or near_lat is None):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="near_lng and near_lat must be provided together",
        )

    try:
        collection = get_products_collection()
    except RuntimeError as exc:
        logger.exception("MongoDB configuration error")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="MongoDB configuration error",
        ) from exc

    base_filter = _build_base_filter(sector, min_price, max_price, negotiable)

    try:
        if has_geo:
            pipeline: list[dict[str, Any]] = [
                {
                    "$geoNear": {
                        "near": {"type": "Point", "coordinates": [near_lng, near_lat]},
                        "distanceField": "distanceMeters",
                        "spherical": True,
                        "key": "location.centroid",
                        "query": base_filter,
                    }
                }
            ]

            if radius_meters is not None:
                pipeline[0]["$geoNear"]["maxDistance"] = radius_meters

            if cursor:
                last_id, last_distance = _decode_geo_cursor(cursor)
                pipeline.append(
                    {
                        "$match": {
                            "$or": [
                                {"distanceMeters": {"$gt": last_distance}},
                                {
                                    "$and": [
                                        {"distanceMeters": last_distance},
                                        {"_id": {"$gt": last_id}},
                                    ]
                                },
                            ]
                        }
                    }
                )

            pipeline.extend(
                [
                    {"$sort": {"distanceMeters": 1, "_id": 1}},
                    {"$limit": limit + 1},
                ]
            )

            documents = list(collection.aggregate(pipeline))
            has_more = len(documents) > limit
            page_documents = documents[:limit]

            next_cursor = None
            if has_more and page_documents:
                last_doc = page_documents[-1]
                next_cursor = _encode_geo_cursor(last_doc["_id"], float(last_doc["distanceMeters"]))

        else:
            query_filter = dict(base_filter)
            if cursor:
                query_filter["_id"] = {"$lt": _decode_default_cursor(cursor)}

            projection = {"_id": 1, "__v": 0}
            documents = list(
                collection.find(query_filter, projection)
                .sort("_id", -1)
                .limit(limit + 1)
            )

            has_more = len(documents) > limit
            page_documents = documents[:limit]
            next_cursor = _encode_default_cursor(page_documents[-1]["_id"]) if has_more and page_documents else None

    except PyMongoError as exc:
        logger.exception("Mongo query failed")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to fetch products",
        ) from exc

    items = [_serialize_product(doc) for doc in page_documents]

    return GetProductsResponse(
        items=items,
        page=PageInfo(limit=limit, nextCursor=next_cursor),
    )
