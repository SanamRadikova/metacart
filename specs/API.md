# API Specification (`API.md`)

> **Status**: Draft. Single inventory of every endpoint the Go backend exposes.
> Future work: each endpoint will move into the canonical `packages/shared/openapi/metacart-api.yaml` (ADR-019).

---

## 🌐 Conventions

* **Base path**: all endpoints are prefixed with `/api/v1/`.
* **Auth**: every endpoint except `/auth/*` requires a Bearer JWT in `Authorization: Bearer <token>`.
* **Errors**: standard JSON `{"code": "...", "message": "..."}` with HTTP codes from the table below.
* **Soft-delete**: every `GET` filters `WHERE deleted_at IS NULL`.
* **Idempotency**: `POST` is idempotent for the same `Idempotency-Key` header within 24h (auth + carts).

### HTTP error codes

| Code | Meaning |
|---|---|
| 400 | Validation error (missing/invalid field) |
| 401 | Missing or invalid JWT |
| 403 | Email not verified, or consent not yet given |
| 404 | Resource not found |
| 409 | Conflict (e.g. email already exists) |
| **412** | **Precondition Failed** — `users.research_group IS NULL`, baseline onboarding not complete |
| 422 | Unprocessable (e.g. OCR confidence too low) |
| 500 | Unexpected server error |

---

## 🔐 1. Authentication & Onboarding (`/auth`, `/consent`)

| Method | Endpoint | Purpose | Auth | Notes |
|---|---|---|---|---|
| GET | `/auth/me` | Return current user profile | ✅ | Used by app on launch to refresh state |
| POST | `/auth/register` | Create user with email/password/date_of_birth | — | Validates age 18-65; `research_group` left NULL |
| POST | `/auth/login` | Email/password → JWT pair | — | 5 wrong attempts lock account 15 min |
| POST | `/auth/refresh` | Refresh access token | — | Uses refresh token |
| POST | `/auth/logout` | Invalidate session | ✅ | |
| POST | `/auth/forgot-password` | Send reset email | — | |
| POST | `/auth/reset-password` | Set new password using reset token | — | |
| POST | `/auth/verify-email` | Confirm email after registration | — | Returns 200 only after verification |
| POST | `/consent` | Record IRB consent (version + hash + IP + UA) | ✅ | `skipped=true` → user enters "explore-only" mode |
| DELETE | `/consent` | Withdraw consent (soft-deletes user & all related records) | ✅ | ADR-009 soft-delete cascade |

---

## 🧪 2. Lab Results (`/labs`)

| Method | Endpoint | Purpose | Notes |
|---|---|---|---|
| POST | `/labs/upload` | Upload PDF/photo (multipart) | Returns `lab_result_id` with `processing_status='processing'` |
| GET | `/labs/{id}/status` | Poll OCR pipeline | `processing_status` = pending/processing/needs_review/completed/failed |
| GET | `/labs/{id}` | Get lab_values for review | Includes `value_original`, `value_normalized`, `unit_original` |
| POST | `/labs/manual` | Manual entry (bypass OCR) | Required: glucose, hba1c, tg, hdl |
| PUT | `/labs/{id}/values` | Edit OCR-extracted values | Used by E4a OCR Review screen |
| POST | `/labs/{id}/confirm` | Finalize values | Triggers `EvaluateAllAxes` + `EvaluateResearchGroup` if baseline |
| GET | `/labs` | List all lab_results for user | Paginated, default timepoint order |
| GET | `/labs/{id}/axes` | Get axis_evaluations for this lab | Triggers re-eval if stale |

---

## 🌍 3. Cultural Profile (`/cultural-profile`)

| Method | Endpoint | Purpose | Notes |
|---|---|---|---|
| POST | `/cultural-profile` | Create cultural profile | `primary_culture` is snake_case (eastern_european, …) |
| GET | `/cultural-profile` | Get current profile | |
| PUT | `/cultural-profile` | Update profile | Triggers re-generation of cart and menu |
| DELETE | `/cultural-profile` | Soft-delete | Sets `deleted_at` |

---

## ⚙️ 4. Engine — Axes & Profiles (`/axes`, `/profiles`)

