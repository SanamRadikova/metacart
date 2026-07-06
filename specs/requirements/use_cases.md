| Epic ID | Epic Name | User Stories | Priority | ADR Covered |
| ------- | ------- | ------- | ------- | ------- |
| EP-01 | Authentication & Consent | US-01 to US-03 | 🔴 P0 | 010 |
| EP-02 | Lab Upload & Processing | US-04 to US-09 | 🔴 P0 | 007, 008, 011 |
| EP-03 | Cultural Profile Setup | US-10 to US-11 | 🔴 P0 | 011 |
| EP-04 | Device Connection | US-12 to US-14 | 🟡 P1 | 002, 016 |
| EP-05 | Hormonal Status | US-15 to US-16 | 🟡 P1 | — |
| EP-06 | Axes Evaluation & Profile Selection | US-17 to US-21 | 🔴 P0 | 005, 006, 011, 014 |
| EP-07 | Menu Generation | US-22 to US-23 | 🟡 P1 | — |
| EP-08 | Cart Generation & Export | US-24 to US-28 | 🔴 P0 | 015 |
| EP-09 | Purchase Capture (CORE) | US-29 to US-32 | 🔴 P0 | 004, 012 |
| EP-10 | OCR Pipeline | US-33 to US-37 | 🔴 P0 | 012 |
| EP-11 | Drift Analysis | US-38 to US-42 | 🔴 P0 | 004, 019 |
| EP-12 | Notifications (Beta) | US-43 to US-46 | 🟡 P1 | 016 |
| EP-13 | Profile Recalculation | US-47 to US-49 | 🔴 P0 | 013 |
| EP-14 | Account Management | US-50 to US-53 | 🔴 P0 | 010, 018 |
| EP-15 | Graceful Degradation | US-54 to US-56 | 🔴 P0 | 006, 014 |

