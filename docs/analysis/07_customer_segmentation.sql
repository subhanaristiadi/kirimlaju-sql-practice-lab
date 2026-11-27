-- Business Questions:
-- How do business vs individual customers differ in shipment volume, value,
-- frequency, and delivery outcome?
-- Grain: first aggregate shipments to customer, then aggregate customer metrics.
-- This avoids treating multiple shipments from one customer as independent customers.

WITH customer_shipments AS (
    SELECT
        c.customer_id,
        c.customer_type,
        COUNT(s.shipment_id) AS shipment_volume,
        SUM(s.total_cost_idr) AS transaction_value_idr,
        AVG(s.total_cost_idr) AS avg_shipment_cost_idr,
        COUNT(*) FILTER (WHERE s.status = 'delivered') AS delivered_shipments,
        COUNT(*) FILTER (
            WHERE s.status = 'delivered' AND s.actual_delivery IS NOT NULL
        ) AS valid_delivered_shipments,
        COUNT(*) FILTER (
            WHERE s.status = 'delivered'
              AND s.actual_delivery IS NOT NULL
              AND s.actual_delivery <= s.estimated_delivery
        ) AS on_time_shipments
    FROM customers c
    LEFT JOIN shipments s ON s.customer_id = c.customer_id
    GROUP BY c.customer_id, c.customer_type
),
segment AS (
    SELECT
        customer_type,
        COUNT(*) FILTER (WHERE shipment_volume > 0) AS active_customers,
        SUM(shipment_volume) AS shipment_volume,
        SUM(transaction_value_idr) AS transaction_value_idr,
        AVG(shipment_volume) FILTER (WHERE shipment_volume > 0) AS avg_shipments_per_active_customer,
        AVG(transaction_value_idr) FILTER (WHERE shipment_volume > 0) AS avg_value_per_active_customer,
        SUM(delivered_shipments) AS delivered_shipments,
        SUM(valid_delivered_shipments) AS valid_delivered_shipments,
        SUM(on_time_shipments) AS on_time_shipments
    FROM customer_shipments
    GROUP BY customer_type
)
SELECT
    customer_type,
    active_customers,
    shipment_volume,
    transaction_value_idr,
    ROUND(avg_shipments_per_active_customer, 2) AS avg_shipments_per_active_customer,
    ROUND(avg_value_per_active_customer, 2) AS avg_value_per_active_customer,
    ROUND(100.0 * delivered_shipments / NULLIF(shipment_volume, 0), 2) AS delivery_rate_pct,
    ROUND(100.0 * on_time_shipments / NULLIF(valid_delivered_shipments, 0), 2) AS on_time_rate_pct
FROM segment
ORDER BY transaction_value_idr DESC;

-- Customer value/frequency ranking.
WITH customer AS (
    SELECT
        c.customer_id,
        c.name,
        c.customer_type,
        COUNT(s.shipment_id) AS shipment_volume,
        COALESCE(SUM(s.total_cost_idr), 0) AS transaction_value_idr
    FROM customers c
    LEFT JOIN shipments s ON s.customer_id = c.customer_id
    GROUP BY c.customer_id, c.name, c.customer_type
)
SELECT
    customer_id,
    name,
    customer_type,
    shipment_volume,
    transaction_value_idr,
    DENSE_RANK() OVER (ORDER BY shipment_volume DESC) AS volume_rank,
    DENSE_RANK() OVER (ORDER BY transaction_value_idr DESC) AS value_rank,
    ROUND(
        100.0 * transaction_value_idr / NULLIF(SUM(transaction_value_idr) OVER (), 0), 2
    ) AS value_share_pct
FROM customer
WHERE shipment_volume > 0
ORDER BY value_rank, volume_rank;
