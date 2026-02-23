
-- ==========================================================================
-- DATA CLEANING
-- ==========================================================================


DROP TABLE IF EXISTS plane_crashes_clean;

CREATE TABLE plane_crashes_clean (
            crash_id INTEGER PRIMARY KEY AUTOINCREMENT,

            -- -- Date
            -- date_original_text TEXT,
            -- date_day_text TEXT,
            -- date_month_text TEXT,
            date_month_num INTEGER,
            -- date_year_text TEXT,
            date_year_num INTEGER,
            date_crash TEXT,  -- there is not date in SQLite

            -- -- Time
            -- time_original_text TEXT,
            time_is_approximate INTEGER,
            time_is_utc INTEGER,
            -- time4d_text TEXT,
            -- time_hour_text TEXT,
            -- time_minutes_text TEXT,
            time_crash TEXT,  -- there is not date in SQLite
            time_of_day_type TEXT,
            time_is_AM INTEGER,

            -- -- Location
            -- crash_location_original_text TEXT,
            crash_location_is_approximate INTEGER,
            crash_location_environment_type TEXT,
            crash_location_text TEXT,

            -- -- Operator
            operator_text TEXT,
            operator_is_military INTEGER,
            operator_is_private INTEGER,
            operator_is_airtaxi INTEGER,
            -- operator_sep_count INTEGER,

            -- -- Flight No
            flight_no_text TEXT,

            -- -- Route
            -- route_original_text TEXT,
            route_text TEXT,
            route_sep_count INTEGER,
            route_from_text TEXT,
            route_to_multiple_text TEXT,

            -- -- Aircraft Type
            -- ac_type_original_text TEXT,
            -- ac_type_adj_text TEXT,
            ac_type_text TEXT,
            ac_type_make_text TEXT,
            ac_type_model_text TEXT,

            -- -- Registration
            registration_text TEXT,
            registration_part1_text TEXT,
            registration_part2_text TEXT,

            -- -- Construction/line number
            serial_fuselage_nbr_text TEXT,

            -- -- Aboard
            -- aboard_original_text TEXT,
            aboard_total_count INTEGER,
            aboard_passengers_count INTEGER,
            aboard_crew_count INTEGER,

            -- -- Fatalities
            -- fatalities_original_text,
            fatalities_total_count INTEGER,
            fatalities_passengers_count INTEGER,
            fatalities_crew_count INTEGER,

            -- Ground
            ground_fatalities_count INTEGER,

            -- -- Summary
            summary_full_text TEXT,
            summary_short_text TEXT

) ;

INSERT INTO plane_crashes_clean 

