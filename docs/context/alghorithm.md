# MetaCart Engine — Core Algorithm

## Overview

The MetaCart engine processes user biomarkers through a deterministic, rule-based pipeline to generate personalized nutrition recommendations. The engine operates in four sequential stages.

## Stage 1: Input Layer

The engine accepts three types of input data with varying levels of completeness.

### Level A — Laboratory Results (Minimum Required)

Standard bloodwork from annual health checkups. The engine can operate with only these data.

| Biomarker | Units | Purpose | Axis |
|-----------|-------|---------|------|
| Fasting Glucose | mg/dL | Carbohydrate metabolism | Axis 1 — Glycemic |
| HbA1c | % | 3-month average glucose | Axis 1 — Glycemic |
| Triglycerides (TG) | mg/dL | Lipid pattern | Axis 1 + Axis 2 |
| HDL | mg/dL | Protective cholesterol | Axis 2 — Lipid |
| LDL | mg/dL | Contextual cholesterol | Context (not an axis) |
| ALT | U/L | Liver function | Safety context |
| AST | U/L | Liver function | Safety context |
| WBC | 10³/μL | Immune status | Safety context |
| Hemoglobin | g/dL | Oxygen capacity | Safety context |
| hs-CRP | mg/L | Inflammation (if available) | Axis 3 — Inflammatory |
| TSH | mIU/L | Thyroid function (if available) | Axis 4 — Stress/Thyroid |

### Level B — Wearable Device Data (Optional, Increases Accuracy)

If user connects CGM (continuous glucose monitor) and/or HRV tracker, the engine receives real-time dynamic data. This activates Axis 5 and dynamic recommendations.

| Parameter | Source | What It Measures | Engine Purpose |
|-----------|--------|------------------|----------------|
| dG/dt | CGM: Stelo, Dexcom, Libre | Glucose velocity (mg/dL/min). Computed as: (G2 - G1) / (T2 - T1) | Main symptom predictor. Activates real-time dynamic recommendations. |
| HRV RMSSD | Welltory, Oura, Apple Watch, Polar | Heart rate variability — parasympathetic nervous system tone | Primary marker for Axis 5. Predicts symptoms better than heart rate. |
| SDNN | Same devices | Total variability. Includes both sympathetic and parasympathetic influences. | Distinguishes quality HRV from dysregulatory HRV. Important: high SDNN with low RMSSD = dysregulation. |
| PNN50 | Same devices | Percentage of high-variability intervals. Precise marker of parasympathetic tone. | Refining marker for Axis 5. Critical for phenotype differentiation. |
| Heart Rate (HR) | Same devices | Heart rate (BPM) | Contextual parameter. NOT a symptom predictor by itself — proven in pilot. |

**Why Heart Rate Is Insufficient — Developer Explanation**

In the pilot study, the user's heart rate was 102 BPM (bracelet showed HIGH), but HRV RMSSD was 36ms (Normal), SDNN 146ms (Good), PNN50 23% (Good). The user had symptoms — but the cause was hormonal phase, not cardiac pathology. This shows: heart rate is misleading. The engine must look at HRV RMSSD + SDNN + PNN50 as a complex, not at heart rate as a separate signal.

### Level C — Hormonal Modifier (Optional, for Women)

User selects from dropdown. This changes Axis 5 activation thresholds and Profile 5 recommendations.

| Status (dropdown) | Physiological Effect | Algorithm Change |
|-------------------|---------------------|------------------|
| Regular cycle — follicular phase | High estrogen → good insulin sensitivity and autonomic stability | Standard axis thresholds. No changes. |
| PMS / luteal phase | Estrogen drop → sympathetic hyperactivation, anxiety, autonomic instability, irritability | Profile 5 activation threshold reduced by 20%. Prioritize protein + fat. More frequent meals. |
| Perimenopause | Fluctuating estrogen → unpredictable HRV and glycemic responses. Any day may behave like PMS phase. | Profile 5 activated by default if any symptoms present. Extended protein component. Magnesium + omega-3 in cart. |
| Postmenopause | Stable low estrogen → moderate insulin resistance, reduced muscle mass | Enhanced protein emphasis in all profiles. Vitamin D + calcium in cart. |
| Not applicable (men) | — | Hormonal modifier not active. |