| Method | Endpoint | Purpose | Notes |
|---|---|---|---|
| GET | `/axes` | Get 5 axis statuses + data_completeness | `axes_analyzed`/`axes_total` ratio returned |
| GET | `/axes/{n}` | Detailed view of single axis | Includes thresholds used (cultural-specific) |
| POST | `/axes/re-evaluate` | Force re-evaluation | Typically automatic on lab confirmation |
| GET | `/profiles/active` | Get current active profile | Returns modifiers + hormonal_modifier |
| GET | `/profiles` | Profile history (transitions) | Ordered by `created_at` DESC |
| POST | `/profiles/{id}/transition` | Manual override (admin) | Phase 2 only |

---

## 🛒 5. Cart & Menu (`/menu`, `/cart`)

| Method | Endpoint | Purpose | Notes |
|---|---|---|---|
| GET | `/menu` | Get current 7-day menu | In-memory or pre-rendered table |
| POST | `/menu/regenerate` | Force re-generation | Uses current profile + cultural |
| GET | `/cart` | Get recommended cart | **Returns 412 if `research_group IS NULL`** |
| POST | `/cart` | Create recommended cart | body: `{budget_tier, household_size}` |
| PUT | `/cart/{id}` | Update cart settings | |
| GET | `/cart/{id}/items` | Get cart_items list | Grouped by category |
| GET | `/cart/{id}/export?format=csv\|pdf` | Export cart | Returns file blob |
| DELETE | `/cart/{id}` | Soft-delete cart | |

---

## 🧾 6. Actual Purchases & OCR (`/purchases`)

| Method | Endpoint | Purpose | Notes |
|---|---|---|---|
| POST | `/purchases` | Create actual_purchase (manual entry) | `capture_method='manual'` |
| POST | `/purchases/receipt` | Upload receipt photo | `capture_method='receipt_photo'`, `ocr_status='uploaded'` |
| GET | `/purchases/{id}/ocr-status` | Poll OCR pipeline | `uploaded`/`ocr_processing`/`needs_review`/`confirmed`/`failed` |
| PUT | `/purchases/{id}/ocr-corrections` | Save user corrections to OCR items | After review screen E4.2 |
| POST | `/purchases/{id}/confirm` | Confirm OCR items | Triggers matching + drift analysis |
| POST | `/purchases/{id}/retry-ocr` | Retry failed OCR | Resets `ocr_status='uploaded'` |
| GET | `/purchases` | List actual_purchases | Paginated |
| GET | `/purchases/{id}/items` | Get purchase_items | With match_status (matches/drift/excluded) |
| POST | `/purchases/{id}/items` | Add manual item | |
| DELETE | `/purchases/{id}` | Soft-delete purchase | |

---

## 📊 7. Drift Analysis (`/drift`) — CORE

| Method | Endpoint | Purpose | Notes |
|---|---|---|---|
| GET | `/drift` | Get drift dashboard (last 4 weeks) | weekly trend + current match% |
| GET | `/drift/weekly/{week}` | Get drift_analyses for a week | Includes `grocery_stability_score` (TBD formula) |
| GET | `/drift/{id}/items` | Detailed drift_items (added/missing/excluded) | With `health_impact` |
| POST | `/drift/recompute/{purchase_id}` | Force re-computation | After purchase item edits |
| GET | `/drift/insights` | Get behavioral insights | E.g. "You often buy white bread" |

---

## ❤️ 8. Devices & Wearables (`/devices`, `/readings`)

| Method | Endpoint | Purpose | Notes |
|---|---|---|---|
| POST | `/devices/connect` | Connect Apple Health / Google Fit | `device_type` enum: `apple_health`, `google_fit` |
| GET | `/devices` | List device_connections | |
| DELETE | `/devices/{id}` | Disconnect | Soft-delete |
| POST | `/readings/ingest` | Batch insert device_readings (background) | Used by mobile sync job |
| GET | `/readings/hrv?from=...&to=...` | HRV time series | Uses `reading_type='hrv_rmssd'` |
| GET | `/readings/cgm?from=...&to=...` | CGM glucose series | Includes `dg_dt` and `dg_dt_status` |
| GET | `/readings/dg-dt/status` | Current dG/dt | Returns one of 6 statuses |