EP-01: Authentication & Consent
US-01: Register Account
As a new user, I want to create an account with email and password, so that I can access MetaCart.
Acceptance Criteria:
Given I am on the registration screen, when I enter valid email + password + DOB, then account is created
Given I enter DOB outside 18-65 range, then registration is blocked with explanation
UC-01: User Registration
Actor: New user
Preconditions: User has not registered yet, age 18-65
Main Flow:
User opens app → Splash screen appears
User taps "Sign Up"
User enters email, password, date of birth
System validates email format, password strength, age (18-65)
System creates user record with `research_group = NULL` (assigned automatically after baseline labs + symptoms)
System sends verification email
User verifies email → redirected to consent screen
Alternative Flows:
A1: Invalid age — System shows error "MetaCart is for adults 18-65. Please contact support if you believe this is an error."
A2: Email already exists — System prompts "Account exists. Sign in or reset password."
A3: Weak password — System shows password requirements, blocks submission
A4: Network error — System retries 3x, then shows "Check connection and try again"
Postconditions: User record created, onboarding_step = 1, email verification pending
US-02: Provide Research Consent
As a pilot participant, I want to review and sign the IRB-approved consent form, so that my data can be used for research.
Acceptance Criteria:
Given I am registered, when I reach consent screen, I see full IRB text
Given I check "I agree", then consent is recorded with version hash and timestamp
Given I skip consent, then I can explore app but cannot participate in pilot
UC-02: Research Consent
Actor: Registered user
Preconditions: User registered, email verified
Main Flow:
User sees consent screen with IRB text (scrollable)
User reads text, checks "I agree to the research consent"
User taps "Continue"
System records consent: consent_version, consent_text_hash, agreed_at, ip_address, device_info
System sets onboarding_step = 2
User proceeds to lab upload
Alternative Flows:
A1: User skips consent — System records skipped_consent = TRUE, user enters "explore-only" mode, cannot participate in pilot
A2: Consent text updated (new version) — System detects version mismatch, prompts user to re-consent
A3: User scrolls partially — System tracks scroll position, requires full scroll before enabling checkbox (optional UX)
Postconditions: Consent recorded in research_consents, audit log entry created
US-03: Sign In
As a returning user, I want to sign in with my credentials, so that I can access my data.
Acceptance Criteria:
Given I have an account, when I enter correct email + password, then I am signed in
Given I enter wrong credentials 5x, then account is temporarily locked
UC-03: User Sign In
Actor: Registered user
Preconditions: User has account, email verified
Main Flow:
User enters email + password
System validates credentials
System returns JWT token
User sees home screen (or resumes onboarding if incomplete)
Alternative Flows:
A1: Wrong password — System shows "Invalid credentials", increments failed attempts
A2: Account locked (5 failed attempts) — System shows "Account locked for 15 minutes. Reset password?"
A3: User forgot password — User taps "Forgot password", receives reset email
A4: Account soft-deleted — System shows "This account has been deactivated. Contact support."
Postconditions: User authenticated, JWT issued
EP-02: Lab Upload & Processing
US-04: Upload Lab PDF/Photo
As a user, I want to upload a PDF or photo of my lab results, so that the system can extract values automatically.
Acceptance Criteria:
Given I am on lab upload screen, when I upload PDF/photo, then OCR extracts values
Given OCR confidence < 0.7, then I am prompted to review/correct manually
UC-04: Lab Upload via OCR
Actor: User in onboarding
Preconditions: User completed consent, has lab document (PDF or photo)
Main Flow:
User taps "Upload PDF/Photo"
System opens file picker (PDF) or camera (photo)
User selects document
System uploads to Supabase Storage, creates lab_results record with source_type = 'ocr'
System sends to OCR service (Google Vision API)
OCR extracts biomarker values + units
System normalizes units to standard (mg/dL, %, etc.)
System displays extracted values for user review
User confirms or corrects values
System saves to lab_values with both value_original and value_normalized
System sets processing_status = 'completed'
Alternative Flows:
A1: OCR fails (confidence < 0.7) — System prompts "We couldn't read this clearly. Enter manually or try another photo."
A2: Missing biomarkers in OCR — System highlights missing fields, prompts user to enter manually
A3: Unit ambiguity (e.g., hs-CRP) — System asks "Is this mg/L or mg/dL?" with explanation
A4: File too large (>10MB) — System compresses or prompts to use smaller file
A5: Unsupported file format — System shows "Supported: PDF, JPG, PNG. Please convert and retry."
Postconditions: lab_results created, lab_values populated, processing_status = 'completed'
US-05: Enter Labs Manually
As a user, I want to enter my lab values manually, so that I can use MetaCart even if OCR doesn't work.
Acceptance Criteria:
Given I am on lab upload screen, when I tap "Enter manually", then I see input fields for each biomarker
Given I enter value + unit, then system normalizes and validates
UC-05: Manual Lab Entry
Actor: User in onboarding
Preconditions: User completed consent
Main Flow:
User taps "Enter manually"
System shows form with fields: Glucose, HbA1c, TG, HDL, LDL, hs-CRP, TSH, ALT, AST, WBC, Hemoglobin
User enters values, selects units from dropdown (mg/dL, mmol/L, %, etc.)
System validates ranges (e.g., glucose 50-500 mg/dL)
System normalizes units to standard
User taps "Next"
System saves to lab_results + lab_values
Alternative Flows:
A1: Value out of range — System highlights field, shows "Value seems incorrect. Expected range: X-Y"
A2: Missing required fields (glucose, HbA1c, TG, HDL) — System blocks submission, shows "Please enter at least glucose, HbA1c, TG, HDL"
A3: User enters partial data — System allows (graceful degradation), marks missing axes as no_data
A4: User switches units mid-entry — System re-normalizes all values
Postconditions: lab_results created, lab_values populated
US-06: View Lab Values
As a user, I want to see my uploaded lab values, so that I can verify they were entered correctly.
Acceptance Criteria:
Given I have uploaded labs, when I view lab summary, then I see all values with units
Given values were normalized, then I see both original and normalized values
UC-06: View Lab Summary
Actor: User
Preconditions: User has uploaded labs
Main Flow:
User navigates to "My Labs" screen
System displays list of lab results (baseline, follow-up)
User taps on a lab result
System shows detailed view: biomarker, original value + unit, normalized value + unit, axis status (🟢/🟡/🟠)
Alternative Flows:
A1: No labs uploaded — System shows empty state: "Upload your labs to get started"
A2: Labs processing — System shows spinner: "Processing your labs..."
A3: Labs need review (OCR low confidence) — System highlights fields needing review
Postconditions: User sees lab summary
US-07: Re-upload Labs
As a user, I want to re-upload my labs if I made a mistake, so that my profile is accurate.
Acceptance Criteria:
Given I have uploaded labs, when I tap "Re-upload", then I can upload new document
Given I re-upload, then old lab values are archived (not deleted)
UC-07: Re-upload Labs
Actor: User
Preconditions: User has uploaded labs, processing_status = 'completed'
Main Flow:
User navigates to "My Labs"
User taps "Re-upload" on existing lab
System prompts "This will replace your current labs. Continue?"
User confirms
System archives old lab_results (sets is_archived = TRUE)
User uploads new document (OCR or manual)
System creates new lab_results record
System re-evaluates axes and profile (triggers EP-13)
Alternative Flows:
A1: User cancels — System returns to lab summary
A2: New upload fails — System keeps old labs, shows error
Postconditions: Old labs archived, new labs created, profile recalculated
US-08: Normalize Lab Units
As the system, I want to normalize all lab values to standard units, so that the engine can evaluate them consistently.
Acceptance Criteria:
Given a lab value with non-standard unit, when it is saved, then it is converted to standard unit
Given conversion is ambiguous (e.g., hs-CRP mg/dL vs mg/L), then user is prompted to confirm
UC-08: Unit Normalization
Actor: System (backend)
Preconditions: Lab value entered with unit
Main Flow:
User enters value + unit (e.g., glucose 5.5 mmol/L)
System looks up conversion in lab_units_reference table
System applies conversion (e.g., 5.5 × 18.02 = 99.1 mg/dL)
System saves both value_original = 5.5, unit_original = 'mmol/L', value_normalized = 99.1, unit_standard = 'mg/dL'
System evaluates axis using normalized value
Alternative Flows:
A1: No conversion found — System flags error, prompts user to check unit
A2: HbA1c mmol/mol — System uses formula (value / 10.929) + 2.15, not linear multiplication
A3: hs-CRP ambiguity — System detects value < 1.0, prompts "Is this mg/dL or mg/L?"
Postconditions: Value normalized, axis evaluated
US-09: Validate Lab Values
As the system, I want to validate lab values against expected ranges, so that I can catch data entry errors.
Acceptance Criteria:
Given a lab value is outside plausible range, then system flags it for review
Given a lab value indicates diabetes (glucose ≥126, HbA1c ≥6.5%), then system excludes user from MetaCart
UC-09: Lab Validation
Actor: System (backend)
Preconditions: Lab value entered
Main Flow:
System receives normalized lab value
System checks against plausible range (e.g., glucose 50-500 mg/dL)
If value is plausible, system saves it
If value indicates exclusion (glucose ≥126, HbA1c ≥6.5%, TSH >10), system flags for medical consultation
Alternative Flows:
A1: Value implausible (e.g., glucose 5 mg/dL) — System prompts "This value seems incorrect. Please verify."
A2: Value indicates diabetes — System shows "Your results indicate diabetes. MetaCart is a preventive tool, not a treatment. Please consult your doctor." User can still explore app but cannot participate in pilot.
A3: Value indicates overt hypothyroidism (TSH >10) — System shows "Your TSH suggests hypothyroidism. Please consult your doctor. MetaCart can provide supportive dietary recommendations."
Postconditions: Value validated, exclusion flagged if needed
EP-03: Cultural Profile Setup
US-10: Select Cultural Background
As a user, I want to select my cultural food background, so that recommendations match my food traditions.
Acceptance Criteria:
Given I am in onboarding, when I reach cultural profile screen, then I see list of cultural groups
Given I select a cultural group, then system saves it and uses it for recommendations
UC-10: Cultural Background Selection
Actor: User in onboarding
Preconditions: User uploaded labs
Main Flow:
System shows cultural profile screen
User selects primary cultural background from dropdown (6 supported groups, stored in snake_case in DB):
  - Eastern European (eastern_european)
  - South Asian (south_asian)
  - Latino (latino)
  - African-American (african_american)
  - East Asian / Chinese (east_asian)
  - Standard American (standard_american)
