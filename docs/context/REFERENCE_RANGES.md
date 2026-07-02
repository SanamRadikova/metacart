# MetaCart — Reference Ranges & Biomarker Thresholds

## Overview

This document defines the functional thresholds used by the MetaCart engine to evaluate biomarkers across 5 metabolic axes. These thresholds are **stricter than official diagnostic criteria** because MetaCart is a preventive nutrition tool, not a diagnostic device.

**Key principle**: MetaCart identifies early signs of metabolic dysfunction before they reach clinical diagnosis thresholds. This allows personalized nutrition recommendations that prevent progression to disease.

**Important for developers**:
- All values are stored in **standard US units** (mg/dL, %, mg/L, mIU/L, ms)
- Conversion from other units (mmol/L, mmol/mol) must happen at data ingestion
- Thresholds are stored in `reference_ranges` table, not hardcoded
- Some thresholds vary by gender (HDL, hemoglobin)
- Age range: 25–65 years (pediatric norms are different and not applicable)

---

## Quick Reference Table — All Biomarkers

| Biomarker | Axis | Unit | 🟢 Stable | 🟡 Attention | 🟠 Deviation | Source | Gender-Specific |
|-----------|------|------|-----------|--------------|--------------|--------|-----------------|
| **Fasting Glucose** | 1 | mg/dL | 70–90 | 91–99 | ≥100 | ADA 2024 | No |
| **HbA1c** | 1 | % | <5.3 | 5.3–5.6 | ≥5.7 | ADA 2024 | No |
| **TG/HDL Ratio** | 1+2 | ratio | <1.5 | 1.5–2.9 | ≥3.0 | AHA 2023 | No |
| **Triglycerides** | 2 | mg/dL | <100 | 100–149 | ≥150 | AHA 2023 | No |
| **HDL (female)** | 2 | mg/dL | >50 | 40–50 | <40 | AHA 2023 | **Yes** |
| **HDL (male)** | 2 | mg/dL | >40 | 35–40 | <35 | AHA 2023 | **Yes** |
| **hs-CRP** | 3 | mg/L | <0.8 | 0.8–1.0 | >1.0 | AHA/CDC 2003 | No |
| **TSH** | 4 | mIU/L | 0.8–2.0 | 2.0–2.5 | >2.5 | ATA 2012 (functional) | No |
| **HRV RMSSD** | 5 | ms | >40 | 25–40 | <25 | Shaffer 2017 | No |
| **SDNN** | 5 | ms | 80–180 | 50–80 | <50 OR >200* | Task Force 1996 | No |
| **PNN50** | 5 | % | >20 | 10–20 | <10 | Clinical consensus | No |

*SDNN >200 with RMSSD <25 = dysregulatory pattern (see Special Cases below)

---

## Detailed Thresholds by Axis

### Axis 1 — Glycemic (Carbohydrate Metabolism)

#### Fasting Glucose

| Status | Range (mg/dL) | Range (mmol/L) | Clinical Meaning |
|--------|---------------|----------------|------------------|
| 🟢 Stable | 70–90 | 3.9–5.0 | Optimal glucose homeostasis. Insulin sensitivity high. |
| 🟡 Attention | 91–99 | 5.1–5.5 | Impaired fasting glucose (ADA: 100–125). Early insulin resistance signs. |
| 🟠 Deviation | ≥100 | ≥5.6 | Prediabetic range (ADA). Requires structural dietary intervention. |
| ⚠️ Exclusion | ≥126 | ≥7.0 | Diabetes diagnosis (WHO). **Exclude from MetaCart** — requires medical treatment, not nutrition recommendations. |

**Why MetaCart is stricter than ADA**:
- ADA defines prediabetes as 100–125 mg/dL
- MetaCart flags 91–99 as "Attention" to catch early metabolic dysfunction
- Rationale: intervention at 95 mg/dL is more effective than at 105 mg/dL

**Developer note**: If glucose ≥126 mg/dL, flag for medical consultation. Do not generate Profile 2 — this is beyond nutrition scope.

#### HbA1c (Glycated Hemoglobin)

