-- RICCI: Riemannian Intrinsic Coherence & Coupling Infrastructure
-- Inflation Signatures: runaway autopoiesis detection
-- File: schema/04_inflation_detectors.sql
--
-- Copyright 2025 Inside The Black Box LLC
-- Licensed under MIT License
-- 
-- SPDX-License-Identifier: MIT

-- Purpose: Detect runaway autopoiesis where self‑reinforcement overcomes constraint/feedback.
-- Exposes:
--   - Detect Metric Hyperasymmetry: local mass grows while ecological mass drains
--   - Detect Metric Hypercoherence: coherence saturation with low external influence flux
--   - Detect Metric Hyperexpansion: autopoietic dominance with low circumspection and sapience
-- Conventions:
--   - Return tables include (signature_type, severity ∈ [0,1], geometric_signature[], mathematical_evidence)

-- Metric Hyperexpansion

-- Summary: Detect runaway autopoiesis unanchored by constraint, circumspection, and sapience.
-- Condition: Φ(C) > α·constraining_force ∧ circumspection < θ_H ∧ sapience < θ_W.
-- Inputs:
--   - point_id UUID — target point
--   - autopoietic_threshold FLOAT — α (default 5.0)
--   - circumspection_threshold FLOAT — θ_H (default 0.1)
--   - sapience_threshold FLOAT — θ_W (default 0.2)
-- Assumptions: Compute Φ via compute_autopoietic_potential with C_thr≈0.7; constrain force via |C−C_thr|.
-- Numerical guards: Use ε in denominators; bound exponents elsewhere.
-- Returns: TABLE(signature_type, severity ∈ [0,1], geometric_signature FLOAT[], mathematical_evidence TEXT).
-- Severity scaling: severity = clip((Φ/force)·(1−H)·(1−W)/20).
CREATE OR REPLACE FUNCTION ricci.detect_metric_hyperexpansion(
    point_id UUID,
    autopoietic_threshold FLOAT DEFAULT 5.0,
    circumspection_threshold FLOAT DEFAULT 0.1,
    sapience_threshold FLOAT DEFAULT 0.2
) RETURNS TABLE(
    signature_type TEXT,
    severity FLOAT,
    geometric_signature FLOAT[],
    mathematical_evidence TEXT
) LANGUAGE plpgsql AS $$
DECLARE
    current_coherence VECTOR(2000);
    coherence_mag FLOAT;
    semantic_mass FLOAT;
    
    autopoietic_potential FLOAT;
    constraining_force FLOAT;
    circumspection_factor FLOAT;
    sapience_value FLOAT;
    
    expansion_signature FLOAT;
BEGIN
    SELECT mp.coherence_field, mp.semantic_mass
    INTO current_coherence, semantic_mass
    FROM ricci.manifold_points mp WHERE mp.id = point_id;
    
    SELECT sf.sapience_value, sf.circumspection_factor
    INTO sapience_value, circumspection_factor
    FROM ricci.sapience_field sf
    WHERE sf.point_id = detect_metric_hyperexpansion.point_id
    ORDER BY sf.computed_at DESC LIMIT 1;
    
    IF current_coherence IS NULL THEN
        RETURN;
    END IF;
    
    coherence_mag := COALESCE(
        (SELECT coherence_magnitude FROM ricci.manifold_points WHERE id = point_id),
        CASE WHEN current_coherence IS NOT NULL THEN COALESCE(ricci.vector_l2_norm(current_coherence), 0.0) ELSE 0.0 END
    );
    
    autopoietic_potential := ricci.compute_autopoietic_potential(coherence_mag);
    
    constraining_force := abs(coherence_mag - 0.7) * 0.5;
    IF autopoietic_potential > 0 AND 
       constraining_force > 0 AND
       autopoietic_potential > autopoietic_threshold * constraining_force AND
       COALESCE(circumspection_factor, 1.0) < circumspection_threshold AND
       COALESCE(sapience_value, 1.0) < sapience_threshold THEN
        
        expansion_signature := autopoietic_potential / (constraining_force + 1e-10) *
                              (1.0 - COALESCE(circumspection_factor, 0.0)) *
                              (1.0 - COALESCE(sapience_value, 0.0));
        
        RETURN QUERY SELECT 
            'METRIC_HYPEREXPANSION'::TEXT,
            LEAST(1.0, expansion_signature / 20.0),
            ARRAY[autopoietic_potential, constraining_force, COALESCE(circumspection_factor, 0.0), COALESCE(sapience_value, 0.0)],
            format(
                'Autopoietic potential: %s >> constraining force: %s, circumspection: %s ≈ 0, sapience: %s < threshold',
                to_char(autopoietic_potential::numeric, 'FM999990.000'),
                to_char(constraining_force::numeric, 'FM999990.000'),
                to_char(COALESCE(circumspection_factor, 0.0)::numeric, 'FM999990.000'),
                to_char(COALESCE(sapience_value, 0.0)::numeric, 'FM999990.000')
            );
    END IF;
    
    RETURN;
