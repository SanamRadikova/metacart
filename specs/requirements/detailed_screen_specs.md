MetaCart — Detailed Screen Specifications
PHASE 1: ONBOARDING (8 screens)
E1: Splash Screen
Screen ID: E1
User Stories: US-01 (partial)
Priority: 🔴 P0
Route: /splash
Purpose
App launch screen with branding and initial auth state check.
User Flow
User opens app
System checks auth state (JWT token validity)
If authenticated → redirect to Home (E25) or resume onboarding
If not authenticated → redirect to Sign Up/Sign In (E2)
States
State 1: Default (2 seconds)
┌─────────────────────────────┐
│                             │
│                             │
│         MetaCart            │
│    Metabolic-to-Grocery     │
│         Engine              │
│                             │
│                             │
│                             │
│      [ Get Started ]        │
│                             │
└─────────────────────────────┘
State 2: Loading (checking auth)
Logo + spinner at bottom
No user interaction
UI Elements
Logo (centered, 200x200px)
Tagline: "Metabolic-to-Grocery Engine" (16px, gray)
"Get Started" button (primary, bottom)
Interactions
Tap "Get Started" → Navigate to E2 (Sign Up/Sign In)
Auto-redirect (after 2s if authenticated) → Home or resume onboarding
API Calls
GET /api/v1/auth/me — check if user is authenticated
Error States
Network error → Show error toast, retry button
Auth token expired → Redirect to E2 (Sign In)
Accessibility
Logo has alt text: "MetaCart logo"
Button has focus state
Screen reader announces: "MetaCart. Metabolic-to-Grocery Engine. Get Started button."


E2: Sign Up / Sign In
Screen ID: E2
User Stories: US-01, US-03
Priority: 🔴 P0
Route: /auth
Purpose
Authentication screen with tabs for Sign Up and Sign In.
User Flow
Sign Up Flow:
User taps "Sign Up" tab
User enters email, password, DOB
System validates (email format, password strength, age 18-65)
System creates account
System sends verification email
User verifies email → redirect to E3 (Consent)
Sign In Flow:
User taps "Sign In" tab
User enters email, password
System validates credentials
System returns JWT
Redirect to Home or resume onboarding
States
State 1: Sign Up Tab (default)
┌─────────────────────────────┐
│  [Sign Up]  [Sign In]       │
├─────────────────────────────┤
│                             │
│  Email                      │
│  ┌───────────────────────┐ │
│  │ you@example.com       │ │
│  └───────────────────────┘ │
│                             │
│  Password                   │
│  ┌───────────────────────┐ │
│  │ ••••••••              │ │
│  └───────────────────────┘ │
│  ⚠️ Password must be 8+    │
│     characters              │
│                             │
│  Date of Birth              │
│  ┌───────────────────────┐ │
│  │ MM / DD / YYYY        │ │
│  └───────────────────────┘ │
│                             │
│  [ Create Account ]         │
│                             │
│  Already have account?      │
│  Sign In                    │
│                             │
└─────────────────────────────┘
State 2: Sign In Tab
┌─────────────────────────────┐
│  [Sign Up]  [Sign In]       │
├─────────────────────────────┤
│                             │
│  Email                      │
│  ┌───────────────────────┐ │
│  │ you@example.com       │ │
│  └───────────────────────┘ │
│                             │
│  Password                   │
│  ┌───────────────────────┐ │
│  │ ••••••••              │ │
│  └───────────────────────┘ │
│                             │
│  [ Sign In ]                │
│                             │
│  Forgot password?           │
│                             │
└─────────────────────────────┘

State 3: Validation Error
Red border on invalid field
Error message below field (e.g., "Age must be 18-65")
Submit button disabled
State 4: Loading
Button shows spinner
Button text: "Creating account..." / "Signing in..."
State 5: Success
Toast: "Account created! Check your email to verify."
Redirect to E3
UI Elements
Tab bar: "Sign Up" / "Sign In"
Email input (required, validated)
Password input (required, min 8 chars, strength indicator)
DOB input (date picker, age validation 18-65)
Primary button: "Create Account" / "Sign In"
Secondary link: "Forgot password?" / "Already have account? Sign In"
Interactions
Tap tab → Switch between Sign Up / Sign In
Focus input → Show keyboard, scroll if needed
Submit form → Validate, call API
Tap "Forgot password?" → Navigate to password reset flow
Tap "Sign In" link → Switch to Sign In tab
Validation Rules
Email: Valid format (regex), max 255 chars
Password: Min 8 chars, at least 1 uppercase, 1 lowercase, 1 number
DOB: Age must be 18-65 
All fields required
API Calls
Sign Up: POST /api/v1/auth/register
Request: { email, password, date_of_birth }
Response: { user_id, message: "Verification email sent" }
Sign In: POST /api/v1/auth/login
Request: { email, password }
Response: { access_token, refresh_token, user }
Error States
Invalid email → "Please enter a valid email address"
Weak password → "Password must be at least 8 characters with uppercase, lowercase, and number"
Age out of range → "MetaCart is for adults 18-65. Please contact support if you believe this is an error."
Email already exists → "Account already exists. Sign in or reset password."
Wrong credentials → "Invalid email or password"
Account locked (5 failed attempts) → "Account locked for 15 minutes. Reset password?"
Network error → "Check your connection and try again"
Accessibility
All inputs have labels
Error messages announced by screen reader
Password field has show/hide toggle
Date picker is accessible (keyboard navigation)


E3: Research Consent
Screen ID: E3
User Stories: US-02
Priority: 🔴 P0
Route: /onboarding/consent
Purpose
IRB-compliant informed consent for pilot participation.
User Flow
User sees full IRB consent text (scrollable)
User reads text (must scroll to bottom)
User checks "I agree to the research consent"
User taps "Continue"
System records consent with version hash, timestamp, IP, device info
Redirect to E4 (Lab Upload)
States
State 1: Default
┌─────────────────────────────┐
│  Research Consent           │
├─────────────────────────────┤
│                             │
│  ┌───────────────────────┐ │
│  │                       │ │
│  │  [Full IRB text]      │ │
│  │  (scrollable)         │ │
│  │                       │ │
│  │  ...                  │ │
│  │                       │ │
│  └───────────────────────┘ │
│                             │
│  ☐ I agree to the research │
│    consent                  │
│                             │
│  [ Continue ]  [ Skip ]     │
│                             │
└─────────────────────────────┘
State 2: Checkbox Checked
Checkbox filled
"Continue" button enabled (primary color)
State 3: Checkbox Unchecked
"Continue" button disabled (gray)
State 4: New Version Available
Banner at top: "Consent form updated. Please review."
User must re-consent
UI Elements
Title: "Research Consent"
Scrollable text area (full IRB text, min-height 400px)
Checkbox: "I agree to the research consent"
"Continue" button (primary, enabled only when checkbox checked)
"Skip" button (secondary, text only)
Version hash displayed at bottom (small, gray): "v1.0 | SHA-256: abc123..."
Interactions
Scroll text → Track scroll position, enable checkbox only after full scroll (optional UX enhancement)
Tap checkbox → Toggle checked state
Tap "Continue" → Record consent, navigate to E4
Tap "Skip" → Record skipped_consent = TRUE, navigate to E4 in "explore-only" mode
API Calls
POST /api/v1/consent
Request: { consent_version, consent_text_hash, agreed: boolean, ip_address, device_info }
Response: { consent_id, created_at }
Error States
Consent recording failed → Toast: "Failed to record consent. Please try again."
Network error → Retry button
Accessibility
Text area is scrollable with keyboard
Checkbox has label
Screen reader announces: "Research consent form. Scroll to read. I agree checkbox. Continue button."


E4: Lab Upload
Screen ID: E4
User Stories: US-04, US-05
Priority: 🔴 P0
Route: /onboarding/labs
Purpose
Upload lab results via PDF/photo (OCR) or manual entry.
User Flow
OCR Flow:
User taps "Upload PDF/Photo"
System opens file picker or camera
User selects document
System uploads to Supabase Storage
System sends to OCR service
OCR extracts values
Redirect to E4a (OCR Review)
Manual Flow:
User taps "Enter manually"
Redirect to E4b (Manual Entry)
States
State 1: Default
┌─────────────────────────────┐
│  Upload Lab Results         │
├─────────────────────────────┤
│                             │
│  ┌───────────────────────┐ │
│  │                       │ │
│  │   📄                  │ │
│  │   Upload PDF or Photo │ │
│  │                       │ │
│  └───────────────────────┘ │
│                             │
│  Or                         │
│                             │
│  [ Enter Manually ]         │
│                             │
└─────────────────────────────┘
State 2: File Selected
Preview of selected file (PDF thumbnail or image)
"Upload" button enabled
State 3: Uploading
Progress bar (0-100%)
"Uploading..." text
State 4: OCR Processing
Spinner
"Processing your labs..." text
Estimated time: "This may take 10-30 seconds"
State 5: OCR Success
Redirect to E4a
State 6: OCR Failed
Error message: "We couldn't read this clearly"
Options: "Try again" / "Enter manually"
UI Elements
Title: "Upload Lab Results"
Upload area (dashed border, tap to open file picker)
Icon: 📄 (document)
Text: "Upload PDF or Photo"
Divider: "Or"
"Enter Manually" button (secondary)
Interactions
Tap upload area → Open file picker (PDF, JPG, PNG) or camera
Select file → Show preview, enable "Upload" button
Tap "Upload" → Start upload + OCR
Tap "Enter Manually" → Navigate to E4b
File Validation
Accepted formats: PDF, JPG, PNG
Max file size: 10MB
Image resolution: Min 300 DPI for OCR
API Calls
POST /api/v1/labs/upload
Request: multipart/form-data with file
Response: { lab_result_id, ocr_status: "processing" }
GET /api/v1/labs/{id}/status
Response: { ocr_status, extracted_values }
Error States
File too large → "File must be under 10MB"
Unsupported format → "Supported formats: PDF, JPG, PNG"
Upload failed → "Upload failed. Check connection and try again."
OCR failed → "We couldn't read this clearly. Try another photo or enter manually."
Accessibility
Upload area has tap target min 48x48px
File picker is accessible
Screen reader announces: "Upload lab results. Tap to upload PDF or photo. Or enter manually."


E4a: OCR Review (Lab Values)
Screen ID: E4a
User Stories: US-04 (alternative)
Priority: 🔴 P0
Route: /onboarding/labs/review
Purpose
Review and correct OCR-extracted lab values before saving.
User Flow
System displays extracted values with units
User reviews each value
User corrects errors (tap to edit)
User confirms values
System saves to lab_values with both original and normalized values
Redirect to E5 (Cultural Profile)
States
State 1: Default
┌─────────────────────────────┐
│  Review Lab Values          │
├─────────────────────────────┤
│                             │
│  Glucose (fasting)          │
│  ┌──────────┐ ┌──────────┐ │
│  │ 88       │ │ mg/dL ▼  │ │
│  └──────────┘ └──────────┘ │
│  🟢 High confidence         │
│                             │
│  HbA1c                      │
│  ┌──────────┐ ┌──────────┐ │
│  │ 5.4      │ │ % ▼      │ │
│  └──────────┘ └──────────┘ │
│  🟡 Medium confidence       │
│                             │
│  Triglycerides              │
│  ┌──────────┐ ┌──────────┐ │
│  │          │ │ mg/dL ▼  │ │
│  └──────────┘ └──────────┘ │
│  🔴 Not detected            │
│                             │
│  [ Confirm ]                │
│  [ Enter Manually ]         │
│                             │
└─────────────────────────────┘
State 2: Editing Field
Field highlighted
Keyboard appears
User can change value or unit
State 3: Low Confidence Highlighted
Field has yellow/red border
Tooltip: "Please verify this value"
State 4: Missing Value
Field empty
Label: "Not detected — please enter"
UI Elements
Title: "Review Lab Values"
List of biomarkers (see below for full list)
Each biomarker:
Name (label)
Value input (numeric)
Unit dropdown (mg/dL, mmol/L, %, etc.)
Confidence indicator (🟢/🟡/🔴)
"Confirm" button (primary)
"Enter Manually" button (secondary, fallback)
Biomarker Fields
Glucose (fasting) — required
HbA1c — required
Triglycerides — required
HDL — required
LDL — optional
hs-CRP — optional
TSH — optional
ALT — optional
AST — optional
WBC — optional
Hemoglobin — optional
Interactions
Tap value field → Edit value
Tap unit dropdown → Select unit
Tap "Confirm" → Validate, save, navigate to E5
Tap "Enter Manually" → Navigate to E4b
Validation
Required fields: Glucose, HbA1c, TG, HDL (at minimum)
Value ranges: See context/REFERENCE_RANGES.md
Unit consistency: Must match biomarker (e.g., HbA1c can be % or mmol/mol, not mg/dL)
API Calls
POST /api/v1/labs/manual
Request: { timepoint: "baseline", values: [{ biomarker, value, unit }, ...] }
Response: { lab_result_id, processing_status: "completed" }
Error States
Missing required fields → "Please enter at least glucose, HbA1c, triglycerides, and HDL"
Value out of range → "This value seems incorrect. Expected range: X-Y"
Invalid unit → "Please select a valid unit for this biomarker"
Accessibility
All inputs have labels
Confidence indicators have alt text
Screen reader announces: "Glucose, 88, milligrams per deciliter, high confidence."


E4b: Manual Lab Entry
Screen ID: E4b
User Stories: US-05
Priority: 🔴 P0
Route: /onboarding/labs/manual
Purpose
Manual entry of lab values (fallback from OCR or user preference).
User Flow
User sees form with all biomarker fields
User enters values + selects units
System validates ranges
User taps "Next"
System saves to lab_values
Redirect to E5 (Cultural Profile)
States
State 1: Default
┌─────────────────────────────┐
│  Enter Lab Values           │
├─────────────────────────────┤
│                             │
│  * Required fields          │
│                             │
│  * Glucose (fasting)        │
│  ┌──────────┐ ┌──────────┐ │
│  │          │ │ mg/dL ▼  │ │
│  └──────────┘ └──────────┘ │
│                             │
│  * HbA1c                    │
│  ┌──────────┐ ┌──────────┐ │
│  │          │ │ % ▼      │ │
│  └──────────┘ └──────────┘ │
│                             │
│  * Triglycerides            │
│  ┌──────────┐ ┌──────────┐ │
│  │          │ │ mg/dL ▼  │ │
│  └──────────┘ └──────────┘ │
│                             │
│  * HDL                      │
│  ┌──────────┐ ┌──────────┐ │
│  │          │ │ mg/dL ▼  │ │
│  └──────────┘ └──────────┘ │
│                             │
│  ... (more fields)          │
│                             │
│  [ Next ]                   │
│                             │
└─────────────────────────────┘
State 2: Partial Data
Banner: "Some biomarkers missing — profile may be less accurate"
"Next" button still enabled (graceful degradation)
State 3: Validation Error
Red border on invalid field
Error message below field
UI Elements
Title: "Enter Lab Values"
Subtitle: "* Required fields"
Form fields (same as E4a)
"Next" button (primary)
Interactions
Enter value → Validate in real-time
Select unit → Update validation range
Tap "Next" → Validate, save, navigate to E5
Validation
Same as E4a
API Calls
Same as E4a
Error States
Same as E4a


E5: Cultural Profile
Screen ID: E5
User Stories: US-10, US-11
Priority: 🔴 P0
Route: /onboarding/cultural
Purpose
Select cultural food background, staple foods, dietary restrictions, household size.
User Flow
User selects primary cultural background
User selects staple foods (multi-select)
User selects dietary restrictions (multi-select)
User sets household size (slider)
User taps "Next"
System saves to cultural_profiles
Redirect to E6 (Device Connection)
States
State 1: Default
┌─────────────────────────────┐
│  Your Food Traditions       │
├─────────────────────────────┤
│                             │
│  Primary cultural           │
│  background                 │
│  ┌───────────────────────┐ │
│  │ Eastern European ▼    │ │
│  └───────────────────────┘ │
│                             │
│  Staple foods (select all)  │
│  ┌──────┐ ┌──────┐        │
│  │🍲    │ │🍚    │        │
│  │Borscht│ │Rice  │        │
│  └──────┘ └──────┘        │
│  ┌──────┐ ┌──────┐        │
│  │🫘    │ │🥬    │        │
│  │Beans │ │Fermen│        │
│  └──────┘ └──────┘        │
│                             │
│  Dietary restrictions       │
│  ┌──────┐ ┌──────┐        │
│  │Veget.│ │Halal │        │
│  └──────┘ └──────┘        │
│                             │
│  Household size             │
│  ────●────────── 2 people  │
│                             │
│  [ Next ]                   │
│                             │
└─────────────────────────────┘
State 2: "Other" Selected
Free text input appears: "Describe your food traditions"
State 3: Validation Error
Red border on required field
Error message: "Please select a cultural background"
UI Elements
Title: "Your Food Traditions"
Dropdown: Primary cultural background. 6 supported groups, stored in DB as snake_case:
  - Eastern European (eastern_european)
  - South Asian (south_asian)
  - Latino (latino)
  - African-American (african_american)
  - East Asian / Chinese (east_asian)
  - Standard American (standard_american)
UI displays Title Case; backend stores snake_case.
Multi-select tags: Staple foods (Borscht/Soups, Rice & Dal, Beans & Corn, Fermented, Flatbreads, Bone broth)
Multi-select tags: Dietary restrictions (Vegetarian, Halal, Kosher, Gluten-free, Dairy-free)
Slider: Household size (1-6)
"Next" button (primary)
Interactions
Select cultural background → Update dropdown
Tap staple food tag → Toggle selection
Tap dietary restriction tag → Toggle selection
Drag slider → Update household size
Tap "Next" → Validate, save, navigate to E6
API Calls
POST /api/v1/cultural-profile
Request: { primary_culture, staple_foods: [], dietary_restrictions: [], household_size }
Response: { cultural_profile_id }
Error States
Cultural background not selected → "Please select a cultural background"
Household size invalid → "Household size must be 1-6"
Accessibility
Dropdown is accessible (keyboard navigation)
Tags have tap targets min 48x48px
Slider is accessible
Screen reader announces: "Primary cultural background, Eastern European selected."


E6: Device Connection
Screen ID: E6
User Stories: US-12, US-13
Priority: 🟡 P1
Route: /onboarding/devices
Purpose
Connect Apple Health (iOS) or Google Fit (Android) for HRV and CGM data.
User Flow
User sees device connection options
User taps "Connect Apple Health" or "Connect Google Fit"
System opens OS permission dialog
User grants permissions
System saves to device_connections
User taps "Continue" or "Skip"
Redirect to E7 (Hormonal Status) or E8 (Axes Dashboard)
States
State 1: Default (iOS)
┌─────────────────────────────┐
│  Connect Your Health Data   │
├─────────────────────────────┤
│                             │
│  💡 By connecting Apple     │
│  Health, MetaCart can read  │
│  your HRV and glucose data. │
│                             │
│  [ Connect Apple Health ]   │
│                             │
│  This is optional but       │
│  recommended for Profile 5  │
│  detection.                 │
│                             │
│  [ Skip ]  [ Continue ]     │
│                             │
└─────────────────────────────┘
State 2: Permission Requested
OS permission dialog appears
User grants/denies
State 3: Connected
Success message: "Apple Health connected!"
"Continue" button enabled
State 4: Denied
Explanation: "Apple Health access is optional but recommended"
"Skip" button highlighted
State 5: Not Available
Message: "Apple Health not found on this device"
"Skip" button only
UI Elements
Title: "Connect Your Health Data"
Explanation text
"Connect Apple Health" button (iOS only)
"Connect Google Fit" button (Android only)
"Skip" button (secondary)
"Continue" button (primary, enabled after connection or skip)
Interactions
Tap "Connect Apple Health" → Open iOS permission dialog
Tap "Connect Google Fit" → Open Health Connect permission dialog
Grant permissions → Save to device_connections, show success
Deny permissions → Show explanation, enable "Skip"
Tap "Skip" → Navigate to E7 or E8
Tap "Continue" → Navigate to E7 or E8
API Calls
POST /api/v1/devices/connect
Request: { device_type: "apple_health" | "google_fit", permissions: [] }
Response: { device_connection_id }
Error States
Permission denied → "Apple Health access is optional but recommended for Profile 5 detection"
Apple Health not found → "Apple Health not found on this device. You can skip this step."
Connection failed → "Failed to connect. Please try again."
Accessibility
Buttons have tap targets min 48x48px
Screen reader announces: "Connect Apple Health button. This is optional but recommended."