### Level D — Graceful Degradation (Operation with Incomplete Data)

The engine never blocks due to missing data. If some labs are missing, the axis is marked 'Insufficient data' and does not participate in profile selection.

| Mode | Available Data | Available Profiles | Accuracy |
|------|---------------|-------------------|----------|
| Minimal | Only glucose + TG/HDL | Profile 1, 2 | Basic nutrition structure |
| Basic | All laboratory (4 axes) | Profile 1, 2, 3, 4 | Good — by metabolic status |
| Extended | Labs + HRV (no CGM) | Profile 1, 2, 3, 4, 5 | High — including autonomic status |
| Full | Labs + CGM + HRV + hormonal | 1–5 + all modifiers | Maximum — real-time |

## Stage 2: Five Metabolic Axes — Detailed

The engine evaluates input data across 5 independent axes. Each axis receives one of three statuses: 🟢 Stable / 🟡 Attention / 🟠 Pronounced Deviation. These statuses form the basis for profile selection.

### Axis 1 — Glycemic

Reflects the body's ability to process carbohydrates. Higher axis = worse carbohydrate tolerance.

**What the engine uses:** Fasting Glucose + HbA1c + TG/HDL Ratio (as indirect marker of insulin resistance).

| Status | Fasting Glucose | HbA1c + TG/HDL | Clinical Meaning |
|--------|----------------|----------------|------------------|
| 🟢 Stable | 75–90 mg/dL | HbA1c 4.8–5.2% AND TG/HDL <1.5 | Good carbohydrate tolerance. Insulin works efficiently. |
| 🟡 Attention | 91–99 mg/dL | HbA1c 5.3–5.6% OR TG/HDL ≥2.0 | Initial signs of insulin resistance. Diet matters. |
| 🟠 Deviation | ≥100 mg/dL | HbA1c ≥5.7% OR TG/HDL ≥3.0 | Pre-diabetic pattern. Requires structural dietary change. |

**Algorithm logic:** If at least one of three indicators falls into 🟡 or 🟠 — the axis receives that status. Priority goes to the higher status.

### Axis 2 — Lipid

Reflects atherogenic lipid pattern associated with excess simple carbohydrates and saturated fats.

**What the engine uses:** Triglycerides (TG) + HDL + TG/HDL ratio.

| Status | Triglycerides | HDL | Clinical Meaning |
|--------|--------------|-----|------------------|
| 🟢 Stable | <100 mg/dL | >60 mg/dL (♀) / >50 (♂) | Healthy lipid profile. Reduced cardiovascular risk. |
| 🟡 Attention | 100–149 mg/dL | 40–60 mg/dL | Moderate atherogenic pattern. Worth adjusting fats and carbs. |
| 🟠 Deviation | ≥150 mg/dL | <40 mg/dL | Pronounced atherogenic pattern. Prioritize omega-3, Mediterranean diet type. |

### Axis 3 — Inflammatory

Reflects level of systemic chronic inflammation. Often related to diet quality — excess ultra-processed foods, sugar, alcohol.

**What the engine uses:** hs-CRP (high-sensitivity C-reactive protein). If not provided — axis marked 'No data' and does not participate in profile selection.

| Status | hs-CRP | What This Means | What Algorithm Does |
|--------|--------|-----------------|---------------------|
| 🟢 Stable | <0.8 mg/L | No inflammatory load | Inflammatory axis not active in profile selection |
| 🟡 Attention | 0.8–1.0 mg/L | Subclinical inflammation | Adds omega-3 as modifier to any profile |
| 🟠 Deviation | >1.0 mg/L | Chronic inflammatory load | Activates Profile 3 (if no higher-priority axes) |

### Axis 4 — Stress / Thyroid

