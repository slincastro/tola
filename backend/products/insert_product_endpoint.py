"""POST /products endpoint implementation with MongoDB insertion and validation."""

from __future__ import annotations

import logging
from datetime import datetime, timezone
from typing import Literal

from bson import ObjectId
from fastapi import HTTPException, status
from pydantic import BaseModel, Field, field_validator
from pymongo.errors import PyMongoError

try:
    from .mongo import get_products_collection
    from .router import router
except ImportError:
    from mongo import get_products_collection
    from router import router

logger = logging.getLogger(__name__)


class Surface(BaseModel):
    value: float = Field(..., gt=0)
    unit: Literal["m2"]


class Price(BaseModel):
    amount: float = Field(..., ge=0)
    currency: Literal["USD"]
    negotiable: bool


class Sector(BaseModel):
    name: str = Field(..., min_length=1, max_length=200)
    city: str = Field(..., min_length=1, max_length=120)
    province: str = Field(..., min_length=1, max_length=120)
    country: str = Field(..., min_length=1, max_length=120)


class PolygonGeometry(BaseModel):
    type: Literal["Polygon"]
    coordinates: list[list[list[float]]]

    @field_validator("coordinates")
    @classmethod
    def validate_polygon(cls, coordinates: list[list[list[float]]]) -> list[list[list[float]]]:
        if not coordinates:
            raise ValueError("Polygon coordinates must include at least one ring")

        outer_ring = coordinates[0]
        if len(outer_ring) < 4:
            raise ValueError("Polygon outer ring must contain at least 4 points")

        first = outer_ring[0]
        last = outer_ring[-1]

        if len(first) < 2 or len(last) < 2:
            raise ValueError("Each polygon point must contain at least [longitude, latitude]")

        if first[:2] != last[:2]:
            raise ValueError("Polygon outer ring must be closed (first point equals last point)")

        for ring in coordinates:
            for point in ring:
                if len(point) != 2:
                    raise ValueError("Polygon points must be [longitude, latitude]")

        return coordinates


class PointGeometry(BaseModel):
    type: Literal["Point"]
    coordinates: list[float]

    @field_validator("coordinates")
    @classmethod
    def validate_point(cls, coordinates: list[float]) -> list[float]:
        if len(coordinates) != 2:
            raise ValueError("Centroid coordinates must be [longitude, latitude]")
        return coordinates


class Location(BaseModel):
    geometry: PolygonGeometry
    centroid: PointGeometry


class Media(BaseModel):
    photos: list[str] = Field(default_factory=list)


class ProductInsertRequest(BaseModel):
    mid: str = Field(..., min_length=1, max_length=80)
    name: str = Field(..., min_length=1, max_length=200)
    description: str = Field(..., min_length=1)
    surface: Surface
    services: list[str] = Field(default_factory=list)
    price: Price
    sector: Sector
    location: Location
    media: Media = Field(default_factory=Media)


class ProductInsertResponse(BaseModel):
    id: str
    createdAt: datetime
    updatedAt: datetime


@router.post("/products", response_model=ProductInsertResponse, status_code=status.HTTP_201_CREATED)
def insert_product(payload: ProductInsertRequest) -> ProductInsertResponse:
    now = datetime.now(timezone.utc)

    document = payload.model_dump(mode="python")
    document["_id"] = ObjectId()
    document["createdAt"] = now
    document["updatedAt"] = now

    try:
        collection = get_products_collection()
        result = collection.insert_one(document)
    except RuntimeError as exc:
        logger.exception("MongoDB configuration error")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="MongoDB configuration error",
        ) from exc
    except PyMongoError as exc:
        logger.exception("MongoDB insert failed")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to insert product",
        ) from exc

    if not result.inserted_id:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Product insert returned empty id",
        )

    return ProductInsertResponse(
        id=str(result.inserted_id),
        createdAt=now,
        updatedAt=now,
    )