User may also select "Other" which captures free-text via primary_culture VARCHAR
User selects staple foods (multi-select): Borscht/Soups, Rice & Dal, Beans & Corn, Fermented, Flatbreads, Bone broth, etc.
User selects dietary restrictions (multi-select): Vegetarian, Halal, Kosher, Gluten-free, Dairy-free
User sets household size (slider 1-6)
User taps "Next"
System saves to cultural_profiles
Alternative Flows:
A1: User selects "Other" — System prompts "Describe your food traditions" (free text)
A2: User skips cultural profile — System blocks (required for pilot): "Cultural profile is required for accurate recommendations"
A3: User changes cultural profile later — User can edit in settings, system regenerates recommendations
Postconditions: cultural_profiles created, used for menu/cart generation
US-11: Edit Cultural Profile
As a user, I want to edit my cultural profile later, so that I can update it if my preferences change.
Acceptance Criteria:
Given I have a cultural profile, when I edit it, then system regenerates recommendations
UC-11: Edit Cultural Profile
Actor: User
Preconditions: User has cultural profile
Main Flow:
User navigates to Settings → Cultural Profile
User edits fields (cultural background, staple foods, restrictions, household size)
User taps "Save"
System updates cultural_profiles, creates history entry in cultural_profile_history
System regenerates menu and cart based on new profile
Alternative Flows:
A1: User cancels edit — System discards changes
A2: User changes household size — System recalculates cart quantities
Postconditions: Cultural profile updated, recommendations regenerated
EP-04: Device Connection
US-12: Connect Apple Health
As an iOS user, I want to connect Apple Health, so that MetaCart can read my HRV and CGM data.
Acceptance Criteria:
Given I am on device connection screen, when I tap "Connect Apple Health", then system requests permissions
Given I grant permissions, then system can read HRV, glucose, sleep, steps
UC-12: Apple Health Connection
Actor: iOS user in onboarding
Preconditions: User has Apple Health app with data
Main Flow:
System shows device connection screen
User taps "Connect Apple Health"
System opens iOS permission dialog
User grants read access to: HRV, Blood Glucose, Sleep, Steps
System saves to device_connections with device_type = 'apple_health', connection_status = 'connected', permissions = [...]
System syncs data (background fetch)
Alternative Flows:
A1: User denies permissions — System shows "Apple Health access is optional but recommended for Profile 5 detection"
A2: User doesn't have Apple Health — System shows "Apple Health not found. You can skip this step."
A3: User revokes permissions later — System detects on next sync, prompts to re-connect
Postconditions: device_connections created, data sync enabled
US-13: Connect Google Fit
As an Android user, I want to connect Google Fit, so that MetaCart can read my HRV and CGM data.
Acceptance Criteria:
Given I am on device connection screen, when I tap "Connect Google Fit", then system requests permissions via Health Connect
Given I grant permissions, then system can read HRV, glucose, sleep, steps
UC-13: Google Fit Connection
Actor: Android user in onboarding
Preconditions: User has Google Fit or Health Connect (Android 14+)
Main Flow:
System shows device connection screen
User taps "Connect Google Fit"
System opens Health Connect permission dialog
User grants read access to: HRV, Blood Glucose, Sleep, Steps
System saves to device_connections with device_type = 'google_fit'
System syncs data
Alternative Flows:
A1: User denies permissions — System shows "Google Fit access is optional"
A2: User doesn't have Health Connect — System prompts to install or skip
A3: Android version < 14 — System shows "Health Connect requires Android 14+. Please update or skip."
Postconditions: device_connections created, data sync enabled
US-14: Sync Device Data
As the system, I want to sync data from connected devices periodically, so that I have up-to-date HRV and CGM data.
Acceptance Criteria:
Given a device is connected, when sync runs, then new readings are saved to device_readings
Given CGM data is available, then system computes dG/dt
UC-14: Device Data Sync
Actor: System (background job)
Preconditions: Device connected, permissions granted
Main Flow:
System triggers sync (every 15 min via background fetch)
System queries Apple Health / Google Fit for new readings since last_sync_at
System saves readings to device_readings (partitioned by month)
For CGM glucose readings, system computes dG/dt = (G_current - G_previous) / time_delta
System updates last_sync_at
Alternative Flows:
A1: No new data — System skips, no records created
A2: Sync fails (network error) — System retries 3x, then logs error
A3: Device disconnected — System detects, sets connection_status = 'disconnected'
Postconditions: device_readings updated, dG/dt computed
EP-05: Hormonal Status
US-15: Select Hormonal Status
As a female user, I want to select my hormonal status, so that recommendations account for hormonal effects.
Acceptance Criteria:
Given I am female, when I reach hormonal status screen, then I see dropdown with options
Given I select a status, then system applies threshold modifiers
UC-15: Hormonal Status Selection
Actor: Female user in onboarding
Preconditions: User selected gender = female
Main Flow:
System shows hormonal status screen
User selects from dropdown: Follicular phase, PMS/Luteal phase, Perimenopause, Postmenopause
User taps "Next"
System saves to hormonal_statuses with status, threshold_modifier.
`threshold_modifier` is a single multiplier in DB, but the Go engine applies it PER-AXIS:
- PMS        -> +10% on Axis 1 (Glycemic glucose threshold shifts 90 -> 99 mg/dL)
              +20% on Axis 5 (RMSSD threshold shifts 25 -> 30 ms)
