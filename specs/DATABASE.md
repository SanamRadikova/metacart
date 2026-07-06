# Database Schema Specification (`DATABASE.md`)

This specification defines the complete database schema for the MetaCart application, designed to run on **Supabase (PostgreSQL 15+)**. It implements all required architectural patterns including soft-deletion for IRB audit trails, monthly range partitioning for high-frequency wearable readings, ethnic and gender reference range parameters, and receipt OCR pipeline tracking.

> **Source of truth**: the SQL in `db/schema.sql`. This markdown mirrors that file. If they ever drift, `db/schema.sql` wins.

---

## 🔑 Design Patterns

### 1. IRB Soft-Delete Compliance
All user-related tables include the `deleted_at TIMESTAMPTZ NULL` field.

| User-related tables with `deleted_at` |
|---|
| `users`, `research_consents`, `cultural_profiles`, `hormonal_statuses` |
| `lab_results`, `lab_values`, `device_connections`, `device_readings` |
| `axis_evaluations`, `profiles`, `recommended_carts`, `actual_purchases`, `drift_analyses` |
| `symptom_logs` |

* **Rule:** Application and reporting queries must filter `WHERE deleted_at IS NULL`.
* **Traceability:** Soft-deleted records preserve the historical cohort audit trail as required by the study protocols.
* **Indexing:** Partial indexes (`WHERE deleted_at IS NULL`) on every user-related table for active-row queries.

### 2. Native PostgreSQL Range Partitioning (pg_partman)
The `device_readings` table is partitioned natively by range on the `timestamp` field.
* Partition interval: **1 month**.
* Auto-creation of partitions is managed via the **`pg_partman`** extension.
* PK is `BIGSERIAL id` (not composite) for simpler partitioning; uniqueness is enforced by `UNIQUE (timestamp, user_id, reading_type)`.
* Retention: 12 months; older partitions are detached by pg_partman's `run_maintenance()`.

### 3. Factorial Cohort Allocation
* `users.date_of_birth` requires the user to be between **18 and 65 years old** at registration.
* `users.research_group` enforces the **2x2 Factorial Design** groups: `A`, `B`, `C`, or `D`.
* `users.research_group` is **NULL until `EvaluateResearchGroup()` runs** in Go after baseline labs + symptom log.
* While `research_group IS NULL` the backend returns **412 Precondition Failed** for any cart-generation request.

### 4. Cultural Group Convention
* Stored in DB as **snake_case**: `eastern_european`, `south_asian`, `latino`, `african_american`, `east_asian`, `standard_american`.
* UI displays Title Case (`Eastern European`, `South Asian`, etc.).
* `reference_ranges.cultural_group` accepts these values **plus** `'general'` as the fallback for any culture without a custom row.

### 5. Engine Status Enums
| Field | Values |
|---|---|
| `axis_status` (lab_values) | `green`, `yellow`, `orange` |
| `dg_dt_status` (device_readings) | `rising_fast`, `rising`, `steady`, `falling_slowly`, `falling`, `falling_fast` |
| `data_completeness` (axis_evaluations) | `minimal` (2/5), `basic` (4/5), `extended` (5/5 + HRV), `full` (5/5 + CGM + hormonal) |
| `processing_status` (lab_results) | `pending`, `processing`, `needs_review`, `completed`, `failed` |
| `ocr_status` (actual_purchases) | `uploaded`, `ocr_processing`, `needs_review`, `confirmed`, `failed` |

---

## 🗄️ Database DDL Schema

