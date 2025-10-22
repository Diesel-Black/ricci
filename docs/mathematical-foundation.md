# RICCI Mathematical Foundation

## Overview

RICCI implements *Recurgent Field Theory* (RFT), a Lagrangian framework that models semantic systems as differentiable manifolds with recursive coupling. The mathematical machinery enables detection of 12 geometric signatures that emerge when feedback loops enter unstable configurations.

## Core Mathematical Objects

### Semantic Manifold Points

Each point `p` in the semantic manifold represents a single message or contribution with both semantic content and coherence structure:

- **Semantic field**: `S(p,t) ∈ ℝ^2000` — The primary vector embedding representing *what is being expressed*
- **Coherence field**: `C(p,t) ∈ ℝ^2000` — A secondary vector representing *how coherently the expression integrates with context*
- **Metric tensor**: `g_ij(p,t)` — Defines how distances and angles are measured at each point, derived from local field gradients
- **Semantic mass**: `M(p,t) = D(p,t) · ρ(p,t) · A(p,t)` — Measures gravitational influence on local geometry

High coherence doesn't mean "good"—it means tightly coupled to existing structure, which can be healthy (integration) or pathological (rigidity).

### The Metric Tensor

The metric tensor `g_ij(p,t)` is the fundamental geometric object in RICCI:

- Computed in a 100-dimensional analytical subspace from local field gradients
- Stored as flattened upper-triangular components (symmetric assumption)
- Defines the constraint geometry: how difficult it is to move in different directions
- When `det(g_ij) → 0`, constraint density spikes (rigidity)
- When `∂g_ij/∂t → 0` with persistent curvature, crystallization occurs

### Semantic Mass Components

Semantic mass `M(p,t)` is computed from three factors:

**Recursive Depth** `D(p,t)`:
- Measures how self-referential a point is
- Higher values indicate more self-contained reasoning

**Constraint Density** `ρ(p,t)`:
- Defined as `ρ = 1 / max(det(g_ij), ε)`
- Inverse of metric determinant (with regularization floor at `1e-10`)
- High constraint density means fewer degrees of freedom

**Attractor Stability** `A(p,t)`:
- Measures how "locked in" a viewpoint is
- High stability resists change; over-stability becomes rigidity

The product `M = D × ρ × A` captures how much a point warps local geometry and resists movement.

### Recursive Coupling Tensors

Coupling between points `p` and `q` is represented by a 3rd-order tensor `R_ijk(p,q,t)`:

- **Coupling magnitude**: `‖R_ijk(p,q,t)‖` — Scalar strength of interaction
- **Self-coupling vs. hetero-coupling**: Decomposition reveals echo chamber dynamics
- **Evolution rate**: Tracks how coupling strength changes over time
- **Latent channels**: Compact descriptors of communication pathways

Strong coupling isn't inherently good or bad; it depends on whether it enables coordination or creates pathological feedback loops.

## Regulatory Mechanisms

### Autopoietic Potential

The autopoietic function drives structure creation:

```
Φ(C) = α(‖C‖ - C_threshold)^β   for ‖C‖ ≥ C_threshold
Φ(C) = 0                          otherwise
```

Where:
- `C_threshold ≈ 0.7` (coherence activation threshold)
- `α = 1.0` (scaling factor)
- `β = 2.0` (exponent governing runaway behavior)

This is what fuels inflation signatures: the system generates structure faster than feedback can constrain it.

### Circumspection Operator

The circumspection operator provides damping against excessive recursion:

```
H[R] = ‖R‖_F · exp(-k(‖R‖_F - R_optimal))
```

Where:
- `‖R‖_F` is the Frobenius norm of the coupling tensor
- `k = 2.0` (decay constant)
- `R_optimal ≈ 0.5` (optimal recursion level)

Exponential damping centered at `R_optimal` prevents runaway self-referential dynamics.

### Sapience Field

The sapience field `W(p,t)` provides foresight-driven regulation:

- **Sapience value**: Overall regulatory capacity (0-1)
- **Forecast sensitivity**: Responsiveness to anticipated changes
- **Gradient response**: Responsiveness to observed field gradients
- **Recursion regulation**: Damping on recursive depth growth

Low sapience combined with high autopoietic potential signals structure hyperexpansion.

## Differential Geometry Operators

### Christoffel Symbols

Connection coefficients that define parallel transport:

```
Γᵏᵢⱼ = ½gᵏˡ(∂ᵢgⱼˡ + ∂ⱼgᵢˡ - ∂ˡgᵢⱼ)
```

Computed via:
1. Expand symmetric metric to full `n×n` array
2. Compute metric inverse `g^{ij}` via Gauss-Jordan elimination with regularization
3. Evaluate partial derivatives of metric components
4. Contract according to formula above
5. Flatten result to row-major order (length `n³`)