| Status | Range (%) | Range (mmol/mol) | Clinical Meaning |
|--------|-----------|------------------|------------------|
| 🟢 Stable | <5.3 | <34 | Excellent 3-month glucose control |
| 🟡 Attention | 5.3–5.6 | 34–37 | Borderline. Monitor closely. |
| 🟠 Deviation | 5.7–6.4 | 38–46 | Prediabetes (ADA). Requires dietary structure. |
| ⚠️ Exclusion | ≥6.5 | ≥48 | Diabetes diagnosis (WHO). **Exclude from MetaCart**. |

**Conversion formula** (for European labs using IFCC standard):
% = (mmol/mol ÷ 10.929) + 2.15

**Example**: 48 mmol/mol → (48 ÷ 10.929) + 2.15 = 6.54% → Exclusion (diabetes)

**Developer note**: HbA1c and fasting glucose must be evaluated together. If one is 🟠 and the other is 🟢, use the higher status for Axis 1.

#### TG/HDL Ratio (Insulin Resistance Marker)

| Status | Ratio | Clinical Meaning |
|--------|-------|------------------|
| 🟢 Stable | <1.5 | Optimal insulin sensitivity |
| 🟡 Attention | 1.5–2.9 | Moderate insulin resistance |
| 🟠 Deviation | ≥3.0 | High insulin resistance. Strong predictor of metabolic syndrome. |

**Why this matters**: TG/HDL ratio is a better predictor of insulin resistance than fasting glucose alone. It captures the atherogenic dyslipidemia pattern (high TG + low HDL) that precedes diabetes by years.

**Developer note**: Calculate as `triglycerides / hdl`. Both must be in mg/dL. If either is missing, mark Axis 1 as `no_data`.

---

### Axis 2 — Lipid (Atherogenic Pattern)

#### Triglycerides

| Status | Range (mg/dL) | Range (mmol/L) | Clinical Meaning |
|--------|---------------|----------------|------------------|
| 🟢 Stable | <100 | <1.13 | Optimal. Low cardiovascular risk. |
| 🟡 Attention | 100–149 | 1.13–1.68 | Borderline high. Dietary intervention effective. |
| 🟠 Deviation | ≥150 | ≥1.69 | High. Requires omega-3, Mediterranean diet. |

**Why MetaCart is stricter than AHA**:
- AHA defines "normal" as <150 mg/dL
- MetaCart flags 100–149 as "Attention" to optimize metabolic health
- Rationale: optimal TG for longevity is <100, not just "not high"

#### HDL Cholesterol (Gender-Specific)

**Female**:

| Status | Range (mg/dL) | Range (mmol/L) | Clinical Meaning |
|--------|---------------|----------------|------------------|
| 🟢 Stable | >50 | >1.3 | Protective. Reduced cardiovascular risk. |
| 🟡 Attention | 40–50 | 1.0–1.3 | Borderline. Increase healthy fats. |
| 🟠 Deviation | <40 | <1.0 | Low. Increased cardiovascular risk. |

**Male**:

| Status | Range (mg/dL) | Range (mmol/L) | Clinical Meaning |
|--------|---------------|----------------|------------------|
| 🟢 Stable | >40 | >1.0 | Acceptable. |
| 🟡 Attention | 35–40 | 0.9–1.0 | Borderline. |
| 🟠 Deviation | <35 | <0.9 | Low. Increased risk. |

**Developer note**: Always check user gender before evaluating HDL. If gender is missing or "other", use female thresholds (more conservative).

#### LDL Cholesterol (Context Only — Not an Axis)

LDL is **not used for axis evaluation** but stored as contextual data.

| Category | Range (mg/dL) | Clinical Meaning |
|----------|---------------|------------------|
| Optimal | <100 | Low risk |
| Near optimal | 100–129 | Acceptable |
| Borderline high | 130–159 | Monitor |
| High | 160–189 | Intervention needed |
| Very high | ≥190 | Medical consultation |

**Developer note**: LDL is displayed to user but does not trigger profile selection. It's used for general health context.

---

### Axis 3 — Inflammatory (Systemic Chronic Inflammation)

