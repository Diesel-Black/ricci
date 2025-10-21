# RICCI
*Riemannian Intrinsic Coherence & Coupling Infrastructure*

[![license: MIT](https://img.shields.io/badge/license-MIT-yellow.svg)](https://opensource.org/licenses/MIT) [![Uses](https://img.shields.io/badge/uses-PostgreSQL%2017%2B-darkgreen.svg)](https://github.com/pgvector/pgvector)

## Background

***"How did we not see this coming?"***

This question follows every catastrophic breakdown. Teams see warning signs but lack the language to name them and the mathematics to measure them.

Every breakdown follows one or more of 12 geometric patterns that repeat at scales from individual conversations, to inter-team dynamics, to full organizational communication health.

RICCI identifies these signatures before they destroy value. Twelve orthogonal detectors measure field evolution dynamics in real-time, each producing traceable, mathematical evidence showing which geometric thresholds were crossed, and when.

## Table of Contents
- [What RICCI Does](#what-ricci-does) / [What RICCI Doesn't](#what-ricci-does-not-do)
- [Privacy Considerations](#privacy-considerations)
- [The Twelve Detectors](#the-twelve-detectors)
- [Why Geometry?](#why-geometry)
- [Quick Start](#quick-start)
- [Manual Installation](#manual-installation)
- [Use Cases](#use-cases)
- [Architecture](#architecture)
- [Testing](#testing)
- [Theoretical Foundation](#theoretical-foundation)
- [License](#license)
- [Contact](#contact)

## What RICCI Does

RICCI detects mathematical signatures of expensive problems long before they destroy value, by measuring the geometry of interaction dynamics in real-time. These include:

- Metric Crystallization — Discussions failing to evolve despite pressure to adapt.
- Coupling Dispersion — Teams fragmenting into isolated camps lacking cross-pollination.
- Field Hypercoherence — Insular echo chambers forming around dominant narratives.
- Structure Hyperexpansion — Complexity spiraling beyond the ability to validate or stabilize it.
- Operative Decoupling — Interpretation drifting from consensus reality.

RICCI runs entirely in PostgreSQL, co-locating vectors and tensors to achieve geometric computation within the database. It requires no external services, incorporates no ML models, and has no cloud dependencies. You provide embeddings; RICCI measures their geometric field evolution.

**Every detection produces mathematical evidence** showing exactly which thresholds were crossed and why—essential for auditing, debugging, and understanding what triggered the alert.

---

## What RICCI Doesn't Do

Like a semantic MRI, RICCI excels at detecting the pathologies in semantic point patterns that threaten systemic health.

However:

- It can't determine who is right or wrong.
- It can't predict which decision will succeed.
- It can't judge whether any idea is good or bad.
- It can't discern what anyone actually said or meant.

Think of RICCI as weather forecasting for organizational discourse, not as a crystal ball. It shows when the *process* is breaking down.

A good example is seismometers; they listen for signs of earthquakes in 3 dimensions. RICCI measures the real-time geometric stress on semantic fault lines (and how things are actively shifting) with 2000 dimensions of resolution.

---

## Privacy Considerations

RICCI operates exclusively on vector embeddings and never sees or processes raw text. User identifiers are type-enforced as UUIDs, precluding accidental storage of names, emails, or other direct identifiers.

What this means:
- The schema cannot accept usernames or PII in the `user_fingerprint` field
- No message content is required or stored; the math cannot process text
- All analysis operates on the geometric properties of embedding spaces

What to know:
- Embeddings themselves encode semantic information as singular vectors. Inherently, they can't be perfectly anonymized, even as a point in space
- Temporal patterns across points can reveal behavioral characteristics
- Coupling analysis explicitly measures and stores interaction patterns between anonymized vector points.

Recommended practices for sensitive deployments:
- Use TLS/SSL for transport encryption between application and database
- Implement strong database access controls appropriate for your threat model
- Rotate user fingerprint UUIDs periodically (if desired)
- Consider which content should be embedded in the first place

RICCI provides the infrastructure to maximize analysis of coordination dynamics while minimizing data collection. The boundary between semantic analysis and privacy is a structural design choice for every deployment.

---

## The Twelve Detectors

Each signature type is mathematically orthogonal to the other 11. They fall into one of four categories, each with three modes. These can occur simultaneously, in varying combinations and degrees of severity.

### Rigidity - *things can't evolve*
- Metric Crystallization — Systemic pathways for change become structurally unavailable. Even needed and wanted updates become difficult or impossible.
- Field Calcification — Feedback is received and understood intellectually, but doesn't translate into structural change.
- Attractor Isolation — The system over-constrains itself to existing attractors. Incoming feedback is twisted to fit an existing story; exploration is often punished, and adaptability decays.

### Fragmentation - *things can't cohere*
- Attractor Dissociation — New options are generated faster than they can stabilize into lasting attractors. Fractured attention results in *starts* vastly outnumbering *finishes*.
- Field Dissolution — Capacity to integrate complexity deteriorates, and signal becomes noise. Past a threshold, the system enters coherence breakdown.
- Coupling Dispersion — Existing insight grows increasingly islanded, lacking sufficient interconnection. Bridges erode between *what the system knows* and *what it can do*.

### Inflation - *things can't be bounded*
- Boundary Hyperasymmetry — A system leverages its internal coherence to siphon off resources from host systems while giving far less in return.
- Field Hypercoherence — An insular overcommitment to the system's own internal logic. Self-elegance breeds subsequent immunity to questioning and incoming feedback.
- Structure Hyperexpansion — The system creates structure faster than it can be questioned. Internally-consistent narratives decouple from external reality.

### Distortion - *things can't align*
- Operative Decoupling — Interpretation is systematically wrong in a self-reinforcing way. A gap widens between field conditions and the understanding of them.
- Signal Projection — The system treats ambiguous, neutral, or positive inputs as a threat. Expectations of hostility often generate conditions for actual hostility, reinforcing the initial expectation.
- Recursive Hypercoupling — The system's self-concept becomes its interpretation, requiring and receiving external validation in lieu of actionable feedback.

Each detector returns `(signature_type, severity ∈ [0,1], geometric_signature[], mathematical_evidence)`.

**Full mathematical definitions**: See `docs/schema.md`

---

## Why Geometry?

Communication creates semantic structure. These structures evolve through tangled feedback loops; ideas reinforce, converge, diverge, stabilize, or even collapse based on how participants use terminology and respond to it.

RICCI measures these dynamics using differential geometry:

- Coupling strength — How connected are participants?
- Semantic Mass — How much conviction drives a position?
- Attractor stability — Is this viewpoint locked in or evolving?
- Coherence curvature — Is inferred meaning bending under pressure?

When these measurements hit critical thresholds, RICCI flags specific pathologies with quantified severity.

---

## Quick Start

### Docker Installation (Recommended)

```bash
# Start PostgreSQL 17 + pgvector 0.8.0 with RICCI schema loaded
docker compose up -d --build

# Connect to RICCI database
psql postgresql://ricci_user:changeme@localhost:5444/ricci_db
```

**Environment variables** (optional `.env` file):
```bash
POSTGRES_DB=ricci_db
POSTGRES_USER=ricci_user 
POSTGRES_PASSWORD=changeme
POSTGRES_PORT=5444
```

**Shutdown:**
```bash
docker compose down
```

### Load Your Data

RICCI requires only three ingredients:
1. Embeddings — Vector representations of each message (2000D)
2. Provenance — Associated UUID (`user_fingerprint`)
3. Timestamp — When the manifoldpoint was created (`creation_timestamp`)

```sql
INSERT INTO ricci.manifold_points (
    id, conversation_id, user_fingerprint, creation_timestamp,
    semantic_field, coherence_field
) VALUES (
    gen_random_uuid(), 
    '550e8400-e29b-41d4-a716-446655440000',  -- conversation_id
    '123e4567-e89b-12d3-a456-426614174000',  -- user_fingerprint (consistent per user; persistent UUIDs may enable tracking—see "Privacy Considerations" below for UUID rotation recommendations)
    NOW(),
    embedding_vector, 
    embedding_vector
);
```

### Run Detection

```sql
-- Analyze a single message
SELECT * FROM ricci.detect_all_signatures(point_id);

-- Analyze an entire conversation
SELECT signature_type, AVG(severity) as avg_severity
FROM ricci.manifold_points mp
CROSS JOIN LATERAL ricci.detect_all_signatures(mp.id)
WHERE conversation_id = 'conversation-123'
GROUP BY signature_type
HAVING AVG(severity) > 0.5;
```

---

## Manual Installation

**Requirements:** PostgreSQL 17+ with pgvector 0.8.0+

```sql
\i install.sql
```

**Run test suite (from psql):**
```sql
\i tests/run_tests.sql
```

---

## Use Cases

### Early Warning System

Monitor Slack channels, GitHub issues, or other communication channels for signs of dysfunction

```sql
-- Flag high-risk discussions
SELECT signature_type, severity, mathematical_evidence
FROM ricci.geometric_alerts 
WHERE severity > 0.7
ORDER BY severity DESC;

-- Example output includes mathematical evidence for every detection:
-- signature_type         | severity | mathematical_evidence
-- ---------------------- | -------- | ----------------------------------------------------
-- field_hypercoherence   | 0.89     | Coherence saturation: 0.94 > 0.85 with external
--                        |          | influence: 0.12 < 0.25 (isolation ratio: 7.83)
-- coupling_dispersion    | 0.76     | Coupling decay: -0.34 < -0.3 with sapience: 0.18
--                        |          | < 0.5 (dispersion ratio: 1.89)
```

### Post-Mortem Analysis

Understand why a project failed by analyzing existing communication geometry
```sql
-- Trace pathology evolution over time
SELECT signature_type, severity, creation_timestamp 
FROM ricci.manifold_points mp
CROSS JOIN LATERAL ricci.detect_all_signatures(mp.id)
WHERE conversation_id = 'failed-project-x'
ORDER BY creation_timestamp;
```

### Team Health Monitoring

Detect coordination breakdowns or echo chamber formation

```sql
-- Identify problematic coupling patterns
SELECT * FROM ricci.detect_coordination_via_coupling(
    time_window => '7 days',
    coupling_threshold => 0.8
);
```

### Escalation Prediction

Forecast when discussions will spiral based on field dynamics

```sql
-- Get intervention urgency scores
SELECT * FROM ricci.detect_escalation_via_field_evolution(
    ARRAY(SELECT id FROM ricci.manifold_points 
          WHERE conversation_id = 'active-debate'
          ORDER BY creation_timestamp)
);
```

---

## Architecture

- Storage — Leverages pgvector to enable 2000-dimensional vector fields for semantic and coherence analysis.
- Computation — Implements pure SQL functions with differential geometry operators.
- Privacy — Enforces UUID user identifiers in embedding-only operation. See [Privacy Considerations](#privacy-considerations).
- Auditability — Every detection returns mathematical evidence showing which thresholds were crossed and why.
- Performance — Optimizes with HNSW indices and materialized views for real-time analysis.
- Size — 70KB, 7-schema SQL implementation requiring no external services or ML models.
- Scale — Supports single-database deployment.

---

## Testing

RICCI includes a SQL-native test suite that runs entirely in Postgres. The runner loads the schema, initializes `ricci_test`, seeds randomness via `setseed(0.42)`, executes category suites, prints a summary, and tears down by default.

### Run The Full Test Suite

```bash
psql postgresql://ricci_user:changeme@localhost:5444/ricci_db -f tests/run_tests.sql
```

### Run Specific Test Categories

```bash
# Initialize framework first
psql postgresql://ricci_user:changeme@localhost:5444/ricci_db -f tests/test_framework.sql

# Then run specific category
psql postgresql://ricci_user:changeme@localhost:5444/ricci_db -f tests/signatures/test_rigidity_signatures.sql
```

### Retain Test Results

By default, the test suite tears down after completion. To retain results:
- Modify the runner to call `SELECT ricci_test.teardown_test_framework(false);`, or
- Run framework + test files manually (above) and query `ricci_test.test_results`
- To export failures: add `\o tests/results/failed.tsv` before the failure query and `\o`

### Expected Performance Bounds

- Foundation functions ≤ 1s for ~1k evaluations
- Matrix operations (50×50) ≤ 3s
- Single-category detectors ≤ 5s per point
- Full `detect_all_signatures` ≤ 10s per point
- Coordination analysis (5 nodes) ≤ 5s
- Field evolution (single step) ≤ 8s

See `tests/README.md` for test framework details and assertion APIs.

---

## Theoretical Foundation

RICCI implements Recurgent Field Theory (RFT), a mathematical framework modeling semantic systems as differentiable manifolds with recursive coupling. RFT models geometric signatures that emerge when feedback loops enter unstable configurations.

Similar patterns appear across scales, from individual cognition to organizational dynamics, suggesting common geometric mechanisms intrinsic to complex systems of inference.

See `docs/schema.md` for function-level mathematical details and `schema/*.sql` for implementation.

---

## License

MIT License - See LICENSE file for details

---

## Contact

Built by Diesel Black following 25 years of analyzing complex systems.

*"The crisis in month 12 was always baked in from week 2. Now we can fix it in week 3 with a simple engineering meeting."*
