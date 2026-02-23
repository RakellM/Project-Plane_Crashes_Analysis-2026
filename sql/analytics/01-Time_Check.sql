SELECT
    time_crash,
    -- time_hour_text,
    -- time_original_text,
    time_of_day_type,
    count(*) AS qty

FROM plane_crashes_clean

WHERE time_crash IS NULL

GROUP BY 1, 2

ORDER BY qty DESC

;

-- PRAGMA table_info(plane_crashes_clean);
