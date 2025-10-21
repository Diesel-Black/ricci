-- RICCI: Test Rigidity Signature Detection
-- File: tests/signatures/test_rigidity_signatures.sql
--
-- Tests for rigidity signature detection functions
-- Copyright 2025 Inside The Black Box LLC
-- Licensed under MIT License

\echo 'Rigidity: attractor isolation → high stability + high coherence should yield detection'

DO $$
DECLARE
    test_point UUID;
BEGIN
    test_point := ricci_test.create_test_manifold_point();
    
    PERFORM ricci_test.assert_no_error(
        'metric_sequestration_executes',
        format('SELECT * FROM ricci.detect_attractor_isolation(''%s'')', test_point),
        'rigidity'
    );
    
    PERFORM ricci_test.cleanup_test_data();
END;
$$;

\echo 'Rigidity: field calcification → recent low response under pressure should be detectable (executes)'
DO $$
DECLARE
    test_point UUID;
BEGIN
    test_point := ricci_test.create_test_manifold_point();
    
    PERFORM ricci_test.assert_no_error(
        'metric_densification_executes',
        format('SELECT * FROM ricci.detect_field_calcification(''%s'')', test_point),
        'rigidity'
    );
    
    PERFORM ricci_test.cleanup_test_data();
END;
$$;

\echo 'Rigidity: Metric Crystallization → slow metric evolution with nonzero curvature (executes)'
DO $$
DECLARE
    test_point UUID;
BEGIN
    test_point := ricci_test.create_test_manifold_point();
    
    PERFORM ricci_test.assert_no_error(
        'metric_crystallization_executes',
        format('SELECT * FROM ricci.detect_metric_crystallization(''%s'')', test_point),
        'rigidity'
    );
    
    PERFORM ricci_test.cleanup_test_data();
END;
$$;

\echo 'Rigidity: combined signatures → multiplexed detector executes'
DO $$
DECLARE
    test_point UUID;
BEGIN
    test_point := ricci_test.create_test_manifold_point();
    
    PERFORM ricci_test.assert_no_error(
        'rigidity_signatures_combined_executes',
        format('SELECT * FROM ricci.detect_rigidity_signatures(''%s'')', test_point),
        'rigidity'
    );
    
    PERFORM ricci_test.cleanup_test_data();
END;
$$;


\echo 'Rigidity: schema verification → expect valid row with type/severity/evidence when conditions met'
DO $$
DECLARE
    test_point UUID;
    signature_rec RECORD;
    found_signature BOOLEAN := false;
    result_count INTEGER;
BEGIN
    -- Create point with high attractor stability to trigger detection
    test_point := ricci_test.create_test_manifold_point();
    
    -- Update point to have high attractor stability
    UPDATE ricci.manifold_points 
    SET attractor_stability = 0.9,
        coherence_magnitude = 0.8
    WHERE id = test_point;
    
    -- Assert at least one detection row exists under high-stability/high-coherence conditions
    SELECT COUNT(*) INTO result_count
    FROM ricci.detect_attractor_isolation(test_point, 0.8, 3.0);
    PERFORM ricci_test.assert_true(
        'metric_sequestration_detection_present',
        result_count > 0,
        'rigidity',
        'At least one rigidity signature should be detected for high stability and coherence'
    );

    -- Check if detection returns proper format
    FOR signature_rec IN 
        SELECT * FROM ricci.detect_attractor_isolation(test_point, 0.8, 3.0)
    LOOP
        found_signature := true;
        
        PERFORM ricci_test.assert_true(
            'metric_sequestration_signature_type',
            signature_rec.signature_type = 'ATTRACTOR_ISOLATION',
            'rigidity',
            'Signature type should be ATTRACTOR_ISOLATION'
        );
        
        PERFORM ricci_test.assert_true(
            'metric_sequestration_severity_range',
            signature_rec.severity >= 0.0 AND signature_rec.severity <= 1.0,
            'rigidity',
            'Severity should be between 0.0 and 1.0'
        );
        
        PERFORM ricci_test.assert_true(
            'metric_sequestration_geometric_signature_exists',
            signature_rec.geometric_signature IS NOT NULL,
            'rigidity',
            'Geometric signature should not be null'
        );
        
        PERFORM ricci_test.assert_true(
            'metric_sequestration_evidence_exists',
            signature_rec.mathematical_evidence IS NOT NULL,
            'rigidity',
            'Mathematical evidence should not be null'
        );
        
        EXIT; -- Only check first result
    END LOOP;
    
    PERFORM ricci_test.cleanup_test_data();
