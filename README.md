# Plane Crashes Data Preparation & Exploratory Analysis

**Position**: Data Analytics Specialist (Job ID 230435)
**Author**: Raquel Marques
**Created**: 2026-02-21


## Project Overview

This project prepares a SQLite-based plane crashes dataset for analytical use.

The objectives were to:

- Clean and standardize the dataset
- Ensure consistent and appropriate data types
- Create derived analytical features
- Conduct exploratory data analysis (EDA)
- Document data treatment decisions and assumptions

The final output is an analysis-ready dataset suitable for downstream modeling and exploration. 


## Repository Structure

```bash
├── data/
│   ├── raw/          # Original SQLite database (read-only)
│   ├── processed/    # Cleaned analysis-ready dataset
│   └── external/     # External datasets
│
├── sql/
│   ├──sql/
│   │   └── 01-Time_Check.sql        # validation check with time field 
│   ├── 00-Data_Checks.sql           # SQL scripts for extraction
│   ├── 01-Database_Creation.sql     # Copying original table
│   └── 02-Cleaning.sql              # Data cleaning and transformation in SQL
│
├── notebooks/
│   ├── 01-Data_Profiling_original.ipynb
│   └── 02-Data_Profiling_cleaned.ipynb   # Data profiling and deduplication in Python
│
├── docs/
│   ├── data_dictionary.md
│   └── assumptions.md
│
└── README.md
```


## Approach & Methods

### 1. Data Extraction

- Loaded the raw SQLite database and reviewed its schema.
- Assessed field formats, types, and initial data quality.


### 2. Data Cleaning

- Standardized **date** and **time** fields; handled ambiguous two-digit years using `crash ID` ordering.
- Normalized text fields (removed wildcards, harmonized casing).
- Parsed complex string fields (e.g., `aboard`, `fatalities`) into separate numeric columns.
- Converted numeric fields stored as text to integer or float types.
- Identified and removed duplicates using a clear, scalable rule (kept first occurrence based on key fields).
- Addressed missing values by converting `?`, blanks to NULLs.


### 3. Documentation

- Created an enhanced **data dictionary** describing every field, transformations applied, and rationale.
- Compiled all cleaning and processing assumptions in docs/assumptions.md.


### 4. Feature Engineering
- Derived key analytics fields:
    - Crash year (with century disambiguity logic)
    - Month, day, hour (where possible)
    - Total aboard/fatalities/ground casualties
    - Fatality rate
    - Boolean flags for operator type and other categorizations
    - Computed fatality rate as fatalities divided by total aboard.
    - Classified severity of crash based on fatality rate (`None`, `Low`, `High`, or `Total` loss).
    - Parsed summary text to flag likely cause categories (e.g., engine failure, weather).


### 5. Data Profiling & Initial Analysis

- Profiled variables for type, completeness, range, and distribution.
- Summarized missingness across all fields.
- Provided descriptive statistics for numeric variables.
- Counted and categorized unique values for categorical variables.
- Assessed duplicate rates and data consistency.


## What Has Not Been Done (Yet)

- Full advanced EDA (visualization, modeling, or in-depth trend analysis).
- No integration with external/public datasets at this stage.
- No deep text mining/NLP on the summary column (this is noted as a next-step opportunity).
- No predictive modeling or advanced statistical testing included here.


### External Data Sources

- Integrat data from the [FAA Aircraft Registry](https://www.faa.gov/licenses_certificates/aircraft_certification/aircraft_registry/releasable_aircraft_download) to standardize and enrich aircraft make/model fields.

- FAA registry can be used to standardize manufacturer and model names for US-registered aircraft where possible.
- Fuzzy matching was used where exact matches were unavailable.
- Only public, freely available data was used and properly cited.



## Key Data Treatment Decisions & Assumptions

- Used `crash_id` ordering to resolve ambiguous years for date parsing.
- Treated `?` & `-` as missing values.
- For deduplication, kept first occurrence within each key combination (not manually curated on a row-by-row basis).
- Parsed complex columns (e.g., aboard, fatalities) using string logic appropriate for their format.
- All transformations are fully documented in the repo.


## How To Reproduce

1. Place the original SQLite database in `data/raw/`.
1. Run the scripts in order:
    1. `sql/01-Data_Checks.sql` [link](./sql/00-Data_Check.sql)
    1. `sql/01-Database_Creation.sql` [link](./sql/01-Database_Creation.sql)
    1. `sql/02-Cleaning.sql` [link](./sql/02-Cleaning.sql)
    1. `notebooks/02-Data_Profiling_cleaned.ipynb` [link](./notebooks/02-Data_Profiling_cleaned.ipynb)

1. The final cleaned table will be created within the same SQLite database located in `data/raw/`.
    1. table name: `plane_crashes_analytics`
1. Optionally, use the Jupyter notebooks in /notebooks/ for profiling and exploratory data analysis.


## Outputs

- Cleaned dataset: [/data/processed/plane_crashes_final.csv](./data/processed/plane_crashes_final.csv)
- Data dictionary: [/docs/data_dictionary.md](./docs/data_dictionary.md)
- Assumptions log: [/docs/assumptions.md](./docs/assumptions.md)


## Final Note

This repository provides a robust foundation for further analysis and modeling by the data science team. All data treatment steps are reproducible and well-documented for transparency.

For any questions about specific data decisions or requests for enhancements (external data integration, deeper EDA, etc.), please see assumptions or contact the author.