#### hs-CRP (High-Sensitivity C-Reactive Protein)

| Status | Range (mg/L) | Clinical Meaning | MetaCart Action |
|--------|--------------|------------------|-----------------|
| 🟢 Stable | <0.8 | No inflammatory load | Axis 3 not active |
| 🟡 Attention | 0.8–1.0 | Subclinical inflammation | Add omega-3 as modifier |
| 🟠 Deviation | >1.0 | Chronic inflammatory load | Activate Profile 3 (if no higher priority) |

**Why MetaCart is stricter than AHA/CDC**:
- AHA/CDC defines "high risk" as >3.0 mg/L
- MetaCart flags >1.0 as "Deviation" to detect dietary inflammation
- Rationale: chronic low-grade inflammation from ultra-processed foods starts at 1.0 mg/L, not 3.0

**Critical trap — unit confusion**:
- Most labs report hs-CRP in **mg/L**
- Some US labs report in **mg/dL** (10× smaller values)
- Example: 0.08 mg/dL = 0.8 mg/L (Attention)
- Example: 0.8 mg/dL = 8.0 mg/L (Deviation!)

**Developer note**: Always confirm unit from lab report. If value <1.0, assume mg/dL and multiply by 10. If value >1.0, assume mg/L. Store both original and normalized values.

---

### Axis 4 — Stress/Thyroid (Neuroendocrine Adaptation)

#### TSH (Thyroid-Stimulating Hormone)

| Status | Range (mIU/L) | Clinical Meaning | MetaCart Action |
|--------|---------------|------------------|-----------------|
| 🟢 Stable | 0.8–2.0 | Optimal thyroid function | No restrictions |
| 🟡 Attention | 2.0–2.5 | Suboptimal function | Add iodine, selenium as modifiers |
| 🟠 Deviation | >2.5 | Hypothyroidism / stress adaptation | Activate Profile 4. **No aggressive calorie restriction.** |

**Why MetaCart is stricter than ATA/AACE**:
- ATA/AACE defines "normal" as 0.4–4.12 mIU/L
- MetaCart uses functional range 0.8–2.0 for optimal metabolic function
- Rationale: TSH 2.5–4.0 is "normal" by diagnostic criteria but indicates slowed metabolism. Aggressive diets at TSH >2.5 can worsen hypothyroidism.

**Critical UX note**: User with TSH 3.2 mIU/L may be told by doctor "your labs are normal." MetaCart will activate Profile 4. This requires clear explanation:
> "Your TSH is within the diagnostic normal range (0.4–4.0), but MetaCart uses a functional range (0.8–2.0) to optimize metabolic health. At TSH >2.5, your metabolism may be slowed, and aggressive dietary restrictions could worsen this. We recommend a supportive, non-restrictive approach."

**Developer note**: If TSH >10 mIU/L, this is overt hypothyroidism requiring medical treatment. Flag for medical consultation. Profile 4 can still provide safe dietary recommendations as adjunct to medical care.

---

### Axis 5 — Neuro-Autonomic (HRV)

#### HRV RMSSD (Root Mean Square of Successive Differences)

| Status | Range (ms) | Clinical Meaning | MetaCart Action |
|--------|------------|------------------|-----------------|
| 🟢 Stable | >40 | Healthy parasympathetic tone | Axis 5 not active |
| 🟡 Attention | 25–40 | Reduced parasympathetic tone | Monitor. Consider Profile 5 if symptoms present. |
| 🟠 Deviation | <25 | Constitutional autonomic dysregulation | **Activate Profile 5** (highest priority) |

**Why RMSSD is the primary marker**:
- RMSSD specifically measures parasympathetic (vagal) tone
- Low RMSSD = sympathetic dominance = stress response
- In pilot: symptomatic users had RMSSD 20–34 ms with normal glucose
- RMSSD <25 ms is a strong predictor of autonomic symptoms

#### SDNN (Standard Deviation of NN Intervals)

