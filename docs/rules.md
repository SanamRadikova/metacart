# MetaCart — Coding Rules & Standards

## 🎯 General Principles

1. **Readability over cleverness** — code is read more than written
2. **Explicit over implicit** — don't hide behavior
3. **Fail fast** — validate early, error clearly
4. **Test the critical path** — engine logic must have 100% coverage
5. **Document decisions** — if it's not obvious, write it down

## 📋 API Contract Rules (MANDATORY)

### Rule 1: OpenAPI YAML is the Single Source of Truth

**File**: `packages/shared/openapi/metacart-api.yaml`

**Rule**: Before implementing any API endpoint, you MUST:
1. Add the endpoint to `metacart-api.yaml`
2. Define request/response schemas in `components/schemas/`
3. Generate DTOs for Go and Flutter
4. Implement handler using generated DTOs

**Why**: This ensures frontend and backend stay in sync, enables automatic DTO generation, and provides a clear contract.

### Rule 2: Update YAML Before Writing Code

**Workflow**:
1. Read screen spec (e.g., `specs/screens/PHASE_1_ONBOARDING.md`)
2. Extract API requirements from "API Calls" section
3. Add endpoint to `metacart-api.yaml` with full schema
4. Generate DTOs: `make generate-dto`
5. Implement Go handler using generated DTOs
6. Implement Flutter API client using generated models
7. Test with contract tests

**Example**:
```bash
# 1. Add endpoint to YAML
vim packages/shared/openapi/metacart-api.yaml

# 2. Generate DTOs
cd packages/shared
make generate-dto

# 3. Implement backend
vim apps/api/internal/handlers/labs.go

# 4. Implement frontend
vim apps/mobile/lib/features/onboarding/api/labs_api.dart

Rule 3: Never Manually Create DTOs
Rule: All DTOs (Data Transfer Objects) must be generated from OpenAPI YAML.
Go:
// ❌ BAD: Manual DTO
type LabUploadRequest struct {
    Timepoint string `json:"timepoint"`
    Values    []LabValue `json:"values"`
}

// ✅ GOOD: Generated from OpenAPI
// File: apps/api/internal/dto/labs.go (generated)
type LabUploadRequest struct {
    Timepoint string `json:"timepoint"`
    Values    []LabValue `json:"values"`
}
Flutter:
// ❌ BAD: Manual model
class LabUploadRequest {
  final String timepoint;
  final List<LabValue> values;
  
  LabUploadRequest({required this.timepoint, required this.values});
}

// ✅ GOOD: Generated from OpenAPI
// File: apps/mobile/lib/core/api/dto/labs.dart (generated)
class LabUploadRequest {
  final String timepoint;
  final List<LabValue> values;
  
  LabUploadRequest({required this.timepoint, required this.values});
}
Rule 4: Screen Specs Reference YAML
Rule: Screen specs should reference OpenAPI endpoints, not duplicate them.
Example (in screen spec):
### API Calls

**Primary**:
- `POST /api/v1/labs/manual` (see `metacart-api.yaml#/paths/labs/manual`)
  - Request: `LabManualEntryRequest` (see `components/schemas/LabManualEntryRequest`)
  - Response: `LabResultResponse` (see `components/schemas/LabResultResponse`)
  Why: Avoids duplication, ensures single source of truth.
