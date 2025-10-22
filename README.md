# RICCI
*Riemannian Intrinsic Coherence & Coupling Infrastructure*

[![license: MIT](https://img.shields.io/badge/license-MIT-yellow.svg)](https://opensource.org/licenses/MIT) [![Uses](https://img.shields.io/badge/uses-PostgreSQL%2017%2B-darkgreen.svg)](https://github.com/pgvector/pgvector)

## *"How did we not see this coming?"*

This question follows every preventable organizational catastrophe. Teams often see the warning signs ahead of time, but lack the language to name them, let alone the math to quantify them.

Organizational dysfunction follows one or more of 12 geometric patterns that repeat at scales from individual conversations, to inter-team dynamics, to full systemic communication health.

RICCI identifies these signatures before they destroy value and competitive advantage. Its 12 orthogonal detectors measure field dynamics in real-time, each producing traceable, mathematical evidence showing which geometric thresholds were crossed and why.

## Table of Contents
- [Overview](#overview)
- [Key Concepts](#key-concepts)
- [Privacy Considerations](#privacy-considerations)
- [The Twelve Detectors](#the-twelve-detectors)
- [Why Geometry?](#why-geometry)
- [Documentation](#documentation)
- [Installation](#installation)
- [Use Cases](#use-cases)
- [Technical Details](#technical-details)
- [Theoretical Foundation](#theoretical-foundation)
- [License](#license)

## Overview

### What RICCI Does

An ounce of prevention is worth a metric ton of cure. RICCI is a "semantic MRI" for complex communication systems, detecting the mathematical signatures of pathologies in semantic point patterns that threaten systemic health long before they can become disastrous money pits or rework nightmares.

Think of it as "weather forecasting for organizational discourse". Just as meteorologists track pressure systems and temperature gradients to predict storms, RICCI tracks semantic field dynamics and coupling patterns to predict breakdowns in the *process* before any resulting dysfunction starts costing money.

Or consider "seismometers", which listen for signs of earthquakes in 3 dimensions. RICCI quantifies the real-time geometric stress on semantic fault lines—and how things are actively shifting—with 2000 dimensions of resolution.

**How It Works:**  
In 97KB of SQL running in PostgreSQL+pgvector, RICCI performs geometric analysis directly in the database with colocated vectors and tensors. It requires no external services, incorporates no ML models, and has no cloud dependencies.

**You provide**: Embeddings (vector representations of messages)  
**RICCI provides**: 12 orthogonal pathology signatures, each with quantified severity (0-1) and mathematical evidence of threshold violations.

Rigorous evidence makes RICCI invaluable for both real-time intervention and for post-mortem forensic analysis of past failures.

### Scope & Limitations

RICCI analyzes how communication is functioning geometrically, not what is being communicated or whether it's correct.

What RICCI can't and doesn't measure:
- Whether any held position or interpretation is right or wrong
- Whether any particular concept or message is good or bad  
- Which decisions, ideas, or products will succeed or fail
- What any given message content actually said or meant

What RICCI can and does measure:
- Whether the *process* of communication is healthy or breaking down
- Whether feedback loops are functioning or pathological
- Whether the system can adapt or is becoming rigid/fragmented
- Whether coordination patterns are productive or dysfunctional

Think of it this way: RICCI can't tell if your team should use JWT or session tokens, but it *can* detect when two teams are using the same words ("stateless architecture") differently while building toward incompatible implementations. It can catch that divergence in week 3 when a simple alignment meeting can fix matters, rather than month 9 when the integration crisis requires $180K of rework.

Less "crystal ball", more "field equations for the geometry of meaning".

## Key Concepts

Before diving deeper, a few core building blocks:

**Manifold Point** — Conceptually, a single point in the semantic manifold (typically one message or contribution). In the implementation, this is represented by a row in `ricci.manifold_points` with both semantic and coherence embeddings plus computed geometric properties (metric tensor/determinant, curvature, mass) and temporal metadata.

**Semantic Field** (`S(p,t)`) — The primary 2000-dimensional vector embedding representing *what is being expressed*. This is the content-bearing field.

**Coherence Field** (`C(p,t)`) — A secondary 2000-dimensional vector representing *how coherently the expression integrates with context*. High coherence doesn't mean "good"—it means tightly coupled to existing structure, which can be healthy (integration) or pathological (rigidity).

**Metric Tensor** (`g_ij(p,t)`) — The fundamental geometric object defining how distances and angles are measured at each point, derived from local field gradients. When the metric tensor stops evolving despite persistent tensions, you get rigidity. When its determinant approaches zero, constraint density spikes.

**Semantic Mass** (`M(p,t)`) — A scalar quantity measuring how much "gravitational" influence a point exerts on the local geometry. Computed as `M = D × ρ × A` where D is recursive depth (how self-referential a point is), ρ is constraint density (the inverse of the metric determinant), and A is attractor stability (how "locked in" a point is). High mass structures warp local geometry and resist movement.

**Coupling Tensor** (`R_ijk(p,q,t)`) — A 3rd-order tensor measuring how two points interact and influence each other's evolution. Strong coupling isn't inherently good or bad; it depends on whether it's enabling coordination or creating echo chambers.

**Autopoietic Potential** (`Φ(C)`) — Measures the system's capacity for self-reinforcing structure creation. Defined as `Φ(C) = α(||C|| - C_threshold)^β` when coherence exceeds threshold, else zero. This is what fuels the "runaway" behavior in inflation signatures: the system generates structure faster than feedback can constrain it.

**Geometric Signatures** — The 12 orthogonal patterns that emerge when field dynamics become pathological. Each signature has a mathematical definition based on thresholds in field properties (curvature, coupling strength, evolution rates, etc.).

## Privacy Considerations

RICCI operates exclusively on vector embeddings and never processes raw text. User identifiers are type-enforced as UUIDs, precluding accidental PII storage. While embeddings can't be perfectly anonymized, the architecture minimizes data collection by design.

For deployment best practices, UUID rotation strategies, and detailed privacy considerations, see the [Operations Guide: Privacy](docs/operations-guide.md#privacy-considerations).

## The Twelve Detectors

Each signature type is orthogonal to the other 11 ways the field equations can malfunction. They fall into one of four primary categories, each with three modes. These can occur simultaneously, in varying combinations, to varying degrees of severity, and in any context involving interaction between N+1 complex systems (humans, organizations, markets, governments, etc.).

### Rigidity - *things can't evolve*
1.  **Metric Crystallization** — Systemic pathways for change become structurally unavailable. Even needed and wanted updates grow increasingly difficult or impossible.
2. **Field Calcification** — Healthy feedback is received and the system understands it intellectually, but it doesn't translate into material change.
3. **Attractor Isolation** — The system over-constrains itself to immutable attractors. Incoming healthy feedback is twisted to fit an existing story. As a result, exploration is often punished and adaptability decays.

### Fragmentation - *things can't cohere*
4. **Attractor Dissociation** — New options divide attention more rapidly than any can stabilize into lasting structures. Splintering priorities results in *starts* that begin vastly outnumbering *finishes*.
5. **Field Dissolution** — Deterioration in the system's capacity to process and integrate complexity leads to a threshold where signal becomes noise. Past the threshold, the system breaks down.
6. **Coupling Dispersion** — Existing insight grows increasingly islanded, lacking sufficient interconnection. Bridges erode between *what the system knows* and *what it can do*.

### Inflation - *things can't be bounded*
7. **Boundary Hyperasymmetry** — A system leverages its internal coherence to siphon off resources from host systems/ecosystems while giving substantively little in return.
8. **Field Hypercoherence** — An insular overcommitment to the system's own internal logic. Self-elegance breeds subsequent immunity to questioning and incoming feedback.
9. **Structure Hyperexpansion** — The system creates structure faster than it can be questioned or validated. Internally-consistent narratives diverge from the conditions of external reality.

### Distortion - *things can't align*
10. **Operative Decoupling** — Interpretation is systematically wrong in a self-reinforcing way. A gap widens between field conditions and the understanding of them.
11. **Signal Projection** — The system treats ambiguous, neutral, or positive inputs as a threat. Expectations of hostility often generate conditions for actual hostility, reinforcing the initial expectation, creating a self-fulfilling prophecy.
12. **Recursive Hypercoupling** — The system's self-concept becomes its interpretation, requiring and receiving external validation in lieu of actionable feedback.

Each detector returns `(signature_type, severity ∈ [0,1], geometric_signature[], mathematical_evidence)`.

For detailed API documentation, see the [API Reference](docs/api-reference.md). For mathematical foundations, see the [Mathematical Foundation](docs/mathematical-foundation.md).

## Why Geometry?

Communication creates semantic structure. These structures evolve through tangled feedback loops: ideas reinforce, converge, diverge, stabilize, or even collapse, based on how participants use language and respond to it.

Most approaches treat embeddings as static points to cluster or compare. But meaning isn't static; it's a dynamic field that curves, couples, and evolves under the influence of interaction. The question now exceeds "how similar are these vectors?" to "how is *interpretation itself* being warped by the forces acting on it?"

This is why RICCI uses differential geometry, the mathematics of curved spaces and field dynamics. A rigid interpretive framework manifests as a measurable change in the metric tensor. Echo chambers emerge from recursive coupling that creates attractor wells in the field.

### What RICCI Measures

- **Coupling strength** — How connected are participants? Are they building on each other's ideas or talking past one another?
- **Semantic mass** — How much conviction drives a position? Mass warps the local geometry, making some ideas harder to move away from.
- **Attractor stability** — How locked in is this viewpoint? Stable attractors resist change; over-stability becomes rigidity.
- **Coherence curvature** — How is inferred meaning bending under pressure? Excessive curvature signals distortion or imminent breakdown.

When these field properties reach critical thresholds, RICCI flags specific dysfunction signatures with quantified severity. The detectors operate on field equations that measure structural breakdown in the mathematical representation of meaning.

## Documentation

- [API Reference](docs/api-reference.md) — Complete function-level API reference
- [Mathematical Foundation](docs/mathematical-foundation.md) — Theoretical concepts and field equations
- [Operations Guide](docs/operations-guide.md) — Usage examples and monitoring strategies
- [Installation Guide](docs/installation.md) — Setup, testing, and verification
- `schema/*.sql` — Implementation source code

## Installation

### Docker (Recommended)

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

RICCI requires embeddings (2000D vectors), a UUID `user_fingerprint`, and a timestamp:

```sql
INSERT INTO ricci.manifold_points (
    id, user_fingerprint, creation_timestamp,
    semantic_field, coherence_field
) VALUES (
    gen_random_uuid(), 
    '123e4567-e89b-12d3-a456-426614174000',
    NOW(),
    embedding_vector, 
    embedding_vector
);
```

See [Operations Guide: Privacy Considerations](docs/operations-guide.md#privacy-considerations) and [Operations Guide: Loading Data](docs/operations-guide.md#loading-data) for detailed descriptions and best practices.

### Run Detection

```sql
-- Analyze a single message
SELECT * FROM ricci.detect_all_signatures(point_id);

-- Analyze an entire conversation
SELECT signature_type, AVG(severity) as avg_severity
FROM ricci.manifold_points mp
CROSS JOIN LATERAL ricci.detect_all_signatures(mp.id)
WHERE conversation_id = '550e8400-e29b-41d4-a716-446655440000'
GROUP BY signature_type
HAVING AVG(severity) > 0.5;
```

### Manual Installation

**Requirements:** PostgreSQL 17+ with pgvector 0.8.0+

```sql
\i install.sql
```

**Run test suite (from psql):**
```sql
\i tests/run_tests.sql
```

## Use Cases

### Early Warning System

Monitor communication channels for signs of dysfunction:

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

For additional use cases including post-mortem analysis, team health monitoring, escalation prediction, and temporal pattern analysis, see the [Operations Guide: Use Cases](docs/operations-guide.md#use-cases).

## Technical Details

### Architecture

- **Storage** — Leverages pgvector to enable 2000-dimensional vector fields for semantic and coherence analysis.
- **Computation** — Pure SQL functions implementing differential geometry operators (Christoffel symbols, covariant derivatives, curvature tensors).
- **Privacy** — UUID-enforced user identifiers, embedding-only operation. See [Privacy Considerations](#privacy-considerations).
- **Auditability** — Traceable mathematical evidence for every detection showing threshold violations.
- **Performance** — HNSW indices for vector similarity, materialized views for monitoring, optimized for real-time analysis.
- **Footprint** — 97KB across 7 schema files, zero external dependencies.
- **Deployment** — Single PostgreSQL database, no distributed infrastructure required.

### Testing

RICCI includes a comprehensive SQL-native test suite. Run with `psql -f tests/run_tests.sql`. See the [Installation Guide: Testing](docs/installation.md#testing) for detailed test commands, expected performance bounds, and test framework documentation.

## Theoretical Foundation

RICCI implements Recurgent Field Theory (RFT), a Lagrangian framework modeling semantic systems as differentiable manifolds with recursive coupling. RFT models geometric signatures that emerge when feedback loops enter unstable configurations.

Similar patterns appear across scales, from individual cognition to organizational dynamics, suggesting common geometric mechanisms intrinsic to complex systems of inference. For more, see [Mathematical Foundation](docs/mathematical-foundation.md).

## License

MIT License - See LICENSE file for details
