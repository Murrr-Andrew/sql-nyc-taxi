-- Data quality checks on the raw trips table.
-- Run from the repository root:
--   duckdb data/nyc_taxi.duckdb < sql/01_quality.sql

-- TODO: missing values, invalid amounts and distances, dates outside the loaded months.