WITH
    data_cleaning_1 AS (
        SELECT 
            crash_id,

            -- -- Date (create a column for each day month, year)
            REPLACE(date, '?', '') AS date_original,
            SUBSTR(date, 1, INSTR(date, '-') - 1) AS date_day,
            SUBSTR(
                SUBSTR(date, INSTR(date, '-') + 1), 
                1, 
                INSTR(SUBSTR(date, INSTR(date, '-') + 1), '-') - 1 
                ) AS date_month,
            SUBSTR(date, -2) AS date_year,

            -- -- Time (splitting all observed scenarios and leaving the field with 4 digits)
            time AS time_original,
            CASE
                WHEN time = '?' THEN NULL
                WHEN time LIKE '%.%' THEN
                    printf('%04d',
                            CASE
                                -- only 1 digit after dot, append 0
                                WHEN LENGTH(substr(time, instr(time, '.') + 1)) = 1
                                    THEN REPLACE(time, '.', '') || '0'
                                
                                -- more than 1 digit, just remove dot
                                ELSE REPLACE(time, '.', '')
                            END
                    )
                -- -- Single integer make it as whole hours
                WHEN time GLOB '[0-9]' THEN printf('%02d00', time)
                ELSE
                -- -- Remove non-numeric, left-pad to 4 digits
                printf('%04d', REPLACE( REPLACE( REPLACE( TRIM(LOWER(time), ' cdz;' ), ';', ':' ), '"', '' ), ':', '' ))
            END AS time4d,

            -- -- Adding booleans for approximate time and utc when observed
            CASE WHEN LOWER(time) LIKE 'c%' THEN 1 ELSE 0 END AS time_approximate,
            CASE WHEN time LIKE '%Z' THEN 1 ELSE 0 END AS time_utc,

            -- -- Location (original and guessed country)
            location,
            LENGTH(location) - LENGTH(REPLACE(location, char(10), '')) AS location_line_break_count,
            CASE 
                WHEN location = '?' THEN NULL
                WHEN INSTR(location, char(10)) > 0 THEN TRIM(SUBSTR(location, 1, INSTR(location, char(10)) - 1))
                ELSE TRIM(location )
            END AS location_adj,
            CASE WHEN LOWER(location) LIKE '%near %' THEN 1 ELSE 0 END AS location_approximate,
            CASE 
                WHEN LOWER(location) LIKE '%off %' OR 
                    LOWER(location) LIKE '% sea %' OR 
                    LOWER(location) LIKE '%ocean%' THEN "Water" 
                ELSE "Land" 
            END AS crash_environment,

            -- -- Operator
            CASE WHEN operator = '?' THEN NULL ELSE TRIM(operator) END AS operator,
            CASE WHEN TRIM(LOWER(operator)) LIKE '%military%' THEN 1 ELSE 0 END AS operator_military,
            CASE WHEN TRIM(LOWER(operator)) LIKE '%private%' THEN 1 ELSE 0 END AS operator_private,
            CASE WHEN TRIM(LOWER(operator)) LIKE '%taxi%' THEN 1 ELSE 0 END AS operator_airtaxi,
            LENGTH(operator) - LENGTH(REPLACE(operator, '-', '')) AS operator_sep_count,

            -- -- Flight number
            CASE WHEN flight_no = '?' OR flight_no = '-' THEN NULL ELSE flight_no END AS flight_no,

            -- -- Route
            route,
            CASE 
                WHEN route = '?' OR route = '#NAME?' THEN NULL 
                WHEN route LIKE "%t:%"  THEN TRIM(REPLACE(route, 't:' , '') )  
                WHEN route LIKE "%:%"   THEN TRIM(REPLACE(route, ':'  , '') )
                WHEN route LIKE "%,- %" THEN TRIM(REPLACE(route, ',- ', ' - ') ) 
                WHEN route LIKE "% -%"  THEN TRIM(REPLACE(route, ' -' , ' - ') )
                WHEN route LIKE "%- %"  THEN TRIM(REPLACE(route, '- ' , ' - ') )
                ELSE TRIM(route)
            END AS route_adj,

            -- -- Aircraft type
            ac_type,
            LENGTH(ac_type) - LENGTH(REPLACE(ac_type, char(10), '')) AS ac_type_line_break_count,
            UPPER(REPLACE(
                CASE 
                    WHEN ac_type = '?' THEN NULL
                    WHEN INSTR(ac_type, char(10)) > 0 
                        THEN TRIM(SUBSTR(ac_type, 1, INSTR(ac_type, char(10)) - 1))
                    ELSE TRIM(ac_type)
                END , '  ', ' ')
            ) AS ac_type_adj,

            -- -- Registration
            CASE WHEN registration = '?' THEN NULL ELSE registration END AS registration,

            -- -- Construction/line number
            CASE 
                WHEN cn_ln = '?' THEN NULL 
                ELSE REPLACE(cn_ln, ' ', '')
            END AS cn_ln,

            -- -- Extract total aboard (before first space or symbol; fallback if missing)
            aboard,
            LENGTH(aboard) - LENGTH(REPLACE(aboard, '�', '')) AS aboard_line_break_count,
            
            CASE
                WHEN aboard LIKE '?%' THEN NULL
                ELSE CAST(
                    TRIM(SUBSTR(aboard, 1, INSTR(aboard, ' ') - 1))
                    AS INTEGER)
            END AS aboard_total,

            CASE
                WHEN aboard LIKE '%passengers:?%' THEN NULL
                ELSE CAST(
                    -- -- Find 'passengers:' and extract number before '�'
                    TRIM(
                    SUBSTR(
                        SUBSTR(aboard, INSTR(aboard, 'passengers:') + LENGTH('passengers:'), 6),
                        1,
                        INSTR(SUBSTR(aboard, INSTR(aboard, 'passengers:') + LENGTH('passengers:'), 6), '�') - 1
                    )
                    ) AS INTEGER
                )
            END AS aboard_passengers,

            CASE
                WHEN aboard LIKE '%crew:?%' THEN NULL
                ELSE CAST(
                    -- -- Find 'crew:' and extract number before ')'
                    TRIM(
                    SUBSTR(
                        SUBSTR(aboard, INSTR(aboard, 'crew:') + LENGTH('crew:'), 6),
                        1,
                        INSTR(SUBSTR(aboard, INSTR(aboard, 'crew:') + LENGTH('crew:'), 6), ')') - 1
                    )
                    ) AS INTEGER
                )
            END AS aboard_crew,

            -- -- Extract total fatalities (before first space or symbol; fallback if missing)
            fatalities,
            LENGTH(fatalities) - LENGTH(REPLACE(fatalities, '�', '')) AS fatalities_line_break_count,
            
            CASE
                WHEN fatalities LIKE '?%' THEN NULL
                ELSE CAST(
                    TRIM(SUBSTR(fatalities, 1, INSTR(fatalities, ' ') - 1))
                    AS INTEGER)
            END AS fatalities_total,

            CASE
                WHEN fatalities LIKE '%passengers:?%' THEN NULL
                ELSE CAST(
                    -- -- Find 'passengers:' and extract number before '�'
                    TRIM(
                    SUBSTR(
                        SUBSTR(fatalities, INSTR(fatalities, 'passengers:') + LENGTH('passengers:'), 6),
                        1,
                        INSTR(SUBSTR(fatalities, INSTR(fatalities, 'passengers:') + LENGTH('passengers:'), 6), '�') - 1
                    )
                    ) AS INTEGER
                )
            END AS fatalities_passengers,

            CASE
                WHEN fatalities LIKE '%crew:?%' THEN NULL
                ELSE CAST(
                    -- -- Find 'crew:' and extract number before ')'
                    TRIM(
                    SUBSTR(
                        SUBSTR(fatalities, INSTR(fatalities, 'crew:') + LENGTH('crew:'), 6),
                        1,
                        INSTR(SUBSTR(fatalities, INSTR(fatalities, 'crew:') + LENGTH('crew:'), 6), ')') - 1
                    )
                    ) AS INTEGER
                )
            END AS fatalities_crew,

            -- Ground
            CASE WHEN ground = '?' THEN NULL ELSE TRIM(ground) END AS ground,

            -- -- Summary
            CASE 
                WHEN summary = '?' THEN NULL 
                WHEN LOWER(summary) LIKE '%unknown%' THEN NULL
                ELSE TRIM(REPLACE(REPLACE(summary, '  ', ' '), '  ', ' ')) 
            END AS summary,

            1 AS test

        FROM plane_crashes_copy 

    ) ,



    data_cleaning_2 AS (
        SELECT 
            crash_id,

            -- -- Date
            date_original,
            date_day,
            date_month,
            date_year,
            CASE
                WHEN crash_id >= 4899 THEN 2000 + CAST(date_year AS INTEGER)
                ELSE 1900 + CAST(date_year AS INTEGER)
            END AS date_year4d,
            CASE LOWER(TRIM(date_month))
                WHEN 'jan' THEN 1  WHEN 'feb' THEN 2  WHEN 'mar' THEN 3
                WHEN 'apr' THEN 4  WHEN 'may' THEN 5  WHEN 'jun' THEN 6
                WHEN 'jul' THEN 7  WHEN 'aug' THEN 8  WHEN 'sep' THEN 9
                WHEN 'oct' THEN 10 WHEN 'nov' THEN 11 WHEN 'dec' THEN 12
            END AS date_month2, 

            -- -- Time
            time_original,
            time_approximate,
            time_utc,
            time4d,
            SUBSTR(time4d, 1, 2) AS time_hour,
            SUBSTR(time4d, -2) AS time_minutes,

            -- -- Location
            location,
            location_approximate,
            crash_environment,

            CASE
                -- -- Look for pattern: digits, comma, digits (like 1,200)
                WHEN location_adj GLOB '*[0-9],[0-9][0-9][0-9]*' 
                THEN SUBSTR(location_adj, 1, INSTR(location_adj, ',') - 1) || 
                    SUBSTR(location_adj, INSTR(location_adj, ',') + 1)
                ELSE location_adj
            END AS location_adj,

            -- -- Operator
            operator,
            operator_military,
            operator_private,
            operator_airtaxi,
            operator_sep_count,

            -- -- Flight No
            flight_no,

            -- -- Route
            route,
            REPLACE(REPLACE(REPLACE(route_adj, ' - ', ' : '), CHAR(9), ''), '  ', ' ') AS route_adj,

            -- -- Aircraft Type
            ac_type,
            ac_type_adj,
            CASE
                WHEN ac_type_adj LIKE "DE HAVILLAND %" THEN REPLACE(ac_type_adj, "DE HAVILLAND", "DEHAVILLAND")
                WHEN ac_type_adj LIKE "DE HVILLAND %" THEN REPLACE(ac_type_adj, "DE HVILLAND", "DEHAVILLAND")
                WHEN ac_type_adj LIKE "%É%" THEN REPLACE(ac_type_adj, "É", "E")
                WHEN ac_type_adj LIKE "ZEPPLIN%" THEN REPLACE(ac_type_adj, "ZEPPLIN", "ZEPPELIN")
                WHEN ac_type_adj LIKE "DE HAV CAN%" THEN REPLACE(ac_type_adj, "DE HAV CAN.", "DEHAVILLAND CANADA")
                ELSE ac_type_adj
            END AS ac_type_adj2,

            -- -- Registration
            registration,
            CASE 
                WHEN INSTR(registration, '/') > 0 
                THEN TRIM(SUBSTR(registration, 1, INSTR(registration, '/') - 1))
                ELSE TRIM(registration) 
            END AS registration_part1,
            CASE 
                WHEN INSTR(registration, '/') > 0 
                THEN TRIM(SUBSTR(registration, 
                        LENGTH(registration) - 
                        LENGTH(SUBSTR(registration, INSTR(registration, '/') + 1)) + 1))
                ELSE NULL
            END AS registration_part2,

            -- -- Construction/line number
            cn_ln,

            -- -- Aboard
            aboard,
            CAST(aboard_total AS INTEGER) AS aboard_total,
            CAST(aboard_passengers AS INTEGER) AS aboard_passengers,
            CAST(aboard_crew AS INTEGER) AS aboard_crew,

            -- -- Fatalities
            fatalities,
            CAST(fatalities_total AS INTEGER) AS fatalities_total,
            CAST(fatalities_passengers AS INTEGER) AS fatalities_passengers,
            CAST(fatalities_crew AS INTEGER) AS fatalities_crew,

            -- -- Ground
            CAST(ground AS INTEGER) AS ground,

            -- -- Summary
            summary,
            CASE 
                WHEN INSTR(summary, '.') > 0 
                THEN TRIM(SUBSTR(summary, 1, INSTR(summary, '.') - 1))
                ELSE TRIM(summary) 
            END AS summary_short,

            1 AS test

        FROM data_cleaning_1
    ) ,



    data_cleaning_3 AS (
        SELECT
            crash_id,

            -- -- Date
            date_original,
            date_day,
            date_month,
            date_month2,
            date_year,
            date_year4d,
            CASE
                WHEN date_original IS NULL THEN NULL
                ELSE printf('%04d-%02d-%02d', date_year4d, date_month2, date_day) 
            END AS date_crash,

            -- -- Time
            time_original,
            time_approximate,
            time_utc,
            time4d,
            time_hour,
            time_minutes,
            CASE
                WHEN time_hour IS NULL OR time_minutes IS NULL THEN NULL
                ELSE printf('%02d:%02d', CAST(time_hour AS INT), CAST(time_minutes AS INT)) 
            END AS time_crash,
            CASE 
                WHEN CAST(time_hour AS INT) >= 5 AND CAST(time_hour AS INT) < 12 THEN "Morning"
                WHEN CAST(time_hour AS INT) >= 12 AND CAST(time_hour AS INT) < 17 THEN "Afternoon"
                WHEN CAST(time_hour AS INT) >= 17 AND CAST(time_hour AS INT) < 21 THEN "Evening"
                WHEN CAST(time_hour AS INT) >= 21 OR CAST(time_hour AS INT) < 5 THEN "Night"
                ELSE NULL
            END AS time_of_day,
            CASE 
                WHEN CAST(time_hour AS INT) >= 0 AND CAST(time_hour AS INT) < 12 THEN 1
                ELSE 0
            END AS time_AM,

            -- -- Location
            location,
            location_approximate,
            crash_environment,
            location_adj,

            -- -- Operator
            operator,
            operator_military,
            operator_private,
            operator_airtaxi,
            operator_sep_count,

            -- Flight No
            flight_no,

            -- -- Route
            route,
            route_adj,
            -- -- Count stops
            LENGTH(route_adj) - LENGTH(REPLACE(route_adj, ':', '')) AS route_sep_count,

            -- -- First name on the route
            CASE 
                WHEN INSTR(route_adj, ' : ') > 0 
                THEN TRIM(SUBSTR(route_adj, 1, INSTR(route_adj, ' : ') - 1))
                ELSE TRIM(route_adj) 
            END AS route_from,
            
            -- -- All but first
            CASE 
                WHEN INSTR(route_adj, ' : ') > 0 
                THEN TRIM(SUBSTR(route_adj, 
                        LENGTH(route_adj) - 
                        LENGTH(SUBSTR(route_adj, INSTR(route_adj, ' : ') + 3)) + 1))
                ELSE TRIM(route_adj) 
            END AS route_to_multiple,

            -- -- Aircraft Type
            ac_type,
            ac_type_adj,
            ac_type_adj2,
            -- -- AC Make
            CASE 
                WHEN INSTR(ac_type_adj2, '/') > 0 
                THEN TRIM(SUBSTR(ac_type_adj2, 1, INSTR(ac_type_adj2, '/') - 1))
                ELSE TRIM(ac_type_adj2) 
            END AS ac_type_make,
            -- -- AC Model
            CASE 
                WHEN INSTR(ac_type_adj2, '/') > 0 
                THEN TRIM(SUBSTR(ac_type_adj2, 
                        LENGTH(ac_type_adj2) - 
                        LENGTH(SUBSTR(ac_type_adj2, INSTR(ac_type_adj2, '/') + 1)) + 1))
                ELSE TRIM(ac_type_adj2) 
            END AS ac_type_model,

            -- -- Registration
            registration,
            CASE 
                WHEN registration_part1 = '?' THEN NULL 
                WHEN registration = '1/2/2003' THEN NULL
                ELSE registration_part1 
            END AS registration_part1,
            CASE 
                WHEN registration_part2 = '?' THEN NULL 
                WHEN registration = '1/2/2003' THEN NULL
                ELSE registration_part2 
            END AS registration_part2,

            -- -- Construction/line number
            cn_ln,

            -- -- Aboard
            aboard,
            aboard_total,
            aboard_passengers,
            aboard_crew,

            -- -- Fatalities
            fatalities,
            fatalities_total,
            fatalities_passengers,
            fatalities_crew,

            -- Ground
            ground,

            -- -- Summary
            summary,
            summary_short,

            1 AS test

        FROM data_cleaning_2
    )

