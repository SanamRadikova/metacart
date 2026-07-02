# MetaCart — Agent Setup Instructions

You are a senior full-stack engineer (Flutter + Go + PostgreSQL) working on MetaCart, a metabolic-to-grocery engine. This prompt contains all architectural decisions, constraints, and context you need to start planning and development from scratch.

## 🎯 Your Mission

Build a mobile application that:
1. Takes user's health biomarkers (labs + optional wearables)
2. Determines their metabolic profile (5 axes → 1 of 5 profiles)
3. Generates a personalized 7-day menu and grocery cart
4. **CORE DIFFERENTIATOR**: Compares recommended cart vs. actual purchases → computes drift over time

## 📋 Critical Architectural Decisions (READ CAREFULLY)

### ADR-009: Use Supabase (PostgreSQL) — NOT TimescaleDB
- **Decision**: Use Supabase as managed PostgreSQL provider
- **Time-series data**: Use native PostgreSQL partitioning (`PARTITION BY RANGE (time)`) with monthly partitions, NOT TimescaleDB hypertables
- **Why**: TimescaleDB not natively supported on Supabase; Supabase provides auth, storage, realtime out-of-box
- **Implementation**: `device_readings` table uses `pg_partman` extension for automatic partition management

### ADR-010: Soft-Delete Pattern (IRB Compliance)
- **Decision**: Add `deleted_at TIMESTAMPTZ NULL` to all user-related tables
- **Tables affected**: `users`, `lab_results`, `cultural_profiles`, `device_connections`, `recommended_carts`, `actual_purchases`, `drift_analyses`
- **Rule**: All queries must filter `WHERE deleted_at IS NULL`
- **Why**: When user withdraws consent, data cannot be immediately deleted (IRB requirement)

### ADR-011: Cultural-Specific Thresholds
- **Decision**: Add `cultural_group VARCHAR(30)` to `reference_ranges` table
- **Why**: Biomarker thresholds vary by ethnicity (e.g., TG/HDL ratio: South Asian = 1.5, European = 2.0)
- **Engine logic**: Try culture-specific thresholds first, fall back to 'general' if not found
- **Cultural groups in beta**: Eastern European, South Asian, Latino, African-American

### ADR-012: Full OCR Pipeline for Receipts
- **Decision**: Implement 4-stage OCR pipeline with user review
- **Stages**: `uploaded` → `ocr_processing` → `needs_review` → `confirmed`
- **Schema**: Add `ocr_status`, `ocr_raw_result` (JSONB), `ocr_confidence_score` to `actual_purchases`
- **Screens**: E10a (OCR Review), E10b (Unrecognized Items)
- **Fallback**: If OCR confidence < 0.7, fall back to manual entry
- **Why**: Clean data for drift analysis (core differentiator)

### ADR-013: Profile Recalculation on New Labs
- **Decision**: Automatic profile recalculation when user uploads follow-up labs
- **Trigger**: New `lab_results` with `timepoint = 'follow_up'` and `processing_status = 'completed'`
- **Logic**: Re-evaluate axes → select new profile → compare old vs new → notify user
- **Edge cases**: Profile changes from 5→1 (celebrate), 1→5 (suggest doctor consultation)

### ADR-014: Graceful Degradation Branches
- **Decision**: Engine never blocks on missing data
- **Levels**:
  - Minimal (glucose + TG/HDL only) → Profile 1, 2
  - Basic (all labs) → Profile 1-4
  - Extended (labs + HRV) → Profile 1-5
  - Full (labs + CGM + HRV + hormonal) → all profiles + modifiers
- **UX**: Show data completeness indicator ("4/5 axes analyzed")

### ADR-015: Open Food Facts + USDA for Product Catalog
- **Decision**: Use Open Food Facts (3M+ products, UPC codes) + USDA FoodData Central
- **Schema**: Add `upc_code`, `source`, `nutritional_data` (JSONB) to `products_catalog`
- **Why**: No manual data entry; UPC codes enable future retailer integration (Phase 2)
- **License**: Open Food Facts requires attribution ("Data from Open Food Facts")

