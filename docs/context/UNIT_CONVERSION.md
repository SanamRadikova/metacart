# MetaCart — Unit Conversion & Normalization

## Overview

MetaCart receives laboratory data from users worldwide. Different countries and laboratories use different units of measurement. The engine **must normalize all values to standard US units** before evaluating biomarkers against reference ranges.

**Critical principle**: Never compare raw lab values against thresholds without first confirming and converting units. A single unit error can flip a 🟢 Stable to a 🟠 Deviation — or worse, miss a diabetes diagnosis.

**Standard units for the engine** (all internal processing uses these):

| Biomarker | Standard Unit |
|-----------|---------------|
| Fasting Glucose | mg/dL |
| HbA1c | % (NGSP/DCCT) |
| Triglycerides | mg/dL |
| HDL | mg/dL |
| LDL | mg/dL |
| hs-CRP | mg/L |
| TSH | mIU/L |
| HRV RMSSD | ms |
| SDNN | ms |
| PNN50 | % |
| dG/dt | mg/dL/min |
| ALT / AST | U/L |
| WBC | 10³/μL |
| Hemoglobin | g/dL |
| Insulin (fasting) | μIU/mL |
| Cortisol (morning) | μg/dL |

**Storage rule**: Always store **both** `value_original` (as in the lab report) and `value_normalized` (in standard units) in the database. This preserves audit trail and enables debugging.

---

## Quick Reference Table — All Conversions

| Biomarker | Source Unit | Target Unit | Conversion Type | Factor / Formula | Notes |
|-----------|-------------|-------------|-----------------|------------------|-------|
| **Glucose** | mg/dL | mg/dL | identity | × 1 | Already standard |
| **Glucose** | mmol/L | mg/dL | multiply | × 18.02 | Canada, Russia, EU |
| **HbA1c** | % | % | identity | × 1 | NGSP/DCCT standard |
| **HbA1c** | mmol/mol | % | **formula** | `(value / 10.929) + 2.15` | IFCC (EU, UK) — **NOT linear!** |
| **Triglycerides** | mg/dL | mg/dL | identity | × 1 | Already standard |
| **Triglycerides** | mmol/L | mg/dL | multiply | × 88.57 | European labs |
| **HDL** | mg/dL | mg/dL | identity | × 1 | Already standard |
| **HDL** | mmol/L | mg/dL | multiply | × 38.67 | European labs |
| **LDL** | mg/dL | mg/dL | identity | × 1 | Already standard |
| **LDL** | mmol/L | mg/dL | multiply | × 38.67 | European labs |
| **hs-CRP** | mg/L | mg/L | identity | × 1 | Already standard |
| **hs-CRP** | mg/dL | mg/L | multiply | × 10 | **TRAP**: some US labs use mg/dL! |
| **TSH** | mIU/L | mIU/L | identity | × 1 | Already standard |
| **TSH** | μIU/mL | mIU/L | identity | × 1 | Units are identical |
| **HRV (all)** | ms | ms | identity | × 1 | All devices use ms |
| **dG/dt** | mg/dL/min | mg/dL/min | identity | × 1 | Computed automatically |
| **dG/dt** | mmol/L/min | mg/dL/min | multiply | × 18.02 | Some CGMs (Libre) |
| **ALT / AST** | U/L | U/L | identity | × 1 | Universal |
| **WBC** | 10³/μL | 10³/μL | identity | × 1 | Universal |
| **Hemoglobin** | g/dL | g/dL | identity | × 1 | Universal |

---

## Detailed Conversions by Biomarker

### 1. Fasting Glucose

**Standard unit**: mg/dL (US standard)

**Common alternative**: mmol/L (Canada, Russia, EU, most of the world)

**Conversion formula**:
mg/dL = mmol/L × 18.02


**Molecular basis**: Glucose molecular weight = 180.16 g/mol. Conversion factor = 180.16 / 10 = 18.016 ≈ 18.02.

**Examples**:

| Source Value | Source Unit | Converted Value | Target Unit | Interpretation |
|--------------|-------------|-----------------|-------------|----------------|
| 5.5 | mmol/L | 99.1 | mg/dL | 🟢 Stable (70–90) — borderline 🟡 |
| 4.6 | mmol/L | 82.9 | mg/dL | 🟢 Stable |
| 6.1 | mmol/L | 109.9 | mg/dL | 🟠 Deviation (≥100) |
| 7.0 | mmol/L | 126.1 | mg/dL | ⚠️ **Exclusion** (diabetes) |
| 88 | mg/dL | 88 | mg/dL | 🟢 Stable (no conversion needed) |
| 107 | mg/dL | 107 | mg/dL | 🟠 Deviation |

