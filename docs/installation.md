# RICCI Installation Guide

## Requirements

- PostgreSQL 17+
- pgvector extension 0.8.0+

## Quick Start with Docker

The recommended way to get started is using Docker Compose:

```bash
# Start PostgreSQL 17 + pgvector 0.8.0 with RICCI schema loaded
docker compose up -d --build

# Connect to RICCI database
psql postgresql://ricci_user:changeme@localhost:5444/ricci_db
```

### Environment Configuration

Create an optional `.env` file to customize settings:

```bash
POSTGRES_DB=ricci_db
POSTGRES_USER=ricci_user 
POSTGRES_PASSWORD=changeme
POSTGRES_PORT=5444
```

### Shutdown

```bash
docker compose down
```

## Manual Installation

If you prefer to install RICCI into an existing PostgreSQL instance:

```sql
\i install.sql
```

This will:
1. Enable required extensions (`pgcrypto`, `vector`)
2. Create the `ricci` schema
3. Load all 7 schema files in dependency order
4. Create necessary indexes and materialized views

## Verification

After installation, verify the schema is loaded:

```sql
-- Check that core tables exist
SELECT COUNT(*) FROM information_schema.tables 
WHERE table_schema = 'ricci';

-- Should return 3 (manifold_points, recursive_coupling, sapience_field)
```

## Testing

RICCI includes a comprehensive SQL-native test suite.

### Run Full Test Suite

```bash
psql postgresql://ricci_user:changeme@localhost:5444/ricci_db -f tests/run_tests.sql
```

The test runner:
1. Loads the schema
2. Initializes the `ricci_test` framework
3. Seeds randomness via `setseed(0.42)`
4. Executes test categories:
   - Foundation functions
   - Geometric analysis
   - All 12 signature detectors
   - Integration tests
   - Performance benchmarks
5. Prints a summary with pass/fail counts
6. Tears down test data (by default)

### Run Specific Test Categories

```bash
# Initialize framework first
psql postgresql://ricci_user:changeme@localhost:5444/ricci_db -f tests/test_framework.sql

# Then run specific category
psql postgresql://ricci_user:changeme@localhost:5444/ricci_db -f tests/signatures/test_rigidity_signatures.sql
psql postgresql://ricci_user:changeme@localhost:5444/ricci_db -f tests/signatures/test_fragmentation_signatures.sql
psql postgresql://ricci_user:changeme@localhost:5444/ricci_db -f tests/signatures/test_inflation_signatures.sql
psql postgresql://ricci_user:changeme@localhost:5444/ricci_db -f tests/signatures/test_distortion_signatures.sql
```

### Retain Test Results

By default, the test suite tears down after completion. To retain results for inspection:

**Option 1:** Modify the runner to call:
```sql
SELECT ricci_test.teardown_test_framework(false);
```

**Option 2:** Run framework + test files manually and query `ricci_test.test_results`

**Option 3:** Export failures:
```sql
\o tests/results/failed.tsv
SELECT * FROM ricci_test.test_results WHERE status = 'FAILED';
\o
```

### Expected Performance Bounds

- Foundation functions: ≤ 1s for ~1k evaluations
- Matrix operations (50×50): ≤ 3s
- Single-category detectors: ≤ 5s per point
- Full `detect_all_signatures`: ≤ 10s per point
- Coordination analysis (5 nodes): ≤ 5s
- Field evolution (single step): ≤ 8s

See `tests/README.md` for test framework details and assertion APIs.

## Next Steps

- [Load your data](operations-guide.md#loading-data)
- [Run your first detection](operations-guide.md#basic-usage)
- [Understand the mathematical foundation](mathematical-foundation.md)
- [Explore the API reference](api-reference.md)

