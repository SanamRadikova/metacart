# System Architecture (`architecture.md`)

MetaCart relies on a cloud-native, serverless-first architecture optimized for rapid iteration, leveraging Supabase as the core backend, Go for intensive data processing, and Flutter for the client interface.

---

## 1. High-Level Components

### 1.1. Mobile Client (Flutter)
*   **Framework:** Flutter (Dart)
*   **Responsibilities:** 
    *   UI rendering for Onboarding, Dashboards, and Carts.
    *   Apple HealthKit / Google Fit SDK integration to pull step counts, HRV, and CGM data.
    *   Local caching of API responses.
    *   Receipt image capture and pre-compression.

### 1.2. Backend Data Store (Supabase)
*   **Database:** PostgreSQL 15+
*   **Auth:** Supabase Auth (Email/Password, JWT).
*   **Storage:** Supabase Storage (PDF Lab results, Receipt JPEG images).
*   **Extensions:** `uuid-ossp` (Primary Keys), `pg_partman` (Partitioning).

### 1.3. Compute Layer (Go / Golang)
*   **Role:** Since the metabolic engine and OCR pipeline require heavy compute and custom logic, they are hosted as a separate Go microservice (or serverless functions).
*   **Responsibilities:**
    *   Processing raw text from Google Vision API.
    *   Running the Threshold Modifier math.
    *   Fuzzy matching receipt items against the Open Food Facts database.

---

## 2. Data Flow Diagrams

### 2.1. Lab Upload Flow
1. **User (Flutter):** Uploads PDF/Image of Lab Results.
2. **Supabase Storage:** Saves file securely.
3. **Webhook/Trigger:** Triggers Go Service upon file upload.
4. **Go Service:** Sends file to Google Document AI / Vision API for structured extraction.
5. **Go Service:** Writes extracted `value_original` to `lab_values` table.
6. **User (Flutter):** Polls `/labs/{id}/status` and retrieves values for manual confirmation.

### 2.2. Wearable Data Ingestion
1. **Flutter App:** Requests permissions for Apple Health / Google Fit on the device.
2. **Flutter App (Background Task):** Queries local OS Health databases for daily aggregates (HRV, Glucose).
3. **Flutter App:** Sends batch JSON payload to Go Service API.
4. **Go Service:** Validates schema and inserts rows into the partitioned `device_readings` table in Supabase.

*Note: The backend never communicates directly with Apple or Google cloud servers for health data; it relies entirely on the local mobile OS as the secure intermediary.*

### 2.3. Receipt OCR & Drift Calculation
1. **User:** Takes a photo of the receipt.
2. **Flutter App:** Uploads to Supabase Storage -> Triggers Go Pipeline.
3. **Google Vision API:** Extracts raw line items.
4. **Go Service:** Queries Open Food Facts / Local Catalog for matches.
5. **Database:** Saves to `actual_purchases` and `purchase_items`.
6. **Go Service:** Calculates match % vs drift % and updates `drift_analyses`.

---

## 3. Security Boundaries
*   **RLS (Row Level Security):** All Supabase tables use RLS ensuring `user_id = auth.uid()`.
*   **Secrets:** API keys for Google Vision and Open Food Facts reside strictly in the Go backend environment variables.