**Reverse conversion** (for display to EU users):
mmol/L = mg/dL / 18.02


**Developer note**: Always confirm the unit from the lab report. If the user enters "5.5" without specifying units, **ask** — do not assume.

---

### 2. HbA1c (Glycated Hemoglobin)

**Standard unit**: % (NGSP/DCCT standard, used in US and Russia)

**Common alternative**: mmol/mol (IFCC standard, used in EU, UK, Australia)

**⚠️ CRITICAL: This is NOT a linear conversion!**

**Conversion formula**:
% = (mmol/mol / 10.929) + 2.15


**Reverse formula**:
mmol/mol = (% - 2.15) × 10.929

**Why it's not linear**: The IFCC (mmol/mol) and NGSP (%) standards use different reference methods. The relationship is affine (linear + offset), not proportional.

**Examples**:

| Source Value | Source Unit | Converted Value | Target Unit | Interpretation |
|--------------|-------------|-----------------|-------------|----------------|
| 48 | mmol/mol | 6.54 | % | ⚠️ **Exclusion** (diabetes, ≥6.5%) |
| 42 | mmol/mol | 5.99 | % | 🟠 Deviation (5.7–6.4%) |
| 36 | mmol/mol | 5.44 | % | 🟡 Attention (5.3–5.6%) |
| 31 | mmol/mol | 4.99 | % | 🟢 Stable (<5.3%) |
| 5.4 | % | 5.4 | % | 🟡 Attention (no conversion needed) |
| 6.5 | % | 6.5 | % | ⚠️ **Exclusion** |

**Common mistake to avoid**:
❌ WRONG: 48 mmol/mol × 0.0915 = 4.39% (treating as linear multiplier)
✅ RIGHT: (48 / 10.929) + 2.15 = 6.54%


**Developer note**: The `lab_units_reference` table stores this as `conversion_type = 'formula'` with `conversion_formula = '(value / 10.929) + 2.15'`. The engine must handle formula-based conversions separately from simple multipliers.

---

### 3. Triglycerides (TG)

**Standard unit**: mg/dL

**Common alternative**: mmol/L (European labs)

**Conversion formula**:
mg/dL = mmol/L × 88.57


**Molecular basis**: Triglyceride molecular weight ≈ 885.7 g/mol (average). Factor = 885.7 / 10 = 88.57.

**Examples**:

| Source Value | Source Unit | Converted Value | Target Unit | Interpretation |
|--------------|-------------|-----------------|-------------|----------------|
| 1.7 | mmol/L | 150.6 | mg/dL | 🟠 Deviation (≥150) |
| 1.13 | mmol/L | 100.1 | mg/dL | 🟡 Attention (100–149) |
| 0.85 | mmol/L | 75.3 | mg/dL | 🟢 Stable (<100) |
| 180 | mg/dL | 180 | mg/dL | 🟠 Deviation (no conversion) |

---

### 4. HDL Cholesterol

**Standard unit**: mg/dL

**Common alternative**: mmol/L (European labs)

**Conversion formula**:
mg/dL = mmol/L × 38.67


**Molecular basis**: Cholesterol molecular weight = 386.65 g/mol. Factor = 386.65 / 10 = 38.665 ≈ 38.67.

**Examples**:

| Source Value | Source Unit | Converted Value | Target Unit | Interpretation (♀) | Interpretation (♂) |
|--------------|-------------|-----------------|-------------|---------------------|---------------------|
| 1.3 | mmol/L | 50.3 | mg/dL | 🟢 Stable (>50) | 🟢 Stable (>40) |
| 1.0 | mmol/L | 38.7 | mg/dL | 🟠 Deviation (<40) | 🟡 Attention (35–40) |
| 1.86 | mmol/L | 71.9 | mg/dL | 🟢 Stable | 🟢 Stable |
| 65 | mg/dL | 65 | mg/dL | 🟢 Stable (♀) | 🟢 Stable (♂) |

**Developer note**: HDL thresholds are **gender-specific**. Always check user gender before evaluating. See `context/REFERENCE_RANGES.md` for details.

---

