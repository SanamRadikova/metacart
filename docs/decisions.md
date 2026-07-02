# MetaCart — Architectural Decisions Record (ADR)

This document records all significant architectural decisions made during MetaCart development. It is the **single source of truth** for architectural choices — when in doubt, consult this file.

## Format

Each decision follows this format:

```markdown
### ADR-XXX: Title

**Status**: Proposed | Accepted | Deprecated | Superseded

**Context**: What is the issue that we're seeing that is motivating this decision?

**Decision**: What is the change that we're proposing and/or doing?

**Consequences**: What becomes easier or more difficult to do because of this change?
Status meanings:
Proposed — under discussion, not yet implemented
Accepted — approved and implemented (or being implemented)
Deprecated — no longer recommended, but existing code may still use it
Superseded — replaced by a newer ADR (reference the replacement)
ADR-001: Use Apple Health / Google Fit Instead of Direct Device Integrations
Status: Accepted
Context: The initial plan was to integrate directly with Stelo, Dexcom, Libre, Welltory, Oura, Apple Watch. This would require 6 separate API integrations, each with different authentication, data formats, and rate limits.
Decision: Use Apple Health (iOS) and Google Fit (Android) as a single aggregation point for all wearable data.
Consequences:
✅ One integration point instead of 6
✅ Users don't need to configure each device separately
✅ Access to more data types (sleep, steps, etc.)
❌ Dependent on user configuring CGM → Apple Health integration
❌ Background fetch limitations on iOS (push notifications may have delay)
❌ Different CGM devices write at different frequencies (Stelo: 5 min, Libre: 1 min)
ADR-002: Modular Monolith Architecture (Ready for Microservices)
Status: Accepted
Context: The MVP needs to be built quickly as a monolith. However, the team plans to split into separate frontend and backend teams in the future. We need an architecture that allows painless separation.
Decision: Use a modular monolith with clear boundaries:
apps/mobile/ — Flutter app (will be separate repo)
apps/api/ — Go backend (will be separate repo)
packages/shared/ — OpenAPI contracts (stays common)
Communication between frontend and backend happens ONLY via OpenAPI contracts.
Consequences:
✅ Fast MVP development (monolith)
✅ Easy to split into separate repos later
✅ Frontend and backend always in sync (OpenAPI)
❌ Slightly more overhead (need to generate DTOs from OpenAPI)
❌ Need to maintain OpenAPI spec as single source of truth
ADR-003: Step 4 (Drift Analysis) is the Core Differentiator
Status: Accepted
Context: MetaCart's unique value proposition is comparing recommended cart vs. actual purchases. Without this, MetaCart is just another nutrition app. The pilot's key data is the drift analysis.
Decision: Prioritize Step 4 implementation over UI polish elsewhere. The drift analysis must work perfectly from day 1.
Consequences:
✅ Core differentiator works from day 1
✅ Pilot data is clean and usable
❌ Other features may be less polished
❌ Need to implement receipt OCR or manual entry early
ADR-004: Use Functional Thresholds (Stricter Than Diagnostic Criteria)
Status: Accepted
Context: MetaCart uses functional thresholds for biomarkers, which are stricter than official diagnostic criteria. For example:
TSH > 2.5 mIU/L → Profile 4 (official diagnosis requires > 4.0)
hs-CRP > 1.0 mg/L → Profile 3 (official high risk is > 3.0)
This may confuse users who are told by their doctor "your labs are normal."
Decision: Use functional thresholds, but add UX explanations to clarify the difference.
Consequences:
✅ Catches early signs of metabolic dysfunction
✅ Aligns with preventive nutrition approach
❌ May confuse users (need clear UX explanations)
❌ Need to document rationale for each threshold
ADR-005: Graceful Degradation (Never Block on Missing Data)
Status: Accepted
Context: Users may not have all lab results. The engine should never block on missing data.
Decision: If a biomarker is missing, mark the axis as no_data and exclude it from profile selection. The engine still works with minimal data (glucose + TG/HDL → Profile 1 or 2).
Consequences:
✅ Better user experience (no blocking)
✅ Works with incomplete data
❌ Less accurate profiles with minimal data
❌ Need to handle no_data status in UI
Note: See ADR-014 for detailed implementation of graceful degradation branches in the user flow.
ADR-006: Store Both Original and Normalized Lab Values
Status: Accepted
Context: Labs from different countries use different units (mg/dL vs. mmol/L, % vs. mmol/mol). We need to normalize to a standard unit for the engine, but also preserve the original value for auditing.
Decision: Store both value_original (as in the lab report) and value_normalized (in standard units).
Consequences:
✅ Engine works with consistent units
✅ Audit trail preserved
✅ Can debug conversion issues
❌ Slightly more storage (but negligible)
ADR-007: Use Reference Tables for Thresholds (Not Hardcoded)
Status: Accepted
Context: Biomarker thresholds may change as we learn more from the pilot. Hardcoding thresholds in the engine would require redeployment.
Decision: Store thresholds in reference_ranges table. Engine reads from the table at runtime.
Consequences:
✅ Easy to update thresholds without redeployment
✅ Can A/B test different thresholds
✅ Clear audit trail of threshold changes
❌ Slightly slower (need to query table)
❌ Need to cache reference data
ADR-008: Use Supabase (PostgreSQL) with Native Partitioning
Status: Accepted
Context: The original plan considered self-managed PostgreSQL with TimescaleDB for time-series data (CGM, HRV readings). However, TimescaleDB is not natively supported on Supabase, and managing our own infrastructure adds operational overhead for a small team building an MVP.
Decision: Use Supabase as the managed PostgreSQL provider. For time-series data (device_readings), use native PostgreSQL partitioning by time (monthly partitions) instead of TimescaleDB hypertables. Compression and retention policies will be implemented via PostgreSQL's native mechanisms and cron jobs.
Implementation:
device_readings table uses PARTITION BY RANGE (time) with monthly partitions
Partition creation automated via pg_partman extension (available on Supabase) or custom cron job
Data older than 90 days compressed via VACUUM FULL + archiving to cold storage
Indexes per partition for fast queries
Consequences:
✅ No infrastructure management (Supabase handles backups, scaling, HA)
✅ Built-in auth, storage, realtime, edge functions
✅ Free tier sufficient for pilot (N=40)
✅ Easy migration path to paid plan
❌ No TimescaleDB-specific features (continuous aggregates, compression policies)
❌ Slightly less optimized time-series queries (but acceptable for N=40 pilot)
❌ Vendor lock-in to Supabase (mitigated by using standard PostgreSQL)
Migration path: If time-series performance becomes critical post-pilot, we can migrate to self-managed Postgres + TimescaleDB with minimal code changes (only partitioning strategy changes).
ADR-009: Implement Soft-Delete Pattern for IRB Compliance
Status: Accepted
Context: When a research participant withdraws consent, IRB requirements dictate that data cannot be immediately deleted — we need an audit trail. The current schema only has withdrew_at in research_consents, which is insufficient for tracking deletion across all related tables.
Decision: Implement soft-delete pattern across all user-related tables:
Add deleted_at TIMESTAMPTZ NULL column to: users, lab_results, cultural_profiles, device_connections, recommended_carts, actual_purchases, drift_analyses
When user withdraws consent: set deleted_at = NOW() on user and all related records
All queries must filter WHERE deleted_at IS NULL (enforced via RLS policies)
Hard delete only after IRB-specified retention period (e.g., 7 years) via scheduled job
Audit log records all soft-delete events with reason and timestamp
Implementation:
sql
-- Add to all user-related tables
ALTER TABLE users ADD COLUMN deleted_at TIMESTAMPTZ NULL;
ALTER TABLE lab_results ADD COLUMN deleted_at TIMESTAMPTZ NULL;
-- ... etc

-- RLS policy example
CREATE POLICY user_isolation ON users
    USING (deleted_at IS NULL);

-- Soft-delete function
CREATE OR REPLACE FUNCTION soft_delete_user(p_user_id UUID, p_reason TEXT)
RETURNS VOID AS $$
BEGIN
    UPDATE users SET deleted_at = NOW() WHERE id = p_user_id;
    UPDATE lab_results SET deleted_at = NOW() WHERE user_id = p_user_id;
    UPDATE cultural_profiles SET deleted_at = NOW() WHERE user_id = p_user_id;
    -- ... cascade to all related tables
    
    INSERT INTO audit_log (user_id, action, table_name, record_id, old_values, new_values)
    VALUES (p_user_id, 'soft_delete', 'users', p_user_id, NULL, 
            jsonb_build_object('reason', p_reason, 'deleted_at', NOW()));
END;
$$ LANGUAGE plpgsql;
Consequences:
✅ IRB-compliant audit trail
✅ Data preserved for research even after withdrawal
✅ Can restore data if consent is reinstated
❌ All queries need WHERE deleted_at IS NULL (mitigated by RLS)
❌ Slightly more complex deletion logic
❌ Storage grows over time (mitigated by scheduled hard-delete after retention period)
ADR-010: Add Cultural Group to Reference Ranges
Status: Accepted
Context: Published literature shows that biomarker thresholds vary by cultural/ethnic group. For example:
TG/HDL ratio threshold for insulin resistance: South Asian = 1.5, European = 2.0
HDL thresholds: African-American populations have different optimal ranges
hs-CRP baseline: varies by ethnicity
The current reference_ranges table does not account for cultural differences, which may lead to inaccurate profile assignments for non-European users.
Decision: Add cultural_group column to reference_ranges table. Engine will select thresholds based on user's cultural profile. If no culture-specific thresholds exist, fall back to default (general population) thresholds.
Implementation:
sql
ALTER TABLE reference_ranges 
ADD COLUMN cultural_group VARCHAR(30) DEFAULT 'general';

-- Example: culture-specific TG/HDL thresholds
INSERT INTO reference_ranges (biomarker, gender, cultural_group, green_max, yellow_max, orange_min, unit) VALUES
('tg_hdl_ratio', 'any', 'south_asian', 1.5, 2.5, 2.5, 'ratio'),
('tg_hdl_ratio', 'any', 'eastern_european', 2.0, 3.0, 3.0, 'ratio'),
('tg_hdl_ratio', 'any', 'general', 1.5, 2.9, 3.0, 'ratio');
Engine logic:
func getReferenceRange(biomarker, gender, culturalGroup string) ReferenceRange {
    // Try culture-specific first
    range := db.Query("SELECT * FROM reference_ranges WHERE biomarker = ? AND gender = ? AND cultural_group = ?", 
                      biomarker, gender, culturalGroup)
    if range != nil {
        return range
    }
    // Fall back to general
    return db.Query("SELECT * FROM reference_ranges WHERE biomarker = ? AND gender = ? AND cultural_group = 'general'", 
                    biomarker, gender)
}
Consequences:
✅ More accurate profiles for diverse populations
✅ Aligns with cultural adaptation hypothesis (H6)
✅ Supports pilot's 4 cultural groups
❌ Need to populate culture-specific thresholds (PI to provide data)
❌ More complex threshold selection logic
❌ Potential for overfitting if sample sizes per culture are small
Open question: PI to provide culture-specific threshold table. Until then, use general thresholds for all cultures.
ADR-011: Implement Full OCR Pipeline for Receipt Processing
Status: Accepted
Context: The current schema has receipt_image_url in actual_purchases, but there's no defined OCR pipeline. Without a structured OCR workflow, we risk collecting dirty data (misrecognized items, missing products) which undermines the core differentiator (drift analysis).
Decision: Implement a 4-stage OCR pipeline with explicit status tracking and user review:
Pipeline stages:
uploaded — User uploads receipt photo, stored in Supabase Storage
ocr_processing — Backend sends image to OCR service (Google Vision API / AWS Textract)
needs_review — OCR extracted items, user reviews and corrects (critical screen!)
confirmed — User confirms corrected items, data saved to purchase_items
New schema fields:
ALTER TABLE actual_purchases 
ADD COLUMN ocr_status VARCHAR(20) DEFAULT 'uploaded' 
CHECK (ocr_status IN ('uploaded', 'ocr_processing', 'needs_review', 'confirmed', 'failed'));

ALTER TABLE actual_purchases
ADD COLUMN ocr_raw_result JSONB,  -- raw OCR output for debugging
ADD COLUMN ocr_confidence_score NUMERIC(3, 2);  -- average confidence across items
New screens (to be added to specs):
Screen E10a: OCR Review — User sees extracted items, can edit names, quantities, prices
Screen E10b: Unrecognized Items — Items OCR found but not in products_catalog — user can search manually, skip, or mark as "other"
Fallback: If OCR fails or confidence < 0.7, fall back to manual entry (existing Screen E10).
Consequences:
✅ Clean data for drift analysis (core differentiator)
✅ User can correct OCR errors (critical for research validity)
✅ Audit trail of OCR confidence and corrections
❌ More complex UX (additional screens)
❌ OCR API costs (Google Vision: $1.50 per 1000 images)
❌ Latency (OCR processing takes 2-5 seconds)
Implementation priority: HIGH — this is part of the core differentiator (Step 4).
ADR-012: Define Profile Recalculation Trigger
Status: Accepted
Context: The current user flow does not define what happens when a user uploads new lab results (e.g., follow-up after 15 days). The profile may change based on new biomarker values, but there's no defined trigger or transition logic.
Decision: Implement automatic profile recalculation on new lab upload with explicit transition logic:
Trigger: When lab_results with timepoint = 'follow_up' is created and processing_status = 'completed':
Engine re-evaluates all 5 axes using new lab values
Engine selects new profile using hierarchy (steps 0-4)
Compare old profile vs new profile
If profile changed:
Archive old profile (is_active = FALSE)
Create new profile (is_active = TRUE)
Generate new recommended cart based on new profile
Notify user: "Your profile has changed from Profile X to Profile Y based on your new labs"
If profile unchanged:
Keep current profile active
Update axis_evaluations with new values
Notify user: "Your labs improved/stayed the same. Keep up the good work!"
Transition logic:
go
func onNewLabResults(userID uuid.UUID, newLabID uuid.UUID) error {
    // 1. Evaluate new axes
    newAxes, err := engine.EvaluateAllAxes(userID, newLabID)
    
    // 2. Select new profile
    newProfile, err := engine.SelectProfile(newAxes)
    
    // 3. Get current active profile
    currentProfile, err := repo.GetActiveProfile(userID)
    
    // 4. Compare and transition
    if newProfile.Number != currentProfile.Number {
        // Profile changed
        repo.ArchiveProfile(currentProfile.ID)
        repo.CreateProfile(newProfile)
        notifyUser(userID, fmt.Sprintf("Profile changed: %s → %s", 
            currentProfile.Name, newProfile.Name))
        
        // Generate new cart
        newCart, err := cartService.GenerateCart(userID, newProfile.ID)
    } else {
        // Profile unchanged
        repo.UpdateAxisEvaluations(currentProfile.AxisEvaluationID, newAxes)
        notifyUser(userID, "Your labs stayed stable. Great job!")
    }
}
Edge cases:
User uploads multiple labs in same timepoint → use most recent
User uploads lab with missing biomarkers → graceful degradation (ADR-005)
Profile changes from 5 → 1 (improvement) → celebrate in UX
Profile changes from 1 → 5 (deterioration) → sensitive messaging, suggest doctor consultation
Consequences:
✅ Automatic profile updates keep recommendations relevant
✅ Clear transition logic prevents confusion
✅ Supports longitudinal study design (baseline → follow-up)
❌ Need to handle profile changes gracefully in UX
❌ May confuse users if profile changes frequently (mitigated by clear messaging)
ADR-013: Define Graceful Degradation Branch in User Flow
Status: Accepted | Elaborates ADR-005
Context: The user flow does not explicitly define how the engine behaves when data for one or more axes is missing (Level D in the architecture document). Without a defined graceful degradation branch, the engine may fail or produce incorrect profiles.
Decision: Implement explicit graceful degradation logic in the engine with clear UX feedback:
Degradation levels:
| Mode | Available Data | Available Profiles | UX Feedback |
| ------- | ------- | ------- | ------- |
| Minimal | Only glucose + TG/HDL | Profile 1, 2 | "Based on limited data, we can estimate your carb sensitivity. For more accurate results, upload full labs." |
| Basic | All labs (4 axes) | Profile 1, 2, 3, 4 | "Good data! We've analyzed 4 metabolic axes. Connect HRV for even more insights." |
| Extended | Labs + HRV (no CGM) | Profile 1, 2, 3, 4, 5 | "Excellent! We've analyzed all 5 axes including your nervous system." |
| Full | Labs + CGM + HRV + hormonal | 1–5 + all modifiers | "Perfect! We have complete data for real-time recommendations." |

Engine logic:
func EvaluateAllAxes(data map[string]float64, gender string) (map[int]string, string) {
    axes := make(map[int]string)
    availableAxes := 0
    
    // Axis 1: Glycemic
    if hasData(data, "glucose", "hba1c") {
        axes[1] = evaluateAxis1(data["glucose"], data["hba1c"], data["tg_hdl_ratio"])
        availableAxes++
    } else {
        axes[1] = "no_data"
    }
    
    // Axis 2: Lipid
    if hasData(data, "tg", "hdl") {
        axes[2] = evaluateAxis2(data["tg"], data["hdl"], gender)
        availableAxes++
    } else {
        axes[2] = "no_data"
    }
    
    // ... repeat for axes 3, 4, 5
    
    // Determine degradation mode
    mode := determineDegradationMode(availableAxes, hasHRV, hasCGM)
    
    return axes, mode
}

func determineDegradationMode(availableAxes int, hasHRV, hasCGM bool) string {
    switch {
    case availableAxes >= 4 && hasHRV && hasCGM:
        return "full"
    case availableAxes >= 4 && hasHRV:
        return "extended"
    case availableAxes >= 4:
        return "basic"
    default:
        return "minimal"
    }
}
UX implementation:
Show data completeness indicator on axes dashboard (e.g., "4/5 axes analyzed")
For missing axes: show grayed-out card with "Upload [biomarker] for complete analysis"
For minimal mode: show banner "Limited data — upload full labs for better accuracy"
Consequences:
✅ Engine never blocks on missing data
✅ Clear UX feedback manages user expectations
✅ Supports progressive data collection (user can add more labs over time)
❌ Less accurate profiles with minimal data
❌ Need to handle no_data status throughout the app
ADR-014: Use Open Food Facts + USDA FoodData Central for Product Catalog
Status: Accepted
Context: Manually populating products_catalog with thousands of US grocery products is impractical. We need a scalable, maintainable source of product data with UPC codes, nutritional information, and categorization.
Decision: Use two free, open data sources:
Open Food Facts — 3M+ products, covers US market, has UPC barcodes, licensed under ODbL (commercial use with attribution)
USDA FoodData Central — Official USDA database, free API, no restrictions, comprehensive nutritional data
Implementation:
Initial catalog populated from Open Food Facts (products with UPC codes)
Nutritional data enriched from USDA FoodData Central
Products stored in products_catalog with upc_code, name, category, nutritional_data (JSONB)
Sync job runs weekly to update prices, add new products, mark discontinued items
Schema additions:
sql
ALTER TABLE products_catalog
ADD COLUMN upc_code VARCHAR(20) UNIQUE,
ADD COLUMN source VARCHAR(20) DEFAULT 'manual' CHECK (source IN ('manual', 'open_food_facts', 'usda')),
ADD COLUMN nutritional_data JSONB,  -- calories, macros, micros
ADD COLUMN last_synced_at TIMESTAMPTZ;
Why this matters for Phase 2: UPC codes stored now become the bridge to retailer integration (Instacart, Walmart) in Phase 2. When we integrate with retailers, we can match products by UPC code.
Consequences:
✅ No manual data entry
✅ Scalable to millions of products
✅ UPC codes enable future retailer integration
❌ Need to handle data quality issues (Open Food Facts has duplicates, incomplete data)
❌ Attribution required for Open Food Facts (ODbL license)
❌ Weekly sync job adds operational overhead
License compliance:
Open Food Facts: Must attribute "Data from Open Food Facts" in app
USDA FoodData Central: Public domain, no attribution required
ADR-015: Real-Time CGM Notifications are Roadmap (Not Beta)
Status: Accepted
Context: Screen 4.3 in wireframes shows real-time CGM notifications (dG/dt = −0.8 mg/dL/min, "eat protein + fat now"). However, this requires direct CGM device API integration (Stelo, Dexcom, Libre), which is out of scope for the beta. The beta uses Apple Health / Google Fit as aggregation layer, which has background fetch limitations.
Decision: Mark Screen 4.3 (Real-Time Notifications) as roadmap for beta. In the beta:
HRV-based notifications (morning RMSSD < 20ms) are supported via Apple Health background fetch (delayed, not real-time)
CGM-based notifications (dG/dt alerts) are NOT supported in beta
Screen 4.3 remains in wireframes as a design mockup for Phase 2
| Notification Type | Beta Support | Mechanism |
| ------- | ------- | ------- |
| HRV morning alert (RMSSD < 20ms) | ✅ Yes | Apple Health background fetch (delayed 15-30 min) |
| CGM rapid drop (dG/dt < -0.7) | ❌ No (roadmap) | Requires direct CGM API |
| Meal reminder (>4h without food) | ✅ Yes | Timer-based, no device data needed |
| Post-dinner walk reminder | ✅ Yes | Time-based (18:00-19:00) |
Consequences:
✅ Reduces beta scope (no direct CGM integration)
✅ Avoids Apple Health background fetch limitations for CGM
❌ Profile 5 users won't get real-time glucose alerts in beta
❌ Need to clearly communicate this limitation to users
Phase 2 plan: Integrate directly with CGM APIs (Stelo, Dexcom, Libre) for real-time notifications. This requires separate API integrations and may require medical device certification.
ADR-016: Factorial Study Design 2×2 (Groups A/B/C/D)
Status: Accepted
Context: The initial research design had 3 groups (A: symptomatic, B: asymptomatic with risk, C: control). However, this design does not allow testing interaction effects between glycemic status and symptomatic phenotype. The PI has revised the design to a 2×2 factorial design.
Decision: Use a 2×2 factorial design with 4 groups:

| Group | Glycemic Status | Symptomatic Phenotype | N |
| ------- | ------- | ------- | ------- |
| A | Normal (HbA1c <5.7%, glucose <100) | Asymptomatic (no symptoms) | 10 |
| B | Impaired (HbA1c 5.7-6.4% OR glucose 100-125) | Asymptomatic (no symptoms) | 10 |
| C | Normal (HbA1c <5.7%, glucose <100) | Symptomatic (≥2 symptoms ≥2×/week) | 10 |
| D | Impaired (HbA1c 5.7-6.4% OR glucose 100-125) | Symptomatic (≥2 symptoms ≥2×/week) | 10 |

Total N = 40 (10 per group)
Why this matters:
Allows testing interaction effects: Does glycemic impairment amplify symptoms?
Enables Profile 5 validation: Group C (normal labs + symptoms) is the target population for Profile 5
Supports hypothesis testing: H1 (dG/dt predicts symptoms), H2 (HRV predicts symptoms), H3 (hyperreactive hunger)
Implementation:
ALTER TABLE users 
MODIFY COLUMN research_group VARCHAR(1) CHECK (research_group IN ('A', 'B', 'C', 'D'));

-- Group assignment logic
-- Group A: HbA1c <5.7% AND glucose <100 AND no symptoms
-- Group B: HbA1c 5.7-6.4% OR glucose 100-125 AND no symptoms
-- Group C: HbA1c <5.7% AND glucose <100 AND symptoms ≥2×/week
-- Group D: HbA1c 5.7-6.4% OR glucose 100-125 AND symptoms ≥2×/week
Consequences:
✅ Enables interaction effect testing
✅ Better statistical power for hypothesis validation
✅ Clear separation of glycemic vs symptomatic phenotypes
❌ More complex group assignment logic
❌ Need to track symptoms systematically (daily symptom logging)
ADR-017: Require date_of_birth in Users Table
Status: Accepted
Context: The users table does not have a date_of_birth field. This is needed for:
Research inclusion criteria (age 18-65 for adults, 25-65 for MetaCart engine)
Hormonal modifier logic (menopause thresholds depend on age)
Age-specific reference ranges (HRV norms vary by age)
Decision: Add date_of_birth DATE NOT NULL to users table. Validate age at registration (must be 18-65).
Implementation:
sql
ALTER TABLE users 
ADD COLUMN date_of_birth DATE NOT NULL;

-- Add check constraint
ALTER TABLE users
ADD CONSTRAINT users_age_check CHECK (
    date_of_birth <= CURRENT_DATE - INTERVAL '18 years'
    AND date_of_birth >= CURRENT_DATE - INTERVAL '65 years'
);

-- Add index for age-based queries
CREATE INDEX idx_users_age ON users(date_of_birth);
Engine logic:
func calculateAge(dob time.Time) int {
    now := time.Now()
    age := now.Year() - dob.Year()
    if now.YearDay() < dob.YearDay() {
        age--
    }
    return age
}

func isEligible(dob time.Time) bool {
    age := calculateAge(dob)
    return age >= 18 && age <= 65
}
Consequences:
✅ Enables age-based eligibility checks
✅ Supports hormonal modifier logic (menopause age thresholds)
✅ Enables age-specific reference ranges
❌ Requires DOB at registration (additional onboarding step)
❌ Privacy consideration: DOB is sensitive data (must be encrypted)
ADR-018: Define grocery_stability_score Formula
Status: OPEN QUESTION — needs PI confirmation
Context: The drift_analyses table has a grocery_stability_score field, but the formula for calculating it is not defined anywhere in the documentation. This score is a key metric for the pilot and product vision.
Proposed formula (pending PI confirmation):

grocery_stability_score = (matched_items / total_recommended_items) × 100
Where:
matched_items = number of items from recommended cart that user actually purchased
total_recommended_items = total number of items in recommended cart
Example:
Recommended: 20 items
Purchased: 17 out of 20
Score: (17 / 20) × 100 = 85%
Alternative formulas to consider:
Option A: Weighted by category
score = Σ(category_weight × matched_in_category / total_in_category) × 100
Where weights: proteins=0.3, vegetables=0.25, fruits=0.15, grains=0.15, fats=0.1, nutraceuticals=0.05
Option B: Penalize excluded items
score = ((matched_items - excluded_items) / total_recommended_items) × 100
Where excluded_items = items user purchased that are in the "exclude" list (cookies, juice, etc.)
Option C: Time-weighted (weekly trend)
score = Σ(week_weight × weekly_score) / Σ(week_weight)Where recent weeks have higher weight (e.g., week 4 = 0.4, week 3 = 0.3, week 2 = 0.2, week 1 = 0.1)
Decision needed from PI:
Which formula to use?
Should the score be normalized (0-100) or raw percentage?
Should it be calculated per purchase or as a rolling average?
Should it account for household size (per-person score)?
Consequences:
✅ Clear metric for pilot success
✅ Enables comparison across users and cultural groups
❌ Wrong formula could mislead users or researchers
❌ Need to validate formula against pilot data
Action item: Schedule meeting with PI to finalize formula before implementing drift analysis.
ADR-019: OpenAPI YAML is the Single Source of Truth for API Contracts
Status: Accepted
Context: Without a single source of truth for API contracts, frontend and backend can diverge, leading to integration issues. Manual DTO creation is error-prone and time-consuming.
Decision: Use OpenAPI YAML (packages/shared/openapi/metacart-api.yaml) as the single source of truth for all API contracts. All DTOs must be generated from this specification.
Rules:
Before implementing any API endpoint, add it to metacart-api.yaml
Define request/response schemas in components/schemas/
Generate DTOs for Go and Flutter using make generate-dto
Implement handlers using generated DTOs
Never manually create DTOs
Workflow:
# 1. Add endpoint to YAML
vim packages/shared/openapi/metacart-api.yaml

# 2. Generate DTOs
cd packages/shared
make generate-dto

# 3. Implement backend
vim apps/api/internal/handlers/labs.go

# 4. Implement frontend
vim apps/mobile/lib/features/onboarding/api/labs_api.dart
Consequences:
✅ Frontend and backend always in sync
✅ No manual DTO maintenance
✅ Easy to split into separate repos later
❌ Slightly more overhead (need to generate DTOs)
❌ Need to maintain OpenAPI spec as single source of truth
How to Add a New Decision
Copy the template above
Fill in the details
Increment the ADR number (next available: ADR-020)
Submit for review
Once accepted, update related files (ARCHITECTURE.md, RULES.md, etc.)
How to Supersede a Decision
Create a new ADR
Reference the old ADR in the Context section
Set old ADR status to "Superseded by ADR-XXX"
Keep the old ADR in this document (for historical record)
Update all references in other files
How to Mark an Open Question
Set status to "OPEN QUESTION — needs [stakeholder] confirmation"
List proposed options with pros/cons
Add "Action item" section with next steps
Once resolved, update status to "Accepted" and remove "OPEN QUESTION" marker