E7: Hormonal Status (Female Only)
Screen ID: E7
User Stories: US-15, US-16
Priority: 🟡 P1
Route: /onboarding/hormonal
Purpose
Select hormonal status for female users (threshold modifiers).
User Flow
User sees dropdown with hormonal status options
User selects status
User taps "Next"
System saves to hormonal_statuses
Redirect to E8 (Axes Dashboard)
States
State 1: Default
┌─────────────────────────────┐
│  Hormonal Status            │
├─────────────────────────────┤
│                             │
│  This helps us personalize  │
│  your recommendations.      │
│                             │
│  Current status             │
│  ┌───────────────────────┐ │
│  │ Follicular phase ▼    │ │
│  └───────────────────────┘ │
│                             │
│  [ Next ]  [ Skip ]         │
│                             │
└─────────────────────────────┘
State 2: Option Selected
Dropdown shows selected option
"Next" button enabled
UI Elements
Title: "Hormonal Status"
Explanation: "This helps us personalize your recommendations."
Dropdown: Follicular phase, PMS/Luteal phase, Perimenopause, Postmenopause
"Next" button (primary)
"Skip" button (secondary, uses default: follicular phase)
Interactions
Select status → Update dropdown
Tap "Next" → Save, navigate to E8
Tap "Skip" → Save default, navigate to E8
API Calls
POST /api/v1/hormonal-status
Request: { status: "follicular_phase" | "luteal_phase_pms" | "perimenopause" | "postmenopause" }
Response: { hormonal_status_id }
Error States
Status not selected → "Please select a hormonal status"
Accessibility
Dropdown is accessible
Screen reader announces: "Hormonal status, Follicular phase selected."

📊 PHASE 1 SUMMARY
| Screen | Priority | User Stories | API Calls |
| ------- | ------- | ------- | ------- |
| E1: Splash | 🔴 P0 | US-01 | GET /auth/me |
| E2: Sign Up/Sign In | 🔴 P0 | US-01, US-03 | POST /auth/register, POST /auth/login |
| E3: Research Consent | 🔴 P0 | US-02 | POST /consent |
| E4: Lab Upload | 🔴 P0 | US-04, US-05 | POST /labs/upload |
| E4a: OCR Review | 🔴 P0 | US-04 | POST /labs/manual |
| E4b: Manual Entry | 🔴 P0 | US-05 | POST /labs/manual |
| E5: Cultural Profile | 🔴 P0 | US-10, US-11 | POST /cultural-profile |
| E6: Device Connection | 🟡 P1 | US-12, US-13 | POST /devices/connect |
| E7: Hormonal Status | 🟡 P1 | US-15, US-16 | POST /hormonal-status |


🎯 PHASE 2: ANALYSIS (5 screens)
E8: Axes Dashboard
Screen ID: E8
User Stories: US-17, US-19
Priority: 🔴 P0
Route: /analysis/axes
Purpose
Display the 5 metabolic axes with their statuses (🟢/🟡/🟠/no_data) based on the user's uploaded biomarkers. This is the first screen where the user sees the engine's analysis of their metabolic health.
Key Architectural Decisions Covered
 (Graceful Degradation): Axes can be no_data if biomarkers are missing
(Degradation Branches): 4 levels — minimal/basic/extended/full
 (Cultural Thresholds): Thresholds vary by cultural group
(Functional Thresholds): Stricter than diagnostic criteria
User Flow
User completes onboarding (E1-E7)
System evaluates 5 axes based on uploaded labs + devices (UC-17)
User lands on Axes Dashboard
User sees 5 axis cards with statuses
User taps an axis → opens E9 (Axis Detail modal)
User taps "See Your Profile" → navigates to E10 (Profile Result)
States
State 1: Loading
┌─────────────────────────────┐
│  Your Metabolic Axes        │
│  Based on labs from Jun 20  │
├─────────────────────────────┤
│                             │
│  ┌───────────────────────┐ │
│  │ ░░░░░░░░░░░░░░░░░░░░░ │ │
│  └───────────────────────┘ │
│  ┌───────────────────────┐ │
│  │ ░░░░░░░░░░░░░░░░░░░░░ │ │
│  └───────────────────────┘ │
│  ┌───────────────────────┐ │
│  │ ░░░░░░░░░░░░░░░░░░░░░ │ │
│  └───────────────────────┘ │
│  ┌───────────────────────┐ │
│  │ ░░░░░░░░░░░░░░░░░░░░░ │ │
│  └───────────────────────┘ │
│  ┌───────────────────────┐ │
│  │ ░░░░░░░░░░░░░░░░░░░░░ │ │
│  └───────────────────────┘ │
│                             │
└─────────────────────────────┘

State 2: Default (Full data — Extended mode)
┌─────────────────────────────┐
│  Your Metabolic Axes        │
│  Based on labs from Jun 20  │
│  📊 5/5 axes analyzed       │
├─────────────────────────────┤
│                             │
│  ┌───────────────────────┐ │
│  │ 🟢  Glycemic           │ │
│  │     Glucose 88 · HbA1c │ │
│  │     5.1% · TG/HDL 1.3  │ │
│  │                  Stable│ │
│  └───────────────────────┘ │
│                             │
│  ┌───────────────────────┐ │
│  │ 🟢  Lipid              │ │
│  │     TG 95 · HDL 65     │ │
│  │                  Stable│ │
│  └───────────────────────┘ │
│                             │
│  ┌───────────────────────┐ │
│  │ 🟠  Inflammatory       │ │
│  │     hs-CRP 1.4 mg/L    │ │
│  │               Elevated │ │
│  └───────────────────────┘ │
│                             │
│  ┌───────────────────────┐ │
│  │ 🟢  Stress / Thyroid   │ │
│  │     TSH 1.8 mIU/L      │ │
│  │                  Stable│ │
│  └───────────────────────┘ │
│                             │
│  ┌───────────────────────┐ │
│  │ 🟠  Neuro-Autonomic    │ │
│  │     RMSSD 24ms · SDNN  │ │
│  │     140ms · PNN50 13%  │ │
│  │                 ⚠ Alert│ │
│  └───────────────────────┘ │
│                             │
│  [ See Your Profile ]       │
│                             │
└─────────────────────────────┘
State 3: Basic mode (no HRV — Axis 5 = no_data)
┌─────────────────────────────┐
│  Your Metabolic Axes        │
│  Based on labs from Jun 20  │
│  📊 4/5 axes analyzed       │
├─────────────────────────────┤
│                             │
│  ┌───────────────────────┐ │
│  │ 🟢  Glycemic           │ │
│  │     ...                │ │
│  └───────────────────────┘ │
│  ┌───────────────────────┐ │
│  │ 🟢  Lipid              │ │
│  │     ...                │ │
│  └───────────────────────┘ │
│  ┌───────────────────────┐ │
│  │ 🟠  Inflammatory       │ │
│  │     ...                │ │
│  └───────────────────────┘ │
│  ┌───────────────────────┐ │
│  │ 🟢  Stress / Thyroid   │ │
│  │     ...                │ │
│  └───────────────────────┘ │
│  ┌───────────────────────┐ │
│  │ ⚪  Neuro-Autonomic    │ │
│  │     No data            │ │
│  │     Connect HRV device │ │
│  │     for complete analy.│ │
│  └───────────────────────┘ │
│                             │
│  💡 Connect HRV device for  │
│  Profile 5 detection        │
│                             │
│  [ See Your Profile ]       │
│                             │
└─────────────────────────────┘
State 4: Minimal mode (only glucose + TG/HDL)
┌─────────────────────────────┐
│  Your Metabolic Axes        │
│  Based on labs from Jun 20  │
│  📊 2/5 axes analyzed       │
├─────────────────────────────┤
│                             │
│  ⚠️ Limited data            │
│  Upload full labs for       │
│  more accurate profile      │
│                             │
│  ┌───────────────────────┐ │
│  │ 🟡  Glycemic           │ │
│  │     Glucose 95 · TG/   │ │
│  │     HDL 2.1            │ │
│  │              Attention │ │
│  └───────────────────────┘ │
│  ┌───────────────────────┐ │
│  │ 🟡  Lipid              │ │
│  │     TG 120 · HDL 48    │ │
│  │              Attention │ │
│  └───────────────────────┘ │
│  ┌───────────────────────┐ │
│  │ ⚪  Inflammatory       │ │
│  │     Upload hs-CRP      │ │
│  └───────────────────────┘ │
│  ┌───────────────────────┐ │
│  │ ⚪  Stress / Thyroid   │ │
│  │     Upload TSH         │ │
│  └───────────────────────┘ │
│  ┌───────────────────────┐ │
│  │ ⚪  Neuro-Autonomic    │ │
│  │     Connect HRV device │ │
│  └───────────────────────┘ │
│                             │
│  [ Upload More Labs ]       │
│  [ See Your Profile ]       │
│                             │
└─────────────────────────────┘
State 5: Profile 5 triggered (Axis 5 = 🟠)
Axis 5 card has red border + ⚠️ icon
Banner at top: "Your nervous system shows signs of dysregulation. See your profile for details."
UI Elements
Header:
Title: "Your Metabolic Axes"
Subtitle: "Based on labs from [date]"
Data completeness indicator: "X/5 axes analyzed" (📊 icon)
Axis Cards (5 total):
Each card contains:
Status icon (🟢/🟡/🟠/⚪)
Axis name (e.g., "Glycemic")
Key biomarker values (2-3 values per axis)
Status text ("Stable" / "Attention" / "Elevated" / "Alert" / "No data")
Tap target: entire card opens E9
Axis-specific content:
| Axis | Values Shown | Status Text |
| ------- | ------- | ------- |
| 1 — Glycemic | Glucose, HbA1c, TG/HDL | Stable / Attention / Deviation |
| 2 — Lipid | TG, HDL | Stable / Attention / Deviation |
| 3 — Inflammatory | hs-CRP | Stable / Attention / Elevated |
| 4 — Stress/Thyroid | TSH | Stable / Attention / Deviation |
| 5 — Neuro-Autonomic | RMSSD, SDNN, PNN50 | Stable / Attention / ⚠️ Alert |
Banner (conditional):
Minimal mode: "⚠️ Limited data — upload full labs for better accuracy"
Basic mode: "💡 Connect HRV device for Profile 5 detection"
Profile 5 triggered: "⚠️ Your nervous system shows signs of dysregulation"
Buttons:
"See Your Profile" (primary, always enabled)
"Upload More Labs" (secondary, shown only in minimal/basic mode)
Interactions
| Action | Result |
| ------- | ------- |
| Tap axis card | Open E9 (Axis Detail modal) for that axis |
| Tap "See Your Profile" | Navigate to E10 (Profile Result) |
| Tap "Upload More Labs" | Navigate to E4 (Lab Upload) with timepoint = 'additional' |
| Long-press axis card | Show tooltip with axis explanation |
| Pull-to-refresh | Re-evaluate axes (if new data available) |
API Calls
Primary:
GET /api/v1/axes
Response:
{
  "evaluation_id": "uuid",
  "evaluation_date": "2026-06-20T10:00:00Z",
  "data_completeness": "extended",
  "axes_analyzed": 5,
  "axes_total": 5,
  "axes": {
    "1": {
      "status": "green",
      "biomarkers": {
        "glucose": {"value": 88, "unit": "mg/dL", "status": "green"},
        "hba1c": {"value": 5.1, "unit": "%", "status": "green"},
        "tg_hdl_ratio": {"value": 1.3, "status": "green"}
      }
    },
    "2": {"status": "green", "biomarkers": {...}},
    "3": {"status": "orange", "biomarkers": {...}},
    "4": {"status": "green", "biomarkers": {...}},
    "5": {"status": "orange", "biomarkers": {...}}
  },
  "cultural_group": "eastern_european",
  "thresholds_used": "culture_specific"
}
Error handling:
404 — No labs uploaded → redirect to E4
500 — Engine evaluation failed → show error state, retry button
Error States
| Error | Message | Action |
| ------- | ------- | ------- |
| No labs uploaded | "Upload your labs to see your axes" | Redirect to E4 |
| Labs processing | "Processing your labs..." | Show spinner, auto-refresh |
| Labs need review | "Please review extracted values first" | Redirect to E4a |
| Engine error | "Failed to evaluate axes. Please try again." | Retry button |
| Network error | "Check your connection and try again" | Retry button |
Accessibility
Each axis card is a single tap target (min 48px height)
Status icons have alt text: "Green circle: Stable", "Orange circle: Elevated", "Gray circle: No data"
Screen reader announces: "Glycemic axis, Stable. Glucose 88 milligrams per deciliter, HbA1c 5.1 percent."
Data completeness indicator announced: "5 of 5 axes analyzed"
Color is not the only indicator — status text is always present


E9: Axis Detail (Modal/Bottom Sheet)
Screen ID: E9
User Stories: US-19 (alternative)
Priority: 🟡 P1
Route: /analysis/axes/{axis_number} (modal)
Purpose
Show detailed explanation of a single axis: all biomarker values, thresholds, status rationale, and clinical context.
User Flow
User taps an axis card on E8
Modal slides up from bottom (or full-screen on small devices)
User sees detailed breakdown of that axis
User taps "Close" or swipes down to dismiss
States
State 1: Default (Axis with data)
┌─────────────────────────────┐
│  Axis 1: Glycemic       [×] │
├─────────────────────────────┤
│                             │
│  Status: 🟢 Stable          │
│                             │
│  What this axis measures:   │
│  Your body's ability to     │
│  process carbohydrates.     │
│                             │
│  Your values:               │
│  ┌───────────────────────┐ │
│  │ Glucose (fasting)     │ │
│  │ 88 mg/dL              │ │
│  │ 🟢 70-90 = Stable     │ │
│  └───────────────────────┘ │
│  ┌───────────────────────┐ │
│  │ HbA1c                 │ │
│  │ 5.1%                  │ │
│  │ 🟢 <5.3 = Stable      │ │
│  └───────────────────────┘ │
│  ┌───────────────────────┐ │
│  │ TG/HDL ratio          │ │
│  │ 1.3                   │ │
│  │ 🟢 <1.5 = Stable      │ │
│  └───────────────────────┘ │
│                             │
│  Clinical meaning:          │
│  Good carbohydrate          │
│  tolerance. Insulin works   │
│  efficiently.               │
│                             │
│  [ Close ]                  │
│                             │
└─────────────────────────────┘
State 2: Axis with no_data
┌─────────────────────────────┐
│  Axis 5: Neuro-Autonomic[×] │
├─────────────────────────────┤
│                             │
│  Status: ⚪ No data          │
│                             │
│  What this axis measures:   │
│  Balance between your       │
│  sympathetic and            │
│  parasympathetic nervous    │
│  systems.                   │
│                             │
│  To analyze this axis, we   │
│  need HRV data from a       │
│  wearable device.           │
│                             │
│  [ Connect HRV Device ]     │
│  [ Close ]                  │
│                             │
└─────────────────────────────┘
State 3: Axis with SDNN paradox (special case)
┌─────────────────────────────┐
│  Axis 5: Neuro-Autonomic[×] │
├─────────────────────────────┤
│                             │
│  Status: 🟠 Alert           │
│                             │
│  Your values:               │
│  ┌───────────────────────┐ │
│  │ RMSSD: 24ms           │ │
│  │ 🟠 <25ms = Alert      │ │
│  └───────────────────────┘ │
│  ┌───────────────────────┐ │
│  │ SDNN: 216ms           │ │
│  │ ⚠️ High + low RMSSD   │ │
│  │    = dysregulatory    │ │
│  └───────────────────────┘ │
│  ┌───────────────────────┐ │
│  │ PNN50: 13%            │ │
│  │ 🟡 10-20% = Attention │ │
│  └───────────────────────┘ │
│                             │
│  ⚠️ SDNN Paradox Detected   │
│  High SDNN with low RMSSD   │
│  indicates dysregulatory    │
│  variability, not health.   │
│                             │
│  [ Close ]                  │
│                             │
└─────────────────────────────┘

UI Elements
Header:
Axis name (e.g., "Axis 1: Glycemic")
Close button (×)
Status Section:
Status icon + text (e.g., "🟢 Stable")
Plain language explanation of what the axis measures
Biomarker Values Section:
List of biomarkers with:
Name
Value + unit
Threshold range (e.g., "🟢 70-90 = Stable")
Status indicator for each biomarker
Clinical Meaning Section:
2-3 sentences explaining what the status means in plain language
For Profile 4 (TSH >2.5): "Your TSH is within the diagnostic normal range (0.4-4.0), but MetaCart uses a functional range (0.8-2.0) to optimize metabolic health. At TSH >2.5, your metabolism may be slowed, and aggressive dietary restrictions could worsen this."
For Profile 5 (RMSSD <25): "Your nervous system shows signs of dysregulation. You may experience symptoms (dizziness, brain fog, fatigue) even with normal glucose levels."
Call-to-Action (conditional):
"Connect HRV Device" button (if axis = no_data for Axis 5)
"Upload [biomarker]" button (if specific biomarker missing)
Interactions
| Action | Result |
| ------- | ------- |
| Tap "Close" or swipe down | Dismiss modal |
| Tap "Connect HRV Device" | Navigate to E6 (Device Connection) |
| Tap "Upload [biomarker]" | Navigate to E4 (Lab Upload) |
| Tap biomarker value | Show tooltip with unit conversion info |
API Calls
GET /api/v1/axes/{axis_number}
Response:
{
  "axis_number": 1,
  "axis_name": "Glycemic",
  "status": "green",
  "description": "Your body's ability to process carbohydrates",
  "biomarkers": [
    {
      "name": "Glucose (fasting)",
      "value": 88,
      "unit": "mg/dL",
      "value_original": 88,
      "unit_original": "mg/dL",
      "status": "green",
      "threshold": {"green_min": 70, "green_max": 90}
    },
    ...
  ],
  "clinical_meaning": "Good carbohydrate tolerance...",
  "cultural_thresholds_used": true,
  "cultural_group": "eastern_european"
}
Error States:
| Error | Message | Action |
| ------- | ------- | ------- |
| Axis not found | "Axis data not available" | Close modal |
| Network error | "Failed to load details" | Retry button |
Accessibility
Modal is focus-trapped
Close button is keyboard-accessible (Escape key)
All biomarker values announced by screen reader
SDNN paradox explanation announced clearly


E10: Profile Result
Screen ID: E10
User Stories: US-20, US-21
Priority: 🔴 P0
Route: /analysis/profile
Purpose
Display the user's selected metabolic profile with plain-language explanation, key principles, and modifiers. This is where the user understands "what type of metabolism they have."
Key Architectural Decisions Covered
(Functional Thresholds): UX explanations for Profile 4 (TSH)
(Profile Recalculation): Shows current active profile
(Cultural Thresholds): Profile selection based on cultural group
User Flow
User taps "See Your Profile" on E8 (Axes Dashboard)
System retrieves active profile (UC-18)
User sees profile screen with explanation
User reads key principles and modifiers
User taps "See 7-Day Menu" → navigates to E13 (Menu)
States
State 1: Default — Profile 1 (Metabolic Flexibility)
┌─────────────────────────────┐
│  Your Profile               │
├─────────────────────────────┤
│                             │
│  ┌───────────────────────┐ │
│  │                       │ │
│  │   Profile 1           │ │
│  │   Metabolic           │ │
│  │   Flexibility         │ │
│  │                       │ │
│  │   🟢 All axes stable  │ │
│  │                       │ │
│  └───────────────────────┘ │
│                             │
│  Your metabolism is         │
│  flexible and efficient.    │
│  Your body handles carbs    │
│  and fats well, with no     │
│  inflammation or stress     │
│  signals.                   │
│                             │
│  Key principles:            │
│  ✓ Diverse, seasonal foods  │
│  ✓ Quality over restriction │
│  ✓ Listen to hunger cues    │
│                             │
│  Modifiers:                 │
│  None needed                │
│                             │
│  [ See 7-Day Menu ]         │
│  [ View Axes ]              │
│                             │
└─────────────────────────────┘
State 2: Profile 5 (Neuro-Autonomic) — SPECIAL UX
┌─────────────────────────────┐
│  Your Profile               │
├─────────────────────────────┤
│                             │
│  ┌───────────────────────┐ │
│  │   Profile 5           │ │
│  │   Neuro-Autonomic     │ │
│  │                       │ │
│  │   🟠 Axis 5 alert     │ │
│  └───────────────────────┘ │
│                             │
│  ⚠️ Important               │
│  Your labs look normal,     │
│  but your nervous system    │
│  shows signs of             │
│  dysregulation.             │
│                             │
│  Symptoms (dizziness,       │
│  brain fog, fatigue) may    │
│  come from how fast your    │
│  glucose drops, not the     │
│  level itself.              │
│                             │
│  Key principles:            │
│  ✓ Protein + fat + fiber    │
│    at every meal            │
│  ✓ Eat every 3-4 hours      │
│  ✓ High-protein breakfast   │
│  ✓ 1 min movement after     │
│    dinner (-42% spike)      │
│  ✗ Avoid: Z-Bars, fruit     │
│    yogurts, juices          │
│                             │
│  Modifiers:                 │
│  • Omega-3 2g/day           │
│  • Berries daily            │
│  • No alcohol               │
│                             │
│  [ See 7-Day Menu ]         │
│  [ View Axes ]              │
│                             │
└─────────────────────────────┘