Reflects thyroid function and neuroendocrine stress adaptation. Elevated TSH indicates the body is in energy-conservation mode.

**Important for algorithm:** If this axis is active — aggressive dietary restrictions (low-calorie diets, intermittent fasting) may cause harm. Therefore Axis 4 has high safety priority.

| Status | TSH | What This Means | What Algorithm Does |
|--------|-----|-----------------|---------------------|
| 🟢 Stable | 0.8–2.0 mIU/L | Normal thyroid function | No restrictions |
| 🟡 Attention | 2.0–2.5 mIU/L | Suboptimal function | Adds iodine and selenium as cart modifiers |
| 🟠 Deviation | >2.5 mIU/L | Hypothyroidism / stress adaptation. Metabolism slowed. | Activates Profile 4. Prohibition on aggressive calorie restriction. |

### Axis 5 — Neuro-Autonomic (HRV)

Reflects balance between sympathetic and parasympathetic nervous systems. This is the newest axis — added based on clinical observations.

**Why this matters:** Some people with normal laboratory values experience real physical symptoms (shakiness, motion sickness sensation, lump in throat, weakness) — with completely normal glucose. These symptoms are explained by autonomic dysregulation and glucose velocity (dG/dt), not absolute glucose level.

| Status | HRV RMSSD | SDNN | PNN50 | Clinical Meaning |
|--------|-----------|------|-------|------------------|
| 🟢 Stable | >40 ms | 80–180 ms | >20% | Healthy autonomic balance. Good metabolic flexibility. |
| 🟡 Attention | 25–40 ms | 50–80 ms | 10–20% | Reduced parasympathetic tone. Subclinical autonomic dysregulation. |
| 🟠 Deviation | <25 ms | <50 ms OR >200ms with RMSSD<25 | <10% | Constitutional autonomic dysregulation. Symptoms with normal glucose. Activates Profile 5. |

**Important: SDNN Paradox — How Engine Recognizes It**

Sometimes SDNN can be high (>150 ms) with low RMSSD (<25 ms). Example: RMSSD 24ms with SDNN 216ms. This is NOT a sign of health — this is dysregulatory variability: sympathetic system is hyperactive and creates chaotic large deviations, but quality parasympathetic activity (which RMSSD measures) remains low.

**Rule for engine:** If SDNN > 150ms AND RMSSD < 25ms → flag 'dysregulatory pattern' → counts as 🟠 for Axis 5.

### Dynamic Parameter dG/dt — Glucose Velocity

This is not a separate axis, but the most important symptom predictor for Profile 5 users. Computed automatically from CGM data every 5 minutes.

**Formula:** dG/dt = (G_current - G_previous) / time_in_minutes

| dG/dt Value | What's Happening | Symptom Risk for Profile 5 | Engine Action |
|-------------|------------------|---------------------------|---------------|
| >0 (Rising) | Glucose rising | No | Notification if rise is fast (>1.5 mg/min) |
| 0 (Steady) | Glucose stable | No | Normal, no notifications |
| -0.1 to -0.3 (Slowly Falling) | Slow decline | Low — possible mild discomfort | Preventive snack reminder |
| -0.3 to -0.7 (Falling) | Active decline | High — shakiness, discomfort | Notification: 'Eat protein + fat now' |
| < -0.7 (Rapidly Falling) | Rapid decline | Very high — pronounced symptoms | Urgent notification + recommendation |

### HRV Metrics Explained — What Each Indicator Means

For developers, it's important to understand what each HRV parameter measures — because they reflect different physiological processes and are not interchangeable.

