-- Business Question:
-- Is route distance associated with actual delivery duration or SLA lateness?
-- Grain: valid delivered shipment joined to its route.
-- This is association analysis, not proof of causation.

WITH delivered AS (
    SELECT
        s.shipment_id,
        s.route_id,
        r.distance_km,
        (s.actual_delivery - s.pickup_date) AS delivery_duration_days,
        (s.actual_delivery - s.estimated_delivery) AS lateness_days
    FROM shipments s
    JOIN routes r ON r.route_id = s.route_id
    WHERE s.status = 'delivered'
      AND s.actual_delivery IS NOT NULL
)
SELECT
    COUNT(*) AS valid_delivered_shipments,
    ROUND(CORR(distance_km::numeric, delivery_duration_days::numeric), 4)
        AS corr_distance_duration,
    ROUND(CORR(distance_km::numeric, lateness_days::numeric), 4)
        AS corr_distance_lateness,
    ROUND(AVG(distance_km), 2) AS avg_distance_km,
    ROUND(AVG(delivery_duration_days), 2) AS avg_delivery_duration_days,
    ROUND(AVG(lateness_days), 2) AS avg_lateness_days
FROM delivered;

-- Distance bands for a more interpretable operational view.
WITH delivered AS (
    SELECT
        r.distance_km,
        (s.actual_delivery - s.pickup_date) AS delivery_duration_days,
        (s.actual_delivery - s.estimated_delivery) AS lateness_days
    FROM shipments s
    JOIN routes r ON r.route_id = s.route_id
    WHERE s.status = 'delivered'
      AND s.actual_delivery IS NOT NULL
),
banded AS (
    SELECT *,
        CASE
            WHEN distance_km < 250 THEN '<250 km'
            WHEN distance_km < 500 THEN '250-499 km'
            WHEN distance_km < 1000 THEN '500-999 km'
            ELSE '1000+ km'
        END AS distance_band
    FROM delivered
)
SELECT
    distance_band,
    COUNT(*) AS valid_delivered_shipments,
    ROUND(AVG(delivery_duration_days), 2) AS avg_delivery_duration_days,
    ROUND(AVG(lateness_days), 2) AS avg_lateness_days,
    ROUND(100.0 * COUNT(*) FILTER (WHERE lateness_days <= 0) / COUNT(*), 2) AS on_time_rate_pct
FROM banded
GROUP BY distance_band
ORDER BY MIN(distance_km);
