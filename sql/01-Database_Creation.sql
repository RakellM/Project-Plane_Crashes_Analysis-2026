
-- ==========================================================================
-- DATA CREATE NEW TABLE
-- ==========================================================================

DROP TABLE IF EXISTS plane_crashes_clean;

CREATE TABLE plane_crashes_clean (
    crash_id INTEGER PRIMARY KEY AUTOINCREMENT,
    date TEXT,
    time TEXT,
    location TEXT,
    operator TEXT,
    flight_no TEXT,
    route TEXT,
    ac_type TEXT,
    registration TEXT,
    cn_ln TEXT,
    aboard TEXT,
    fatalities TEXT,
    ground TEXT,
    summary TEXT
);

INSERT INTO plane_crashes_clean (
    date, time, location, operator, flight_no, route,
    ac_type, registration, cn_ln, aboard,
    fatalities, ground, summary
)
SELECT 
    date, time, location, operator, flight_no, route,
    ac_type, registration, cn_ln, aboard,
    fatalities, ground, summary
FROM plane_crashes_data;
