-- RICCI: Test Inflation Signature Detection
-- File: tests/signatures/test_inflation_signatures.sql
--
-- Tests for inflation signature detection functions
-- Copyright 2025 Inside The Black Box LLC
-- Licensed under MIT License

\echo 'Inflation: structure hyperexpansion → autopoietic >> constraining with low circumspection/sapience (executes)'
DO $$
DECLARE
    test_point UUID;
BEGIN
    test_point := ricci_test.create_test_manifold_point();
    
    PERFORM ricci_test.assert_no_error(
        'metric_hyperexpansion_executes',
        format('SELECT * FROM ricci.detect_structure_hyperexpansion(''%s'')', test_point),
        'inflation'
    );
    
    PERFORM ricci_test.cleanup_test_data();
END;
$$;

\echo 'Inflation: field hypercoherence → coherence above C_max with low boundary flux (executes)'
DO $$
DECLARE
    test_point UUID;
BEGIN
    test_point := ricci_test.create_test_manifold_point();
    
    PERFORM ricci_test.assert_no_error(
        'metric_hypercoherence_executes',
        format('SELECT * FROM ricci.detect_field_hypercoherence(''%s'')', test_point),
        'inflation'
    );
    
    PERFORM ricci_test.cleanup_test_data();
END;
$$;

\echo 'Inflation: boundary hyperasymmetry → local mass growth with ecological drain (executes)'
DO $$
DECLARE
    test_point UUID;
BEGIN
    test_point := ricci_test.create_test_manifold_point();
    
    PERFORM ricci_test.assert_no_error(
        'metric_hyperasymmetry_executes',
        format('SELECT * FROM ricci.detect_boundary_hyperasymmetry(''%s'')', test_point),
        'inflation'
    );
    
    PERFORM ricci_test.cleanup_test_data();
END;
$$;

\echo 'Inflation: combined signatures → multiplexed detector executes'
DO $$
DECLARE
    test_point UUID;
BEGIN
    test_point := ricci_test.create_test_manifold_point();
    
    PERFORM ricci_test.assert_no_error(
        'inflation_signatures_combined',
        format('SELECT * FROM ricci.detect_inflation_signatures(''%s'')', test_point),
        'inflation'
    );
    
    PERFORM ricci_test.cleanup_test_data();
END;
$$;

\echo 'Inflation: schema verification → expect at least one valid row with type/severity/evidence under low-flux high-coherence setup'
DO $$
DECLARE
    test_point UUID;
    signature_rec RECORD;
    result_count INTEGER;
BEGIN
    test_point := ricci_test.create_test_manifold_point();

    -- Create a minimal boundary flux sample to ensure sample_count > 0 and flux < leakage threshold
    INSERT INTO ricci.recursive_coupling (id, point_p, point_q, coupling_magnitude, coupling_tensor, computed_at)
    VALUES (gen_random_uuid(), test_point, test_point, 0.01, ARRAY[0.0], NOW() - INTERVAL '2 minutes');
    
    -- Ensure at least one detection (semantic hypercoherence): coherence norm is already high for random fields.
    -- Assert presence deterministically so the block never silently skips.
    SELECT COUNT(*) INTO result_count FROM ricci.detect_inflation_signatures(test_point);
    PERFORM ricci_test.assert_true(
        'inflation_signatures_present',
        result_count > 0,
        'inflation',
        'At least one inflation signature should be detected for random high-norm coherence'
    );

    FOR signature_rec IN 
        SELECT * FROM ricci.detect_inflation_signatures(test_point)
    LOOP
        PERFORM ricci_test.assert_true(
            'inflation_signature_type_valid',
            signature_rec.signature_type IN ('STRUCTURE_HYPEREXPANSION', 'FIELD_HYPERCOHERENCE', 'BOUNDARY_HYPERASYMMETRY'),
            'inflation',
            'Signature type should be valid inflation type'
        );
        
        PERFORM ricci_test.assert_true(
            'inflation_severity_range',
            signature_rec.severity >= 0.0 AND signature_rec.severity <= 1.0,
            'inflation',
            'Severity should be between 0.0 and 1.0'
        );
    END LOOP;
    
    PERFORM ricci_test.cleanup_test_data();
END;
$$;

\echo 'Inflation: performance → combined detector ≤ 3s'
DO $$
DECLARE
    test_point UUID;
BEGIN
    test_point := ricci_test.create_test_manifold_point();
    
    PERFORM ricci_test.assert_performance(
        'inflation_signatures_performance',
        format('SELECT * FROM ricci.detect_inflation_signatures(''%s'')', test_point),
        '3 seconds',
        'inflation'
    );
    
    PERFORM ricci_test.cleanup_test_data();
END;
$$;

\echo ''
\echo 'Completed inflation signature tests.'