| Status | Range (ms) | Clinical Meaning | MetaCart Action |
|--------|------------|------------------|-----------------|
| 🟢 Stable | 80–180 | Healthy overall variability | Normal |
| 🟡 Attention | 50–80 | Reduced variability | Monitor |
| 🟠 Deviation | <50 | Low variability | Autonomic dysfunction |
| 🟠 **Paradox** | >200 **AND** RMSSD <25 | Dysregulatory pattern | **Activate Profile 5** |

**SDNN Paradox — Critical for Developers**:

High SDNN (>150 ms) with low RMSSD (<25 ms) is **NOT** a sign of health. This is dysregulatory variability:
- Sympathetic system is hyperactive → creates chaotic large deviations → high SDNN
- But parasympathetic quality activity (RMSSD) remains low
- Result: autonomic chaos, not health

**Rule for engine**:
IF SDNN > 150 AND RMSSD < 25:
axis_5_status = 'orange' # Dysregulatory pattern
flag = 'sdnn_paradox'


**Example from pilot**: RMSSD 24ms, SDNN 216ms → Profile 5 activated (not Profile 1 despite "high" SDNN)

#### PNN50 (Percentage of Successive Intervals Differing by >50 ms)

| Status | Range (%) | Clinical Meaning | MetaCart Action |
|--------|-----------|------------------|-----------------|
| 🟢 Stable | >20 | Good parasympathetic tone | Normal |
| 🟡 Attention | 10–20 | Reduced variability | Refines RMSSD assessment |
| 🟠 Deviation | <10 | Monotonous heart rhythm | Autonomic dysfunction |

**Why PNN50 matters**:
- PNN50 refines RMSSD assessment
- In pilot: Profile 5 (symptomatic) had PNN50 24% with HRV 34ms
- Profile B (asymptomatic) had PNN50 6% with HRV 38ms
- Almost identical HRV, but radically different PNN50 → different phenotypes

**Rule for engine**: If RMSSD is borderline (25–35 ms), use PNN50 to refine:
- PNN50 <10% → lean toward 🟡
- PNN50 >20% → lean toward 🟢

#### Heart Rate (HR) — Context Only, NOT an Axis Marker

**Critical**: Heart rate is **NOT used for profile selection**. It's displayed to user but does not activate Axis 5.

**Why HR is insufficient**:
- HR 102 BPM can occur with excellent HRV (physical activity) or poor HRV (stress)
- In pilot: user had HR 102 (bracelet showed HIGH) but RMSSD 36ms (Normal), SDNN 146ms (Good), PNN50 23% (Good)
- Bracelet panicked, but autonomic status was fine
- Symptoms were from hormonal phase, not cardiac pathology

**Developer note**: Store HR for display, but never use it in axis evaluation logic.

---

## Special Cases & Edge Cases

### Case 1: Missing Biomarkers (Graceful Degradation)

If a biomarker is missing, the axis is marked `no_data` and does not participate in profile selection.

| Missing Data | Impact |
|--------------|--------|
| Glucose or HbA1c | Axis 1 = `no_data` |
| TG or HDL | Axis 2 = `no_data` |
| hs-CRP | Axis 3 = `no_data` |
| TSH | Axis 4 = `no_data` |
| HRV (RMSSD, SDNN, PNN50) | Axis 5 = `no_data` |

**Profile selection with missing axes**:
- If Axis 5 = `no_data`, Step 0 (Profile 5) cannot trigger
- If Axis 4 = `no_data`, Step 1 (Profile 4) cannot trigger
- Engine continues with available data (graceful degradation)

### Case 2: Diabetes Exclusion

If any of the following are true, **exclude user from MetaCart** and flag for medical consultation:
- Fasting glucose ≥126 mg/dL
- HbA1c ≥6.5%
- TSH >10 mIU/L (overt hypothyroidism)

**Developer note**: These are medical diagnoses requiring treatment, not nutrition recommendations. MetaCart is a preventive tool, not a treatment tool.

### Case 3: Hormonal Modifier (Women)

Hormonal status changes Axis 5 thresholds:

| Hormonal Status | Profile 5 Threshold Change |
|-----------------|----------------------------|
| Follicular phase (regular cycle) | Standard (RMSSD <25) |
| PMS / luteal phase | RMSSD <30 (20% reduction) |
| Perimenopause | RMSSD <35 (default activation if symptoms) |
| Postmenopause | Standard, but enhanced protein emphasis |
| Not applicable (men) | N/A |

