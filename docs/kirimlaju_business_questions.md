# KIRIMLAJU — Business Questions

Dokumen ini berisi pertanyaan bisnis yang dapat dijawab dari dataset KIRIMLAJU. Gunakan sebagai backlog analitik; jangan menganggap semua pertanyaan harus dijawab sekaligus.

## A. Executive / KPI
1. Berapa total shipment, total transaction value, average shipment cost, dan average weight?
2. Bagaimana komposisi shipment berdasarkan service type?
3. Service mana yang memiliki volume terbesar dan transaction value terbesar?
4. Bagaimana delivery, loss, dan return rate secara keseluruhan?
5. Bagaimana KPI berubah dari bulan ke bulan?

## B. Service Performance
6. Bagaimana volume, transaction value, average cost, dan average weight untuk regular, express, dan same-day?
7. Service mana yang memiliki on-time rate terbaik?
8. Apakah service dengan transaction value lebih tinggi juga memberikan delivery performance lebih baik?
9. Bagaimana tingkat keterlambatan menurut service?
10. Apakah ada service yang memiliki volume tinggi tetapi outcome delivery relatif buruk?

## C. Route Performance
11. Rute mana yang memiliki shipment volume tertinggi?
12. Rute mana yang menghasilkan transaction value terbesar?
13. Rute mana yang memiliki average shipment cost tertinggi/terendah?
14. Rute mana yang memiliki on-time rate terbaik dan terburuk?
15. Apakah jarak rute berkorelasi dengan delivery duration atau keterlambatan?
16. Rute mana yang memiliki loss/return rate yang perlu diperhatikan?
17. Rute mana yang menjadi kandidat evaluasi harga atau operational improvement?

Catatan: tanpa data biaya operasional, jangan menyebut rute “profit” atau “rugi” secara literal. Gunakan istilah transaction value/revenue proxy dan jelaskan keterbatasannya.

## D. Customer
18. Berapa proporsi shipment business vs individual?
19. Segmen mana yang menghasilkan total transaction value terbesar?
20. Bagaimana average shipment cost per customer type?
21. Bagaimana shipment frequency per customer?
22. Siapa pelanggan dengan volume dan transaction value terbesar?
23. Apakah customer type tertentu memiliki delivery outcome yang berbeda?
24. Apakah pelanggan dengan volume tinggi menunjukkan pola service/route tertentu?

## E. Package & Weight
25. Bagaimana volume dan transaction value berdasarkan package type?
26. Bagaimana distribusi weight_kg per package type?
27. Apakah terdapat berat yang tidak lazim untuk suatu package category?
28. Apakah package type tertentu lebih sering menggunakan express atau same-day?
29. Apakah shipment yang lebih berat cenderung memiliki transaction value atau keterlambatan lebih tinggi?

## F. SLA & Delivery
30. Berapa on-time rate berdasarkan service type?
31. Berapa rata-rata dan median keterlambatan shipment yang terlambat?
32. Rute/service mana yang paling sering terlambat?
33. Apakah delivery duration aktual berbeda signifikan dari estimated delivery?
34. Berapa proporsi delivered shipment yang tidak memiliki actual_delivery?
35. Apakah ada konflik antara status shipment, actual_delivery, dan status history?

Definisi on-time default: actual_delivery <= estimated_delivery, hanya untuk shipment delivered dengan actual_delivery valid.

## G. Tracking & Operations
36. Berapa rata-rata jumlah status event per shipment?
37. Status/event apa yang paling sering muncul?
38. Berapa banyak shipment yang mengalami failed delivery?
39. Lokasi/hub mana yang paling sering muncul pada tracking event?
40. Berapa lama rata-rata waktu dari pickup_confirmed ke delivered?
41. Untuk shipment bermasalah, event sequence apa yang paling umum?
42. Apakah ada shipment dengan urutan status yang tidak wajar?

## H. Data Quality Audit
43. Apakah semua shipment memiliki customer dan route yang valid?
44. Apakah tracking_number unik?
45. Berapa banyak missing value pada setiap tabel?
46. Apakah shipment berstatus delivered selalu memiliki actual_delivery?
47. Apakah actual_delivery masuk akal dibanding pickup_date dan estimated_delivery?
48. Apakah ada shipment tanpa histori tracking?
49. Apakah ada duplicate record atau foreign key yang tidak match?
50. Apa dampak data-quality issue terhadap KPI delivery dan SLA?

## I. Dashboard / Management
51. KPI apa yang paling relevan untuk dashboard operations manager?
52. Service, route, customer segment, dan periode mana yang menjadi outlier?
53. Area mana yang membutuhkan investigasi operasional lebih lanjut?
54. Insight apa yang paling actionable untuk meningkatkan on-time delivery?
55. Bagaimana membangun scorecard yang menggabungkan volume, value, SLA, loss, dan return tanpa mengaburkan definisi masing-masing metrik?