```sql
-- Enable necessary PostgreSQL extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pg_partman";

-- ==========================================
-- 1. CORE USER AND CONSENT TABLES
-- ==========================================

CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email VARCHAR(255) UNIQUE NOT NULL,
    gender VARCHAR(10) NOT NULL CHECK (gender IN ('male', 'female', 'other')),
    date_of_birth DATE NOT NULL,
    cohort_type VARCHAR(30) NOT NULL DEFAULT 'standard' CHECK (cohort_type IN ('standard', 'deep_tracking')),
    cultural_group VARCHAR(30) NOT NULL CHECK (cultural_group IN (
        'eastern_european', 'south_asian', 'latino',
        'african_american', 'east_asian', 'standard_american'
    )),
    research_group VARCHAR(1) NULL CHECK (research_group IN ('A', 'B', 'C', 'D')),
    onboarding_completed BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at TIMESTAMPTZ NULL,
    CONSTRAINT age_eligibility CHECK (
        EXTRACT(YEAR FROM AGE(NOW(), date_of_birth)) >= 18 AND
        EXTRACT(YEAR FROM AGE(NOW(), date_of_birth)) <= 65
    )
);

CREATE TABLE research_consents (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    consent_version VARCHAR(20) NOT NULL,
    consent_text_hash VARCHAR(64) NOT NULL,
    agreed_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    withdrew_at TIMESTAMPTZ NULL,
    deleted_at TIMESTAMPTZ NULL
);

CREATE TABLE cultural_profiles (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID UNIQUE NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    primary_culture VARCHAR(50) NOT NULL,
    staple_foods JSONB NOT NULL DEFAULT '[]'::jsonb,
    dietary_restrictions JSONB NOT NULL DEFAULT '[]'::jsonb,
    household_size SMALLINT NOT NULL DEFAULT 1 CHECK (household_size BETWEEN 1 AND 6),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at TIMESTAMPTZ NULL
);

CREATE TABLE hormonal_statuses (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID UNIQUE NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    status VARCHAR(40) NOT NULL CHECK (status IN ('follicular', 'pms', 'perimenopause', 'postmenopause', 'not_applicable')),
    threshold_modifier NUMERIC(3,2) NOT NULL DEFAULT 1.00 CHECK (threshold_modifier BETWEEN 0.50 AND 1.50),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at TIMESTAMPTZ NULL
);

-- ==========================================
-- 2. BIOMARKERS AND REFERENCE TABLES
-- ==========================================

CREATE TABLE lab_results (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    timepoint VARCHAR(20) NOT NULL CHECK (timepoint IN ('baseline', 'follow_up')),
    sample_date DATE NOT NULL,
    source_type VARCHAR(20) NOT NULL DEFAULT 'manual' CHECK (source_type IN ('manual', 'ocr', 'pdf')),
    processing_status VARCHAR(20) NOT NULL DEFAULT 'pending' CHECK (processing_status IN (
        'pending', 'processing', 'needs_review', 'completed', 'failed'
    )),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at TIMESTAMPTZ NULL
);

CREATE TABLE lab_values (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    lab_result_id UUID NOT NULL REFERENCES lab_results(id) ON DELETE CASCADE,
    biomarker VARCHAR(30) NOT NULL CHECK (biomarker IN (
        'glucose', 'hba1c', 'tg', 'hdl', 'ldl',
        'alt', 'ast', 'wbc', 'hemoglobin', 'hs_crp', 'tsh'
    )),
    value_normalized NUMERIC(10,4) NOT NULL,
    value_original NUMERIC(10,4) NOT NULL,
    unit_original VARCHAR(20) NOT NULL,
    axis_status VARCHAR(10) NOT NULL CHECK (axis_status IN ('green', 'yellow', 'orange')),
    deleted_at TIMESTAMPTZ NULL
);

CREATE TABLE lab_units_reference (
    id SERIAL PRIMARY KEY,
    biomarker VARCHAR(30) NOT NULL,
    source_unit VARCHAR(20) NOT NULL,
    conversion_type VARCHAR(15) NOT NULL CHECK (conversion_type IN ('multiply', 'formula')),
    conversion_factor NUMERIC(10,4) NULL
);

CREATE TABLE reference_ranges (
    id SERIAL PRIMARY KEY,
    biomarker VARCHAR(30) NOT NULL,
    cultural_group VARCHAR(30) NOT NULL DEFAULT 'general' CHECK (cultural_group IN (
        'eastern_european', 'south_asian', 'latino',
        'african_american', 'east_asian', 'standard_american', 'general'
    )),
    gender VARCHAR(10) NOT NULL DEFAULT 'any' CHECK (gender IN ('male', 'female', 'any')),
    green_min NUMERIC(10,4) NULL,
    green_max NUMERIC(10,4) NULL,
    yellow_min NUMERIC(10,4) NULL,
    yellow_max NUMERIC(10,4) NULL,
    orange_min NUMERIC(10,4) NULL,
    orange_max NUMERIC(10,4) NULL
);

CREATE TABLE cultural_food_patterns (
    id SERIAL PRIMARY KEY,
    culture VARCHAR(30) NOT NULL,
    pattern_name VARCHAR(50) NOT NULL,
    typical_ingredients JSONB NOT NULL DEFAULT '[]'::jsonb,
    glycemic_impact VARCHAR(15) NOT NULL CHECK (glycemic_impact IN ('low', 'moderate', 'high')),
    protective BOOLEAN NOT NULL DEFAULT FALSE,
    trigger BOOLEAN NOT NULL DEFAULT FALSE
);

-- ==========================================
-- 3. WEARABLE DEVICES PARTITIONED TABLES
-- ==========================================

CREATE TABLE device_connections (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    device_type VARCHAR(30) NOT NULL CHECK (device_type IN ('apple_health', 'google_fit')),
    permissions JSONB NOT NULL DEFAULT '{}'::jsonb,
    connection_status VARCHAR(20) NOT NULL DEFAULT 'connected' CHECK (connection_status IN ('connected', 'disconnected', 'expired')),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at TIMESTAMPTZ NULL
);

CREATE TABLE device_readings (
    id BIGSERIAL,
    timestamp TIMESTAMPTZ NOT NULL,
    user_id UUID NOT NULL,
    device_connection_id UUID NOT NULL,
    reading_type VARCHAR(20) NOT NULL CHECK (reading_type IN ('hrv_rmssd', 'cgm_glucose', 'sdnn', 'pnn50')),
    value NUMERIC(10,4) NOT NULL,
    dg_dt NUMERIC(10,4) NULL,
    dg_dt_status VARCHAR(20) NULL CHECK (dg_dt_status IN (
        'rising_fast', 'rising', 'steady', 'falling_slowly', 'falling', 'falling_fast'
    )),
    deleted_at TIMESTAMPTZ NULL,
    PRIMARY KEY (id, timestamp),
    UNIQUE (timestamp, user_id, reading_type)
) PARTITION BY RANGE (timestamp);

SELECT partman.create_parent(
    p_parent_table := 'public.device_readings',
    p_control_column := 'timestamp',
    p_type := 'range',
    p_interval := '1 month',
    p_premake := 3
);

CREATE TABLE symptom_logs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    symptoms JSONB NOT NULL DEFAULT '[]'::jsonb,
    severity SMALLINT NOT NULL CHECK (severity BETWEEN 1 AND 10),
    hunger_level SMALLINT NOT NULL CHECK (hunger_level BETWEEN 0 AND 10),
    glucose_at_symptom NUMERIC(6,2) NULL,
    dg_dt_at_symptom NUMERIC(6,2) NULL,
    hrv_rmssd_at_symptom NUMERIC(6,2) NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at TIMESTAMPTZ NULL
);

-- ==========================================
-- 4. ENGINE METABOLIC PROFILES
-- ==========================================

CREATE TABLE axis_evaluations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    lab_result_id UUID NOT NULL REFERENCES lab_results(id) ON DELETE CASCADE,
    axis_1_status VARCHAR(10) NOT NULL CHECK (axis_1_status IN ('green', 'yellow', 'orange')),
    axis_2_status VARCHAR(10) NOT NULL CHECK (axis_2_status IN ('green', 'yellow', 'orange')),
    axis_3_status VARCHAR(10) NOT NULL CHECK (axis_3_status IN ('green', 'yellow', 'orange')),
    axis_4_status VARCHAR(10) NOT NULL CHECK (axis_4_status IN ('green', 'yellow', 'orange')),
    axis_5_status VARCHAR(10) NOT NULL CHECK (axis_5_status IN ('green', 'yellow', 'orange')),
    data_completeness VARCHAR(20) NOT NULL DEFAULT 'basic' CHECK (data_completeness IN (
        'minimal', 'basic', 'extended', 'full'
    )),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at TIMESTAMPTZ NULL
);

CREATE TABLE profiles (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    axis_evaluation_id UUID NOT NULL REFERENCES axis_evaluations(id) ON DELETE CASCADE,
    profile_number SMALLINT NOT NULL CHECK (profile_number BETWEEN 1 AND 5),
    selection_step SMALLINT NOT NULL CHECK (selection_step BETWEEN 0 AND 4),
    modifiers JSONB NOT NULL DEFAULT '{}'::jsonb,
    hormonal_modifier JSONB NOT NULL DEFAULT '{}'::jsonb,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at TIMESTAMPTZ NULL
);

-- ==========================================
-- 5. PRODUCT CATALOG AND GROCERY CARTS
-- ==========================================

CREATE TABLE products_catalog (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    product_name VARCHAR(150) NOT NULL,
    product_category VARCHAR(50) NOT NULL CHECK (product_category IN (
        'proteins', 'vegetables', 'grains_legumes', 'fats_oils', 'spices_herbs', 'beverages', 'supplements'
    )),
    trade_units JSONB NOT NULL DEFAULT '{}'::jsonb,
    is_nutraceutical BOOLEAN NOT NULL DEFAULT FALSE,
    profile_tags JSONB NOT NULL DEFAULT '[]'::jsonb,
    upc_code VARCHAR(30) UNIQUE NULL,
    source VARCHAR(30) NOT NULL DEFAULT 'USDA' CHECK (source IN ('USDA', 'Open Food Facts', 'Manual')),
    nutritional_data JSONB NOT NULL DEFAULT '{}'::jsonb
);

CREATE TABLE recommended_carts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    profile_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    budget_tier VARCHAR(10) NOT NULL CHECK (budget_tier IN ('low', 'mid', 'high')),
    household_size SMALLINT NOT NULL DEFAULT 1,
    total_estimated_cost NUMERIC(8,2) NOT NULL,
    exported_format VARCHAR(10) NULL CHECK (exported_format IN ('csv', 'pdf')),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at TIMESTAMPTZ NULL
);

CREATE TABLE cart_items (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    recommended_cart_id UUID NOT NULL REFERENCES recommended_carts(id) ON DELETE CASCADE,
    product_catalog_id UUID NOT NULL REFERENCES products_catalog(id),
    product_name VARCHAR(150) NOT NULL,
    quantity NUMERIC(6,2) NOT NULL,
    unit VARCHAR(20) NOT NULL,
    is_nutraceutical BOOLEAN NOT NULL DEFAULT FALSE,
    disclaimer_accepted BOOLEAN NOT NULL DEFAULT FALSE
);

-- ==========================================
-- 6. ACTUAL PURCHASES AND RECEIPT OCR
-- ==========================================

CREATE TABLE actual_purchases (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    recommended_cart_id UUID NULL REFERENCES recommended_carts(id) ON DELETE SET NULL,
    capture_method VARCHAR(20) NOT NULL DEFAULT 'receipt_photo' CHECK (capture_method IN ('manual', 'receipt_photo', 'retailer_import')),
    receipt_image_url VARCHAR(512) NULL,
    ocr_status VARCHAR(20) NOT NULL DEFAULT 'uploaded' CHECK (ocr_status IN (
        'uploaded', 'ocr_processing', 'needs_review', 'confirmed', 'failed'
    )),
    ocr_raw_result JSONB NULL,
    ocr_confidence_score NUMERIC(3,2) NULL CHECK (ocr_confidence_score BETWEEN 0.00 AND 1.00),
    purchase_date DATE NOT NULL,
    store_name VARCHAR(100) NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at TIMESTAMPTZ NULL
);

CREATE TABLE purchase_items (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    actual_purchase_id UUID NOT NULL REFERENCES actual_purchases(id) ON DELETE CASCADE,
    product_name VARCHAR(150) NOT NULL,
    match_status VARCHAR(15) NOT NULL CHECK (match_status IN ('matches', 'drift', 'excluded')),
    matched_cart_item_id UUID NULL REFERENCES cart_items(id) ON DELETE SET NULL
);

-- ==========================================
-- 7. DRIFT ANALYSIS (CORE DIFFERENTIAL LAYER)
-- ==========================================

CREATE TABLE drift_analyses (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    recommended_cart_id UUID NOT NULL REFERENCES recommended_carts(id) ON DELETE CASCADE,
    actual_purchase_id UUID UNIQUE NOT NULL REFERENCES actual_purchases(id) ON DELETE CASCADE,
    match_percentage NUMERIC(5,2) NOT NULL,
    drift_percentage NUMERIC(5,2) NOT NULL,
    week_number SMALLINT NOT NULL,
    grocery_stability_score NUMERIC(5,2) NOT NULL, -- formula TBD (ADR-018)
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at TIMESTAMPTZ NULL
);

CREATE TABLE drift_items (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    drift_analysis_id UUID NOT NULL REFERENCES drift_analyses(id) ON DELETE CASCADE,
    product_name VARCHAR(150) NOT NULL,
    drift_type VARCHAR(15) NOT NULL CHECK (drift_type IN ('added', 'missing', 'excluded')),
    health_impact VARCHAR(15) NOT NULL DEFAULT 'neutral' CHECK (health_impact IN ('positive', 'neutral', 'negative'))
);

-- ==========================================
-- 8. INDEX OPTIMIZATION AND TUNING
-- ==========================================

CREATE INDEX idx_users_active ON users(id) WHERE deleted_at IS NULL;
CREATE INDEX idx_research_consents_active ON research_consents(user_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_cultural_profiles_active ON cultural_profiles(user_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_hormonal_statuses_active ON hormonal_statuses(user_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_lab_results_active ON lab_results(user_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_lab_values_active ON lab_values(lab_result_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_device_connections_active ON device_connections(user_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_axis_evaluations_active ON axis_evaluations(user_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_profiles_active ON profiles(user_id) WHERE deleted_at IS NULL AND is_active = TRUE;
CREATE INDEX idx_recommended_carts_active ON recommended_carts(user_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_actual_purchases_active ON actual_purchases(user_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_drift_analyses_active ON drift_analyses(user_id) WHERE deleted_at IS NULL;

CREATE INDEX idx_lab_values_lookup ON lab_values(lab_result_id);
CREATE INDEX idx_cart_items_lookup ON cart_items(recommended_cart_id);
CREATE INDEX idx_purchase_items_lookup ON purchase_items(actual_purchase_id);
CREATE INDEX idx_drift_items_lookup ON drift_items(drift_analysis_id);

CREATE INDEX idx_device_readings_query ON device_readings(user_id, timestamp DESC, reading_type);

UPDATE partman.part_config
SET retention = '12 months', retention_keep_table = false
WHERE parent_table = 'public.device_readings';
```


