-- Loads the raw files into DuckDB without cleaning them.
-- Run from the repository root:
--   duckdb data/nyc_taxi.duckdb < sql/00_load.sql

CREATE OR REPLACE TABLE trips AS
SELECT *
FROM read_parquet(
    'data/raw/yellow_tripdata_*.parquet',
    union_by_name = true,  -- monthly files may differ in columns
    filename = 'source_file'  -- keeps the file each trip came from
);

CREATE OR REPLACE TABLE zones AS
SELECT *
FROM read_csv('data/raw/taxi_zone_lookup.csv', header = true);

SELECT 'trips' AS table_name, COUNT(*) AS row_count FROM trips
UNION ALL
SELECT 'zones', COUNT(*) FROM zones;
