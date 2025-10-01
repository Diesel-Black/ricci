-- RICCI: Riemannian Intrinsic Coherence & Coupling Infrastructure
-- Coupling Signatures: interface breakdowns
-- File: schema/05_coupling_detectors.sql
--
-- Copyright 2025 Inside The Black Box LLC
-- Licensed under MIT License
-- 
-- SPDX-License-Identifier: MIT

-- Purpose: Detect interpretation breakdowns relative to consensus and external references.
-- Exposes:
--   - Detect Metric Tension: negative bias with threat‑pattern concentration
--   - Detect Metric Decoupling: interpretation divergence relative to field magnitude
--   - Detect Metric Hypercoupling: self‑coupling dominance with weak external references
-- Conventions:
--   - Return tables include (signature_type, severity ∈ [0,1], geometric_signature[], mathematical_evidence)

-- Metric Tension

-- Summary: Detect negative interpretation bias with threat‑pattern concentration.
-- Condition: mean negative bias > θ_bias ∧ threat pattern concentration > τ.
-- Inputs:
--   - point_id UUID — target point
--   - bias_threshold FLOAT — θ_bias (default 0.3)
--   - threat_hyperattractor_threshold FLOAT — τ (default 0.8)
-- Assumptions: Use small window norm as a bias proxy; count threats where mass high and coupling low.
-- Numerical guards: Require sufficient samples; compute norms over small window.
-- Returns: TABLE(signature_type, severity ∈ [0,1], geometric_signature FLOAT[], mathematical_evidence TEXT).
-- Severity scaling: severity = clip(bias · threat_concentration · 2).
CREATE OR REPLACE FUNCTION ricci.detect_metric_tension(
    point_id UUID,
    bias_threshold FLOAT DEFAULT 0.3,
    threat_hyperattractor_threshold FLOAT DEFAULT 0.8
) RETURNS TABLE(
    signature_type TEXT,
    severity FLOAT,
    geometric_signature FLOAT[],
    mathematical_evidence TEXT
) LANGUAGE plpgsql AS $$
DECLARE
    current_coherence VECTOR(2000);
    semantic_mass FLOAT;
    user_fp TEXT;
    
    negative_interpretation_bias FLOAT := 0.0;
    threat_pattern_concentration FLOAT := 0.0;
    interpretation_divergence FLOAT := 0.0;
    tension_signature FLOAT;
    
    sample_count INTEGER := 0;
    threat_interpretation_count INTEGER := 0;
    
    rec RECORD;
BEGIN
    SELECT mp.coherence_field, mp.semantic_mass, mp.user_fingerprint
    INTO current_coherence, semantic_mass, user_fp
    FROM ricci.manifold_points mp WHERE mp.id = point_id;
    
    IF current_coherence IS NULL THEN
        RETURN;
    END IF;
    
    FOR rec IN (
        SELECT mp.coherence_field, mp.semantic_mass, mp.creation_timestamp,
               rc.coupling_magnitude
        FROM ricci.manifold_points mp
        LEFT JOIN ricci.recursive_coupling rc ON mp.id = rc.point_p
        WHERE mp.user_fingerprint = user_fp
        AND mp.creation_timestamp >= NOW() - INTERVAL '12 hours'
        ORDER BY mp.creation_timestamp DESC
        LIMIT 20
    ) LOOP
        sample_count := sample_count + 1;
        
        negative_interpretation_bias := negative_interpretation_bias + 
            GREATEST(0, 0.5 - COALESCE(ricci.vector_l2_norm_first_n(rec.coherence_field, ricci.get_small_window())
            , 0.0));
        
        IF rec.semantic_mass > 0.6 AND COALESCE(rec.coupling_magnitude, 0) < 0.3 THEN
            threat_interpretation_count := threat_interpretation_count + 1;
        END IF;
        
        interpretation_divergence := interpretation_divergence + 
            abs(0.5 - COALESCE(ricci.vector_l2_norm_first_n(rec.coherence_field, ricci.get_small_window())
            , 0.0));
    END LOOP;
    
    IF sample_count > 3 THEN
        negative_interpretation_bias := negative_interpretation_bias / sample_count;
        interpretation_divergence := interpretation_divergence / sample_count;
        threat_pattern_concentration := threat_interpretation_count::FLOAT / sample_count;
        
        IF negative_interpretation_bias > bias_threshold AND 
           threat_pattern_concentration > threat_hyperattractor_threshold THEN
            
            tension_signature := negative_interpretation_bias * threat_pattern_concentration;
            
            RETURN QUERY SELECT 
                'METRIC_TENSION'::TEXT,
                LEAST(1.0, tension_signature * 2.0),
                ARRAY[negative_interpretation_bias, threat_pattern_concentration, interpretation_divergence, sample_count::FLOAT],
                format(
                    'Negative bias: %s > threshold, threat patterns: %s%% (samples: %s)', 
                    to_char(negative_interpretation_bias::numeric, 'FM999990.000'),
                    to_char((threat_pattern_concentration * 100)::numeric, 'FM999990.0'),
                    sample_count
                );
        END IF;
    END IF;
    
    RETURN;