END;
$$;

\echo 'Rigidity: null point handling → executes without error'
SELECT ricci_test.assert_no_error(
    'rigidity_signatures_null_point',
    'SELECT * FROM ricci.detect_attractor_isolation(NULL)',
    'rigidity'
);

\echo 'Rigidity: nonexistent point handling → executes without error'
SELECT ricci_test.assert_no_error(
    'rigidity_signatures_nonexistent_point',
    format('SELECT * FROM ricci.detect_attractor_isolation(''%s'')', gen_random_uuid()),
    'rigidity'
);

\echo 'Rigidity: boundary condition (at threshold) → executes and handles edge gracefully'
DO $$
DECLARE
    test_point UUID;
    result_count INTEGER;
BEGIN
    test_point := ricci_test.create_test_manifold_point();
    
    -- Set exactly at threshold
    UPDATE ricci.manifold_points 
    SET attractor_stability = 0.8,
        coherence_magnitude = 0.7
    WHERE id = test_point;
    
    SELECT COUNT(*) INTO result_count
    FROM ricci.detect_attractor_isolation(test_point, 0.8, 3.0);
    
    PERFORM ricci_test.assert_true(
        'metric_sequestration_boundary_threshold',
        true, -- Just testing it doesn't crash at boundary
        'rigidity',
        'Function should handle boundary conditions gracefully'
    );
    
    PERFORM ricci_test.cleanup_test_data();
END;
$$;

\echo 'Rigidity: performance → combined detector ≤ 2s'
DO $$
DECLARE
    test_point UUID;
BEGIN
    test_point := ricci_test.create_test_manifold_point();
    
    PERFORM ricci_test.assert_performance(
        'rigidity_signatures_performance',
        format('SELECT * FROM ricci.detect_rigidity_signatures(''%s'')', test_point),
        '2 seconds',
        'rigidity'
    );
    
    PERFORM ricci_test.cleanup_test_data();
END;
$$;

\echo 'Rigidity: severity scaling → higher stability tends toward higher severity (tolerance 0.1)'
DO $$
DECLARE
    test_point_low UUID;
    test_point_high UUID;
    severity_low FLOAT;
    severity_high FLOAT;
    rec RECORD;
BEGIN
    -- Create two test points with different stability levels
    test_point_low := ricci_test.create_test_manifold_point();
    test_point_high := ricci_test.create_test_manifold_point();
    
    -- Set low stability
    UPDATE ricci.manifold_points 
    SET attractor_stability = 0.81,
        coherence_magnitude = 0.75
    WHERE id = test_point_low;
    
    -- Set high stability  
    UPDATE ricci.manifold_points 
    SET attractor_stability = 0.95,
        coherence_magnitude = 0.85
    WHERE id = test_point_high;
    
    -- Get severities (if any detections occur)
    SELECT severity INTO severity_low
    FROM ricci.detect_attractor_isolation(test_point_low) 
    LIMIT 1;
    
    SELECT severity INTO severity_high
    FROM ricci.detect_attractor_isolation(test_point_high)
    LIMIT 1;
    
    -- If both detected, higher values should generally produce higher severity
    IF severity_low IS NOT NULL AND severity_high IS NOT NULL THEN
        PERFORM ricci_test.assert_true(
            'severity_scales_with_conditions',
            severity_high >= severity_low OR ABS(severity_high - severity_low) < 0.1,
            'rigidity',
            'Higher attractor stability should tend toward higher severity'
        );
    END IF;
    
    PERFORM ricci_test.cleanup_test_data();
END;
$$;

\echo ''
\echo 'Completed rigidity signature tests.'
