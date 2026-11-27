-- KIRIMLAJU PostgreSQL 16 schema
-- Source of truth: KIRIMLAJU data reference and supplied CSV files.

CREATE TABLE customers (
    customer_id       text PRIMARY KEY,
    name              text,
    customer_type     text,
    email             text,
    phone             text,
    address           text,
    city              text,
    province          text,
    registration_date date
);

CREATE TABLE routes (
    route_id                 text PRIMARY KEY,
    origin_city              text,
    destination_city         text,
    distance_km              integer,
    estimated_days_regular   integer,
    estimated_days_express   integer,
    price_per_kg_regular     integer,
    price_per_kg_express     integer
);

CREATE TABLE shipments (
    shipment_id          text PRIMARY KEY,
    customer_id          text NOT NULL,
    route_id             text NOT NULL,
    origin_address       text,
    destination_address  text,
    weight_kg             numeric,
    package_type         text,
    service_type         text,
    pickup_date          date,
    estimated_delivery   date,
    actual_delivery      date,
    status                text,
    total_cost_idr       integer,
    tracking_number      text,
    CONSTRAINT fk_shipments_customer
        FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    CONSTRAINT fk_shipments_route
        FOREIGN KEY (route_id) REFERENCES routes(route_id)
);

CREATE TABLE status_history (
    record_id        text PRIMARY KEY,
    shipment_id      text NOT NULL,
    status           text,
    update_timestamp timestamp,
    location         text,
    notes            text,
    CONSTRAINT fk_status_history_shipment
        FOREIGN KEY (shipment_id) REFERENCES shipments(shipment_id)
);

CREATE INDEX idx_shipments_customer_id ON shipments(customer_id);
CREATE INDEX idx_shipments_route_id ON shipments(route_id);
CREATE INDEX idx_shipments_pickup_date ON shipments(pickup_date);
CREATE INDEX idx_shipments_service_type ON shipments(service_type);
CREATE INDEX idx_status_history_shipment_id ON status_history(shipment_id);
CREATE INDEX idx_status_history_timestamp ON status_history(update_timestamp);
