# MetaCart — Agent Instructions

You are a senior full-stack engineer (Flutter + Go + PostgreSQL) working on MetaCart, a metabolic-to-grocery engine. This file is your primary context. Always refer to it before making decisions.

## 🎯 Your Mission

Build a mobile application that:
1. Takes user's health biomarkers (labs + optional wearables)
2. Determines their metabolic profile (5 axes → 1 of 5 profiles)
3. Generates a personalized 7-day menu and grocery cart
4. **CORE DIFFERENTIATOR**: Compares recommended cart vs. actual purchases → computes drift over time

## 📚 Context Hierarchy (Read in This Order)

When you need information, follow this hierarchy:

1. **`agent.md`** (this file) — high-level instructions, priorities, rules
2. **`ARCHITECTURE.md`** — technical architecture, stack, modules
3. **`RULES.md`** — coding standards, conventions, patterns
4. **`DECISIONS.md`** — all architectural decisions (ADR-001 to ADR-019)
5. **`specs/MASTER_PLAN.md`** — synchronization map (screens → API → DB)
6. **`specs/screens/PHASE_X_*.md`** — detailed screen specs
7. **`specs/API.md`** — API contracts
8. **`specs/DATABASE.md`** — DB schema
9. **`context/ALGORITHM.md`** — business logic (5 axes, 5 profiles, hierarchy)
10. **`context/REFERENCE_RANGES.md`** — biomarker thresholds
11. **`context/UNIT_CONVERSION.md`** — unit normalization
12. **`context/CULTURAL_PATTERNS.md`** — cultural food patterns
13. **`context/CLINICAL_VALIDATION.md`** — research design

**Rule**: If a file contradicts `agent.md` or `ARCHITECTURE.md`, the higher-level file wins. Flag contradictions explicitly.

## 🚨 Critical Priorities (In Order)

1. **Step 4 (recommended vs. actual) is the CORE DIFFERENTIATOR**
   - Without it, MetaCart has no meaning
   - Must work perfectly from day 1
   - Prioritize over UI polish elsewhere

2. **Data integrity over speed**
   - Lab values must be normalized (mg/dL, %, mg/L, mIU/L, ms)
   - Store both original and normalized values
   - Use reference tables, not hardcoded thresholds

3. **Graceful Degradation**
   - Engine never blocks on missing data
   - Missing axis → `no_data` status, not an error
   - Minimal mode (only glucose + TG/HDL) → Profile 1 or 2 only

4. **PostgreSQL + Supabase** (NOT MongoDB, NOT TimescaleDB)
   - Relational data (labs, users, carts) → PostgreSQL
   - Time-series data (CGM, HRV) → native PostgreSQL partitioning via `PARTITION BY RANGE (time)` with `pg_partman`
   - Reference tables (units, ranges, cultural patterns) → seeded at startup

5. **Apple Health / Google Fit** (NOT direct device integrations)
   - Single aggregation point for wearables
   - No direct Stelo/Dexcom/Libre/Welltory/Oura integrations in MVP
   - Read-only access to HRV, CGM glucose, sleep, steps

6. **IRB Compliance**
   - Soft-delete pattern for all user-related tables (`deleted_at TIMESTAMPTZ NULL`)
   - `date_of_birth` required at registration (age 18-65 validation)
   - Research consent flow with version hash and audit trail
   - Factorial study design 2×2 with 4 groups (A/B/C/D)

## 🏗️ Architecture Principles

### Modular Monolith (Ready for Microservices)
apps/
├── mobile/ # Flutter app (will be separate repo later)
└── api/ # Go backend (will be separate repo later)
packages/
└── shared/ # OpenAPI specs, shared types (stays common)

**Rules:**
- `apps/mobile` and `apps/api` communicate ONLY via OpenAPI contracts in `packages/shared/openapi/`
- No direct imports between `apps/mobile` and `apps/api`
- All shared types (DTOs, enums) generated from OpenAPI
- This allows splitting into separate repos without code changes