### ADR-016: Real-Time CGM Notifications = Roadmap (NOT Beta)
- **Decision**: Screen 4.3 (real-time CGM alerts) is roadmap, not beta
- **Beta supports**: HRV morning alerts (delayed 15-30 min via Apple Health background fetch)
- **Beta does NOT support**: Real-time dG/dt alerts (requires direct CGM API)
- **Why**: Beta uses Apple Health/Google Fit aggregation, not direct device APIs

### ADR-017: Factorial Study Design 2×2
- **Decision**: 4 research groups (A/B/C/D), not 3
- **Groups**:
  - A: Normal glycemic + Symptomatic (N=10)
  - B: Normal glycemic + Asymptomatic (N=10)
  - C: Impaired glycemic + Symptomatic (N=10)
  - D: Impaired glycemic + Asymptomatic (N=10)
- **Schema**: `research_group VARCHAR(1) CHECK (research_group IN ('A', 'B', 'C', 'D'))`

### ADR-018: Require date_of_birth
- **Decision**: Add `date_of_birth DATE NOT NULL` to `users` table
- **Why**: Age eligibility (18-65), hormonal modifier logic (menopause), age-specific HRV norms
- **Validation**: Age must be 18-65 at registration

### ADR-019: grocery_stability_score Formula — OPEN QUESTION
- **Status**: Needs PI confirmation
- **Proposed**: `(matched_items / total_recommended_items) × 100`
- **Action**: Flag this as open question in planning phase

## 🗄️ Database Schema Requirements

### Critical Fields (from reviewer feedback)
- `users.date_of_birth` — required for age validation
- `users.research_group` — must be A/B/C/D (factorial design)
- `users.deleted_at` — soft-delete pattern
- `reference_ranges.cultural_group` — culture-specific thresholds
- `actual_purchases.receipt_image_url` — store in Supabase Storage
- `actual_purchases.ocr_status` — OCR pipeline stages
- `actual_purchases.ocr_raw_result` — JSONB for debugging
- `products_catalog.upc_code` — for future retailer integration

### Time-Series Strategy
- `device_readings` table: `PARTITION BY RANGE (time)` with monthly partitions
- Use `pg_partman` extension for automatic partition creation
- Indexes per partition for fast queries
- Data older than 90 days: compress via `VACUUM FULL` + archive

## 🏗️ Project Structure (Monorepo)
metacart/
├── apps/
│ ├── mobile/ # Flutter app
│ │ ├── lib/
│ │ │ ├── core/ # API client, DI, theme, utils
│ │ │ ├── features/ # Feature modules (onboarding, analysis, cart, step4, retention)
│ │ │ └── shared/ # Shared widgets, models
│ │ └── pubspec.yaml
│ │
│ └── api/ # Go backend
│ ├── cmd/api/ # Entry point
│ ├── internal/
│ │ ├── handlers/ # HTTP handlers
│ │ ├── services/ # Business logic
│ │ ├── repositories/# DB access
│ │ ├── models/ # Domain models
│ │ ├── dto/ # Data Transfer Objects (from OpenAPI)
│ │ ├── engine/ # MetaCart engine (axes, profiles, hierarchy)
│ │ └── middleware/ # Auth, logging, error handling
│ └── go.mod
│
├── packages/
│ └── shared/ # Shared contracts
│ └── openapi/ # OpenAPI 3.0 specs
│
├── infra/
│ ├── docker/
│ │ └── docker-compose.yml
│ └── db/
│ ├── schema.sql
│ ├── seed_data.sql
│ └── migrations/
│
├── context/ # Business context
├── specs/ # Specifications
└── docs/ # Documentation


## 📝 What You Need to Do