**Developer note**: Hormonal modifier is optional. If not provided, use standard thresholds.

### Case 4: dG/dt (Glucose Velocity) — Dynamic Parameter

dG/dt is computed from CGM data every 5 minutes:
dG/dt = (G_current - G_previous) / time_in_minutes

| dG/dt Value | Status | Action |
|-------------|--------|--------|
| >0 (rising) | Normal | No action |
| 0 to -0.3 (slowly falling) | Monitor | Preventive snack reminder |
| -0.3 to -0.7 (falling) | Warning | Notification: "Eat protein + fat now" |
| <-0.7 (rapidly falling) | Critical | Urgent notification + recommendation |

**Developer note**: dG/dt is only relevant for Profile 5 users with connected CGM. It does not activate Profile 5 by itself — requires RMSSD <25 OR symptoms.

### Case 5: SDNN Paradox (Dysregulatory Pattern)

**Condition**: SDNN >150 ms AND RMSSD <25 ms

**Interpretation**: This is NOT health. This is autonomic chaos:
- Sympathetic system creates chaotic large deviations → high SDNN
- Parasympathetic quality activity remains low → low RMSSD
- Result: dysregulatory pattern → Profile 5

**Developer note**: This is a critical edge case. Do not interpret high SDNN as "good" without checking RMSSD.

---

## Sources & References

| Biomarker | Primary Source | MetaCart Threshold | Official Threshold | Why Stricter |
|-----------|----------------|--------------------|--------------------|--------------|
| Fasting Glucose | ADA Standards of Care 2024 | 91–99 = Attention | 100–125 = Prediabetes | Catch early insulin resistance |
| HbA1c | ADA 2024 | 5.3–5.6 = Attention | 5.7–6.4 = Prediabetes | Catch early glycemic dysfunction |
| TG/HDL Ratio | AHA/ACC 2023 | ≥3.0 = Deviation | Not standardized | Better predictor than glucose alone |
| Triglycerides | AHA 2023 | 100–149 = Attention | ≥150 = High | Optimal TG <100 for longevity |
| HDL | AHA 2023 | <40 (♂) / <50 (♀) = Deviation | <40 (♂) / <50 (♀) = Low | Same as AHA |
| hs-CRP | AHA/CDC 2003 | >1.0 = Deviation | >3.0 = High risk | Detect dietary inflammation early |
| TSH | ATA 2012 (functional) | >2.5 = Deviation | >4.0 = Subclinical hypothyroidism | Functional range for optimal metabolism |
| HRV RMSSD | Shaffer & Ginsberg 2017 | <25 = Deviation | <27 = Clinically low | Based on pilot data + clinical consensus |

**Regulatory documents**:
- ADA Standards of Care 2024 (American Diabetes Association)
- AHA/ACC 2023 (American Heart Association / American College of Cardiology)
- ESC/EAS 2019 (European Society of Cardiology / European Atherosclerosis Society)
- ATA 2012 (American Thyroid Association)
- AACE 2023 (American Association of Clinical Endocrinologists)
- AHA/CDC 2003 Joint Statement on hs-CRP
- Task Force of ESC and NASPE 1996 (HRV standards)
- Shaffer & Ginsberg 2017 (HRV review)

---

## Developer Implementation Notes

### 1. Unit Normalization

All values must be normalized to standard US units before evaluation:

