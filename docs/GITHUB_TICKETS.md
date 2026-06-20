# GitHub Issues — Sprint 1 Tickets

---

## #001 — [backend] Setup Laravel project with Sanctum authentication

**Labels:** `backend`, `auth`, `setup`

**Description:**

Scaffold the Laravel 12 backend with Sanctum token-based authentication. This is the foundation for all protected API endpoints.

**Acceptance Criteria:**

- [ ] `POST /api/v1/auth/register` registers a new user and returns a Sanctum token
- [ ] `POST /api/v1/auth/login` returns a token on valid credentials, 401 on invalid
- [ ] `POST /api/v1/auth/logout` revokes the current token
- [ ] `GET /api/v1/auth/profile` returns the authenticated user
- [ ] Auth routes are rate-limited to 10 requests/minute
- [ ] All responses use the `ApiResponse` trait format `{ success, message, data }`
- [ ] Form Requests used for login and register validation (not controller)
- [ ] Unit test: login with wrong credentials returns 401
- [ ] Feature test: register → login → logout flow passes

---

## #002 — [backend] Implement Expense CRUD API

**Labels:** `backend`, `expense`

**Description:**

Build the full expense management API with filtering, pagination, and ownership enforcement. Must follow Fat Service, Thin Controller pattern.

**Acceptance Criteria:**

- [ ] `GET /api/v1/expenses` returns paginated list for authenticated user only
- [ ] Supports filters: `category_id`, `from`, `to`, `search`
- [ ] `POST /api/v1/expenses` creates expense with `StoreExpenseRequest` validation
- [ ] `PUT /api/v1/expenses/{id}` updates expense; returns 403 if not owner
- [ ] `DELETE /api/v1/expenses/{id}` soft-deletes expense; returns 403 if not owner
- [ ] `ExpensePolicy` enforces resource ownership
- [ ] `ExpenseRepository` handles all Eloquent queries (not the service)
- [ ] Unit test: deleting another user's expense throws `ModelNotFoundException`
- [ ] Feature test: CRUD flow for authenticated user passes

---

## #003 — [backend] Implement Budget management API

**Labels:** `backend`, `budget`

**Description:**

Build the budget management system with upsert logic (one budget per category per month/year). Include live spending calculation against actual expenses.

**Acceptance Criteria:**

- [ ] `GET /api/v1/budgets?year=&month=` returns budget summary with `spent`, `remaining`, `percent`
- [ ] `POST /api/v1/budgets` creates or updates budget for same category/month/year
- [ ] `DELETE /api/v1/budgets/{id}` deletes a budget; enforces ownership
- [ ] DB unique constraint prevents duplicate budgets
- [ ] `BudgetService::getSummary` computes `spent` from actual expense records
- [ ] Unit test: budget summary returns correct `percent` calculation

---

## #004 — [backend][ai] Implement AI Receipt Scanner endpoint

**Labels:** `backend`, `ai`, `security`

**Description:**

Build the receipt scanning endpoint that securely receives an uploaded image, sends it to the Gemini API via the backend only, and stores the extracted data. The frontend must never call the Gemini API directly.

**Acceptance Criteria:**

- [ ] `POST /api/v1/receipts/scan` accepts `multipart/form-data` with `image` field
- [ ] Validates: only JPEG/PNG/WebP, max 5MB (rejected at `ScanReceiptRequest` level)
- [ ] Image stored in private disk with randomised filename (prevents path traversal)
- [ ] `GeminiService` sends image to `gemini-2.5-flash` with structured prompt
- [ ] Returns `merchant_name`, `amount`, `date`, `category_suggestion`
- [ ] Rate limit: 5 requests/minute per user
- [ ] If Gemini fails, image is deleted and a `RuntimeException` is thrown
- [ ] `raw_ai_response` is hidden from API response (only stored in DB)
- [ ] Feature test: upload valid JPEG returns `processing_status: completed`

---

## #005 — [backend] Implement Dashboard summary API

**Labels:** `backend`

**Description:**

Build the `/dashboard` endpoint that aggregates current month spending, previous month comparison, category breakdown, and weekly trend in a single API call.

**Acceptance Criteria:**

- [ ] `GET /api/v1/dashboard` returns all summary data in one request
- [ ] `current_month.total` matches sum of authenticated user's expenses for current month
- [ ] `category_breakdown` sorted by total descending
- [ ] `weekly_trend` shows spending by day for current week
- [ ] Response time under 200ms for users with ≤ 500 expenses (optimised queries, proper indexes)
- [ ] Uses `DB::raw` aggregations, not Eloquent collection loops for performance
- [ ] Feature test: dashboard returns expected structure for a seeded user