---

## Recent Schema Changes (Phase E — 2026-07-06)

### users table — new columns

**`is_participant BOOLEAN NOT NULL DEFAULT FALSE`**
- `TRUE` if user is enrolled in the research study (signed IRB consent)
- Set to `TRUE` by `POST /api/v1/consent` handler when `agreed = true`
- Gates admin-only endpoints (`POST /api/v1/admin/account/delete`, `GET /api/v1/admin/research/export`)
- Default `FALSE` for explore-only users who clicked "Skip" on E3 (Research Consent)
- Returned by `GET /api/v1/account` as `is_participant` field (E35 spec)

**`onboarding_step SMALLINT NOT NULL DEFAULT 0`**
- Range 0–7, CHECK constraint
- 0 = not started, 1 = E2 (Sign Up), 2 = E3 (Consent), 3 = E4 (Labs), 3.5 = E4a/E4b (OCR review/manual), 4 = E5 (Cultural), 5 = E6 (Devices), 6 = E7 (Hormonal), 7 = onboarded
- Used by E1 (Splash) to resume from first incomplete step per UC-03
- Updated by every onboarding handler
- `onboarding_completed = TRUE` ↔ `onboarding_step = 7`

### cultural_profiles table — CHECK constraint extended

**`primary_culture`** CHECK now includes `'other'`:
- `eastern_european`, `south_asian`, `latino`, `african_american`, `east_asian`, `standard_american`, `other`
- The `'other'` option is for users whose food traditions don't fit the 6 supported cultural groups
- When `'other'` is selected on E5, a free-text "Describe your food traditions" field appears
- The free-text description is stored in `cultural_profiles.staple_foods` as a JSON array starting with `{"type": "other_description", "text": "..."}` (or in a new `other_description TEXT` column if schema migration is preferred)

### Note on users.cultural_group

`users.cultural_group` does NOT have `'other'` — it remains one of the 6 supported groups (account-level default).
`cultural_profiles.primary_culture` is per-E5-selection and can be `'other'`.