State 3: Profile 4 (Stress-Adaptive) — SPECIAL UX
┌─────────────────────────────┐
│  Your Profile               │
├─────────────────────────────┤
│                             │
│  ┌───────────────────────┐ │
│  │   Profile 4           │ │
│  │   Stress-Adaptive     │ │
│  │                       │ │
│  │   🟠 Axis 4 alert     │ │
│  └───────────────────────┘ │
│                             │
│  ℹ️ About your TSH          │
│  Your TSH (2.8 mIU/L) is    │
│  within the diagnostic      │
│  normal range (0.4-4.0),    │
│  but MetaCart uses a        │
│  functional range (0.8-2.0) │
│  to optimize metabolic      │
│  health.                    │
│                             │
│  At TSH >2.5, your          │
│  metabolism may be slowed.  │
│  Aggressive diets could     │
│  worsen this.               │
│                             │
│  Key principles:            │
│  ✓ Regular meals            │
│  ✓ No aggressive restrict.  │
│  ✓ Moderate iodine          │
│  ✓ Whole foods              │
│                             │
│  Modifiers:                 │
│  • Fatty fish 3×/week       │
│  • Berries                  │
│  • Magnesium                │
│                             │
│  [ See 7-Day Menu ]         │
│  [ View Axes ]              │
│                             │
└─────────────────────────────┘

State 4: Profile with hormonal modifier
┌─────────────────────────────┐
│  Your Profile               │
├─────────────────────────────┤
│                             │
│  ┌───────────────────────┐ │
│  │   Profile 5           │ │
│  │   Neuro-Autonomic     │ │
│  │                       │ │
│  │   🟠 + Hormonal mod.  │ │
│  └───────────────────────┘ │
│                             │
│  ⚠️ Hormonal modifier active│
│  You're in perimenopause.   │
│  Fluctuating estrogen can   │
│  cause unpredictable HRV    │
│  and glycemic responses.    │
│                             │
│  We've adjusted your        │
│  profile to prioritize      │
│  protein and include        │
│  magnesium + omega-3.       │
│                             │
│  [rest of Profile 5 content]│
│                             │
└─────────────────────────────┘

UI Elements
Header:
Title: "Your Profile"
Profile Card (hero section):
Profile number (1-5)
Profile name
Status icon (🟢/🟠)
Selection step (e.g., "Step 0: Axis 5 = 🟠")
Explanation Section:
Plain language explanation (2-4 sentences)
Special callouts for Profile 4 (TSH) and Profile 5 (neuro-autonomic)
Hormonal modifier callout if applicable
Key Principles Section:
Bullet list (4-6 items)
✓ for "do" items
✗ for "avoid" items (Profile 5)
Modifiers Section:
List of active modifiers (from secondary axes)
Each modifier shows: axis name, status, action
If no modifiers: "None needed"
Nutraceuticals Section (Profile 5 only):
List of recommended supplements
Disclaimer banner: "⚕️ Consult your doctor before taking supplements"
Buttons:
"See 7-Day Menu" (primary)
"View Axes" (secondary)
Interactions
| Action | Result |
| ------- | ------- |
| Tap "See 7-Day Menu" | Navigate to E13 (Menu) |
| Tap "View Axes" | Navigate back to E8 (Axes Dashboard) |
| Tap profile card | Show "How was this profile selected?" explanation |
| Tap modifier | Show detailed explanation of that modifier |
| Tap nutraceutical | Show dosage + disclaimer |

API Calls
GET /api/v1/profiles/active
Response:
{
  "profile_id": "uuid",
  "profile_number": 5,
  "profile_name": "Neuro-Autonomic",
  "selection_step": 0,
  "selection_reason": "Axis 5 = orange (RMSSD < 25ms)",
  "explanation": "Your labs look normal, but your nervous system shows signs of dysregulation...",
  "key_principles": [
    "Protein + fat + fiber at every meal",
    "Eat every 3-4 hours",
    "High-protein breakfast",
    "1 min movement after dinner"
  ],
  "avoid_items": ["Z-Bars", "fruit yogurts", "juices"],
  "modifiers": [
    {
      "axis": 3,
      "status": "orange",
      "action": "omega_3_2g_daily",
      "description": "Add omega-3 2g/day, berries, exclude alcohol"
    }
  ],
  "hormonal_modifier": {
    "status": "perimenopause",
    "threshold_modifier": 0.8,
    "additional_recommendations": ["magnesium", "omega_3"]
  },
  "nutraceuticals": [
    {"name": "CoQ10", "dose": "200mg", "requires_disclaimer": true},
    {"name": "Omega-3", "dose": "1-2g EPA/DHA", "requires_disclaimer": true}
  ],
  "created_at": "2026-06-20T10:00:00Z"
}

Error States:
| Error | Message | Action |
| ------- | ------- | ------- |
| No profile selected | "Profile not yet calculated. Please upload labs first." | Redirect to E4 |
| Profile calculation failed | "Failed to calculate profile. Please try again." | Retry button |
| Network error | "Check your connection and try again" | Retry button |

Accessibility
Profile card announced as heading
Key principles announced as list
Disclaimer for nutraceuticals announced clearly
Screen reader announces: "Profile 5, Neuro-Autonomic. Your labs look normal, but your nervous system shows signs of dysregulation."



E11: Profile Modifiers (Section within E10)
Screen ID: E11
User Stories: US-21
Priority: 🟡 P1
Route: Part of E10 (not a separate screen)
Purpose
Display secondary axis modifiers that add specific products or nutraceuticals to the cart without changing the primary profile.
Note
This is not a separate screen — it's a section within E10 (Profile Result). However, it has its own detailed spec because it's critical for understanding how the engine handles multiple active axes.
UI Elements
Modifiers Section (within E10):
Section header: "Modifiers"
List of active modifiers (0-N items)
Each modifier card:
Axis name + status icon
Action description
"Why?" tooltip (tap for explanation)
Modifier Card Example:

┌─────────────────────────────┐
│  🟠 Axis 3: Inflammatory    │
│  Add: fatty fish 2×/week,   │
│  flaxseed oil, turmeric     │
│                             │
│  [ Why? ]                   │
└─────────────────────────────┘

Modifier Logic
| Error | Message | Action |
| ------- | ------- | ------- |
| No profile selected | "Profile not yet calculated. Please upload labs first." | Redirect to E4 |
| Profile calculation failed | "Failed to calculate profile. Please try again." | Retry button |
| Network error | "Check your connection and try again" | Retry button |

Interactions
| Action | Result |
| ------- | ------- |
| Tap "Why?" | Show bottom sheet explaining the modifier |
| Tap modifier card | Show detailed explanation + affected cart items |
API Calls
Modifiers are included in the GET /api/v1/profiles/active response (see E10).


E12: Profile History
Screen ID: E12
User Stories: US-48
Priority: 🟡 P1
Route: /analysis/profile/history
Purpose
Show timeline of profile changes over time (baseline → follow-up). This is important for the longitudinal study design  and for users to see their progress.
User Flow
User navigates to Settings → Profile History
OR user taps "View history" on E10 (if multiple profiles exist)
System displays timeline of profile changes
User taps a profile → sees details for that timepoint
States
State 1: Default (multiple profiles)
┌─────────────────────────────┐
│  Profile History            │
├─────────────────────────────┤
│                             │
│  ┌───────────────────────┐ │
│  │ 📅 Jun 20, 2026       │ │
│  │ Follow-up             │ │
│  │                       │ │
│  │ Profile 2             │ │
│  │ Carb Sensitivity      │ │
│  │                       │ │
│  │ Changed from:         │ │
│  │ Profile 5 → Profile 2 │ │
│  │ 🎉 Great progress!    │ │
│  │                       │ │
│  │ [ View Details ]      │ │
│  └───────────────────────┘ │
│                             │
│  ┌───────────────────────┐ │
│  │ 📅 May 15, 2026       │ │
│  │ Baseline              │ │
│  │                       │ │
│  │ Profile 5             │ │
│  │ Neuro-Autonomic       │ │
│  │                       │ │
│  │ [ View Details ]      │ │
│  └───────────────────────┘ │
│                             │
└─────────────────────────────┘

State 2: Single profile (baseline only)
┌─────────────────────────────┐
│  Profile History            │
├─────────────────────────────┤
│                             │
│  ┌───────────────────────┐ │
│  │ 📅 May 15, 2026       │ │
│  │ Baseline              │ │
│  │                       │ │
│  │ Profile 5             │ │
│  │ Neuro-Autonomic       │ │
│  │                       │ │
│  │ [ View Details ]      │ │
│  └───────────────────────┘ │
│                             │
│  💡 Upload follow-up labs   │
│  in 30 days to see how      │
│  your profile changes       │
│                             │
└─────────────────────────────┘
State 3: Empty (no profiles yet)
┌─────────────────────────────┐
│  Profile History            │
├─────────────────────────────┤
│                             │
│  📭 No profile history yet  │
│                             │
│  Upload your labs to get    │
│  your first profile.        │
│                             │
│  [ Upload Labs ]            │
│                             │
└─────────────────────────────┘
UI Elements
Header:
Title: "Profile History"
Timeline (vertical):
Each entry:
Date
Timepoint label (Baseline / Follow-up / Additional)
Profile number + name
Change indicator (if changed from previous): "Changed from Profile X → Profile Y"
Celebration message (if improved): "🎉 Great progress!"
Concern message (if worsened): "⚠️ Consider consulting your doctor"
"View Details" button
Call-to-Action (if single profile):
"💡 Upload follow-up labs in 30 days to see how your profile changes"
Interactions
| Action | Result |
| ------- | ------- |
| Tap "View Details" | Show modal with full profile details for that timepoint |
| Tap "Upload Labs" | Navigate to E4 (Lab Upload) with timepoint = 'follow_up' |
| Pull-to-refresh | Reload profile history |
API Calls
GET /api/v1/profiles/history
Response:
{
  "profiles": [
    {
      "profile_id": "uuid",
      "created_at": "2026-06-20T10:00:00Z",
      "timepoint": "follow_up",
      "profile_number": 2,
      "profile_name": "Carb Sensitivity",
      "previous_profile_number": 5,
      "previous_profile_name": "Neuro-Autonomic",
      "changed": true,
      "change_direction": "improved",
      "key_axis_changes": {
        "5": {"from": "orange", "to": "green"},
        "1": {"from": "green", "to": "yellow"}
      }
    },
    {
      "profile_id": "uuid",
      "created_at": "2026-05-15T10:00:00Z",
      "timepoint": "baseline",
      "profile_number": 5,
      "profile_name": "Neuro-Autonomic",
      "changed": false
    }
  ]
}
Error States:
| Error | Message | Action |
| ------- | ------- | ------- |
| No profiles | "No profile history yet" | Show "Upload Labs" CTA |
| Network error | "Failed to load history" | Retry button |

Accessibility
Timeline announced as list
Change indicators announced: "Changed from Profile 5 to Profile 2. Great progress!"
Dates announced in readable format

📊 PHASE 2 SUMMARY
| Screen | Priority | User Stories | API Calls | Key ADRs |
| ------- | ------- | ------- | ------- | ------- |
| E8: Axes Dashboard | 🔴 P0 | US-17, US-19 | GET /axes | 006, 014, 011, 005 |
| E9: Axis Detail | 🟡 P1 | US-19 | GET /axes/{n} | 011, 005 |
| E10: Profile Result | 🔴 P0 | US-20, US-21 | GET /profiles/active | 005, 013, 011 |
| E11: Modifiers (section) | 🟡 P1 | US-21 | (part of E10) | 011 |
| E12: Profile History | 🟡 P1 | US-48 | GET /profiles/history | 013, 017 |
| E_symptom: Log Symptom | 🟡 P1 | US-43, US-44 | POST /symptoms | 011, 005 |



E_symptom: Log Symptom (Profile 5 users)
Screen ID: E_symptom
User Stories: US-43, US-44 (partial)
Priority: 🟡 P1
Route: /profile5/symptom-log
Purpose
Allow Profile 5 users to log symptoms (dizziness, brain fog, fatigue, shakiness) with optional context (hunger level, current glucose, dG/dt, HRV). This data is required to trigger / confirm Profile 5 selection (RMSSD < 25 + symptoms present).
States
State 1: Default
┌─────────────────────────────┐
│  Log Symptom           [×]  │
├─────────────────────────────┤
│                             │
│  What are you feeling?      │
│  ┌───────────────────────┐ │
│  │ ☐ Dizziness           │ │
│  │ ☐ Brain fog           │ │
│  │ ☐ Shakiness           │ │
│  │ ☐ Fatigue             │ │
│  │ ☐ Lump in throat      │ │
│  │ ☐ Heart racing        │ │
│  │ ☐ Sweating            │ │
│  │ ☐ Other: _______      │ │
│  └───────────────────────┘ │
│                             │
│  Severity (1-10):           │
│  ──●────────  4             │
│                             │
│  Hunger level (0-10):       │
│  ────●──────  6             │
│                             │
│  (Optional) Recent context: │
│  Glucose: ___ mg/dL         │
│  dG/dt:    ___ mg/dL/min    │
│  RMSSD:    ___ ms           │
│  Last meal: ___ ago         │
│                             │
│  [ Save ]                   │
│                             │
└─────────────────────────────┘
State 2: Saved
Toast: "Symptom logged. Thanks for the data — this helps calibrate your profile."
API Calls
POST /api/v1/symptoms
Request:
{
  "symptoms": ["dizziness", "brain_fog"],
  "severity": 4,
  "hunger_level": 6,
  "glucose_at_symptom": 92,
  "dg_dt_at_symptom": -0.4,
  "hrv_rmssd_at_symptom": 22
}
Response: { symptom_log_id, created_at }
Notes
- Symptom frequency ≥ 2/week AND RMSSD < 25 = Profile 5 confirmation (used by EvaluateResearchGroup)
- Auto-fills from latest device_readings when available (glucose, dG/dt, RMSSD)
- Available only for Profile 5 users (or for any user with symptoms as exploratory data)



🔑 CRITICAL UX NOTES FOR PHASE 2
1. Functional Thresholds Explanation 
Users with TSH 2.5-4.0 will be told by their doctor "your labs are normal." MetaCart will activate Profile 4. This requires clear UX explanation to avoid confusion and loss of trust.
Solution: Dedicated callout box on E10 (Profile 4) explaining the difference between diagnostic and functional ranges.
2. Profile 5 — "Normal Labs but Real Symptoms" 
Profile 5 users have normal labs but experience symptoms. This is a new concept for many users (especially from post-Soviet countries where this is diagnosed as "VSD").
Solution: Empathetic, clear explanation on E10 (Profile 5) that validates their symptoms and provides a biological mechanism (dG/dt, not absolute glucose).
3. Graceful Degradation UX 
Users with incomplete data need to understand:
What's missing
Why it matters
How to get a more accurate profile
Solution: Data completeness indicator on E8 + contextual CTAs ("Upload hs-CRP for complete analysis").
4. SDNN Paradox (Critical Edge Case)
High SDNN (>150ms) with low RMSSD (<25ms) is NOT health — it's dysregulatory variability. This is counterintuitive.
Solution: Special callout on E9 (Axis Detail) explaining the paradox clearly.
5. Cultural-Specific Thresholds 
Users from different cultural groups may have different thresholds for the same biomarker. This should be transparent but not confusing.
Solution: Small indicator on E9: "Thresholds adjusted for your cultural background (Eastern European)."



🎯 PHASE 3: CART GENERATION (6 screens)
E13: 7-Day Menu
Screen ID: E13
User Stories: US-22, US-23
Priority: 🟡 P1
Route: /cart/menu
Purpose
Display the personalized 7-day meal plan generated based on the user's metabolic profile, cultural food patterns, and dietary restrictions. This screen bridges the profile result (E10) with the grocery cart (E15) — users see what they'll eat before seeing what they'll buy.
Key Architectural Decisions Covered
(Cultural-Specific Thresholds): Menu reflects cultural food patterns (e.g., borscht for Eastern Europeans, rice & dal for South Asians)
(Functional Thresholds): Profile-specific meal principles (e.g., Profile 5: protein + fat + fiber at every meal)
(Step 4 is Core): Menu is the precursor to the cart, which feeds into drift analysis
User Flow
User taps "See 7-Day Menu" on E10 (Profile Result)
System generates menu based on profile + cultural profile + dietary restrictions (UC-22)
User sees week view with 7 days
User taps a day → sees meals for that day
User taps a meal → opens E17 (Recipe Detail modal)
User taps "Generate Grocery Cart" → navigates to E14 (Cart Settings)
States
State 1: Loading

┌─────────────────────────────┐
│  Your Week                  │
│  Profile 5 · Eastern Europ. │
├─────────────────────────────┤
│                             │
│  ┌──┬──┬──┬──┬──┬──┬──┐   │
│  │░░│░░│░░│░░│░░│░░│░░│   │
│  └──┴──┴──┴──┴──┴──┴──┘   │
│                             │
│  Generating your menu...    │
│                             │
└─────────────────────────────┘
State 2: Default (Week view)
┌─────────────────────────────┐
│  Your Week                  │
│  Profile 5 · Eastern Europ. │
├─────────────────────────────┤
│                             │
│  ┌──┬──┬──┬──┬──┬──┬──┐   │
│  │Mo│Tu│We│Th│Fr│Sa│Su│   │
│  └──┴──┴──┴──┴──┴──┴──┘   │
│  ──●─────────────────────   │
│                             │
│  📅 Monday, Jun 22          │
│                             │
│  ┌───────────────────────┐ │
│  │ 🌅 Breakfast          │ │
│  │ Eggs + avocado +      │ │
│  │ spinach               │ │
│  └───────────────────────┘ │
│                             │
│  ┌───────────────────────┐ │
│  │ ☀️ Lunch              │ │
│  │ Borscht with beef +   │ │
│  │ sour cream            │ │
│  └───────────────────────┘ │
│                             │
│  ┌───────────────────────┐ │
│  │ 🌙 Dinner             │ │
│  │ Wild salmon + roasted │ │
│  │ beets                 │ │
│  └───────────────────────┘ │
│                             │
│  ┌───────────────────────┐ │
│  │ 🥜 Snack              │ │
│  │ Greek yogurt +        │ │
│  │ walnuts               │ │
│  └───────────────────────┘ │
│                             │
│  [ Generate Grocery Cart ]  │
│                             │
└─────────────────────────────┘
State 3: Day selected (different day)
Week selector highlights selected day
Meals update for that day
Scroll to top of meals list
State 4: Empty state (menu not generated)
┌─────────────────────────────┐
│  Your Week                  │
├─────────────────────────────┤
│                             │
│  📭 No menu yet             │
│                             │
│  Complete your profile to   │
│  generate a personalized    │
│  7-day menu.                │
│                             │
│  [ See Your Profile ]       │
│                             │
└─────────────────────────────┘
UI Elements
Header:
Title: "Your Week"
Subtitle: "[Profile name] · [Cultural group]"
Week Selector (horizontal scroll):
7 day cards (Mon-Sun)
Selected day highlighted (primary color)
Today marked with dot indicator
Tap day → load meals for that day
Meals List (4 meals per day):
Each meal card:
Meal type icon (🌅 Breakfast / ☀️ Lunch / 🌙 Dinner / 🥜 Snack)
Meal name (e.g., "Borscht with beef + sour cream")
Tap target: entire card opens E17 (Recipe Detail)
Profile-Specific Meal Principles (banner, shown once at top):
Profile 1: "Diverse, seasonal foods. Quality over restriction."
Profile 2: "Protein first. Slow carbs. Fiber as buffer."
Profile 3: "Maximize reduction of ultra-processed foods. Omega-3."
Profile 4: "Regular meals. No aggressive restrictions. Moderate iodine."
Profile 5: "Protein + fat + fiber at every meal. Eat every 3-4 hours."
Buttons:
"Generate Grocery Cart" (primary)
Interactions
| Action | Result |
| ------- | ------- |
| Tap day in week selector | Load meals for that day |
| Tap meal card | Open E17 (Recipe Detail modal) |
| Tap "Generate Grocery Cart" | Navigate to E14 (Cart Settings) |
| Swipe left/right on week selector | Navigate to previous/next day |
| Pull-to-refresh | Regenerate menu (if profile changed) |

