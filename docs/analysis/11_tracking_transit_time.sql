-- Business Questions:
-- How long does a shipment take from pickup_confirmed to delivered?
-- What locations/hubs appear most often in tracking events?
-- Grain: shipment for transit duration; event for location frequency.

WITH event_times AS (
    SELECT
        shipment_id,
        MIN(update_timestamp) FILTER (WHERE status = 'pickup_confirmed') AS pickup_confirmed_at,
        MIN(update_timestamp) FILTER (WHERE status = 'delivered') AS delivered_at
    FROM status_history
    GROUP BY shipment_id
),
transit AS (
    SELECT
        shipment_id,
        delivered_at - pickup_confirmed_at AS tracking_transit_interval
    FROM event_times
    WHERE pickup_confirmed_at IS NOT NULL
      AND delivered_at IS NOT NULL
      AND delivered_at >= pickup_confirmed_at
)
SELECT
    COUNT(*) AS shipments_with_pickup_and_delivered_events,
    ROUND(AVG(EXTRACT(EPOCH FROM tracking_transit_interval) / 86400.0), 2)
        AS avg_tracking_transit_days,
    ROUND(
        PERCENTILE_CONT(0.5) WITHIN GROUP (
            ORDER BY EXTRACT(EPOCH FROM tracking_transit_interval) / 86400.0
        ), 2
    ) AS median_tracking_transit_days,
    ROUND(
        MAX(EXTRACT(EPOCH FROM tracking_transit_interval) / 86400.0), 2
    ) AS max_tracking_transit_days
FROM transit;

-- Most frequent tracking locations.
SELECT
    location,
    COUNT(*) AS event_count,
    COUNT(DISTINCT shipment_id) AS shipment_count
FROM status_history
GROUP BY location
ORDER BY event_count DESC, shipment_count DESC;