- Perimenopause -> defaults to Profile 5 if any symptoms present
- Postmenopause -> standard, enhanced protein emphasis
- Follicular -> baseline (no modifier)
- not_applicable (men) -> no modifier applied
Alternative Flows:
A1: User is male — System skips this screen, sets status = 'not_applicable'
A2: User skips — System uses default (follicular phase)
A3: User changes status later — User can edit in settings, system re-evaluates profile
Postconditions: hormonal_statuses created, threshold modifiers applied
US-16: Update Hormonal Status
As a female user, I want to update my hormonal status if it changes, so that recommendations stay accurate.
Acceptance Criteria:
Given I have a hormonal status, when I update it, then system re-evaluates profile
UC-16: Update Hormonal Status
Actor: Female user
Preconditions: User has hormonal status
Main Flow:
User navigates to Settings → Hormonal Status
User selects new status
User taps "Save"
System updates hormonal_statuses
System re-evaluates axes and profile (triggers EP-13)
Alternative Flows:
A1: User cancels — System discards changes
Postconditions: Hormonal status updated, profile recalculated
EP-06: Axes Evaluation & Profile Selection
US-17: Evaluate 5 Axes
As the system, I want to evaluate all 5 metabolic axes based on lab values, so that I can determine the user's profile.
Acceptance Criteria:
Given lab values are uploaded, when evaluation runs, then each axis gets status (🟢/🟡/🟠/no_data)
Given a biomarker is missing, then that axis is marked no_data
UC-17: Axes Evaluation
Actor: System (engine)
Preconditions: Lab values uploaded and normalized
Main Flow:
System retrieves normalized lab values
System evaluates Axis 1 (Glycemic): glucose, HbA1c, TG/HDL ratio → status
System evaluates Axis 2 (Lipid): TG, HDL (gender-specific) → status
System evaluates Axis 3 (Inflammatory): hs-CRP → status (or no_data if missing)
System evaluates Axis 4 (Stress/Thyroid): TSH → status (or no_data if missing)
System evaluates Axis 5 (Neuro-Autonomic): HRV RMSSD, SDNN, PNN50 → status (or no_data if missing)
System checks for SDNN paradox (SDNN >150 AND RMSSD <25) → flags as 🟠
System saves to axis_evaluations
Alternative Flows:
A1: Missing biomarkers — System marks axis as no_data, continues evaluation
A2: Cultural-specific thresholds — System uses user's cultural_group to select thresholds from reference_ranges
A3: Hormonal modifier active — System applies threshold modifier to Axis 5 (e.g., PMS → RMSSD threshold reduced by 20%)
Postconditions: axis_evaluations created with 5 axis statuses
US-18: Select Profile
As the system, I want to select 1 primary profile based on axis statuses, so that I can generate personalized recommendations.
Acceptance Criteria:
Given axis evaluations are complete, when profile selection runs, then 1 profile is selected using hierarchy (steps 0-4)
Given multiple axes are active, then highest priority axis determines profile
UC-18: Profile Selection
Actor: System (engine)
Preconditions: Axis evaluations complete
Main Flow:
System checks Step 0: Axis 5 = 🟠 OR SDNN paradox OR dG/dt < -0.7 with symptoms OR hormonal modifier + HRV <35 → Profile 5
If Step 0 not triggered, check Step 1: Axis 4 = 🟠 → Profile 4
If Step 1 not triggered, check Step 2: Axis 3 = 🟠 → Profile 3
If Step 2 not triggered, check Step 3: Axis 1 or 2 = 🟡/🟠 → Profile 2
If Step 3 not triggered, check Step 4: All axes 🟢 → Profile 1
System saves selected profile to profiles with profile_number, selection_step, selection_reason
System identifies secondary axes as modifiers
Alternative Flows:
A1: All axes no_data — System cannot select profile, prompts user to upload labs
A2: Profile 5 triggered by dG/dt — System requires symptom log confirmation
A3: Profile 5 triggered by hormonal modifier — System applies threshold modifier
Postconditions: profiles created, modifiers identified
US-19: View Axes Dashboard
As a user, I want to see my 5 metabolic axes with statuses, so that I understand my metabolic health.
Acceptance Criteria:
Given axes are evaluated, when I view axes dashboard, then I see 5 axes with 🟢/🟡/🟠/no_data statuses
Given an axis is no_data, then I see explanation "Upload [biomarker] for complete analysis"
UC-19: View Axes Dashboard
Actor: User
Preconditions: Axes evaluated
Main Flow:
User navigates to "My Axes" screen
System displays 5 axis cards:
Axis 1: Glycemic — status + key values (glucose, HbA1c)
Axis 2: Lipid — status + key values (TG, HDL)
Axis 3: Inflammatory — status + hs-CRP value
Axis 4: Stress/Thyroid — status + TSH value
Axis 5: Neuro-Autonomic — status + HRV values
User taps on an axis → system shows detailed explanation
Alternative Flows:
A1: Axis is no_data — System shows grayed-out card with "Upload [biomarker] for complete analysis"
A2: Data completeness indicator — System shows "4/5 axes analyzed" at top
A3: Minimal mode (only glucose + TG/HDL) — System shows banner "Limited data — upload full labs for better accuracy"
Postconditions: User sees axes dashboard
US-20: View Profile Result
As a user, I want to see my selected profile with explanation, so that I understand my metabolic type.
Acceptance Criteria:
Given profile is selected, when I view profile screen, then I see profile name, explanation, key principles
Given profile is Profile 5, then I see explanation "Your labs are normal, but your nervous system shows signs of dysregulation"
UC-20: View Profile Result
Actor: User
Preconditions: Profile selected
Main Flow:
User taps "See Your Profile" from axes dashboard
System displays profile screen:
Profile name (e.g., "Profile 5: Neuro-Autonomic")
Explanation in plain language
Key principles (e.g., "Protein + fat + fiber at every meal")
Modifiers (e.g., "Omega-3 2g/day")
User taps "See 7-Day Menu"
Alternative Flows:
A1: Profile 4 (TSH >2.5) — System shows explanation "Your TSH is within diagnostic normal range, but MetaCart uses functional range to optimize metabolic health"
A2: Profile 5 with normal labs — System shows explanation "Your labs look normal, but your nervous system shows signs of dysregulation. Symptoms may come from how fast glucose drops, not the level itself."
Postconditions: User sees profile result
US-21: View Profile Modifiers
As a user, I want to see secondary axis modifiers, so that I understand additional recommendations.
Acceptance Criteria:
Given secondary axes are active, when I view profile, then I see modifiers (e.g., "Add omega-3 due to inflammation")
UC-21: View Profile Modifiers
Actor: User
Preconditions: Profile selected, secondary axes active
Main Flow:
User views profile screen
System displays modifiers section:
"Axis 3 (Inflammation) is elevated → Add fatty fish 2×/week, flaxseed oil, turmeric"
"Axis 2 (Lipids) needs attention → Add olive oil, nuts, avocado"
Modifiers are added to cart automatically
Alternative Flows:
A1: No modifiers — System shows "No additional modifications needed"
Postconditions: User sees modifiers
EP-07: Menu Generation
US-22: Generate 7-Day Menu
As the system, I want to generate a 7-day menu based on profile and cultural preferences, so that the user has a personalized meal plan.
Acceptance Criteria:
Given profile and cultural profile are set, when menu generation runs, then 7-day menu is created
Given user is Profile 5, then menu emphasizes protein + fat + fiber
UC-22: Menu Generation
Actor: System (engine)
Preconditions: Profile selected, cultural profile set
Main Flow:
System retrieves profile + cultural profile
System selects recipes from recipe database based on profile principles
System filters by cultural staple foods and dietary restrictions
System generates 7-day menu (breakfast, lunch, dinner, snack for each day)
System saves menu (in-memory or separate table)
Alternative Flows:
A1: User is vegetarian — System excludes meat/fish recipes
A2: User is halal/kosher — System filters recipes accordingly
A3: No recipes match cultural profile — System uses closest match, flags for review
Postconditions: 7-day menu generated
US-23: View 7-Day Menu
As a user, I want to see my 7-day menu, so that I know what to eat each day.
Acceptance Criteria:
Given menu is generated, when I view menu screen, then I see 7 days with meals
Given I tap a day, then I see meals for that day
UC-23: View 7-Day Menu
Actor: User
Preconditions: Menu generated
Main Flow:
User navigates to "My Menu" screen
System displays week view (Mon-Sun)
User taps a day → system shows meals (breakfast, lunch, dinner, snack)
User taps a meal → system shows recipe details (ingredients, instructions)
Alternative Flows:
A1: Menu not generated — System shows "Generate your menu first"
A2: User wants to swap a meal — System allows swap from alternatives (future feature)
Postconditions: User sees menu
EP-08: Cart Generation & Export
US-24: Set Budget Tier
As a user, I want to select my budget tier (LOW/MID/HIGH), so that the cart matches my price preferences.
Acceptance Criteria:
Given I am on cart settings screen, when I select a tier, then system applies it to cart
Given I select LOW, then cart uses Walmart/Aldi products
UC-24: Budget Tier Selection
Actor: User
Preconditions: Menu generated
Main Flow:
User navigates to "Cart Settings" screen
User selects budget tier: LOW (Walmart/Aldi), MID (Costco/Target), HIGH (Whole Foods)
System saves to recommended_carts.budget_tier
System regenerates cart with tier-specific products
Alternative Flows:
A1: User changes tier later — System regenerates cart
Postconditions: Budget tier set, cart regenerated
US-25: Set Household Size
As a user, I want to set household size, so that cart quantities are scaled correctly.
Acceptance Criteria:
Given I set household size, when cart is generated, then quantities are scaled
Given household size = 2, then proteins ×2, grains stepped (2 packs)
UC-25: Household Size Setting
Actor: User
Preconditions: Menu generated
Main Flow:
User sets household size (slider 1-6)
System saves to recommended_carts.household_size
System scales quantities:
Proteins/vegetables/fruits: × N
Grains/bread: stepped (1 person = 1 pack, 2-3 = 2 packs, 4+ = 3 packs)
Oils/spices: slow scaling (1 bottle for 1-3 people)
Nutraceuticals (Profile 5): always ×1 (personal dose)
System regenerates cart
Alternative Flows:
A1: User changes household size later — System regenerates cart
Postconditions: Household size set, cart quantities scaled
US-26: Generate Shopping Cart
As the system, I want to generate a shopping cart from the menu, so that the user has a ready-to-buy list.
Acceptance Criteria:
Given menu, budget tier, household size are set, when cart generation runs, then cart is created with trade units and prices
Given user is Profile 5, then nutraceuticals are added with disclaimer
UC-26: Cart Generation
Actor: System (engine)
Preconditions: Menu generated, budget tier set, household size set
Main Flow:
System extracts all ingredients from 7-day menu
System aggregates quantities (e.g., eggs = 14 per week)
System converts to trade units (14 eggs → 1 pack of 18)
System looks up products in products_catalog by name/UPC
System applies budget tier (LOW/MID/HIGH) to select specific products
System estimates prices
System saves to recommended_carts + cart_items
If Profile 5, system adds nutraceuticals with requires_disclaimer = TRUE
Alternative Flows:
A1: Product not found in catalog — System uses closest match or generic description
A2: Nutraceuticals for Profile 5 — System adds disclaimer "Consult your doctor before taking supplements"
Postconditions: recommended_carts + cart_items created
US-27: View Shopping Cart
As a user, I want to see my shopping cart, so that I know what to buy.
Acceptance Criteria:
Given cart is generated, when I view cart screen, then I see items grouped by category with quantities and prices
Given total cost is calculated, then I see estimated total
UC-27: View Shopping Cart
Actor: User
Preconditions: Cart generated
Main Flow:
User navigates to "My Cart" screen
System displays cart items grouped by category:
Proteins (eggs, yogurt, salmon, etc.)
Vegetables (beets, spinach, avocados, etc.)
Fruits, Grains, Fats/Oils, etc.
Nutraceuticals (if Profile 5)
Each item shows: name, quantity, unit, estimated price
System shows total estimated cost
Alternative Flows:
A1: Cart empty — System shows "Generate your cart first"
A2: Nutraceuticals present — System shows disclaimer banner
Postconditions: User sees shopping cart
US-28: Export Cart
As a user, I want to export my cart as CSV or PDF, so that I can use it for shopping.
Acceptance Criteria:
Given cart is generated, when I tap "Export", then system generates CSV or PDF
Given I export, then I can share or save the file
UC-28: Cart Export
Actor: User
Preconditions: Cart generated
Main Flow:
User taps "Export" on cart screen
System prompts "Export as CSV or PDF?"
User selects format
System generates file with items, quantities, prices
System saves to device or shares via system share sheet
System updates recommended_carts.exported_format, exported_at
Alternative Flows:
A1: Export fails — System shows error, prompts retry
A2: User wants to print — System opens print dialog
Postconditions: Cart exported, exported_at updated
EP-09: Purchase Capture (CORE!)
US-29: Capture Purchase Manually
As a user, I want to enter what I actually bought, so that MetaCart can compare it with recommendations.
Acceptance Criteria:
Given I have a recommended cart, when I tap "Capture Purchase", then I can enter items manually
Given I enter items, then system matches them with recommended cart
UC-29: Manual Purchase Capture
Actor: User after shopping
Preconditions: Recommended cart exists
Main Flow:
User taps "Capture Purchase" on home screen
System shows manual entry form
User enters items: product name, quantity, price (optional)
User taps "Save"
System creates actual_purchases record with capture_method = 'manual'
System creates purchase_items records
System matches each item with cart_items (fuzzy matching)
System sets match_status for each item (matches/drift/excluded/no_match)
System triggers drift analysis (EP-11)
Alternative Flows:
A1: User wants to upload receipt instead — System redirects to OCR pipeline (EP-10)
A2: Item not in recommended cart — System marks as drift or no_match
A3: User buys excluded item (cookies, juice) — System marks as excluded
Postconditions: actual_purchases + purchase_items created, drift analysis triggered
US-30: Upload Receipt Photo
As a user, I want to upload a photo of my receipt, so that OCR can extract items automatically.
Acceptance Criteria:
Given I have a receipt photo, when I upload it, then system sends to OCR service
Given OCR extracts items, then I can review and correct them
UC-30: Receipt Photo Upload
Actor: User after shopping
Preconditions: User has receipt photo
Main Flow:
User taps "Upload Receipt" on purchase capture screen
System opens camera or file picker
User takes photo or selects from gallery
System uploads to Supabase Storage, saves URL in actual_purchases.receipt_image_url
System creates actual_purchases record with capture_method = 'receipt_photo', ocr_status = 'uploaded'
System sends to OCR service (Google Vision API)
System updates ocr_status = 'ocr_processing'
OCR extracts items
System updates ocr_status = 'needs_review', saves ocr_raw_result
System redirects to OCR review screen (UC-34)
Alternative Flows:
A1: OCR fails — System sets ocr_status = 'failed', prompts manual entry
A2: Image too blurry — System prompts "Image is unclear. Try another photo or enter manually."
A3: Network error — System retries 3x, then shows error
Postconditions: Receipt uploaded, OCR processing started
US-31: Match Purchases with Recommendations
As the system, I want to match actual purchases with recommended cart, so that I can compute drift.
Acceptance Criteria:
Given purchase items are captured, when matching runs, then each item gets match_status
Given an item matches a recommended item, then match_status = 'matches'
UC-31: Purchase Matching
Actor: System (engine)
Preconditions: Purchase items captured
Main Flow:
System retrieves purchase_items
For each purchase item, system searches cart_items for match:
Exact name match → matches
Fuzzy match (Levenshtein distance < 3) → matches
UPC code match → matches
No match → drift or no_match
System checks if item is in "exclude" list (cookies, juice, etc.) → excluded
System saves match_status for each item
System triggers drift analysis
Alternative Flows:
A1: Multiple matches found — System picks best match, flags for user review
A2: Item is generic (e.g., "milk") — System matches by category, not exact name
Postconditions: All purchase items have match_status
US-32: View Purchase Summary
As a user, I want to see a summary of my purchase vs. recommendations, so that I understand what I bought.
Acceptance Criteria:
Given purchases are captured and matched, when I view summary, then I see items grouped by match status
UC-32: View Purchase Summary
Actor: User
Preconditions: Purchases captured and matched
Main Flow:
User navigates to "My Purchases" screen
System displays purchase summary:
Matched items (✓)
Drift items (⚠️)
Excluded items (✗)
No match items (?)
User taps an item → system shows details
Alternative Flows:
A1: No purchases yet — System shows empty state: "Capture your first purchase to see drift"
Postconditions: User sees purchase summary
EP-10: OCR Pipeline
US-33: Review OCR Results
As a user, I want to review OCR-extracted items, so that I can correct errors before saving.
Acceptance Criteria:
Given OCR has extracted items, when I view review screen, then I see list of items with names, quantities, prices
Given I edit an item, then system updates it
UC-33: OCR Review
Actor: User
Preconditions: OCR processing complete, ocr_status = 'needs_review'
Main Flow:
System shows OCR review screen with extracted items
Each item shows: name (editable), quantity (editable), price (editable), confidence score
User reviews items, corrects errors (e.g., "GV LG EGGS 18CT" → "Eggs 18ct")
User taps "Confirm"
System saves corrected items to purchase_items
System updates ocr_status = 'confirmed'
System triggers matching (UC-31) and drift analysis (EP-11)
Alternative Flows:
A1: Item has low confidence (<0.7) — System highlights item, suggests manual verification
A2: User wants to delete an item — User swipes to delete
A3: User wants to add an item OCR missed — User taps "Add item"
Postconditions: OCR results confirmed, ocr_status = 'confirmed'
US-34: Handle Unrecognized Items
As a user, I want to handle items OCR couldn't match, so that I can decide what to do with them.
Acceptance Criteria:
Given OCR found items not in products_catalog, when I view unrecognized items screen, then I can search, skip, or mark as "other"
UC-34: Handle Unrecognized Items
Actor: User
Preconditions: OCR review complete, some items unrecognized
Main Flow:
System shows unrecognized items screen
For each unrecognized item, user can:
Search in products_catalog and select match
Skip (item not saved)
Mark as "Other" (saved with generic description)
User taps "Done"
System saves decisions
Alternative Flows:
A1: No matches found in catalog — User marks as "Other"
A2: User skips all unrecognized items — System saves only recognized items
Postconditions: All items handled
US-35: Retry OCR
As a user, I want to retry OCR if it failed, so that I can get better results.
Acceptance Criteria:
Given OCR failed, when I tap "Retry", then system re-processes the receipt
UC-35: Retry OCR
Actor: User
Preconditions: OCR failed (ocr_status = 'failed')
Main Flow:
User taps "Retry OCR"
System resets ocr_status = 'uploaded'
System re-sends to OCR service
System updates status through pipeline
Alternative Flows:
A1: Retry fails again — System prompts manual entry
Postconditions: OCR re-processed
US-36: Fall Back to Manual Entry
As a user, I want to fall back to manual entry if OCR doesn't work, so that I can still capture purchases.
Acceptance Criteria:
Given OCR fails or confidence is low, when I tap "Enter manually", then I can enter items manually
UC-36: Fallback to Manual Entry
Actor: User
Preconditions: OCR failed or low confidence
Main Flow:
User taps "Enter manually"
System redirects to manual entry form (UC-29)
User enters items
System saves to purchase_items
Alternative Flows:
A1: User wants to try OCR again — User taps "Retry OCR" (UC-35)
Postconditions: Manual entry completed
US-37: View OCR History
As a user, I want to see my OCR processing history, so that I can track past receipts.
Acceptance Criteria:
Given I have uploaded receipts, when I view OCR history, then I see list of receipts with status
UC-37: View OCR History
Actor: User
Preconditions: User has uploaded receipts
Main Flow:
User navigates to "OCR History" screen
System displays list of receipts:
Date uploaded
Status (uploaded/processing/needs_review/confirmed/failed)
Number of items extracted
User taps a receipt → system shows details
Alternative Flows:
A1: No receipts uploaded — System shows empty state
Postconditions: User sees OCR history
EP-11: Drift Analysis
US-38: Compute Drift Score
As the system, I want to compute drift score for each purchase, so that I can track how far actual purchases deviate from recommendations.
Acceptance Criteria:
Given purchases are matched, when drift analysis runs, then match_percentage and drift_percentage are computed
Given formula is defined (ADR-018), then score is calculated
======= REPLACE