API Calls
Primary:
GET /api/v1/menu/week
Response:
{
  "profile_id": "uuid",
  "cultural_group": "eastern_european",
  "dietary_restrictions": [],
  "meal_principles": ["Protein + fat + fiber at every meal", "..."],
  "days": [
    {
      "date": "2026-06-22",
      "day_name": "Monday",
      "meals": [
        {
          "meal_type": "breakfast",
          "name": "Eggs + avocado + spinach",
          "recipe_id": "uuid",
          "ingredients": [
            {"name": "Eggs", "quantity": 3, "unit": "pcs"},
            {"name": "Avocado", "quantity": 0.5, "unit": "pcs"},
            {"name": "Spinach", "quantity": 50, "unit": "g"}
          ],
          "prep_time_min": 15,
          "cultural_pattern": null,
          "nutritional_info": {
            "calories": 450,
            "protein_g": 28,
            "carbs_g": 12,
            "fat_g": 32
          }
        },
        {
          "meal_type": "lunch",
          "name": "Borscht with beef + sour cream",
          "recipe_id": "uuid",
          "cultural_pattern": "borscht",
          "ingredients": [...]
        }
      ]
    }
  ]
}

Error handling:
404 — No profile selected → redirect to E10
500 — Menu generation failed → show error state, retry button
Error States
| Error | Message | Action |
| ------- | ------- | ------- |
| No profile | "Complete your profile to generate a menu" | Redirect to E10 |
| Menu generation failed | "Failed to generate menu. Please try again." | Retry button |
| No recipes match cultural profile | "Limited recipes for your cultural background. Showing closest matches." | Show banner, continue |
| Network error | "Check your connection and try again" | Retry button |

Accessibility
Week selector is horizontally scrollable with keyboard
Each meal card is a single tap target (min 48px height)
Meal type icons have alt text
Screen reader announces: "Monday. Breakfast. Eggs, avocado, spinach. Tap for recipe details."
Selected day announced: "Monday selected, day 1 of 7"



E14: Cart Settings
Screen ID: E14
User Stories: US-24, US-25
Priority: 🔴 P0
Route: /cart/settings
Purpose
Configure budget tier and household size before generating the shopping cart. These settings determine which specific products are selected and how quantities are scaled.
Key Architectural Decisions Covered
 (Open Food Facts + USDA): Products selected based on budget tier
Household scaling rules (from Developer Architecture):
Proteins/vegetables/fruits: × N people
Grains/bread: stepped (1 person = 1 pack, 2-3 = 2 packs, 4+ = 3 packs)
Oils/spices: slow scaling (1 bottle for 1-3 people)
Nutraceuticals (Profile 5): always × 1 (personal dose)
User Flow
User taps "Generate Grocery Cart" on E13 (Menu)
User sees cart settings screen
User selects budget tier (LOW / MID / HIGH)
User sets household size (slider 1-6)
User taps "View Cart" → navigates to E15 (Shopping Cart)
System generates cart with selected settings
States
State 1: Default
┌─────────────────────────────┐
│  Cart Settings              │
├─────────────────────────────┤
│                             │
│  Budget tier                │
│                             │
│  ┌──────┐ ┌──────┐ ┌──────┐│
│  │  🟢  │ │  🟡  │ │  🔵  ││
│  │ LOW  │ │ MID  │ │ HIGH ││
│  │      │ │ ●    │ │      ││
│  │Walmart│ │Costco│ │Whole ││
│  │Aldi  │ │Target│ │Foods ││
│  └──────┘ └──────┘ └──────┘│
│                             │
│  People in household        │
│  ───────●───────── 2 people │
│                             │
│  💡 Scaling applied:        │
│  • Proteins ×2              │
│  • Vegetables ×2            │
│  • Grains: 2 packs          │
│  • Oils: 1 bottle           │
│  • Nutraceuticals ×1        │
│    (personal dose)          │
│                             │
│  [ View Cart ]              │
│                             │
└─────────────────────────────┘

State 2: Budget tier selected
Selected tier card has primary color border + background tint
Other tiers are neutral
State 3: Household size changed
Slider updates
Scaling explanation updates dynamically
"View Cart" button remains enabled
UI Elements
Header:
Title: "Cart Settings"
Budget Tier Selector (3 cards):
🟢 LOW: "Walmart / Aldi" — frozen, canned, store-brand
🟡 MID: "Costco / Target" — bulk packs, good value
🔵 HIGH: "Whole Foods" — organic, wild-caught, specialty
Selected tier has primary color border + tinted background
Tap to select
Household Size Slider:
Range: 1-6 people
Current value displayed: "2 people"
Real-time update
Scaling Explanation (dynamic):
Updates based on household size
Shows how each category is scaled
Special note for nutraceuticals (Profile 5): "×1 (personal dose)"
Buttons:
"View Cart" (primary)
Interactions

| Action | Result |
| ------- | ------- |
| Tap budget tier card | Select that tier, update styling |
| Drag household slider | Update household size + scaling explanation |
| Tap "View Cart" | Navigate to E15 (Shopping Cart) |
API Calls
Primary:
POST /api/v1/carts/generate
Request
{
  "budget_tier": "mid",
  "household_size": 2,
  "profile_id": "uuid",
  "menu_id": "uuid"
}

Response:
{
  "cart_id": "uuid",
  "total_estimated_cost": 142.50,
  "currency": "USD",
  "items_count": 28,
  "generated_at": "2026-06-22T10:00:00Z"
}
Error States
| Error | Message | Action |
| ------- | ------- | ------- |
| Cart generation failed | "Failed to generate cart. Please try again." | Retry button |
| No products match budget tier | "Limited products available for this budget tier." | Show banner, continue |
| Network error | "Check your connection and try again" | Retry button |

Accessibility
Budget tier cards have tap targets min 48x48px
Slider is keyboard-accessible
Screen reader announces: "Budget tier, MID selected. Household size, 2 people."
Scaling explanation announced as list


E15: Shopping Cart
Screen ID: E15
User Stories: US-26, US-27
Priority: 🔴 P0
Route: /cart/shopping
Purpose
Display the generated shopping cart with all items grouped by category, quantities, units, and estimated prices. This is the final output before the user exports the list for actual shopping.
Key Architectural Decisions Covered
(Open Food Facts + USDA): Products come from catalog with UPC codes
Nutraceuticals disclaimer (from Developer Architecture): Profile 5 nutraceuticals require "Consult your doctor" disclaimer
No retailer integration in beta (from Beta Spec): Export only, no live checkout
User Flow
User taps "View Cart" on E14 (Cart Settings)
System retrieves generated cart (UC-26)
User sees items grouped by category
User reviews items, quantities, prices
User taps "Export" → opens E16 (Cart Export)
User taps item → opens E18 (Cart Item Detail modal)
States
State 1: Loading

┌─────────────────────────────┐
│  Your Cart                  │
│  MID · 2 people · 7 days    │
├─────────────────────────────┤
│                             │
│  ┌───────────────────────┐ │
│  │ ░░░░░░░░░░░░░░░░░░░░░ │ │
│  └───────────────────────┘ │
│  ┌───────────────────────┐ │
│  │ ░░░░░░░░░░░░░░░░░░░░░ │ │
│  └───────────────────────┘ │
│                             │
│  Generating your cart...    │
│                             │
└─────────────────────────────┘
State 2: Default (Profile 1-4, no nutraceuticals)
┌─────────────────────────────┐
│  Your Cart                  │
│  MID · 2 people · 7 days    │
│  ~$142                      │
├─────────────────────────────┤
│                             │
│  PROTEINS                   │
│  ┌───────────────────────┐ │
│  │ 🥚 Eggs (18 ct)  $5.99│ │
│  │ 🥛 Greek yogurt  $6.49│ │
│  │ 🐟 Wild salmon   $24  │ │
│  └───────────────────────┘ │
│                             │
│  VEGETABLES                 │
│  ┌───────────────────────┐ │
│  │ 🥬 Beets (3 lb)  $4.50│ │
│  │ 🥬 Spinach (10oz)$3.99│ │
│  │ 🥑 Avocados (6)  $7.80│ │
│  └───────────────────────┘ │
│                             │
│  GRAINS                     │
│  ┌───────────────────────┐ │
│  │ 🌾 Buckwheat (2lb)$3.50│ │
│  └───────────────────────┘ │
│                             │
│  FATS & OILS                │
│  ┌───────────────────────┐ │
│  │ 🫒 Olive oil (750ml)$9│ │
│  │ 🥜 Walnuts (16oz) $8  │ │
│  └───────────────────────┘ │
│                             │
│  [ Export List ]            │
│  [ Regenerate ]             │
│                             │
└─────────────────────────────┘

State 3: Profile 5 (with nutraceuticals)
┌─────────────────────────────┐
│  Your Cart                  │
│  MID · 2 people · 7 days    │
│  ~$185                      │
├─────────────────────────────┤
│                             │
│  ⚕️ Consult your doctor     │
│  before taking supplements  │
│                             │
│  PROTEINS                   │
│  ┌───────────────────────┐ │
│  │ 🥚 Eggs (18 ct)  $5.99│ │
│  │ 🧀 Burrata (2)   $9.00│ │
│  │ 🥛 Greek yogurt  $6.49│ │
│  │ 🐟 Wild salmon   $24  │ │
│  └───────────────────────┘ │
│                             │
│  [other categories...]      │
│                             │
│  NUTRACEUTICALS ⚕️          │
│  ┌───────────────────────┐ │
│  │ 💊 CoQ10 200mg   $18  │ │
│  │ 💊 Omega-3 2g    $22  │ │
│  │ 💊 Vitamin D3    $12  │ │
│  └───────────────────────┘ │
│                             │
│  [ Export List ]            │
│  [ Regenerate ]             │
│                             │
└─────────────────────────────┘

State 4: Empty state
┌─────────────────────────────┐
│  Your Cart                  │
├─────────────────────────────┤
│                             │
│  🛒 Cart is empty           │
│                             │
│  Generate a cart from your  │
│  7-day menu to see what to  │
│  buy.                       │
│                             │
│  [ Generate Cart ]          │
│                             │
└─────────────────────────────┘
UI Elements
Header:
Title: "Your Cart"
Subtitle: "[Budget tier] · [Household size] people · 7 days"
Total estimated cost: "~$142"
Disclaimer Banner (Profile 5 only):
"⚕️ Consult your doctor before taking supplements"
Yellow background, warning icon
Category Sections:
Category header (PROTEINS, VEGETABLES, GRAINS, FATS & OILS, NUTRACEUTICALS)
Item list within each category:
Emoji icon
Product name + trade unit (e.g., "Eggs (18 ct)")
Estimated price
Tap target: entire row opens E18 (Cart Item Detail)
Buttons:
"Export List" (primary)
"Regenerate" (secondary)
Interactions
| Action | Result |
| ------- | ------- |
| Tap item row | Open E18 (Cart Item Detail modal) |
| Tap "Export List" | Navigate to E16 (Cart Export) |
| Tap "Regenerate" | Return to E14 (Cart Settings) |
| Pull-to-refresh | Reload cart |
| Long-press item | Show "Remove from cart" option |
API Calls
Primary:
GET /api/v1/carts/{cart_id}
Response:
{
  "cart_id": "uuid",
  "budget_tier": "mid",
  "household_size": 2,
  "duration_days": 7,
  "total_estimated_cost": 142.50,
  "currency": "USD",
  "categories": [
    {
      "name": "proteins",
      "items": [
        {
          "item_id": "uuid",
          "product_name": "Eggs (large, pasture-raised)",
          "product_category": "proteins",
          "quantity": 1,
          "unit": "carton",
          "trade_unit_description": "Eggs (18 ct)",
          "estimated_price": 5.99,
          "upc_code": "012345678905",
          "is_nutraceutical": false,
          "cultural_pattern": null,
          "modifier_source": null
        },
        {
          "product_name": "Greek yogurt (full-fat)",
          "quantity": 1,
          "unit": "tub",
          "trade_unit_description": "Greek yogurt (32oz)",
          "estimated_price": 6.49,
          "upc_code": "098765432109",
          "is_nutraceutical": false
        }
      ]
    },
    {
      "name": "nutraceuticals",
      "items": [
        {
          "product_name": "CoQ10 200mg",
          "quantity": 1,
          "unit": "bottle",
          "trade_unit_description": "CoQ10 200mg (60 ct)",
          "estimated_price": 18.00,
          "is_nutraceutical": true,
          "requires_disclaimer": true
        }
      ]
    }
  ],
  "generated_at": "2026-06-22T10:00:00Z",
  "expires_at": "2026-06-29T10:00:00Z"
}
Error States

| Error | Message | Action |
| ------- | ------- | ------- |
| Cart not found | "Cart not found. Please regenerate." | Redirect to E14 |
| Cart expired | "This cart has expired. Please regenerate." | Redirect to E14 |
| Network error | "Check your connection and try again" | Retry button |

Accessibility
Each item row is a single tap target (min 48px height)
Category headers are announced as headings
Disclaimer banner announced with warning role
Screen reader announces: "Eggs, 18 count, $5.99. Tap for details."
Total cost announced: "Total estimated cost, $142.50"


E16: Cart Export
Screen ID: E16
User Stories: US-28
Priority: 🔴 P0
Route: /cart/export
Purpose
Export the shopping cart as CSV or PDF for use during actual shopping. This is the final step before the user goes to the store — no live retailer integration in beta (roadmap).
User Flow
User taps "Export List" on E15 (Shopping Cart)
User selects export format (CSV / PDF)
System generates file
System opens share sheet (iOS/Android native)
User can share via email, Messages, save to Files, etc.
States
State 1: Default
┌─────────────────────────────┐
│  Export Cart                │
├─────────────────────────────┤
│                             │
│  Choose format:             │
│                             │
│  ┌───────────────────────┐ │
│  │ 📊 CSV                │ │
│  │ Spreadsheet format    │ │
│  │ Editable, importable  │ │
│  └───────────────────────┘ │
│                             │
│  ┌───────────────────────┐ │
│  │ 📄 PDF                │ │
│  │ Print-friendly format │ │
│  │ Read-only, shareable  │ │
│  └───────────────────────┘ │
│                             │
│  [ Export ]                 │
│                             │
└─────────────────────────────┘
State 2: Exporting
┌─────────────────────────────┐
│  Export Cart                │
├─────────────────────────────┤
│                             │
│  ⏳ Generating PDF...       │
│                             │
│  ━━━━━━━━━━░░░░░░░░░░░░░░  │
│                             │
└─────────────────────────────┘
State 3: Success (Share Sheet)
Native iOS/Android share sheet appears
User can share via email, Messages, AirDrop, save to Files, etc.
State 4: Error
┌─────────────────────────────┐
│  Export Cart                │
├─────────────────────────────┤
│                             │
│  ❌ Export failed           │
│                             │
│  Please try again or check  │
│  your storage space.        │
│                             │
│  [ Retry ]  [ Cancel ]      │
│                             │
└─────────────────────────────┘
UI Elements
Header:
Title: "Export Cart"
Format Selector (2 cards):
📊 CSV: "Spreadsheet format. Editable, importable."
📄 PDF: "Print-friendly format. Read-only, shareable."
Tap to select (radio button behavior)
Buttons:
"Export" (primary, enabled only when format selected)
Interactions
| Action | Result |
| ------- | ------- |
| Tap format card | Select that format |
| Tap "Export" | Generate file, open share sheet |
| Tap "Retry" (on error) | Retry export |
| Tap "Cancel" (on error) | Return to E15 |
API Calls
Primary:
POST /api/v1/carts/{cart_id}/export
Request:
{
  "format": "pdf"
}
Response: Binary file (PDF or CSV)
Error States:
| Error | Message | Action |
| ------- | ------- | ------- |
| Export failed | "Export failed. Please try again or check your storage space." | Retry button |
| No format selected | "Please select a format" | Disable Export button |
| Network error | "Check your connection and try again" | Retry button |
Accessibility
Format cards have tap targets min 48x48px
Export progress announced by screen reader
Share sheet is native (accessible by default)

E17: Recipe Detail (Modal)
Screen ID: E17
User Stories: US-23 (alternative)
Priority: 🟢 P2
Route: /cart/menu/recipe/{recipe_id} (modal)
Purpose
Show detailed recipe information for a specific meal from the 7-day menu. This is a nice-to-have screen (P2) — users can see ingredients and instructions, but it's not critical for the core flow.
User Flow
User taps a meal card on E13 (7-Day Menu)
Modal slides up from bottom
User sees recipe details (ingredients, instructions, nutritional info)
User taps "Close" or swipes down to dismiss
States
State 1: Default
┌─────────────────────────────┐
│  Borscht with beef     [×]  │
├─────────────────────────────┤
│                             │
│  [Recipe photo placeholder] │
│                             │
│  ☀️ Lunch · 45 min          │
│  Cultural pattern: Borscht  │
│                             │
│  Ingredients:               │
│  • Beef (1 lb)              │
│  • Beets (2 medium)         │
│  • Cabbage (1/4 head)       │
│  • Carrots (2)              │
│  • Onion (1)                │
│  • Tomato paste (2 tbsp)    │
│  • Sour cream (for serving) │
│  • Dill (fresh)             │
│                             │
│  Instructions:              │
│  1. Simmer beef in water    │
│     for 1 hour              │
│  2. Add beets, cabbage,     │
│     carrots, onion          │
│  3. Simmer 30 min          │
│  4. Add tomato paste,       │
│     seasonings              │
│  5. Serve with sour cream   │
│     and dill                │
│                             │
│  Nutrition (per serving):   │
│  380 cal · 28g protein      │
│  18g carbs · 22g fat        │
│                             │
│  [ Close ]                  │
│                             │
└─────────────────────────────┘
UI Elements
Header:
Recipe name
Close button (×)
Hero Section:
Recipe photo (placeholder if not available)
Meal type icon + prep time
Cultural pattern tag (if applicable, e.g., "Cultural pattern: Borscht")
Ingredients Section:
List of ingredients with quantities
Each ingredient: name + quantity + unit
Instructions Section:
Numbered list of steps
Nutrition Section:
Calories, protein, carbs, fat (per serving)
Buttons:
"Close" (secondary)
Interactions:
| Action | Result |
| ------- | ------- |
| Tap "Close" or swipe down | Dismiss modal |
| Tap ingredient | Show tooltip with product details (if in catalog) |
API Calls
Primary:
GET /api/v1/recipes/{recipe_id}
Response:
{
  "recipe_id": "uuid",
  "name": "Borscht with beef + sour cream",
  "meal_type": "lunch",
  "prep_time_min": 45,
  "cultural_pattern": "borscht",
  "photo_url": "https://...",
  "ingredients": [
    {"name": "Beef", "quantity": 1, "unit": "lb"},
    {"name": "Beets", "quantity": 2, "unit": "medium"},
    ...
  ],
  "instructions": [
    "Simmer beef in water for 1 hour",
    "Add beets, cabbage, carrots, onion",
    ...
  ],
  "nutritional_info": {
    "calories": 380,
    "protein_g": 28,
    "carbs_g": 18,
    "fat_g": 22
  }
}

