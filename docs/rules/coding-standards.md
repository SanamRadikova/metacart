# Code Standards

## Go
- Go 1.21+
- gofmt + goimports
- golangci-lint (all rules enabled)
- All functions have unit tests
- All errors logged (structured logging)
- All SQL queries — via prepared statements (SQL injection protection)
- All handlers validate input data
- All services return domain objects, not DTOs
- All repositories work with sqlx or pgx

## Flutter
- Flutter 3.16+
- Dart 3.2+
- flutter_lints (all rules enabled)
- BLoC pattern for state management
- Riverpod for dependency injection
- All widgets have unit tests
- All screens have widget tests
- All API calls — via repository pattern
- All models — immutable (freezed)

## PostgreSQL
- All migrations — via golang-migrate
- All schema changes — via migrations (not manually)
- All indexes — justified (EXPLAIN ANALYZE)
- All functions — IMMUTABLE or STABLE (where possible)
- All views — for analytical queries (not for application)

## Testing
- Unit tests: >80% coverage
- Integration tests: all API endpoints
- E2E tests: critical user flows (onboarding, cart generation, drift analysis)
- Performance tests: load testing for API (1000 concurrent users)

## Documentation
- All public functions — with doc comments
- All API endpoints — with OpenAPI spec
- All migrations — with change description
- All configurations — with examples

## Git
- Conventional commits (feat:, fix:, docs:, refactor:, test:, chore:)
- Branch naming: feature/, bugfix/, hotfix/, release/
- PR review mandatory
- No direct commits to main/master