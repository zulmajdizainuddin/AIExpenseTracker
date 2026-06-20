# API Design

## Base URL

```
http://localhost/api/v1
```

## Authentication

All protected routes require:

```
Authorization: Bearer {token}
Accept: application/json
```

---

## Response Format

All responses follow this structure:

```json
{
  "success": true | false,
  "message": "Human-readable message",
  "data": {} | [] | null,
  "errors": {}
}
```

---

## HTTP Status Codes

| Code | Meaning            |
|------|--------------------|
| 200  | OK                 |
| 201  | Created            |
| 401  | Unauthenticated    |
| 403  | Forbidden          |
| 404  | Not Found          |
| 422  | Validation Error   |
| 429  | Too Many Requests  |
| 500  | Server Error       |

---

## Endpoints

### Auth

#### POST /api/v1/auth/register

Rate limit: 10 req/min

Request:
```json
{
  "name": "Ahmad Zulmajdi",
  "email": "ahmad@example.com",
  "password": "password123",
  "password_confirmation": "password123",
  "currency": "MYR",
  "timezone": "Asia/Kuala_Lumpur"
}
```

Response `201`:
```json
{
  "success": true,
  "message": "Account created successfully.",
  "data": {
    "user": { "id": 1, "name": "Ahmad Zulmajdi", "email": "ahmad@example.com" },
    "token": "1|abc123..."
  }
}
```

---

#### POST /api/v1/auth/login

Rate limit: 10 req/min

Request:
```json
{
  "email": "ahmad@example.com",
  "password": "password123"
}
```

Response `200`:
```json
{
  "success": true,
  "message": "Login successful.",
  "data": {
    "user": { "id": 1, "name": "Ahmad Zulmajdi", "email": "ahmad@example.com" },
    "token": "2|xyz789..."
  }
}
```

---

#### POST /api/v1/auth/logout

Response `200`:
```json
{
  "success": true,
  "message": "Logged out successfully.",
  "data": null
}
```

---

#### GET /api/v1/auth/profile

Response `200`:
```json
{
  "success": true,
  "message": "Operation successful",
  "data": {
    "id": 1,
    "name": "Ahmad Zulmajdi",
    "email": "ahmad@example.com",
    "currency": "MYR",
    "timezone": "Asia/Kuala_Lumpur"
  }
}
```

---

### Categories

#### GET /api/v1/categories

Response `200`:
```json
{
  "success": true,
  "data": [
    { "id": 1, "name": "Food & Dining", "icon": "restaurant", "color": "#f59e0b" },
    { "id": 2, "name": "Transportation", "icon": "directions_car", "color": "#3b82f6" }
  ]
}
```

---

### Expenses

#### GET /api/v1/expenses

Query params: `category_id`, `from` (YYYY-MM-DD), `to` (YYYY-MM-DD), `search`, `page`, `per_page`

Response `200` (paginated):
```json
{
  "success": true,
  "data": {
    "current_page": 1,
    "data": [
      {
        "id": 1,
        "title": "Lunch at Nasi Kandar",
        "amount": "12.50",
        "transaction_date": "2024-01-15",
        "note": null,
        "category": { "id": 1, "name": "Food & Dining", "color": "#f59e0b" }
      }
    ],
    "per_page": 15,
    "total": 42
  }
}
```

---

#### POST /api/v1/expenses

Request:
```json
{
  "category_id": 1,
  "title": "Lunch at Nasi Kandar",
  "amount": 12.50,
  "transaction_date": "2024-01-15",
  "note": "With colleague"
}
```

Response `201`:
```json
{
  "success": true,
  "message": "Expense created.",
  "data": { "id": 5, "title": "Lunch at Nasi Kandar", ... }
}
```

---

#### PUT /api/v1/expenses/{id}

Partial update. Only include fields to change.

---

#### DELETE /api/v1/expenses/{id}

Response `200`:
```json
{ "success": true, "message": "Expense deleted.", "data": null }
```

---

### Dashboard

#### GET /api/v1/dashboard

Response `200`:
```json
{
  "success": true,
  "data": {
    "current_month": {
      "total": 1250.00,
      "count": 34,
      "average": 36.76,
      "year": 2024,
      "month": 1
    },
    "previous_month": { "total": 980.00, "count": 28, ... },
    "category_breakdown": [
      { "category": { "id": 1, "name": "Food & Dining" }, "total": 450.00, "count": 15 }
    ],
    "weekly_trend": [
      { "date": "2024-01-15", "total": 120.00 }
    ],
    "top_categories": [...]
  }
}
```

---

### Budgets

#### GET /api/v1/budgets?year=2024&month=1

Response `200`:
```json
{
  "success": true,
  "data": [
    {
      "budget": { "id": 1, "category_id": 1, "amount": "500.00", "month": 1, "year": 2024, "category": {...} },
      "spent": 450.00,
      "remaining": 50.00,
      "percent": 90.0
    }
  ]
}
```

---

#### POST /api/v1/budgets

Upserts the budget (creates or updates for same category/month/year).

Request:
```json
{
  "category_id": 1,
  "amount": 500.00,
  "month": 1,
  "year": 2024
}
```

---

#### DELETE /api/v1/budgets/{id}

---

### Receipts

#### POST /api/v1/receipts/scan

Rate limit: 5 req/min per user

Content-Type: `multipart/form-data`

Form field: `image` (file, max 5MB, JPEG/PNG/WebP)

Response `201`:
```json
{
  "success": true,
  "message": "Receipt scanned successfully.",
  "data": {
    "receipt": {
      "id": 1,
      "merchant_name": "AEON Big Subang",
      "amount": "87.50",
      "receipt_date": "2024-01-15",
      "category_suggestion": "Shopping",
      "processing_status": "completed"
    },
    "ai_data": {
      "merchant_name": "AEON Big Subang",
      "amount": 87.50,
      "date": "2024-01-15",
      "category_suggestion": "Shopping"
    }
  }
}
```

---

## Rate Limiting

| Endpoint                   | Limit        |
|----------------------------|------------- |
| POST /auth/register        | 10 req/min   |
| POST /auth/login           | 10 req/min   |
| All protected routes       | 60 req/min   |
| POST /receipts/scan        | 5 req/min    |
