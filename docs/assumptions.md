# Assumptions File

1. Where `?` or an unparseable value is found, the corresponding cleaned field is set to NULL.
2. Garbled symbols (`�`) are results of encoding issues and will be cleaned/replaced.
3. The breakdowns in parenthesis for aboard/fatalities will be extracted into separate fields for maximum analytic value.
4. Date format ambiguity will be handled by context, two-digit years will be mapped to centuries based on earliest crash data in the table.
5. Planes were invented in 1903, so it only make sense years be above 1903.



## `01-Database_Creation.sql`

- Added `crash_id` as primary key using autoincrement.
- Copy all other columns as TEXT so we can make adjustments.

## `02-Cleaning.sql`

- Date:
    - Dates in the table might be in order, so choosing between 1900 / 2000 will depend on previous rows.

- Time:
    - Create boolean for approximate time (if it had `c`)
    - Create boolean for UTC (if had `Z`)
    - Remove all ponctuation (`;`, `.`, `:`) and convert the fild into a 4 digits integer
    - Use that field to get Hours and Minutes

- Location: 
    - Check number of row breaks in ech cell, keep the first appearance
    - Count the number of commas in the new field
    - Create boolean for approximate (if it had `near`)
    - Create boolean for environment (if it had `Off` then Sea else Land)