### 5. LDL Cholesterol

**Standard unit**: mg/dL

**Common alternative**: mmol/L

**Conversion formula**:
mg/dL = mmol/L × 38.67


Same factor as HDL (both are cholesterol molecules).

**Examples**:

| Source Value | Source Unit | Converted Value | Target Unit | Interpretation |
|--------------|-------------|-----------------|-------------|----------------|
| 2.6 | mmol/L | 100.5 | mg/dL | Optimal (<100) |
| 3.0 | mmol/L | 116.0 | mg/dL | Near optimal (100–129) |
| 4.1 | mmol/L | 158.5 | mg/dL | Borderline high (130–159) |

**Friedewald formula** (if LDL not directly measured):
LDL = Total_Cholesterol - HDL - (Triglycerides / 5)

All values in mg/dL. Valid only when TG < 400 mg/dL.

**Developer note**: LDL is **context only** — not used for axis evaluation. Stored for display.

---

### 6. hs-CRP (High-Sensitivity C-Reactive Protein)

**Standard unit**: mg/L

**⚠️ CRITICAL TRAP**: Some US laboratories report hs-CRP in **mg/dL** (not mg/L). Values differ by factor of 10!

**Conversion formula**:
mg/L = mg/dL × 10


**Examples**:

| Source Value | Source Unit | Converted Value | Target Unit | Interpretation |
|--------------|-------------|-----------------|-------------|----------------|
| 0.08 | mg/dL | 0.8 | mg/L | 🟡 Attention (0.8–1.0) |
| 0.05 | mg/dL | 0.5 | mg/L | 🟢 Stable (<0.8) |
| 0.8 | mg/dL | 8.0 | mg/L | 🟠 **Deviation** (>1.0) — **10× higher than it looks!** |
| 0.6 | mg/L | 0.6 | mg/L | 🟢 Stable (no conversion) |
| 1.4 | mg/L | 1.4 | mg/L | 🟠 Deviation |

**How to detect which unit the lab uses**:
1. **Heuristic**: If value < 1.0, it's likely mg/dL (because mg/L values are typically 0.5–10.0)
2. **Check lab report**: Look for unit label "mg/dL" or "mg/L"
3. **Check lab country**: Some US labs (Quest, LabCorp) use mg/dL; most others use mg/L
4. **Ask user**: If ambiguous, show both interpretations and ask them to confirm

**Developer note**: This is the #1 source of unit errors in MetaCart. Always validate hs-CRP units explicitly.

---

### 7. TSH (Thyroid-Stimulating Hormone)

**Standard unit**: mIU/L

**Common alternative**: μIU/mL

**Conversion formula**:
mIU/L = μIU/mL × 1 (IDENTICAL UNITS)


**Why they're identical**:
- mIU = milli-International Unit = 10⁻³ IU
- μIU = micro-International Unit = 10⁻⁶ IU
- But: mIU/L = (10⁻³ IU) / L and μIU/mL = (10⁻⁶ IU) / (10⁻³ L) = (10⁻³ IU) / L
- Therefore: mIU/L = μIU/mL

**Examples**:

| Source Value | Source Unit | Converted Value | Target Unit | Interpretation |
|--------------|-------------|-----------------|-------------|----------------|
| 1.8 | μIU/mL | 1.8 | mIU/L | 🟢 Stable (0.8–2.0) |
| 2.8 | μIU/mL | 2.8 | mIU/L | 🟠 Deviation (>2.5) |
| 3.5 | mIU/L | 3.5 | mIU/L | 🟠 Deviation (no conversion) |
| 0.5 | mIU/L | 0.5 | mIU/L | Below functional range (may need monitoring) |

**Developer note**: No conversion needed, but display both unit names so user understands they're equivalent.

---

### 8. HRV Metrics (RMSSD, SDNN, PNN50)

**Standard units**:
- RMSSD: ms (milliseconds)
- SDNN: ms
- PNN50: % (percentage)

**All devices use the same units**: Welltory, Oura, Apple Watch, Polar, Garmin — all report HRV in ms. No conversion needed.

**Caveat**: Different devices use different measurement methods (ECG vs PPG), which can introduce ±10–15% variation. For MetaCart purposes, this is acceptable — we're looking for gross patterns (<25 ms vs >40 ms), not precise values.

---

### 9. dG/dt (Glucose Velocity)

**Standard unit**: mg/dL/min

