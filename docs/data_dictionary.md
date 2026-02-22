# Data Dictionary


| cid | Field | Description | Type | Missing | Primary Key (PK) | 
| --- | --- | --- | --- | --- | --- | 
| 01 | date | Date of accident | NVARCHAR(50) |  | No | 
| 02 | time | Local time, in 24 hr. format unless otherwise specified | NVARCHAR(50) |  | No | 
| 03 | location | Location information | VARCHAR(50) |  | No | 
| 04 | operator | Airline or operator of the aircraft | VARCHAR(50) |  | No | 
| 05 | flight_no | Flight number assigned by the aircraft operator | NVARCHAR(50) |  | No | 
| 06 | route | Complete or partial route flown prior to the accident | VARCHAR(64) |  | No | 
| 07 | ac_type | Aircraft type | VARCHAR(50) |  | No | 
| 08 | registration | ICAO registration of the aircraft | NVARCHAR(50) |  | No | 
| 09 | cn_ln | Construction or serial number / Line or fuselage number | NVARCHAR(50) |  | No | 
| 10 | aboard | Total aboard (passengers / crew) | NVARCHAR(50) |  | No | 
| 11 | fatalities | Total fatalities aboard (passengers / crew) | NVARCHAR(50) |  | No | 
| 12 | ground | Total killed on the ground | TEXT(50) |  | No | 
| 13 | summary | Brief description of the accident and cause if known | VARCHAR(512) |  | No |  


- Full table contains <span style="color: orange;">5783</span> rows.
- No obvious duplicates (entire row duplicated) observed.
- Natural Unique Keys:
    1. date / location/ operator: found 3 observations that have the same combination.

    2. date / time / location/ operator: found 1 observations that have the same combination.


| date      | location            | operator                            | record_count |
| --------- | ------------------- | ----------------------------------- | ------------ |
| 17-Feb-66 | Moscow, Russia      | Aeroflot                            | 2            |
| 19-Nov-43 | Kunming, China      | China National Aviation Corporation | 2            |
| 29-Feb-68 | Near Bratsk, Russia | Aeroflot                            | 2            |



| date      | time | location       | operator                            | record_count |
| --------- | ---- | -------------- | ----------------------------------- | ------------ |
| 19-Nov-43 | ?    | Kunming, China | China National Aviation Corporation | 2            |


## General Issues

1. **No Primary Key**: Add a surrogate key (id) during cleaning for unique row identification.
2. **All Fields Nullable**: Handle missingness appropriately (retain as NULL or impute if justified).
3. **Text Storage for Numeric Fields**: Explicit conversion and validation required for all numerics.
4. **No Constraints or Relationships**: No enforced referential integrity; treat all fields as independent unless otherwise indicated.
5. **Encoding Errors**: The symbol `�` indicates encoding or parsing errors—needs replacement or removal during extraction/parsing.


## Data Integrity Check: per column (first 5 rows)

### 01 - `date` 

```Code
17-Sep-08
7-Sep-09
12-Jul-12
6-Aug-13
9-Sep-13
```

**Description**: Date of accident

**Type**: NVARCHAR(50) <span style="color: lightgreen;">← convert to DATE</span>

**Issues**: 
- Non-standardized formats (YY-MMM-DD or DD-MMMM-YY)
- For ambiguous years (08), infer century based on context or earliest known crash record.
- Missing values

**Assumption & Cleaning**:
- Parse to standard ISO date (YYYY-MM-DD).
- Any parsing errors or missing dates are flagged.
- Create derived fields: year, month, day.

**Analytic Use**: Key for temporal analysis (trends, seasonality).


---

### 02 - `time` 

```Code
17:18
?
06:30
?
c 18:30
```

**Description**: Local time, in 24 hr. format unless otherwise specified.

**Type**: NVARCHAR(50) <span style="color: lightgreen;">← convert to TIME</span>

**Issues**: Inconsistent formats (24-hour, 12-hour, 'unknown', blank).

