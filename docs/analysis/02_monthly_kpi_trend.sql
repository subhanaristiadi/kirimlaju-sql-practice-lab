-- Business Question:
-- How do shipment KPIs change month to month?
-- Grain: shipment-month based on pickup_date.
-- Rates use all shipments in each pickup month.

SELECT
    DATE_TRUNC('month', pickup_date)::date AS pickup_month,
    COUNT(*) AS shipment_volume,
    SUM(total_cost_idr) AS transaction_value_idr,
    ROUND(AVG(total_cost_idr), 2) AS avg_shipment_cost_idr,
    ROUND(AVG(weight_kg), 2) AS avg_weight_kg,
    COUNT(*) FILTER (WHERE status = 'delivered') AS delivered_shipments,
    COUNT(*) FILTER (WHERE status = 'lost') AS lost_shipments,
    COUNT(*) FILTER (WHERE status = 'returned') AS returned_shipments,
    ROUND(100.0 * COUNT(*) FILTER (WHERE status = 'delivered') / COUNT(*), 2) AS delivery_rate_pct,
    ROUND(100.0 * COUNT(*) FILTER (WHERE status = 'lost') / COUNT(*), 2) AS loss_rate_pct,
    ROUND(100.0 * COUNT(*) FILTER (WHERE status = 'returned') / COUNT(*), 2) AS return_rate_pct
FROM shipments
GROUP BY 1
ORDER BY 1;

-- Window-function extension: month-over-month shipment change.
WITH monthly AS (
    SELECT
        DATE_TRUNC('month', pickup_date)::date AS pickup_month,
        COUNT(*) AS shipment_volume,
        SUM(total_cost_idr) AS transaction_value_idr
    FROM shipments
    GROUP BY 1
)
SELECT
    pickup_month,
    shipment_volume,
    shipment_volume - LAG(shipment_volume) OVER (ORDER BY pickup_month) AS mom_volume_change,
    ROUND(
        100.0 * (shipment_volume - LAG(shipment_volume) OVER (ORDER BY pickup_month))
        / NULLIF(LAG(shipment_volume) OVER (ORDER BY pickup_month), 0), 2
    ) AS mom_volume_change_pct,
    transaction_value_idr,
    transaction_value_idr - LAG(transaction_value_idr) OVER (ORDER BY pickup_month) AS mom_value_change_idr
FROM monthly
ORDER BY pickup_month;