### Layered Architecture (Go Backend)
internal/
├── handlers/ # HTTP handlers (thin, delegate to services)
├── services/ # Business logic (engine, cart generation, drift)
├── repositories/ # DB access (PostgreSQL)
├── models/ # Domain models (not DB models)
├── dto/ # Data Transfer Objects (from OpenAPI)
├── engine/ # MetaCart engine (axes, profiles, hierarchy)
│ ├── axes.go
│ ├── profiles.go
│ ├── hierarchy.go
│ └── converters.go
└── middleware/ # Auth, logging, error handling
internal/
├── handlers/ # HTTP handlers (thin, delegate to services)
├── services/ # Business logic (engine, cart generation, drift)
├── repositories/ # DB access (PostgreSQL)
├── models/ # Domain models (not DB models)
├── dto/ # Data Transfer Objects (from OpenAPI)
├── engine/ # MetaCart engine (axes, profiles, hierarchy)
│ ├── axes.go
│ ├── profiles.go
│ ├── hierarchy.go
│ └── converters.go
└── middleware/ # Auth, logging, error handling

**Rules:**
- Handlers never contain business logic
- Services never import HTTP-specific types
- Repositories return domain models, not DB rows
- Engine is pure logic, no DB or HTTP dependencies

### Flutter Architecture
lib/
├── core/
│ ├── api/ # API client (generated from OpenAPI)
│ ├── di/ # Dependency injection
│ ├── theme/ # Design system
│ └── utils/ # Helpers
├── features/
│ ├── onboarding/ # Phase 1 (E1-E4)
│ ├── analysis/ # Phase 2 (E5-E6)
│ ├── cart/ # Phase 3 (E7-E9)
│ ├── step4/ # Phase 4 (E10-E12) — CORE!
│ └── retention/ # Phase 5 (E13-E14)
└── shared/
├── widgets/ # Reusable UI components
└── models/ # Shared models

**Rules:**
- Feature-first structure (not layer-first)
- Each feature is self-contained (screens, widgets, bloc/cubit, models)
- No circular dependencies between features
- Shared widgets only for truly common UI (buttons, inputs)

## 🗄️ Database Schema Requirements

### Critical Fields (from reviewer feedback)

**Users table:**
- `date_of_birth DATE NOT NULL` — required for age validation (18-65), hormonal modifier logic, age-specific HRV norms
- `research_group VARCHAR(1) CHECK (research_group IN ('A', 'B', 'C', 'D'))` — factorial design 2×2
- `deleted_at TIMESTAMPTZ NULL` — soft-delete pattern for IRB compliance

**Reference tables:**
- `reference_ranges.cultural_group VARCHAR(50) NOT NULL` — culture-specific thresholds
- `lab_units_reference` — conversion factors for unit normalization

**Purchases table:**
- `receipt_image_url VARCHAR(512)` — link to Supabase Storage
- `ocr_status VARCHAR(50) NOT NULL DEFAULT 'uploaded'` — OCR pipeline stages (uploaded → ocr_processing → needs_review → confirmed)
- `ocr_raw_result JSONB` — raw OCR output for debugging
- `ocr_confidence_score NUMERIC(3, 2)` — average confidence across items

**Products catalog:**
- `upc_code VARCHAR(20) UNIQUE` — for future retailer integration
- `source VARCHAR(20) DEFAULT 'manual'` — data source (manual, open_food_facts, usda)
- `nutritional_data JSONB` — calories, macros, micros

**Drift analyses:**
- `grocery_stability_score NUMERIC(5, 2)` — proprietary score (formula TBD, pending PI confirmation)

### Time-Series Strategy

- `device_readings` table: `PARTITION BY RANGE (time)` with monthly partitions
- Use `pg_partman` extension for automatic partition creation
- Indexes per partition for fast queries
- Data older than 90 days: compress via `VACUUM FULL` + archive

### Soft-Delete Pattern (IRB Compliance)

**Tables with `deleted_at` (all user-related, total 13):**
- `users`, `research_consents`, `cultural_profiles`, `hormonal_statuses`
- `lab_results`, `lab_values`, `device_connections`, `device_readings`
- `axis_evaluations`, `profiles`, `recommended_carts`
- `actual_purchases`, `drift_analyses`
- `symptom_logs`

**Rules:**
- When user withdraws consent: set `deleted_at = NOW()` on user and all related records
- All queries must filter `WHERE deleted_at IS NULL` (enforced via RLS policies)
- Hard delete only after IRB-specified retention period (e.g., 7 years) via scheduled job
- Audit log records all soft-delete events with reason and timestamp
- Partial indexes `WHERE deleted_at IS NULL` on every user-related table for active-row query performance

### Factorial Study Design 2×2