| Parameter | What It Measures | In Simple Terms | Why It Matters for Engine |
|-----------|------------------|-----------------|---------------------------|
| HRV RMSSD | Root mean square of successive differences between adjacent RR intervals | How much the heart 'breathes' from beat to beat. High RMSSD = parasympathetic active, body in recovery/rest mode. Low RMSSD = sympathetic dominates, body in stress/protection mode. | Main marker for Axis 5. Most accurate predictor of autonomic state. This is what drops during symptoms in Profile 5. |
| SDNN | Standard deviation of all RR intervals over measurement period | Overall variability range — includes both sympathetic and parasympathetic influences, and slower rhythms (breathing, temperature, pressure). Reflects overall autonomic tone, not just parasympathetic. | Needed to identify paradox: high SDNN with low RMSSD = dysregulatory variability (chaotic sympathetic activity), not health. This is a flag for Profile 5. |
| PNN50 | Percentage of adjacent RR interval pairs differing by >50 ms | How many heartbeats have significant variability. High PNN50 = many 'live', variable beats = good parasympathetic tone. Low = beats are monotonous, nervous system 'tense'. | Refines RMSSD. Especially important for phenotype separation: in pilot, Profile 5 (symptomatic) had PNN50 24% with HRV 34ms, while Profile B (asymptomatic) had PNN50 6% with HRV 38ms. Almost identical HRV, but radically different PNN50. |
| CoV | Coefficient of variation of RR intervals | Relative variability accounting for heart rate. Useful when two people have different baseline heart rates — normalizes comparison. | Additional contextual marker. Not used as primary profile activation threshold. |
| Heart Rate HR | Beats per minute | Heart speed. Does not reflect quality of autonomic regulation. Heart rate 102 can be with excellent HRV (physical activity) and with poor HRV (stress, sympathetic storm). | NOT a marker for Axis 5. Used only for display to user. Example from pilot: heart rate 102 HIGH with HRV 36 Normal and PNN50 23% Good — bracelet panicked, but autonomic status was fine. |

### How to Read HRV in Combination — Rules for Code

- **RMSSD is primary.** If RMSSD < 25ms → Axis 5 = 🟠 regardless of other indicators.
- **SDNN helps identify dysregulation:** If SDNN > 150ms AND RMSSD < 25ms → this is NOT a good sign. This is dysregulatory pattern → Axis 5 = 🟠.
- **PNN50 refines:** If RMSSD is borderline (25–35ms), look at PNN50. If PNN50 < 10% → lean toward 🟡. If PNN50 > 20% → lean toward 🟢.
- **Ignore heart rate for profile selection** — use only for display to user.

## Stage 3: Five Metabolic Profiles — Detailed

Based on the statuses of five axes, the engine selects one primary profile. There are five profiles total.

### Profile 1 — Metabolic Flexibility

**Who this is:** Person with good labs and good HRV. Body efficiently switches between energy sources (carbs ↔ fats), responds well to diverse foods. Insulin works normally, no inflammation, thyroid normal, autonomic system balanced.

**Engine goal:** Maintain this state, not restrict.

### Profile 2 — Carb Sensitivity

**Who this is:** Person whose fasting glucose is elevated, HbA1c at upper limit or above, TG/HDL ratio poor. Pancreas works, but insulin needs more effort to remove sugar from blood — this is called insulin resistance. Every intake of fast carbs gives disproportionately high glucose spike and slow return to normal. Mood and energy depend on these spikes. HRV is normal — no autonomic symptoms.

### Profile 3 — Inflammatory Load

**Who this is:** Person with elevated hs-CRP — marker of chronic systemic inflammation. Often this results from diet with many ultra-processed foods, added sugar, alcohol, refined oils. Inflammation constantly 'smolders' at low level — not acute disease, but background process that worsens insulin sensitivity, burdens blood vessels, reduces immunity. Person may not feel anything specific, but labs show the picture.

### Profile 4 — Stress-Adaptive

**Who this is:** Person with elevated TSH — thyroid works slower than normal. This may be subclinical hypothyroidism or physiological response to prolonged stress (HPA axis suppresses thyroid function). Metabolism slowed: person tires quickly, feels cold, gains weight even with moderate eating, recovers worse. Aggressive diets and intermittent fasting in this state may worsen the problem — body enters even greater conservation mode.

### Profile 5 — Neuro-Autonomic

