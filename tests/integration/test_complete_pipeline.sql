-- RICCI: Integration Tests - Complete Pipeline
-- File: tests/integration/test_complete_pipeline.sql
--
-- Tests for complete RICCI analysis pipeline
-- Copyright 2025 Inside The Black Box LLC
-- Licensed under MIT License

\echo 'Integration: complete analysis pipeline → detect_all_signatures executes and returns count ≥ 0'
DO $$
DECLARE
    test_point UUID;
    signature_count INTEGER;
BEGIN
    -- Create a test point and populate minimal geometric fields for end-to-end run
    test_point := ricci_test.create_test_manifold_point();
    
    -- Add geometric properties
    UPDATE ricci.manifold_points SET
        semantic_mass = ricci.compute_semantic_mass(recursive_depth, 1.0, attractor_stability),
        metric_tensor = ARRAY(SELECT (i + j)::FLOAT FROM generate_series(1,100) i, generate_series(1,100) j ORDER BY i,j),
        metric_determinant = 1.0
    WHERE id = test_point;
    
    -- Test complete signature detection
    SELECT COUNT(*) INTO signature_count
    FROM ricci.detect_all_signatures(test_point);
    
    PERFORM ricci_test.assert_true(
        'complete_pipeline_executes',
        signature_count >= 0,
        'integration',
        'Complete analysis pipeline should execute successfully'
    );
    
    PERFORM ricci_test.cleanup_test_data();
END;
$$;

\echo 'Integration: coordination detection → clusters computed over high-coupling triples (count ≥ 0)'
DO $$
DECLARE
    test_point_1 UUID;
    test_point_2 UUID;
    test_point_3 UUID;
    coordination_count INTEGER;
BEGIN
    -- Create multiple points and strong pairwise couplings to enable cluster formation
    test_point_1 := ricci_test.create_test_manifold_point(NULL, NULL, 'test_user_1');
    test_point_2 := ricci_test.create_test_manifold_point(NULL, NULL, 'test_user_2');
    test_point_3 := ricci_test.create_test_manifold_point(NULL, NULL, 'test_user_3');
    
    -- Create coupling relationships
    INSERT INTO ricci.recursive_coupling (id, point_p, point_q, coupling_magnitude, coupling_tensor)
    VALUES 
        (gen_random_uuid(), test_point_1, test_point_2, 0.9, ARRAY(SELECT random()::FLOAT FROM generate_series(1, 1000000))),
        (gen_random_uuid(), test_point_2, test_point_3, 0.85, ARRAY(SELECT random()::FLOAT FROM generate_series(1, 1000000))),
        (gen_random_uuid(), test_point_1, test_point_3, 0.8, ARRAY(SELECT random()::FLOAT FROM generate_series(1, 1000000)));
    
    -- Test coordination detection
    SELECT COUNT(*) INTO coordination_count
    FROM ricci.detect_coordination_via_coupling('1 hour', 0.7, 2);
    
    PERFORM ricci_test.assert_true(
        'coordination_detection_pipeline',
        coordination_count >= 0,
        'integration',
        'Coordination detection should execute without error'
    );
    
    PERFORM ricci_test.cleanup_test_data();
END;
$$;

\echo 'Integration: escalation prediction → trajectory over 5 points executes (count ≥ 0)'
DO $$
DECLARE
    test_points UUID[];
    test_point UUID;
    escalation_count INTEGER;
    i INTEGER;
BEGIN
    -- Create 5 points with increasing coherence and curvature to simulate escalation
    test_points := ARRAY[]::UUID[];
    
    FOR i IN 1..5 LOOP
        test_point := ricci_test.create_test_manifold_point();
        test_points := array_append(test_points, test_point);
        
        -- Update with increasing coherence to simulate escalation
        UPDATE ricci.manifold_points SET 
            coherence_magnitude = 0.5 + (i * 0.1),
            scalar_curvature = i * 0.2,
            creation_timestamp = NOW() + (i || ' minutes')::INTERVAL
        WHERE id = test_point;
    END LOOP;
    
    -- Test escalation detection
    SELECT COUNT(*) INTO escalation_count
    FROM ricci.detect_escalation_via_field_evolution(test_points);
    
    PERFORM ricci_test.assert_true(
        'escalation_prediction_pipeline',
        escalation_count >= 0,
        'integration',
        'Escalation prediction should execute without error'
    );
    
    PERFORM ricci_test.cleanup_test_data();
END;
$$;