**Assumption & Cleaning**:
- Add a boolean field time_approximate if `c` was present.
- Remove leading `c` and whitespace.
- Standardize to 24-hour time (HH:MM).
- If missing or unparseable, set as NULL.
- Create derived fields: hour.

**Analytic Use**: Analyze time-of-day patterns in crashes.

\
*Notes*:
- `c` = :
    - "_Circa_"? (means around, approximatelly) <span style="color: orange;">← more likely</span>
    - "Central Time"?
    - "Crash Time"? 

---

### 03 - `location` 

```Code
Fort Myer, Virginia
Juvisy-sur-Orge, France
Atlantic City, New Jersey
Victoria, British Columbia, Canada
Over the North Sea
```

**Description**: Location information.

**Type**: VARCHAR(50)

**Issues**: 
- Free-text
- May include city, state, country, or partial info
- Inconsistent spelling

**Assumption & Cleaning**:
- Attempt to split into city, state_province, country via pattern matching.
- Standardize spelling/casing.
- For unparseable entries, retain as is.

**Analytic Use**: Geospatial analysis, mapping crash density.

\
*Notes*:
- Different formats:
    - City, State
    - City, State, Country
    - City, Country
    - State, Country
    - Ocean
- `Near` being used to refer closeness
- Check if `,` is the only clear separator

---

### 04 - `operator` 

```Code 
Military - U.S. Army
?
Military - U.S. Navy
Private
Military - German Navy
```

**Description**: Location information.

**Type**: VARCHAR(50)

**Issues**: 
- Free-text
- Inconsistent naming

**Assumption & Cleaning**:
- Standardize casing and whitespace.
- Map known variations to canonical names where possible.
- `?` replaced with NULL.

**Analytic Use**: Operator-level safety analysis.

\
*Notes*:
- Can be subdivided as:
    - Military / Private 
- For military can be also dived in:
    - Navy
    - Army

---

### 05 - `flight_no` 

```Code
?
?
?
?
?
```

**Description**: Flight number assigned by the aircraft operator.

**Type**: NVARCHAR(50)

**Issues**: Alphanumeric, sometimes missing or formatted inconsistently.

**Assumption & Cleaning**:
- Standardize format if possible (e.g., remove spaces).
- `?` replaced with NULL.

**Analytic Use**: For specific incident tracking; often not used for aggregation.


\
*Notes*:
- Not useful for analysis unless populated.

---

### 06 - `route` 

```Code
Demonstration
Air show
Test flight
?
?
```

**Description**: Complete or partial route flown prior to the accident.

**Type**: VARCHAR(64)

**Issues**: 
- Free-text
- May contain multiple cities or only partial routes
- Often describes purpose/event ('Air show'), not geographic route.

**Assumption & Cleaning**:
- Extract origin and destination if possible using delimiters ('-', 'to', '/', etc.).
- Standardize to origin-destination if possible.
- Label as event if not a route.
- `?` replaced with NULL.

**Analytic Use**: Analyze risk by route or region if possible.


---

### 07 - `ac_type` 

```Code
Wright Flyer III
Wright Byplane
Dirigible
Curtiss seaplane
Zeppelin L-1 (airship)
```

**Description**: Aircraft type.

**Type**: VARCHAR(50)

**Issues**: Varying naming conventions (e.g., 'Boeing 737', 'B737').

**Assumption & Cleaning**:
- Normalize common naming variations.
- Consider extracting manufacturer where feasible.
- `?` replaced with NULL.

**Analytic Use**: Safety by aircraft model/manufacturer.


---

### 08 - `registration` 

```Code
?
SC1
?
?
?
```

**Description**: ICAO registration of the aircraft.

**Type**: NVARCHAR(50)

**Issues**: Inconsistent formatting; sometimes missing.

**Assumption & Cleaning**:
- Standardize format (uppercase, remove spaces).
- `?` replaced with NULL.

**Analytic Use**: Useful for joining with other aircraft-centric datasets.


\
*Notes*:
- Not useful for analysis unless populated.


---

### 09 - `cn_ln` 

```Code
1
?
?
?
?
```

