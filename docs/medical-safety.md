# Medical Safety and Failsafes (`medical-safety.md`)

MetaCart deals with sensitive biometric data. This document outlines the boundaries of the system and the automated failsafes designed to prevent harm.

---

## 1. Disclaimers and Legal Boundaries

### 1.1. "Not a Medical Device"
*   MetaCart is explicitly **not an FDA-approved medical device**.
*   It does not diagnose, treat, cure, or prevent any disease.
*   All UI copy must use terminology like "Supportive for your profile" or "May trigger inflammation," avoiding terms like "Cures your diabetes" or "Prescription."

### 1.2. UI Enforcement
*   The Phase 3 Shopping Cart screen and the Phase 2 Profile Dashboard must contain sticky disclaimers stating: *"Recommendations are for informational purposes only. Consult your physician."*
*   Users must tap an "I Understand" acknowledgement before confirming their first grocery cart.

---

## 2. Automated Safety Failsafes

The system actively monitors for extreme or dangerous states and halts the standard recommendation engine if triggered.

### 2.1. Dangerous Lab Values
During Phase 2 (Lab Confirmation), if `value_original` exceeds critical medical thresholds (e.g., Fasting Glucose > 300 mg/dL or HbA1c > 12%), the system triggers a **Safety Halt**.
*   **Action:** The app displays a hard-coded alert advising the user to contact emergency medical services or their primary care physician immediately.
*   **Result:** The metabolic profile generation is suspended until medical clearance is (mock) provided or the user adjusts the input.

### 2.2. Severe Glucose Drops (Hypoglycemia Risk)
While MetaCart does not provide real-time alerts, if historical data synced from Apple Health/Google Fit shows repeated events of $Glucose < 55$ mg/dL (severe hypoglycemia):
*   **Action:** The algorithm will **not** recommend a strict low-carb/ketogenic profile (e.g., Profile 1 - Glycemic Strict), even if their baseline HbA1c is high.
*   **Reason:** Putting a patient prone to hypoglycemia on a strict low-carb diet without direct medical supervision is dangerous. The system defaults to a safer, moderate-carb profile (e.g., Profile 5).

### 2.3. Eating Disorder Failsafe
*   During onboarding, if `household_size = 1` and the calculated `budget_tier` combined with specific restrictive `dietary_restrictions` yields a daily caloric estimate below 1,000 calories, the system flags a potential risk.
*   **Action:** The system artificially inflates portion sizes in the recommended cart to ensure a minimum safe caloric baseline.