### Covariant Derivative

Extends ordinary derivatives to curved spaces:

```
∇ᵢVⱼ = ∂ᵢVⱼ - ΓᵏᵢⱼVₖ
```

The covariant derivative accounts for how basis vectors change across the manifold.

### Gregorio Curvature

A contracted curvature tensor measuring geometric stress:

```
R_ij = ∂_k Γᵏᵢⱼ - ∂_j Γᵏᵢₖ + Γˡᵢⱼ Γᵏₖˡ - Γˡᵢₖ Γᵏⱼˡ
```

When `R_ij ≠ 0` while `∂g_ij/∂t → 0`, you have metric crystallization.

### Scalar Curvature

The fully contracted curvature:

```
R = g^{ij} R_ij
```

Used in escalation prediction and field evolution to couple geometric stress with coherence acceleration.

## Computational Methodology

### Dimension Reduction Strategy

RICCI uses a two-tier approach:

- **Storage**: Full 2000-dimensional embeddings via pgvector
- **Analysis**: 100-dimensional analytical subspace for real-time geometric calculations

This enables tractable computation of metric tensors, Christoffel symbols, and curvature tensors without sacrificing embedding quality.

### Numerical Guards

Throughout the implementation:

- **Regularization constants**: `ε ∈ [1e-12, 1e-6]` guard near-singular cases
- **Determinant floors**: `det(g_ij) ≥ 1e-10` prevents division by zero in constraint density
- **Diagonal stabilization**: Add `1e-6` to diagonal when `|det(g_ij)| < 1e-10` before inversion
- **Exponent clamping**: Bound exponential arguments to `[-50, 50]` for numerical stability
- **Index clipping**: Ensure array access stays within bounds when truncating dimensions

### Finite Difference Methods

First and second derivatives use centered differences when possible:

```
∂_i C_j ≈ (C_j(i+h) - C_j(i-h)) / 2h
∂²_i C_j ≈ (C_j(i+h) - 2C_j(i) + C_j(i-h)) / h²
```

With `h = 1e-6` as the default step size. Forward/backward differences are used at boundaries.

## Geometric Signatures

The 12 signatures emerge from threshold violations in field properties:

### Rigidity Signatures

1. **Metric Crystallization**: `∂g_ij/∂t → 0` while `R_ij ≠ 0`
2. **Field Calcification**: `lim(ε→0) dC/dt|C+ε ≈ 0`
3. **Attractor Isolation**: `A(p,t) > A_crit ∧ ‖∇V(C)‖ ≫ Φ(C)`

### Fragmentation Signatures

4. **Attractor Dissociation**: `dN_attractors/dt > κ·dΦ(C)/dt`
5. **Field Dissolution**: `‖∇C‖ ≫ ‖C‖ ∧ d²C/dt² > 0`
6. **Coupling Dispersion**: `d‖R_ijk‖/dt < 0` without compensation

### Inflation Signatures

7. **Boundary Hyperasymmetry**: `d/dt∫_Ω M(p,t) dV > 0, d/dt∫_{M\Ω} M(p,t) dV < 0`
8. **Field Hypercoherence**: `C(p,t) > C_max, ∮F_i·dS^i < F_leakage`
9. **Structure Hyperexpansion**: `Φ(C) ≫ V(C), H[R] ≈ 0, W(p,t) < W_min`

### Distortion Signatures

10. **Operative Decoupling**: `‖I_ψ[C] - C‖ > τ‖C‖`
11. **Signal Projection**: `Ĉ_ψ(q,t) ≪ C(q,t), ∀q ∈ Q`
12. **Recursive Hypercoupling**: `‖R_ijk(p,p,t)‖/∫‖R_ijk(p,q,t)‖dq → 1`

Each signature has a severity score `∈ [0,1]` computed from the ratio of observed field properties to threshold values, and includes mathematical evidence showing which geometric conditions were violated.

## Theoretical Foundations

RICCI draws from multiple mathematical domains:

- **Differential Geometry**: Semantic manifolds with dynamic metric tensors
- **Field Theory**: Coherence fields and recursive coupling dynamics
- **Gravitational Concepts**: Semantic mass influences information geometry
- **Complex Systems**: Stability analysis and geometric attractors
- **Information Theory**: Entropy and constraint dynamics in communication systems

The unifying principle is that *communication creates semantic structure*, and this structure evolves through tangled feedback loops that can be measured geometrically. When these feedback loops enter unstable configurations, predictable pathological patterns emerge from the field equations.

## Related Work

Similar patterns appear across scales from individual cognition to organizational dynamics, suggesting common geometric mechanisms intrinsic to complex systems of inference and interpretation.

For implementation details, see the schema files in `schema/*.sql`.

For practical usage, see the [Operations Guide](operations-guide.md) and [API Reference](api-reference.md).

