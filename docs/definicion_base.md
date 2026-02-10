# Definition

A Product Orchestrator that manages catalogs for multiple merchants, where each merchant can have multiple products distributed across multiple sales channels (e.g. Facebook, Instagram, Mercado Libre).

The platform is channel-agnostic and vertical-agnostic: products do not need to belong to the same industry or category.

The system acts as a central source of truth for products and coordinates their publication and lifecycle across channels.

## Cloud

**Cloud Provider:** AWS

**Architecture Style:** Serverless, Event-Driven

## Catalog

The Catalog API must support the following business scenarios.

Product Lifecycle Statuses

* DRAFT

Product exists

Incomplete or not approved

Not publishable

* READY

Product is complete and valid

Eligible for publication

Not yet published anywhere

* ACTIVE

Published in at least one channel

Actively managed

* INACTIVE

Explicitly deactivated (soft delete)

Should not be published or visible

Triggers unpublish actions


## Core Use Cases
1. Register a Product

When a user registers a product:

Product metadata (name, description, pricing, attributes, channel overrides) is stored in a document database

Product images are stored in an object storage bucket

Only references (URLs / object keys) to images are stored in the catalog

2. Retrieve a Product by ID

When querying a product by ID:

Product metadata is retrieved from the document database

Image URLs are resolved from object storage

The API should return a single, aggregated product view

The retrieval strategy should be optimized to minimize latency and unnecessary calls.

3. List Products

Retrieve a paginated list of products

Support filtering by:

merchant

status

channel (optional, future)

4. Update a Product

Update product metadata

Update channel-specific overrides

Preserve product history and status transitions

5. Deactivate or Delete a Product

Soft delete / deactivate products

Trigger events to unpublish products from channels if needed

Ensure idempotency and safe retries

## Platform Responsibility

This API is responsible for:

Managing all products belonging to a merchant

Acting as the source of truth for product data

Emitting domain events related to product lifecycle changes

** It is not responsible for: **

Direct synchronous publication to external channels

Channel-specific business logic

Architecture & Stack
Backend

## Details :

**Language:** Python

**Framework:** FastAPI

**Runtime:** AWS Lambda

**Communication Pattern:** Event-Driven Architecture (EDA)

Product lifecycle changes emit domain events (e.g. ProductCreated, ProductPublished)

## Data Storage

**Catalog Database:** Document-oriented

**Primary candidate:** DynamoDB

Mongo-style modeling (denormalized, aggregate-oriented)

**Assets Storage:**

Object storage bucket for images and media

**Design Principles:**

Multi-tenant by design (merchant-isolated data)

Channel adapters are decoupled from the catalog core

Schema flexibility to support multiple verticals

Scales horizontally with minimal operational overhead