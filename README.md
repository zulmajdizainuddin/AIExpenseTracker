# AI Expense Tracker + Receipt Scanner

A full-stack expense tracking app built with Flutter and Laravel 12 — track expenses, scan receipts with Gemini AI, set category budgets, and view spending analytics.

---

## Overview

AI Expense Tracker helps users manage personal finances by:

* Tracking expenses with category-based filtering and search
* Scanning receipts and auto-extracting merchant/amount/date/category via Gemini AI
* Setting monthly budgets per category with real-time spend tracking
* Viewing spending analytics on a dashboard (trend chart, category breakdown)

---

## Tech Stack

### Frontend

* Flutter
* Riverpod (state management)
* Dio (HTTP client)
* GoRouter (navigation)
* fl_chart (charts)

### Backend

* Laravel 12
* Laravel Sanctum (token auth)
* Eloquent ORM
* Service / Repository layer architecture

### Database

* MySQL (or SQLite for a quick local setup — see [backend/README.md](backend/README.md))

### AI

* Google Gemini API (receipt parsing)

---

## Architecture

### Mobile App

Feature-first structure:

```text
lib/
├── core         # shared: network client, theme, widgets, utils
├── config       # theme, router
├── features
│   ├── auth
│   ├── dashboard
│   ├── expense
│   ├── budget
│   ├── receipt
│   └── profile
└── main.dart
```

### Backend

```text
app/
├── Http/          # Controllers, Requests, Middleware
├── Models/
├── Services/       # business logic
├── Repositories/    # data access
├── Policies/        # per-resource ownership authorization
└── Exceptions/
```

---

## Key Features

**Authentication** — register, login, logout, profile.

**Expense Management** — create / update / delete expenses, search and filter, category-based tracking.

**Budget System** — monthly budget per category with real-time spend/remaining tracking.

**AI Receipt Scanner** — upload a receipt image, extract structured data (merchant, amount, date, suggested category) via Gemini, use it to pre-fill a new expense.

**Dashboard** — monthly summary vs. last month, weekly spending trend chart, category breakdown.

---

## Security

* Laravel Sanctum token authentication
* Ownership-based authorization via Policies (a user can only view/edit/delete their own expenses and budgets)
* Per-endpoint API rate limiting (tighter limits on writes than reads)
* Secure file upload validation for receipt images (mime type, size, private storage disk, randomized filenames)
* Gemini API key never leaves the backend — the mobile app never talks to Gemini directly

---

## API Overview

Base URL: `/api/v1`

| Endpoint | Description |
|---|---|
| `POST /auth/register`, `/auth/login`, `/auth/logout` | Authentication |
| `GET /auth/profile` | Current user |
| `GET/POST/PUT/DELETE /expenses` | Expense CRUD, search, filter |
| `GET/POST/DELETE /budgets` | Budget CRUD |
| `GET /dashboard` | Monthly summary, trend, category breakdown |
| `GET /categories` | Category list |
| `POST /receipts/scan` | Upload + AI-parse a receipt image |

Full request/response details: [docs/API_DESIGN.md](docs/API_DESIGN.md). Database schema: [docs/DATABASE_SCHEMA.md](docs/DATABASE_SCHEMA.md).

---

## Getting Started

Each subproject has its own setup guide with full details:

* **Backend** (Laravel API): [backend/README.md](backend/README.md)
* **Mobile** (Flutter app): [mobile/README.md](mobile/README.md)

Quick version:

```bash
# Backend
cd backend
composer install
cp .env.example .env
php artisan key:generate
# set GEMINI_API_KEY and your DB connection in .env, then:
php artisan migrate
php artisan serve

# Mobile (in a separate terminal)
cd mobile
flutter pub get
flutter run
```

---

## Testing

* **Backend**: PHPUnit — `php artisan test` (auth flow and service-layer coverage; still growing)
* **Mobile**: `flutter test` — widget tests are written ad hoc alongside features rather than kept as a standing suite

---

## CI/CD

GitHub Actions runs on every push/PR touching each subproject:

* **Backend CI**: PHPUnit tests, Pint code style check
* **Mobile CI**: `flutter analyze`, `flutter test`, debug APK build on `develop`

---

## Documentation

* [docs/API_DESIGN.md](docs/API_DESIGN.md) — full API request/response reference
* [docs/DATABASE_SCHEMA.md](docs/DATABASE_SCHEMA.md) — schema design and rationale

---

## Future Improvements

* Offline mode
* Push notifications
* PDF export
* AI spending prediction
* Editable profile (currency/timezone), password reset flow
