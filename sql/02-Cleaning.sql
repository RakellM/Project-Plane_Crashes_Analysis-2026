
-- ==========================================================================
-- DATA CLEANING
-- ==========================================================================

WITH
    data_clean_1 AS (
SELECT 
    crash_id,

    -- Date (create a column for each day month, year)
    date AS date_original,
    SUBSTR(date, 1, INSTR(date, '-') - 1) AS date_day,
    SUBSTR(
        SUBSTR(date, INSTR(date, '-') + 1), 
        1, 
        INSTR(SUBSTR(date, INSTR(date, '-') + 1), '-') - 1 
        ) AS date_month,
    SUBSTR(date, -2) AS date_year,

    -- Time (splitting all observed scenarios and leaving the field with 4 digits)
    time AS time_original,
    CASE
        WHEN time = '?' THEN NULL
        ELSE printf('%04d', REPLACE(REPLACE(REPLACE(TRIM(time, ' cZ;'), ';', ''), '.', ''), ':', ''))
    END AS crash_time,
    -- Adding booleans for approximate time and utc when observed
    CASE WHEN time LIKE 'c %' THEN 1 ELSE 0 END AS time_approximate,
    CASE WHEN time LIKE '%Z' THEN 1 ELSE 0 END AS time_utc,

    -- Location (original and guessed country)
    location,
    LENGTH(location) - LENGTH(REPLACE(location, char(10), '')) AS line_break_count,
    CASE 
        WHEN INSTR(location, char(10)) > 0 
        THEN SUBSTR(location, 1, INSTR(location, char(10)) - 1)
        ELSE location 
    END AS location_adj,
    CASE WHEN location LIKE 'near %' THEN 1 ELSE 0 END AS location_approximate,
    CASE WHEN location LIKE 'Off %' THEN "Water" ELSE "Land" END AS crash_environment,

    -- Operator
    CASE WHEN operator = '?' THEN NULL ELSE TRIM(operator) END AS operator_clean,
    LENGTH(operator) - LENGTH(REPLACE(operator, '-', '')) AS operator_sep_count,


    -- Flight number
    CASE WHEN flight_no = '?' THEN NULL ELSE flight_no END AS flight_no_clean,

    -- Route
    CASE WHEN route = '?' THEN NULL ELSE route END AS route_clean,
    LENGTH(route) - LENGTH(REPLACE(route, '-', '')) AS route_sep_count,

    -- Aircraft type cleaned
    TRIM(ac_type) AS ac_type_clean,


    1
FROM plane_crashes_clean 
)

SELECT *
FROM data_clean_1
WHERE route_sep_count = 0 and route_clean is not null
ORDER BY route_sep_count, route_clean
-- LIMIT 20
;
��
-- route_clean LIKE "Demo%" "Air%Show%" "Test%" "Train5"



    -- -- time
    -- SUBSTR(crash_time, 2) AS time_hour,
    -- SUBSTR(crash_time, -2) AS time_minutes,

    -- -- location 
    -- TRIM(REPLACE(REPLACE(location_adj, 'Off ', ''), 'Near', '')) AS location_adj2,
    -- LENGTH(location_adj) - LENGTH(REPLACE(location_adj, ',', '')) AS comma_count,
    -- TRIM(SUBSTR(location, INSTR(location, ',') + 1)) AS location1,
    -- TRIM(SUBSTR(location, 1, INSTR(location, ',') - 1)) AS part1,
    -- TRIM(SUBSTR(location, INSTR(location, ',') + 1, 
    --     INSTR(SUBSTR(location, INSTR(location, ',') + 1), ',') - 1)) AS part2,
    -- TRIM(SUBSTR(location, INSTR(location, ',') + 1 + 
    --     INSTR(SUBSTR(location, INSTR(location, ',') + 1), ',') + 1)) AS part3,