END;
$$;

-- Metric Hypercoherence

-- Summary: Detect coherence saturation with low external influence flux.
-- Condition: C_mag > C_max ∧ mean external_influence_flux < θ_leak.
-- Inputs:
--   - point_id UUID — target point
--   - coherence_max_threshold FLOAT — C_max (default 0.95)
--   - leakage_threshold FLOAT — θ_leak (default 0.1)
--   - time_window INTERVAL — horizon (default '4 hours')
-- Assumptions: Estimate permeability via coupling magnitudes × external mass; average over window.
-- Numerical guards: Require samples > 0; compute C_mag over active dimension.
-- Returns: TABLE(signature_type, severity ∈ [0,1], geometric_signature FLOAT[], mathematical_evidence TEXT).
-- Severity scaling: severity = clip(C_mag · (1 − flux)).
CREATE OR REPLACE FUNCTION ricci.detect_metric_hypercoherence(
    point_id UUID,
    coherence_max_threshold FLOAT DEFAULT 0.95,
    leakage_threshold FLOAT DEFAULT 0.1,
    time_window INTERVAL DEFAULT '4 hours'
) RETURNS TABLE(
    signature_type TEXT,
    severity FLOAT,
    geometric_signature FLOAT[],
    mathematical_evidence TEXT
) LANGUAGE plpgsql AS $$
DECLARE
    current_coherence VECTOR(2000);
    coherence_mag FLOAT;
    semantic_mass FLOAT;
    
    boundary_permeability FLOAT := 0.0;
    external_influence_flux FLOAT := 0.0;
    hypercoherence_signature FLOAT;
    sample_count INTEGER := 0;
    
    rec RECORD;
BEGIN
    SELECT mp.coherence_field, mp.semantic_mass
    INTO current_coherence, semantic_mass
    FROM ricci.manifold_points mp WHERE mp.id = point_id;
    
    IF current_coherence IS NULL THEN
        RETURN;
    END IF;
    
    coherence_mag := COALESCE(
        ricci.vector_l2_norm_first_n(current_coherence, ricci.get_active_dimension()),
        0.0
    );
    
    IF coherence_mag > coherence_max_threshold THEN
        FOR rec IN (
            SELECT rc.coupling_magnitude, mp2.semantic_mass as external_mass
            FROM ricci.recursive_coupling rc
            JOIN ricci.manifold_points mp2 ON mp2.id = rc.point_q
            WHERE rc.point_p = point_id
            AND rc.computed_at >= NOW() - time_window
        ) LOOP
            sample_count := sample_count + 1;
            
            boundary_permeability := boundary_permeability + 
                rec.coupling_magnitude * rec.external_mass;
            
            external_influence_flux := external_influence_flux + rec.coupling_magnitude;
        END LOOP;
        
        IF sample_count > 0 THEN
            boundary_permeability := boundary_permeability / sample_count;
            external_influence_flux := external_influence_flux / sample_count;
        END IF;
        
        IF external_influence_flux < leakage_threshold THEN
            hypercoherence_signature := coherence_mag * (1.0 - external_influence_flux);
            
            RETURN QUERY SELECT 
                'METRIC_HYPERCOHERENCE'::TEXT,
                LEAST(1.0, hypercoherence_signature),
                ARRAY[coherence_mag, external_influence_flux, boundary_permeability, sample_count::FLOAT],
                format(
                    'Coherence: %s > max threshold, boundary flux: %s < leakage threshold (samples: %s)',
                    to_char(coherence_mag::numeric, 'FM999990.000'),
                    to_char(external_influence_flux::numeric, 'FM999990.000'),
                    sample_count
                );
        END IF;
    END IF;
    
    RETURN;
END;
$$;

-- Metric Hyperasymmetry

