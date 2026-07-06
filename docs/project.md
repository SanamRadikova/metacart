
---

### 3. `PROJECT.md`

```markdown
# MetaCart — Product Description

## 🎯 What is MetaCart?

MetaCart is a metabolic-to-grocery engine that helps people sustain healthy eating by managing their food environment — the groceries that end up in their home — adapted to both their metabolism and their cultural food traditions.

**Core insight**: Your environment shapes your behavior more than your motivation does. MetaCart focuses on changing the environment — starting with what goes in your grocery cart.

## 🔬 How It Works

MetaCart follows a four-step process:

### Step 1 — User Inputs Health Profile

- Routine lab results (bloodwork)
- Current symptoms and energy patterns
- Food preferences and dietary restrictions
- Cultural / ethnic foodways (required, not cosmetic)
- Lifestyle context (work schedule, stress)
- Optional: wearable device data (via Apple Health / Google Fit)

### Step 2 — MetaCart Creates Personalized Plan

- Health profile across five layers (mitochondrial resilience, neuro-autonomic stability, metabolic stability, behavioral sustainability, grocery environment)
- Culturally-adapted recommended food environment
- Grocery stability plan (structured list of supportive foods)

### Step 3 — System Generates Ready-to-Buy Grocery Cart

- Structured, categorized, exportable shopping list
- Healthier substitutions for common items
- Items pre-selected based on user's health profile
- One-tap export (CSV/PDF) — no direct retailer integration in beta

### Step 4 — System Tracks and Compares Environments ⭐ CORE DIFFERENTIATOR

- Capture what was **actually purchased** (manual entry + receipt photo)
- Compare recommended cart vs. actual purchases
- Surface drift over time (weekly trend)
- This becomes a **passive health signal** — no daily meal logging required

## 🧬 The Five Layers of Health

MetaCart uses a five-layer model to understand how body, nervous system, and daily habits interact:

| Layer | What It Measures |
|-------|------------------|
| **1. Mitochondrial Resilience** | How well your body produces and sustains energy |
| **2. Neuro-Autonomic Stability** | How your nervous system handles food and stress |
| **3. Metabolic Stability** | How well your metabolism handles what you eat |
| **4. Behavioral Sustainability** | How consistently you can stick to healthy habits |
| **5. Grocery Environment** | The food that actually ends up in your home |

**Cultural lens**: Every layer is interpreted through a cultural-metabolic lens. The same biomarker leads to different recommendations depending on food traditions.

## 🎯 Five Metabolic Profiles

Based on five metabolic axes, MetaCart assigns one primary profile:

| Profile | Name | When Activated |
|---------|------|----------------|
| **1** | Metabolic Flexibility | All 5 axes stable, HRV normal |
| **2** | Carb Sensitivity | Axis 1 or 2 elevated, HRV normal |
| **3** | Inflammatory Load | Axis 3 elevated, axes 4-5 not elevated |
| **4** | Stress-Adaptive | Axis 4 elevated, Profile 5 not activated |
| **5** | Neuro-Autonomic | Axis 5 elevated OR symptoms on dG/dt OR hormonal modifier active |

**Profile 5 is the most clinically important** — it explains symptoms in people with "normal labs but real symptoms" (dizziness, brain fog, fatigue) caused by fast glucose drops, not absolute glucose levels.

## 🛒 The Grocery Cart

The cart is generated in 5 steps:

1. Extract all ingredients from 7-day menu
2. Aggregate quantities (e.g., eggs = 14 per week)
3. Convert to trade units (14 eggs → 1 pack of 18)
4. Apply pricing tier (LOW / MID / HIGH)
5. Scale by household size

### Three Pricing Tiers

| Tier | Retailer Example | What's Included |
|------|------------------|-----------------|
| 🟢 LOW | Walmart, Aldi | Frozen, canned, store-brand |
| 🟡 MID | Costco, Target | Bulk packs, good value |
| 🔵 HIGH | Whole Foods | Organic, wild-caught, specialty |

**Nutritional logic doesn't change between tiers** — only quality and price of sources.

### Household Scaling

- Proteins / vegetables / fruits: × N people
- Grains / bread: stepped (1 person = 1 pack, 2-3 = 2 packs, 4+ = 3 packs)
- Oils / spices: slow scaling (1 bottle for 1-3 people)
- **Nutraceuticals (Profile 5): always × 1** — personal dose

## 📊 The Core Differentiator: Drift Analysis

Most health apps ask: "What did you eat?"

**MetaCart asks: "How far did your actual food environment drift from what your body needs?"**

This shift is significant:
- Logging meals requires constant effort → leads to guilt or abandonment
- MetaCart works **passively** — by comparing what you bought to what was recommended
- Detects patterns without requiring daily input

### What the System Detects

1. Increasing exposure to processed or inflammatory foods
2. Shopping patterns associated with stress, cravings, or fatigue
3. Signs of relapse before they fully take hold
4. Recovery speed after a difficult period
5. Long-term behavioral volatility vs. stability

## 🧪 Clinical Validation

MetaCart is built on a clinical validation study:

- **Deep Tracking Cohort**: ~50-75 users with CGM + HRV
- **Standard Cohort**: ~200 users with labs + grocery tracking
- **6 cultural groups**: Eastern European, South Asian, Latino, African-American, East Asian, Standard American
- **15-day protocol**: continuous monitoring + symptom logging

### Key Hypotheses

- **H1**: dG/dt (glucose velocity) predicts symptoms better than absolute glucose
- **H2**: HRV/SDNN predicts symptoms better than resting heart rate
- **H3**: Hyperreactive hunger is a marker of glucosensory hypersensitivity
- **H4**: Chaotic snacking lowers HRV independent of absolute glucose
- **H5**: SDNN is the most sensitive marker of recovery after food episodes
- **H6**: Cultural food patterns are predictable and reproducible

## 🏆 Proprietary Health Scores (Product Vision)

The platform produces five key scores (validated in pilot, not all at once):

| Score | What It Measures |
|-------|------------------|
| **Neuro-Metabolic Resilience Index** | Overall ability to sustain healthy behavior (master score) |
| **Grocery Stability Score** | How consistent and health-supportive your grocery purchases are |
| **Behavioral Recovery Index** | How quickly you return to healthy patterns after disruption |
| **Autonomic Food Response Score** | How your nervous system reacts to different food patterns |
| **Metabolic Sustainability Score** | Long-term ability to maintain stable energy and metabolic function |

**Note**: The pilot validates the core model beneath these scores, not all five indices at once.

## 🚫 What MetaCart is NOT

| MetaCart Does NOT | MetaCart DOES |
|-------------------|---------------|
| ✗ Diagnose conditions | ✓ Interpret metabolic patterns |
| ✗ Prescribe treatment | ✓ Form nutrition structure |
| ✗ Replace a doctor | ✓ Form grocery cart |
| ✗ Function as a medical device | ✓ Function as a preventive nutrition tool |
| ✗ Monitor diseases | ✓ Support healthy lifestyle |

**Nutraceuticals in Profile 5 cart always include disclaimer**: "Consult your doctor before taking supplements."

## 🎯 Beta Scope

The beta is a lean instrument for validation, not the full product.

### In Beta

- ✅ User-uploaded labs (manual / OCR / PDF)
- ✅ Cultural food profile (required)
- ✅ 5 axes + 5 profiles engine
- ✅ 7-day menu generation
- ✅ Grocery cart (exportable list)
- ✅ **Purchase capture + drift analysis (CORE!)**
- ✅ Apple Health / Google Fit integration (optional)
- ✅ Research consent flow
- ✅ Retention loop for second lab upload

### NOT in Beta (Roadmap)

- ❌ EHR / medical record integration (changes regulatory posture)
- ❌ Live retailer API checkout (Instacart / Walmart / Amazon Fresh)
- ❌ Electronic receipt import
- ❌ Condition-specific menus
- ❌ Expanded cultural cuisine sets (beyond 6 pilot groups)
- ❌ All 5 proprietary scores (pilot validates core model only)

## 📚 Further Reading

- `context/alghorithm.md` — detailed engine logic
- `context/REFERENCE_RANGES.md` — biomarker thresholds
- `context/CULTURAL_PATTERNS.md` — cultural food patterns
- `context/CLINICAL_VALIDATION.md` — research design
- `specs/MASTER_PLAN.md` — synchronization map
