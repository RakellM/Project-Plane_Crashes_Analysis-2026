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
│   └── processed/    # Cleaned analysis-ready dataset
│
├── notebooks/
│   ├── 01_extraction.ipynb
│   ├── 02_cleaning.ipynb
│   ├── 03_feature_engineering.ipynb
│   └── 04_eda.ipynb
│
├── docs/
│   ├── data_dictionary.md
│   └── assumptions.md
│
└── README.md
```


## Workflow Summary

### 1. Data Extraction

- Connected to SQLite database
- Reviewed schema and table structure
- Loaded data into analytical environment


### 2. Data Profiling

- Assessed data types and consistency
- Evaluated missingness
- Identified duplicates
- Reviewed categorical and text fields


### 3. Data Cleaning

- Standardized date, numeric, and categorical formats
- Normalized text fields
- Addressed missing values
- Removed or resolved duplicate records


### 4. Feature Engineering

- Derived variables include:
- Crash year, month, quarter
- Total casualties
- Fatality rate
- Severity classification
- Categorized cause (parsed from narrative text)


### 5. Exploratory Data Analysis

- Temporal trends
- Geographic distribution
- Aircraft type patterns
- Severity and cause analysis



## Documentation

The repository includes:

- Updated data dictionary
- Data treatment decisions and assumptions
- Clean, reproducible workflow



## Reproducibility

To reproduce:

1. Clone repository
1. Install required packages
1. Run notebooks in numerical order
1. Processed dataset will be generated in `/data/processed/`



### Notes

- Raw data files remain unmodified.
- All transformations are documented.
- Any assumptions made during cleaning are recorded in `/docs/assumptions.md`.

