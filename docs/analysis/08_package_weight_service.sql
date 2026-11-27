-- Business Questions:
-- How do package types differ in volume/value/weight, and what services do they use?
-- Grain: shipment aggregated by package_type.
-- Weight outliers are described statistically within package type; no business
-- threshold is assumed.

SELECT
    package_type,
    COUNT(*) AS shipment_volume,
    SUM(total_cost_idr) AS transaction_value_idr,
    ROUND(AVG(weight_kg), 2) AS avg_weight_kg,
    ROUND(MIN(weight_kg), 2) AS min_weight_kg,
    ROUND(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY weight_kg), 2) AS median_weight_kg,
    ROUND(PERCENTILE_CONT(0.95) WITHIN GROUP (ORDER BY weight_kg), 2) AS p95_weight_kg,
    ROUND(MAX(weight_kg), 2) AS max_weight_kg
FROM shipments
GROUP BY package_type
ORDER BY shipment_volume DESC;

-- Service mix within each package type.
SELECT
    package_type,
    COUNT(*) AS shipment_volume,
    COUNT(*) FILTER (WHERE service_type = 'regular') AS regular_shipments,
    COUNT(*) FILTER (WHERE service_type = 'express') AS express_shipments,
    COUNT(*) FILTER (WHERE service_type = 'same_day') AS same_day_shipments,
    ROUND(
        100.0 * COUNT(*) FILTER (WHERE service_type = 'express') / COUNT(*), 2
    ) AS express_share_pct,
    ROUND(
        100.0 * COUNT(*) FILTER (WHERE service_type = 'same_day') / COUNT(*), 2
    ) AS same_day_share_pct
FROM shipments
GROUP BY package_type
ORDER BY shipment_volume DESC;

-- Potential statistical weight outliers: above the package-type P95.
WITH stats AS (
    SELECT
        package_type,
        PERCENTILE_CONT(0.95) WITHIN GROUP (ORDER BY weight_kg) AS p95_weight_kg
    FROM shipments
    GROUP BY package_type
)
SELECT
    s.shipment_id,
    s.package_type,
    s.weight_kg,
    st.p95_weight_kg,
    s.service_type,
    s.total_cost_idr
FROM shipments s
JOIN stats st ON st.package_type = s.package_type
WHERE s.weight_kg > st.p95_weight_kg
ORDER BY s.package_type, s.weight_kg DESC;