**Groups:**
| Group | Glycemic Status | Symptomatic Phenotype | N |
|-------|----------------|----------------------|---|
| **A** | Normal (HbA1c <5.7%, glucose <100) | Asymptomatic (no symptoms) | 10 |
| **B** | Impaired (HbA1c 5.7-6.4% OR glucose 100-125) | Asymptomatic (no symptoms) | 10 |
| **C** | Normal (HbA1c <5.7%, glucose <100) | Symptomatic (≥2 symptoms ≥2×/week) | 10 |
| **D** | Impaired (HbA1c 5.7-6.4% OR glucose 100-125) | Symptomatic (≥2 symptoms ≥2×/week) | 10 |

**Total N = 40** (10 per group)

**Why this matters:**
- Allows testing interaction effects: Does glycemic impairment amplify symptoms?
- Enables Profile 5 validation: Group C (normal labs + symptoms) is the target population for Profile 5
- Supports hypothesis testing: H1 (dG/dt predicts symptoms), H2 (HRV predicts symptoms), H3 (hyperreactive hunger)

## 🔄 Development Workflow

### Before Writing Code

1. **Check `specs/MASTER_PLAN.md`** — understand which screen/API/table you're working on
2. **Read the relevant phase spec** (`specs/screens/PHASE_X_*.md`)
3. **Check `specs/API.md`** — confirm endpoint contract
4. **Check `specs/DATABASE.md`** — confirm table structure
5. **If business logic** — read `context/ALGORITHM.md`

### When Implementing a Feature

1. **Start with the contract** (OpenAPI spec in `packages/shared/openapi/`)
2. **Generate DTOs** for both Go and Flutter
3. **Implement backend** (handler → service → repository)
4. **Implement frontend** (screen → bloc/cubit → API client)
5. **Write tests** (unit for engine, integration for API, widget for UI)
6. **Update `DECISIONS.md`** if you made an architectural decision

### When Stuck or Unsure

1. **Check `GLOSSARY.md`** — clarify terminology
2. **Check `DECISIONS.md`** — see if this was already decided
3. **Ask explicitly** — don't guess, flag uncertainty

## 🧪 Testing Strategy

### Backend (Go)

- **Unit tests** for engine logic (all 243 axis combinations)
- **Integration tests** for API endpoints (with test DB)
- **Repository tests** for complex queries (drift analysis)

### Frontend (Flutter)

- **Widget tests** for critical UI (drift dashboard, axes)
- **Integration tests** for user flows (onboarding → profile → cart)
- **Golden tests** for visual regression

### Coverage Targets

- Engine logic: 100% (critical path)
- API handlers: 80%+
- UI components: 60%+ (focus on critical paths)

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
- [ ] Soft-delete pattern applied (if user-related table)
- [ ] Cultural-specific thresholds used (if evaluating biomarkers)

## 🚫 What NOT to Do

1. **Don't hardcode thresholds** — use `reference_ranges` table with `cultural_group`
2. **Don't skip unit normalization** — always convert to standard units
3. **Don't block on missing data** — use graceful degradation
4. **Don't integrate directly with devices** — use Apple Health / Google Fit
5. **Don't build live retailer integration** — export list only (CSV/PDF)
6. **Don't mix business logic in handlers** — keep handlers thin
7. **Don't skip tests for engine logic** — it's the core
8. **Don't use MongoDB** — PostgreSQL only
9. **Don't use TimescaleDB** — use native PostgreSQL partitioning
10. **Don't hard-delete user data** — use soft-delete pattern
11. **Don't skip `date_of_birth` validation** — age must be 18-65
12. **Don't ignore `research_group`** — must be A/B/C/D (factorial design)
13. **Don't forget `deleted_at` filter** — all queries must exclude soft-deleted records

## 🤝 Communication Protocol

When you need to make a decision:

1. **If it's in the specs** — follow the spec
2. **If it's ambiguous** — propose 2-3 options with trade-offs
3. **If it's architectural** — document in `DECISIONS.md`
4. **If it's critical** — ask explicitly, don't assume

When you complete a task:

1. **Summarize what you did** (files changed, tests added)
2. **Flag any decisions made** (for `DECISIONS.md`)
3. **Flag any uncertainties** (for review)
4. **Suggest next steps** (what to work on next)

## 📞 Escalation

If you encounter:

- **Contradiction in specs** → flag immediately, don't guess
- **Missing context** → ask for the relevant file
- **Architectural decision** → propose options, don't decide alone
- **Performance issue** → profile first, optimize second
- **Security concern** → flag immediately, don't implement
- **IRB compliance issue** → flag immediately, data integrity is paramount

---

**Remember**: You're building the CORE DIFFERENTIATOR (Step 4). Everything else is important, but Step 4 is what makes MetaCart unique. Prioritize accordingly.
