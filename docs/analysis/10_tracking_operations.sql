-- Business Questions:
-- What is the tracking-event profile, which events are common, and how many
-- shipments experience failed delivery?
-- Grain: event for event counts; shipment for shipment-level metrics.

SELECT
    status AS event_status,
    COUNT(*) AS event_count,
    COUNT(DISTINCT shipment_id) AS affected_shipments
FROM status_history
GROUP BY status
ORDER BY event_count DESC;

SELECT
    ROUND(AVG(event_count), 2) AS avg_events_per_shipment,
    MIN(event_count) AS min_events_per_shipment,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY event_count) AS median_events_per_shipment,
    MAX(event_count) AS max_events_per_shipment
FROM (
    SELECT shipment_id, COUNT(*) AS event_count
    FROM status_history
    GROUP BY shipment_id
) x;

-- Shipment-level failed-delivery exposure.
WITH failed AS (
    SELECT
        shipment_id,
        COUNT(*) AS failed_delivery_events,
        MIN(update_timestamp) AS first_failed_delivery_at
    FROM status_history
    WHERE status = 'failed_delivery'
    GROUP BY shipment_id
)
SELECT
    COUNT(*) AS shipments_with_failed_delivery,
    SUM(failed_delivery_events) AS failed_delivery_event_count,
    ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM shipments), 2) AS pct_of_all_shipments
FROM failed;