---

## ♀️ 9. Hormonal Status (`/hormonal-status`)

| Method | Endpoint | Purpose | Notes |
|---|---|---|---|
| POST | `/hormonal-status` | Set initial status | `status` enum: `follicular`/`pms`/`perimenopause`/`postmenopause`/`not_applicable` |
| GET | `/hormonal-status` | Get current | Includes `threshold_modifier` |
| PUT | `/hormonal-status` | Update (cycle phase changes) | Triggers profile re-eval |

---

## 🩺 10. Symptoms (`/symptoms`)

| Method | Endpoint | Purpose | Notes |
|---|---|---|---|
| POST | `/symptoms` | Log a new symptom | body: `{symptoms[], severity, hunger_level, ...}` |
| GET | `/symptoms` | List symptom_logs | Paginated by `created_at` |
| GET | `/symptoms/recent` | Last 24h symptoms | Used by Profile 5 trigger check |

---

## 🔔 11. Notifications (`/notifications`)

| Method | Endpoint | Purpose | Notes |
|---|---|---|---|
| GET | `/notifications` | List user notifications | |
| PUT | `/notifications/{id}/read` | Mark as read | |
| GET | `/notifications/preferences` | Get toggles per type | |
| PUT | `/notifications/preferences` | Update toggles | HRV/meal/post-dinner walk |

---

## 🧬 12. Research Group Lifecycle (`/research-group`)

| Method | Endpoint | Purpose | Notes |
|---|---|---|---|
| GET | `/research-group` | Get current `users.research_group` | Returns NULL until first baseline |
| POST | `/research-group/evaluate` | Manually trigger `EvaluateResearchGroup()` | Usually called automatically after baseline labs + symptoms |

---

## 👤 13. Account Management (`/account`)

| Method | Endpoint | Purpose | Notes |
|---|---|---|---|
| GET | `/account` | Get account details | |
| PUT | `/account` | Update email/password | |
| POST | `/account/deactivate` | Soft-delete account (ADR-009) | Reversible by support |
| POST | `/account/delete` | Hard delete after retention period | 7-year retention for IRB |
| GET | `/account/audit-log` | Get user's audit log entries | |

---

## 📦 14. Products Catalog (`/products`)

| Method | Endpoint | Purpose | Notes |
|---|---|---|---|
| GET | `/products` | List products (with filters) | Filter by `category`, `is_nutraceutical`, `profile_tags` |
| GET | `/products/{id}` | Get single product | Includes `nutritional_data` |
| GET | `/products/search?q=...` | Fuzzy text search | Used by OCR match review |
| POST | `/products` | Admin: create product | |
| PUT | `/products/{id}` | Admin: update product | |
| POST | `/products/sync` | Trigger Open Food Facts / USDA sync | Cron-triggered usually |

---

## 🩻 15. Reference Data (`/reference`)

| Method | Endpoint | Purpose | Notes |
|---|---|---|---|
| GET | `/reference/ranges` | Get reference_ranges | Filter by `biomarker`, `cultural_group`, `gender` |
| GET | `/reference/cultural-patterns` | Get cultural_food_patterns | |
| GET | `/reference/units` | Get lab_units_reference | |
| POST | `/reference/ranges` | Admin: upsert range | |

---

## 🧪 16. Health (`/health`)

| Method | Endpoint | Purpose | Notes |
|---|---|---|---|
| GET | `/health` | Service health | Returns DB connectivity status |
| GET | `/health/ready` | Readiness probe | For K8s/Cloud Run |

---

## 📋 Endpoint summary by feature area

| Feature area | # Endpoints |
|---|---|
| Auth & Onboarding | 9 |
| Labs | 8 |
| Cultural Profile | 4 |
| Engine (axes + profiles) | 6 |
| Cart & Menu | 8 |
| Purchases & OCR | 9 |
| Drift (CORE) | 5 |
| Devices & Wearables | 7 |
| Hormonal | 3 |
| Symptoms | 3 |
| Notifications | 4 |
| Research Group | 2 |
| Account | 5 |
| Products | 6 |
| Reference | 4 |
| Health | 2 |
| **Total** | **~85** |