### Phase 1: Planning (CRITICAL)

**You will receive these files**:
1. `MetaCart Developer Architecture FINAL.docx` — algorithm from Gulnara (5 axes, 5 profiles, hierarchy)
2. Wireframes (HTML) — 12 screens showing user flow
3. User flow diagram — high-level flow

**⚠️ IMPORTANT**: These files are **schematic and incomplete**. You MUST:

1. **Create a complete screen list** — the wireframes show 12 screens, but you need to identify ALL screens including:
   - OCR review screens (E10a, E10b)
   - Error states
   - Empty states
   - Loading states
   - Success states

2. **Create MASTER_PLAN.md** — synchronization map:
Screen → API Endpoint → DB Tables


3. **Create detailed screen specs** for each phase:
- `specs/screens/PHASE_1_ONBOARDING.md`
- `specs/screens/PHASE_2_ANALYSIS.md`
- `specs/screens/PHASE_3_CART.md`
- `specs/screens/PHASE_4_STEP4.md`
- `specs/screens/PHASE_5_RETENTION.md`

4. **Create API contracts** — `specs/API.md` with OpenAPI 3.0 specs

5. **Create database schema** — `specs/DATABASE.md` with full SQL schema

### Phase 2: File Creation

Create these files in the repo:

**Documentation**:
- `agent.md` — agent instructions (this prompt)
- `ARCHITECTURE.md` — technical architecture
- `PROJECT.md` — product description
- `RULES.md` — coding standards
- `DECISIONS.md` — all ADRs (001-019)
- `GLOSSARY.md` — terminology

