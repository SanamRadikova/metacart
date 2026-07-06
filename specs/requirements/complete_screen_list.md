| Category | Count | Notes |
| ------- | ------- | ------- |
| Total Screens | 38 | Including error/empty states |
| Onboarding (Phase 1) | 8 | E1-E4 + states |
| Analysis (Phase 2) | 5 | E5-E6 + states |
| Cart (Phase 3) | 6 | E7-E9 + states |
| Step 4 - CORE (Phase 4) | 9 | E10-E12 + OCR pipeline |
| Retention (Phase 5) | 3 | E13-E14 |
| Account/Settings | 7 | Profile, consent, notifications |
🎯 PHASE 1: ONBOARDING (8 screens)
E1: Splash Screen
Purpose: App launch, branding
User Story: US-01 (partial)
Priority: 🔴 P0
States:
Default: Logo + tagline + "Get Started" button
Loading: Spinner while checking auth state
E2: Sign Up / Sign In
Purpose: Authentication
User Stories: US-01, US-03
Priority: 🔴 P0
States:
Sign Up form: Email, password, DOB, "Create Account" button
Sign In form: Email, password, "Sign In" button, "Forgot password?" link
Error state: Invalid credentials, network error
Success state: Redirect to consent screen
Fields:
Email (required, validated)
Password (required, min 8 chars, strength indicator)
Date of Birth (required, age 18-65 validation per ADR-018)
E3: Research Consent
Purpose: IRB-compliant consent for pilot participation
User Story: US-02
Priority: 🔴 P0
States:
Default: Scrollable IRB text + checkbox + "Continue" button
Skipped: "Skip" button → explore-only mode
New version available: Prompt to re-consent
Elements:
Scrollable IRB text (full text, not summary)
Checkbox: "I agree to the research consent"
"Continue" button (enabled only when checkbox checked)
"Skip" button (secondary)
Version hash displayed (for audit)
E4: Lab Upload
Purpose: Upload lab results (PDF/photo/manual)
User Stories: US-04, US-05
Priority: 🔴 P0
States:
Upload mode: File picker / camera button + "Enter manually" link
OCR processing: Spinner + "Processing your labs..."
OCR review: Extracted values for confirmation (see E4a)
Manual entry mode: Form with biomarker fields (see E4b)
Error state: OCR failed, file too large, unsupported format
Success state: Redirect to cultural profile
Elements:
"Upload PDF/Photo" button (primary)
"Enter manually" link (secondary)
File picker (PDF, JPG, PNG)
Camera integration (iOS/Android)
E4a: OCR Review (Lab Values)
Purpose: Review and correct OCR-extracted lab values
User Story: US-04 (alternative)
Priority: 🔴 P0
States:
Default: List of extracted values with units
Editing: User taps field to edit
Low confidence: Highlighted fields (confidence < 0.7)
Missing values: Empty fields marked "Not detected"
Elements:
Biomarker name + extracted value + unit dropdown
Confidence indicator (🟢 high / 🟡 medium / 🔴 low)
"Confirm" button
"Edit" button per field
"Enter manually" fallback link
Fields (all with unit selection):
Glucose (fasting)
HbA1c
Triglycerides
HDL
LDL (optional)
hs-CRP (optional)
TSH (optional)
ALT, AST, WBC, Hemoglobin (optional)
E4b: Manual Lab Entry
Purpose: Manual entry of lab values
User Story: US-05
Priority: 🔴 P0
States:
Default: Form with biomarker fields
Validation error: Out-of-range values highlighted
Partial data: Warning banner "Some biomarkers missing — profile may be less accurate"
Success: Redirect to cultural profile
Elements:
Form fields for each biomarker (see E4a)
Unit dropdown per field (mg/dL, mmol/L, %, etc.)
Validation messages
"Next" button
"Skip optional fields" link
E5: Cultural Profile
Purpose: Select cultural food background
User Stories: US-10, US-11
Priority: 🔴 P0
States:
Default: Dropdown + multi-select tags
Other selected: Free text input for description
Error: Required field not filled
Success: Redirect to device connection
Elements:
Dropdown: Primary cultural background (Eastern European, South Asian, Latino, African-American, Other)
Multi-select: Staple foods (Borscht/Soups, Rice & Dal, Beans & Corn, Fermented, Flatbreads, Bone broth)
Multi-select: Dietary restrictions (Vegetarian, Halal, Kosher, Gluten-free, Dairy-free)
Slider: Household size (1-6)
"Next" button
E6: Device Connection
Purpose: Connect Apple Health / Google Fit
User Stories: US-12, US-13
Priority: 🟡 P1
States:
Default: Buttons for Apple Health / Google Fit
Permission requested: OS permission dialog
Connected: Success message + "Continue" button
Denied: Explanation + "Skip" button
Not available: "Apple Health not found" message
Elements:
"Connect Apple Health" button (iOS only)
"Connect Google Fit" button (Android only)
Explanation text: "Optional but recommended for Profile 5 detection"
"Skip" button (secondary)
"Continue" button (after connection or skip)
E7: Hormonal Status (Female Only)
Purpose: Select hormonal status for threshold modifiers
User Stories: US-15, US-16
Priority: 🟡 P1
States:
Default: Dropdown with options
Selected: Confirmation + "Next" button
Skipped: Default to follicular phase
Elements:
Dropdown: Follicular phase, PMS/Luteal phase, Perimenopause, Postmenopause
Explanation text for each option
"Next" button
"Skip" button (uses default)
Note: Only shown if gender = female
🎯 PHASE 2: ANALYSIS (5 screens)
E8: Axes Dashboard
Purpose: Display 5 metabolic axes with statuses
User Story: US-19
Priority: 🔴 P0
States:
Loading: Skeleton screens for 5 axes
Default: 5 axis cards with 🟢/🟡/🟠/no_data statuses
Minimal mode: Banner "Limited data — upload full labs for better accuracy"
Empty state: "Upload your labs to see axes"
Elements:
Data completeness indicator: "4/5 axes analyzed"
5 axis cards:
Axis 1: Glycemic (glucose, HbA1c, TG/HDL)
Axis 2: Lipid (TG, HDL)
Axis 3: Inflammatory (hs-CRP)
Axis 4: Stress/Thyroid (TSH)
Axis 5: Neuro-Autonomic (HRV RMSSD, SDNN, PNN50)
Each card shows: status icon, axis name, key values, tap for details
"See Your Profile" button (primary)
E9: Axis Detail (Modal/Bottom Sheet)
Purpose: Detailed explanation of one axis
User Story: US-19 (alternative)
Priority: 🟡 P1
States:
Default: Axis name, status, values, explanation
No data: "Upload [biomarker] for complete analysis"
Elements:
Axis name + status
All biomarker values with units
Status explanation (plain language)
Threshold ranges (🟢/🟡/🟠)
"Close" button
E10: Profile Result
Purpose: Display selected profile with explanation
User Story: US-20
Priority: 🔴 P0
States:
Loading: Skeleton screen
Default: Profile name, explanation, principles, modifiers
Profile 5 special: Enhanced explanation "Your labs are normal, but..."
Profile 4 special: TSH explanation "Your TSH is within diagnostic normal range..."
Elements:
Profile name (e.g., "Profile 5: Neuro-Autonomic")
Plain language explanation (2-3 sentences)
Key principles (bullet list)
Modifiers section (if any)
"See 7-Day Menu" button (primary)
"View Axes" button (secondary)
E11: Profile Modifiers (Section in E10)
Purpose: Display secondary axis modifiers
User Story: US-21
Priority: 🟡 P1
Elements:
List of active modifiers:
"Axis 3 (Inflammation) is elevated → Add fatty fish 2×/week"
"Axis 2 (Lipids) needs attention → Add olive oil, nuts"
Each modifier shows: axis name, status, action
E12: Profile History
Purpose: Timeline of profile changes
User Story: US-48
Priority: 🟡 P1
States:
Default: Timeline with dates, profile numbers
Empty: "No profile history yet"
Single entry: "Baseline profile"
Elements:
Timeline view (vertical)
Each entry: date, profile number, profile name, key changes
Tap entry → see details
🎯 PHASE 3: CART GENERATION (6 screens)
E13: 7-Day Menu
Purpose: Display personalized meal plan
User Story: US-23
Priority: 🟡 P1
States:
Loading: Skeleton screens
Default: Week view (Mon-Sun) with meals
Day selected: Meals for that day
Empty: "Generate your menu first"
Elements:
Week selector (horizontal scroll: Mon-Sun)
Day cards with meals:
Breakfast
Lunch
Dinner
Snack
Tap meal → recipe details (modal)
"Generate Grocery Cart" button (primary)
E14: Cart Settings
Purpose: Set budget tier and household size
User Stories: US-24, US-25
Priority: 🔴 P0
States:
Default: Budget tier selector + household slider
Changed: "Regenerate cart?" confirmation
Elements:
Budget tier selector (3 cards):
🟢 LOW (Walmart/Aldi)
🟡 MID (Costco/Target)
🔵 HIGH (Whole Foods)
Household size slider (1-6)
Explanation: "Proteins ×2, grains stepped, nutraceuticals ×1"
"View Cart" button (primary)
E15: Shopping Cart
Purpose: Display recommended grocery list
User Story: US-27
Priority: 🔴 P0
States:
Loading: Skeleton screens
Default: Items grouped by category
Empty: "Generate your cart first"
Nutraceuticals present: Disclaimer banner
Elements:
Cart items grouped by category:
Proteins (eggs, yogurt, salmon)
Vegetables (beets, spinach, avocados)
Fruits, Grains, Fats/Oils, etc.
Nutraceuticals (Profile 5 only)
Each item: name, quantity, unit, estimated price
Total estimated cost
Disclaimer banner (if nutraceuticals): "Consult your doctor before taking supplements"
"Export" button (primary)
"Regenerate" button (secondary)
E16: Cart Export
Purpose: Export cart as CSV/PDF
User Story: US-28
Priority: 🔴 P0
States:
Default: Format selector (CSV/PDF)
Exporting: Spinner
Success: "Exported! Share or save"
Error: "Export failed, try again"
Elements:
Format selector: CSV, PDF
"Export" button
Share sheet (iOS/Android native)
"Save to device" option
E17: Recipe Detail (Modal)
Purpose: Show recipe details
User Story: US-23 (alternative)
Priority: 🟢 P2
Elements:
Recipe name + photo
Ingredients list
Instructions (step-by-step)
Nutritional info (calories, macros)
"Close" button
E18: Cart Item Detail (Modal)
Purpose: Show item details
User Story: US-27 (alternative)
Priority: 🟢 P2
Elements:
Product name + photo
Quantity + unit
Estimated price
Nutritional info
"Why this item?" explanation (based on profile)
"Close" button
🎯 PHASE 4: STEP 4 — CORE DIFFERENTIATOR (9 screens)
E19: Purchase Capture (Home)
Purpose: Entry point for capturing actual purchases
User Story: US-29, US-30
Priority: 🔴 P0
States:
Default: Two options (manual / receipt photo)
No cart: "Generate cart first" message
Elements:
"Upload Receipt Photo" button (primary)
"Enter Manually" button (secondary)
Explanation: "Compare what you bought with recommendations"
Recent purchases list (last 5)
E20: Manual Purchase Entry
Purpose: Manually enter purchased items
User Story: US-29
Priority: 🔴 P0
States:
Default: Form with item fields
Adding items: List of entered items
Success: Redirect to drift dashboard
Elements:
Item entry form:
Product name (autocomplete from catalog)
Quantity
Unit
Price (optional)
"Add Item" button
List of entered items (swipe to delete)
"Save" button
E21: Receipt Upload
Purpose: Upload receipt photo for OCR
User Story: US-30
Priority: 🔴 P0
States:
Default: Camera / file picker
Uploading: Spinner + progress bar
OCR processing: "Processing receipt..." spinner
Success: Redirect to OCR review (E22)
Error: "Upload failed, try again"
Elements:
"Take Photo" button (camera)
"Choose from Gallery" button (file picker)
Preview of selected image
"Upload" button
"Enter manually instead" link (fallback)
E22: OCR Review (Receipt Items) ⭐ CRITICAL
Purpose: Review and correct OCR-extracted items
User Story: US-33
Priority: 🔴 P0
States:
Default: List of extracted items
Editing: User taps item to edit
Low confidence: Highlighted items (confidence < 0.7)
Unrecognized items: Link to E23
Success: Redirect to drift analysis
Elements:
List of extracted items:
Product name (editable)
Quantity (editable)
Price (editable)
Confidence indicator (🟢/🟡/🔴)
"Unrecognized items (X)" link → E23
"Confirm" button
"Add item" button
"Delete" (swipe)
Note: This is the most critical screen for data quality (ADR-012)
E23: Unrecognized Items
Purpose: Handle items OCR couldn't match
User Story: US-34
Priority: 🔴 P0
States:
Default: List of unrecognized items
Searching: Autocomplete search
Success: All items handled
Elements:
List of unrecognized items:
Original OCR text
Actions: "Search", "Skip", "Mark as Other"
Search bar with autocomplete (from products_catalog)
"Done" button
E24: Purchase Summary
Purpose: View captured purchases with match status
User Story: US-32
Priority: 🔴 P0
States:
Default: Items grouped by match status
Empty: "No purchases yet"
Elements:
Items grouped by status:
✓ Matched (green)
⚠️ Drift (yellow)
✗ Excluded (red)
? No match (gray)
Each item: name, quantity, price, status icon
Tap item → see details
E25: Drift Dashboard ⭐ CORE
Purpose: Display drift analysis over time
User Story: US-39
Priority: 🔴 P0
States:
Loading: Skeleton screens
Default: Current score + weekly trend
Empty: "Capture your first purchase to see drift"
Improved: Positive feedback message
Declined: Supportive message
Elements:
Current week's match percentage (large number)
Weekly trend chart (bar chart: W1, W2, W3, W4)
Top drifts list:
"Refined grains +3 items"
"Leafy greens -2 items"
Feedback message (based on trend)
Tap week → E26 (drift details)
E26: Drift Details (Weekly)
Purpose: Detailed drift analysis for one week
User Story: US-40
Priority: 🔴 P0
States:
Default: Matched/drift/excluded items
Perfect match: "You bought exactly what was recommended!"
Elements:
Week selector
Items grouped by status:
Matched items (✓) with recommended vs actual
Drift items (⚠️) — what user bought instead
Excluded items (✗) — what user bought that's excluded
Missing items — what user didn't buy
Tap item → explanation
E27: Drift Trends
Purpose: Long-term drift trends
User Story: US-41
Priority: 🟡 P1
States:
Default: Line chart over weeks
Single week: Single data point
Elements:
Line chart: match percentage over weeks
Average score
Best week, worst week
Insights (from E28)
E28: Drift Insights
Purpose: Actionable insights about drift patterns
User Story: US-42
Priority: 🟡 P1
States:
Default: Pattern analysis
No patterns: "Keep tracking to see patterns emerge"
Elements:
Most common drift items
Categories with most drift
Recovery patterns (e.g., "You tend to drift on weekends")
Actionable suggestions
🎯 PHASE 5: RETENTION (3 screens)
E29: Follow-up Reminder (Notification)
Purpose: Remind user to upload follow-up labs
User Story: US-47 (partial)
Priority: 🟡 P1
Elements:
Push notification: "Time for your follow-up labs! Upload now to see how your profile has changed."
Deep link → E4 (lab upload)
E30: Follow-up Lab Upload
Purpose: Upload follow-up labs (same as E4 but with timepoint=follow_up)
User Story: US-47
Priority: 🔴 P0
Note: Reuses E4 flow, but backend sets timepoint = 'follow_up'
E31: Profile Change Notification
Purpose: Notify user of profile change
User Story: US-49
Priority: 🟡 P1
Elements:
Push notification: "Your profile has changed from Profile X to Profile Y. Your recommendations have been updated."
Deep link → E10 (profile result)
🎯 ACCOUNT & SETTINGS (7 screens)
E32: Settings (Home)
Purpose: Access all settings
User Stories: US-11, US-16, US-46, US-50, US-51
Priority: 🔴 P0
Elements:
List of settings:
Cultural Profile → E5
Hormonal Status → E7
Notifications → E33
Research Consent → E34
Account → E35
About → E36
E33: Notification Preferences
Purpose: Manage notification settings
User Story: US-46
Priority: 🟡 P1
Elements:
Toggles:
HRV morning alerts
Meal reminders
Post-dinner walk reminders
Profile change notifications
"Save" button
E34: Research Consent Management
Purpose: View/withdraw consent
User Story: US-50
Priority: 🔴 P0
States:
Default: Consent status + "Withdraw" button
Confirming: "Are you sure?" dialog
Withdrawn: "Consent withdrawn" message
Elements:
Consent status: "Active" / "Withdrawn"
Consent date
"View consent text" link
"Withdraw consent" button (destructive)
Confirmation dialog
E35: Account Management
Purpose: Deactivate/reactivate account
User Stories: US-51, US-52
Priority: 🔴 P0
States:
Default: Account info + "Deactivate" button
Confirming: "Are you sure?" dialog
Deactivated: "Account deactivated" message
Elements:
Email, DOB, join date
"Deactivate account" button (destructive)
Confirmation dialog
Explanation: "You can reactivate later by signing in"
E36: About
Purpose: App info, version, legal
User Story: N/A
Priority: 🟢 P2
Elements:
App version
"Terms of Service" link
"Privacy Policy" link
"Open Food Facts attribution" (ADR-015)
"Contact support" link
E37: Error Screen (Global)
Purpose: Display errors
User Story: N/A
Priority: 🔴 P0
States:
Network error: "Check your connection"
Server error: "Something went wrong"
Not found: "Page not found"
Elements:
Error icon
Error message
"Retry" button
"Go home" button
E38: Empty State (Global)
Purpose: Display empty states
User Story: N/A
Priority: 🔴 P0
Elements:
Illustration
Message (e.g., "No labs uploaded yet")
Call-to-action button (e.g., "Upload labs")