**Common alternative**: mmol/L/min (some CGMs, e.g., Libre)

**Conversion formula**:
mg/dL/min = mmol/L/min × 18.02


Same factor as glucose (because it's glucose per minute).

**⚠️ IMPORTANT**: dG/dt is **computed automatically** by the engine from raw CGM data. Users do NOT enter it manually.

**Computation formula**:
dG/dt = (G_current - G_previous) / time_in_minutes

Where:
- `G_current` and `G_previous` are consecutive CGM readings (in mg/dL)
- `time_in_minutes` is the time difference between readings (typically 5 minutes for Stelo/Dexcom, 1 minute for Libre)

**Examples**:

| G_previous | G_current | Time Delta | dG/dt (mg/dL/min) | Status |
|------------|-----------|------------|-------------------|--------|
| 120 | 118 | 5 min | -0.4 | Falling (warning) |
| 132 | 96 | 50 min | -0.72 | Rapidly falling (critical) |
| 95 | 98 | 5 min | +0.6 | Rising (normal) |
| 100 | 100 | 5 min | 0.0 | Steady (normal) |

**Developer note**: If CGM reports glucose in mmol/L, convert to mg/dL **before** computing dG/dt. Do not compute dG/dt in mmol/L/min and then convert — this introduces rounding errors.

---

### 10. Other Biomarkers (Context Only)

These biomarkers are stored but **not used for axis evaluation**:

| Biomarker | Standard Unit | Conversion Needed? |
|-----------|---------------|-------------------|
| ALT | U/L | No (universal) |
| AST | U/L | No (universal) |
| WBC | 10³/μL | No (universal) |
| Hemoglobin | g/dL | No (universal) |
| Insulin (fasting) | μIU/mL | No (universal) |
| Cortisol (morning) | μg/dL | Rare: nmol/L → μg/dL (÷ 2.76) |
| HOMA-IR | (calculated) | Computed: (Glucose × Insulin) / 405 |

**HOMA-IR formula** (if needed for research):
HOMA-IR = (Fasting_Glucose_mg_dL × Fasting_Insulin_μIU_mL) / 405

Or in SI units:
HOMA-IR = Fasting_Glucose_mmol_L × Fasting_Insulin_mIU_L / 22.5


---

## Critical Traps — Top 5 Unit Errors

### Trap #1: hs-CRP in mg/dL vs mg/L

**Severity**: 🔴 CRITICAL — can cause 10× misinterpretation

**Scenario**: Lab reports hs-CRP = 0.8 mg/dL. Developer treats it as mg/L.

**Result**:
- ❌ Wrong: 0.8 mg/L → 🟢 Stable (<0.8 is borderline, so this is 🟡)
- ✅ Right: 0.8 mg/dL = 8.0 mg/L → 🟠 Deviation (>1.0)

**Prevention**:
- Always check unit label on lab report
- If value < 1.0 and no unit specified, ask user to confirm
- Log both original value and unit in `lab_values` table

### Trap #2: HbA1c mmol/mol Treated as Linear

**Severity**: 🔴 CRITICAL — produces completely wrong values

**Scenario**: Lab reports HbA1c = 48 mmol/mol. Developer multiplies by 0.0915 (linear factor).

**Result**:
- ❌ Wrong: 48 × 0.0915 = 4.39% → 🟢 Stable (completely wrong!)
- ✅ Right: (48 / 10.929) + 2.15 = 6.54% → ⚠️ Exclusion (diabetes)

**Prevention**:
- Use formula-based conversion, not linear multiplier
- Store conversion type in `lab_units_reference` table (`formula` vs `multiply`)
- Unit test: 48 mmol/mol must equal 6.54%, not 4.39%

### Trap #3: Glucose mmol/L Treated as mg/dL

**Severity**: 🔴 CRITICAL — misses diabetes diagnosis

**Scenario**: User enters glucose = 7.0 (mmol/L). Developer treats it as mg/dL.

**Result**:
- ❌ Wrong: 7.0 mg/dL → way too low, likely error
- ✅ Right: 7.0 mmol/L = 126.1 mg/dL → ⚠️ Exclusion (diabetes)

**Prevention**:
- Always ask user to specify unit
- If value > 30, assume mg/dL (mmol/L values are typically 3–15)
- If value < 30, assume mmol/L (mg/dL values are typically 60–300)

### Trap #4: HDL Without Gender Context

**Severity**: 🟡 MEDIUM — causes false deviations

**Scenario**: HDL = 45 mg/dL. Developer uses male threshold (>40) for female user.

**Result**:
- ❌ Wrong (for female): 45 mg/dL → 🟡 Attention (40–50)
- ✅ Right (for female): 45 mg/dL → 🟡 Attention (correct, but for different reason)
- ✅ Right (for male): 45 mg/dL → 🟢 Stable (>40)

**Prevention**:
- Always pass gender to axis evaluation function
- Store gender in `users` table (required field)

### Trap #5: TSH μIU/mL vs mIU/L Confusion

**Severity**: 🟢 LOW — but causes user confusion

**Scenario**: User sees "μIU/mL" on lab report, thinks it's different from "mIU/L".

**Result**: No error (they're identical), but user may be confused.

**Prevention**:
- Display both unit names in UI: "TSH: 1.8 mIU/L (μIU/mL)"
- Add tooltip explaining they're equivalent

---

## Implementation Guide

### Database Schema (Reference Table)

```sql
CREATE TABLE lab_units_reference (
    id SERIAL PRIMARY KEY,
    biomarker VARCHAR(50) NOT NULL,
    source_unit VARCHAR(20) NOT NULL,
    target_unit VARCHAR(20) NOT NULL,
    conversion_type VARCHAR(20) NOT NULL CHECK (conversion_type IN ('identity', 'multiply', 'formula')),
    conversion_factor NUMERIC(12, 6),
    conversion_formula TEXT,
    notes TEXT,
    UNIQUE(biomarker, source_unit, target_unit)
);
Seeding the Reference Table
INSERT INTO lab_units_reference (biomarker, source_unit, target_unit, conversion_type, conversion_factor, conversion_formula, notes) VALUES
-- Glucose
('glucose_fasting', 'mg/dL', 'mg/dL', 'identity', 1, NULL, 'Already standard'),
('glucose_fasting', 'mmol/L', 'mg/dL', 'multiply', 18.02, NULL, 'Canada, Russia, EU'),

-- HbA1c
('hba1c', '%', '%', 'identity', 1, NULL, 'NGSP/DCCT standard'),
('hba1c', 'mmol/mol', '%', 'formula', NULL, '(value / 10.929) + 2.15', 'IFCC (EU, UK) — NOT linear!'),

-- Triglycerides
('triglycerides', 'mg/dL', 'mg/dL', 'identity', 1, NULL, 'Already standard'),
('triglycerides', 'mmol/L', 'mg/dL', 'multiply', 88.57, NULL, 'European labs'),

-- HDL
('hdl', 'mg/dL', 'mg/dL', 'identity', 1, NULL, 'Already standard'),
('hdl', 'mmol/L', 'mg/dL', 'multiply', 38.67, NULL, 'European labs'),

-- LDL
('ldl', 'mg/dL', 'mg/dL', 'identity', 1, NULL, 'Already standard'),
('ldl', 'mmol/L', 'mg/dL', 'multiply', 38.67, NULL, 'European labs'),

-- hs-CRP
('hs_crp', 'mg/L', 'mg/L', 'identity', 1, NULL, 'Already standard'),
('hs_crp', 'mg/dL', 'mg/L', 'multiply', 10, NULL, 'TRAP: some US labs use mg/dL!'),

-- TSH
('tsh', 'mIU/L', 'mIU/L', 'identity', 1, NULL, 'Already standard'),
('tsh', 'μIU/mL', 'mIU/L', 'identity', 1, NULL, 'Units are identical'),

-- dG/dt
('dg_dt', 'mg/dL/min', 'mg/dL/min', 'identity', 1, NULL, 'Computed automatically'),
('dg_dt', 'mmol/L/min', 'mg/dL/min', 'multiply', 18.02, NULL, 'Some CGMs (Libre)');

Go Implementation
package engine

import (
    "fmt"
    "strings"
)

// NormalizeLabValue converts a lab value from source unit to standard unit.
// Returns the normalized value and an error if conversion is not possible.
func NormalizeLabValue(biomarker string, value float64, sourceUnit string) (float64, error) {
    // Normalize unit names (case-insensitive, handle variations)
    sourceUnit = normalizeUnitName(sourceUnit)
    targetUnit := getStandardUnit(biomarker)
    
    // If already in standard unit, return as-is
    if sourceUnit == targetUnit {
        return value, nil
    }
    
    // Look up conversion in reference table
    conversion, err := getConversion(biomarker, sourceUnit, targetUnit)
    if err != nil {
        return 0, fmt.Errorf("no conversion found for %s from %s to %s: %w", 
            biomarker, sourceUnit, targetUnit, err)
    }
    
    // Apply conversion
    switch conversion.Type {
    case "identity":
        return value, nil
    case "multiply":
        return value * conversion.Factor, nil
    case "formula":
        return applyFormula(biomarker, value, conversion.Formula)
    default:
        return 0, fmt.Errorf("unknown conversion type: %s", conversion.Type)
    }
}

// applyFormula handles special formula-based conversions (e.g., HbA1c)
func applyFormula(biomarker string, value float64, formula string) (float64, error) {
    switch biomarker {
    case "hba1c":
        // HbA1c: % = (mmol/mol / 10.929) + 2.15
        return (value / 10.929) + 2.15, nil
    default:
        return 0, fmt.Errorf("no formula defined for biomarker: %s", biomarker)
    }
}

// normalizeUnitName standardizes unit names (handles variations like "mmol/l" vs "mmol/L")
func normalizeUnitName(unit string) string {
    unit = strings.TrimSpace(unit)
    unit = strings.ToLower(unit)
    
    // Common variations
    variations := map[string]string{
        "mg/dl":     "mg/dL",
        "mgdl":      "mg/dL",
        "mmol/l":    "mmol/L",
        "mmoll":     "mmol/L",
        "miu/l":     "mIU/L",
        "μiu/ml":    "μIU/mL",
        "mcu/ml":    "μIU/mL",
    }
    
    if normalized, ok := variations[unit]; ok {
        return normalized
    }
    return unit
}

// getStandardUnit returns the standard unit for a biomarker
func getStandardUnit(biomarker string) string {
    standardUnits := map[string]string{
        "glucose_fasting": "mg/dL",
        "hba1c":           "%",
        "triglycerides":   "mg/dL",
        "hdl":             "mg/dL",
        "ldl":             "mg/dL",
        "hs_crp":          "mg/L",
        "tsh":             "mIU/L",
        "dg_dt":           "mg/dL/min",
    }
    
    if unit, ok := standardUnits[biomarker]; ok {
        return unit
    }
    return "" // unknown biomarker
}
Flutter Implementation (Client-Side Validation)
class UnitConverter {
  /// Converts a lab value from source unit to standard unit.
  /// Returns null if conversion is not possible.
  static double? convert(String biomarker, double value, String sourceUnit) {
    final targetUnit = _getStandardUnit(biomarker);
    
    if (sourceUnit.toLowerCase() == targetUnit.toLowerCase()) {
      return value; // already in standard unit
    }
    
    switch (biomarker) {
      case 'glucose_fasting':
        if (sourceUnit == 'mmol/L') {
          return value * 18.02;
        }
        break;
      
      case 'hba1c':
        if (sourceUnit == 'mmol/mol') {
          return (value / 10.929) + 2.15;
        }
        break;
      
      case 'triglycerides':
        if (sourceUnit == 'mmol/L') {
          return value * 88.57;
        }
        break;
      
      case 'hdl':
      case 'ldl':
        if (sourceUnit == 'mmol/L') {
          return value * 38.67;
        }
        break;
      
      case 'hs_crp':
        if (sourceUnit == 'mg/dL') {
          return value * 10;
        }
        break;
      
      case 'tsh':
        if (sourceUnit == 'μIU/mL') {
          return value; // identical to mIU/L
        }
        break;
    }
    
    return null; // conversion not supported
  }
  
  static String _getStandardUnit(String biomarker) {
    const standardUnits = {
      'glucose_fasting': 'mg/dL',
      'hba1c': '%',
      'triglycerides': 'mg/dL',
      'hdl': 'mg/dL',
      'ldl': 'mg/dL',
      'hs_crp': 'mg/L',
      'tsh': 'mIU/L',
    };
    
    return standardUnits[biomarker] ?? '';
  }
  
  /// Detects likely unit based on value range (heuristic)
  static String? detectUnit(String biomarker, double value) {
    switch (biomarker) {
      case 'glucose_fasting':
        if (value > 30) return 'mg/dL'; // typical range: 60-300
        if (value < 30) return 'mmol/L'; // typical range: 3-15
        break;
      
      case 'hba1c':
        if (value > 10) return 'mmol/mol'; // typical range: 20-100
        if (value < 10) return '%'; // typical range: 4-10
        break;
      
      case 'hs_crp':
        if (value < 1.0) return 'mg/dL'; // typical range: 0.01-1.0
        if (value >= 1.0) return 'mg/L'; // typical range: 0.5-20.0
        break;
    }
    
    return null; // cannot detect
  }
}
Testing Checklist
Before deploying unit conversion logic, verify all these cases:
Glucose
5.5 mmol/L → 99.1 mg/dL → 🟢 Stable (borderline 🟡)
4.6 mmol/L → 82.9 mg/dL → 🟢 Stable
6.1 mmol/L → 109.9 mg/dL → 🟠 Deviation
7.0 mmol/L → 126.1 mg/dL → ⚠️ Exclusion (diabetes)
88 mg/dL → 88 mg/dL (no conversion) → 🟢 Stable
107 mg/dL → 107 mg/dL (no conversion) → 🟠 Deviation
HbA1c
48 mmol/mol → 6.54% → ⚠️ Exclusion (diabetes)
42 mmol/mol → 5.99% → 🟠 Deviation
36 mmol/mol → 5.44% → 🟡 Attention
31 mmol/mol → 4.99% → 🟢 Stable
5.4% → 5.4% (no conversion) → 🟡 Attention
CRITICAL: 48 mmol/mol must NOT equal 4.39% (linear multiplication error)
Triglycerides
1.7 mmol/L → 150.6 mg/dL → 🟠 Deviation
1.13 mmol/L → 100.1 mg/dL → 🟡 Attention
0.85 mmol/L → 75.3 mg/dL → 🟢 Stable
180 mg/dL → 180 mg/dL (no conversion) → 🟠 Deviation
HDL
1.3 mmol/L → 50.3 mg/dL → 🟢 Stable (♀), 🟢 Stable (♂)
1.0 mmol/L → 38.7 mg/dL → 🟠 Deviation (♀), 🟡 Attention (♂)
65 mg/dL → 65 mg/dL (no conversion) → 🟢 Stable (♀), 🟢 Stable (♂)
hs-CRP (CRITICAL TRAP)
0.08 mg/dL → 0.8 mg/L → 🟡 Attention (NOT 🟢!)
0.05 mg/dL → 0.5 mg/L → 🟢 Stable
0.8 mg/dL → 8.0 mg/L → 🟠 Deviation (10× higher than it looks!)
0.6 mg/L → 0.6 mg/L (no conversion) → 🟢 Stable
1.4 mg/L → 1.4 mg/L (no conversion) → 🟠 Deviation
TSH
1.8 μIU/mL → 1.8 mIU/L → 🟢 Stable
2.8 μIU/mL → 2.8 mIU/L → 🟠 Deviation
3.5 mIU/L → 3.5 mIU/L (no conversion) → 🟠 Deviation
dG/dt
CGM: 120 → 118 in 5 min → dG/dt = -0.4 mg/dL/min → Falling (warning)
CGM: 132 → 96 in 50 min → dG/dt = -0.72 mg/dL/min → Rapidly falling (critical)
CGM: 5.5 → 5.3 mmol/L in 5 min → convert to mg/dL first → dG/dt = -0.72 mg/dL/min
Sources & References
Biomarker
Conversion Source
Molecular Weight
Glucose
WHO, ADA 2024
180.16 g/mol
HbA1c
IFCC/NGSP alignment study 2007
N/A (affine formula)
Triglycerides
AHA/ACC 2023
~885.7 g/mol (average)
HDL / LDL
ESC/EAS 2019
386.65 g/mol (cholesterol)
hs-CRP
AHA/CDC 2003 Joint Statement
N/A (protein)
TSH
ATA 2012
N/A (hormone)
HRV
Task Force ESC/NASPE 1996
N/A (time domain)
Regulatory documents:
ADA Standards of Care 2024 (American Diabetes Association)
IFCC/NGSP HbA1c Standardization Program
AHA/ACC 2023 (American Heart Association / American College of Cardiology)
ESC/EAS 2019 (European Society of Cardiology / European Atherosclerosis Society)
ATA 2012 (American Thyroid Association)
AHA/CDC 2003 Joint Statement onMarkers of Inflammation
Task Force of ESC and NASPE 1996 (HRV standards)
