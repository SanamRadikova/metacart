# Data Privacy and IRB Compliance (`data-privacy.md`)

MetaCart is designed under strict ethical and legal constraints due to its nature as a clinical trial beta. This document outlines how data privacy is enforced.

---

## 1. IRB (Institutional Review Board) Compliance

### 1.1. Consent Management
*   **Explicit Consent:** Users cannot proceed past the splash screen without checking the consent agreement.
*   **Hash Tracking:** The `research_consents` table stores a SHA-256 hash of the exact consent text version the user agreed to, ensuring non-repudiation.
*   **Age Gating:** Registration throws a validation error if `date_of_birth` calculates to $< 18$ or $> 65$.

### 1.2. The Soft-Delete Protocol
Users have the "Right to Withdraw" from the study at any point (Phase 5).
*   **Action:** Deleting an account **does not** remove the rows from the database.
*   **Implementation:** A cascade `UPDATE` sets the `deleted_at` column to `NOW()` across all tables (`users`, `lab_results`, `profiles`, etc.).
*   **Why:** Clinical trials require an unbroken audit trail of who was in the study and when they left. The data is anonymized and hidden from the live application but retained for statistical auditing.

## 2. Data Anonymization & Security

### 2.1. Row Level Security (RLS)
Supabase RLS is strictly enforced.
*   A user can only `SELECT`, `INSERT`, `UPDATE` rows where `user_id = auth.uid()`.
*   Cross-user data leakage is impossible at the database engine level.

### 2.2. Personally Identifiable Information (PII)
*   **Separation:** Email addresses and passwords are handled strictly by Supabase Auth and are not duplicated in logging systems.
*   **No Names Required:** The app does not ask for the user's first or last name, only demographic factors necessary for the metabolic engine (age, gender, cultural group).

### 2.3. Health Data Boundaries
*   **Apple Health / Google Fit:** The app requests read-only access to specific metrics (Glucose, HRV, Sleep). It never writes data back to the OS hub.
*   **EHR (Electronic Health Records):** By design, MetaCart avoids direct EHR integration to bypass HIPAA BAA requirements during the Beta phase. Lab results are user-uploaded PDFs, processed locally by OCR, and confirmed by the user.

## 3. Data Retention
*   **Storage Buckets:** Uploaded receipt images and lab result PDFs are stored in private Supabase Storage buckets.
*   **Auto-Cleanup:** Once the OCR pipeline extracts structured data into the `lab_values` or `purchase_items` tables, the original raw image/PDF can be scheduled for deletion to minimize liability.