**Description**: Construction or serial number / Line or fuselage number.

**Type**: NVARCHAR(50)

**Issues**: May be blank or inconsistent.

**Assumption & Cleaning**:
- Change format
- `?` replaced with NULL.

**Analytic Use**: Trace individual airframes.

\
*Notes*:
- Not useful for analysis unless populated.

---

### 10 - `aboard` 

```Code
2 � (passengers:1� crew:1)
1 � (passengers:0� crew:1)
5 � (passengers:0� crew:5)
1 � (passengers:0� crew:1)
20 � (passengers:?� crew:?)
```

**Description**: Total aboard (passengers / crew).

**Type**: NVARCHAR(50) <span style="color: lightgreen;">← convert to INTEGER</span>

**Issues**: 
- Should be integer but stored as text
- May be missing or non-numeric
- Format is `<number> � (passengers:<n>� crew:<n>)`
- Sometimes numbers replaced with `?` or symbols.

**Assumption & Cleaning**:
- Use regular expressions to extract:
    - Total number aboard (integer)
    - Passengers
    - Crew
- If any are `?`, set as NULL
- Remove encoding errors
- Store all three as separate integer columns: 
    - aboard_total
    - aboard_passengers
    - aboard_crew

**Analytic Use**: Compute survival rates, severity.


---

### 11 - `fatalities` 

```Code
1 � (passengers:1� crew:0)
1 � (passengers:0� crew:0)
5 � (passengers:0� crew:5)
1 � (passengers:0� crew:1)
14 � (passengers:?� crew:?)
```

**Description**: Total fatalities aboard (passengers / crew).

**Type**: NVARCHAR(50) <span style="color: lightgreen;">← convert to INTEGER</span>

**Issues**: 
- Should be integer but stored as text
- May be missing or non-numeric
- Format is `<number> � (passengers:<n>� crew:<n>)`
- Sometimes numbers replaced with `?` or symbols.

**Assumption & Cleaning**:
- Use regular expressions to extract:
    - Total number fatalities aboard (integer)
    - Passengers
    - Crew
- If any are `?`, set as NULL
- Remove encoding errors
- Store all three as separate integer columns: 
    - fatalities_total
    - fatalities_passengers
    - fatalities_crew

**Analytic Use**: Severity analysis.



---

### 12 - `ground` 

```Code
0
0
0
0
0
```

**Description**: Total killed on the ground.

**Type**: TEXT(50)

**Issues**: Should be integer but stored as text; may be missing or non-numeric.

**Assumption & Cleaning**:
- Convert to integer
- Set as NULL if non-numeric/missing
- Zero if not specified

**Analytic Use**: Scope of incident impact beyond passengers/crew.

---

### 13 - `summary` 

```Code
During a demonstration flight, a U.S. Army flyer flown by Orville Wright nose-dived into the ground from a height of approximately 75 feet, killing Lt. Thomas E. Selfridge, 26, who was a passenger. This was the first recorded airplane fatality in history.  One of two propellers separated in flight, tearing loose the wires bracing the rudder and causing the loss of control of the aircraft.  Orville Wright suffered broken ribs, pelvis and a leg.  Selfridge suffered a crushed skull and died a short time later.
Eugene Lefebvre was the first pilot to ever be killed in an air accident, after his controls jambed while flying in an air show.
First U.S. dirigible Akron exploded just offshore at an altitude of 1,000 ft. during a test flight.
The first fatal airplane accident in Canada occurred when American barnstormer, John M. Bryant, California aviator was killed.
The airship flew into a thunderstorm and encountered a severe downdraft crashing 20 miles north of Helgoland Island into the sea. The ship broke in two and the control car immediately sank drowning its occupants.
```

**Description**: Brief description of the accident and cause if known.

**Type**: VARCHAR(512)

**Issues**: Free-text; variable detail/quality.

**Assumption & Cleaning**:
- Retain original text for qualitative review after trimming whitespace.
- Optionally use NLP/text mining to extract cause categories or keywords.

**Analytic Use**: Text analysis for cause patterns, incident clustering.