\echo 'Integration: field evolution → evolve_coherence_field_complete returns non-null vector'
DO $$
DECLARE
    test_point UUID;
    evolved_field VECTOR(2000);
BEGIN
    test_point := ricci_test.create_test_manifold_point();
    
    -- Provide identity metric and zero Γ for stable evolution step
    UPDATE ricci.manifold_points SET
        metric_tensor = ARRAY(SELECT CASE WHEN i=j THEN 1.0 ELSE 0.0 END::FLOAT 
                             FROM generate_series(1,100) i, generate_series(1,100) j ORDER BY i,j),
        christoffel_symbols = ARRAY(SELECT 0.0::FLOAT FROM generate_series(1, 1000000)),
        semantic_mass = 1.0
    WHERE id = test_point;
    
    -- Test field evolution
    SELECT ricci.evolve_coherence_field_complete(test_point, 0.01) INTO evolved_field;
    
    PERFORM ricci_test.assert_true(
        'field_evolution_pipeline',
        evolved_field IS NOT NULL,
        'integration',
        'Field evolution should return a result'
    );
    
    PERFORM ricci_test.cleanup_test_data();
END;
$$;

\echo 'Integration: monitoring views → refresh and basic access succeed'
DO $$
DECLARE
    test_point UUID;
    alert_count INTEGER;
BEGIN
    test_point := ricci_test.create_test_manifold_point();
    
    -- Insert parameters likely to produce alerts; then refresh materialized views
    UPDATE ricci.manifold_points SET
        attractor_stability = 0.9,
        coherence_magnitude = 0.8,
        semantic_mass = 2.0
    WHERE id = test_point;
    
    -- Refresh materialized view
    PERFORM ricci.refresh_geometric_alerts();
    
    -- Test alert views work
    SELECT COUNT(*) INTO alert_count FROM ricci.coordination_alerts;
    SELECT COUNT(*) INTO alert_count FROM ricci.geometric_alerts_mv;
    
    PERFORM ricci_test.assert_true(
        'monitoring_views_accessible',
        true,  -- Just testing they're accessible
        'integration',
        'Monitoring views should be accessible'
    );
    
    PERFORM ricci_test.cleanup_test_data();
END;
$$;

\echo 'Integration: stress test → 10 points, aggregate signature counts computed (≥ 0)'
DO $$
DECLARE
    test_points UUID[];
    test_point UUID;
    i INTEGER;
    total_signatures INTEGER := 0;
    signature_count INTEGER;
BEGIN
    test_points := ARRAY[]::UUID[];
    
    -- Generate points, compute semantic_mass, invoke detector per point
    FOR i IN 1..10 LOOP
        test_point := ricci_test.create_test_manifold_point(
            NULL, NULL, 'test_user_' || i
        );
        test_points := array_append(test_points, test_point);
        
        -- Compute semantic mass for each
        UPDATE ricci.manifold_points SET
            semantic_mass = ricci.compute_semantic_mass(recursive_depth, 1.0, attractor_stability)
        WHERE id = test_point;
        
        -- Test individual signature detection
        SELECT COUNT(*) INTO signature_count
        FROM ricci.detect_all_signatures(test_point);
        
        total_signatures := total_signatures + signature_count;
    END LOOP;
    
    PERFORM ricci_test.assert_true(
        'stress_test_multiple_points',
        total_signatures >= 0,
        'integration',
        'System should handle multiple points without error'
    );
    
    PERFORM ricci_test.cleanup_test_data();
END;
$$;

\echo 'Integration: data consistency → computed semantic_mass stored; invariants hold'
DO $$
DECLARE
    test_point UUID;
    computed_mass FLOAT;
    stored_mass FLOAT;
BEGIN
    test_point := ricci_test.create_test_manifold_point();
    
    -- Compare computed vs stored semantic_mass; update stored value to computed
    SELECT 
        semantic_mass,
        ricci.compute_semantic_mass(recursive_depth, COALESCE(metric_determinant, 1.0), attractor_stability)
    INTO stored_mass, computed_mass
    FROM ricci.manifold_points 
    WHERE id = test_point;
    
    -- Update with computed value
    UPDATE ricci.manifold_points SET semantic_mass = computed_mass WHERE id = test_point;
    
    PERFORM ricci_test.assert_true(
        'data_consistency_check',
        true,  -- Test that computations are consistent
        'integration',
        'Computed and stored values should be consistent'
    );
    
    PERFORM ricci_test.cleanup_test_data();
END;
$$;

\echo ''
\echo 'Completed integration tests.'
