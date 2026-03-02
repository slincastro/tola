#!/usr/bin/env bash
set -euo pipefail

API_BASE_URL="${1:-${API_BASE_URL:-https://454pqm0o6c.execute-api.us-east-1.amazonaws.com}}"

curl -sS -X POST "${API_BASE_URL%/}/products" \
  -H "Content-Type: application/json" \
  -d '{
    "mid": "merchant_001",
    "name": "Terreno urbano en venta",
    "description": "Terreno con acceso a servicios basicos.",
    "surface": {
      "value": 450,
      "unit": "m2"
    },
    "services": ["water", "electricity", "sewer"],
    "price": {
      "amount": 120000,
      "currency": "USD",
      "negotiable": true
    },
    "sector": {
      "name": "Centro",
      "city": "Quito",
      "province": "Pichincha",
      "country": "Ecuador"
    },
    "location": {
      "geometry": {
        "type": "Polygon",
        "coordinates": [
          [
            [-78.4921, -0.1807],
            [-78.4915, -0.1807],
            [-78.4915, -0.1812],
            [-78.4921, -0.1807]
          ]
        ]
      },
      "centroid": {
        "type": "Point",
        "coordinates": [-78.4918, -0.1809]
      }
    },
    "media": {
      "photos": []
    }
  }'

echo