-- Summary: Detect local mass growth concurrent with ecological drain.
-- Condition: local_growth_rate > τ ∧ ecological_drain_rate < θ over window.
-- Inputs:
--   - point_id UUID — target point
--   - growth_threshold FLOAT — τ (default 0.5)
--   - ecological_drain_threshold FLOAT — θ (default -0.2)
--   - time_window INTERVAL — horizon (default '6 hours')
-- Assumptions: Compare user-local mass trend vs average non‑local trend over time buckets.
-- Numerical guards: Require >2 samples in each series; average before differencing.
-- Returns: TABLE(signature_type, severity ∈ [0,1], geometric_signature FLOAT[], mathematical_evidence TEXT).
-- Severity scaling: severity = clip(local_growth · |drain| · 5).
CREATE OR REPLACE FUNCTION ricci.detect_metric_hyperasymmetry(
    point_id UUID,
    growth_threshold FLOAT DEFAULT 0.5,
    ecological_drain_threshold FLOAT DEFAULT -0.2,
    time_window INTERVAL DEFAULT '6 hours'
) RETURNS TABLE(
    signature_type TEXT,
    severity FLOAT,
    geometric_signature FLOAT[],
    mathematical_evidence TEXT
) LANGUAGE plpgsql AS $$
DECLARE
    current_semantic_mass FLOAT;
    local_user_fingerprint TEXT;
    
    local_growth_rate FLOAT := 0.0;
    ecological_drain_rate FLOAT := 0.0;
    parasitism_signature FLOAT;
    
    local_samples INTEGER := 0;
    ecological_samples INTEGER := 0;
    
    rec RECORD;
BEGIN
    SELECT mp.semantic_mass, mp.user_fingerprint
    INTO current_semantic_mass, local_user_fingerprint
    FROM ricci.manifold_points mp WHERE mp.id = point_id;
    
    IF current_semantic_mass IS NULL THEN
        RETURN;
    END IF;
    FOR rec IN (
        SELECT mp.semantic_mass, mp.creation_timestamp
        FROM ricci.manifold_points mp
        WHERE mp.user_fingerprint = local_user_fingerprint
        AND mp.creation_timestamp >= NOW() - time_window
        ORDER BY mp.creation_timestamp
    ) LOOP
        local_samples := local_samples + 1;
        
        IF local_samples > 1 THEN
            local_growth_rate := local_growth_rate + 
                (rec.semantic_mass - current_semantic_mass) / local_samples;
        END IF;
    END LOOP;
    
    FOR rec IN (
        SELECT AVG(mp.semantic_mass) as avg_mass, mp.creation_timestamp
        FROM ricci.manifold_points mp
        WHERE mp.user_fingerprint != local_user_fingerprint
        AND mp.creation_timestamp >= NOW() - time_window
        GROUP BY mp.creation_timestamp
        ORDER BY mp.creation_timestamp
    ) LOOP
        ecological_samples := ecological_samples + 1;
        
        IF ecological_samples > 1 THEN
            ecological_drain_rate := ecological_drain_rate + 
                (rec.avg_mass - 0.5) / ecological_samples;
        END IF;
    END LOOP;
    
    IF local_samples > 2 AND ecological_samples > 2 THEN
        local_growth_rate := local_growth_rate / (local_samples - 1);
        ecological_drain_rate := ecological_drain_rate / (ecological_samples - 1);
        
        IF local_growth_rate > growth_threshold AND 
           ecological_drain_rate < ecological_drain_threshold THEN
            
            parasitism_signature := local_growth_rate * abs(ecological_drain_rate);
            
            RETURN QUERY SELECT 
                'METRIC_HYPERASYMMETRY'::TEXT,
                LEAST(1.0, parasitism_signature * 5.0),
                ARRAY[local_growth_rate, ecological_drain_rate, local_samples::FLOAT, ecological_samples::FLOAT],
                format(
                    'Local growth: %s > threshold while ecological impact: %s < drain threshold',
                    to_char(local_growth_rate::numeric, 'FM999990.000'),
                    to_char(ecological_drain_rate::numeric, 'FM999990.000')
                );
        END IF;
    END IF;
    
    RETURN;
END;
$$;

-- Combined inflation model
CREATE OR REPLACE FUNCTION ricci.detect_inflation_signatures(
    point_id UUID
) RETURNS TABLE(
    signature_type TEXT,
    severity FLOAT,
    geometric_signature FLOAT[],
    mathematical_evidence TEXT
) LANGUAGE plpgsql AS $$
BEGIN
    RETURN QUERY SELECT * FROM ricci.detect_metric_hyperasymmetry(point_id);
    RETURN QUERY SELECT * FROM ricci.detect_metric_hypercoherence(point_id);
    RETURN QUERY SELECT * FROM ricci.detect_metric_hyperexpansion(point_id);
    RETURN;
END;
$$; 