
### skills/database.md

```markdown
# Skill: PostgreSQL + TimescaleDB

## What you can do
- Create tables with correct data types
- Write migrations via golang-migrate
- Create indexes (justified)
- Work with TimescaleDB hypertables
- Write SQL functions (IMMUTABLE, STABLE)
- Create views for analysts

## Migrations
migrations/
├── 000001_init_schema.up.sql
├── 000001_init_schema.down.sql
├── 000002_add_lab_units_reference.up.sql
├── 000002_add_lab_units_reference.down.sql
└── ...


## Migration Example
```sql
-- 000001_init_schema.up.sql
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email VARCHAR(255) UNIQUE NOT NULL,
    gender VARCHAR(10) NOT NULL CHECK (gender IN ('male', 'female', 'other')),
    cohort_type VARCHAR(20) NOT NULL DEFAULT 'standard',
    cultural_group VARCHAR(30) NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TRIGGER users_updated_at
    BEFORE UPDATE ON users
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

## TimescaleDB
-- Create hypertable
CREATE TABLE device_readings (
    time TIMESTAMPTZ NOT NULL,
    user_id UUID NOT NULL,
    reading_type VARCHAR(30) NOT NULL,
    value NUMERIC(10, 3) NOT NULL,
    PRIMARY KEY (time, user_id, reading_type)
);

SELECT create_hypertable('device_readings', 'time');

-- Compress after 30 days
SELECT add_compression_policy('device_readings', INTERVAL '30 days');

Indexes
Always justify (EXPLAIN ANALYZE)
Use partial indexes (WHERE is_active = TRUE)
Use composite indexes for frequent queries
What NOT to do
❌ Do not create indexes "just in case"
❌ Do not use TEXT where VARCHAR is needed
❌ Do not store JSONB for critical data (labs)
❌ Do not forget FOREIGN KEY constraints