**Who this is:** Person with constitutional autonomic dysregulation. Labs may be completely normal — glucose, HbA1c, hs-CRP, TSH — all normal. But HRV is chronically low, and person experiences real physical symptoms: shakiness, motion sickness sensation, lump in throat, weakness — with normal glucose level. Symptoms appear not from absolute glucose level, but from speed of its drop (dG/dt). Hypothalamic neurons sense not glucose level itself, but speed of its change inside the cell. Rapid drop triggers catecholamine cascade — adrenaline and noradrenaline release — causing vestibular-autonomic response.

In post-Soviet medicine, such person receives diagnosis VSD (vegetative-vascular dystonia) — without understanding the mechanism. In Western medicine, their symptoms are often considered functional or psychosomatic. MetaCart gives this objective biomarker explanation.

### Profile Selection Logic

| # | Name | Activation Condition | Main Principle | Cart Emphasis |
|---|------|---------------------|----------------|---------------|
| 1 | Metabolic Flexibility | All 5 axes = 🟢, HRV normal | Supportive mode. Diverse nutrition. | Seasonal products, quality, variety |
| 2 | Carb Sensitivity | Axis 1 or 2 = 🟡/🟠, HRV normal (Profile 5 not activated) | Protein first. Slow carbs. Fiber as buffer. | Eggs, legumes, fish, non-starchy vegetables |
| 3 | Inflammatory Load | Axis 3 = 🟠, Axes 4-5 not activated | Maximize reduction of ultra-processed foods. Omega-3. Antioxidants. | Wild salmon, berries, turmeric, olive oil, green leafy |
| 4 | Stress-Adaptive | Axis 4 = 🟠 (TSH high), Profile 5 not activated | Regular meals. No aggressive restrictions. Moderate iodine. | Whole foods, sea fish, magnesium, adaptogens |
| 5 | Neuro-Autonomic | Axis 5 = 🟠 OR symptoms on dG/dt OR hormonal modifier active | Stabilize glycemic curve. Protein + fat in every meal. Frequent eating. | Eggs, burrata, avocado, Greek yogurt, wild salmon, CoQ10, omega-3 |

### Profile 5 — Neuro-Autonomic (Detailed Description)

This is the newest and most clinically important profile. It explains symptoms in people doctors traditionally consider 'healthy by labs'.

**Who is the Profile 5 user:**
1. Labs normal — glucose, HbA1c, hs-CRP, TSH — all good
2. HRV chronically low (20–34 ms) with normal heart rate
3. Experiences symptoms with normal glucose: shakiness, motion sickness sensation, lump in throat, weakness, irritability
4. Symptoms appear when glucose drops quickly — even if it remains normal itself (e.g., from 132 to 96 in 50 minutes)
5. Often since childhood: low energy, nocturia, low blood pressure, tendency to motion sickness
6. In post-Soviet medicine diagnosed as VSD (vegetative-vascular dystonia) — without understanding mechanism

**Mechanism:** Neurons in ventromedial hypothalamus (VMH) respond to speed of glucose change inside the cell. With rapid drop, intracellular ATP decreases faster than it can replenish — even with normal absolute glucose level. This triggers catecholamine cascade (adrenaline, noradrenaline) → vestibular-autonomic response → symptoms.

### Profile 5 Nutrition Principles

1. Every meal = protein + fat + fiber. Never fast carbohydrates alone.
2. Meals every 3–4 hours. Don't skip. Don't do long fasting intervals.
3. Breakfast: prioritize protein and fat (eggs, Greek yogurt, burrata, avocado, nuts).
4. Dinner: protein-fat (borscht with meat, fish, chicken). Avoid pure carbohydrates in evening.
5. 1 minute of light movement after eating — reduces postprandial peak by 42% (proven in RCT).
6. Exclude: Z-Bar and similar bars, fruit yogurts without protein, juices, processed cereals.

### What Goes in Profile 5 Cart