UC-38: Drift Score Computation
Actor: System (engine)
Preconditions: Purchases matched
Main Flow:
System retrieves matched purchase items
System computes:
matched_items = count of items with match_status = 'matches'
total_recommended_items = count of items in cart_items
match_percentage = (matched_items / total_recommended_items) × 100
drift_percentage = 100 - match_percentage
System computes grocery_stability_score (formula TBD, see ADR-018)
======= REPLACE

System saves to drift_analyses
Alternative Flows:
A1: No recommended cart — System cannot compute drift, prompts user to generate cart first
A2: All items are drift — System shows 0% match, 100% drift
Postconditions: drift_analyses created with scores
US-39: View Drift Dashboard
As a user, I want to see my drift dashboard, so that I can track my grocery environment over time.
Acceptance Criteria:
Given drift analyses exist, when I view dashboard, then I see weekly trend and current score
Given score improved, then I see positive feedback
UC-39: View Drift Dashboard
Actor: User
Preconditions: Drift analyses exist
Main Flow:
User navigates to "Drift Dashboard" screen
System displays:
Current week's match percentage (e.g., 87%)
Weekly trend chart (W1, W2, W3, W4)
Top drifts (e.g., "Refined grains +3 items", "Leafy greens -2 items")
Positive feedback if score improved
User taps a week → system shows details for that week
Alternative Flows:
A1: No drift data yet — System shows empty state: "Capture your first purchase to see drift"
A2: Score declined — System shows supportive message: "It's okay to have off weeks. Let's get back on track!"
Postconditions: User sees drift dashboard
US-40: View Drift Details
As a user, I want to see detailed drift analysis for a specific week, so that I understand what drifted.
Acceptance Criteria:
Given I tap a week on drift dashboard, when details load, then I see matched/drift/excluded items
UC-40: View Drift Details
Actor: User
Preconditions: Drift analysis exists for selected week
Main Flow:
User taps a week on drift dashboard
System displays detailed view:
Matched items (✓) with recommended vs actual
Drift items (⚠️) — what user bought instead
Excluded items (✗) — what user bought that's excluded
Missing items — what user didn't buy but was recommended
User taps an item → system shows explanation
Alternative Flows:
A1: No drift that week — System shows "Perfect match! You bought exactly what was recommended."
Postconditions: User sees drift details
US-41: View Drift Trends
As a user, I want to see my drift trends over time, so that I can track long-term progress.
Acceptance Criteria:
Given multiple drift analyses exist, when I view trends, then I see chart over weeks
UC-41: View Drift Trends
Actor: User
Preconditions: Multiple drift analyses exist
Main Flow:
User navigates to "Trends" tab on drift dashboard
System displays line chart: match percentage over weeks
System shows average score, best week, worst week
Alternative Flows:
A1: Only 1 week of data — System shows single data point
Postconditions: User sees trends
US-42: Receive Drift Insights
As a user, I want to receive insights about my drift patterns, so that I can understand my behavior.
Acceptance Criteria:
Given drift analysis is complete, when insights are generated, then I see actionable feedback
UC-42: Drift Insights
Actor: System (engine)
Preconditions: Drift analysis complete
Main Flow:
System analyzes drift patterns:
Most common drift items (e.g., "You often buy white bread instead of whole grain")
Categories with most drift (e.g., "Refined grains")
Recovery patterns (e.g., "You tend to drift on weekends")
System generates insights
System displays on drift dashboard
Alternative Flows:
A1: No patterns detected — System shows "Keep tracking to see patterns emerge"
Postconditions: Insights displayed
EP-12: Notifications (Beta Scope)
US-43: Receive HRV Morning Alert
As a Profile 5 user with HRV connected, I want to receive a morning alert if my HRV is low, so that I can adjust my day.
Acceptance Criteria:
Given I am Profile 5 with HRV connected, when my morning RMSSD < 20ms, then I receive notification
Given notification is delivered, then I see message "Your HRV is low today — especially important not to skip meals"
UC-43: HRV Morning Alert
Actor: System (background job)
Preconditions: User is Profile 5, HRV connected, morning data available
Main Flow:
System checks morning HRV data (via Apple Health background fetch)
If RMSSD < 20ms, system generates notification
System sends push notification: "Your HRV is low today — especially important not to skip meals and add protein to each"
User receives notification
Alternative Flows:
A1: HRV data not available (delayed sync) — System skips notification, tries again later
A2: User disabled notifications — System does not send
A3: User is not Profile 5 — System does not send
Postconditions: Notification sent (if conditions met)
US-44: Receive Meal Reminder
As a Profile 5 user, I want to receive a reminder if I haven't eaten in 4+ hours, so that I can avoid symptoms.
Acceptance Criteria:
Given I am Profile 5, when 4+ hours pass without meal log, then I receive reminder
UC-44: Meal Reminder
Actor: System (timer-based)
Preconditions: User is Profile 5
Main Flow:
System tracks time since last meal log
If 4+ hours pass, system sends notification: "Time to eat — long intervals may worsen symptoms"
User receives notification
Alternative Flows:
A1: User logged meal — System resets timer
A2: User disabled notifications — System does not send
Postconditions: Notification sent (if conditions met)
US-45: Receive Post-Dinner Walk Reminder
As a user, I want to receive a reminder to walk after dinner, so that I can reduce glucose spikes.
Acceptance Criteria:
Given it's 18:00-19:00, when reminder triggers, then I receive notification
UC-45: Post-Dinner Walk Reminder
Actor: System (time-based)
Preconditions: User has enabled notifications
Main Flow:
At 18:30, system sends notification: "1 minute of movement after dinner reduces postprandial peak by 42%"
User receives notification
Alternative Flows:
A1: User disabled notifications — System does not send
Postconditions: Notification sent
US-46: Manage Notification Preferences
As a user, I want to manage my notification preferences, so that I can control what I receive.
Acceptance Criteria:
Given I navigate to settings, when I view notification preferences, then I can toggle each notification type
UC-46: Manage Notification Preferences
Actor: User
Preconditions: User has account
Main Flow:
User navigates to Settings → Notifications
System displays toggles for each notification type:
HRV morning alerts
Meal reminders
Post-dinner walk reminders
User toggles preferences
System saves preferences
Alternative Flows:
A1: User disables all notifications — System saves, does not send any
Postconditions: Preferences saved
EP-13: Profile Recalculation
US-47: Recalculate Profile on New Labs
As the system, I want to recalculate the user's profile when new labs are uploaded, so that recommendations stay accurate.
Acceptance Criteria:
Given user uploads follow-up labs, when processing completes, then system re-evaluates axes and profile
Given profile changed, then system notifies user
UC-47: Profile Recalculation
Actor: System (triggered by lab upload)
Preconditions: User uploads follow-up labs
Main Flow:
User uploads follow-up labs (UC-04 or UC-05)
System processes labs, normalizes units
System re-evaluates all 5 axes (UC-17)
System selects new profile (UC-18)
System compares old profile vs new profile
If profile changed:
System archives old profile (is_active = FALSE)
System creates new profile (is_active = TRUE)
System generates new cart based on new profile
System notifies user: "Your profile has changed from Profile X to Profile Y based on your new labs"
If profile unchanged:
System updates axis_evaluations with new values
System notifies user: "Your labs improved/stayed the same. Keep up the good work!"
Alternative Flows:
A1: Profile improved (e.g., 5 → 1) — System shows celebratory message: "Great progress! Your metabolic health has improved."
A2: Profile worsened (e.g., 1 → 5) — System shows sensitive message: "Your labs suggest increased metabolic stress. Consider consulting your doctor."
A3: Labs incomplete (missing biomarkers) — System uses graceful degradation (EP-15)
Postconditions: Profile recalculated, user notified
US-48: View Profile History
As a user, I want to see my profile history, so that I can track changes over time.
Acceptance Criteria:
Given I have multiple profiles over time, when I view history, then I see timeline of profile changes
UC-48: View Profile History
Actor: User
Preconditions: User has multiple profiles (baseline + follow-up)
Main Flow:
User navigates to "Profile History" screen
System displays timeline:
Date, profile number, profile name
Key axis changes
User taps a profile → system shows details
Alternative Flows:
A1: Only 1 profile — System shows single entry
Postconditions: User sees profile history
US-49: Receive Profile Change Notification
As a user, I want to receive a notification when my profile changes, so that I know my recommendations have updated.
Acceptance Criteria:
Given profile changed, when notification is sent, then I see message with old and new profile
UC-49: Profile Change Notification
Actor: System
Preconditions: Profile changed after follow-up labs
Main Flow:
System detects profile change
System generates notification: "Your profile has changed from Profile X to Profile Y. Your recommendations have been updated."
System sends push notification
Alternative Flows:
A1: User disabled notifications — System shows in-app message instead
Postconditions: Notification sent
EP-14: Account Management
US-50: Withdraw Consent
As a pilot participant, I want to withdraw my research consent, so that my data is no longer used for research.
Acceptance Criteria:
Given I navigate to settings, when I tap "Withdraw consent", then system soft-deletes my data
Given consent is withdrawn, then withdrew_at is recorded, data is preserved for audit
UC-50: Withdraw Consent
Actor: Pilot participant
Preconditions: User has given consent
Main Flow:
User navigates to Settings → Research Consent
User taps "Withdraw consent"
System prompts "Are you sure? Your data will be preserved for audit but no longer used for research."
User confirms
System updates research_consents.withdrew_at = NOW()
System calls soft_delete_user() function (ADR-009):
======= REPLACE

