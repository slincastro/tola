"""Single FastAPI app exposing all products endpoints."""

from fastapi import FastAPI

try:
    from .router import router
    from . import get_products_endpoint  # noqa: F401
    from . import insert_product_endpoint  # noqa: F401
except ImportError:
    from router import router
    import get_products_endpoint  # noqa: F401
    import insert_product_endpoint  # noqa: F401

app = FastAPI(title="Tola Products API")
app.include_router(router)
