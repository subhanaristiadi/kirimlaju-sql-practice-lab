-- Business Questions:
-- Are keys, foreign keys, dates, missing values, and shipment/tracking states consistent?
-- Grain varies by audit; each check is independent.

-- Primary-key duplicate checks.
SELECT 'customers.customer_id' AS key_name, COUNT(*) - COUNT(DISTINCT customer_id) AS duplicate_rows FROM customers
UNION ALL
SELECT 'routes.route_id', COUNT(*) - COUNT(DISTINCT route_id) FROM routes
UNION ALL
SELECT 'shipments.shipment_id', COUNT(*) - COUNT(DISTINCT shipment_id) FROM shipments
UNION ALL
SELECT 'shipments.tracking_number', COUNT(*) - COUNT(DISTINCT tracking_number) FROM shipments
UNION ALL
SELECT 'status_history.record_id', COUNT(*) - COUNT(DISTINCT record_id) FROM status_history;

-- Foreign-key mismatch checks.
SELECT COUNT(*) AS shipments_missing_customer
FROM shipments s
LEFT JOIN customers c ON c.customer_id = s.customer_id
WHERE c.customer_id IS NULL;

SELECT COUNT(*) AS shipments_missing_route
FROM shipments s
LEFT JOIN routes r ON r.route_id = s.route_id
WHERE r.route_id IS NULL;

SELECT COUNT(*) AS tracking_events_missing_shipment
FROM status_history h
LEFT JOIN shipments s ON s.shipment_id = h.shipment_id
WHERE s.shipment_id IS NULL;

-- Missing-value audit.
SELECT
    COUNT(*) FILTER (WHERE actual_delivery IS NULL) AS shipments_missing_actual_delivery,
    COUNT(*) FILTER (WHERE total_cost_idr IS NULL) AS shipments_missing_transaction_value,
    COUNT(*) FILTER (WHERE weight_kg IS NULL) AS shipments_missing_weight,
    COUNT(*) FILTER (WHERE tracking_number IS NULL) AS shipments_missing_tracking_number
FROM shipments;

SELECT
    COUNT(*) FILTER (WHERE notes IS NULL) AS status_events_missing_notes,
    COUNT(*) AS total_status_events
FROM status_history;

-- Documented anomaly: delivered with NULL actual_delivery.
SELECT
    status,
    COUNT(*) AS shipment_count
FROM shipments
WHERE actual_delivery IS NULL
GROUP BY status
ORDER BY shipment_count DESC;

SELECT COUNT(*) AS delivered_without_actual_delivery
FROM shipments
WHERE status = 'delivered'
  AND actual_delivery IS NULL;

-- Date sanity checks.
SELECT
    COUNT(*) FILTER (WHERE estimated_delivery < pickup_date) AS estimated_before_pickup,
    COUNT(*) FILTER (WHERE actual_delivery < pickup_date) AS actual_before_pickup
FROM shipments;

-- Tracking coverage.
SELECT
    COUNT(*) AS total_shipments,
    COUNT(DISTINCT h.shipment_id) AS shipments_with_tracking,
    COUNT(*) - COUNT(DISTINCT h.shipment_id) AS shipments_without_tracking
FROM shipments s
LEFT JOIN status_history h ON h.shipment_id = s.shipment_id;
