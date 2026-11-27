-- Business Question:
-- What are total shipment volume, transaction value, average shipment cost,
-- average weight, and overall delivery/loss/return rates?
-- Grain: shipment.
-- Rate denominator: all shipments for delivery/loss/return rates.
-- Delivery rate uses shipment status = 'delivered'.

SELECT
    COUNT(DISTINCT shipment_id) AS total_shipments,
    SUM(total_cost_idr) AS total_transaction_value_idr,
    ROUND(AVG(total_cost_idr), 2) AS avg_shipment_cost_idr,
    ROUND(AVG(weight_kg), 2) AS avg_weight_kg,
    COUNT(*) FILTER (WHERE status = 'delivered') AS delivered_shipments,
    COUNT(*) FILTER (WHERE status = 'lost') AS lost_shipments,
    COUNT(*) FILTER (WHERE status = 'returned') AS returned_shipments,
    ROUND(
        100.0 * COUNT(*) FILTER (WHERE status = 'delivered')
        / NULLIF(COUNT(*), 0), 2
    ) AS delivery_rate_pct,
    ROUND(
        100.0 * COUNT(*) FILTER (WHERE status = 'lost')
        / NULLIF(COUNT(*), 0), 2
    ) AS loss_rate_pct,
    ROUND(
        100.0 * COUNT(*) FILTER (WHERE status = 'returned')
        / NULLIF(COUNT(*), 0), 2
    ) AS return_rate_pct
FROM shipments;

-- Validation: status counts should reconcile to shipment volume.
SELECT status, COUNT(*) AS shipment_count
FROM shipments
GROUP BY status
ORDER BY shipment_count DESC;
