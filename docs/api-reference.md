# RICCI API Reference

Complete reference for tables, functions, and views in the RICCI schema.

## Core Tables

### `ricci.manifold_points`

Primary table storing semantic manifold points with geometric properties.

**Schema:**

```sql
CREATE TABLE ricci.manifold_points (
    id UUID PRIMARY KEY,
    conversation_id UUID,
    user_fingerprint UUID,
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
- `user_fingerprint` — UUID identifier for the actor/user (type-enforced privacy, no PII storage)
- `creation_timestamp` — When the source observation occurred
- `semantic_field` — Primary 2000-dimensional semantic embedding (what is being expressed)
- `coherence_field` — 2000-dimensional coherence field embedding (how coherently it integrates)
- `coherence_magnitude` — Cached scalar magnitude `‖C‖`
- `metric_tensor` — Geometric metric tensor components (flattened upper-triangular array)
- `metric_determinant` — Determinant of the metric tensor `det(g_ij)`
- `recursive_depth` — Recursion depth component `D` for semantic mass
- `constraint_density` — Constraint density `ρ = 1/det(g_ij)` for semantic mass
- `attractor_stability` — Attractor stability `A` for semantic mass
- `semantic_mass` — Computed semantic mass `M = D × ρ × A`
- `christoffel_symbols` — Connection coefficients `Γᵏᵢⱼ` (flattened, length 1M for 100D)
- `gregorio_curvature` — Gregorio* curvature tensor components `R_ij` (flattened, length 10K for 100D)
- `scalar_curvature` — Scalar curvature `R = g^{ij}R_ij`
- `created_at` — Row creation timestamp

**Indexes:**
- HNSW on `semantic_field` (vector cosine ops)
- HNSW on `coherence_field` (vector cosine ops)
- B-tree on `(semantic_mass, creation_timestamp)`
- B-tree on `(user_fingerprint, creation_timestamp)`

*Gregorio is a reference to Gregorio Ricci-Curbastro, the mathematician who discovered tensor calculus. "Gregorio curvature" is used here in place of the more standard term "Ricci curvature" to sidestep confusion with the RICCI repository acronym, also named in his honor.

---

### `ricci.recursive_coupling`

Stores coupling relationships between manifold points.

**Schema:**

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
- `coupling_tensor` — 3rd-order coupling tensor `R_ijk` (flattened, length 1M for 100D)
- `coupling_magnitude` — Scalar strength `‖R_ijk‖`
- `self_coupling`, `hetero_coupling` — Decomposed coupling components
- `evolution_rate` — Rate of change `d‖R‖/dt`
- `latent_channels` — Compact channel descriptors

**Indexes:**
- B-tree on `(coupling_magnitude, computed_at)`
- B-tree on `(point_p, point_q, computed_at)`

---

### `ricci.sapience_field`

Regulatory mechanisms for controlling runaway dynamics.

**Schema:**

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

- `sapience_value` — Overall regulatory value ∈ [0,1]
- `forecast_sensitivity` — Responsiveness to anticipated changes
- `gradient_response` — Responsiveness to observed gradients
- `circumspection_factor` — Damping factor from circumspection operator `H[R]`
- `recursion_regulation` — Regulation on recursive depth growth

**Indexes:**
- B-tree on `(sapience_value, circumspection_factor)`

---

## Foundation Functions

### Semantic Mass

```sql
ricci.compute_semantic_mass(
    recursive_depth FLOAT,
    metric_determinant FLOAT,
    attractor_stability FLOAT
) RETURNS FLOAT
```

Computes semantic mass as: `M(p,t) = D(p,t) × ρ(p,t) × A(p,t)`

Where `ρ(p,t) = 1 / max(det(g_ij), 1e-10)` (constraint density with regularization floor).

**Example:**
```sql
SELECT ricci.compute_semantic_mass(0.8, 0.05, 0.9);
-- Returns: 14.4 (= 0.8 × (1/0.05) × 0.9; high mass due to high constraint density from low determinant)
```

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

Computes autopoietic potential: `Φ(C) = α(‖C‖ - C_threshold)^β` for `‖C‖ ≥ C_threshold`, else 0.

**Example:**
```sql
SELECT ricci.compute_autopoietic_potential(0.85);
-- Returns: 0.0225 (= 1.0 * (0.85 - 0.7)^2)
```

---

### Circumspection Operator

```sql
ricci.compute_circumspection_operator(
    coupling_magnitude FLOAT,
    optimal_recursion FLOAT DEFAULT 0.5,
    decay_constant FLOAT DEFAULT 2.0
) RETURNS FLOAT
```

Computes circumspection regulation: `H[R] = ‖R‖_F × exp(-k(‖R‖_F - R_optimal))`

Exponent is clamped to `[-50, 50]` for numerical stability.

**Example:**
```sql
SELECT ricci.compute_circumspection_operator(0.6);
-- Returns: ~0.57 (damped slightly above optimal)
```

---

### Vector Utilities

```sql
ricci.vector_to_real_array(v VECTOR) RETURNS FLOAT[]
```

Converts pgvector to FLOAT[] for element-wise operations.

---

```sql
ricci.vector_l2_norm(v VECTOR) RETURNS FLOAT
```

Computes L2 norm: `‖v‖ = sqrt(Σ v_i²)`

---

```sql
ricci.vector_l2_norm_first_n(v VECTOR, n INTEGER) RETURNS FLOAT
```

Computes L2 norm of first `n` components only.

---

```sql
ricci.vector_l2_distance_first_n(v1 VECTOR, v2 VECTOR, n INTEGER) RETURNS FLOAT
```

Computes L2 distance using only first `n` components.

---

## Geometric Analysis Functions

### Metric Tensor

```sql
ricci.compute_metric_tensor_from_semantic_field(
    semantic_field VECTOR(2000),
    neighboring_fields VECTOR(2000)[],
    base_metric_scale FLOAT DEFAULT 1.0
) RETURNS FLOAT[]
```

Constructs heuristic metric tensor `g_ij` from local field gradients in 100D analytical subspace.

- Uses two neighbors to estimate gradients
- Populates upper-triangular entries (symmetric assumption)
- Adds `base_metric_scale` to diagonal for stability
- Returns flattened array (length 10,000)

**Example:**
```sql
SELECT ricci.compute_metric_tensor_from_semantic_field(
    (SELECT semantic_field FROM ricci.manifold_points WHERE id = '...'),
    ARRAY(SELECT semantic_field FROM ricci.manifold_points 
          ORDER BY creation_timestamp LIMIT 2)
);
```

---

### Metric Inverse

```sql
ricci.compute_metric_inverse(
    metric_components FLOAT[],
    dimension INTEGER DEFAULT 100
) RETURNS FLOAT[]
```

Computes `g^{ij}` from symmetric `g_ij` using Gauss-Jordan elimination.

- Expands upper-triangular to full `n×n`
- If `|det(g)| < 1e-10`, adds `1e-6` to diagonal (regularization)
- Returns flattened full inverse (length `n²`)

---

### Christoffel Symbols

```sql
ricci.compute_christoffel_symbols(
    metric_components FLOAT[],
    metric_derivatives FLOAT[][],
    dimension INTEGER DEFAULT 100
) RETURNS FLOAT[]
```

Computes connection coefficients: `Γᵏᵢⱼ = ½g^{kl}(∂ᵢg_{jl} + ∂ⱼg_{il} - ∂ₗg_{ij})`

- Requires metric and its derivatives
- Returns flattened array (length `n³ = 1,000,000` for 100D)
- Complexity: O(n⁴)

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

Truncates VECTOR(2000) to active dimension for computation.

---

### Gregorio Curvature

```sql
ricci.compute_gregorio_curvature(
    christoffel_symbols FLOAT[],
    christoffel_derivatives FLOAT[][][],
    dimension INTEGER DEFAULT 100
) RETURNS FLOAT[]
```

Computes contracted curvature tensor components `R_ij`.

- Uses Christoffel symbols and their derivatives
- Returns flattened array (length `n² = 10,000` for 100D)
- Complexity: O(n⁴)

---

### Scalar Curvature

```sql
ricci.compute_scalar_curvature(
    gregorio_components FLOAT[],
    metric_inverse FLOAT[],
    dimension INTEGER DEFAULT 100
) RETURNS FLOAT
```

Contracts scalar curvature: `R = g^{ij}R_ij`

---

### Geodesic Distance

```sql
ricci.integrate_geodesic_distance(
    point_a UUID,
    point_b UUID,
    num_steps INTEGER DEFAULT 100
) RETURNS FLOAT
```

Integrates geodesic distance between two manifold points over linearized trajectory.

- Linearly mixes `Γ` and `g` along path
- Falls back to Euclidean when tensors missing
- Returns approximate geodesic length accounting for curvature

---

### Recursive Coupling Tensor

```sql
ricci.compute_recursive_coupling_tensor(
    point_p UUID,
    point_q UUID,
    h FLOAT DEFAULT 1e-6
) RETURNS FLOAT[]
```

Computes 3rd-order coupling tensor `R_ijk` between two points.

- Heuristic mixed-partial over semantic/coherence fields
- Active dimension n=100
- Returns flattened array (length 1,000,000)

---

### Finite Differences

```sql
ricci.compute_finite_differences(
    point_id UUID,
    h FLOAT DEFAULT 1e-6
) RETURNS TABLE(
    first_derivatives FLOAT[],
    second_derivatives FLOAT[]
)
```

Computes first and second finite-difference derivatives of coherence field in 100D.

- Center differences for interior points
- Forward/backward near edges
- Returns arrays of length 100

---

### Linear Algebra

```sql
ricci.matrix_determinant(matrix FLOAT[][], n INTEGER) RETURNS FLOAT
```

Computes determinant via LU-style elimination with partial pivoting. Returns 0.0 if `|pivot| < 1e-12`.

---

```sql
ricci.matrix_inverse_gauss_jordan(matrix FLOAT[][], n INTEGER) RETURNS FLOAT[][]
```

Inverts matrix using Gauss-Jordan elimination on augmented system. Raises exception if singular.

---

## Signature Detection Functions

All signature detectors return:

```sql
TABLE(
    signature_type TEXT,
    severity FLOAT,              -- ∈ [0,1]
    geometric_signature FLOAT[], -- Relevant field quantities
    mathematical_evidence TEXT   -- Human-readable threshold violations
)
```

### Rigidity Signatures

#### Metric Crystallization

```sql
ricci.detect_metric_crystallization(
    point_id UUID,
    evolution_threshold FLOAT DEFAULT 0.01,
    curvature_threshold FLOAT DEFAULT 0.1
) RETURNS TABLE(...)
```

**Condition:** `∂g_ij/∂t → 0` while `R_ij ≠ 0`

Detects interpretive frameworks freezing while tensions persist.

**Severity:** `clip((curvature_pressure / (evolution_rate + ε)) / 100)`

---

#### Field Calcification

```sql
ricci.detect_field_calcification(
    point_id UUID,
    responsiveness_threshold FLOAT DEFAULT 0.01,
    time_window INTERVAL DEFAULT '6 hours'
) RETURNS TABLE(...)
```

**Condition:** `lim(ε→0) dC/dt|C+ε ≈ 0` despite external pressure

Detects low response rate of coherence under external pressure.

**Severity:** `clip((avg_external_pressure / (coherence_change_rate + ε)) / 50)`

---

#### Attractor Isolation

```sql
ricci.detect_attractor_isolation(
    point_id UUID,
    attractor_threshold FLOAT DEFAULT 0.8,
    force_ratio_threshold FLOAT DEFAULT 3.0
) RETURNS TABLE(...)
```

**Condition:** `A(p,t) > A_crit ∧ ‖∇V(C)‖ ≫ Φ(C)`

Detects over-commitment to existing attractors or constraints.

**Severity:** `clip((constraining_force / Φ(C)) / 10)`

---

### Fragmentation Signatures

#### Attractor Dissociation

```sql
ricci.detect_attractor_dissociation(
    point_id UUID,
    splintering_threshold FLOAT DEFAULT 2.0,
    time_window INTERVAL DEFAULT '2 hours'
) RETURNS TABLE(...)
```

**Condition:** `dN_attractors/dt > κ × dΦ(C)/dt`

Detects attractor proliferation beyond stabilization capacity.

**Severity:** `clip((attractor_generation_rate / autopoietic_generation_rate) / 10)`

---

#### Field Dissolution

```sql
ricci.detect_field_dissolution(
    point_id UUID,
    gradient_ratio_threshold FLOAT DEFAULT 3.0,
    acceleration_threshold FLOAT DEFAULT 0.0
) RETURNS TABLE(...)
```

**Condition:** `‖∇C‖ ≫ ‖C‖ ∧ d²C/dt² > 0`

Detects unstable gradient growth relative to magnitude.

**Severity:** `clip((‖∇C‖ / (‖C‖ + ε)) / 10)`

---

#### Coupling Dispersion

```sql
ricci.detect_coupling_dispersion(
    point_id UUID,
    decay_threshold FLOAT DEFAULT -0.1,
    sapience_compensation_threshold FLOAT DEFAULT 0.3
) RETURNS TABLE(...)
```

**Condition:** `d‖R_ijk‖/dt < 0` without compensatory sapience

Detects coupling decay without compensatory regulation.

**Severity:** `clip(|decay_rate| × (1 - compensatory_sapience) × 10)`

---

### Inflation Signatures

#### Structure Hyperexpansion

```sql
ricci.detect_structure_hyperexpansion(
    point_id UUID,
    autopoietic_threshold FLOAT DEFAULT 5.0,
    circumspection_threshold FLOAT DEFAULT 0.1,
    sapience_threshold FLOAT DEFAULT 0.2
) RETURNS TABLE(...)
```

**Condition:** `Φ(C) ≫ V(C), H[R] ≈ 0, W(p,t) < W_min`

Detects autopoietic dominance with low circumspection and sapience.

**Severity:** `clip((Φ / force) × (1 - H) × (1 - W) / 20)`

---

#### Field Hypercoherence

```sql
ricci.detect_field_hypercoherence(
    point_id UUID,
    coherence_max_threshold FLOAT DEFAULT 0.95,
    leakage_threshold FLOAT DEFAULT 0.1,
    time_window INTERVAL DEFAULT '4 hours'
) RETURNS TABLE(...)
```

**Condition:** `C(p,t) > C_max, ∮F_i·dS^i < F_leakage`

Detects coherence saturation with low external influence flux.

**Severity:** `clip(‖C‖ × (1 - external_influence_flux))`

---

#### Boundary Hyperasymmetry

```sql
ricci.detect_boundary_hyperasymmetry(
    point_id UUID,
    growth_threshold FLOAT DEFAULT 0.5,
    ecological_drain_threshold FLOAT DEFAULT -0.2,
    time_window INTERVAL DEFAULT '6 hours'
) RETURNS TABLE(...)
```

**Condition:** `d/dt∫_Ω M(p,t) dV > 0, d/dt∫_{M\Ω} M(p,t) dV < 0`

Detects local mass growth concurrent with ecological drain.

**Severity:** `clip(local_growth × |ecological_drain| × 5)`

---

### Distortion Signatures

#### Signal Projection

```sql
ricci.detect_signal_projection(
    point_id UUID,
    bias_threshold FLOAT DEFAULT 0.3,
    threat_hyperattractor_threshold FLOAT DEFAULT 0.8
) RETURNS TABLE(...)
```

**Condition:** `Ĉ_ψ(q,t) ≪ C(q,t), ∀q ∈ Q`

Detects negative bias with concentrated threat patterns.

**Severity:** `clip(negative_bias × threat_concentration × 2)`

---

#### Operative Decoupling

```sql
ricci.detect_operative_decoupling(
    point_id UUID,
    divergence_threshold FLOAT DEFAULT 0.5,
    time_window INTERVAL DEFAULT '8 hours'
) RETURNS TABLE(...)
```

**Condition:** `‖I_ψ[C] - C‖ > τ‖C‖`

Detects interpretation divergence relative to field magnitude.

**Severity:** `clip((interpretation_divergence / ‖C‖) × consensus_divergence)`

---

#### Recursive Hypercoupling

```sql
ricci.detect_recursive_hypercoupling(
    point_id UUID,
    self_coupling_threshold FLOAT DEFAULT 0.8,
    external_reference_threshold FLOAT DEFAULT 0.2
) RETURNS TABLE(...)
```

**Condition:** `‖R_ijk(p,p,t)‖ / ∫‖R_ijk(p,q,t)‖dq → 1`

Detects self-coupling dominance with weak external references.

**Severity:** `clip((self_coupling / total) × (1 - external / total))`

---

### Combined Detection

```sql
ricci.detect_all_signatures(point_id UUID) RETURNS TABLE(...)
```

Runs all 12 signature detection functions for a given point.

---

```sql
ricci.detect_rigidity_signatures(point_id UUID) RETURNS TABLE(...)
ricci.detect_fragmentation_signatures(point_id UUID) RETURNS TABLE(...)
ricci.detect_inflation_signatures(point_id UUID) RETURNS TABLE(...)
ricci.detect_distortion_signatures(point_id UUID) RETURNS TABLE(...)
```

Category-specific detection (3 signatures each).

---

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

Clusters cross-user pairs with high coupling into hourly buckets and scores coordination confidence:

```
rft_coordination_confidence = clip(
    avg(coupling) × avg(geometric_coherence) × (count/10) × (avg_mass/100)
)
```

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

- Computes velocity from distance over time
- Couples with scalar curvature
- Weights by semantic mass
- Flags high intervention urgency when acceleration > 0.3 and circumspection < 0.3

---

### Coherence Field Evolution

```sql
ricci.evolve_coherence_field_complete(
    point_id UUID,
    dt FLOAT DEFAULT 0.01
) RETURNS VECTOR(2000)
```

Simulates coherence field evolution with geometric field dynamics.

Integrates four evolution forces:
1. **Dalembertian** (covariant second derivative + Gregorio term)
2. **Stability attractor** (restoring force toward `C_threshold`)
3. **Autopoietic gradient** (structure creation above threshold)
4. **Circumspection damping** (regulatory constraint)

---

## Monitoring Views

### `ricci.coordination_alerts`

Real-time view of coordination clusters with priority levels.

**Schema:**
```sql
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

### `ricci.geometric_alerts_mv`

Materialized view of geometric alerts within the last 24 hours.

**Schema:**
```sql
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

**Refresh:**
```sql
SELECT ricci.refresh_geometric_alerts();
```

**Indexes:**
- B-tree on `(point_id, creation_timestamp)`
- B-tree on `(severity, creation_timestamp)`
- B-tree on `priority`

---

## Performance Notes

- **Active dimension**: Geometric computations use 100D analytical subspace
- **Storage dimension**: Full 2000D embeddings stored via pgvector
- **Complexity bounds**:
  - Christoffel symbols: O(n⁴) ≈ 100M operations for n=100
  - Curvature tensors: O(n⁴) ≈ 100M operations
  - Single detector: ~3-5s per point
  - All signatures: ~10s per point
- **Index coverage**: HNSW for vector similarity, B-tree for temporal/coupling queries

For detailed usage examples, see the [Operations Guide](operations-guide.md).

For mathematical context, see the [Mathematical Foundation](mathematical-foundation.md).