| User Story | Screens Covered |
| ------- | ------- |
| US-01 (Register) | E2 |
| US-02 (Consent) | E3 |
| US-03 (Sign In) | E2 |
| US-04 (Upload labs OCR) | E4, E4a |
| US-05 (Manual lab entry) | E4b |
| US-06 (View labs) | E8 (axes) |
| US-07 (Re-upload labs) | E4 |
| US-10 (Cultural profile) | E5 |
| US-12 (Apple Health) | E6 |
| US-13 (Google Fit) | E6 |
| US-15 (Hormonal status) | E7 |
| US-17 (Evaluate axes) | E8 |
| US-18 (Select profile) | E10 |
| US-19 (View axes) | E8, E9 |
| US-20 (View profile) | E10 |
| US-23 (View menu) | E13, E17 |
| US-24 (Budget tier) | E14 |
| US-26 (Generate cart) | E15 |
| US-28 (Export cart) | E16 |
| US-29 (Manual purchase) | E20 |
| US-30 (Receipt upload) | E21 |
| US-33 (OCR review) | E22 |
| US-34 (Unrecognized items) | E23 |
| US-39 (Drift dashboard) | E25 |
| US-40 (Drift details) | E26 |
| US-46 (Notification prefs) | E33 |
| US-47 (Profile recalc) | E30, E31 |
| US-48 (Profile history) | E12 |
| US-50 (Withdraw consent) | E34 |
| US-51 (Deactivate) | E35 |

