#!/usr/bin/env python3
"""Bulk loader for Products API using JSON files."""

from __future__ import annotations

import argparse
import json
import os
import ssl
import sys
from pathlib import Path
from urllib import error, request

DEFAULT_API_BASE_URL = "http://localhost:8000"
DEFAULT_DATA_DIR = Path(__file__).resolve().parent / "data"
SCRIPT_VERSION = "2026-03-03.1"


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Load products to POST /products from JSON files")
    parser.add_argument(
        "--api-base-url",
        default=os.getenv("API_BASE_URL", DEFAULT_API_BASE_URL),
        help="Products service base URL (default: API_BASE_URL env or http://localhost:8000)",
    )
    parser.add_argument(
        "--data-dir",
        default=str(DEFAULT_DATA_DIR),
        help="Directory containing product JSON files",
    )
    parser.add_argument(
        "--stop-on-error",
        action="store_true",
        help="Stop execution on first failed request",
    )
    parser.add_argument(
        "--ca-bundle",
        default=os.getenv("SSL_CERT_FILE"),
        help="Path to CA bundle file (PEM) used to validate HTTPS certificates",
    )
    parser.add_argument(
        "--insecure",
        action="store_true",
        default=True,
        help="Disable HTTPS certificate validation (default: enabled for this loader)",
    )
    parser.add_argument(
        "--secure",
        dest="insecure",
        action="store_false",
        help="Enable HTTPS certificate validation",
    )
    return parser.parse_args()


def build_ssl_context(ca_bundle: str | None, insecure: bool) -> ssl.SSLContext:
    if insecure:
        context = ssl.create_default_context()
        context.check_hostname = False
        context.verify_mode = ssl.CERT_NONE
        return context

    if ca_bundle:
        return ssl.create_default_context(cafile=ca_bundle)

    return ssl.create_default_context()


def build_products_endpoint(api_base_url: str) -> str:
    base = api_base_url.rstrip("/")
    if base.endswith("/products"):
        return base
    return f"{base}/products"


def post_product(api_base_url: str, payload: dict, ssl_context: ssl.SSLContext) -> tuple[int, dict]:
    endpoint = build_products_endpoint(api_base_url)
    body = json.dumps(payload).encode("utf-8")
    req = request.Request(
        endpoint,
        data=body,
        headers={"Content-Type": "application/json"},
        method="POST",
    )

    with request.urlopen(req, timeout=30, context=ssl_context) as response:
        response_body = response.read().decode("utf-8")
        if not response_body:
            parsed = {}
        else:
            try:
                parsed = json.loads(response_body)
            except json.JSONDecodeError:
                parsed = {"rawResponse": response_body}
        return response.getcode(), parsed


def load_json(path: Path) -> dict:
    raw = path.read_text(encoding="utf-8-sig")
    if not raw.strip():
        raise json.JSONDecodeError("Empty JSON file", raw, 0)
    return json.loads(raw)


def main() -> int:
    args = parse_args()
    data_dir = Path(args.data_dir).resolve()
    ssl_context = build_ssl_context(args.ca_bundle, args.insecure)

    if not data_dir.exists() or not data_dir.is_dir():
        print(f"[ERROR] Data directory does not exist: {data_dir}")
        return 1

    json_files = sorted(data_dir.glob("*.json"))
    if not json_files:
        print(f"[ERROR] No JSON files found in {data_dir}")
        return 1

    success_count = 0
    error_count = 0

    print(f"Loader v{SCRIPT_VERSION} | script={Path(__file__).resolve()}")
    endpoint = build_products_endpoint(args.api_base_url)
    print(f"Loading {len(json_files)} file(s) to {endpoint}")
    print(f"[INFO] Data dir: {data_dir}")
    if args.insecure:
        print("[WARN] HTTPS certificate validation is disabled (--insecure).")
    elif args.ca_bundle:
        print(f"[INFO] Using CA bundle: {args.ca_bundle}")

    for file_path in json_files:
        try:
            payload = load_json(file_path)
        except json.JSONDecodeError as exc:
            error_count += 1
            try:
                size = file_path.stat().st_size
            except OSError:
                size = -1
            print(f"[ERROR] {file_path.name} has invalid JSON: {exc} | path={file_path} | size={size}")
            if args.stop_on_error:
                break
            continue

        try:
            status_code, response = post_product(args.api_base_url, payload, ssl_context)
            success_count += 1
            print(f"[OK] {file_path.name} -> HTTP {status_code} | id={response.get('id', 'n/a')}")
        except error.HTTPError as exc:
            error_count += 1
            raw_body = exc.read().decode("utf-8", errors="replace")
            print(f"[ERROR] {file_path.name} -> HTTP {exc.code} | {raw_body}")
            if args.stop_on_error:
                break
        except error.URLError as exc:
            error_count += 1
            print(f"[ERROR] {file_path.name} -> connection error: {exc.reason}")
            if args.stop_on_error:
                break
        except Exception as exc:  # noqa: BLE001
            error_count += 1
            print(f"[ERROR] {file_path.name} -> unexpected error: {exc}")
            if args.stop_on_error:
                break

    print(f"Done. success={success_count} error={error_count}")
    return 0 if error_count == 0 else 2


if __name__ == "__main__":
    sys.exit(main())