Error States:
| Error | Message | Action |
| ------- | ------- | ------- |
| Recipe not found | "Recipe not available" | Close modal |
| Network error | "Failed to load recipe" | Retry button |
Accessibility
Modal is focus-trapped
Close button is keyboard-accessible (Escape key)
Ingredients and instructions announced as lists
Screen reader announces: "Borscht with beef. Lunch. 45 minutes. Cultural pattern: Borscht."


E18: Cart Item Detail (Modal)
Screen ID: E18
User Stories: US-27 (alternative)
Priority: 🟢 P2
Route: /cart/item/{item_id} (modal)
Purpose
Show detailed information about a specific item in the shopping cart, including why it was recommended (based on profile), nutritional info, and product details from the catalog.
User Flow
User taps an item row on E15 (Shopping Cart)
Modal slides up from bottom
User sees item details (product info, why recommended, nutrition)
User taps "Close" or swipes down to dismiss
States
State 1: Default
┌─────────────────────────────┐
│  Eggs (18 ct)          [×]  │
├─────────────────────────────┤
│                             │
│  [Product photo]            │
│                             │
│  Quantity: 1 carton         │
│  Estimated price: $5.99     │
│  UPC: 012345678905          │
│                             │
│  Why this item:             │
│  Recommended for Profile 5. │
│  High-quality protein + fat │
│  for every meal.            │
│                             │
│  Nutrition (per serving):   │
│  140 cal · 12g protein      │
│  1g carbs · 10g fat         │
│                             │
│  Source: Open Food Facts    │
│                             │
│  [ Close ]                  │
│                             │
└─────────────────────────────┘
UI Elements
Header:
Product name
Close button (×)
Hero Section:
Product photo (from catalog)
Quantity + unit
Estimated price
UPC code (small, gray)
Why Recommended Section:
Explanation based on profile + modifiers
Example: "Recommended for Profile 5. High-quality protein + fat for every meal."
If from modifier: "Added due to Axis 3 (Inflammation) — omega-3 source"
Nutrition Section:
Calories, protein, carbs, fat (per serving)
Source Attribution:
"Source: Open Food Facts" 
Buttons:
"Close" (secondary)
Interactions:

| Action | Result |
| ------- | ------- |
| Tap "Close" or swipe down | Dismiss modal |
| Tap UPC code | Copy to clipboard |
API Calls
Primary:
GET /api/v1/cart-items/{item_id}
Response:
{
  "item_id": "uuid",
  "product_name": "Eggs (large, pasture-raised)",
  "product_category": "proteins",
  "quantity": 1,
  "unit": "carton",
  "trade_unit_description": "Eggs (18 ct)",
  "estimated_price": 5.99,
  "upc_code": "012345678905",
  "photo_url": "https://...",
  "why_recommended": "Recommended for Profile 5. High-quality protein + fat for every meal.",
  "modifier_source": null,
  "nutritional_info": {
    "calories": 140,
    "protein_g": 12,
    "carbs_g": 1,
    "fat_g": 10
  },
  "source": "open_food_facts"
}
Error States:
| Error | Message | Action |
| ------- | ------- | ------- |
| Item not found | "Item not available" | Close modal |
| Network error | "Failed to load item details" | Retry button |
Accessibility
Modal is focus-trapped
Close button is keyboard-accessible
All fields announced by screen reader
Source attribution announced: "Source: Open Food Facts"


📊 PHASE 3 SUMMARY
| Screen | Priority | User Stories | API Calls | Key ADRs |
| ------- | ------- | ------- | ------- | ------- |
| E13: 7-Day Menu | 🟡 P1 | US-22, US-23 | GET /menu/week | 011, 005 |
| E14: Cart Settings | 🔴 P0 | US-24, US-25 | POST /carts/generate | 015 |
| E15: Shopping Cart | 🔴 P0 | US-26, US-27 | GET /carts/{id} | 015 |
| E16: Cart Export | 🔴 P0 | US-28 | POST /carts/{id}/export | — |
| E17: Recipe Detail | 🟢 P2 | US-23 | GET /recipes/{id} | 011 |
| E18: Cart Item Detail | 🟢 P2 | US-27 | GET /cart-items/{id} | 015 |



🔑 CRITICAL UX NOTES FOR PHASE 3
1. Cultural Adaptation is Visible
Users should see that the menu reflects their cultural background. This builds trust and differentiates MetaCart from generic nutrition apps.
Solution:
Cultural pattern tags on recipes (e.g., "Cultural pattern: Borscht")
Subtitle on E13: "Profile 5 · Eastern European"
Explanation in E10 (Profile Result): "Your recommendations are adapted to your Eastern European food traditions"
2. Budget Tier Clarity 
Users need to understand what each budget tier means without confusion.
Solution:
Clear retailer examples (Walmart/Aldi vs Costco/Target vs Whole Foods)
Visual differentiation (🟢/🟡/🔵 color coding)
Explanation that nutritional logic doesn't change — only quality/price of sources
3. Household Scaling Transparency
Users need to understand how quantities are scaled, especially for nutraceuticals (which are NOT scaled).
Solution:
Dynamic scaling explanation on E14
Special callout for nutraceuticals: "×1 (personal dose)"
Tooltip on scaling explanation for more details
4. Nutraceuticals Disclaimer (Legal Requirement)
Profile 5 nutraceuticals require clear disclaimer to avoid medical device classification.
Solution:
Yellow banner at top of cart (Profile 5 only): "⚕️ Consult your doctor before taking supplements"
Disclaimer on each nutraceutical item detail (E18)
Screen reader announces disclaimer clearly
5. No Retailer Integration (Beta Scope)
Users may expect "Buy Now" button like other apps. Need to manage expectations.
Solution:
Clear "Export List" button (not "Buy Now")
Explanation: "Export your cart as CSV or PDF for shopping"
Future roadmap note (optional): "Live retailer integration coming soon"
6. Open Food Facts Attribution 
Must attribute Open Food Facts data to comply with ODbL license.
Solution:
Small attribution on E18 (Cart Item Detail): "Source: Open Food Facts"
Attribution in E36 (About screen): "Product data from Open Food Facts (ODbL license)"


🎯 PHASE 4: STEP 4 — CORE DIFFERENTIATOR (10 screens)
This is MetaCart's unique value proposition. Everything in this phase must work flawlessly from day 1. The drift analysis is what makes MetaCart different from every other nutrition app on the market.
E19: Purchase Capture (Home)
Screen ID: E19
User Stories: US-29, US-30
Priority: 🔴 P0
Route: /step4/purchase
Purpose
Entry point for capturing actual purchases. This is where the user compares what they bought with what was recommended — the heart of MetaCart's core differentiator.
Key Architectural Decisions Covered
(Step 4 is Core): This screen must work perfectly from day 1
(OCR Pipeline): Two capture methods (manual + receipt photo)
(Open Food Facts + USDA): Product matching uses catalog with UPC codes
User Flow
User taps "Capture Purchase" from home screen or navigation
System checks if recommended cart exists
If no cart → redirect to E15 (Shopping Cart) with message
If cart exists → show two capture options (manual / receipt)
User chooses method → navigates to E20 or E21
Recent purchases list shown below (last 5)
States
State 1: Default (cart exists)
┌─────────────────────────────┐
│  Capture Purchase           │
├─────────────────────────────┤
│                             │
│  Compare what you bought    │
│  with your recommendations  │
│                             │
│  ┌───────────────────────┐ │
│  │ 📸 Upload Receipt     │ │
│  │    Photo              │ │
│  │                       │ │
│  │    Quick & automatic  │ │
│  └───────────────────────┘ │
│                             │
│  ┌───────────────────────┐ │
│  │ ✏️ Enter Manually     │ │
│  │                       │ │
│  │    Type what you      │ │
│  │    bought             │ │
│  └───────────────────────┘ │
│                             │
│  Recent Purchases           │
│  ┌───────────────────────┐ │
│  │ Jun 25 · 87% match    │ │
│  │ 18 items · $138       │ │
│  └───────────────────────┘ │
│  ┌───────────────────────┐ │
│  │ Jun 18 · 92% match    │ │
│  │ 22 items · $156       │ │
│  └───────────────────────┘ │
│  [ View All ]               │
│                             │
└─────────────────────────────┘
State 2: No recommended cart
┌─────────────────────────────┐
│  Capture Purchase           │
├─────────────────────────────┤
│                             │
│  📭 No recommended cart yet │
│                             │
│  Generate a shopping cart   │
│  first to start tracking    │
│  your drift.                │
│                             │
│  [ Generate Cart ]          │
│                             │
└─────────────────────────────┘
State 3: Empty state (no recent purchases)
┌─────────────────────────────┐
│  Capture Purchase           │
├─────────────────────────────┤
│                             │
│  [ Upload Receipt ]         │
│  [ Enter Manually ]         │
│                             │
│  📝 No purchases yet        │
│                             │
│  Capture your first         │
│  purchase to see how your   │
│  actual groceries compare   │
│  to recommendations.        │
│                             │
└─────────────────────────────┘
UI Elements
Header:
Title: "Capture Purchase"
Capture Method Cards (2 cards):
📸 "Upload Receipt Photo" — subtitle "Quick & automatic"
✏️ "Enter Manually" — subtitle "Type what you bought"
Tap target: entire card
Recent Purchases List:
Last 5 purchases
Each entry: date, match percentage, item count, total spent
Tap entry → navigate to E24 (Purchase Summary)
"View All" link → full purchase history
Call-to-Action (conditional):
"Generate Cart" button (if no cart exists)
Interactions
| Action | Result |
| ------- | ------- |
| Tap "Upload Receipt Photo" | Navigate to E21 (Receipt Upload) |
| Tap "Enter Manually" | Navigate to E20 (Manual Purchase Entry) |
| Tap recent purchase | Navigate to E24 (Purchase Summary) |
| Tap "View All" | Navigate to full purchase history |
| Tap "Generate Cart" | Navigate to E15 (Shopping Cart) |
API Calls
Primary:
GET /api/v1/purchases/recent?limit=5
Response:
{
  "purchases": [
    {
      "purchase_id": "uuid",
      "purchase_date": "2026-06-25",
      "capture_method": "receipt_photo",
      "total_items": 18,
      "total_spent": 138.50,
      "match_percentage": 87.0,
      "drift_percentage": 13.0,
      "ocr_status": "confirmed"
    }
  ],
  "has_recommended_cart": true,
  "active_cart_id": "uuid"
}
Error States
| Error | Message | Action |
| ------- | ------- | ------- |
| No recommended cart | "No recommended cart yet. Generate a shopping cart first." | Show "Generate Cart" button |
| Network error | "Check your connection and try again" | Retry button |
Accessibility
Capture cards have tap targets min 48x48px
Recent purchases list is keyboard-navigable
Screen reader announces: "Upload Receipt Photo button. Quick and automatic."
Match percentage announced: "June 25, 87 percent match, 18 items, $138"


E20: Manual Purchase Entry
Screen ID: E20
User Stories: US-29
Priority: 🔴 P0
Route: /step4/purchase/manual
Purpose
Manually enter purchased items when receipt photo is not available or user prefers typing. This is the fallback from OCR pipeline.
User Flow
User taps "Enter Manually" on E19
System shows item entry form
User enters items one by one (product name, quantity, unit, optional price)
Product name has autocomplete from products_catalog
User taps "Add Item" → item added to list
User can edit/delete items in list
User taps "Save" → system creates actual_purchases + purchase_items
System triggers matching (UC-31) and drift analysis (EP-11)
Redirect to E25 (Drift Dashboard)
States
State 1: Default (empty form)
┌─────────────────────────────┐
│  Manual Entry          [×]  │
├─────────────────────────────┤
│                             │
│  Add items you bought       │
│                             │
│  Product name               │
│  ┌───────────────────────┐ │
│  │ 🔍 Search...          │ │
│  └───────────────────────┘ │
│                             │
│  Quantity    Unit           │
│  ┌────────┐  ┌──────────┐  │
│  │ 1      │  │ pcs ▼    │  │
│  └────────┘  └──────────┘  │
│                             │
│  Price (optional)           │
│  ┌───────────────────────┐ │
│  │ $                     │ │
│  └───────────────────────┘ │
│                             │
│  [ Add Item ]               │
│                             │
│  Items added (0)            │
│                             │
│  [ Save & See Drift ]       │
│                             │
└─────────────────────────────┘
State 2: Items added
┌─────────────────────────────┐
│  Manual Entry          [×]  │
├─────────────────────────────┤
│                             │
│  [ Add more items form... ] │
│                             │
│  Items added (3)            │
│  ┌───────────────────────┐ │
│  │ 🥚 Eggs (18 ct)   ←→  │ │
│  │    1 carton · $5.99   │ │
│  └───────────────────────┘ │
│  ┌───────────────────────┐ │
│  │ 🥛 Greek yogurt   ←→  │ │
│  │    1 tub · $6.49      │ │
│  └───────────────────────┘ │
│  ┌───────────────────────┐ │
│  │ 🍞 White bread    ←→  │ │
│  │    1 loaf · $3.50     │ │
│  └───────────────────────┘ │
│                             │
│  [ Save & See Drift ]       │
│                             │
└─────────────────────────────┘

State 3: Autocomplete suggestions
┌─────────────────────────────┐
│  Manual Entry          [×]  │
├─────────────────────────────┤
│                             │
│  Product name               │
│  ┌───────────────────────┐ │
│  │ eggs                  │ │
│  └───────────────────────┘ │
│  ┌───────────────────────┐ │
│  │ 🥚 Eggs (18 ct)       │ │
│  │    $5.99 · Open Food  │ │
│  ├───────────────────────┤ │
│  │ 🥚 Eggs (dozen)       │ │
│  │    $4.99 · Open Food  │ │
│  ├───────────────────────┤ │
│  │ 🥚 Eggs (organic)     │ │
│  │    $7.99 · Open Food  │ │
│  └───────────────────────┘ │
│                             │
└─────────────────────────────┘
State 4: Empty list validation
"Save" button disabled
Message: "Add at least one item"
UI Elements
Header:
Title: "Manual Entry"
Close button (×)
Item Entry Form:
Product name input with autocomplete (from products_catalog)
Quantity input (numeric, default 1)
Unit dropdown (pcs, lbs, oz, carton, tub, bottle, etc.)
Price input (optional, numeric with $ prefix)
"Add Item" button
Items List:
Each item card:
Emoji icon (from product category)
Product name
Quantity + unit
Price (if entered)
Swipe left to delete (←→ indicator)
Tap to edit
Buttons:
"Save & See Drift" (primary, disabled if list empty)
Interactions:
| Action | Result |
| ------- | ------- |
| Type in product name | Show autocomplete suggestions after 2+ chars |
| Tap autocomplete suggestion | Fill product name + auto-fill unit |
| Tap "Add Item" | Add item to list, clear form |
| Swipe item left | Show delete button |
| Tap item in list | Open edit mode |
| Tap "Save & See Drift" | Save, trigger matching, navigate to E25 |
| Tap "×" | Discard changes, navigate back |
API Calls
Primary:
GET /api/v1/products/search?q={query}&limit=5
Response:
{
  "products": [
    {
      "product_id": "uuid",
      "name": "Eggs (large, pasture-raised)",
      "category": "proteins",
      "default_unit": "carton",
      "upc_code": "012345678905",
      "source": "open_food_facts"
    }
  ]
}

POST /api/v1/purchases/manual
Request:
{
  "purchase_date": "2026-06-25",
  "capture_method": "manual",
  "items": [
    {
      "product_catalog_id": "uuid",
      "product_name": "Eggs (18 ct)",
      "quantity": 1,
      "unit": "carton",
      "price": 5.99
    }
  ]
}
Response:
{
  "purchase_id": "uuid",
  "processing_status": "completed",
  "items_matched": 2,
  "items_drift": 1
}
Error States:
| Error | Message | Action |
| ------- | ------- | ------- |
| Empty list | "Add at least one item" | Disable Save button |
| Product not found | "Product not in catalog. You can still add it as 'Other'." | Allow manual name entry |
| Save failed | "Failed to save. Please try again." | Retry button |
| Network error | "Check your connection and try again" | Retry button |
Accessibility
Autocomplete is keyboard-navigable (arrow keys)
Each item card is swipe-accessible
Screen reader announces: "Eggs, 18 count, 1 carton, $5.99. Swipe left to delete."


E21: Receipt Upload
Screen ID: E21
User Stories: US-30
Priority: 🔴 P0
Route: /step4/purchase/receipt
Purpose
Upload a receipt photo for OCR processing. This is the primary capture method for most users.
User Flow
User taps "Upload Receipt Photo" on E19
System opens camera or file picker
User takes photo or selects from gallery
System shows preview
User taps "Upload"
System uploads to Supabase Storage
System sends to OCR service (Google Vision API)
System shows "Processing receipt..." screen
OCR completes → redirect to E22 (OCR Review)
States
State 1: Default (no photo selected)
┌─────────────────────────────┐
│  Upload Receipt        [×]  │
├─────────────────────────────┤
│                             │
│  📸                         │
│                             │
│  Take a clear photo of      │
│  your receipt               │
│                             │
│  Tips:                      │
│  • Good lighting            │
│  • All items visible        │
│  • Flat surface             │
│                             │
│  [ Take Photo ]             │
│  [ Choose from Gallery ]    │
│                             │
│  Or                         │
│                             │
│  [ Enter Manually ]         │
│                             │
└─────────────────────────────┘
State 2: Photo selected (preview)
┌─────────────────────────────┐
│  Upload Receipt        [×]  │
├─────────────────────────────┤
│                             │
│  ┌───────────────────────┐ │
│  │                       │ │
│  │   [Receipt preview]   │ │
│  │                       │ │
│  └───────────────────────┘ │
│                             │
│  [ Retake ]  [ Use this ]   │
│                             │
└─────────────────────────────┘
State 3: Uploading
┌─────────────────────────────┐
│  Upload Receipt        [×]  │
├─────────────────────────────┤
│                             │
│  ⏳ Uploading receipt...    │
│                             │
│  ━━━━━━━━━━░░░░░░░░░░░░░░  │
│                             │
└─────────────────────────────┘
State 4: OCR Processing
┌─────────────────────────────┐
│  Upload Receipt        [×]  │
├─────────────────────────────┤
│                             │
│  🔍 Processing receipt...   │
│                             │
│  This may take 10-30        │
│  seconds                    │
│                             │
│  ⏳ ⏳ ⏳                    │
│                             │
│  [ Cancel ]                 │
│                             │
└─────────────────────────────┘
State 5: OCR Failed
┌─────────────────────────────┐
│  Upload Receipt        [×]  │
├─────────────────────────────┤
│                             │
│  ❌ Couldn't read receipt   │
│                             │
│  The image may be blurry    │
│  or too dark.               │
│                             │
│  [ Try Again ]              │
│  [ Enter Manually ]         │
│                             │
└─────────────────────────────┘
UI Elements
Header:
Title: "Upload Receipt"
Close button (×)
Upload Area:
Camera icon (large, centered)
Instructions: "Take a clear photo of your receipt"
Tips list (good lighting, all items visible, flat surface)
"Take Photo" button (primary)
"Choose from Gallery" button (secondary)
Divider: "Or"
"Enter Manually" link (fallback)
Preview (after photo selected):
Image preview
"Retake" button
"Use this" button (primary)
Processing:
Progress indicator
"Processing receipt..." text
Estimated time: "10-30 seconds"
"Cancel" button
Interactions:
| Action | Result |
| ------- | ------- |
| Tap "Take Photo" | Open camera |
| Tap "Choose from Gallery" | Open file picker |
| Select photo | Show preview |
| Tap "Retake" | Clear preview, return to default |
| Tap "Use this" | Start upload + OCR |
| Tap "Cancel" (during processing) | Cancel OCR, return to default |
| Tap "Try Again" (on error) | Return to default |
| Tap "Enter Manually" | Navigate to E20 |

Image Validation
Accepted formats: JPG, PNG, HEIC
Max file size: 10MB
Min resolution: 1024×768
Auto-compress: If >5MB, compress before upload
API Calls
Primary:
POST /api/v1/purchases/receipt
Request: multipart/form-data with image file
Respons:
{
  "purchase_id": "uuid",
  "receipt_image_url": "https://supabase.../receipt.jpg",
  "ocr_status": "ocr_processing"
}

