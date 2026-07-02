
### skills/engine-logic.md

```markdown
# Skill: MetaCart Engine Implementation

## What you can do
- Implement profile selection hierarchy (steps 0-4)
- Evaluate biomarkers by axes
- Compute dG/dt from CGM data
- Handle SDNN paradox
- Generate cart modifiers

## Engine Structure
internal/engine/
├── axes.go # Axis evaluation
├── profiles.go # Profile selection
├── modifiers.go # Modifier generation
├── dg_dt.go # dG/dt computation
└── engine.go # Main engine


## Axis Evaluation Example
```go
func (e *Engine) EvaluateAxis1(values NormalizedValues, gender string) AxisStatus {
    // Fasting glucose
    glucoseStatus := e.evaluateBiomarker("glucose_fasting", values.Glucose, gender)
    
    // HbA1c
    hba1cStatus := e.evaluateBiomarker("hba1c", values.HbA1c, gender)
    
    // TG/HDL ratio
    tgHdlRatio := values.Triglycerides / values.HDL
    tgHdlStatus := e.evaluateTgHdlRatio(tgHdlRatio)
    
    // Highest status wins
    return highestStatus(glucoseStatus, hba1cStatus, tgHdlStatus)
}

## Profile Selection Example
func (e *Engine) SelectProfile(axes Axes, hormonalStatus string) Profile {
    // Step 0: safety
    if axes.Axis5 == Orange || e.isSdnnParadox(axes) || e.isHormonalTrigger(hormonalStatus, axes) {
        return Profile{Number: 5, Step: 0}
    }
    
    // Step 1: high priority
    if axes.Axis4 == Orange {
        return Profile{Number: 4, Step: 1}
    }
    
    // Step 2: medium priority
    if axes.Axis3 == Orange {
        return Profile{Number: 3, Step: 2}
    }
    
    // Step 3: basic priority
    if axes.Axis1 == Yellow || axes.Axis1 == Orange || 
       axes.Axis2 == Yellow || axes.Axis2 == Orange {
        return Profile{Number: 2, Step: 3}
    }
    
    // Step 4: minimal priority
    return Profile{Number: 1, Step: 4}
}

## dG/dt Computation Example
func (e *Engine) ComputeDgDt(current, previous CGMReading) float64 {
    minutes := current.Time.Sub(previous.Time).Minutes()
    if minutes <= 0 {
        return 0
    }
    return (current.Glucose - previous.Glucose) / minutes
}

func (e *Engine) DgDtStatus(dgDt float64) string {
    switch {
    case dgDt > 0.5:
        return "rising"
    case dgDt >= -0.1:
        return "steady"
    case dgDt >= -0.3:
        return "slowly_falling"
    case dgDt >= -0.7:
        return "falling"
    default:
        return "rapidly_falling"
    }
}

Testing
Unit tests for all 243 axis combinations
Unit tests for all conversion traps
Integration tests for full flow (labs → axes → profile)
What NOT to do
❌ Do not hardcode thresholds (only from DB)
❌ Do not use ML at start (rule-based engine)
❌ Do not forget about Graceful Degradation
❌ Do not ignore SDNN paradox