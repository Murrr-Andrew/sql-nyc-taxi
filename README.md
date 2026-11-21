# SQL analysis of NYC Yellow Taxi trips

> **Status: in progress.** The data setup is ready. Quality checks, queries and findings are being added.

Business questions answered with SQL on real NYC taxi trip records, using DuckDB directly on Parquet files.

## Stack

`SQL` · `DuckDB` · `Parquet`

## Data

- [NYC TLC Trip Record Data](https://www.nyc.gov/site/tlc/about/tlc-trip-record-data.page): Yellow Taxi trips for July–September 2026: 10.7 million rows, about 190 MB of Parquet.
- Taxi Zone Lookup: maps pickup and dropoff location IDs to boroughs and zones.

The data is not stored in this repository. `scripts/download.sh` fetches it from the official source.

## Quick start

Requires [DuckDB](https://duckdb.org/docs/installation/) and `curl`.

```bash
bash scripts/download.sh
duckdb data/nyc_taxi.duckdb < sql/00_load.sql
```

## Project structure

```text
.
├── scripts/download.sh   # downloads the raw files into data/raw/
├── sql/
│   ├── 00_load.sql       # loads raw files into DuckDB tables
│   └── 01_quality.sql    # data quality checks
├── queries/              # one .sql file per business question
└── data/                 # local only, ignored by git
```

## Roadmap

- [x] Download and load the data
- [ ] Check data quality: missing values, invalid amounts and distances, out-of-range dates
- [ ] Answer 10 business questions, one `.sql` file each
- [ ] Use window functions in at least 3 queries
- [ ] Add a results table: question, answer, SQL technique

## Findings

Coming as the queries are completed.
