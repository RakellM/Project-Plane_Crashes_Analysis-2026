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
        - Identified that the first `date_year = 00` started in 4899:
            - anything prior will be 1900
            - anything after that (inclusive) will be 2000

<img src="../outputs/figures/01-SQL-DateCutOffAssumption.jpg">


- Time:
    - Create boolean for approximate time (if it had `c`)
    - Create boolean for UTC (if had `Z`)
    - Time with `.`, digits after '.':
        -If more than 1 just remove the dot (e.g. 0.625 = 0625, 0.51 = 0051)
        - If less than 1 add padd a 0 at the end (e.g. 18.4 = 1840, 5.4 = 0540)
    - Time with whole numbers:
        - If it is single digits, assume as hours (e.g. 2 = 0200)
        - If is is double digits, assume as minutes (e.g. 20 = 0020)
        - If it is triple digits, will pad a 0 at the beginning (e.g. 200 = 0200)
    - Remove all ponctuation and letters (`;`,`"`, `:`, `c`, `d`, `Z`) and convert the fild into a 4 digits integer
        - Treat `;`,`"`, `:` as ":" (e.g. 8;50 = 0850, 8"50 = 0850)
    - Use that field to get Hours and Minutes
        - Assume `00:00` is an actual time (midnight) not a missing information
    - 

- Location: 
    - Check number of row breaks in ech cell, keep the first appearance
    - Count the number of commas in the new field
    - Create boolean for approximate (if it had `Near`)
    - Create boolean for environment (if it had `Off` then 'Water' else 'Land')

- Operator:
    - Create boolean for military, private and airtaxi

- Flight No:
    - 

- Route:
    - Remove `t:`, `:`, `,-`
    - Correct writing spaces for separator `-` to ` - ` but keeping when the city name unchanged if there is any


- Aircraft Type
    - Check if there is line breaks within the cell and keep only the first row
    - Assume the format of field is Make / Model
        -  Create columns for Make and Model following this logic

- Registration
    - Create 2 columns assuming `/` as a divisor
    - Assume `1/2/2003` is `NULL`

- Construction/line number
    - Remove spaces

- Aboard

- Fatalities

- Ground:
    - Convert `?` to `NULL` but decide what to do next, maybe set default to 0

- Summary:
    -`Unknown` as NULL
    - Create a short summary using the first phrase (using `.` as end point of a phrase)
