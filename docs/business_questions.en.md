# Kirimlaju Business Questions

1. What are the total shipment count, total transaction value, average shipment cost, and average weight?
2. What is the shipment mix by service type?
3. Which services have the highest shipment volume and transaction value?
4. What are the overall delivery, loss, and return rates?
5. How do the KPIs change from month to month?
6. What are the shipment volume, transaction value, average cost, and average weight for regular, express, and same-day services?
7. Which service has the best on-time rate?
8. Do services with higher transaction value also deliver better delivery performance?
9. How do late delivery rates vary by service?
10. Are there services with high shipment volume but relatively poor delivery outcomes?
11. Which routes have the highest shipment volume?
12. Which routes generate the highest transaction value?
13. Which routes have the highest and lowest average shipment costs?
14. Which routes have the best and worst on-time rates?
15. Does route distance correlate with delivery duration or lateness?
16. Which routes have loss or return rates that deserve attention?
17. Which routes are candidates for a pricing review or operational improvement?
18. What proportion of shipments comes from business versus individual customers?
19. Which customer segment generates the highest total transaction value?
20. What is the average shipment cost for each customer type?
21. What is the shipment frequency for each customer?
22. Which customers have the highest shipment volume and transaction value?
23. Do delivery outcomes differ between customer types?
24. Do high-volume customers show particular service or route preferences?
25. How do shipment volume and transaction value vary by package type?
26. What is the distribution of weight_kg for each package type?
27. Are there unusual weights within any package category?
28. Are certain package types more likely to use express or same-day services?
29. Do heavier shipments tend to have higher transaction value or higher late delivery rates?
30. What is the on-time rate for each service type?
31. What are the average and median delays for late shipments?
32. Which route and service combinations have the most late deliveries?
33. Does actual delivery duration differ substantially from the estimated duration?
34. What proportion of delivered shipments is missing actual_delivery?
35. Are there conflicts between shipment status, actual_delivery, and status history?
36. What is the average number of status events per shipment?
37. Which status events occur most frequently?
38. How many shipments have experienced a failed delivery attempt?
39. Which locations or hubs appear most frequently in tracking events?
40. What is the average time from pickup_confirmed to delivered?
41. What are the most common event sequences for problem shipments?
42. Are there shipments with unusual status sequences?
43. Does every shipment reference a valid customer and route?
44. Are tracking_number values unique?
45. How many missing values are there in each table?
46. Do delivered shipments always have an actual_delivery date?
47. Are actual_delivery dates reasonable relative to pickup_date and estimated_delivery?
48. Are there shipments without tracking history?
49. Are there duplicate records or unmatched foreign keys?
50. How do data quality issues affect delivery and on-time KPIs?
51. Which KPIs are most relevant to an operations manager's dashboard?
52. Which services, routes, customer segments, and periods are outliers?
53. Which areas require further operational investigation?
54. Which insights are most actionable for improving on-time delivery?
55. How can a scorecard combine volume, value, on-time performance, loss, and returns while keeping each metric's definition clear?
56. What is the month-over-month growth in shipment volume and transaction value?
57. What is the three-month rolling average of shipment volume?
58. What is the cumulative transaction value by month across the dataset period?
59. What are the three highest-volume routes in each month?
60. How do shipment volume, late delivery rate, and transaction value vary by pickup weekday?
61. How many new customers make their first shipment each month?
62. What is customer retention in the month after the first-shipment month?
63. Which customers have been inactive for more than 90 days relative to the latest pickup date in the dataset?
64. How does customer transaction value contribution vary by decile?
65. What proportion of customers uses more than one service type?
66. What tracking status transitions occur, and how frequently?
67. What is the average interval in hours between events for each origin and destination status pair?
68. How many shipments have a failed delivery event followed by a delivered event?
69. How closely does shipment status match the latest tracking event?
70. How many tracking events have a missing timestamp or location for each status?
71. How does the transaction price per kg compare with the catalog price for regular and express services?
72. How many same_day shipments have an estimated delivery date different from the pickup date?
73. How do shipment duration estimates differ from route catalog estimates for regular and express services?
74. Which five routes contribute the most transaction value within each service?
75. How many additional shipments are needed to reach a 90% on-time rate if every additional shipment is on time?
