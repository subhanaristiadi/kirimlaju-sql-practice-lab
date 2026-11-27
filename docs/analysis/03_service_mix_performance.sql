-- Business Questions:
-- How do regular, express, and same-day services compare on volume, value,
-- average cost/weight, delivery outcome, and on-time performance?
-- Grain: shipment aggregated by service_type.
-- On-time denominator: delivered shipments with non-NULL actual_delivery.

WITH service AS (
    SELECT
        service_type,
        COUNT(*) AS shipment_volume,
        SUM(total_cost_idr) AS transaction_value_idr,
        AVG(total_cost_idr) AS avg_shipment_cost_idr,
        AVG(weight_kg) AS avg_weight_kg,
        COUNT(*) FILTER (WHERE status = 'delivered') AS delivered_shipments,
        COUNT(*) FILTER (WHERE status = 'lost') AS lost_shipments,
        COUNT(*) FILTER (WHERE status = 'returned') AS returned_shipments,
        COUNT(*) FILTER (
            WHERE status = 'delivered' AND actual_delivery IS NOT NULL
        ) AS valid_delivered_shipments,
        COUNT(*) FILTER (
            WHERE status = 'delivered'
              AND actual_delivery IS NOT NULL
              AND actual_delivery <= estimated_delivery
        ) AS on_time_shipments
    FROM shipments
    GROUP BY service_type
)
SELECT
    service_type,
    shipment_volume,
    transaction_value_idr,
    ROUND(avg_shipment_cost_idr, 2) AS avg_shipment_cost_idr,
    ROUND(avg_weight_kg, 2) AS avg_weight_kg,
    delivered_shipments,
    lost_shipments,
    returned_shipments,
    ROUND(100.0 * delivered_shipments / shipment_volume, 2) AS delivery_rate_pct,
    ROUND(100.0 * lost_shipments / shipment_volume, 2) AS loss_rate_pct,
    ROUND(100.0 * returned_shipments / shipment_volume, 2) AS return_rate_pct,
    on_time_shipments,
    valid_delivered_shipments,
    ROUND(100.0 * on_time_shipments / NULLIF(valid_delivered_shipments, 0), 2) AS on_time_rate_pct
FROM service
ORDER BY shipment_volume DESC;

-- Ranking extension: rank services by volume and transaction value.
WITH service AS (
    SELECT service_type, COUNT(*) AS shipment_volume, SUM(total_cost_idr) AS transaction_value_idr
    FROM shipments
    GROUP BY service_type
)
SELECT
    service_type,
    shipment_volume,
    RANK() OVER (ORDER BY shipment_volume DESC) AS volume_rank,
    transaction_value_idr,
    RANK() OVER (ORDER BY transaction_value_idr DESC) AS value_rank,
    ROUND(100.0 * transaction_value_idr / SUM(transaction_value_idr) OVER (), 2) AS value_share_pct
FROM service
ORDER BY volume_rank;