Rule 5: Contract Tests
Rule: Every endpoint must have contract tests that validate request/response against OpenAPI schema.
Go:
func TestLabManualEntry_Contract(t *testing.T) {
    // Load OpenAPI schema
    schema := loadOpenAPISchema("packages/shared/openapi/metacart-api.yaml")
    
    // Create request
    req := dto.LabManualEntryRequest{
        Timepoint: "baseline",
        Values: []dto.LabValue{
            {Biomarker: "glucose_fasting", Value: 88, Unit: "mg/dL"},
        },
    }
    
    // Validate against schema
    err := validateAgainstSchema(req, schema, "LabManualEntryRequest")
    assert.NoError(t, err)
}
Rule 6: Versioning
Rule: API version is in URL (/api/v1/...). When breaking changes needed:
Create /api/v2/...
Keep /api/v1/... for backward compatibility
Deprecate v1 after 6 months
Rule 7: Documentation
Rule: Every endpoint in YAML must have:
summary: One-line description
description: Detailed description (optional)
tags: Grouping (Auth, Labs, Analysis, Cart, Purchases, Drift)
parameters: Path/query parameters
requestBody: Request schema
responses: Response schemas (200, 400, 401, 404, 500)
Example:
/labs/manual:
  post:
    summary: Enter lab values manually
    description: |
      Manual entry of lab biomarkers. Used when OCR fails or user prefers typing.
      All values are normalized to standard units (mg/dL, %, mg/L, mIU/L).
    tags: [Labs]
    requestBody:
      required: true
      content:
        application/json:
          schema:
            $ref: '#/components/schemas/LabManualEntryRequest'
    responses:
      '200':
        description: Lab result created
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/LabResultResponse'
      '400':
        description: Invalid input
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/ErrorResponse'
      '401':
        description: Unauthorized
      '500':
        description: Internal server error
Rule 8: Error Handling
Rule: All API errors must follow standard format:
{
  "error": "VALIDATION_ERROR",
  "message": "Invalid input",
  "details": {
    "field": "glucose",
    "reason": "Value out of range"
  }
}
Standard error codes:
VALIDATION_ERROR — Invalid input (400)
UNAUTHORIZED — Not authenticated (401)
FORBIDDEN — Not authorized (403)
NOT_FOUND — Resource not found (404)
CONFLICT — Resource already exists (409)
INTERNAL_ERROR — Server error (500)

## 📝 Language-Specific Rules

### Go (Backend)

#### Naming

- **Packages**: lowercase, single word (`engine`, `handlers`, `services`)
- **Functions**: camelCase, verb-first (`calculateDrift`, `normalizeLabValue`)
- **Types**: PascalCase, noun (`UserProfile`, `LabResult`)
- **Constants**: PascalCase or SCREAMING_SNAKE_CASE (`MaxRetries`, `MAX_RETRIES`)
- **Interfaces**: `-er` suffix (`Repository`, `Converter`, `Validator`)

#### Error Handling

