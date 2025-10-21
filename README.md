# RICCI: Riemannian Intrinsic Coherence & Coupling Infrastructure

[![license: MIT](https://img.shields.io/badge/license-MIT-yellow.svg)](https://opensource.org/licenses/MIT) [![Uses](https://img.shields.io/badge/uses-PostgreSQL%2017%2B-darkgreen.svg)](https://github.com/pgvector/pgvector)

## Table of Contents

- [Purpose](#purpose)
- [Capabilities](#capabilities)
- [Interfaces](#interfaces)
- [Typical Use Cases](#typical-use-cases)
- [Detectors](#detectors)
- [Installation](#installation)
- [Testing](#testing)
- [Usage](#usage)
- [Design Notes](#design-notes)

## Purpose

RICCI is a Postgres‑native geometric analysis library for detecting structural changes in high‑dimensional semantic fields. It operates solely on vector/tensor representations stored in the database; raw content is neither required nor processed.

- Scope: differential‑geometric operators, temporal field evolution, and detector functions over the `ricci` schema.
- Privacy: operates on `VECTOR(2000)` fields and derived tensors; no raw text or content.
- Outputs: per‑point detections with severity in [0,1] and machine‑readable evidence.

## Capabilities

- Deterministic SQL functions with explicit inputs/outputs
- Numerical regularization throughout (1e‑6–1e‑12)
- Dimensional convention: storage at 2000D; operators compute on a 100D subspace
- Tested performance envelopes (see Testing)

## Interfaces

- Core analysis:
  - `ricci.detect_all_signatures(point_id UUID)`
  - Category multiplexers: `detect_rigidity_signatures`, `detect_fragmentation_signatures`, `detect_inflation_signatures`, `detect_coupling_signatures`
- Operations and monitoring:
  - `ricci.detect_coordination_via_coupling(time_window, coupling_threshold, min_cluster_size)`
  - `ricci.detect_escalation_via_field_evolution(conversation_points UUID[])`
  - Views/materialized: `ricci.geometric_alerts`, `ricci.coordination_alerts`
- Field evolution:
  - `ricci.evolve_coherence_field_complete(point_id UUID, dt FLOAT)`

## Typical Use Cases

- Coordination analysis from recursive coupling tensors and temporal dynamics
- Escalation prediction from coherence acceleration and scalar curvature
- System health monitoring via alerts and thresholded severity

## Detectors

Four categories emit rows with `(signature_type, severity, evidence)`:

- Rigidity: metric crystallization, densification, sequestration
- Fragmentation: dissociation, dissolution, dispersion
- Inflation: hyperasymmetry, hypercoherence, hyperexpansion
- Distortion: operative decoupling, signal projection, recursive hypercoupling

Equations and details: see `docs/schema.md`.

## Installation

### Docker (Recommended)

**Prerequisites:** Docker

```bash
docker compose up -d --build
```

**Environment variables** (optional `.env` file):
```bash
POSTGRES_DB=ricci_db
POSTGRES_USER=ricci_user 
POSTGRES_PASSWORD=changeme
POSTGRES_PORT=5444
```

**Connection:**
```bash
psql postgresql://ricci_user:changeme@localhost:5444/ricci_db
```

**Shutdown:**
```bash
docker compose down
```

### Testing

RICCI includes a SQL‑native test suite that runs entirely in Postgres. The runner loads the schema, initializes `ricci_test`, seeds randomness via `setseed(0.42)`, executes category suites, prints a summary, and tears down by default.

- Run full suite:
```bash
psql postgresql://ricci_user:changeme@localhost:5444/ricci_db -f tests/run_tests.sql
```

- Run a single category (initialize framework, then run a file):
```bash
psql postgresql://ricci_user:changeme@localhost:5444/ricci_db -f tests/test_framework.sql
psql postgresql://ricci_user:changeme@localhost:5444/ricci_db -f tests/signatures/test_rigidity_signatures.sql
```

- Retain results (optional):
  - Modify the runner to call `SELECT ricci_test.teardown_test_framework(false);`, or run framework + files manually (above) and query `ricci_test.test_results`.
  - To export failures, add `\o tests/results/failed.tsv` before the failure query and `\o`.

- Expected bounds (guidance):
  - Foundation functions ≤ 1s for ~1k evals
  - Matrix ops (50×50) ≤ 3s
  - Single-category detectors ≤ 5s per point
  - Full `detect_all_signatures` ≤ 10s per point
  - Coordination (5 nodes) ≤ 5s
  - Field evolution (single step) ≤ 8s

See `tests/README.md` for layout and assertion APIs.

---

### Manual Installation

**Requirements:** PostgreSQL 17+ with pgvector 0.8.0+

```sql
\i install.sql
```

**Run test suite (from psql):**
```sql
\i tests/run_tests.sql
```

## Usage

#### Primary Detection Interface
```sql
-- Comprehensive geometric analysis
SELECT * FROM ricci.detect_all_signatures(point_id);

-- Category-specific detection
SELECT * FROM ricci.detect_rigidity_signatures(point_id);
SELECT * FROM ricci.detect_fragmentation_signatures(point_id);
SELECT * FROM ricci.detect_inflation_signatures(point_id);
SELECT * FROM ricci.detect_distortion_signatures(point_id);
```

### Investigative Analysis
```sql
-- Detect coordination patterns
SELECT * FROM ricci.detect_coordination_via_coupling(
    time_window => '24 hours',
    coupling_threshold => 0.8,
    min_cluster_size => 3
);

-- Predict escalation trajectories  
SELECT * FROM ricci.detect_escalation_via_field_evolution(conversation_points);
```

### Field Evolution Simulation
```sql
-- Simulate coherence field evolution
SELECT ricci.evolve_coherence_field_complete(point_id, dt => 0.01);
```

### Real-Time Monitoring
```sql
-- High-priority alerts
SELECT * FROM ricci.coordination_alerts WHERE priority = 'HIGH';
SELECT * FROM ricci.geometric_alerts WHERE severity > 0.6;
```

## Design Notes

- Modules mirror `schema/00..06` with base entities, operators, detectors, and operational monitoring
- Vector indices: HNSW on `semantic_field`, `coherence_field`; composite temporal indices for analysis queries
- Numerical stability: explicit regularization and symmetric storage for tensors