GET /api/v1/purchases/{id}/ocr-status
Response:
{
  "ocr_status": "needs_review",
  "extracted_items": [
    {
      "ocr_text": "GV LG EGGS 18CT",
      "suggested_name": "Eggs (18 ct)",
      "quantity": 1,
      "unit": "carton",
      "price": 5.99,
      "confidence": 0.85,
      "matched_product_id": "uuid"
    }
  ],
  "ocr_raw_result": {...},
  "ocr_confidence_score": 0.82
}
Error States:
| Error | Message | Action |
| ------- | ------- | ------- |
| File too large | "File must be under 10MB" | Auto-compress or prompt to resize |
| Unsupported format | "Supported formats: JPG, PNG, HEIC" | Show supported formats |
| Image too blurry | "Image is unclear. Try another photo." | Prompt to retake |
| OCR failed | "Couldn't read receipt. Try again or enter manually." | Show retry + manual entry |
| Upload failed | "Upload failed. Check connection." | Retry button |
| OCR timeout (>60s) | "Processing taking too long. Try again later." | Retry or fallback to manual |

Accessibility
Camera and gallery buttons have tap targets min 48x48px
Image preview is zoomable
Processing state announced by screen reader: "Processing receipt. This may take 10 to 30 seconds."
Error states announced clearly with retry option




E22: OCR Review (Receipt Items) ⭐ CRITICAL
Screen ID: E22
User Stories: US-33
Priority: 🔴 P0
Route: /step4/purchase/ocr-review
Purpose
This is the most critical screen in the entire app. Users review and correct OCR-extracted items before saving. Without this screen, drift analysis data would be garbage. This screen ensures data quality for the core differentiator.
Key Architectural Decisions Covered
(OCR Pipeline): Stage 3 of 4-stage pipeline (needs_review)
(Step 4 is Core): Data quality is paramount
(Open Food Facts): Product matching uses catalog
User Flow
OCR completes with ocr_status = 'needs_review'
System displays extracted items with confidence scores
User reviews each item:
High confidence (≥0.85): green indicator, auto-matched
Medium confidence (0.7-0.85): yellow indicator, may need review
Low confidence (<0.7): red indicator, requires manual verification
User can edit: name, quantity, price
User can delete items (swipe left)
User can add items OCR missed
Unrecognized items (not in catalog) → link to E23
User taps "Confirm" → system saves to purchase_items
System updates ocr_status = 'confirmed'
System triggers matching (UC-31) and drift analysis (EP-11)
Redirect to E25 (Drift Dashboard)
States
State 1: Default (items extracted)
┌─────────────────────────────┐
│  Review Receipt        [×]  │
├─────────────────────────────┤
│                             │
│  [Receipt thumbnail]        │
│                             │
│  12 items extracted         │
│  Avg confidence: 82%        │
│                             │
│  ┌───────────────────────┐ │
│  │ 🟢 Eggs (18 ct)       │ │
│  │    1 carton · $5.99   │ │
│  │    [Edit]             │ │
│  └───────────────────────┘ │
│                             │
│  ┌───────────────────────┐ │
│  │ 🟢 Greek yogurt       │ │
│  │    1 tub · $6.49      │ │
│  │    [Edit]             │ │
│  └───────────────────────┘ │
│                             │
│  ┌───────────────────────┐ │
│  │ 🟡 GV LG EGGS 18CT    │ │
│  │    → Eggs (18 ct)     │ │
│  │    1 carton · $5.99   │ │
│  │    [Edit] [Verify]    │ │
│  └───────────────────────┘ │
│                             │
│  ┌───────────────────────┐ │
│  │ 🔴 XYZ123ABC          │ │
│  │    Unrecognized       │ │
│  │    [Search] [Skip]    │ │
│  └───────────────────────┘ │
│                             │
│  ⚠️ 3 unrecognized items   │
│  [ Review Unrecognized ]   │
│                             │
│  [ + Add Item ]             │
│                             │
│  [ Confirm & See Drift ]    │
│                             │
└─────────────────────────────┘
State 2: Editing item
┌─────────────────────────────┐
│  Review Receipt        [×]  │
├─────────────────────────────┤
│                             │
│  [items list...]            │
│                             │
│  ┌───────────────────────┐ │
│  │ 🟡 GV LG EGGS 18CT    │ │
│  │                       │ │
│  │  Product name         │ │
│  │  ┌─────────────────┐  │ │
│  │  │ Eggs (18 ct)    │  │ │
│  │  └─────────────────┘  │ │
│  │                       │ │
│  │  Quantity    Unit     │ │
│  │  ┌────────┐ ┌──────┐  │ │
│  │  │ 1      │ │ct ▼  │  │ │
│  │  └────────┘ └──────┘  │ │
│  │                       │ │
│  │  Price                │ │
│  │  ┌─────────────────┐  │ │
│  │  │ $5.99           │  │ │
│  │  └─────────────────┘  │ │
│  │                       │ │
│  │  [Save] [Cancel]      │ │
│  └───────────────────────┘ │
│                             │
└─────────────────────────────┘
State 3: Low confidence warning
┌─────────────────────────────┐
│  Review Receipt        [×]  │
├─────────────────────────────┤
│                             │
│  ⚠️ Low confidence items    │
│  Please verify these items  │
│                             │
│  ┌───────────────────────┐ │
│  │ 🔴 [Blurred text]     │ │
│  │    → Chicken breast?  │ │
│  │    2 lbs · $12.99     │ │
│  │    ⚠️ Confidence: 45% │ │
│  │    [Verify] [Edit]    │ │
│  └───────────────────────┘ │
│                             │
└─────────────────────────────┘
State 4: All items confirmed
┌─────────────────────────────┐
│  Review Receipt        [×]  │
├─────────────────────────────┤
│                             │
│  ✅ All items reviewed      │
│  12 items · $138.50         │
│                             │
│  [ Confirm & See Drift ]    │
│                             │
└─────────────────────────────┘
UI Elements
Header:
Title: "Review Receipt"
Close button (×)
Receipt Thumbnail:
Small preview of uploaded receipt
Tap to view full-size
Summary Bar:
"X items extracted"
"Avg confidence: Y%"
Color-coded by average confidence
Item List:
Each item card contains:
Confidence indicator:
🟢 High (≥0.85): green dot
🟡 Medium (0.7-0.85): yellow dot
🔴 Low (<0.7): red dot + warning
Product name (editable)
If OCR text differs from matched product: show both (e.g., "GV LG EGGS 18CT → Eggs (18 ct)")
Quantity (editable)
Unit (editable dropdown)
Price (editable, optional)
Actions:
[Edit] — open inline edit mode
[Verify] — mark as verified (for low-confidence items)
Swipe left → delete
Unrecognized Items Section (conditional):
"⚠️ X unrecognized items"
"Review Unrecognized" button → navigate to E23
Add Item Button:
"+ Add Item" — for items OCR missed
Confirm Button:
"Confirm & See Drift" (primary)
Disabled if low-confidence items not verified
Interactions:
| Action | Result |
| ------- | ------- |
| Tap item card | Open inline edit mode |
| Tap [Edit] | Open edit mode for that item |
| Tap [Verify] | Mark item as verified (removes warning) |
| Swipe item left | Show delete button |
| Tap "Review Unrecognized" | Navigate to E23 |
| Tap "+ Add Item" | Open add item form (same as E20) |
| Tap "Confirm & See Drift" | Save, trigger matching, navigate to E25 |
| Tap "×" | Discard changes, navigate back |

Confidence Scoring:
| Confidence | Indicator | User Action Required |
| ------- | ------- | ------- |
| ≥0.85 | 🟢 Green | Optional review |
| 0.7-0.85 | 🟡 Yellow | Recommended review |
| <0.7 | 🔴 Red | Required verification |

Verification flow:
User taps [Verify] on low-confidence item
System marks item as verified = true
Warning indicator removed
Item can be saved without further review
API Calls
Primary:
GET /api/v1/purchases/{id}/ocr-review
Response:
{
  "purchase_id": "uuid",
  "receipt_image_url": "https://...",
  "ocr_status": "needs_review",
  "ocr_confidence_score": 0.82,
  "items": [
    {
      "item_id": "uuid",
      "ocr_text": "GV LG EGGS 18CT",
      "suggested_name": "Eggs (18 ct)",
      "product_catalog_id": "uuid",
      "quantity": 1,
      "unit": "carton",
      "price": 5.99,
      "confidence": 0.85,
      "match_status": "auto_matched",
      "verified": false
    },
    {
      "item_id": "uuid",
      "ocr_text": "XYZ123ABC",
      "suggested_name": null,
      "product_catalog_id": null,
      "quantity": null,
      "unit": null,
      "price": null,
      "confidence": 0.35,
      "match_status": "unrecognized",
      "verified": false
    }
  ]
}
PUT /api/v1/purchases/{id}/items/{item_id}
Request:
{
  "product_name": "Eggs (18 ct)",
  "product_catalog_id": "uuid",
  "quantity": 1,
  "unit": "carton",
  "price": 5.99,
  "verified": true
}

POST /api/v1/purchases/{id}/confirm
Response:
{
  "purchase_id": "uuid",
  "ocr_status": "confirmed",
  "items_count": 12,
  "items_matched": 10,
  "items_drift": 2
}

Error States:
| Error | Message | Action |
| ------- | ------- | ------- |
| Low confidence not verified | "Please verify low-confidence items before confirming" | Highlight unverified items |
| Save failed | "Failed to save. Please try again." | Retry button |
| Network error | "Check your connection and try again" | Retry button |
| OCR result expired | "OCR result expired. Please re-upload receipt." | Redirect to E21 |

Accessibility
Confidence indicators announced: "High confidence", "Medium confidence — review recommended", "Low confidence — verification required"
Edit mode is focus-trapped
Screen reader announces: "Eggs, 18 count, 1 carton, $5.99. High confidence. Tap to edit."
Unrecognized items count announced: "3 unrecognized items. Tap to review."



E23: Unrecognized Items
Screen ID: E23
User Stories: US-34
Priority: 🔴 P0
Route: /step4/purchase/unrecognized
Purpose
Handle items OCR extracted but couldn't match to products_catalog. User can search manually, skip, or mark as "Other".
User Flow
User taps "Review Unrecognized" on E22
System displays list of unrecognized items
For each item, user can:
Search: Type to search in products_catalog → select match
Skip: Item not saved to purchase_items
Mark as "Other": Saved with generic description
User taps "Done" → return to E22
All items handled
States
State 1: Default
┌─────────────────────────────┐
│  Unrecognized Items    [×]  │
├─────────────────────────────┤
│                             │
│  3 items couldn't be        │
│  matched automatically      │
│                             │
│  ┌───────────────────────┐ │
│  │ OCR: "XYZ123ABC"      │ │
│  │                       │ │
│  │ [ 🔍 Search ]         │ │
│  │ [ Skip ]              │ │
│  │ [ Mark as Other ]     │ │
│  └───────────────────────┘ │
│                             │
│  ┌───────────────────────┐ │
│  │ OCR: "BRND MILK 1G"   │ │
│  │                       │ │
│  │ [ 🔍 Search ]         │ │
│  │ [ Skip ]              │ │
│  │ [ Mark as Other ]     │ │
│  └───────────────────────┘ │
│                             │
│  ┌───────────────────────┐ │
│  │ OCR: "???"            │ │
│  │                       │ │
│  │ [ 🔍 Search ]         │ │
│  │ [ Skip ]              │ │
│  │ [ Mark as Other ]     │ │
│  └───────────────────────┘ │
│                             │
│  [ Done ]                   │
│                             │
└─────────────────────────────┘
State 2: Search mode
┌─────────────────────────────┐
│  Unrecognized Items    [×]  │
├─────────────────────────────┤
│                             │
│  OCR: "XYZ123ABC"           │
│                             │
│  Search in catalog:         │
│  ┌───────────────────────┐ │
│  │ 🔍 milk               │ │
│  └───────────────────────┘ │
│  ┌───────────────────────┐ │
│  │ 🥛 Whole milk (1 gal) │ │
│  │    $4.99              │ │
│  ├───────────────────────┤ │
│  │ 🥛 2% milk (1 gal)    │ │
│  │    $4.49              │ │
│  ├───────────────────────┤ │
│  │ 🥛 Organic milk (1gal)│ │
│  │    $6.99              │ │
│  └───────────────────────┘ │
│                             │
│  [ Cancel Search ]          │
│                             │
└─────────────────────────────┘
State 3: Mark as "Other"
┌─────────────────────────────┐
│  Unrecognized Items    [×]  │
├─────────────────────────────┤
│                             │
│  OCR: "XYZ123ABC"           │
│                             │
│  Describe this item:        │
│  ┌───────────────────────┐ │
│  │ Unknown item          │ │
│  └───────────────────────┘ │
│                             │
│  Quantity    Unit           │
│  ┌────────┐  ┌──────────┐  │
│  │ 1      │  │ pcs ▼    │  │
│  └────────┘  └──────────┘  │
│                             │
│  Price (optional)           │
│  ┌───────────────────────┐ │
│  │ $                     │ │
│  └───────────────────────┘ │
│                             │
│  [ Save as Other ]          │
│  [ Cancel ]                 │
│                             │
└─────────────────────────────┘
State 4: All items handled
┌─────────────────────────────┐
│  Unrecognized Items    [×]  │
├─────────────────────────────┤
│                             │
│  ✅ All items handled       │
│                             │
│  • 2 matched                │
│  • 1 marked as Other        │
│  • 0 skipped                │
│                             │
│  [ Done ]                   │
│                             │
└─────────────────────────────┘
UI Elements
Header:
Title: "Unrecognized Items"
Close button (×)
Intro Text:
"X items couldn't be matched automatically"
Item Cards (for each unrecognized item):
OCR text (original)
Three action buttons:
🔍 Search — open search mode
Skip — item not saved
Mark as Other — open "Other" form
Search Mode:
Search input with autocomplete
Results list (from products_catalog)
"Cancel Search" button
"Mark as Other" Form:
Description input (pre-filled with OCR text)
Quantity + unit inputs
Price input (optional)
"Save as Other" button
"Cancel" button
Summary (after all handled):
Counts: matched, marked as Other, skipped
"Done" button
Interactions:
| Action | Result |
| ------- | ------- |
| Tap 🔍 Search | Open search mode |
| Type in search | Show autocomplete suggestions |
| Tap suggestion | Match item, mark as handled |
| Tap Skip | Mark item as skipped |
| Tap "Mark as Other" | Open "Other" form |
| Tap "Save as Other" | Save with generic description |
| Tap "Done" | Return to E22 |
API Calls
Primary:
GET /api/v1/products/search?q={query}&limit=5 (same as E20)
PUT /api/v1/purchases/{id}/items/{item_id}/handle
Request:
{
  "action": "match" | "skip" | "other",
  "product_catalog_id": "uuid",  // if match
  "description": "Unknown item",  // if other
  "quantity": 1,
  "unit": "pcs",
  "price": null
}

Error States:
Error
Message
Action
No search results
"No matches found. Try different keywords or mark as Other."
Show "Mark as Other" option
Save failed
"Failed to save. Please try again."
Retry button
Accessibility
Search is keyboard-navigable
Each action button has clear label
Screen reader announces: "OCR text: XYZ123ABC. Search, Skip, or Mark as Other."


E24: Purchase Summary
Screen ID: E24
User Stories: US-32
Priority: 🔴 P0
Route: /step4/purchases/{id}
Purpose
View a specific purchase with items grouped by match status (matched / drift / excluded / no_match). This is the detailed view after capture.
User Flow
User taps a purchase from E19 (recent list) or E25 (drift dashboard)
System displays purchase summary
Items grouped by match status
User taps item → see details
States
State 1: Default
┌─────────────────────────────┐
│  Purchase Summary           │
│  Jun 25, 2026               │
├─────────────────────────────┤
│                             │
│  87% match · 18 items       │
│  $138.50                    │
│                             │
│  ✓ Matched (15)             │
│  ┌───────────────────────┐ │
│  │ 🥚 Eggs (18 ct)       │ │
│  │ 🥛 Greek yogurt       │ │
│  │ 🐟 Wild salmon        │ │
│  │ ...                   │ │
│  └───────────────────────┘ │
│                             │
│  ⚠️ Drift (2)               │
│  ┌───────────────────────┐ │
│  │ 🍞 White bread        │ │
│  │    (rec: Whole grain) │ │
│  │ 🍪 Cookies            │ │
│  │    (not recommended)  │ │
│  └───────────────────────┘ │
│                             │
│  ✗ Excluded (1)             │
│  ┌───────────────────────┐ │
│  │ 🥤 Soda               │ │
│  │    (excluded for P5)  │ │
│  └───────────────────────┘ │
│                             │
│  ? No match (0)             │
│                             │
│  [ View Drift Analysis ]    │
│                             │
└─────────────────────────────┘
State 2: Item detail (expanded)
┌─────────────────────────────┐
│  Purchase Summary           │
├─────────────────────────────┤
│                             │
│  ⚠️ Drift (2)               │
│  ┌───────────────────────┐ │
│  │ 🍞 White bread        │ │
│  │    Status: Drift      │ │
│  │    Qty: 1 loaf        │ │
│  │    Price: $3.50       │ │
│  │                       │ │
│  │    Recommended:       │ │
│  │    Whole grain bread  │ │
│  │                       │ │
│  │    Why: Profile 5     │ │
│  │    prioritizes slow   │ │
│  │    carbs over refined │ │
│  └───────────────────────┘ │
│                             │
└─────────────────────────────┘
UI Elements
Header:
Title: "Purchase Summary"
Date
Summary Bar:
Match percentage (large)
Item count
Total spent
Sections (grouped by match status):
✓ Matched (green) — count + item list
⚠️ Drift (yellow) — count + item list with "recommended vs actual"
✗ Excluded (red) — count + item list with exclusion reason
? No match (gray) — count + item list
Item Cards:
Emoji icon
Product name
Status indicator
Quantity + unit + price
Tap to expand → show details
Details (expanded):
Recommended item (if drift)
Explanation (why drift / why excluded)
Profile context
Buttons:
"View Drift Analysis" → navigate to E25
Interactions:
| Action | Result |
| ------- | ------- |
| Tap item card | Expand to show details |
| Tap "View Drift Analysis" | Navigate to E25 |
API Calls
Primary:
GET /api/v1/purchases/{id}
Response:
{
  "purchase_id": "uuid",
  "purchase_date": "2026-06-25",
  "capture_method": "receipt_photo",
  "total_items": 18,
  "total_spent": 138.50,
  "match_percentage": 87.0,
  "items_by_status": {
    "matched": [
      {
        "item_id": "uuid",
        "product_name": "Eggs (18 ct)",
        "quantity": 1,
        "unit": "carton",
        "price": 5.99,
        "matched_cart_item_id": "uuid"
      }
    ],
    "drift": [
      {
        "item_id": "uuid",
        "product_name": "White bread",
        "quantity": 1,
        "unit": "loaf",
        "price": 3.50,
        "recommended_item": "Whole grain bread",
        "explanation": "Profile 5 prioritizes slow carbs over refined"
      }
    ],
    "excluded": [...],
    "no_match": [...]
  }
}
Accessibility
Sections announced as headings
Match status announced: "Matched", "Drift", "Excluded", "No match"
Screen reader announces: "White bread, drift. Recommended: whole grain bread. Profile 5 prioritizes slow carbs over refined."



