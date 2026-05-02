# product-db-flutter

Flutter mobile client for the Product DB ecosystem.

Companion app to:
- [`product-db`](https://github.com/aricardoreis/product-db) — NestJS backend
- [`product-db-server-app`](https://github.com/aricardoreis/product-db-server-app) — NF-e scraper microservice
- [`product-db-web-refine`](https://github.com/aricardoreis/product-db-web-refine) — React/Refine web client

## Scope (MVP)

1. Email/password auth against the NestJS backend (`/auth/login`, `/auth/refresh`)
2. NF-e QR code scanner → `POST /sales` to ingest invoices
3. Sales list + detail (paginated)
4. Products list + detail with price history (paginated, name search)

## Stack

- Flutter 3.41+, Dart 3.11+
- Riverpod 3 (state management)
- dio (HTTP)
- go_router (navigation)
- mobile_scanner (QR/barcode)
- flutter_secure_storage (tokens)
- fl_chart (price history sparkline)

## Getting started

```bash
fvm install stable
fvm use stable
cp .env.example .env   # edit API_BASE_URL if needed
flutter pub get
flutter run
```
