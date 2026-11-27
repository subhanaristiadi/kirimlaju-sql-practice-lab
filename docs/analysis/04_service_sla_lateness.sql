-- Business Questions:
-- Which services have the best on-time rate and what is the lateness profile?
-- Grain: delivered shipment with valid actual_delivery.
-- Lateness = actual_delivery - estimated_delivery, in days.

WITH delivered AS (
    SELECT
        shipment_id,
        service_type,
        actual_delivery - estimated_delivery AS lateness_days
    FROM shipments
    WHERE status = 'delivered'
      AND actual_delivery IS NOT NULL
),
service AS (
    SELECT
        service_type,
        COUNT(*) AS valid_delivered_shipments,
        COUNT(*) FILTER (WHERE lateness_days <= 0) AS on_time_shipments,
        COUNT(*) FILTER (WHERE lateness_days > 0) AS late_shipments,
        AVG(lateness_days) AS avg_lateness_days,
        PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY lateness_days) AS median_lateness_days,
        MAX(lateness_days) AS max_lateness_days
    FROM delivered
    GROUP BY service_type
)
SELECT
    service_type,
    valid_delivered_shipments,
    on_time_shipments,
    late_shipments,
    ROUND(100.0 * on_time_shipments / valid_delivered_shipments, 2) AS on_time_rate_pct,
    ROUND(avg_lateness_days, 2) AS avg_lateness_days,
    median_lateness_days AS median_lateness_days,
    max_lateness_days
FROM service
ORDER BY on_time_rate_pct DESC;