---

## #006 — [frontend] Setup Flutter app with Riverpod and GoRouter

**Labels:** `frontend`, `setup`

**Description:**

Scaffold the Flutter app with feature-first folder structure, Riverpod for state management, and GoRouter for navigation with auth guard.

**Acceptance Criteria:**

- [ ] App initialises with `ProviderScope` wrapping root
- [ ] `GoRouter` redirects unauthenticated users to `/auth/login`
- [ ] `GoRouter` redirects authenticated users away from auth routes to `/dashboard`
- [ ] Bottom navigation bar with 5 tabs: Dashboard, Expenses, Scan, Budgets, Profile
- [ ] `DioClient` with `_AuthInterceptor` injects `Authorization: Bearer` header
- [ ] `FlutterSecureStorage` used for token persistence (not SharedPreferences)
- [ ] Auth state survives app restart (loaded from secure storage on startup)
- [ ] Theme uses Material 3 with `useMaterial3: true`

---

## #007 — [frontend] Implement Login and Registration screens

**Labels:** `frontend`, `auth`

**Description:**

Build the login and registration screens with form validation and proper error handling from the API. No business logic in widgets.

**Acceptance Criteria:**

- [ ] Login screen validates: email format, password required
- [ ] Register screen validates: name required, valid email, password min 8 chars
- [ ] Loading state shown on FilledButton while request is in progress
- [ ] API error message from `Failure.message` shown in a SnackBar
- [ ] Successful login navigates to `/dashboard` (via GoRouter redirect, not manual `context.go`)
- [ ] `AuthNotifier` handles all state transitions (loading → success / error)
- [ ] Widget test: submitting empty form shows validation errors (no API call made)

---

## #008 — [frontend] Build Expense List and Create Expense screens

**Labels:** `frontend`, `expense`

**Description:**

Build the expense list with pull-to-refresh and the expense creation form. Providers handle all state; widgets only render and trigger actions.

**Acceptance Criteria:**

- [ ] Expense list shows: title, category, date, amount (formatted as `RM X.XX`)
- [ ] Pull-to-refresh calls `expenseListProvider.notifier.refresh()`
- [ ] Swipe-to-delete or popup menu with confirmation dialog before delete
- [ ] Expense form: title, amount, category dropdown (from API), date picker, optional note
- [ ] Category dropdown populated via `categoriesProvider`
- [ ] Date picker prevents selecting future dates
- [ ] On save success, invalidates `expenseListProvider` (list auto-refreshes)
- [ ] Empty state message shown when no expenses exist
- [ ] Widget test: form submits with valid data calls provider once

---

## #009 — [frontend][ai] Build AI Receipt Scanner screen

**Labels:** `frontend`, `ai`

**Description:**

Build the receipt scanning screen that lets users pick or photograph a receipt, send it to the backend, and display AI-extracted data. Users can then create an expense from the result.

**Acceptance Criteria:**

- [ ] Camera and gallery pick options via `image_picker`
- [ ] Image preview shown after selection
- [ ] "Scan with AI" button disabled until an image is selected
- [ ] Loading state shown during scan (button disabled, indicator shown)
- [ ] AI result displayed: merchant name, amount, date, category suggestion
- [ ] Error state shown (e.g., "Scan failed") when API returns error
- [ ] "Create Expense from Receipt" button pre-fills `ExpenseFormScreen`
- [ ] `ScanReceiptNotifier.reset()` called when user picks a new image
- [ ] Widget test: selecting image enables Scan button

---

## #010 — [frontend] Build Budget screen with monthly view

**Labels:** `frontend`, `budget`

**Description:**

Build the budget management screen showing progress bars for each category against the monthly budget. Allow creating/updating budgets via a bottom sheet.

**Acceptance Criteria:**

- [ ] Month navigation (prev/next) updates displayed data without full reload
- [ ] Each budget card shows: category name, progress bar, amount spent, total budget, percentage
- [ ] Progress bar turns red when spending exceeds 100% of budget
- [ ] "Add Budget" bottom sheet: category dropdown + amount field
- [ ] Save triggers `createBudgetProvider` (upserts via API)
- [ ] After save, `budgetProvider` is invalidated to refresh the list
- [ ] Empty state: "No budgets set. Tap + to add one."
- [ ] Currency formatted as `RM X.XX` using `intl` package
- [ ] Widget test: progress bar renders red when percent > 100
