# Kirimlaju SQL Practice Lab

Aplikasi latihan PostgreSQL dengan **75 business question**, memakai tampilan dan interaksi [Sedukopi SQL Practice Lab](https://github.com/subhanaristiadi/sedukopi-sql-practice-lab).

- Aplikasi: https://subhanaristiadi.github.io/krimlaju-sql-practice-lab/
- API: https://krimlaju-sql-practice-lab.onrender.com
- Dataset simulasi: https://ngulikdata.com/datasets/kirimlaju
- Seluruh 55 pertanyaan asli: `docs/kirimlaju_business_questions.md`
- 20 tambahan: `docs/additional_business_questions.md`
- Cakupan dan bukti query: `coverage_matrix.md`, `docs/reference_verification.json`

## Fitur

Editor SQL, hasil query PostgreSQL langsung, validasi hasil terhadap referensi server, reveal reference SQL, skema empat tabel, filter topik/kesulitan/status, catatan pribadi, progres lokal, dan ekspor/impor progres. CSS, tata letak, panel, warna, dan kontrol berasal dari Sedukopi.

## Dataset

| Tabel | Baris | Grain |
|---|---:|---|
| customers | 600 | Pelanggan |
| routes | 80 | Rute |
| shipments | 4.000 | Pengiriman |
| status_history | 12.747 | Event tracking |
| Total | 17.427 | |

CSV asli ada di `data/`; `data/manifest.json` mencatat SHA-256 dan jumlah baris. Skema PostgreSQL 16 berada di `schema.sql`. Data tidak dibersihkan diam-diam: 50 delivered tanpa actual_delivery tetap dipertahankan untuk latihan audit.

On-time memakai status delivered dengan actual_delivery dan estimated_delivery terisi. Numerator: actual_delivery <= estimated_delivery. Denominator: eligible delivered. Tanggal aktual sebelum pickup diaudit terpisah. Nilai `total_cost_idr` adalah nilai transaksi, bukan biaya operasi/profit. Jangan menggandakan KPI shipment dengan join langsung ke banyak event tracking.

Setiap latihan memuat kontrak output, grain, filter, denominator, rounding, dan tie-breaker. Nama serta urutan kolom harus sama dengan Expected output; urutan baris diabaikan dan multiplicity tetap dibandingkan. Referensi adalah satu baseline SQL yang dapat diganti dengan query ekuivalen.

## Jalankan lokal

```powershell
python -m pip install -r requirements.txt
# Isi .env dari .env.example dengan URL role kirimlaju_reader.
python server.py
# Di terminal lain untuk frontend:
python -m http.server 5500 --bind 127.0.0.1
```

Frontend menggunakan API Render. Untuk API lokal, ganti `API_BASE` pada index.html ke `http://127.0.0.1:8000`.

```powershell
python -m unittest discover -s tests -v
python verify_curriculum.py
```

`build_curriculum.py` membangun ulang materi. Setelah dijalankan, jalankan `verify_curriculum.py` untuk mengeksekusi semua referensi, melengkapi Expected output, dan memperbarui bukti verifikasi. Verifikasi menggunakan role SELECT-only pada database dengan dataset yang sesuai.

## Deployment

GitHub Pages memakai workflow GitHub Actions yang mempublikasikan hanya `index.html` dan `.nojekyll`. API Flask/Gunicorn berjalan pada Render Free di Singapura. PostgreSQL 16 memakai project Neon terpisah. Konfigurasi langsung Render menjadi sumber kebenaran deployment; tidak ada Blueprint yang melakukan sinkronisasi ulang. Lihat `DEPLOYMENT.md`.

API membatasi query ke satu SELECT/CTE, transaksi read-only, role tanpa CREATE atau hak tulis, timeout 10 detik, maksimum 1.000 baris / 1 MB, tiga query bersamaan per worker, dan 20 request per menit per endpoint/IP. Render Free dapat memerlukan waktu bangun saat lama tidak digunakan. Progres lokal tidak tersinkron lintas perangkat; ekspor untuk mencadangkannya.

UI template: Sedukopi SQL Practice Lab oleh subhanaristiadi. Dataset: Kirimlaju dari NgulikData.
