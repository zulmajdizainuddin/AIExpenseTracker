# AI Expense Tracker — Backend

Laravel 12 REST API for the [AI Expense Tracker + Receipt Scanner](../README.md) project. Token authentication via Sanctum, expense/budget management, dashboard analytics, and AI receipt parsing via Google Gemini.

See the [root README](../README.md) for the project overview and the [mobile README](../mobile/README.md) for the Flutter client.

## Requirements

* PHP 8.2+
* Composer
* A database — SQLite (zero setup) or MySQL
* A [Gemini API key](https://aistudio.google.com/apikey) (free tier is fine) for receipt scanning

## Setup

```bash
composer install
cp .env.example .env
php artisan key:generate
```

Edit `.env`:

* `GEMINI_API_KEY` — your Gemini API key (receipt scanning will fail without this)
* `DB_CONNECTION` — defaults to `sqlite`, which needs no further setup. To use MySQL instead, set `DB_CONNECTION=mysql` and fill in `DB_HOST`/`DB_DATABASE`/`DB_USERNAME`/`DB_PASSWORD`, then create the database first.

Then run migrations and start the dev server:

```bash
php artisan migrate
php artisan serve
```

The API is now available at `http://127.0.0.1:8000/api/v1`.

## Connecting the mobile app

The Flutter app's `API_BASE_URL` needs to point at wherever this server is reachable from, which depends on what you're running the app on — see [mobile/README.md](../mobile/README.md#configuring-the-api-url) for the exact value for an emulator, a physical device, or a browser.

## Testing

```bash
php artisan test
```

## Code style

This project uses [Laravel Pint](https://laravel.com/docs/pint):

```bash
./vendor/bin/pint
```

## API documentation

Full request/response reference: [../docs/API_DESIGN.md](../docs/API_DESIGN.md). Schema design: [../docs/DATABASE_SCHEMA.md](../docs/DATABASE_SCHEMA.md).