E25: Drift Dashboard ⭐ CORE
Screen ID: E25
User Stories: US-38, US-39
Priority: 🔴 P0
Route: /step4/drift
Purpose
This is the crown jewel of MetaCart. The drift dashboard shows how far the user's actual food environment deviates from recommendations over time. This is the passive health signal that makes MetaCart unique.
Key Architectural Decisions Covered
(Step 4 is Core): This screen must work perfectly
(grocery_stability_score): Formula TBD (open question)
Proprietary Score: This is the foundation of "Grocery Stability Score"
User Flow
User navigates to Drift Dashboard (from home or after purchase capture)
System displays current week's match percentage
Weekly trend chart shown (W1, W2, W3, W4)
Top drifts listed
Feedback message based on trend
User taps week → navigate to E26 (Drift Details)
User taps "Trends" tab → navigate to E27 (Drift Trends)
User taps "Insights" tab → navigate to E28 (Drift Insights)
States
State 1: Default (multiple weeks of data)
┌─────────────────────────────┐
│  Environment Drift          │
├─────────────────────────────┤
│                             │
│  This week                  │
│  ┌───────────────────────┐ │
│  │                       │ │
│  │        87%            │ │
│  │        match          │ │
│  │                       │ │
│  │  ↑ 12% vs last week   │ │
│  │                       │ │
│  │  ━━━━━━━━━━━░░░░░░░░  │ │
│  │                       │ │
│  └───────────────────────┘ │
│                             │
│  Weekly trend               │
│  ┌──┬──┬──┬──┐            │
│  │▓▓│▓▓│▓▓│▓▓│            │
│  │65│75│80│87│            │
│  └──┴──┴──┴──┘            │
│   W1 W2 W3 W4              │
│                             │
│  Top drifts this week       │
│  ┌───────────────────────┐ │
│  │ 🍞 Refined grains +3  │ │
│  │ 🥬 Leafy greens   -2  │ │
│  │ 🍪 Sugary snacks  +2  │ │
│  └───────────────────────┘ │
│                             │
│  💡 Your environment is     │
│  stabilizing. Keep it up!   │
│                             │
│  [ Home ] [ Cart ] [Drift]  │
│  [ Profile ]                │
│                             │
└─────────────────────────────┘
State 2: Empty state (no purchases yet)
┌─────────────────────────────┐
│  Environment Drift          │
├─────────────────────────────┤
│                             │
│  📭 No drift data yet       │
│                             │
│  Capture your first         │
│  purchase to see how your   │
│  actual groceries compare   │
│  to recommendations.        │
│                             │
│  [ Capture Purchase ]       │
│                             │
└─────────────────────────────┘
State 3: Improved trend (celebration)
┌─────────────────────────────┐
│  Environment Drift          │
├─────────────────────────────┤
│                             │
│  This week                  │
│  ┌───────────────────────┐ │
│  │                       │ │
│  │        92%            │ │
│  │        match          │ │
│  │                       │ │
│  │  🎉 Best week yet!    │ │
│  │                       │ │
│  └───────────────────────┘ │
│                             │
│  [trend chart...]           │
│                             │
│  🎊 Great progress!         │
│  Your food environment is   │
│  becoming more supportive   │
│  of your health.            │
│                             │
└─────────────────────────────┘
State 4: Declined trend (supportive message)
┌─────────────────────────────┐
│  Environment Drift          │
├─────────────────────────────┤
│                             │
│  This week                  │
│  ┌───────────────────────┐ │
│  │                       │ │
│  │        65%            │ │
│  │        match          │ │
│  │                       │ │
│  │  ↓ 15% vs last week   │ │
│  │                       │ │
│  └───────────────────────┘ │
│                             │
│  [trend chart...]           │
│                             │
│  💙 It's okay to have off   │
│  weeks. Let's get back on   │
│  track together.            │
│                             │
│  [ View Details ]           │
│                             │
└─────────────────────────────┘
State 5: Single week of data
┌─────────────────────────────┐
│  Environment Drift          │
├─────────────────────────────┤
│                             │
│  This week                  │
│  ┌───────────────────────┐ │
│  │        87%            │ │
│  │        match          │ │
│  └───────────────────────┘ │
│                             │
│  Weekly trend               │
│  ┌──┐                      │
│  │▓▓│  ← only 1 week       │
│  │87│                      │
│  └──┘                      │
│   W1                       │
│                             │
│  💡 Capture more purchases  │
│  to see trends over time    │
│                             │
└─────────────────────────────┘
UI Elements
Header:
Title: "Environment Drift"
Current Week Card (hero section):
Large match percentage (e.g., "87%")
"match" label
Trend indicator: "↑ 12% vs last week" / "↓ 15% vs last week"
Progress bar (visual representation)
Conditional message:
Improved: "🎉 Best week yet!"
Declined: "💙 It's okay to have off weeks"
Stable: "💡 Your environment is stabilizing"
Weekly Trend Chart:
Bar chart with 4 weeks (W1, W2, W3, W4)
Color-coded bars:
🟢 ≥80% match
🟡 60-79% match
🔴 <60% match
Tap bar → navigate to E26 (Drift Details for that week)
Top Drifts Section:
List of top 3-5 drift categories
Each entry: emoji + category + count (+3 / -2)
Color-coded:
Negative drifts (red): refined grains, sugary snacks
Missing recommended (yellow): leafy greens, proteins
Feedback Message:
Contextual message based on trend
Celebratory for improvement
Supportive for decline
Encouraging for stability
Tab Bar (bottom navigation):
Home
Cart
Drift (active)
Profile
Interactions:
| Action | Result |
| ------- | ------- |
| Tap week bar in chart | Navigate to E26 (Drift Details for that week) |
| Tap "View Details" | Navigate to E26 (current week) |
| Tap "Capture Purchase" (empty state) | Navigate to E19 |
| Pull-to-refresh | Reload drift data |
API Calls
Primary:
GET /api/v1/drift/dashboard
Response:
{
  "current_week": {
    "week_number": 4,
    "match_percentage": 87.0,
    "drift_percentage": 13.0,
    "grocery_stability_score": 85.5,
    "total_items_recommended": 20,
    "total_items_matched": 17,
    "total_items_drift": 3,
    "change_from_last_week": 12.0,
    "trend": "improved"
  },
  "weekly_trend": [
    {"week": 1, "match_percentage": 65.0},
    {"week": 2, "match_percentage": 75.0},
    {"week": 3, "match_percentage": 80.0},
    {"week": 4, "match_percentage": 87.0}
  ],
  "top_drifts": [
    {"category": "refined_grains", "count": 3, "direction": "added"},
    {"category": "leafy_greens", "count": -2, "direction": "missing"},
    {"category": "sugary_snacks", "count": 2, "direction": "added"}
  ],
  "feedback_message": "Your environment is stabilizing. Keep it up!",
  "feedback_type": "encouraging"
}
Error States
| Error | Message | Action |
| ------- | ------- | ------- |
| No drift data | "No drift data yet. Capture your first purchase." | Show "Capture Purchase" button |
| Network error | "Check your connection and try again" | Retry button |
Accessibility
Match percentage announced prominently: "87 percent match"
Trend announced: "Up 12 percent versus last week"
Chart bars are keyboard-navigable
Screen reader announces: "Week 1, 65 percent. Week 2, 75 percent. Week 3, 80 percent. Week 4, 87 percent."
Feedback message announced with appropriate tone



E26: Drift Details (Weekly)
Screen ID: E26
User Stories: US-40
Priority: 🔴 P0
Route: /step4/drift/week/{week_number}
Purpose
Detailed drift analysis for a specific week. Shows all items grouped by match status with explanations.
User Flow
User taps a week bar on E25 (Drift Dashboard)
System displays detailed view for that week
Items grouped: Matched / Drift / Excluded / Missing
User taps item → see explanation
User can navigate to other weeks
States
State 1: Default
┌─────────────────────────────┐
│  Week 4 Details        [×]  │
│  Jun 22-28, 2026            │
├─────────────────────────────┤
│                             │
│  ← W3    W4    W5 →        │
│                             │
│  87% match · 20 items       │
│                             │
│  ✓ Matched (17)             │
│  ┌───────────────────────┐ │
│  │ 🥚 Eggs (18 ct)       │ │
│  │ 🥛 Greek yogurt       │ │
│  │ 🐟 Wild salmon        │ │
│  │ 🥑 Avocados           │ │
│  │ ... (13 more)         │ │
│  └───────────────────────┘ │
│                             │
│  ⚠️ Drift (2)               │
│  ┌───────────────────────┐ │
│  │ 🍞 White bread        │ │
│  │    → Rec: Whole grain │ │
│  │ 🍪 Cookies            │ │
│  │    → Not recommended  │ │
│  └───────────────────────┘ │
│                             │
│  ✗ Excluded (1)             │
│  ┌───────────────────────┐ │
│  │ 🥤 Soda               │ │
│  │    Excluded for P5    │ │
│  └───────────────────────┘ │
│                             │
│  📭 Missing (3)             │
│  ┌───────────────────────┐ │
│  │ 🥬 Spinach            │ │
│  │    Recommended but    │ │
│  │    not purchased      │ │
│  │ 🐟 Salmon (2nd pack)  │ │
│  │ ... (1 more)          │ │
│  └───────────────────────┘ │
│                             │
└─────────────────────────────┘
State 2: Item expanded
┌─────────────────────────────┐
│  Week 4 Details        [×]  │
├─────────────────────────────┤
│                             │
│  ⚠️ Drift (2)               │
│  ┌───────────────────────┐ │
│  │ 🍞 White bread        │ │
│  │                       │ │
│  │  You bought:          │ │
│  │  White bread (1 loaf) │ │
│  │  $3.50                │ │
│  │                       │ │
│  │  Recommended:         │ │
│  │  Whole grain bread    │ │
│  │                       │ │
│  │  Why it matters:      │ │
│  │  Profile 5 prioritizes│ │
│  │  slow-digesting carbs │ │
│  │  to stabilize glucose │ │
│  │  curve. White bread   │ │
│  │  causes rapid spikes. │ │
│  │                       │ │
│  │  Suggestion:          │ │
│  │  Next week, try whole │ │
│  │  grain or sourdough   │ │
│  │  bread instead.       │ │
│  └───────────────────────┘ │
│                             │
└─────────────────────────────┘
UI Elements
Header:
Title: "Week X Details"
Date range
Close button (×)
Week Navigator:
Horizontal: ← W3 | W4 | W5 →
Current week highlighted
Tap to navigate
Summary Bar:
Match percentage
Item count
Sections:
✓ Matched (green) — items user bought that were recommended
⚠️ Drift (yellow) — items user bought instead of recommended
✗ Excluded (red) — items user bought that are excluded for their profile
📭 Missing (gray) — items recommended but not purchased
Item Cards:
Emoji icon
Product name
Tap to expand → show details
Expanded Details:
"You bought" vs "Recommended"
Price
"Why it matters" explanation (profile-specific)
"Suggestion" for next time
Interactions:
| Action | Result |
| ------- | ------- |
| Tap week in navigator | Navigate to that week |
| Tap item card | Expand to show details |
| Tap "×" | Return to E25 |
API Calls
Primary:
GET /api/v1/drift/week/{week_number}
Response:
{
  "week_number": 4,
  "date_range": {"start": "2026-06-22", "end": "2026-06-28"},
  "match_percentage": 87.0,
  "total_items": 20,
  "items": {
    "matched": [...],
    "drift": [
      {
        "product_name": "White bread",
        "quantity": 1,
        "unit": "loaf",
        "price": 3.50,
        "recommended_item": "Whole grain bread",
        "explanation": "Profile 5 prioritizes slow-digesting carbs to stabilize glucose curve. White bread causes rapid spikes.",
        "suggestion": "Next week, try whole grain or sourdough bread instead."
      }
    ],
    "excluded": [
      {
        "product_name": "Soda",
        "quantity": 2,
        "unit": "cans",
        "price": 3.00,
        "exclusion_reason": "Excluded for Profile 5 — sugary beverages cause glucose instability"
      }
    ],
    "missing": [
      {
        "product_name": "Spinach",
        "recommended_quantity": 2,
        "unit": "bags",
        "estimated_price": 7.98,
        "importance": "high"
      }
    ]
  }
}
Accessibility
Week navigator is keyboard-navigable
Item details announced clearly
Screen reader announces: "White bread, drift. You bought white bread, 1 loaf, $3.50. Recommended: whole grain bread. Profile 5 prioritizes slow-digesting carbs."



E27: Drift Trends
Screen ID: E27
User Stories: US-41
Priority: 🟡 P1
Route: /step4/drift/trends
Purpose
Long-term drift trends over multiple weeks. Shows line chart, average score, best/worst weeks.
User Flow
User taps "Trends" tab on E25
System displays long-term trend chart
Stats shown: average, best week, worst week
User can zoom in/out
States
State 1: Default (multiple weeks)
┌─────────────────────────────┐
│  Drift Trends               │
├─────────────────────────────┤
│                             │
│  Match percentage over time │
│                             │
│  100% ──────────────────    │
│   90% ─ ─ ─ ─ ─ ─ ─ ─ ─   │
│   80% ────────╭───────╮    │
│   70% ───╮   ╱         ╲   │
│   60% ───╰──╯           ╰── │
│   50% ──────────────────    │
│      W1  W2  W3  W4  W5    │
│                             │
│  📊 Statistics              │
│  ┌───────────────────────┐ │
│  │ Average: 78%          │ │
│  │ Best week: W5 (92%)   │ │
│  │ Worst week: W1 (65%)  │ │
│  │ Trend: ↗ Improving    │ │
│  └───────────────────────┘ │
│                             │
│  [ Home ] [ Cart ] [Drift]  │
│  [ Profile ]                │
│                             │
└─────────────────────────────┘
State 2: Single week
┌─────────────────────────────┐
│  Drift Trends               │
├─────────────────────────────┤
│                             │
│  Not enough data for trends │
│                             │
│  You have 1 week of data.   │
│  Capture more purchases to  │
│  see trends over time.      │
│                             │
│  Current week: 87%          │
│                             │
│  [ Back to Dashboard ]      │
│                             │
└─────────────────────────────┘
UI Elements
Header:
Title: "Drift Trends"
Line Chart:
X-axis: weeks (W1, W2, W3, ...)
Y-axis: match percentage (0-100%)
Line with data points
Color-coded segments (green/yellow/red)
Statistics Card:
Average match percentage
Best week (highest match)
Worst week (lowest match)
Overall trend (improving / stable / declining)
Buttons:
"Back to Dashboard" (if single week)
Interactions:
| Action | Result |
| ------- | ------- |
| Tap data point | Show tooltip with week details |
| Pinch to zoom | Zoom in/out on chart |
| Tap "Back to Dashboard" | Navigate to E25 |
API Calls
Primary:
GET /api/v1/drift/trends
Response:
{
  "weeks": [
    {"week": 1, "match_percentage": 65.0},
    {"week": 2, "match_percentage": 75.0},
    {"week": 3, "match_percentage": 80.0},
    {"week": 4, "match_percentage": 87.0},
    {"week": 5, "match_percentage": 92.0}
  ],
  "statistics": {
    "average": 78.0,
    "best_week": {"week": 5, "match_percentage": 92.0},
    "worst_week": {"week": 1, "match_percentage": 65.0},
    "trend": "improving"
  }
}
Accessibility
Chart is keyboard-navigable (arrow keys to move between data points)
Data points announced: "Week 1, 65 percent. Week 2, 75 percent."
Statistics announced clearly



E28: Drift Insights
Screen ID: E28
User Stories: US-42
Priority: 🟡 P1
Route: /step4/drift/insights
Purpose
Actionable insights about drift patterns. Analyzes user behavior and provides personalized suggestions.
User Flow
User taps "Insights" tab on E25
System displays pattern analysis
Insights shown: common drifts, categories, recovery patterns
Actionable suggestions provided
States
State 1: Default (patterns detected)
┌─────────────────────────────┐
│  Drift Insights             │
├─────────────────────────────┤
│                             │
│  🔍 Your patterns           │
│                             │
│  Most common drifts         │
│  ┌───────────────────────┐ │
│  │ 🍞 White bread        │ │
│  │    4 out of 5 weeks   │ │
│  │    → Try sourdough    │ │
│  ├───────────────────────┤ │
│  │ 🍪 Cookies            │ │
│  │    3 out of 5 weeks   │ │
│  │    → Try dark choc.   │ │
│  └───────────────────────┘ │
│                             │
│  Categories with most drift │
│  ┌───────────────────────┐ │
│  │ 🍞 Refined grains     │ │
│  │    40% of drifts      │ │
│  ├───────────────────────┤ │
│  │ 🍬 Sugary snacks      │ │
│  │    30% of drifts      │ │
│  └───────────────────────┘ │
│                             │
│  Recovery patterns          │
│  ┌───────────────────────┐ │
│  │ 📅 Weekends           │ │
│  │    Drift tends to     │ │
│  │    increase on Sat/Sun│ │
│  │    → Plan ahead!      │ │
│  └───────────────────────┘ │
│                             │
│  💡 Suggestions             │
│  ┌───────────────────────┐ │
│  │ • Try whole grain or  │ │
│  │   sourdough bread     │ │
│  │ • Keep dark chocolate │ │
│  │   (70%+) as snack     │ │
│  │ • Prep healthy snacks │ │
│  │   before weekend      │ │
│  └───────────────────────┘ │
│                             │
└─────────────────────────────┘
State 2: Not enough data
┌─────────────────────────────┐
│  Drift Insights             │
├─────────────────────────────┤
│                             │
│  📝 Not enough data yet     │
│                             │
│  Keep tracking to see       │
│  patterns emerge.           │
│                             │
│  You need at least 3 weeks  │
│  of data for insights.      │
│                             │
│  Current: 1 week            │
│                             │
│  [ Back to Dashboard ]      │
│                             │
└─────────────────────────────┘
UI Elements
Header:
Title: "Drift Insights"
Sections:
🔍 "Your patterns" — overall summary
"Most common drifts" — top 3-5 items with frequency
"Categories with most drift" — category breakdown
"Recovery patterns" — temporal patterns (weekends, holidays, etc.)
💡 "Suggestions" — actionable recommendations
Insight Cards:
Emoji icon
Pattern description
Frequency or percentage
Actionable suggestion
Interactions

| Action | Result |
| ------- | ------- |
| Tap insight card | Expand for more details |
| Tap "Back to Dashboard" | Navigate to E25 |API Calls
Primary:
GET /api/v1/drift/insights
Response:
{
  "patterns": {
    "most_common_drifts": [
      {
        "product_name": "White bread",
        "frequency": "4 out of 5 weeks",
        "suggestion": "Try sourdough"
      }
    ],
    "categories": [
      {"category": "refined_grains", "percentage": 40},
      {"category": "sugary_snacks", "percentage": 30}
    ],
    "temporal_patterns": [
      {
        "pattern": "Weekends",
        "description": "Drift tends to increase on Sat/Sun",
        "suggestion": "Plan ahead!"
      }
    ]
  },
  "suggestions": [
    "Try whole grain or sourdough bread",
    "Keep dark chocolate (70%+) as snack",
    "Prep healthy snacks before weekend"
  ],
  "data_weeks": 5,
  "min_weeks_required": 3
}
Accessibility
Insights announced clearly
Suggestions announced as list
Screen reader announces: "Most common drift: White bread, 4 out of 5 weeks. Suggestion: Try sourdough."



📊 PHASE 4 SUMMARY
| Screen | Priority | User Stories | API Calls | Key ADRs |
| ------- | ------- | ------- | ------- | ------- |
| E19: Purchase Capture (Home) | 🔴 P0 | US-29, US-30 | GET /purchases/recent | 004, 012 |
| E20: Manual Entry | 🔴 P0 | US-29 | POST /purchases/manual | 012, 015 |
| E21: Receipt Upload | 🔴 P0 | US-30 | POST /purchases/receipt | 012 |
| E22: OCR Review ⭐ | 🔴 P0 | US-33 | GET /purchases/{id}/ocr-review, PUT /items/{id}, POST /confirm | 012, 004 |
| E23: Unrecognized Items | 🔴 P0 | US-34 | PUT /items/{id}/handle | 012, 015 |
| E24: Purchase Summary | 🔴 P0 | US-32 | GET /purchases/{id} | 004 |
| E25: Drift Dashboard ⭐ | 🔴 P0 | US-38, US-39 | GET /drift/dashboard | 004, 019 |
| E26: Drift Details | 🔴 P0 | US-40 | GET /drift/week/{n} | 004 |
| E27: Drift Trends | 🟡 P1 | US-41 | GET /drift/trends | 019 |
| E28: Drift Insights | 🟡 P1 | US-42 | GET /drift/insights | 019 |


