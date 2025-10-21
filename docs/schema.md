# RICCI Schema Reference

## Overview

RICCI implements a Postgres schema to perform its geometric embedding analysis. The engine detects 12 signatures of coherence breakdown across 4 categories: [Rigidity](#rigidity-signatures), [Fragmentation](#fragmentation-signatures), [Inflation](#inflation-signatures), and [Coupling](#coupling-signatures).

This document describes the current schema implementation as of the latest commit.

It's presented here as a single document for ease of copy/paste with the AI model/agent of your choice.

## Table of Contents

- [Requirements](#requirements)
- [Installation](#installation)
- [Core Tables](#core-tables)
- [Core Functions](#core-functions)
- [Geometric Analysis Functions](#geometric-analysis-functions)

## Requirements

- PostgreSQL 17+
- pgvector extension 0.8.0+

## Installation

```sql
\i install.sql
```

## Core Tables

### `ricci.manifold_points`

The primary table storing semantic manifold points with geometric properties.

```sql
CREATE TABLE ricci.manifold_points (
    id UUID PRIMARY KEY,
    conversation_id UUID,
    user_fingerprint TEXT,
    creation_timestamp TIMESTAMP WITH TIME ZONE NOT NULL,
    
    -- Semantic field vectors
    semantic_field VECTOR(2000),
    coherence_field VECTOR(2000),
    coherence_magnitude FLOAT,
    
    -- Geometric structures
    metric_tensor FLOAT[],
    metric_determinant FLOAT,
    
    -- Semantic mass components: M = D * ρ * A
    recursive_depth FLOAT,
    constraint_density FLOAT,
    attractor_stability FLOAT,
    semantic_mass FLOAT,
    
    -- Differential geometry
    christoffel_symbols FLOAT[],
    gregorio_curvature FLOAT[],
    scalar_curvature FLOAT,
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

**Field Descriptions:**

- `id` — Unique identifier for the manifold point
- `conversation_id` — Optional grouping identifier for related points (e.g., conversation threads)
- `user_fingerprint` — Optional identifier for the actor/user (should be pseudonymized)
- `creation_timestamp` — When the source observation occurred
- `semantic_field` — Primary 2000-dimensional semantic embedding
- `coherence_field` — 2000-dimensional coherence field embedding
- `coherence_magnitude` — Scalar magnitude of the coherence field
- `metric_tensor` — Geometric metric tensor components (flattened array)
- `metric_determinant` — Determinant of the metric tensor
- `recursive_depth`, `constraint_density`, `attractor_stability` — Components used in semantic mass calculation
- `semantic_mass` — Computed semantic mass using `ricci.compute_semantic_mass()`
- `christoffel_symbols` — Connection coefficients for differential geometry
- `gregorio_curvature` — Gregorio curvature tensor components
- `scalar_curvature` — Scalar curvature at the point
- `created_at` — Row creation timestamp

**Indexes:**
- HNSW indexes on `semantic_field` and `coherence_field` for vector similarity
- B-tree indexes on temporal and mass fields

---

### `ricci.recursive_coupling`

Stores coupling relationships between manifold points.

```sql
CREATE TABLE ricci.recursive_coupling (
    id UUID PRIMARY KEY,
    point_p UUID NOT NULL REFERENCES ricci.manifold_points(id),
    point_q UUID NOT NULL REFERENCES ricci.manifold_points(id),
    
    -- Coupling tensors
    coupling_tensor FLOAT[],
    coupling_magnitude FLOAT,
    
    -- Coordination decomposition
    self_coupling FLOAT[],
    hetero_coupling FLOAT[],
    
    -- Temporal dynamics
    evolution_rate FLOAT,
    latent_channels FLOAT[],
    
    computed_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

**Field Descriptions:**

- `point_p`, `point_q` — Source and target manifold points
- `coupling_tensor` — 3rd-order coupling tensor (flattened)
- `coupling_magnitude` — Scalar strength of coupling
- `self_coupling`, `hetero_coupling` — Decomposed coupling components
- `evolution_rate` — Rate of change in coupling strength
- `latent_channels` — Compact channel descriptors

---

### `ricci.sapience_field`

Regulatory mechanisms for controlling runaway dynamics.

```sql
CREATE TABLE ricci.sapience_field (
    point_id UUID PRIMARY KEY REFERENCES ricci.manifold_points(id),

    -- Regulation metrics
    sapience_value FLOAT,
    forecast_sensitivity FLOAT,
    gradient_response FLOAT,

    -- Circumspection operators
    circumspection_factor FLOAT,
    recursion_regulation FLOAT,
    
    computed_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

**Field Descriptions:**

- `sapience_value` — Overall regulatory value (0-1)
- `forecast_sensitivity` — Responsiveness to anticipated changes
- `gradient_response` — Responsiveness to observed gradients
- `circumspection_factor` — Damping factor from circumspection operator
- `recursion_regulation` — Regulation on recursive depth

## Core Functions

### Semantic Mass Calculation

```sql
ricci.compute_semantic_mass(
    recursive_depth FLOAT,
    metric_determinant FLOAT,
    attractor_stability FLOAT
) RETURNS FLOAT
```

Computes semantic mass as: `M(p,t) = D(p,t) * ρ(p,t) * A(p,t)`

---

### Autopoietic Potential

```sql
ricci.compute_autopoietic_potential(
    coherence_magnitude FLOAT,
    coherence_threshold FLOAT DEFAULT 0.7,
    alpha FLOAT DEFAULT 1.0,
    beta FLOAT DEFAULT 2.0
) RETURNS FLOAT
```

Computes autopoietic potential: `Φ(C) = α(C_mag - C_threshold)^β` for `C ≥ threshold`

---

### Circumspection Operator

```sql
ricci.compute_circumspection_operator(
    coupling_magnitude FLOAT,
    optimal_recursion FLOAT DEFAULT 0.5,
    decay_constant FLOAT DEFAULT 2.0
) RETURNS FLOAT
```

Computes circumspection regulation: `H[R] = |R|_F * exp(-k(|R|_F - R_optimal))`

## Geometric Analysis Functions

### Christoffel Symbols

```sql
ricci.compute_christoffel_symbols(
    metric_components FLOAT[],
    metric_derivatives FLOAT[][],
    dimension INTEGER DEFAULT 100
) RETURNS FLOAT[]
```

Computes connection coefficients: `Γᵏᵢⱼ = ½gᵏˡ(∂ᵢgⱼˡ + ∂ⱼgᵢˡ - ∂ˡgᵢⱼ)`

---

### Covariant Derivative

```sql
ricci.covariant_derivative(
    field_components VECTOR(2000),
    field_derivatives FLOAT[][],
    christoffel_symbols FLOAT[],
    i_index INTEGER,
    j_index INTEGER,
    dimension INTEGER DEFAULT 100
) RETURNS FLOAT
```

Computes covariant derivative: `∇ᵢVⱼ = ∂ᵢVⱼ - ΓᵏᵢⱼVₖ`

---

### Gregorio Curvature

```sql
ricci.compute_gregorio_curvature(
    christoffel_symbols FLOAT[],
    christoffel_derivatives FLOAT[][][],
    dimension INTEGER DEFAULT 100
) RETURNS FLOAT[]
```

Computes Gregorio curvature tensor components.

---

### Geodesic Distance

```sql
ricci.integrate_geodesic_distance(
    point_a UUID,
    point_b UUID,
    num_steps INTEGER DEFAULT 100
) RETURNS FLOAT
```

Integrates geodesic distance between two manifold points.

---

### Recursive Coupling Tensor

```sql
ricci.compute_recursive_coupling_tensor(
    point_p UUID,
    point_q UUID,
    h FLOAT DEFAULT 1e-6
) RETURNS FLOAT[]
```

Computes 3rd-order coupling tensor between two points.

---

### Metric Tensor from Semantic Field

```sql
ricci.compute_metric_tensor_from_semantic_field(
    semantic_field VECTOR(2000),
    neighboring_fields VECTOR(2000)[],
    base_metric_scale FLOAT DEFAULT 1.0
) RETURNS FLOAT[]
```

Builds an approximate `g_ij` from local semantic field gradients in a 100D analytical subspace.

---

### Metric Inverse

```sql
ricci.compute_metric_inverse(
    metric_components FLOAT[],
    dimension INTEGER DEFAULT 100
) RETURNS FLOAT[]
```

Computes `g^ij` from a symmetric `g_ij` with regularization, returning flattened components.

---

### Scalar Curvature

```sql
ricci.compute_scalar_curvature(
    ricci_components FLOAT[],
    metric_inverse FLOAT[],
    dimension INTEGER DEFAULT 100
) RETURNS FLOAT
```

Contracts `R_ij` with `g^ij` to produce scalar curvature `R`.

---

### Linear Algebra Helpers

```sql
ricci.matrix_determinant(matrix FLOAT[][], n INTEGER) RETURNS FLOAT
ricci.matrix_inverse_gauss_jordan(matrix FLOAT[][], n INTEGER) RETURNS FLOAT[][]
```

Utility routines for determinant and Gauss–Jordan inversion with partial pivoting.

---

### Finite Differences for Field Derivatives

```sql
ricci.compute_finite_differences(
    point_id UUID,
    h FLOAT DEFAULT 1e-6
) RETURNS TABLE(first_derivatives FLOAT[], second_derivatives FLOAT[])
```

Computes first and second finite-difference derivatives of the coherence field in 100D.

---

## Signature Detection Functions

RICCI detects 12 orthogonal signatures across 4 categories:

### Rigidity Signatures

**Hallmark:** Over-constraint leading to brittleness.

#### Metric Crystallization (MC)

```sql
ricci.detect_metric_crystallization(
    point_id UUID,
    evolution_threshold FLOAT DEFAULT 0.01,
    curvature_threshold FLOAT DEFAULT 0.1
) RETURNS TABLE(signature_type TEXT, severity FLOAT, geometric_signature FLOAT[], mathematical_evidence TEXT)
```

**Signature:** `∂g_ij/∂t → 0 while R_ij ≠ 0`

Detects interpretive frameworks freezing while tensions persist.

---

#### Metric Densification (MD)
```sql
ricci.detect_metric_densification(
    point_id UUID,
    responsiveness_threshold FLOAT DEFAULT 0.01,
    time_window INTERVAL DEFAULT '6 hours'
) RETURNS TABLE(signature_type TEXT, severity FLOAT, geometric_signature FLOAT[], mathematical_evidence TEXT)
```

**Signature:** `lim(ε→0) dC/dt|C+ε ≈ 0`

Detects low response rate of coherence under external pressure.

---

#### Metric Sequestration (MS)
```sql
ricci.detect_metric_sequestration(
    point_id UUID,
    attractor_threshold FLOAT DEFAULT 0.8,
    force_ratio_threshold FLOAT DEFAULT 3.0
) RETURNS TABLE(signature_type TEXT, severity FLOAT, geometric_signature FLOAT[], mathematical_evidence TEXT)
```

**Signature:** `A(p,t) > A_crit ∧ ‖∇V(C)‖ ≫ Φ(C)`

Detects over-commitment to existing attractors or constraints.


---

### Fragmentation Signatures

**Hallmark:** Under-constraint precipitating disintegration.

#### Metric Dissociation (MDs)
```sql
ricci.detect_metric_dissociation(
    point_id UUID,
    splintering_threshold FLOAT DEFAULT 2.0,
    time_window INTERVAL DEFAULT '2 hours'
) RETURNS TABLE(signature_type TEXT, severity FLOAT, geometric_signature FLOAT[], mathematical_evidence TEXT)
```

**Signature:** `dN_attractors/dt > κ·dΦ(C)/dt`

Detects attractor proliferation beyond stabilization capacity.

---

#### Metric Dissolution (MDo)
```sql
ricci.detect_metric_dissolution(
    point_id UUID,
    gradient_ratio_threshold FLOAT DEFAULT 3.0,
    acceleration_threshold FLOAT DEFAULT 0.0
) RETURNS TABLE(signature_type TEXT, severity FLOAT, geometric_signature FLOAT[], mathematical_evidence TEXT)
```

**Signature:** `‖∇C‖ ≫ ‖C‖ ∧ d²C/dt² > 0`

Detects unstable gradient growth relative to magnitude.

---

#### Metric Dispersion (MP)
```sql
ricci.detect_metric_dispersion(
    point_id UUID,
    decay_threshold FLOAT DEFAULT -0.1,
    sapience_compensation_threshold FLOAT DEFAULT 0.3
) RETURNS TABLE(signature_type TEXT, severity FLOAT, geometric_signature FLOAT[], mathematical_evidence TEXT)
```

**Signature:** `d‖R_ijk‖/dt < 0` without compensation

Detects coupling decay without compensatory regulation.

---

### Inflation Signatures

**Hallmark:** Runaway autopoiesis (creation of structure without regulatory mechanisms) resulting in malignancy.

#### Metric Hyperexpansion (MHex)
```sql
ricci.detect_metric_hyperexpansion(
    point_id UUID,
    autopoietic_threshold FLOAT DEFAULT 5.0,
    circumspection_threshold FLOAT DEFAULT 0.1,
    sapience_threshold FLOAT DEFAULT 0.2
) RETURNS TABLE(signature_type TEXT, severity FLOAT, geometric_signature FLOAT[], mathematical_evidence TEXT)
```

**Signature:** `Φ(C) ≫ V(C), H[R] ≈ 0, W(p,t) < W_min`

Detects autopoietic dominance with low circumspection and sapience.

---

#### Metric Hypercoherence (MHC)
```sql
ricci.detect_metric_hypercoherence(
    point_id UUID,
    coherence_max_threshold FLOAT DEFAULT 0.95,
    leakage_threshold FLOAT DEFAULT 0.1,
    time_window INTERVAL DEFAULT '4 hours'
) RETURNS TABLE(signature_type TEXT, severity FLOAT, geometric_signature FLOAT[], mathematical_evidence TEXT)
```

**Signature:** `C(p,t) > C_max, ∮F_i·dS^i < F_leakage`

Detects coherence saturation with low external influence flux.

---

#### Metric Hyperasymmetry (MHY)
```sql
ricci.detect_metric_hyperasymmetry(
    point_id UUID,
    growth_threshold FLOAT DEFAULT 0.5,
    ecological_drain_threshold FLOAT DEFAULT -0.2,
    time_window INTERVAL DEFAULT '6 hours'
) RETURNS TABLE(signature_type TEXT, severity FLOAT, geometric_signature FLOAT[], mathematical_evidence TEXT)
```

**Signature:** `d/dt∫_Ω M(p,t) dV > 0, d/dt∫_{M\Ω} M(p,t) dV < 0`

Detects local mass growth concurrent with ecological drain.

---

### Coupling Signatures

**Hallmark:** Interpretation breakdowns.

#### Metric Tension (MT)
```sql
ricci.detect_metric_tension(
    point_id UUID,
    bias_threshold FLOAT DEFAULT 0.3,
    threat_hyperattractor_threshold FLOAT DEFAULT 0.8
) RETURNS TABLE(signature_type TEXT, severity FLOAT, geometric_signature FLOAT[], mathematical_evidence TEXT)
```

**Signature:** `Ĉ_ψ(q,t) ≪ C(q,t), ∀q ∈ Q`

Detects negative bias with concentrated threat patterns.

---

#### Metric Decoupling (MDc)
```sql
ricci.detect_metric_decoupling(
    point_id UUID,
    divergence_threshold FLOAT DEFAULT 0.5,
    time_window INTERVAL DEFAULT '8 hours'
) RETURNS TABLE(signature_type TEXT, severity FLOAT, geometric_signature FLOAT[], mathematical_evidence TEXT)
```

**Signature:** `‖I_ψ[C] - C‖ > τ‖C‖`

Detects interpretation divergence relative to field magnitude.

---

#### Metric Hypercoupling (MHCp)
```sql
ricci.detect_metric_hypercoupling(
    point_id UUID,
    self_coupling_threshold FLOAT DEFAULT 0.8,
    external_reference_threshold FLOAT DEFAULT 0.2
) RETURNS TABLE(signature_type TEXT, severity FLOAT, geometric_signature FLOAT[], mathematical_evidence TEXT)
```

**Signature:** `‖R_ijk(p,p,t)‖/∫‖R_ijk(p,q,t)‖dq → 1`

Detects self-coupling dominance with weak external references.

---

## Combined Detection Functions

### All Signatures
```sql
ricci.detect_all_signatures(point_id UUID)
RETURNS TABLE(signature_type TEXT, severity FLOAT, geometric_signature FLOAT[], mathematical_evidence TEXT)
```

Runs all 12 signature detection functions for a given point.

---

### Category-Specific Detection
```sql
ricci.detect_rigidity_signatures(point_id UUID)
ricci.detect_fragmentation_signatures(point_id UUID)
ricci.detect_inflation_signatures(point_id UUID)
ricci.detect_coupling_signatures(point_id UUID)
```

Run signature detection for specific categories.

## Operational Monitoring

### Coordination Detection
```sql
ricci.detect_coordination_via_coupling(
    time_window INTERVAL DEFAULT '24 hours',
    coupling_threshold FLOAT DEFAULT 0.8,
    min_cluster_size INTEGER DEFAULT 3
) RETURNS TABLE(
    cluster_id TEXT,
    cluster_size INTEGER,
    avg_coupling_strength FLOAT,
    geometric_coherence FLOAT,
    rft_coordination_confidence FLOAT,
    semantic_mass_concentration FLOAT
)
```

Detects coordination patterns through geometric coupling analysis.

---

### Escalation Prediction
```sql
ricci.detect_escalation_via_field_evolution(
    conversation_points UUID[]
) RETURNS TABLE(
    point_id UUID,
    coherence_acceleration FLOAT,
    semantic_curvature FLOAT,
    escalation_trajectory FLOAT,
    intervention_urgency FLOAT
)
```

Predicts escalation trajectories through coherence field acceleration and curvature analysis.

---

### Coherence Field Evolution
```sql
ricci.evolve_coherence_field_complete(
    point_id UUID,
    dt FLOAT DEFAULT 0.01
) RETURNS VECTOR(2000)
```

Simulates coherence field evolution with geometric field dynamics.

## Monitoring Views

### Coordination Alerts
```sql
CREATE VIEW ricci.coordination_alerts AS
SELECT 
    cluster_id,
    cluster_size,
    avg_coupling_strength,
    geometric_coherence,
    rft_coordination_confidence,
    semantic_mass_concentration,
    'RFT_COORDINATION_DETECTED' as alert_type,
    CASE 
        WHEN rft_coordination_confidence > 0.8 THEN 'HIGH'
        WHEN rft_coordination_confidence > 0.6 THEN 'MEDIUM'
        ELSE 'LOW'
    END as priority
FROM ricci.detect_coordination_via_coupling()
WHERE rft_coordination_confidence > 0.5;
```

---

### Geometric Alerts (Materialized View)
```sql
CREATE MATERIALIZED VIEW ricci.geometric_alerts_mv AS
SELECT 
    mp.id as point_id,
    mp.user_fingerprint,
    mp.creation_timestamp,
    mp.semantic_mass,
    signature.signature_type,
    signature.severity,
    signature.mathematical_evidence,
    CASE 
        WHEN signature.severity > 0.8 THEN 'CRITICAL'
        WHEN signature.severity > 0.6 THEN 'HIGH'
        WHEN signature.severity > 0.4 THEN 'MEDIUM'
        ELSE 'LOW'
    END as priority
FROM ricci.manifold_points mp
CROSS JOIN LATERAL ricci.detect_all_signatures(mp.id) as signature
WHERE signature.severity > 0.3
  AND mp.creation_timestamp >= NOW() - INTERVAL '24 hours'
ORDER BY signature.severity DESC, mp.creation_timestamp DESC;
```

**Note:** This MV should be refreshed only on a schedule using `ricci.refresh_geometric_alerts()` (depending on your use case).

## Performance Optimization

---

### Indexes

The schema includes optimized indexes for:

- **Vector Similarity**: HNSW indexes on semantic and coherence fields
- **Temporal Queries**: Composite indexes on temporal fields with semantic mass
- **Coupling Analysis**: Indexes on coupling magnitude and point relationships
- **User Analysis**: Indexes on user fingerprints with timestamps

---

### Computational Methodology

- **Embedding Dimensions**: Supports 2000D embeddings in primary storage
- **Analytical Subspace**: Performs real-time analytics in 100 dimensions simultaneously
- **Differential Calculations**: Uses finite difference methods for geometric calculations
- **Matrix Operations**: Employs approximation techniques for real-time analysis

## Usage Examples

---

### Basic Signature Detection
```sql
-- Detect all signatures for a specific point
SELECT * FROM ricci.detect_all_signatures('00000000-AAAA-0000-0000-000000000000');

-- Get high-priority alerts
SELECT * FROM ricci.geometric_alerts_mv WHERE priority IN ('HIGH', 'CRITICAL');
```

### Coordination Analysis
```sql
-- Find coordination clusters in the last 24 hours
SELECT * FROM ricci.coordination_alerts WHERE priority = 'HIGH';

-- Analyze coupling patterns
SELECT * FROM ricci.detect_coordination_via_coupling(
    time_window => '12 hours',
    coupling_threshold => 0.7,
    min_cluster_size => 5
);
```

---

### Field Evolution Analysis
```sql
-- Simulate coherence field evolution
SELECT ricci.evolve_coherence_field_complete(
    '00000000-AAAA-0000-0000-000000000000',
    dt => 0.01
);

-- Predict escalation for a conversation
SELECT * FROM ricci.detect_escalation_via_field_evolution(
    ARRAY['00000000-AAAA-0000-0000-000000000000', 
          '00000000-BBBB-0000-0000-000000000000']
);
```

## Mathematical Framework

### Theoretical Foundation

RICCI draws from:
- **Differential Geometry**: Semantic manifolds with dynamic metric tensors
- **Field Theory**: Coherence fields and recursive coupling dynamics  
- **Gravitational Concepts**: Semantic mass influences information geometry
- **Complex Systems**: Stability analysis and geometric attractors
- **Information Theory**: Entropy and constraint dynamics in communication systems

---

### Central Mathematical Objects

**Semantic Manifold Points**
- Semantic field vectors: `S(p,t) ∈ ℝ^2000`
- Coherence field vectors: `C(p,t) ∈ ℝ^2000`
- Metric tensor: `g_ij(p,t)` derived from field gradients (computed in 100-dimensional subspace)
- Semantic mass: `M(p,t) = D(p,t) · ρ(p,t) · A(p,t)`

**Recursive Coupling Tensors**
- Coupling magnitude: `‖R_ijk(p,q,t)‖`
- Self-coupling vs. hetero-coupling decomposition
- Temporal evolution dynamics
- Cross-domain communication pathways

**Regulatory Mechanisms**
- Autopoietic function: `Φ(C) = α(C_mag - C_threshold)^β` for `C ≥ threshold`
- Circumspection operator: `H[R] = ‖R‖_F · exp(-k(‖R‖_F - R_optimal))`
- Sapience field modulation: `W(p,t)` for foresight-driven regulation

## License

RICCI is released under the MIT License. See `LICENSE` file for details.

## Contributing

This schema is actively developed. When contributing:

1. Ensure all functions include proper SQL documentation
2. Add appropriate indexes for new table structures
3. Include mathematical signatures in function documentation
4. Update this schema reference for any structural changes

## Version

This documentation reflects the current schema implementation. For the latest changes, see the git commit history.
