# Database Schema

## Entity Relationship Diagram

```
users
 ├── expenses (user_id FK)
 │    └── receipts (expense_id FK, nullable)
 ├── budgets  (user_id FK)
 └── receipts (user_id FK)

categories
 ├── expenses (category_id FK)
 └── budgets  (category_id FK)
```

---

## Tables

### `users`

| Column         | Type            | Constraints                          |
|----------------|-----------------|--------------------------------------|
| id             | BIGINT UNSIGNED | PK, AUTO_INCREMENT                   |
| name           | VARCHAR(255)    | NOT NULL                             |
| email          | VARCHAR(255)    | NOT NULL, UNIQUE                     |
| password       | VARCHAR(255)    | NOT NULL                             |
| currency       | CHAR(3)         | NOT NULL, DEFAULT 'MYR'              |
| timezone       | VARCHAR(50)     | NOT NULL, DEFAULT 'Asia/KL'          |
| email_verified_at | TIMESTAMP   | NULLABLE                             |
| remember_token | VARCHAR(100)    | NULLABLE                             |
| created_at     | TIMESTAMP       |                                      |
| updated_at     | TIMESTAMP       |                                      |

---

### `categories`

| Column     | Type            | Constraints                      |
|------------|-----------------|----------------------------------|
| id         | BIGINT UNSIGNED | PK, AUTO_INCREMENT               |
| name       | VARCHAR(100)    | NOT NULL                         |
| icon       | VARCHAR(50)     | NULLABLE                         |
| color      | CHAR(7)         | NOT NULL, DEFAULT '#6366f1'      |
| is_default | TINYINT(1)      | NOT NULL, DEFAULT 0              |
| created_at | TIMESTAMP       |                                  |
| updated_at | TIMESTAMP       |                                  |

**Index:** `is_default`

---

### `expenses`

| Column           | Type            | Constraints                              |
|------------------|-----------------|------------------------------------------|
| id               | BIGINT UNSIGNED | PK, AUTO_INCREMENT                       |
| user_id          | BIGINT UNSIGNED | FK → users(id) CASCADE DELETE            |
| category_id      | BIGINT UNSIGNED | FK → categories(id) RESTRICT DELETE      |
| title            | VARCHAR(200)    | NOT NULL                                 |
| amount           | DECIMAL(12,2)   | NOT NULL                                 |
| note             | TEXT            | NULLABLE                                 |
| transaction_date | DATE            | NOT NULL                                 |
| created_at       | TIMESTAMP       |                                          |
| updated_at       | TIMESTAMP       |                                          |
| deleted_at       | TIMESTAMP       | NULLABLE (soft delete)                   |

**Indexes:**
- `(user_id, transaction_date)`
- `(user_id, category_id)`

---

### `budgets`

| Column      | Type              | Constraints                              |
|-------------|-------------------|------------------------------------------|
| id          | BIGINT UNSIGNED   | PK, AUTO_INCREMENT                       |
| user_id     | BIGINT UNSIGNED   | FK → users(id) CASCADE DELETE            |
| category_id | BIGINT UNSIGNED   | FK → categories(id) RESTRICT DELETE      |
| amount      | DECIMAL(12,2)     | NOT NULL                                 |
| month       | TINYINT UNSIGNED  | NOT NULL (1–12)                          |
| year        | SMALLINT UNSIGNED | NOT NULL (2020–2099)                     |
| created_at  | TIMESTAMP         |                                          |
| updated_at  | TIMESTAMP         |                                          |

**Unique:** `(user_id, category_id, month, year)`
**Index:** `(user_id, year, month)`

---

### `receipts`

| Column              | Type            | Constraints                              |
|---------------------|-----------------|------------------------------------------|
| id                  | BIGINT UNSIGNED | PK, AUTO_INCREMENT                       |
| user_id             | BIGINT UNSIGNED | FK → users(id) CASCADE DELETE            |
| expense_id          | BIGINT UNSIGNED | FK → expenses(id) SET NULL, NULLABLE     |
| file_path           | VARCHAR(500)    | NOT NULL                                 |
| merchant_name       | VARCHAR(200)    | NULLABLE                                 |
| amount              | DECIMAL(12,2)   | NULLABLE                                 |
| receipt_date        | DATE            | NULLABLE                                 |
| category_suggestion | VARCHAR(100)    | NULLABLE                                 |
| raw_ai_response     | LONGTEXT        | NULLABLE                                 |
| processing_status   | ENUM(pending, completed, failed) | DEFAULT 'pending'  |
| created_at          | TIMESTAMP       |                                          |
| updated_at          | TIMESTAMP       |                                          |

**Indexes:** `user_id`, `expense_id`

---

## Key Design Decisions

1. **Soft deletes on expenses** — preserve financial history even when users "delete" entries.
2. **DECIMAL(12,2) for amounts** — avoids floating-point precision errors in currency calculations.
3. **Unique constraint on budgets** — prevents duplicate budgets per category/period at DB level.
4. **`expense_id` nullable on receipts** — allows scanning a receipt before creating the expense.
5. **Private file storage for receipts** — images stored on `private` disk, never publicly accessible.
6. **`raw_ai_response` hidden in model** — prevents accidental exposure of AI internals in API responses.
