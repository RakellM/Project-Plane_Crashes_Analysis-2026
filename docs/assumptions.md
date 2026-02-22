# Assumptions File

1. Where `?` or an unparseable value is found, the corresponding cleaned field is set to NULL.
2. Garbled symbols (`�`) are results of encoding issues and will be cleaned/replaced.
3. The breakdowns in parenthesis for aboard/fatalities will be extracted into separate fields for maximum analytic value.
4. Date format ambiguity will be handled by context, two-digit years will be mapped to centuries based on earliest crash data in the table.

