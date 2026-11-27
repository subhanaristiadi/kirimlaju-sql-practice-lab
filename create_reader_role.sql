-- Dokumentasi manual; seed_neon.py membuat role dan password acak secara otomatis.
-- Jalankan sebagai owner pada database kirimlaju baru. Jangan commit password nyata.
CREATE ROLE kirimlaju_reader LOGIN NOSUPERUSER NOCREATEDB NOCREATEROLE NOINHERIT
  PASSWORD 'REPLACE_WITH_A_UNIQUE_STRONG_PASSWORD';
REVOKE CREATE ON SCHEMA public FROM PUBLIC;
GRANT CONNECT ON DATABASE kirimlaju TO kirimlaju_reader;
GRANT USAGE ON SCHEMA public TO kirimlaju_reader;
GRANT SELECT ON customers, routes, shipments, status_history TO kirimlaju_reader;
ALTER ROLE kirimlaju_reader SET default_transaction_read_only = on;
ALTER ROLE kirimlaju_reader SET statement_timeout = '10s';