Sets deleted_at on user and all related records
Creates audit log entry with reason
System logs user out
System shows "Consent withdrawn. Thank you for participating."
Alternative Flows:
A1: User cancels — System returns to settings
A2: User wants to delete account entirely — System explains data must be preserved for IRB, offers to deactivate instead
Postconditions: Consent withdrawn, data soft-deleted, audit log created
US-51: Deactivate Account
As a user, I want to deactivate my account, so that I can stop using MetaCart without deleting data.
Acceptance Criteria:
Given I deactivate, when I try to sign in, then system shows "Account deactivated"
UC-51: Deactivate Account
Actor: User
Preconditions: User has account
Main Flow:
User navigates to Settings → Account
User taps "Deactivate account"
System prompts "Are you sure? You can reactivate later by signing in."
User confirms
System sets users.deleted_at = NOW() (soft-delete)
System logs user out
Alternative Flows:
A1: User cancels — System returns to settings
A2: User wants to reactivate later — User signs in, system detects deleted_at, prompts "Reactivate account?"
Postconditions: Account deactivated (soft-deleted)
US-52: Reactivate Account
As a deactivated user, I want to reactivate my account, so that I can use MetaCart again.
Acceptance Criteria:
Given my account is deactivated, when I sign in, then system prompts to reactivate
UC-52: Reactivate Account
Actor: Deactivated user
Preconditions: User account is soft-deleted
Main Flow:
User signs in with email + password
System detects deleted_at IS NOT NULL
System prompts "Your account is deactivated. Reactivate?"
User confirms
System sets deleted_at = NULL on user and related records
System logs user in
Alternative Flows:
A1: User cancels — System logs user out
A2: Consent was withdrawn — System shows "Consent was withdrawn. Please re-consent to reactivate."
Postconditions: Account reactivated
US-53: Delete Account (Hard Delete)
As the system administrator, I want to hard-delete accounts after IRB retention period, so that storage is freed.
Acceptance Criteria:
Given account was soft-deleted >7 years ago, when scheduled job runs, then account is hard-deleted
UC-53: Hard Delete After Retention
Actor: System (scheduled job)
Preconditions: Account soft-deleted >7 years ago
Main Flow:
Scheduled job runs daily
System queries users with deleted_at < NOW() - INTERVAL '7 years'
System hard-deletes user and all related records
System logs hard-delete in audit log
Alternative Flows:
A1: IRB requires longer retention — System uses configured retention period
Postconditions: Account hard-deleted
EP-15: Graceful Degradation
US-54: Operate with Minimal Data
As the system, I want to operate with minimal data (only glucose + TG/HDL), so that users can still get basic recommendations.
Acceptance Criteria:
Given only glucose + TG/HDL are available, when engine runs, then Profile 1 or 2 is selected
Given other axes are missing, then they are marked no_data
UC-54: Minimal Data Mode
Actor: System (engine)
Preconditions: Only glucose + TG/HDL uploaded
Main Flow:
System evaluates Axis 1 (Glycemic) using glucose + TG/HDL
System evaluates Axis 2 (Lipid) using TG/HDL
System marks Axes 3, 4, 5 as no_data
System selects Profile 1 or 2 based on Axes 1-2
System shows UX feedback: "Based on limited data, we can estimate your carb sensitivity. For more accurate results, upload full labs."
Alternative Flows:
A1: User uploads more labs later — System re-evaluates with full data
Postconditions: Profile selected (1 or 2), graceful degradation active
US-55: Operate with Basic Data
As the system, I want to operate with basic data (all labs, no HRV), so that users can get Profiles 1-4.
Acceptance Criteria:
Given all labs are available but no HRV, when engine runs, then Profiles 1-4 are available
Given Axis 5 is missing, then Profile 5 cannot be activated
UC-55: Basic Data Mode
Actor: System (engine)
Preconditions: All labs uploaded, no HRV
Main Flow:
System evaluates Axes 1-4
System marks Axis 5 as no_data
System selects Profile 1-4 (Profile 5 not available)
System shows UX feedback: "Good data! We've analyzed 4 metabolic axes. Connect HRV for even more insights."
Alternative Flows:
A1: User connects HRV later — System re-evaluates with Axis 5
Postconditions: Profile selected (1-4), graceful degradation active
US-56: Operate with Extended Data
As the system, I want to operate with extended data (labs + HRV, no CGM), so that users can get all 5 profiles.
Acceptance Criteria:
Given labs + HRV are available, when engine runs, then all 5 profiles are available
Given CGM is missing, then dG/dt is not computed
UC-56: Extended Data Mode
Actor: System (engine)
Preconditions: Labs + HRV uploaded, no CGM
Main Flow:
System evaluates all 5 axes
System selects Profile 1-5
System shows UX feedback: "Excellent! We've analyzed all 5 axes including your nervous system."
dG/dt is not computed (no CGM)
Alternative Flows:
A1: User connects CGM later — System starts computing dG/dt
Postconditions: Profile selected (1-5), graceful degradation active
