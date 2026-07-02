# Skill: Go Backend

## What you can do
- Create REST API handlers (gin/echo)
- Write service logic (business logic)
- Work with PostgreSQL via sqlx/pgx
- Implement middleware (auth, logging, rate limiting)
- Write unit tests and integration tests

## Project Structure
backend/
├── cmd/
│ └── api/
│ └── main.go
├── internal/
│ ├── handler/ # HTTP handlers
│ ├── service/ # Business logic
│ ├── repository/ # Database access
│ ├── model/ # Domain models
│ ├── dto/ # Data transfer objects
│ ├── middleware/ # Auth, logging, etc.
│ └── engine/ # MetaCart engine (axes, profiles)
├── pkg/
│ ├── config/ # Configuration
│ ├── logger/ # Structured logging
│ └── validator/ # Input validation
├── migrations/ # SQL migrations
└── tests/
├── integration/
└── e2e/


## Patterns
- **Handler**: validate input → call service → return DTO
- **Service**: business logic → call repository → return domain object
- **Repository**: SQL queries → return domain object
- **Engine**: rule-based logic → return profile

## Handler Example
```go
func (h *LabHandler) UploadLabResults(c *gin.Context) {
    // 1. Validate input
    var req dto.UploadLabRequest
    if err := c.ShouldBindJSON(&req); err != nil {
        c.JSON(400, ErrorResponse(err))
        return
    }
    
    // 2. Call service
    result, err := h.service.ProcessLabResults(c.Request.Context(), req)
    if err != nil {
        c.JSON(500, ErrorResponse(err))
        return
    }
    
    // 3. Return DTO
    c.JSON(200, SuccessResponse(result))
}

Service Example
func (s *LabService) ProcessLabResults(ctx context.Context, req dto.UploadLabRequest) (*model.LabResult, error) {
    // 1. Normalize units
    normalizedValues := s.normalizer.NormalizeAll(req.Values)
    
    // 2. Save to DB
    labResult := &model.LabResult{
        UserID:     req.UserID,
        Timepoint:  req.Timepoint,
        SampleDate: req.SampleDate,
    }
    if err := s.repo.CreateLabResult(ctx, labResult); err != nil {
        return nil, err
    }
    
    // 3. Evaluate axes
    axes := s.engine.EvaluateAxes(normalizedValues, req.Gender)
    
    // 4. Select profile
    profile := s.engine.SelectProfile(axes)
    
    // 5. Return result
    return labResult, nil
}

Testing
Unit tests for all services (mock repository)
Integration tests for all handlers (test database)
E2E tests for critical flows
What NOT to do
❌ Do not write SQL in handlers
❌ Do not hardcode configuration
❌ Do not log sensitive data (passwords, tokens)
❌ Do not return domain objects in API (only DTOs)