```go
// Example: normalize glucose from mmol/L to mg/dL
func normalizeGlucose(value float64, unit string) float64 {
    if unit == "mmol/L" {
        return value * 18.02
    }
    return value  // already mg/dL
}
Critical conversions:
Glucose: mmol/L × 18.02 = mg/dL
HbA1c: mmol/mol ÷ 10.929 + 2.15 = %
TG: mmol/L × 88.57 = mg/dL
HDL/LDL: mmol/L × 38.67 = mg/dL
hs-CRP: mg/dL × 10 = mg/L (if lab reports in mg/dL)
TSH: μIU/mL = mIU/L (identical)

2. Reference Table Storage
Store thresholds in reference_ranges table, not hardcoded:
INSERT INTO reference_ranges (biomarker, gender, green_min, green_max, yellow_min, yellow_max, orange_min, orange_max, unit) VALUES
('glucose_fasting', 'any', 70, 90, 91, 99, 100, 125, 'mg/dL'),
('hba1c', 'any', NULL, 5.2, 5.3, 5.6, 5.7, 6.4, '%'),
('hdl', 'female', 50, NULL, 40, 50, NULL, 39, 'mg/dL'),
('hdl', 'male', 40, NULL, 35, 40, NULL, 34, 'mg/dL'),
('hs_crp', 'any', NULL, 0.79, 0.8, 1.0, 1.01, NULL, 'mg/L'),
('tsh', 'any', 0.8, 2.0, 2.01, 2.5, 2.51, NULL, 'mIU/L');
Benefits:
Easy to update thresholds without redeployment
Can A/B test different thresholds
Clear audit trail

3. Axis Evaluation Logic
func evaluateAxis1(glucose, hba1c, tgHdlRatio float64) string {
    // Check glucose
    glucoseStatus := evaluateBiomarker("glucose_fasting", glucose, "any")
    
    // Check HbA1c
    hba1cStatus := evaluateBiomarker("hba1c", hba1c, "any")
    
    // Check TG/HDL ratio
    tgHdlStatus := evaluateBiomarker("tg_hdl_ratio", tgHdlRatio, "any")
    
    // Return highest status
    return highestStatus(glucoseStatus, hba1cStatus, tgHdlStatus)
}
4. Gender-Specific Evaluation
func evaluateAxis2(tg, hdl float64, gender string) string {
    tgStatus := evaluateBiomarker("triglycerides", tg, "any")
    hdlStatus := evaluateBiomarker("hdl", hdl, gender)  // gender-specific!
    
    return highestStatus(tgStatus, hdlStatus)
}

5. SDNN Paradox Check
func evaluateAxis5(rmssd, sdnn, pnn50 float64) (string, bool) {
    // Check for SDNN paradox
    if sdnn > 150 && rmssd < 25 {
        return "orange", true  // dysregulatory pattern
    }
    
    // Normal evaluation
    rmssdStatus := evaluateBiomarker("hrv_rmssd", rmssd, "any")
    sdnnStatus := evaluateBiomarker("sdnn", sdnn, "any")
    pnn50Status := evaluateBiomarker("pnn50", pnn50, "any")
    
    return highestStatus(rmssdStatus, sdnnStatus, pnn50Status), false
}

6. Graceful Degradation
func evaluateAllAxes(data map[string]float64, gender string) map[int]string {
    axes := make(map[int]string)
    
    // Axis 1: Glycemic
    if hasData(data, "glucose", "hba1c") {
        axes[1] = evaluateAxis1(data["glucose"], data["hba1c"], data["tg_hdl_ratio"])
    } else {
        axes[1] = "no_data"
    }
    
    // Axis 2: Lipid
    if hasData(data, "tg", "hdl") {
        axes[2] = evaluateAxis2(data["tg"], data["hdl"], gender)
    } else {
        axes[2] = "no_data"
    }
    
    // ... repeat for axes 3, 4, 5
    
    return axes
}
Testing Checklist
Before deploying engine logic, verify:
Unit conversion: glucose 5.5 mmol/L → 99.1 mg/dL → 🟢
Unit conversion: HbA1c 48 mmol/mol → 6.54% → Exclusion (diabetes)
Unit trap: hs-CRP 0.08 mg/dL → 0.8 mg/L → 🟡 (not 🟢!)
Gender-specific: HDL 45 mg/dL for female → 🟡, for male → 🟢
SDNN paradox: RMSSD 24ms, SDNN 216ms → 🟠 (Profile 5)
Graceful degradation: missing TSH → Axis 4 = no_data
Diabetes exclusion: glucose 130 mg/dL → flag for medical consultation
Hormonal modifier: PMS + RMSSD 28ms → Profile 5 (threshold reduced by 20%)