---

## 📋 Complete User Story → Screen Traceability (Extended)

> **Status:** Comprehensive mapping below. Each User Story (US-01 through US-56) is mapped to the primary screen(s) that implement it. This complements the per-screen tables above.

| US ID | Title | Primary Screen(s) | Notes |
| ----- | ----- | ----------------- | ----- |
| US-01 | Sign up / Sign in / Onboarding | E1, E2, E3, E4, E4a/E4b, E5, E6, E7 | Splash → Sign Up → Consent → Labs → Cultural → Devices → Hormonal |
| US-02 | Research consent | E3 | IRB-compliant |
| US-03 | Re-sign-in after deactivation | E2 | UC-52 reactivation on sign-in |
| US-04 | Upload lab PDF/photo (OCR) | E4, E4a | OCR pipeline |
| US-05 | Enter lab values manually | E4b | Manual entry fallback |
| US-06 | (no spec) | — | — |
| US-07 | (no spec) | — | — |
| US-08 | Skip onboarding step | E3, E5, E6, E7 | All onboarding steps have Skip |
| US-09 | Resume onboarding | E1 | Per UC-03 — resume from first incomplete step |
| US-10 | Select cultural background | E5 | 6 supported groups + "other" |
| US-11 | Edit cultural profile in settings | E5, E32 | Edit from settings hub |
| US-12 | Connect Apple Health | E6 | iOS HRV/CGM data |
| US-13 | Connect Google Fit | E6 | Android HRV data |
| US-14 | Skip device connection | E6 | Graceful degradation |
| US-15 | Select hormonal status | E7 | Female users only |
| US-16 | Edit hormonal status in settings | E7, E32 | Edit from settings hub |
| US-17 | View 5 metabolic axes | E8 | Axes dashboard |
| US-18 | Profile calculation (5 profiles) | E10 | Backend — EvaluateProfile service |
| US-19 | View axis details | E8, E9 | Tap axis card → modal |
| US-20 | View active profile | E10 | Profile result screen |
| US-21 | View profile modifiers + nutraceuticals | E10, E11 | Modifiers section |
| US-22 | View 7-day menu | E13 | Cultural-adapted menu |
| US-23 | View recipe details | E17 | Modal — recipe from /menu/week cache |
| US-24 | Configure cart (budget + household) | E14 | Cart settings |
| US-25 | Generate cart from menu | E14, E15 | POST /carts/generate |
| US-26 | View shopping cart | E15 | Categories + total |
| US-27 | View cart item details | E18 | Modal |
| US-28 | Export cart (CSV/PDF) | E16 | Beta scope — no checkout |
| US-29 | Manual purchase entry | E20 | Capture without receipt |
| US-30 | Receipt photo (OCR) | E21, E22 | OCR pipeline |
| US-31 | Product matching (drift detection) | Backend | Service `MatchPurchase` |
| US-32 | View purchase summary | E24 | Match status by item |
| US-33 | Review OCR results | E22 | Confidence scoring 🟢/🟡/🔴 |
| US-34 | Handle unrecognized items | E23 | Search / Skip / Mark as Other |
| US-35 | Add item to manual purchase | E20 | Inline add |
| US-36 | Delete item from manual purchase | E20 | Swipe-to-delete |
| US-37 | View item price (manual) | E20 | Optional price field |
| US-38 | View drift dashboard | E25 | Core differentiator ⭐ |
| US-39 | Empty drift state | E25 | UC-39 A1 — Capture CTA |
| US-40 | View weekly drift details | E26 | Matched/Drift/Excluded/Missing |
| US-41 | View drift trends over time | E27 | Line chart + stats |
| US-42 | View drift insights | E28 | Pattern analysis |
| US-43 | Log symptom (dizzy, brain fog) | E_symptom | Profile 5 users |
| US-44 | Symptom log + context (HRV, dG/dt) | E_symptom | Auto-fill from device_readings |
| US-45 | View recent purchases | E19 | Last 5 + View All |
| US-46 | Configure notification preferences | E33 | 5 toggles, debounced save |
| US-47 | Upload follow-up labs (30+ days) | E29, E30 | Push + in-app reminder |
| US-48 | View profile history | E12 | Timeline + change indicators |
| US-49 | Receive profile change notification | E31 | Improvement vs worsening tone |
| US-50 | Withdraw research consent | E34 | UC-50 — IRB right-to-withdraw |
| US-51 | Deactivate account | E35 | UC-51 — soft delete |
| US-52 | Reactivate account (sign in) | E2 | UC-52 — undo deactivation |
| US-53 | (no spec) | — | — |
| US-54 | (no spec) | — | — |
| US-55 | (no spec) | — | — |
| US-56 | (no spec) | — | — |