```go
// ✅ Good: wrap errors with context
func (s *LabService) ProcessLab(ctx context.Context, labID uuid.UUID) error {
    lab, err := s.repo.GetLab(ctx, labID)
    if err != nil {
        return fmt.Errorf("get lab %s: %w", labID, err)
    }
    // ...
}

// ❌ Bad: lose context
func (s *LabService) ProcessLab(ctx context.Context, labID uuid.UUID) error {
    lab, err := s.repo.GetLab(ctx, labID)
    if err != nil {
        return err  // No context!
    }
}

#### Dependencies
Use dependency injection (constructor injection)
No global state
No init() functions (except for registration)

// ✅ Good: explicit dependencies
type LabService struct {
    repo     LabRepository
    engine   Engine
    logger   Logger
}

func NewLabService(repo LabRepository, engine Engine, logger Logger) *LabService {
    return &LabService{repo: repo, engine: engine, logger: logger}
}

// ❌ Bad: global state
var globalRepo LabRepository

func ProcessLab() {
    globalRepo.GetLab()  // Where did this come from?
}



#### Concurrency
Use context.Context for cancellation and timeouts
Prefer channels over shared memory
Document goroutine lifecycles

// ✅ Good: context-aware
func (s *LabService) ProcessLab(ctx context.Context, labID uuid.UUID) error {
    ctx, cancel := context.WithTimeout(ctx, 30*time.Second)
    defer cancel()
    
    lab, err := s.repo.GetLab(ctx, labID)
    // ...
}



#### Database
Use sqlc or sqlx for type-safe queries
Never concatenate SQL strings (SQL injection risk)
Use transactions for multi-step operations
Always close rows (defer rows.Close())

// ✅ Good: parameterized query
func (r *LabRepository) GetLab(ctx context.Context, id uuid.UUID) (*Lab, error) {
    query := `SELECT id, user_id, timepoint FROM lab_results WHERE id = $1`
    var lab Lab
    err := r.db.QueryRowContext(ctx, query, id).Scan(&lab.ID, &lab.UserID, &lab.Timepoint)
    if err != nil {
        return nil, fmt.Errorf("scan lab: %w", err)
    }
    return &lab, nil
}

// ❌ Bad: string concatenation
func (r *LabRepository) GetLab(ctx context.Context, id uuid.UUID) (*Lab, error) {
    query := fmt.Sprintf(`SELECT * FROM lab_results WHERE id = '%s'`, id)  // SQL injection!
}

#### Flutter (Frontend)
Architecture
Feature-first structure (not layer-first)
Each feature is self-contained
Use BLoC or Cubit for state management
No business logic in widgets
// ✅ Good: feature structure
lib/
├── features/
│   ├── onboarding/
│   │   ├── screens/
│   │   │   └── upload_labs_screen.dart
│   │   ├── widgets/
│   │   │   └── lab_input_field.dart
│   │   ├── bloc/
│   │   │   └── upload_labs_bloc.dart
│   │   └── models/
│   │       └── lab_input.dart
│   └── analysis/
│       └── ...

// ❌ Bad: layer structure
lib/
├── screens/
│   ├── onboarding_screen.dart
│   └── analysis_screen.dart
├── widgets/
│   ├── lab_input.dart
│   └── axis_card.dart
└── blocs/
    ├── onboarding_bloc.dart
    └── analysis_bloc.dart

#### API Client
Generate from OpenAPI spec
Never manually construct HTTP requests
Handle errors centrally

// ✅ Good: generated client
class ApiClient {
  final Dio _dio;
  
  Future<LabResult> uploadLabs(LabInput input) async {
    final response = await _dio.post('/api/v1/labs', data: input.toJson());
    return LabResult.fromJson(response.data);
  }
}

// ❌ Bad: manual HTTP
Future<void> uploadLabs(LabInput input) async {
  final response = await http.post(
    Uri.parse('https://api.metacart.com/labs'),
    body: jsonEncode(input.toJson()),
  );
}

#### UI
Use design system (theme, colors, typography)
No hardcoded colors or sizes
Responsive design (mobile-first)

// ✅ Good: use theme
Text(
  'Your Profile',
  style: Theme.of(context).textTheme.headline6,
)

// ❌ Bad: hardcoded
Text(
  'Your Profile',
  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
)

#### PostgreSQL (Database)
Schema Design
Use UUID for primary keys (not SERIAL)
Always include created_at and updated_at
Use ENUM or CHECK constraints for limited values
Index foreign keys
-- ✅ Good: UUID, timestamps, constraints
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email VARCHAR(255) UNIQUE NOT NULL,
    gender VARCHAR(10) NOT NULL CHECK (gender IN ('male', 'female', 'other')),
    cohort_type VARCHAR(20) NOT NULL CHECK (cohort_type IN ('standard', 'deep_tracking')),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_users_cohort ON users(cohort_type);

-- ❌ Bad: SERIAL, no constraints
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    email VARCHAR(255),
    gender VARCHAR(10),
    cohort_type VARCHAR(20)
);

#### Queries
Use parameterized queries (never concatenate)
Use transactions for multi-step operations
Index columns used in WHERE, JOIN, ORDER BY
-- ✅ Good: parameterized, indexed
SELECT id, email, gender
FROM users
WHERE cohort_type = $1
  AND created_at > $2
ORDER BY created_at DESC;

-- ❌ Bad: string concatenation
SELECT * FROM users WHERE cohort_type = 'standard';  -- No parameterization

#### Migrations
Use incremental migrations (not full schema replacement)
Name migrations with timestamp: 20260101120000_create_users.sql
Always test migrations on a copy of production data

-- ✅ Good: incremental migration
-- migrations/20260101120000_create_users.sql
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email VARCHAR(255) UNIQUE NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- migrations/20260102120000_add_gender_to_users.sql
ALTER TABLE users ADD COLUMN gender VARCHAR(10) CHECK (gender IN ('male', 'female', 'other'));

#### 🧪 Testing Rules
Backend (Go)
Unit tests for engine logic (all 243 axis combinations)
Integration tests for API endpoints (with test DB)
Table-driven tests for multiple cases

// ✅ Good: table-driven test
func TestEvaluateAxis(t *testing.T) {
    tests := []struct {
        name     string
        axis     int
        values   map[string]float64
        expected string
    }{
        {
            name:     "glucose normal",
            axis:     1,
            values:   map[string]float64{"glucose": 88, "hba1c": 5.1},
            expected: "green",
        },
        {
            name:     "glucose elevated",
            axis:     1,
            values:   map[string]float64{"glucose": 107, "hba1c": 5.8},
            expected: "orange",
        },
    }
    
    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            result := EvaluateAxis(tt.axis, tt.values, "any")
            if result != tt.expected {
                t.Errorf("expected %s, got %s", tt.expected, result)
            }
        })
    }
}

#### Frontend (Flutter)
Widget tests for critical UI (drift dashboard, axes)
Integration tests for user flows (onboarding → profile → cart)
Golden tests for visual regression
// ✅ Good: widget test
testWidgets('AxisCard shows correct status', (WidgetTester tester) async {
  await tester.pumpWidget(
    MaterialApp(
      home: AxisCard(
        axisNumber: 1,
        axisName: 'Glycemic',
        status: 'green',
      ),
    ),
  );
  
  expect(find.text('Glycemic'), findsOneWidget);
  expect(find.byIcon(Icons.check_circle), findsOneWidget);
});

#### 📚 Documentation Rules
Code Comments
Why, not what — explain reasoning, not obvious code
Document public APIs — functions, types, interfaces
Use Godoc format (Go) and dartdoc (Flutter)
// ✅ Good: explains why
// EvaluateAxis determines the status of a metabolic axis based on biomarker values.
// It uses functional thresholds (stricter than diagnostic criteria) to identify
// early signs of metabolic dysfunction.
func EvaluateAxis(axis int, values map[string]float64, gender string) string {
    // ...
}

// ❌ Bad: explains what
// This function evaluates the axis
func EvaluateAxis(axis int, values map[string]float64, gender string) string {
    // ...
}
 
#### README Files
Every module should have a README:
# Module Name

## What It Does

Brief description of the module purpose.
## How to Use

```bash
# Example usage

#### Dependencies
List of dependencies

#### Testing
# How to run tests


## 🚫 Anti-Patterns to Avoid

1. **God objects** — classes/functions that do everything
2. **Magic numbers** — use named constants
3. **Deep nesting** — max 3 levels of indentation
4. **Comments that lie** — remove outdated comments
5. **Premature optimization** — profile first, optimize second
6. **Copy-paste code** — extract to functions
7. **Global state** — use dependency injection
8. **Ignoring errors** — handle or propagate explicitly

## ✅ Code Review Checklist

Before merging:

- [ ] Code follows naming conventions
- [ ] No hardcoded thresholds (use reference tables)
- [ ] Error handling is explicit
- [ ] Tests added for new logic
- [ ] Documentation updated (if public API changed)
- [ ] No TODO comments without issue numbers
- [ ] No commented-out code
- [ ] Dependencies are justified

## 📚 Further Reading

- `agent.md` — agent instructions
- `ARCHITECTURE.md` — technical architecture
- `DECISIONS.md` — architectural decisions