1. **Base:** eggs, Greek yogurt (full-fat), burrata/mozzarella, avocado, wild salmon, walnuts, bacon (natural)
2. **Vegetables:** beets, cabbage, carrots (borscht components), spinach, cucumbers, tomatoes
3. **Nutraceuticals** (with note 'consult your doctor'): CoQ10 200mg, Omega-3 1–2g EPA/DHA, Inositol 2g, Vitamin D3 2000 IU
4. **Exclude from cart:** bars, packaged cereals, fruit juices, processed snacks

## Stage 4: Profile Selection — Logic and All Combinations

This is the most important part for developers. The engine uses hierarchical logic: first checks condition with highest priority (safety), then descends.

### Profile Selection Hierarchy — Step-by-Step Algorithm

| Step | Priority | Condition (checked in this order) | Result |
|------|----------|-----------------------------------|--------|
| 0 | HIGHEST Symptoms + safety | IF (Axis 5 = 🟠) OR (SDNN > 150ms AND RMSSD < 25ms) OR (dG/dt < -0.7 documented AND symptoms) OR (Hormonal modifier = PMS/Perimenopause AND HRV < 35ms) | → Profile 5 (Neuro-Autonomic) |
| 1 | HIGH Safety restriction | IF Step 0 did NOT trigger AND (Axis 4 = 🟠) | → Profile 4 (Stress-Adaptive) |
| 2 | MEDIUM Systemic effect | IF Steps 0 and 1 did NOT trigger AND (Axis 3 = 🟠) | → Profile 3 (Inflammatory) |
| 3 | BASIC Structural pattern | IF Steps 0–2 did NOT trigger AND (Axis 1 = 🟡/🟠 OR Axis 2 = 🟡/🟠) | → Profile 2 (Carb Sensitivity) |
| 4 | MINIMAL Supportive | IF all steps 0–3 did NOT trigger (all axes 🟢, HRV normal) | → Profile 1 (Metabolic Flexibility) |

### How Many Axis Combinations Exist

Each of 5 axes has 3 possible statuses (🟢/🟡/🟠). Mathematically this gives 3⁵ = 243 possible combinations.

However, the hierarchical algorithm reduces all 243 combinations to 5 profiles by principle 'highest priority wins'. This means: developer does not need to write 243 cases — enough to implement 5 sequential conditions (steps 0–4).

### Secondary Axes as Modifiers

When primary profile is selected, remaining active axes (with status 🟡 or 🟠) become modifiers — they add specific products or nutraceuticals to cart, without changing overall profile.

| Primary Profile | Active Secondary Axis | What Added to Cart | What Does NOT Change |
|----------------|----------------------|-------------------|----------------------|
| Profile 2 (carb) | Axis 3 🟡 (inflammation) | Add: fatty fish 2×/week, flaxseed oil, turmeric | Menu structure remains Profile 2 |
| Profile 4 (stress) | Axis 1 🟡 (glycemic) | Add: fiber before meals, limit fast carbs | No aggressive restrictions — Profile 4 principle preserved |
| Profile 5 (neuro) | Axis 3 🟠 (inflammation) | Enhance: omega-3 to 2g/day, add berries, exclude alcohol | Profile 5 curve stabilization principle preserved |
| Profile 5 (neuro) | Axis 2 🟡 (lipids) | Add: olive oil, nuts, avocado — limit saturated fats | Protein + fat in every meal remains main |
| Profile 3 (inflammatory) | Axis 4 🟡 (thyroid) | Add: iodine (kelp), selenium — limit raw cabbage | Profile 3 anti-inflammatory strategy preserved |

### Real Combination Examples — How Engine Makes Decisions

**Example 1: Woman 47 years, perimenopause**

**Data:**
- Glucose 88 ✅, HbA1c 5.1% ✅, TG/HDL 1.3 ✅, hs-CRP 0.6 ✅, TSH 1.8 ✅
- HRV RMSSD 24ms 🟠, SDNN 140ms, PNN50 13% — normal, but RMSSD low
- Hormonal status: Perimenopause