### Backend-only User Stories (no UI screen)

| US ID | Title | Implementation | Notes |
| ----- | ----- | -------------- | ----- |
| US-31 | Product matching + drift calc | `internal/services/matching.go` | Core differentiator logic |
| US-18 | Profile selection logic | `internal/services/profile.go` | 5-profile decision tree |

### Admin-only User Stories (not in mobile app)

| US ID | Title | Endpoint | Notes |
| ----- | ----- | -------- | ----- |
| Hard delete | 7-year IRB retention purge | `POST /api/v1/admin/account/delete` | Admin-only, not in mobile client |
| Research export | Bulk participant data | `GET /api/v1/admin/research/export` | For IRB reporting |

### Push Notification-triggered User Stories

| US ID | Trigger | Destination | Notes |
| ----- | ------- | ----------- | ----- |
| US-47 | 30/37/44/51 days since baseline | E4 with `timepoint=follow_up` | Reminder cascade |
| US-49 | Profile change detected | E10 with new profile | Celebration or supportive |
| HRV alerts | RMSSD < 25 + Profile 5 | E_symptom | Daily morning check |
| Meal reminders | 4+ hours since last meal + Profile 5 | E19 | Timer-based |
| Post-dinner walk | 18:00–19:00 + any profile | (in-app) | 1-min movement reminder |