END;
$$;

-- Metric Decoupling

-- Summary: Detect divergence between self interpretation and consensus normalized by field magnitude.
-- Condition: (E_self_divergence / ||C||) > τ with adequate samples.
-- Inputs:
--   - point_id UUID — target point
--   - divergence_threshold FLOAT — τ (default 0.5)
--   - time_window INTERVAL — sample horizon (default '8 hours')
-- Assumptions: Use latest non‑self coherence as baseline consensus; compare over active dimension.
-- Numerical guards: Require ||C|| > 0.1 and >2 samples; use ε in ratios.
-- Returns: TABLE(signature_type, severity ∈ [0,1], geometric_signature FLOAT[], mathematical_evidence TEXT).
-- Severity scaling: severity = clip(ratio · consensus_divergence).
CREATE OR REPLACE FUNCTION ricci.detect_metric_decoupling(
    point_id UUID,
    divergence_threshold FLOAT DEFAULT 0.5,
    time_window INTERVAL DEFAULT '8 hours'
) RETURNS TABLE(
    signature_type TEXT,
    severity FLOAT,
    geometric_signature FLOAT[],
    mathematical_evidence TEXT
) LANGUAGE plpgsql AS $$
DECLARE
    current_coherence VECTOR(2000);
    user_fp TEXT;
    
    interpretation_divergence FLOAT := 0.0;
    consensus_divergence FLOAT := 0.0;
    field_magnitude FLOAT;
    insular_decoupling_ratio FLOAT;
    decoupling_signature FLOAT;
    
    baseline_coherence VECTOR(2000);
    sample_count INTEGER := 0;
    
    rec RECORD;
BEGIN
    SELECT mp.coherence_field, mp.user_fingerprint
    INTO current_coherence, user_fp
    FROM ricci.manifold_points mp WHERE mp.id = point_id;
    
    IF current_coherence IS NULL OR user_fp IS NULL THEN
        RETURN;
    END IF;
    
    field_magnitude := COALESCE(
        (SELECT coherence_magnitude FROM ricci.manifold_points WHERE id = point_id),
        CASE WHEN current_coherence IS NOT NULL THEN COALESCE(ricci.vector_l2_norm(current_coherence), 0.0) ELSE 0.0 END
    );
    
    -- Baseline latest consensus sample
    SELECT mp.coherence_field INTO baseline_coherence
    FROM ricci.manifold_points mp
    WHERE mp.user_fingerprint != user_fp
    ORDER BY mp.creation_timestamp DESC LIMIT 1;
    
    IF baseline_coherence IS NULL THEN
        RETURN;
    END IF;
    
    FOR rec IN (
        SELECT coherence_field
        FROM ricci.manifold_points mp
        WHERE mp.user_fingerprint = user_fp
        ORDER BY mp.creation_timestamp DESC LIMIT 10
    ) LOOP
        sample_count := sample_count + 1;
        
        interpretation_divergence := interpretation_divergence + 
            ricci.vector_l2_distance_first_n(rec.coherence_field, current_coherence, ricci.get_active_dimension());
        consensus_divergence := consensus_divergence + 
            ricci.vector_l2_distance_first_n(rec.coherence_field, baseline_coherence, ricci.get_active_dimension());
    END LOOP;
    
    IF sample_count > 2 AND field_magnitude > 0.1 THEN
        interpretation_divergence := interpretation_divergence / sample_count;
        consensus_divergence := consensus_divergence / sample_count;
        
        insular_decoupling_ratio := interpretation_divergence / field_magnitude;
        
        IF insular_decoupling_ratio > divergence_threshold THEN
            decoupling_signature := insular_decoupling_ratio * consensus_divergence;
            
            RETURN QUERY SELECT 
                'METRIC_DECOUPLING'::TEXT,
                LEAST(1.0, decoupling_signature),
                ARRAY[interpretation_divergence, field_magnitude, insular_decoupling_ratio, consensus_divergence],
                format(
                    'Interpretation divergence: %s > %s * field magnitude: %s (ratio: %s)', 
                    to_char(interpretation_divergence::numeric, 'FM999990.000'),
                    to_char(divergence_threshold::numeric, 'FM999990.0'),
                    to_char(field_magnitude::numeric, 'FM999990.000'),
                    to_char(insular_decoupling_ratio::numeric, 'FM999990.000')
                );
        END IF;
    END IF;
    
    RETURN;