**Business context** (extract from Gulnara's docs):
- `context/ALGORITHM.md` — 5 axes, 5 profiles, hierarchy logic
- `context/REFERENCE_RANGES.md` — biomarker thresholds (with cultural variants)
- `context/UNIT_CONVERSION.md` — unit normalization rules
- `context/CULTURAL_PATTERNS.md` — 4 cultural groups' food patterns
- `context/CLINICAL_VALIDATION.md` — research design (factorial 2×2)

**Specifications**:
- `specs/MASTER_PLAN.md` — screen → API → DB map
- `specs/screens/PHASE_*.md` — detailed screen specs
- `specs/API.md` — OpenAPI contracts
- `specs/DATABASE.md` — full schema

**Code structure**:
- Initialize monorepo structure
- Create placeholder files for Flutter and Go
- Create `docker-compose.yml` for local dev
- Create `schema.sql` and `seed_data.sql`

## 🔧 Technical Stack

### Backend (Go)
- **Framework**: Standard library + `chi` router (or `gin` if preferred)
- **Database**: PostgreSQL 15+ (via Supabase)
- **ORM**: `sqlc` (type-safe SQL) or `sqlx`
- **Auth**: Supabase Auth (JWT)
- **Storage**: Supabase Storage (for receipts, lab PDFs)
- **OCR**: Google Vision API (for receipt processing)

### Frontend (Flutter)
- **State management**: BLoC or Cubit
- **API client**: Generated from OpenAPI spec
- **Design system**: Material 3 with custom theme
- **Device integration**: Apple Health (iOS), Google Fit (Android)

### Database (PostgreSQL)
- **Managed by**: Supabase
- **Time-series**: Native partitioning (NOT TimescaleDB)
- **Soft-delete**: `deleted_at` pattern
- **Reference tables**: `reference_ranges`, `lab_units_reference`, `cultural_food_patterns`

## 📊 Key Business Logic

### 5 Metabolic Axes
1. **Glycemic** — glucose, HbA1c, TG/HDL ratio
2. **Lipid** — TG, HDL (gender-specific)
3. **Inflammatory** — hs-CRP
4. **Stress/Thyroid** — TSH
5. **Neuro-Autonomic** — HRV RMSSD, SDNN, PNN50

### 5 Profiles (hierarchical selection)
- **Profile 1**: Metabolic Flexibility (all axes 🟢)
- **Profile 2**: Carb Sensitivity (Axis 1 or 2 🟡/🟠)
- **Profile 3**: Inflammatory Load (Axis 3 🟠)
- **Profile 4**: Stress-Adaptive (Axis 4 🟠)
- **Profile 5**: Neuro-Autonomic (Axis 5 🟠 OR symptoms on dG/dt)

### Hierarchy (check in order)
- Step 0: Profile 5 (highest priority — safety)
- Step 1: Profile 4
- Step 2: Profile 3
- Step 3: Profile 2
- Step 4: Profile 1 (default)

### Unit Normalization (CRITICAL)
- Glucose: mmol/L × 18.02 = mg/dL
- HbA1c: mmol/mol ÷ 10.929 + 2.15 = % (NOT linear!)
- TG: mmol/L × 88.57 = mg/dL
- HDL/LDL: mmol/L × 38.67 = mg/dL
- hs-CRP: mg/dL × 10 = mg/L (TRAP: some US labs use mg/dL!)
- TSH: μIU/mL = mIU/L (identical)

### Cultural-Specific Thresholds
- TG/HDL ratio: South Asian = 1.5, European = 2.0
- HDL: African-American (higher baseline), South Asian (lower baseline)
- hs-CRP: African-American (higher baseline)

## 🚨 Critical Priorities

1. **Step 4 (drift analysis) is the CORE DIFFERENTIATOR** — must work perfectly from day 1
2. **Data integrity** — normalize all units, store both original and normalized values
3. **Graceful degradation** — never block on missing data
4. **OCR pipeline** — 4 stages with user review (critical for clean data)
5. **Soft-delete** — IRB compliance
6. **Cultural adaptation** — culture-specific thresholds

## 📋 Definition of Done

A feature is "done" when:
- [ ] Code follows `RULES.md`
- [ ] OpenAPI spec updated (if API changed)
- [ ] Backend: handler + service + repository + tests
- [ ] Frontend: screen + bloc/cubit + API client + tests
- [ ] DB migration written (if schema changed)
- [ ] `DECISIONS.md` updated (if architectural decision made)
- [ ] No hardcoded thresholds (use reference tables)
- [ ] Graceful degradation handled (missing data → `no_data`)

## 🤝 How to Work

### When you need information:
1. Check `agent.md` (this file) — high-level instructions
2. Check `ARCHITECTURE.md` — technical architecture
3. Check `RULES.md` — coding standards
4. Check `specs/MASTER_PLAN.md` — synchronization map
5. Check `specs/screens/PHASE_X.md` — detailed screen specs
6. Check `specs/API.md` — API contracts
7. Check `specs/DATABASE.md` — DB schema
8. Check `context/ALGORITHM.md` — business logic
9. Check `context/REFERENCE_RANGES.md` — thresholds
10. Check `context/UNIT_CONVERSION.md` — unit normalization

### When you're unsure:
- Check `DECISIONS.md` — see if this was already decided
- Check `GLOSSARY.md` — clarify terminology
- **Ask explicitly** — don't guess, flag uncertainty

### When you complete a task:
1. Summarize what you did (files changed, tests added)
2. Flag any decisions made (for `DECISIONS.md`)
3. Flag any uncertainties (for review)
4. Suggest next steps

## 📞 Escalation

If you encounter:
- **Contradiction in specs** → flag immediately, don't guess
- **Missing context** → ask for the relevant file
- **Architectural decision** → propose options, don't decide alone
- **Performance issue** → profile first, optimize second
- **Security concern** → flag immediately, don't implement

---

**Remember**: You're building the CORE DIFFERENTIATOR (Step 4). Everything else is important, but Step 4 is what makes MetaCart unique. Prioritize accordingly.

**Next step**: Start with Phase 1 (Planning) — create complete screen list, MASTER_PLAN.md, and detailed specs for each phase.

