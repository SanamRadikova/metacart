# Medical Safety (CRITICAL)

## What MetaCart Does NOT do
- Does NOT diagnose
- Does NOT prescribe treatment
- Does NOT replace a doctor
- Is NOT a medical device
- Does NOT monitor diseases

## What MetaCart DOES
- Interprets metabolic patterns (functional, not diagnostic)
- Forms nutrition structure
- Forms grocery cart
- Supports healthy lifestyle

## Functional Thresholds
MetaCart uses functional thresholds (stricter than official):
- TSH >2.5 → Profile 4 (official: TSH >4.0 = subclinical hypothyroidism)
- hs-CRP >1.0 → Profile 3 (official: >3.0 = high risk)
- TG ≥100 → attention (official: ≥150 = high)

**MANDATORY in UX:** explain to user the difference between functional and diagnostic thresholds.

## Exceptions (require doctor consultation)
- Glucose ≥126 mg/dL or HbA1c ≥6.5% → show warning: "Possible diabetes. Consult your doctor."
- TSH >10 mIU/L → show warning: "Possible overt hypothyroidism. Consult your doctor."
- hs-CRP >10 mg/L → show warning: "Possible acute inflammation. Consult your doctor."
- Hemoglobin <10 g/dL → show warning: "Possible severe anemia. Consult your doctor."

## Nutraceuticals (Profile 5)
- ALWAYS show disclaimer: "Consult your doctor before use"
- User must explicitly confirm they read disclaimer
- Log confirmation in audit_log

## HRV and Heart Rate
- **Do NOT use heart rate (HR) as Axis 5 marker**
- Use only HRV: RMSSD, SDNN, PNN50
- Heart rate 102 BPM with HRV 36ms Normal ≠ problem (example from pilot)
- In UX, show heart rate only as context, not as diagnosis

## dG/dt
- Computed automatically from CGM data
- NOT entered manually by user
- At dG/dt < -0.7 → urgent notification: "Eat protein + fat now"
- At dG/dt < -0.3 → preventive reminder about snack

## SDNN Paradox
- If SDNN >150ms AND RMSSD <25ms → this is NOT health, but dysregulation
- Flag: "dysregulatory pattern" → Axis 5 = 🟠
- Explanation in UX: "Your autonomic system shows signs of dysregulation"

## Hormonal Modifier (women)
- PMS / luteal phase → Profile 5 threshold reduced by 20%
- Perimenopause → Profile 5 activated by default if symptoms present
- Postmenopause → enhanced protein emphasis in all profiles

## Audit Logging
- All profile changes logged
- All consents (research consent) logged with IP and device info
- All disclaimer confirmations logged
- Logs stored for 7 years (for research)