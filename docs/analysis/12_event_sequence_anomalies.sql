-- Business Questions:
-- What event sequences are common for problematic shipments, and are there
-- shipments with potentially unusual status ordering?
-- Grain: shipment reconstructed from ordered status_history events.
-- This is an audit heuristic, not a claim that every unusual sequence is invalid.

WITH ordered AS (
    SELECT
        shipment_id,
        status,
        update_timestamp,
        LAG(status) OVER (
            PARTITION BY shipment_id ORDER BY update_timestamp, record_id
        ) AS previous_status,
        LEAD(status) OVER (
            PARTITION BY shipment_id ORDER BY update_timestamp, record_id
        ) AS next_status
    FROM status_history
),
sequence AS (
    SELECT
        shipment_id,
        STRING_AGG(status, ' -> ' ORDER BY update_timestamp) AS event_sequence,
        COUNT(*) AS event_count
    FROM status_history
    GROUP BY shipment_id
)
SELECT
    event_sequence,
    COUNT(*) AS shipment_count
FROM sequence
WHERE event_sequence ILIKE '%failed_delivery%'
   OR event_sequence ILIKE '%returned_to_sender%'
   OR event_sequence ILIKE '%lost%'
GROUP BY event_sequence
ORDER BY shipment_count DESC, event_sequence;

-- Heuristic checks for event-order anomalies:
-- 1) event after a terminal delivered/lost/returned_to_sender event
-- 2) timestamp reversal is structurally prevented by ordering, so repeated
-- timestamps are retained using record_id as deterministic tie-breaker.
WITH ordered AS (
    SELECT
        shipment_id,
        status,
        update_timestamp,
        LAG(status) OVER (
            PARTITION BY shipment_id ORDER BY update_timestamp, record_id
        ) AS previous_status
    FROM status_history
)
SELECT
    shipment_id,
    status,
    previous_status,
    update_timestamp
FROM ordered
WHERE previous_status IN ('delivered', 'lost', 'returned_to_sender')
  AND status NOT IN ('delivered', 'lost', 'returned_to_sender')
ORDER BY shipment_id, update_timestamp;
