
-- ==========================================================================
-- DATA EXTRACTION
-- ==========================================================================

-- Check tables that exist in the database
-- ──────────────────────────────────────────
-- .tables

-- SELECT name 
-- FROM sqlite_master 
-- WHERE type='table';



-- Check table sctructure
-- ──────────────────────────────────────────
-- .schema

-- PRAGMA table_info(plane_crashes_data);



-- ==========================================================================
-- DATA INTEGRITY CHECKS
-- ==========================================================================

-- Count information
-- ──────────────────────────────────────────
-- SELECT count(*) AS total_rows
-- FROM plane_crashes_data ;


-- Check for Duplicate Rows
-- ──────────────────────────────────────────
-- SELECT 
--     date,
--     time,
--     location,
--     operator,
--     flight_no,
--     route,
--     ac_type,
--     registration,
--     cn_ln,
--     aboard,
--     fatalities,
--     ground,
--     summary,
--        COUNT(*) as duplicate_count
-- FROM plane_crashes_data
-- GROUP BY 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13;
-- HAVING COUNT(*) > 1;



-- Check for Natural Unique Keys (date / location/ operator)
-- ──────────────────────────────────────────
-- SELECT date, location, operator, COUNT(*) as record_count
-- FROM plane_crashes_data
-- GROUP BY 1, 2, 3
-- HAVING COUNT(*) > 1;


-- Check for Natural Unique Keys (date / location/ operator)
-- ──────────────────────────────────────────
-- SELECT date, time, location, operator, COUNT(*) as record_count
-- FROM plane_crashes_data
-- GROUP BY 1, 2, 3, 4
-- HAVING COUNT(*) > 1;



-- Check Quality for columns
-- ──────────────────────────────────────────
-- SELECT *
-- FROM plane_crashes_data
-- LIMIT 50;


