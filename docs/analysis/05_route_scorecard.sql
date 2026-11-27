-- Business Questions:
-- Which routes lead on volume/value, and which have weak SLA, loss, or return outcomes?
-- Grain: shipment aggregated to route.
-- On-time denominator: delivered shipments with valid actual_delivery.

WITH route_shipments AS (
    SELECT
        s.route_id,
        r.origin_city,
        r.destination_city,
        r.distance_km,
        COUNT(*) AS shipment_volume,
        SUM(s.total_cost_idr) AS transaction_value_idr,
        AVG(s.total_cost_idr) AS avg_shipment_cost_idr,
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
    JOIN routes r ON r.route_id = s.route_id
    GROUP BY s.route_id, r.origin_city, r.destination_city, r.distance_km
)
SELECT
    route_id,
    origin_city,
    destination_city,
    distance_km,
    shipment_volume,
    transaction_value_idr,
    ROUND(avg_shipment_cost_idr, 2) AS avg_shipment_cost_idr,
    ROUND(100.0 * delivered_shipments / shipment_volume, 2) AS delivery_rate_pct,
    ROUND(100.0 * lost_shipments / shipment_volume, 2) AS loss_rate_pct,
    ROUND(100.0 * returned_shipments / shipment_volume, 2) AS return_rate_pct,
    valid_delivered_shipments,
    on_time_shipments,
    ROUND(100.0 * on_time_shipments / NULLIF(valid_delivered_shipments, 0), 2) AS on_time_rate_pct
FROM route_shipments
ORDER BY shipment_volume DESC, transaction_value_idr DESC;

-- Top/bottom route ranking with minimum volume threshold to avoid tiny-sample extremes.
WITH route AS (
    SELECT
        s.route_id,
        COUNT(*) AS shipment_volume,
        SUM(s.total_cost_idr) AS transaction_value_idr,
        COUNT(*) FILTER (
            WHERE s.status = 'delivered' AND s.actual_delivery IS NOT NULL
        ) AS valid_delivered_shipments,
        COUNT(*) FILTER (
            WHERE s.status = 'delivered'
              AND s.actual_delivery IS NOT NULL
              AND s.actual_delivery <= s.estimated_delivery
        ) AS on_time_shipments
    FROM shipments s
    GROUP BY s.route_id
)
SELECT
    route_id,
    shipment_volume,
    transaction_value_idr,
    ROUND(100.0 * on_time_shipments / NULLIF(valid_delivered_shipments, 0), 2) AS on_time_rate_pct,
    RANK() OVER (ORDER BY transaction_value_idr DESC) AS value_rank,
    RANK() OVER (ORDER BY
        1.0 * on_time_shipments / NULLIF(valid_delivered_shipments, 0) DESC
    ) AS on_time_rank
FROM route
WHERE shipment_volume >= 20
ORDER BY on_time_rate_pct DESC;
