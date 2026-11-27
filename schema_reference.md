# KIRIMLAJU — Data Reference

## Dataset Overview
KIRIMLAJU adalah dataset simulasi bisnis perusahaan kurir/pengiriman fiktif di Indonesia dari NgulikData.

Source: https://ngulikdata.com/datasets/kirimlaju

Dataset terdiri dari 4 tabel, 17.427 baris total.

## 1. customers
**Grain:** 1 baris = 1 customer
**Rows:** 600
**Columns:** 9

| Column | Type | Meaning |
|---|---|---|
| customer_id | text | Primary key, CUS0001–CUS0600 |
| name | text | Nama pelanggan |
| customer_type | text | business / individual |
| email | text | Email pelanggan |
| phone | text | Nomor telepon |
| address | text | Alamat |
| city | text | Kota domisili |
| province | text | Provinsi |
| registration_date | date | Tanggal registrasi |

Observed composition: 400 business, 200 individual. Registration dates pada data yang diberikan berada sekitar 2020–2024.

## 2. routes
**Grain:** 1 baris = 1 route
**Rows:** 80
**Columns:** 8

| Column | Type | Meaning |
|---|---|---|
| route_id | text | Primary key, RTE001–RTE080 |
| origin_city | text | Kota asal |
| destination_city | text | Kota tujuan |
| distance_km | integer | Jarak rute |
| estimated_days_regular | integer | Estimasi hari regular |
| estimated_days_express | integer | Estimasi hari express |
| price_per_kg_regular | integer | Harga/kg regular |
| price_per_kg_express | integer | Harga/kg express |

Observed ranges: distance 25–2,400 km; regular estimate 1–7 hari; express estimate 1–3 hari. Harga/kg tersedia untuk regular dan express.

## 3. shipments
**Grain:** 1 baris = 1 shipment/order
**Rows:** 4,000
**Columns:** 14

| Column | Type | Meaning |
|---|---|---|
| shipment_id | text | Primary key, SHP00001–SHP04000 |
| customer_id | text | FK → customers |
| route_id | text | FK → routes |
| origin_address | text | Alamat asal |
| destination_address | text | Alamat tujuan |
| weight_kg | decimal | Berat paket |
| package_type | text | dokumen / paket_kecil / paket_sedang / paket_besar / fragile |
| service_type | text | regular / express / same_day |
| pickup_date | date | Tanggal pickup |
| estimated_delivery | date | Estimasi tanggal delivery |
| actual_delivery | date | Tanggal delivery aktual |
| status | text | delivered / in_transit / lost / returned |
| total_cost_idr | integer | Nilai transaksi pengiriman dalam IDR |
| tracking_number | text | Nomor tracking |

Observed values:
- service: regular 2,418; express 1,183; same_day 399.
- package: paket_sedang 1,225; paket_kecil 1,177; paket_besar 812; dokumen 414; fragile 372.
- status: delivered 3,200; in_transit 500; returned 200; lost 100.
- `actual_delivery` NULL pada 850 rows.
- pickup dates pada data yang diberikan: 2022-01-01 s.d. 2025-01-31.
- tracking_number tidak duplikat pada file yang diperiksa.

**Penting:** dokumentasi dataset menyatakan terdapat 50 baris berstatus `delivered` tetapi `actual_delivery` NULL. Ini merupakan bahan data-quality audit.

## 4. status_history
**Grain:** 1 baris = 1 tracking/status event
**Rows:** 12,747
**Columns:** 6

| Column | Type | Meaning |
|---|---|---|
| record_id | text | Primary key |
| shipment_id | text | FK → shipments |
| status | text | Status event |
| update_timestamp | datetime | Timestamp event |
| location | text | Kota/hub/transit |
| notes | text | Catatan event |

Status event yang muncul:
- pickup_confirmed
- in_transit
- arrived_at_hub
- out_for_delivery
- delivered
- failed_delivery
- returned_to_sender
- lost

Observed: semua 4,000 shipment memiliki histori pada file yang diperiksa. `notes` memiliki 2,583 NULL dari 12,747 rows (~20.3%).

## Relationships
```text
customers (1) ───< shipments >─── (1) routes
                       |
                       |
                       v
                status_history
                  (many events)
```

## Analytical Grain Rules
- KPI shipment: gunakan `shipments` dan `COUNT(DISTINCT shipment_id)`.
- Customer KPI: agregasikan shipment ke customer terlebih dahulu.
- Route KPI: agregasikan shipment ke route.
- Tracking KPI: agregasikan `status_history` ke shipment sebelum join kembali ke `shipments` jika metrik berada pada level shipment.
- Jangan COUNT(*) dari join shipments × status_history untuk menghitung jumlah shipment.

## Important Data Quality Rules
1. NULL `actual_delivery` tidak boleh langsung dianggap lost/returned.
2. Status `delivered` + NULL `actual_delivery` adalah anomali yang perlu dilaporkan.
3. `notes` kosong pada status history adalah missing data, bukan bukti event tidak terjadi.
4. Validasi foreign key sebelum analisis lintas tabel.
5. Validasi tanggal dan urutan event sebelum menghitung SLA atau transit time.
6. Jangan mengubah data sumber secara diam-diam.
7. `total_cost_idr` adalah nilai transaksi; dataset tidak menyediakan actual operating cost sehingga margin/profit tidak dapat dihitung secara langsung.
8. Untuk same-day, jangan memaksakan formula harga/SLA dari kolom regular/express tanpa bukti dari data.

## Useful Default Metrics
- Shipment volume = COUNT(DISTINCT shipment_id)
- Transaction value = SUM(total_cost_idr)
- Average shipment cost = AVG(total_cost_idr)
- Average weight = AVG(weight_kg)
- Delivery duration = actual_delivery - pickup_date
- Lateness = actual_delivery - estimated_delivery
- On-time = actual_delivery <= estimated_delivery
- Loss rate = lost / total shipments
- Return rate = returned / total shipments

Untuk semua rate, selalu tampilkan numerator dan denominator atau jelaskan denominator yang digunakan.
