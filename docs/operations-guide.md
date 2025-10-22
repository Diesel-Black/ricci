# RICCI Operations Guide

## Loading Data

RICCI requires three ingredients, plus an optional grouping ID:

1. Embeddings — Vector representations of each message (2000D)
2. Provenance — Associated UUID (`user_fingerprint`)
3. Timestamp — When the manifold point was created (`creation_timestamp`)
4. Conversation ID — (optional) UUID grouping identifier for related points

### Insert Manifold Points

```sql
INSERT INTO ricci.manifold_points (
    id, 
    conversation_id, 
    user_fingerprint, 
    creation_timestamp,
    semantic_field, 
    coherence_field
) VALUES (
    gen_random_uuid(), 
    '550e8400-e29b-41d4-a716-446655440000',  -- conversation_id (optional; set NULL if not used)
    '123e4567-e89b-12d3-a456-426614174000',  -- user_fingerprint (consistent per user)
    NOW(),
    embedding_vector,  -- VECTOR(2000)
    embedding_vector   -- VECTOR(2000)
);
```

### Important privacy notes
- `user_fingerprint` must be a UUID (type-enforced, no PII storage)
- Persistent UUIDs require consideration; see [Privacy Considerations](#privacy-considerations)
- Consider rotating UUIDs periodically to limit temporal pattern exposure

### Initial Field Setup

For initial inserts, you typically set `semantic_field = coherence_field` using the same embedding. RICCI will compute geometric properties (`metric_tensor`, `semantic_mass`, etc.) through subsequent analysis functions or triggers if you choose to implement them.

Alternatively, populate computed fields explicitly:

```sql
UPDATE ricci.manifold_points
SET 
    coherence_magnitude = ricci.vector_l2_norm(coherence_field),
    semantic_mass = ricci.compute_semantic_mass(
        recursive_depth,
        COALESCE(metric_determinant, 1.0),
        attractor_stability
    )
WHERE id = '...';
```

## Basic Usage

### Analyze a Single Point

```sql
-- Detect all signatures for a specific point
SELECT * FROM ricci.detect_all_signatures('00000000-aaaa-0000-0000-000000000000');
```

Returns:
```
signature_type         | severity | geometric_signature          | mathematical_evidence
-----------------------|----------|------------------------------|----------------------------------------
FIELD_HYPERCOHERENCE   | 0.89     | {0.94,0.12,0.45,8.0}        | Coherence: 0.940000 > max threshold...
COUPLING_DISPERSION    | 0.76     | {-0.34,0.52,0.18,7.0}       | Coupling decay rate: -0.340000 < 0...
```

### Analyze an Entire Conversation

```sql
-- Get average severity by signature type for a conversation
SELECT 
    signature_type, 
    AVG(severity) as avg_severity,
    MAX(severity) as max_severity,
    COUNT(*) as occurrence_count
FROM ricci.manifold_points mp
CROSS JOIN LATERAL ricci.detect_all_signatures(mp.id)
WHERE mp.conversation_id = '550e8400-e29b-41d4-a716-446655440000'
GROUP BY signature_type
HAVING AVG(severity) > 0.5
ORDER BY avg_severity DESC;
```

### Category-Specific Detection

```sql
-- Run only rigidity detectors
SELECT * FROM ricci.detect_rigidity_signatures(point_id);

-- Run only fragmentation detectors
SELECT * FROM ricci.detect_fragmentation_signatures(point_id);

-- Run only inflation detectors
SELECT * FROM ricci.detect_inflation_signatures(point_id);

-- Run only distortion detectors
SELECT * FROM ricci.detect_distortion_signatures(point_id);
```

## Monitoring & Alerting

### Real-Time Geometric Alerts

Query the materialized view for high-severity alerts:

```sql
-- Get all high-priority alerts from the last 24 hours
SELECT * 
FROM ricci.geometric_alerts_mv 
WHERE priority IN ('HIGH', 'CRITICAL')
ORDER BY severity DESC;
```

The materialized view includes:
- `point_id`, `user_fingerprint`, `creation_timestamp`
- `signature_type`, `severity`, `mathematical_evidence`
- `priority` (LOW/MEDIUM/HIGH/CRITICAL based on severity thresholds)

### Refresh Alerts

The materialized view is not auto-refreshed. Refresh on your schedule:

```sql
-- Manual refresh
SELECT ricci.refresh_geometric_alerts();

-- Or schedule via cron/pg_cron:
SELECT cron.schedule('refresh-ricci-alerts', '*/15 * * * *', 
    'SELECT ricci.refresh_geometric_alerts();'
);
```

Recommended refresh intervals:
- Real-time monitoring: Every 5-15 minutes
- Daily review: Once per hour
- Historical analysis: Manual refresh as needed

### Coordination Alerts

Detect coordination patterns across users:

```sql
-- View coordination clusters with high confidence
SELECT * 
FROM ricci.coordination_alerts 
WHERE priority = 'HIGH';
```

The view shows:
- `cluster_id`, `cluster_size` — Temporal grouping and edge count
- `avg_coupling_strength` — Mean coupling magnitude in cluster
- `geometric_coherence` — Adjusted similarity via metric determinant
- `rft_coordination_confidence` — Combined score ∈ [0,1]
- `semantic_mass_concentration` — Average influence in cluster

### Escalation Prediction

Forecast when discussions will spiral:

```sql
-- Get intervention urgency scores for a conversation
SELECT * 
FROM ricci.detect_escalation_via_field_evolution(
    ARRAY(
        SELECT id 
        FROM ricci.manifold_points 
        WHERE conversation_id = 'a3dcb4d2-6f1a-4a3e-9fb7-9c4ad5b6e7f8'
        ORDER BY creation_timestamp
    )
);
```

Returns:
- `point_id` — Point being analyzed
- `coherence_acceleration` — Rate of change in coherence velocity
- `semantic_curvature` — Scalar curvature at point
- `escalation_trajectory` — Predicted escalation intensity
- `intervention_urgency` — Priority score ∈ [0,1]

High `intervention_urgency` (> 0.7) combined with low circumspection indicates imminent breakdown.

## Use Cases

### Early Warning System

Monitor communication channels for signs of dysfunction:

```sql
-- Flag high-risk discussions requiring immediate attention
SELECT 
    mp.conversation_id,
    COUNT(DISTINCT signature_type) as pathology_count,
    AVG(severity) as avg_severity,
    MAX(severity) as max_severity,
    array_agg(DISTINCT signature_type) as signatures_present
FROM ricci.geometric_alerts_mv ga
JOIN ricci.manifold_points mp ON mp.id = ga.point_id
WHERE severity > 0.7
GROUP BY mp.conversation_id
ORDER BY avg_severity DESC;
```

Example output includes mathematical evidence for every detection, enabling targeted intervention:

```
signature_type         | severity | mathematical_evidence
-----------------------|----------|--------------------------------------------------------
field_hypercoherence   | 0.89     | Coherence saturation: 0.94 > 0.85 with external
                       |          | influence: 0.12 < 0.25 (isolation ratio: 7.83)
coupling_dispersion    | 0.76     | Coupling decay: -0.34 < -0.3 with sapience: 0.18
                       |          | < 0.5 (dispersion ratio: 1.89)
```

### Post-Mortem Analysis

Understand why a project failed by tracing pathology evolution:

```sql
-- Trace signatures over time for a failed initiative
SELECT 
    mp.creation_timestamp,
    signature_type,
    severity,
    mathematical_evidence,
    mp.semantic_mass
FROM ricci.manifold_points mp
CROSS JOIN LATERAL ricci.detect_all_signatures(mp.id)
WHERE mp.conversation_id = '8b1e7a30-1f3a-4b8a-9b9e-1a2b3c4d5e6f'
  AND severity > 0.3
ORDER BY mp.creation_timestamp;
```

Identify:
- When pathologies first emerged
- Which signature types dominated at each phase
- Whether interventions reduced severity
- Tipping points where severity spiked

### Team Health Monitoring

Detect coordination breakdowns or echo chamber formation:

```sql
-- Identify problematic coupling patterns
SELECT * 
FROM ricci.detect_coordination_via_coupling(
    time_window => '7 days',
    coupling_threshold => 0.8,
    min_cluster_size => 5
);
```

### Temporal Pattern Analysis

Track how field properties evolve:

```sql
-- Monitor semantic mass concentration over time
SELECT 
    date_trunc('day', creation_timestamp) as day,
    AVG(semantic_mass) as avg_mass,
    STDDEV(semantic_mass) as mass_variance,
    COUNT(*) as message_count
FROM ricci.manifold_points
WHERE creation_timestamp >= NOW() - INTERVAL '30 days'
GROUP BY day
ORDER BY day;
```

## Advanced Operations

### Field Evolution Simulation

Simulate how coherence fields will evolve:

```sql
-- Evolve coherence field forward one time step
SELECT ricci.evolve_coherence_field_complete(
    '00000000-aaaa-0000-0000-000000000000',
    dt => 0.01
);
```

The evolution integrates:
- Dalembertian (covariant wave operator)
- Stability attractor forces
- Autopoietic gradient (structure creation)
- Circumspection damping

Useful for forecasting field dynamics without waiting for new data.

### Geodesic Distance Computation

Measure true distance between points accounting for metric curvature:

```sql
-- Compute geodesic distance between two points
SELECT ricci.integrate_geodesic_distance(
    point_a => '00000000-aaaa-0000-0000-000000000000',
    point_b => '00000000-bbbb-0000-0000-000000000000',
    num_steps => 100
);
```

Returns integrated path length through curved semantic space.

### Coupling Tensor Analysis

Compute recursive coupling between specific points:

```sql
-- Analyze coupling between two contributors
SELECT ricci.compute_recursive_coupling_tensor(
    point_p => '00000000-aaaa-0000-0000-000000000000',
    point_q => '00000000-bbbb-0000-0000-000000000000'
);
```

Returns flattened 3rd-order tensor (length 1,000,000 for 100D).

### Custom Threshold Tuning

All detectors accept threshold parameters:

```sql
-- Detect metric crystallization with custom thresholds
SELECT * FROM ricci.detect_metric_crystallization(
    point_id => '00000000-aaaa-0000-0000-000000000000',
    evolution_threshold => 0.005,      -- Lower = more sensitive
    curvature_threshold => 0.15        -- Higher = less sensitive
);
```

Tune thresholds based on your domain's baseline dynamics.

## Performance Optimization

### Index Strategy

RICCI creates several indexes automatically:

**Vector Similarity** (HNSW):
- `idx_manifold_points_semantic_field`
- `idx_manifold_points_coherence_field`

**Temporal Queries** (B-tree):
- `idx_manifold_points_semantic_mass` (with `creation_timestamp`)
- `idx_manifold_points_user_timestamp`

**Coupling Analysis** (B-tree):
- `idx_recursive_coupling_magnitude` (with `computed_at`)
- `idx_recursive_coupling_points` (with `computed_at`)

### Memory Considerations

- Each manifold point: ~8KB (2× VECTOR(2000) + metadata)
- Coupling records: ~4KB (flattened tensors)
- Metric tensors: ~40KB (100×100 matrix)

Estimate storage: `(8KB × points) + (4KB × couplings) + overhead`

## Privacy Considerations

RICCI operates exclusively on vector embeddings and enforces privacy-by-design:

### Built-In Privacy

- The `user_fingerprint` field only accepts UUIDs, precluding accidental PII storage
- RICCI never sees or processes raw text
- Embeddings cannot be perfectly anonymized, but contain no direct identifiers

### Deployment Best Practices

For sensitive deployments:

1. Always use TLS/SSL between application and database
2. Implement strong database-level permissions appropriate for your threat model
3. Rotate `user_fingerprint` UUIDs periodically to limit temporal pattern exposure
4. Exercise judicious consideration of what content should be embedded in the first place

### Inherent Limitations

Be aware:

- Embeddings encode semantic structure that may be identifiable in context
- Coupling analysis explicitly stores interaction patterns between UUIDs
- Temporal sequences enable the coordination/escalation analysis that makes RICCI valuable
- Even with UUIDs, persistent patterns may enable correlation

RICCI provides infrastructure to analyze coordination while minimizing data collection. **How you configure that boundary is your responsibility** as the deployer, subject to data privacy laws in your jurisdiction.

## Troubleshooting

### Missing Geometric Properties

If `metric_tensor`, `semantic_mass`, or `christoffel_symbols` are NULL, detectors may return empty results. Ensure you:

1. Populate `coherence_magnitude` after insert
2. Compute metric tensors using helper functions
3. Update `semantic_mass` with component values

### Slow Queries

If detection is slow:

1. Check index coverage: `EXPLAIN ANALYZE` on your queries
2. Verify HNSW indexes built: `\d ricci.manifold_points`
3. Consider reducing time windows in detector calls
4. Use category-specific detectors instead of `detect_all_signatures`

### Unexpected Severities

If severities seem too high/low:

1. Verify your embeddings are properly normalized
2. Check that `coherence_field` differs from `semantic_field` (if applicable)
3. Tune detector thresholds for your domain
4. Review mathematical evidence to understand which conditions triggered

### Materialized View Staleness

If alerts seem outdated:

1. Check last refresh: `SELECT * FROM pg_matviews WHERE matviewname = 'geometric_alerts_mv';`
2. Manually refresh: `SELECT ricci.refresh_geometric_alerts();`
3. Set up automated refresh schedule

## Next Steps

- [Explore the API reference for function details](api-reference.md)
- [Understand the mathematical foundation](mathematical-foundation.md)
- [Review the test suite for examples](../tests/README.md)

