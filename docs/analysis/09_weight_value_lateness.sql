-- Business Question:
-- Do heavier shipments tend to have higher transaction value or greater lateness?
-- Grain: valid delivered shipment for SLA metrics.
-- Correlation is descriptive association, not causation.

WITH delivered AS (
    SELECT
        weight_kg,
        total_cost_idr,
        (actual_delivery - estimated_delivery) AS lateness_days
    FROM shipments
    WHERE status = 'delivered'
      AND actual_delivery IS NOT NULL
)
SELECT
    COUNT(*) AS valid_delivered_shipments,
    ROUND(CORR(weight_kg::numeric, total_cost_idr::numeric), 4)
        AS corr_weight_value,
    ROUND(CORR(weight_kg::numeric, lateness_days::numeric), 4)
        AS corr_weight_lateness,
    ROUND(AVG(weight_kg), 2) AS avg_weight_kg,
    ROUND(AVG(total_cost_idr), 2) AS avg_transaction_value_idr,
    ROUND(AVG(lateness_days), 2) AS avg_lateness_days
FROM delivered;

-- Weight bands to complement the correlation.
WITH delivered AS (
    SELECT
        weight_kg,
        total_cost_idr,
        (actual_delivery - estimated_delivery) AS lateness_days
    FROM shipments
    WHERE status = 'delivered'
      AND actual_delivery IS NOT NULL
),
banded AS (
    SELECT *,
        CASE
            WHEN weight_kg < 1 THEN '<1 kg'
            WHEN weight_kg < 5 THEN '1-4.99 kg'
            WHEN weight_kg < 10 THEN '5-9.99 kg'
            WHEN weight_kg < 25 THEN '10-24.99 kg'
            ELSE '25+ kg'
        END AS weight_band
    FROM delivered
)
SELECT
    weight_band,
    COUNT(*) AS valid_delivered_shipments,
    ROUND(AVG(total_cost_idr), 2) AS avg_transaction_value_idr,
    ROUND(AVG(lateness_days), 2) AS avg_lateness_days,
    ROUND(100.0 * COUNT(*) FILTER (WHERE lateness_days <= 0) / COUNT(*), 2) AS on_time_rate_pct
FROM banded
GROUP BY weight_band
ORDER BY MIN(weight_kg);
