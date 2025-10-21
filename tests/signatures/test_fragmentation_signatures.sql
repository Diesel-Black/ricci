-- RICCI: Test Fragmentation Signature Detection
-- File: tests/signatures/test_fragmentation_signatures.sql
--
-- Tests for fragmentation signature detection functions
-- Copyright 2025 Inside The Black Box LLC
-- Licensed under MIT License

\echo 'Fragmentation: attractor dissociation → direction variance exceeds autopoietic stabilization (executes)'
DO $$
DECLARE
    test_point UUID;
BEGIN
    test_point := ricci_test.create_test_manifold_point();
    
    PERFORM ricci_test.assert_no_error(
        'metric_dissociation_executes',
        format('SELECT * FROM ricci.detect_attractor_dissociation(''%s'')', test_point),
        'fragmentation'
    );
    
    PERFORM ricci_test.cleanup_test_data();
END;
$$;

\echo 'Fragmentation: field dissolution → large gradient vs magnitude with positive acceleration (executes)'
DO $$
DECLARE
    test_point UUID;
BEGIN
    test_point := ricci_test.create_test_manifold_point();
    
    PERFORM ricci_test.assert_no_error(
        'metric_dissolution_executes',
        format('SELECT * FROM ricci.detect_field_dissolution(''%s'')', test_point),
        'fragmentation'
    );
    
    PERFORM ricci_test.cleanup_test_data();
END;
$$;

\echo 'Fragmentation: coupling dispersion → coupling trend negative with low sapience (executes)'
DO $$
DECLARE
    test_point UUID;
BEGIN
    test_point := ricci_test.create_test_manifold_point();
    
    PERFORM ricci_test.assert_no_error(
        'metric_dispersion_executes',
        format('SELECT * FROM ricci.detect_coupling_dispersion(''%s'')', test_point),
        'fragmentation'
    );
    
    PERFORM ricci_test.cleanup_test_data();
END;
$$;

\echo 'Fragmentation: combined signatures → multiplexed detector executes'
DO $$
DECLARE
    test_point UUID;
BEGIN
    test_point := ricci_test.create_test_manifold_point();
    
    PERFORM ricci_test.assert_no_error(
        'fragmentation_signatures_combined',
        format('SELECT * FROM ricci.detect_fragmentation_signatures(''%s'')', test_point),
        'fragmentation'
    );
    
    PERFORM ricci_test.cleanup_test_data();
END;
$$;

\echo 'Fragmentation: schema verification → expect at least one valid row with type/severity/evidence under induced decay'
DO $$
DECLARE
    test_point UUID;
    signature_rec RECORD;
    result_count INTEGER;
BEGIN
    test_point := ricci_test.create_test_manifold_point();

    -- Deterministically trigger REFERENCE_DECAY: create decreasing coupling magnitudes and low sapience
    INSERT INTO ricci.sapience_field (point_id, sapience_value, circumspection_factor)
    VALUES (test_point, 0.0, 0.0)
    ON CONFLICT (point_id) DO UPDATE SET sapience_value = EXCLUDED.sapience_value, circumspection_factor = EXCLUDED.circumspection_factor;

    INSERT INTO ricci.recursive_coupling (id, point_p, point_q, coupling_magnitude, coupling_tensor, computed_at)
    VALUES 
        (gen_random_uuid(), test_point, test_point, 0.6, ARRAY[0.0], NOW() - INTERVAL '5 minutes'),
        (gen_random_uuid(), test_point, test_point, 0.4, ARRAY[0.0], NOW() - INTERVAL '10 minutes'),
        (gen_random_uuid(), test_point, test_point, 0.2, ARRAY[0.0], NOW() - INTERVAL '20 minutes'),
        (gen_random_uuid(), test_point, test_point, 0.1, ARRAY[0.0], NOW() - INTERVAL '30 minutes');

    -- Assert at least one fragmentation signature is detected
    SELECT COUNT(*) INTO result_count FROM ricci.detect_fragmentation_signatures(test_point);
    PERFORM ricci_test.assert_true(
        'fragmentation_signatures_present',
        result_count > 0,
        'fragmentation',
        'At least one fragmentation signature should be detected with decreasing coupling and low sapience'
    );

    -- Test schema of returned rows
    FOR signature_rec IN 
        SELECT * FROM ricci.detect_fragmentation_signatures(test_point)
    LOOP
        PERFORM ricci_test.assert_true(
            'fragmentation_signature_type_valid',
            signature_rec.signature_type IN ('ATTRACTOR_DISSOCIATION', 'FIELD_DISSOLUTION', 'COUPLING_DISPERSION'),
            'fragmentation',
            'Signature type should be a valid fragmentation type'
        );
        
        PERFORM ricci_test.assert_true(
            'fragmentation_severity_range',
            signature_rec.severity >= 0.0 AND signature_rec.severity <= 1.0,
            'fragmentation',
            'Severity should be between 0.0 and 1.0'
        );
        
        PERFORM ricci_test.assert_true(
            'fragmentation_evidence_exists',
            signature_rec.mathematical_evidence IS NOT NULL,
            'fragmentation',
            'Mathematical evidence should exist'
        );
    END LOOP;
    
    PERFORM ricci_test.cleanup_test_data();
END;
$$;

\echo 'Fragmentation: null point handling → executes without error'
SELECT ricci_test.assert_no_error(
    'fragmentation_null_handling',
    'SELECT * FROM ricci.detect_fragmentation_signatures(NULL)',
    'fragmentation'
);

\echo 'Fragmentation: performance → combined detector ≤ 3s'
DO $$
DECLARE
    test_point UUID;
BEGIN
    test_point := ricci_test.create_test_manifold_point();
    
    PERFORM ricci_test.assert_performance(
        'fragmentation_signatures_performance',
        format('SELECT * FROM ricci.detect_fragmentation_signatures(''%s'')', test_point),
        '3 seconds',
        'fragmentation'
    );
    
    PERFORM ricci_test.cleanup_test_data();
END;
$$;

\echo ''
\echo 'Completed fragmentation signature tests.'
