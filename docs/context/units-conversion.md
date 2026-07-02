# Unit Conversion

## Engine Standard
All data in engine stored in **US standard**: mg/dL, %, mg/L, mIU/L, ms.

## Conversion Table

| Biomarker | Standard | Unit A (US) | A→Standard | Unit B (Russia/EU) | B→Standard |
|-----------|----------|-------------|------------|---------------------|------------|
| Fasting Glucose | mg/dL | mg/dL | ×1 | mmol/L | **×18.02** |
| HbA1c | % (NGSP) | % | ×1 | mmol/mol (IFCC) | **÷10.929 + 2.15** |
| Triglycerides | mg/dL | mg/dL | ×1 | mmol/L | **×88.57** |
| HDL | mg/dL | mg/dL | ×1 | mmol/L | **×38.67** |
| LDL | mg/dL | mg/dL | ×1 | mmol/L | **×38.67** |
| hs-CRP | mg/L | mg/L | ×1 | **mg/dL** (some US labs!) | **×10** |
| TSH | mIU/L | mIU/L | ×1 | μIU/mL | ×1 (identical) |
| HRV RMSSD | ms | ms | ×1 | — | — |
| dG/dt | mg/dL/min | mg/dL/min | ×1 | mmol/L/min | **×18.02** |

## Critical Traps

### Trap 1: hs-CRP in mg/dL vs mg/L
Some US labs output hs-CRP in mg/dL, not mg/L.
- 0.08 mg/dL = 0.8 mg/L = normal
- 0.8 mg/dL = 8.0 mg/L = deviation!
**Solution**: always ask for unit from lab report.

### Trap 2: HbA1c in mmol/mol (Europe)
European labs output HbA1c in mmol/mol per IFCC standard.
- Formula: % = (mmol/mol ÷ 10.929) + 2.15
- Example: 48 mmol/mol → (48 ÷ 10.929) + 2.15 = 6.54%
**Solution**: use formula, not linear coefficient.

### Trap 3: HDL depends on gender
- Women: normal HDL >50 mg/dL
- Men: normal HDL >40 mg/dL
**Solution**: gender is required field, passed to Axis 2 evaluation function.

### Trap 4: TSH — functional vs diagnostic boundary
- Official normal: 0.4-4.0 mIU/L
- MetaCart functional normal: 0.8-2.0 mIU/L
- User with TSH 3.5 mIU/L in "official normal", but MetaCart activates Profile 4
**Solution**: explain difference in UX.

### Trap 5: dG/dt computed automatically
User does NOT enter dG/dt manually.
- Formula: dG/dt = (G_current - G_previous) / time_in_minutes
- Computed every 5 minutes from CGM data
**Solution**: compute on backend on new value insertion.

## Code Implementation

### Reference Table in DB
```sql
CREATE TABLE lab_units_reference (
    biomarker VARCHAR(50),
    source_unit VARCHAR(20),
    target_unit VARCHAR(20),
    conversion_type VARCHAR(20),  -- 'multiply' or 'formula'
    conversion_factor NUMERIC,
    conversion_formula TEXT
);

### Conversion Function (Go)
func NormalizeLabValue(biomarker string, value float64, sourceUnit string) (float64, error) {
    // 1. Find coefficient in reference table
    // 2. Apply conversion (for HbA1c — special formula)
    // 3. Return value in standard units
}

Unit Tests (mandatory!)
Glucose: 5.5 mmol/L → 99.1 mg/dL → 🟢
HbA1c: 48 mmol/mol → 6.54% → 🟠
hs-CRP: 0.08 mg/dL → 0.8 mg/L → 🟢
TSH: 3.5 mIU/L → 🟠 (despite official normal)
HDL: 45 mg/dL for woman → 🟡, for man → 🟢