🔑 CRITICAL UX NOTES FOR PHASE 4
1. E22 (OCR Review) is the Most Important Screen
Without this screen, drift data is garbage. Users MUST be able to correct OCR errors.
Key requirements:
Confidence scoring (🟢/🟡/🔴)
Low-confidence items require verification
Inline editing (no separate screen)
Clear visual distinction between OCR text and matched product
2. Match Status Must Be Transparent
Users need to understand WHY an item is "drift" or "excluded".
Solution:
Every drift item shows "You bought X, recommended Y"
Explanation tied to profile (e.g., "Profile 5 prioritizes slow carbs")
Actionable suggestion for next time
3. Drift Dashboard Must Be Celebratory, Not Shaming
Users may feel guilty about drift. The UX must be supportive, not punitive.
Solution:
Positive language: "Your environment is stabilizing"
Celebrate improvement: "🎉 Best week yet!"
Supportive for decline: "💙 It's okay to have off weeks"
Never use red/shaming colors for low match %
4. grocery_stability_score Formula
This is still an OPEN QUESTION. Proposed formula:
grocery_stability_score = (matched_items / total_recommended_items) × 100

Action needed: Confirm with PI before implementation.
5. OCR Fallback Must Be Seamless
If OCR fails, user must be able to fall back to manual entry without friction.
Solution:
"Enter Manually" link always visible on E21
Pre-fill manual form with any partially-extracted items
Don't lose user's progress
6. Unrecognized Items Handling 
OCR will find items not in products_catalog. User needs clear options.
Solution:
Three clear actions: Search / Skip / Mark as Other
Search uses autocomplete from catalog
"Mark as Other" saves with generic description
Don't block user from confirming if some items are unrecognized
7. Real-Time CGM Notifications
NOT in beta. Screen 4.3 from original wireframes is roadmap only.
Beta supports:
✅ HRV morning alerts (delayed via Apple Health background fetch)
✅ Meal reminders (timer-based)
✅ Post-dinner walk reminders (time-based)
❌ Real-time dG/dt alerts (requires direct CGM API)
8. Data Quality Over Speed
Step 4 is the core differentiator. Data quality is paramount.
Solution:
OCR review screen (E22) is mandatory, not optional
Low-confidence items require verification
Audit trail: ocr_raw_result, ocr_confidence_score stored
User corrections tracked for future OCR improvement


🎯 PHASE 5: RETENTION (3 screens)
This phase is critical for the longitudinal study design. The Beta Spec explicitly states: "Two timepoints per user minimum (baseline + follow-up) — the app must bring users back for a second lab upload; build the reminder/retention loop deliberately."
Without successful retention, we cannot:
Validate profile changes over time 
Test the factorial design 2×2 
Generate the preliminary data needed for NIH SBIR application
E29: Follow-up Reminder (Notification)
Screen ID: E29
User Stories: US-47 (partial)
Priority: 🟡 P1
Route: N/A (push notification, not a screen)
Purpose
Trigger user to upload follow-up labs after baseline + 30 days. This is the retention mechanism that enables longitudinal analysis.
Key Architectural Decisions Covered
(Profile Recalculation): Follow-up labs trigger profile re-evaluation
(Factorial Design 2×2): Requires baseline + follow-up data for all 40 participants
Beta Spec v1.1: "Build the reminder/retention loop deliberately"
User Flow
System detects 30 days since baseline lab upload
System checks if follow-up labs uploaded → if yes, skip
System sends push notification
User taps notification → deep link to E4 (Lab Upload) with timepoint = 'follow_up'
User uploads follow-up labs
System triggers profile recalculation (EP-13)
States
State 1: Push Notification (iOS)
┌─────────────────────────────┐
│  MetaCart              now  │
├─────────────────────────────┤
│  📊 Time for follow-up labs │
│                             │
│  It's been 30 days since    │
│  your baseline. Upload new  │
│  labs to see how your       │
│  profile has changed.       │
│                             │
│  [ Upload Now ]             │
└─────────────────────────────┘
State 2: Push Notification (Android)
┌─────────────────────────────┐
│  MetaCart              now  │
├─────────────────────────────┤
│  📊 Time for follow-up labs │
│  It's been 30 days since    │
│  your baseline. Tap to      │
│  upload new labs.           │
└─────────────────────────────┘
State 3: In-App Banner (if push disabled)
┌─────────────────────────────┐
│  ⏰ Follow-up Reminder       │
│                             │
│  It's been 30 days since    │
│  your baseline labs.        │
│  Upload new labs to see     │
│  how your profile changed.  │
│                             │
│  [ Upload Now ] [ Dismiss ] │
└─────────────────────────────┘
UI Elements
Push Notification:
App icon + name
Title: "Time for follow-up labs"
Body: "It's been 30 days since your baseline. Upload new labs to see how your profile has changed."
Deep link action: "Upload Now"
In-App Banner (fallback):
Icon: ⏰
Title: "Follow-up Reminder"
Body: 30-day message
Two buttons: "Upload Now" (primary), "Dismiss" (secondary)
Interactions:
| Action | Result |
| ------- | ------- |
| Tap push notification | Deep link to E4 (Lab Upload) with timepoint = 'follow_up' |
| Tap "Upload Now" (in-app) | Navigate to E4 with timepoint = 'follow_up' |
| Tap "Dismiss" (in-app) | Hide banner, reschedule reminder in 7 days |
| Swipe notification (iOS) | Dismiss, reschedule in 7 days |

Notification Logic
// Pseudocode for reminder scheduling
func scheduleFollowUpReminder(userID uuid.UUID) {
    baselineLab := getBaselineLab(userID)
    if baselineLab == nil {
        return
    }
    
    daysSinceBaseline := time.Since(baselineLab.SampleDate).Hours() / 24
    
    // Check if follow-up already uploaded
    followUpLab := getFollowUpLab(userID)
    if followUpLab != nil {
        return // Already completed
    }
    
    // Send reminder at 30, 37, 44 days (weekly after initial)
    if daysSinceBaseline >= 30 {
        sendPushNotification(userID, "follow_up_reminder")
        scheduleNextReminder(userID, 7) // Remind again in 7 days
    }
}
API Calls
Primary:
POST /api/v1/reminders/schedule
Request:
{
  "user_id": "uuid",
  "reminder_type": "follow_up",
  "trigger_date": "2026-07-20T10:00:00Z",
  "timepoint": "follow_up"
}
Response:
{
  "reminder_id": "uuid",
  "scheduled_at": "2026-07-20T10:00:00Z"
}

GET /api/v1/reminders/{user_id}/pending
Response:
{
  "reminders": [
    {
      "reminder_id": "uuid",
      "reminder_type": "follow_up",
      "trigger_date": "2026-07-20T10:00:00Z",
      "status": "pending"
    }
  ]
}
Error States:
| Error | Message | Action |
| ------- | ------- | ------- |
| Push permission denied | Show in-app banner instead | Fallback to in-app banner |
| Notification service down | Log error, retry in 1 hour | Retry logic |
| User already uploaded follow-up | Skip reminder | Mark reminder as completed |
Accessibility
Notification text is concise and clear
Deep link works with VoiceOver/TalkBack
In-app banner is keyboard-navigable



E30: Follow-up Lab Upload
Screen ID: E30
User Stories: US-47
Priority: 🔴 P0
Route: /labs/follow-up
Purpose
Upload follow-up labs (same flow as E4, but with timepoint = 'follow_up'). This enables profile recalculation and longitudinal analysis.
Key Architectural Decisions Covered
(Profile Recalculation): New labs trigger automatic profile re-evaluation
(Factorial Design 2×2): Follow-up data required for all participants
Beta Spec v1.1: "Two timepoints per user minimum"
User Flow
User taps "Upload Now" from E29 (reminder) OR navigates to "Upload Labs" from home
System detects this is follow-up (not baseline)
System shows E4 flow with timepoint = 'follow_up'
User uploads labs (OCR or manual)
System processes labs, normalizes units
System triggers profile recalculation (UC-47)
If profile changed → redirect to E31 (Profile Change Notification)
If profile unchanged → redirect to E25 (Drift Dashboard) with success message
States
State 1: Default (same as E4)
┌─────────────────────────────┐
│  Follow-up Labs             │
├─────────────────────────────┤
│                             │
│  📊 Time for your follow-up │
│                             │
│  Upload new labs to see how │
│  your metabolic profile has │
│  changed since baseline.    │
│                             │
│  ┌───────────────────────┐ │
│  │ 📄 Upload PDF/Photo   │ │
│  └───────────────────────┘ │
│                             │
│  Or                         │
│                             │
│  [ Enter Manually ]         │
│                             │
│  [ View Baseline Labs ]     │
│                             │
└─────────────────────────────┘
State 2: Comparison prompt (after upload)
┌─────────────────────────────┐
│  Follow-up Labs             │
├─────────────────────────────┤
│                             │
│  ✅ Labs uploaded           │
│                             │
│  Comparing with baseline... │
│                             │
│  ⏳ Processing...            │
│                             │
└─────────────────────────────┘
State 3: Profile changed
┌─────────────────────────────┐
│  Follow-up Labs             │
├─────────────────────────────┤
│                             │
│  🎉 Your profile changed!   │
│                             │
│  Profile 5 → Profile 2      │
│                             │
│  Your metabolic health has  │
│  improved. Let's see your   │
│  new recommendations.       │
│                             │
│  [ See New Profile ]        │
│  [ Compare Labs ]           │
│                             │
└─────────────────────────────┘
State 4: Profile unchanged
┌─────────────────────────────┐
│  Follow-up Labs             │
├─────────────────────────────┤
│                             │
│  ✅ Labs uploaded           │
│                             │
│  Your profile stayed the    │
│  same: Profile 2            │
│                             │
│  Your labs are stable.      │
│  Keep up the good work!     │
│                             │
│  [ View Profile ]           │
│  [ Compare Labs ]           │
│                             │
└─────────────────────────────┘
UI Elements
Header:
Title: "Follow-up Labs"
Subtitle: "Time for your follow-up"
Context Banner:
"Upload new labs to see how your metabolic profile has changed since baseline."
Upload Options (same as E4):
"Upload PDF/Photo" button
"Enter Manually" button
Baseline Comparison Link:
"View Baseline Labs" — shows previous lab values for comparison
Post-Upload States:
Profile changed: celebration message + "See New Profile" button
Profile unchanged: encouragement message + "View Profile" button
"Compare Labs" button — shows side-by-side comparison
Interactions:
| Action | Result |
| ------- | ------- |
| Tap "Upload PDF/Photo" | Open file picker (same as E4) |
| Tap "Enter Manually" | Navigate to E4b (same as E4) |
| Tap "View Baseline Labs" | Show baseline lab values (modal) |
| Tap "See New Profile" | Navigate to E10 (Profile Result) with new profile |
| Tap "Compare Labs" | Show side-by-side lab comparison (modal) |
| Tap "View Profile" | Navigate to E10 (Profile Result) with current profile |
API Calls
Primary:
POST /api/v1/labs/upload (same as E4, but with timepoint = 'follow_up')
Request:
{
  "timepoint": "follow_up",
  "source_type": "ocr",
  "file_url": "https://..."
}
GET /api/v1/labs/compare?user_id={id}&baseline={baseline_id}&followup={followup_id}
Response:
{
  "baseline": {
    "sample_date": "2026-05-15",
    "values": {
      "glucose": {"value": 95, "unit": "mg/dL", "status": "yellow"},
      "hba1c": {"value": 5.8, "unit": "%", "status": "yellow"}
    }
  },
  "followup": {
    "sample_date": "2026-06-20",
    "values": {
      "glucose": {"value": 88, "unit": "mg/dL", "status": "green"},
      "hba1c": {"value": 5.4, "unit": "%", "status": "yellow"}
    }
  },
  "changes": [
    {
      "biomarker": "glucose",
      "baseline_value": 95,
      "followup_value": 88,
      "change": -7,
      "change_percentage": -7.4,
      "status_change": "yellow → green",
      "interpretation": "Improved"
    }
  ]
}
Error States:
| Error | Message | Action |
| ------- | ------- | ------- |
| No baseline found | "No baseline labs found. Please upload baseline first." | Redirect to E4 with timepoint = 'baseline' |
| Labs too close together | "Follow-up labs must be at least 14 days after baseline." | Show error, suggest waiting |
| Profile recalculation failed | "Failed to recalculate profile. Please try again." | Retry button |
Accessibility
Comparison view is keyboard-navigable
Changes announced by screen reader: "Glucose improved from 95 to 88 milligrams per deciliter."
Celebration message announced with positive tone



E31: Profile Change Notification
Screen ID: E31
User Stories: US-49
Priority: 🟡 P1
Route: N/A (push notification + in-app message)
Purpose
Notify user that their profile has changed after follow-up labs. This is the reward mechanism for completing the retention loop.
Key Architectural Decisions Covered
 (Profile Recalculation): Automatic profile updates with clear messaging
 (Factorial Design 2×2): Profile changes are key outcomes
User Flow
System detects profile change after follow-up labs
System generates notification with old/new profile
User receives push notification OR sees in-app message
User taps notification → deep link to E10 (Profile Result) with new profile
User sees new profile + explanation of changes
States
State 1: Push Notification (Profile Improved)

┌─────────────────────────────┐
│  MetaCart              now  │
├─────────────────────────────┤
│  🎉 Your profile improved!  │
│                             │
│  Profile 5 → Profile 2      │
│                             │
│  Your metabolic health has  │
│  improved. Tap to see your  │
│  new recommendations.       │
│                             │
│  [ View Profile ]           │
└─────────────────────────────┘
State 2: Push Notification (Profile Worsened)
┌─────────────────────────────┐
│  MetaCart              now  │
├─────────────────────────────┤
│  ⚠️ Your profile changed    │
│                             │
│  Profile 1 → Profile 4      │
│                             │
│  Your labs suggest increased│
│  metabolic stress. Tap to   │
│  see updated recommendations│
│                             │
│  [ View Profile ]           │
└─────────────────────────────┘
State 3: In-App Modal (detailed)
┌─────────────────────────────┐
│  Profile Update        [×]  │
├─────────────────────────────┤
│                             │
│  🎉 Great progress!         │
│                             │
│  Your profile changed:      │
│                             │
│  Profile 5 → Profile 2      │
│  Neuro-Autonomic →          │
│  Carb Sensitivity           │
│                             │
│  What changed:              │
│  • Axis 5: 🟠 → 🟢          │
│    (HRV improved)           │
│  • Axis 1: 🟢 → 🟡          │
│    (Glucose slightly up)    │
│                             │
│  Your new recommendations   │
│  focus on protein-first     │
│  meals and slow carbs.      │
│                             │
│  [ See New Profile ]        │
│  [ View Changes ]           │
│                             │
└─────────────────────────────┘
UI Elements
Push Notification:
App icon + name
Title: "Your profile improved!" (or "Your profile changed")
Body: "Profile X → Profile Y" + brief explanation
Deep link action: "View Profile"
In-App Modal:
Header: "Profile Update" + close button
Celebration/warning icon (🎉 or ⚠️)
Old profile → New profile (with names)
"What changed" section:
List of axis changes (e.g., "Axis 5: 🟠 → 🟢")
Brief interpretation
Explanation of new recommendations
Two buttons:
"See New Profile" (primary) → navigate to E10
"View Changes" (secondary) → show detailed comparison
Notification Logic go:
// Pseudocode for profile change notification
func onProfileChanged(userID uuid.UUID, oldProfile, newProfile Profile) {
    // Determine message tone
    var message string
    var icon string
    
    if isImprovement(oldProfile, newProfile) {
        message = "Great progress! Your metabolic health has improved."
        icon = "🎉"
    } else if isWorsening(oldProfile, newProfile) {
        message = "Your labs suggest increased metabolic stress. Consider consulting your doctor."
        icon = "⚠️"
    } else {
        message = "Your profile has been updated based on new labs."
        icon = "📊"
    }
    
    // Send push notification
    sendPushNotification(userID, PushNotification{
        Title: "Your profile changed",
        Body: fmt.Sprintf("Profile %d → Profile %d. %s", oldProfile.Number, newProfile.Number, message),
        Icon: icon,
        DeepLink: fmt.Sprintf("/profile/%d", newProfile.ID),
    })
    
    // Store in-app message for later display
    createInAppMessage(userID, InAppMessage{
        Type: "profile_change",
        Title: "Profile Update",
        Body: message,
        OldProfile: oldProfile,
        NewProfile: newProfile,
        AxisChanges: getAxisChanges(oldProfile, newProfile),
    })
}

func isImprovement(old, new Profile) bool {
    // Profile 5 → 1-4 = improvement
    // Profile 4 → 1-3 = improvement
    // Profile 3 → 1-2 = improvement
    // Profile 2 → 1 = improvement
    return new.Number < old.Number
}
Interactions:
| Action | Result |
| ------- | ------- |
| Tap push notification | Deep link to E10 (Profile Result) with new profile |
| Tap "View Profile" (in-app) | Navigate to E10 with new profile |
| Tap "View Changes" (in-app) | Show detailed axis comparison (modal) |
| Tap "×" (in-app) | Dismiss modal |
API Calls
Primary:
GET /api/v1/profiles/changes?user_id={id}&old={old_id}&new={new_id}
Response:
{
  "old_profile": {
    "profile_number": 5,
    "profile_name": "Neuro-Autonomic",
    "axes": {
      "1": "green",
      "2": "green",
      "3": "green",
      "4": "green",
      "5": "orange"
    }
  },
  "new_profile": {
    "profile_number": 2,
    "profile_name": "Carb Sensitivity",
    "axes": {
      "1": "yellow",
      "2": "yellow",
      "3": "green",
      "4": "green",
      "5": "green"
    }
  },
  "axis_changes": [
    {
      "axis": 5,
      "old_status": "orange",
      "new_status": "green",
      "interpretation": "Improved",
      "explanation": "Your HRV improved from 24ms to 45ms, indicating better autonomic balance."
    },
    {
      "axis": 1,
      "old_status": "green",
      "new_status": "yellow",
      "interpretation": "Attention needed",
      "explanation": "Your glucose increased from 88 to 95 mg/dL. Focus on protein-first meals."
    }
  ],
  "overall_change": "improved",
  "recommendation": "Your new recommendations focus on protein-first meals and slow carbs."
}
Error States:
| Error | Message | Action |
| ------- | ------- | ------- |
| Profile change data not found | "Unable to load profile changes." | Show generic message, link to E10 |
| Network error | "Check your connection and try again." | Retry button |
Accessibility
Notification text is clear and concise
Profile changes announced: "Profile changed from 5, Neuro-Autonomic, to 2, Carb Sensitivity."
Axis changes announced: "Axis 5 improved from orange to green. Your HRV improved from 24 to 45 milliseconds."
Celebration/warning tone conveyed through icon + text

🔑 CRITICAL UX NOTES FOR PHASE 5
1. Retention is Critical for Research Success
The Beta Spec explicitly requires two timepoints. Without follow-up data:
Cannot validate profile changes
Cannot test factorial design
Cannot generate preliminary data for NIH SBIR
Solution:
Automated reminders at 30, 37, 44 days
Clear messaging about why follow-up matters
Celebration when follow-up completed
2. Profile Change Must Be Celebratory (or Supportive)
Users need to understand that profile changes are normal and expected.
Solution:
Improved profile: "🎉 Great progress!" celebration
Worsened profile: "⚠️ Consider consulting your doctor" supportive message
Unchanged profile: "✅ Your labs are stable. Keep up the good work!"
3. Lab Comparison Must Be Transparent
Users need to see what changed and why.
Solution:
Side-by-side lab comparison (baseline vs follow-up)
Axis-by-axis changes with interpretation
Clear explanation of what each change means
4. Reminder Timing Must Be Smart
Too many reminders = annoyance. Too few = missed follow-ups.
Solution:
Initial reminder at 30 days
Weekly reminders after that (37, 44, 51 days)
Stop after 60 days (user either completed or dropped out)
Respect notification preferences 
5. Deep Links Must Work Seamlessly
Users tap notification → must land exactly where they need to be.
Solution:
Push notification deep link → E4 with timepoint = 'follow_up'
Profile change notification deep link → E10 with new profile
Test all deep links on iOS and Android
6. Profile Recalculation Must Be Fast
Users expect immediate feedback after uploading follow-up labs.
Solution:
Profile recalculation happens synchronously (not background job)
Show "Processing..." spinner during recalculation
Target: <5 seconds for full recalculation
7. Factorial Design Groups Must Be Tracked
Each user is assigned to one of 4 groups (A/B/C/D) based on glycemic status + symptomatic phenotype.
Solution:
Group assignment happens at baseline (after labs + symptom log)
Group displayed in user profile (for research team)
Group used in analysis (compare outcomes across groups)

