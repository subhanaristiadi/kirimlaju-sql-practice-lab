# Deployment Kirimlaju

## Infrastruktur

- GitHub: https://github.com/subhanaristiadi/krimlaju-sql-practice-lab
- Pages: https://subhanaristiadi.github.io/krimlaju-sql-practice-lab/
- API: https://krimlaju-sql-practice-lab.onrender.com
- Neon project: blue-field-39983906, database kirimlaju, production branch, PostgreSQL 16, Singapore.

## Database kosong baru

Jalankan `seed_neon.py` hanya pada database kosong. Skrip menolak tabel existing, mengimpor CSV tanpa menghapus data lama, membuat role SELECT-only kirimlaju_reader, dan menyimpan URL reader di `.env` yang diabaikan Git. Admin URL dibaca dari NEON_ADMIN_DATABASE_URL atau input tersembunyi `--stdin-url`, tidak disimpan.

Jangan jalankan seed pada database produksi yang telah terisi. Perubahan skema selanjutnya harus diuji pada branch Neon terpisah.

## Konfigurasi Render langsung

- Runtime: Python 3.12.8
- Region: Singapore
- Plan: Free
- Branch: main
- Build: `pip install -r requirements.txt`
- Start: `gunicorn server:app --bind 0.0.0.0:$PORT --workers 1 --threads 4 --timeout 35`
- Auto deploy: enabled
- DATABASE_URL: URL pooled role kirimlaju_reader, disimpan sebagai environment secret Render.
- REQUIRE_NON_SUPERUSER: true
- KIRIMLAJU_MAX_ROWS: 1000
- KIRIMLAJU_QUERY_TIMEOUT_MS: 10000
- CORS_ALLOWED_ORIGINS: https://subhanaristiadi.github.io

Frontend, server, dan dokumentasi tidak menyimpan credential. Pembaruan konfigurasi Render langsung adalah sumber kebenaran; tidak dikelola Blueprint.

## GitHub Pages

Deployment melalui workflow `.github/workflows/pages.yml` dari branch `main`. Artefak Pages hanya memuat `index.html` dan `.nojekyll`; CSV, server, dan dokumen tidak diunggah ke Pages. Query dan validasi melalui API Render. Push main memicu pembaruan Pages dan Render.

## Verifikasi

`python -m unittest discover -s tests -v` memeriksa cakupan 55 sumber + 20 tambahan, parsing seluruh referensi, penolakan operasi tulis/multi-statement, CORS, dan perbandingan hasil. `python verify_curriculum.py` mengeksekusi 75 referensi dengan role reader, memeriksa truncation, dan mencatat kolom serta jumlah baris di docs/reference_verification.json. Uji deployment mencakup health, query, jawaban benar/salah, SQL terlarang, CORS, dan browser frontend.
