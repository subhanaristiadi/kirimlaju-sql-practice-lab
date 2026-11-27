-- Business Question:
-- What is the potential KPI impact of the delivered shipments whose actual_delivery is NULL?
-- Grain: shipment.
-- This analysis compares the documented/observed anomaly against the valid delivered
-- population. NULL actual_delivery is not reclassified as lost/returned.

WITH delivered AS (
    SELECT
        shipment_id,
        actual_delivery,
        estimated_delivery
    FROM shipments
    WHERE status = 'delivered'
),
summary AS (
    SELECT
        COUNT(*) AS all_delivered_status_shipments,
        COUNT(*) FILTER (WHERE actual_delivery IS NOT NULL) AS valid_delivered_shipments,
        COUNT(*) FILTER (WHERE actual_delivery IS NULL) AS delivered_missing_actual,
        COUNT(*) FILTER (
            WHERE actual_delivery IS NOT NULL
              AND actual_delivery <= estimated_delivery
        ) AS on_time_valid_delivered,
        COUNT(*) FILTER (
            WHERE actual_delivery IS NOT NULL
              AND actual_delivery > estimated_delivery
        ) AS late_valid_delivered
    FROM delivered
)
SELECT
    all_delivered_status_shipments,
    valid_delivered_shipments,
    delivered_missing_actual,
    on_time_valid_delivered,
    late_valid_delivered,
    ROUND(
        100.0 * on_time_valid_delivered / NULLIF(valid_delivered_shipments, 0), 2
    ) AS on_time_rate_valid_population_pct,
    ROUND(
        100.0 * delivered_missing_actual / NULLIF(all_delivered_status_shipments, 0), 2
    ) AS delivered_missing_actual_pct
FROM summary;

-- Sensitivity range: if anomalous delivered rows were excluded vs counted in the
-- denominator with no on-time classification, the on-time rate cannot be assigned
-- without inventing delivery dates. The query exposes both denominators explicitly.
WITH x AS (
    SELECT
        COUNT(*) FILTER (WHERE status = 'delivered') AS delivered_status_count,
        COUNT(*) FILTER (
            WHERE status = 'delivered' AND actual_delivery IS NOT NULL
        ) AS valid_delivered_count,
        COUNT(*) FILTER (
            WHERE status = 'delivered'
              AND actual_delivery IS NOT NULL
              AND actual_delivery <= estimated_delivery
        ) AS on_time_count
    FROM shipments
)
SELECT
    delivered_status_count,
    valid_delivered_count,
    on_time_count,
    delivered_status_count - valid_delivered_count AS excluded_missing_actual,
    ROUND(100.0 * on_time_count / NULLIF(valid_delivered_count, 0), 2) AS on_time_rate_excluding_missing_actual_pct,
    ROUND(100.0 * on_time_count / NULLIF(delivered_status_count, 0), 2) AS lower_bound_if_missing_actual_not_on_time_pct
FROM x;