**Step 0:** Axis 5 = 🟠 (RMSSD < 25ms) → CONDITION TRIGGERED → Result: Profile 5 (Neuro-Autonomic)

**Secondary modifiers:** none (all other axes 🟢)

**Cart:** eggs, burrata, Greek yogurt, avocado, wild salmon, CoQ10, omega-3, vitamin D

---

**Example 2: Man 52 years, chaotic eating**

**Data:**
- Glucose 107 🟠, HbA1c 5.8% 🟠, TG 180 🟠, HDL 42 🟡, hs-CRP 0.5 ✅, TSH 1.6 ✅
- HRV RMSSD 38ms ✅ — normal
- Hormonal status: Not applicable

**Step 0:** Axis 5 = 🟢 → did not trigger
**Step 1:** Axis 4 = 🟢 → did not trigger
**Step 2:** Axis 3 = 🟢 → did not trigger
**Step 3:** Axis 1 = 🟠 OR Axis 2 = 🟠 → CONDITION TRIGGERED → Result: Profile 2 (Carb Sensitivity)

**Secondary modifiers:** Axis 2 🟡 (HDL low) → add omega-3, olive oil to cart

**Cart:** eggs, legumes, non-starchy vegetables, fish, olive oil, omega-3

---

**Example 3: Woman 35 years, chronic stress + inflammation**

**Data:**
- Glucose 82 ✅, HbA1c 5.0% ✅, TG 95 ✅, HDL 65 ✅, hs-CRP 1.4 🟠, TSH 2.8 🟠
- HRV RMSSD 45ms ✅ — normal
- Hormonal status: Regular cycle

**Step 0:** Axis 5 = 🟢 → did not trigger
**Step 1:** Axis 4 = 🟠 (TSH 2.8 > 2.5) → CONDITION TRIGGERED → Result: Profile 4 (Stress-Adaptive)

**Secondary modifiers:** Axis 3 🟠 (hs-CRP high) → add fatty fish 3×/week, berries, exclude alcohol, exclude ultra-processed

**Note:** hs-CRP is high, but Profile 3 is NOT activated, because TSH has higher priority. Inflammation is processed as modifier.

**Cart:** whole foods, sea fish (iodine), fatty fish (omega-3), berries, magnesium, NO aggressive calorie restriction

## Push Notifications and Dynamic Recommendations

Next level after static cart — dynamic real-time notifications (only with connected CGM and/or HRV).

| Trigger | Notification to User | Only For |
|---------|---------------------|----------|
| dG/dt < -0.3 mg/dL/min (Slowly Falling) | "Glucose starting to drop — good time for small protein snack" | Profile 5 + CGM connected |
| dG/dt < -0.7 mg/dL/min (Rapidly Falling) | "Glucose dropping fast — eat protein + fat right now (egg, yogurt, nuts)" | Profile 5 + CGM |
| HRV RMSSD < 20ms in morning | "Your HRV is low today — especially important not to skip meals and add protein to each" | Profile 5 + HRV |
| >4 hours passed without food (Profile 5) | "Time to eat — long intervals may worsen symptoms" | Profile 5 |
| Evening (18:00–19:00) | "1 minute of movement after dinner reduces postprandial peak by 42%" | All profiles |
| User noted symptoms | "Write down: what you ate, when, what was glucose — this will help tune your recommendations more precisely" | All profiles with CGM |

## Legal Position

| MetaCart Does NOT | MetaCart DOES |
|-------------------|---------------|
| ✗ Does not diagnose | ✓ Interprets metabolic patterns |
| ✗ Does not prescribe treatment | ✓ Forms nutrition structure |
| ✗ Does not replace doctor | ✓ Forms grocery cart |
| ✗ Is not a medical device | ✓ Is a preventive nutrition tool |
| ✗ Does not monitor diseases | ✓ Supports healthy lifestyle |

Nutraceuticals in Profile 5 cart always accompanied by note: "Consult your doctor before use."

dG/dt and HRV data used exclusively for nutrition recommendation personalization — not for medical diagnosis.