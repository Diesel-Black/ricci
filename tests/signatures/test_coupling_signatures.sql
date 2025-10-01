-- RICCI: Test Coupling Signature Detection
-- File: tests/signatures/test_coupling_signatures.sql
--
-- Tests for coupling signature detection functions
-- Copyright 2025 Inside The Black Box LLC
-- Licensed under MIT License

\echo 'Coupling: metric tension → negative bias + concentrated threat patterns (executes)'
DO $$
DECLARE
    test_point UUID;
BEGIN
    test_point := ricci_test.create_test_manifold_point();
    
    PERFORM ricci_test.assert_no_error(
        'metric_tension_executes',
        format('SELECT * FROM ricci.detect_metric_tension(''%s'')', test_point),
        'coupling'
    );
    
    PERFORM ricci_test.cleanup_test_data();
END;
$$;

\echo 'Coupling: metric decoupling → interpretation divergence exceeds threshold (executes)'
DO $$
DECLARE
    test_point UUID;
BEGIN
    test_point := ricci_test.create_test_manifold_point();
    
    PERFORM ricci_test.assert_no_error(
        'metric_decoupling_executes',
        format('SELECT * FROM ricci.detect_metric_decoupling(''%s'')', test_point),
        'coupling'
    );
    
    PERFORM ricci_test.cleanup_test_data();
END;
$$;

\echo 'Coupling: metric hypercoupling → dominant self-coupling with weak externals (executes)'
DO $$
DECLARE
    test_point UUID;
BEGIN
    test_point := ricci_test.create_test_manifold_point();
    
    PERFORM ricci_test.assert_no_error(
        'metric_hypercoupling_executes',
        format('SELECT * FROM ricci.detect_metric_hypercoupling(''%s'')', test_point),
        'coupling'
    );
    
    PERFORM ricci_test.cleanup_test_data();
END;
$$;

\echo 'Coupling: combined signatures → multiplexed detector executes'
DO $$
DECLARE
    test_point UUID;
BEGIN
    test_point := ricci_test.create_test_manifold_point();
    
    PERFORM ricci_test.assert_no_error(
        'coupling_signatures_combined',
        format('SELECT * FROM ricci.detect_coupling_signatures(''%s'')', test_point),
        'coupling'
    );
    
    PERFORM ricci_test.cleanup_test_data();
END;
$$;

\echo 'Coupling: schema verification → expect at least one valid row with type/severity/evidence under dominant self-coupling'
DO $$
DECLARE
    test_point UUID;
    signature_rec RECORD;
    result_count INTEGER;
BEGIN
    test_point := ricci_test.create_test_manifold_point();

    -- Deterministically create coupling data to allow hypercoupling to potentially trigger
    INSERT INTO ricci.recursive_coupling (id, point_p, point_q, coupling_magnitude, coupling_tensor, computed_at)
    VALUES 
        (gen_random_uuid(), test_point, test_point, 0.95, ARRAY[0.0], NOW() - INTERVAL '15 minutes'),
        (gen_random_uuid(), test_point, test_point, 0.90, ARRAY[0.0], NOW() - INTERVAL '10 minutes'),
        (gen_random_uuid(), test_point, test_point, 0.85, ARRAY[0.0], NOW() - INTERVAL '7 minutes'),
        (gen_random_uuid(), test_point, test_point, 0.80, ARRAY[0.0], NOW() - INTERVAL '5 minutes');

    -- Also add one weak external coupling to keep external_reference low
    INSERT INTO ricci.recursive_coupling (id, point_p, point_q, coupling_magnitude, coupling_tensor, computed_at)
    SELECT gen_random_uuid(), test_point, id, 0.05, ARRAY[0.0], NOW() - INTERVAL '7 minutes'
    FROM ricci.manifold_points WHERE id != test_point LIMIT 1;

    -- Assert at least one coupling signature row is returned (non-zero count)
    SELECT COUNT(*) INTO result_count FROM ricci.detect_coupling_signatures(test_point);
    PERFORM ricci_test.assert_true(
        'coupling_signatures_present',
        result_count > 0,
        'coupling',
        'At least one coupling signature should be detected with dominant self-coupling and minimal external references'
    );

    FOR signature_rec IN 
        SELECT * FROM ricci.detect_coupling_signatures(test_point)
    LOOP
        PERFORM ricci_test.assert_true(
            'coupling_signature_type_valid',
            signature_rec.signature_type IN ('METRIC_TENSION', 'METRIC_DECOUPLING', 'METRIC_HYPERCOUPLING'),
            'coupling',
            'Signature type should be valid coupling type'
        );
        
        PERFORM ricci_test.assert_true(
            'coupling_severity_range',
            signature_rec.severity >= 0.0 AND signature_rec.severity <= 1.0,
            'coupling',
            'Severity should be between 0.0 and 1.0'
        );
    END LOOP;
    
    PERFORM ricci_test.cleanup_test_data();
END;
$$;

\echo 'Coupling: performance → combined detector ≤ 3s'
DO $$
DECLARE
    test_point UUID;
BEGIN
    test_point := ricci_test.create_test_manifold_point();
    
    PERFORM ricci_test.assert_performance(
        'coupling_signatures_performance',
        format('SELECT * FROM ricci.detect_coupling_signatures(''%s'')', test_point),
        '3 seconds',
        'coupling'
    );
    
    PERFORM ricci_test.cleanup_test_data();
END;
$$;

\echo ''
\echo 'Completed coupling signature tests.'
