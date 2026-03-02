# GET /products examples

## Basic pagination

```bash
curl -s "http://localhost:8000/products?limit=20"
```

## Filter by sector and price range

```bash
curl -s "http://localhost:8000/products?sector=Centro&min_price=50000&max_price=200000&negotiable=true&limit=20"
```

## Geospatial search (sorted by distance)

```bash
curl -s "http://localhost:8000/products?near_lng=-78.4918&near_lat=-0.1809&radius_meters=5000&limit=20"
```

## Geospatial next page with cursor

```bash
curl -s "http://localhost:8000/products?near_lng=-78.4918&near_lat=-0.1809&radius_meters=5000&limit=20&cursor=<geo_cursor>"
```