END;
$$;

-- Metric Hypercoupling

-- Summary: Detect dominance of self‑coupling over total coupling mass with weak external references.
-- Condition: (self_coupling/total) > τ ∧ (external/total) < θ with sufficient references.
-- Inputs:
--   - point_id UUID — target point
--   - self_coupling_threshold FLOAT — τ (default 0.8)
--   - external_reference_threshold FLOAT — θ (default 0.2)
-- Assumptions: Sum coupling magnitudes for self vs non‑self within a time horizon.
-- Numerical guards: Require >3 references; clip severity to [0,1].
-- Returns: TABLE(signature_type, severity ∈ [0,1], geometric_signature FLOAT[], mathematical_evidence TEXT).
-- Severity scaling: severity = clip((self/total) · (1 − external/total)).
CREATE OR REPLACE FUNCTION ricci.detect_metric_hypercoupling(
    point_id UUID,
    self_coupling_threshold FLOAT DEFAULT 0.8,
    external_reference_threshold FLOAT DEFAULT 0.2
) RETURNS TABLE(
    signature_type TEXT,
    severity FLOAT,
    geometric_signature FLOAT[],
    mathematical_evidence TEXT
) LANGUAGE plpgsql AS $$
DECLARE
    user_fp TEXT;
    
    self_coupling_strength FLOAT := 0.0;
    total_coupling_strength FLOAT := 0.0;
    external_coupling_strength FLOAT := 0.0;
    hypercoupling_ratio FLOAT;
    hypercoupling_signature FLOAT;
    
    self_reference_count INTEGER := 0;
    external_reference_count INTEGER := 0;
    
    rec RECORD;
BEGIN
    SELECT mp.user_fingerprint
    INTO user_fp
    FROM ricci.manifold_points mp WHERE mp.id = point_id;
    
    IF user_fp IS NULL THEN
        RETURN;
    END IF;
    
    FOR rec IN (
        SELECT rc.coupling_magnitude, rc.point_p, rc.point_q
        FROM ricci.recursive_coupling rc
        JOIN ricci.manifold_points mp1 ON mp1.id = rc.point_p
        JOIN ricci.manifold_points mp2 ON mp2.id = rc.point_q
        WHERE mp1.user_fingerprint = user_fp
          AND rc.computed_at >= NOW() - INTERVAL '12 hours'
    ) LOOP
        total_coupling_strength := total_coupling_strength + COALESCE(rec.coupling_magnitude, 0.0);
        
        IF rec.point_p = rec.point_q THEN
            self_coupling_strength := self_coupling_strength + COALESCE(rec.coupling_magnitude, 0.0);
            self_reference_count := self_reference_count + 1;
        ELSE
            external_coupling_strength := external_coupling_strength + COALESCE(rec.coupling_magnitude, 0.0);
            external_reference_count := external_reference_count + 1;
        END IF;
    END LOOP;
    
    IF total_coupling_strength > 0 AND (self_reference_count + external_reference_count) > 3 THEN
        hypercoupling_ratio := self_coupling_strength / total_coupling_strength;
        
        IF hypercoupling_ratio > self_coupling_threshold AND 
           external_coupling_strength / total_coupling_strength < external_reference_threshold THEN
            
            hypercoupling_signature := hypercoupling_ratio * (1.0 - external_coupling_strength / total_coupling_strength);
            
            RETURN QUERY SELECT 
                'METRIC_HYPERCOUPLING'::TEXT,
                LEAST(1.0, hypercoupling_signature),
                ARRAY[self_coupling_strength, external_coupling_strength, hypercoupling_ratio, (self_reference_count + external_reference_count)::FLOAT],
                format(
                    'Self-coupling: %s%% of total, external coupling: %s%% < threshold (refs: %s/%s)',
                    to_char((hypercoupling_ratio * 100)::numeric, 'FM999990.0'),
                    to_char(((external_coupling_strength / total_coupling_strength) * 100)::numeric, 'FM999990.0'),
                    self_reference_count, external_reference_count
                );
        END IF;
    END IF;
    
    RETURN;
END;
$$;

-- Combined coupling model
CREATE OR REPLACE FUNCTION ricci.detect_coupling_signatures(
    point_id UUID
) RETURNS TABLE(
    signature_type TEXT,
    severity FLOAT,
    geometric_signature FLOAT[],
    mathematical_evidence TEXT
) LANGUAGE plpgsql AS $$
BEGIN
    RETURN QUERY SELECT * FROM ricci.detect_metric_decoupling(point_id);
    RETURN QUERY SELECT * FROM ricci.detect_metric_tension(point_id);
    RETURN QUERY SELECT * FROM ricci.detect_metric_hypercoupling(point_id);
    RETURN;
END;
$$;  