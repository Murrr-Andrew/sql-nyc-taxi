-- Data quality checks on the raw trips table.
-- Run from the repository root:
--   duckdb -readonly data/nyc_taxi.duckdb < sql/01_quality.sql


-- Check 1: does total_amount equal the sum of its nine money columns?
-- Why: revenue questions rely on total_amount, so its parts must add up.
-- Notes: a missing fee counts as 0; diff is rounded to cents because DOUBLE is approximate.

WITH trip_diffs AS (
    SELECT
        VendorID,
        ROUND(
            total_amount - (
                fare_amount
                + extra
                + mta_tax
                + tip_amount
                + tolls_amount
                + improvement_surcharge
                + COALESCE(congestion_surcharge, 0)
                + COALESCE(Airport_fee, 0)
                + cbd_congestion_fee
            ),
            2
        ) AS diff
    FROM trips
)
SELECT
    VendorID,
    COUNT(*) AS trips,
    COUNT(*) FILTER (WHERE diff = 0) AS matches,
    COUNT(*) FILTER (WHERE diff <> 0) AS mismatches,
    ROUND(COUNT(*) FILTER (WHERE diff = 0) * 100.0 / COUNT(*), 1) AS match_pct
FROM trip_diffs
GROUP BY VendorID
ORDER BY VendorID;


-- Check 2: do mismatches depend on the vendor, missing fees and how fees are counted?
-- Why: Test whether some vendors already include fees in `extra`, which would count them twice.
-- Finding: With fees recorded, Vendor 1 matches total_amount on 100.0% of trips using six columns,
-- and Vendor 2 on 99.9% using all nine. So Vendor 1 already includes the fees in `extra`.
-- 3,081,321 trips (28.7%) have no recorded fees, and neither formula reliably matches them.
-- Vendors 6 and 7 (1.4% of trips) remain unexplained.
-- Decision: use total_amount for revenue; do not rebuild it from parts or compare `extra` across vendors.

WITH trip_diffs AS (
    SELECT
        VendorID,
        Airport_fee IS NULL AS fees_missing,
        ROUND(
            total_amount - (
                fare_amount
                + extra
                + mta_tax
                + tip_amount
                + tolls_amount
                + improvement_surcharge
                + COALESCE(congestion_surcharge, 0)
                + COALESCE(Airport_fee, 0)
                + cbd_congestion_fee
            ),
            2
        ) AS diff_nine,
        ROUND(
            total_amount - (
                fare_amount
                + extra
                + mta_tax
                + tip_amount
                + tolls_amount
                + improvement_surcharge
            ),
            2
        ) AS diff_six
    FROM trips
)
SELECT
    VendorID,
    fees_missing,
    COUNT(*) AS trips,
    ROUND(COUNT(*) FILTER (WHERE diff_nine = 0) * 100.0 / COUNT(*), 1) AS match_nine_pct,
    ROUND(COUNT(*) FILTER (WHERE diff_six = 0) * 100.0 / COUNT(*), 1) AS match_six_pct
FROM trip_diffs
GROUP BY VendorID, fees_missing
ORDER BY VendorID, fees_missing;
-- TODO: missing values, invalid amounts and distances, dates outside the loaded months.