SELECT 
            crash_id,

            -- -- Date
            -- date_original AS date_original_text,
            -- date_day AS date_day_text,
            -- date_month AS date_month_text,
            CAST(date_month2 AS INTEGER) AS date_month_num,
            -- date_year AS date_year_text,
            CAST(date_year4d AS INTEGER) AS date_year_num,
            date_crash,

            -- -- Time
            -- time_original AS time_original_text,
            time_approximate AS time_is_approximate,
            time_utc AS time_is_utc,
            -- time4d AS time4d_text,
            -- time_hour AS time_hour_text,
            -- time_minutes AS time_minutes_text,
            time_crash,
            time_of_day AS time_of_day_type,
            time_AM AS time_is_AM,

            -- -- Location
            -- location AS crash_location_original_text,
            location_approximate AS crash_location_is_approximate,
            crash_environment AS crash_location_environment_type,
            location_adj AS crash_location_text,

            -- -- Operator
            operator AS operator_text,
            operator_military AS operator_is_military,
            operator_private AS operator_is_private,
            operator_airtaxi AS operator_is_airtaxi,
            -- operator_sep_count,

            -- -- Flight No
            flight_no AS flight_no_text,

            -- -- Route
            -- route AS route_original_text,
            route_adj AS route_text,
            route_sep_count,
            route_from AS route_from_text,
            route_to_multiple AS route_to_multiple_text,

            -- -- Aircraft Type
            -- ac_type AS ac_type_original_text,
            -- ac_type_adj AS ac_type_adj_text,
            ac_type_adj2 AS ac_type_text,
            ac_type_make AS ac_type_make_text,
            ac_type_model AS ac_type_model_text,

            -- -- Registration
            registration AS registration_text,
            registration_part1 AS registration_part1_text,
            registration_part2 AS registration_part2_text,

            -- -- Construction/line number
            cn_ln AS serial_fuselage_nbr_text,

            -- -- Aboard
            -- aboard AS aboard_original_text,
            aboard_total AS aboard_total_count,
            aboard_passengers AS aboard_passengers_count,
            aboard_crew AS aboard_crew_count,

            -- -- Fatalities
            -- fatalities AS fatalities_original_text,
            fatalities_total AS fatalities_total_count,
            fatalities_passengers AS fatalities_passengers_count,
            fatalities_crew As fatalities_crew_count,

            -- Ground
            ground AS ground_fatalities_count,

            -- -- Summary
            summary AS summary_full_text,
            summary_short AS summary_short_text

            -- test

FROM data_cleaning_3

ORDER BY crash_id

;







