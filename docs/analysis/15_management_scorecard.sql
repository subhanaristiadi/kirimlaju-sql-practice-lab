-- Business Questions:
-- How can volume, transaction value, SLA, loss, and return be combined into an
-- operations scorecard without collapsing distinct metric definitions?
-- Grain: service x month. Metrics retain separate denominators.

WITH base AS (
    SELECT
        DATE_TRUNC('month', s.pickup_date)::date AS pickup_month,
        s.service_type,
        COUNT(*) AS shipment_volume,
        SUM(s.total_cost_idr) AS transaction_value_idr,
        COUNT(*) FILTER (WHERE s.status = 'delivered') AS delivered_shipments,
        COUNT(*) FILTER (WHERE s.status = 'lost') AS lost_shipments,
        COUNT(*) FILTER (WHERE s.status = 'returned') AS returned_shipments,
        COUNT(*) FILTER (
            WHERE s.status = 'delivered' AND s.actual_delivery IS NOT NULL
        ) AS valid_delivered_shipments,
        COUNT(*) FILTER (
            WHERE s.status = 'delivered'
              AND s.actual_delivery IS NOT NULL
              AND s.actual_delivery <= s.estimated_delivery
        ) AS on_time_shipments
    FROM shipments s
    GROUP BY 1, 2
)
SELECT
    pickup_month,
    service_type,
    shipment_volume,
    transaction_value_idr,
    delivered_shipments,
    lost_shipments,
    returned_shipments,
    valid_delivered_shipments,
    on_time_shipments,
    ROUND(100.0 * delivered_shipments / shipment_volume, 2) AS delivery_rate_pct,
    ROUND(100.0 * lost_shipments / shipment_volume, 2) AS loss_rate_pct,
    ROUND(100.0 * returned_shipments / shipment_volume, 2) AS return_rate_pct,
    ROUND(100.0 * on_time_shipments / NULLIF(valid_delivered_shipments, 0), 2) AS on_time_rate_pct,
    RANK() OVER (
        PARTITION BY pickup_month
        ORDER BY shipment_volume DESC
    ) AS monthly_volume_rank,
    ROUND(
        100.0 * transaction_value_idr
        / SUM(transaction_value_idr) OVER (PARTITION BY pickup_month), 2
    ) AS monthly_value_share_pct
FROM base
ORDER BY pickup_month, monthly_volume_rank;
