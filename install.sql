-- RICCI: Riemannian Intrinsic Coherence & Coupling Infrastructure
-- Main Runner
-- File: install.sql
--
-- Licensed under MIT License
-- 
-- SPDX-License-Identifier: MIT

\echo '============================================================'
\echo '                          RICCI'
\echo '  Riemannian Intrinsic Coherence & Coupling Infrastructure'
\echo ''
\echo '  a field analysis engine for semantic database structures'
\echo '============================================================'
\echo ''
\echo ''

SET client_min_messages TO warning;

\echo 'Sequence: schema/00_foundation.sql'
\echo '          schema/01_geometric_analysis.sql'
\echo '          schema/02_rigidity_detectors.sql'
\echo '          schema/03_fragmentation_detectors.sql'
\echo '          schema/04_inflation_detectors.sql'
\echo '          schema/05_coupling_detectors.sql'
\echo '          schema/06_operational_monitoring.sql'
\echo ''
\echo '====================  RFT Foundation  ======================'
\echo ''
\i schema/00_foundation.sql
\echo ''

\echo '==================  Geometric Analysis  ===================='
\echo ''
\i schema/01_geometric_analysis.sql
\echo ''

\echo '==================  Rigidity Signatures  ==================='
\echo ''
\i schema/02_rigidity_detectors.sql
\echo ''

\echo '===============  Fragmentation Signatures  ================='
\echo ''
\i schema/03_fragmentation_detectors.sql
\echo ''

\echo '=================  Inflation Signatures  ==================='
\echo ''
\i schema/04_inflation_detectors.sql
\echo ''

\echo '==================   Coupling Signatures  =================='
\echo ''
\i schema/05_coupling_detectors.sql
\echo ''

\echo '================  Operational Monitoring  =================='
\echo ''
\i schema/06_operational_monitoring.sql
\echo ''

SET client_min_messages TO notice;

\echo 'RICCI engine loaded successfully.'
\echo ''