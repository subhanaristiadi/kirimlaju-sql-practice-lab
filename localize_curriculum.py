"""English display copy for all exercises; SQL, IDs, and source mappings stay stable."""
import json
from pathlib import Path

ENGLISH_TEXT = """
1|Shipment KPI summary|What are the total shipment count, total transaction value, average shipment cost, and average weight?|One summary row|Calculate these metrics directly from shipments without joins.
2|Service mix|What is the shipment mix by service type?|One row per service_type|Use all shipments as the percentage denominator.
3|Service volume and value rankings|Which services have the highest shipment volume and transaction value?|One row per service|Return all services with both rankings. Use DENSE_RANK for ties.
4|Delivery, loss, and return rates|What are the overall delivery, loss, and return rates?|One summary row|Use all shipments as the denominator.
5|Monthly KPI trends|How do the KPIs change from month to month?|One row per pickup month|Include months with shipments. Represent each month using its first calendar date.
6|Service volume and value profile|What are the shipment volume, transaction value, average cost, and average weight for regular, express, and same-day services?|One row per service|Use the exact service_type values stored in the dataset.
7|Services with the best on-time performance|Which service has the best on-time rate?|One row per service|Return all services and rank them using the rounded on-time rate.
8|Transaction value and delivery performance|Do services with higher transaction value also deliver better delivery performance?|One row per service|Compare value and performance using a scorecard. Do not infer causation from the comparison.
9|Late delivery rates by service|How do late delivery rates vary by service?|One row per service|Calculate the late rate using eligible delivered shipments only.
10|High volume and poor delivery outcomes|Are there services with high shipment volume but relatively poor delivery outcomes?|One row per service|High volume means volume at least equal to the mean across services. Below-average delivery uses the unweighted mean of service delivery rates.
11|Route volume rankings|Which routes have the highest shipment volume?|One row per active route|Return all active routes.
12|Route transaction value rankings|Which routes generate the highest transaction value?|One row per active route|Return all active routes.
13|Highest and lowest average shipment costs|Which routes have the highest and lowest average shipment costs?|One row per active route|Use the rounded average for both rankings.
14|Route on-time performance rankings|Which routes have the best and worst on-time rates?|One row per active route|Return all active routes and rank them using the rounded on-time rate.
15|Distance and delivery duration correlation|Does route distance correlate with delivery duration or lateness?|One summary row|Use Pearson CORR and round correlation coefficients to 4 decimal places. Negative lateness means early delivery.
16|Loss and return risks by route|Which routes have loss or return rates that deserve attention?|One row per active route|Return all routes so the numerators and denominators can be reviewed.
17|Route investigation priorities|Which routes are candidates for a pricing review or operational improvement?|One row per active route|Flag a route for review if its on-time rate is below 80%, loss rate is at least 5%, or return rate is at least 10%. This identifies investigation priorities, not profit or loss.
18|Business versus individual shipments|What proportion of shipments comes from business versus individual customers?|One row per customer_type|Measure the proportion of shipments, not the proportion of customers.
19|Transaction value by customer segment|Which customer segment generates the highest total transaction value?|One row per customer_type|Return all customer segments.
20|Average shipment cost by customer segment|What is the average shipment cost for each customer type?|One row per customer_type|Calculate the average at shipment grain.
21|Shipment frequency by customer|What is the shipment frequency for each customer?|One row per customer|Include customers with no shipments.
22|Top ten customers|Which customers have the highest shipment volume and transaction value?|One row per top-ten customer|Select exactly 10 customers by transaction value DESC, breaking ties by customer_id ASC. Calculate both rankings across all customers before selecting the top 10.
23|Delivery outcomes by customer segment|Do delivery outcomes differ between customer types?|One row per customer_type and status|Use shipments within each customer segment as the denominator.
24|High-volume customer patterns|Do high-volume customers show particular service or route preferences?|One row per top customer, service, and route|Select exactly 10 customers by shipment count DESC, breaking ties by customer_id ASC.
25|Package volume and transaction value|How do shipment volume and transaction value vary by package type?|One row per package_type|Use all shipments.
26|Package weight distribution|What is the distribution of weight_kg for each package type?|One row per package_type|Calculate quartiles using PERCENTILE_CONT.
27|Weight outliers using IQR|Are there unusual weights within any package category?|One row per package_type|Identify weights outside the Tukey fences of 1.5 IQR within each category. Include categories with no outliers.
28|Service preferences by package type|Are certain package types more likely to use express or same-day services?|One row per package_type and service_type|Return all observed combinations.
29|Weight, transaction value, and lateness|Do heavier shipments tend to have higher transaction value or higher late delivery rates?|One row per weight band|Use these weight bands: below 1 kg, 1 to 5 kg inclusive, and above 5 kg. Return the labels '<1 kg', '1-5 kg', and '>5 kg'.
30|On-time rates by service|What is the on-time rate for each service type?|One row per service|Return the eligible-delivery denominator and the on-time numerator.
31|Average and median delivery delay|What are the average and median delays for late shipments?|One summary row|Include only eligible delivered shipments that arrived late.
32|Late deliveries by route and service|Which route and service combinations have the most late deliveries?|One row per active route and service combination|Return all active combinations, including those with no late deliveries.
33|Actual versus estimated delivery duration|Does actual delivery duration differ substantially from the estimated duration?|One row per service|Use a descriptive paired comparison of eligible delivered shipments. This is not a statistical significance test.
34|Delivered shipments without actual delivery dates|What proportion of delivered shipments is missing actual_delivery?|One summary row|Use only shipments with status delivered as the denominator.
35|Shipment status and tracking conflicts|Are there conflicts between shipment status, actual_delivery, and status history?|One audit summary row|Check conflicts using the presence of a delivered event, rather than only the latest event.
36|Average tracking event count|What is the average number of status events per shipment?|One summary row|Include shipments without history as having zero events.
37|Status event frequency|Which status events occur most frequently?|One row per event status|Use event grain and all events as the denominator.
38|Shipments with failed delivery attempts|How many shipments have experienced a failed delivery attempt?|One summary row|Count distinct shipments, not events.
39|Tracking location frequency|Which locations or hubs appear most frequently in tracking events?|One row per location|Return all locations, including NULL if present.
40|Transit time from pickup to delivery|What is the average time from pickup_confirmed to delivered?|One summary row|Use the first pickup and first delivered event. Include only complete pairs with nonnegative durations.
41|Event patterns for problem shipments|What are the most common event sequences for problem shipments?|One row per event sequence|Problem shipments have shipment status lost or returned. Order events by timestamp, then record_id.
42|Event sequence audit|Are there shipments with unusual status sequences?|One audit summary row|Terminal statuses are delivered, lost, and returned_to_sender. Flag any event after a terminal status. Break timestamp ties using record_id.
43|Customer and route validity|Does every shipment reference a valid customer and route?|One audit summary row|Use LEFT JOIN to retain orphan shipments.
44|Tracking number uniqueness|Are tracking_number values unique?|One summary row|Duplicate excess equals the non-NULL count minus the distinct non-NULL count.
45|Missing values in every column|How many missing values are there in each table?|One row per table and column|Treat SQL NULL and empty strings as missing. Include columns with no missing values.
46|Actual delivery date audit|Do delivered shipments always have an actual_delivery date?|One row per shipment status|Return all statuses to compare expected missing dates with anomalies.
47|Delivery date sanity checks|Are actual_delivery dates reasonable relative to pickup_date and estimated_delivery?|One audit summary row|An actual date after the estimated date indicates lateness; it does not automatically mean the data is invalid.
48|Tracking history coverage|Are there shipments without tracking history?|One summary row|Count each shipment once, even when it has multiple tracking events.
49|Duplicate and foreign key audit|Are there duplicate records or unmatched foreign keys?|One row per audit check|Return seven checks. Duplicate counts measure excess primary-key rows, not repeated non-key content.
50|Impact of missing dates on on-time rates|How do data quality issues affect delivery and on-time KPIs?|One summary row|Compare the eligible-delivery denominator with the naive denominator of all delivered shipments. Use the naive rate only to audit bias.
51|Operations manager scorecard|Which KPIs are most relevant to an operations manager's dashboard?|One row per service|Return the complete service metrics: volume, transaction value, cost, weight, on-time performance, and delivery, loss, and return rates.
52|Outliers across business dimensions|Which services, routes, customer segments, and periods are outliers?|One row per dimension category|Return all categories across the four dimensions. Identify outliers using late-rate rankings, not a statistical outlier test.
53|Areas for operational investigation|Which areas require further operational investigation?|One row per route requiring review|Include routes with volume at least 30 and at least one of these conditions: on-time rate below 80%, loss rate at least 5%, or return rate at least 10%.
54|Priorities for improving on-time delivery|Which insights are most actionable for improving on-time delivery?|One row per top-ten route and service combination|Select exactly 10 combinations with the most late deliveries. Break ties by route_id, then service_type ASC. These are investigation candidates, not causal recommendations.
55|Monthly service scorecard|How can a scorecard combine volume, value, on-time performance, loss, and returns while keeping each metric's definition clear?|One row per service and month|Use all shipments within each service-month as the loss and return denominator. Use eligible delivered shipments for the on-time denominator.
56|Month-over-month growth|What is the month-over-month growth in shipment volume and transaction value?|One row per month|Apply LAG in pickup-month order. Growth is NULL for the first month.
57|Three-month rolling average|What is the three-month rolling average of shipment volume?|One row per month|Use a window of up to three observed months. Use partial windows for the first two months.
58|Cumulative transaction value|What is the cumulative transaction value by month across the dataset period?|One row per month|Accumulate across the entire dataset without resetting at the start of each year.
59|Top three routes each month|What are the three highest-volume routes in each month?|One row per month and selected route|Return exactly three routes per month. Break ties by route_id ASC.
60|Pickup weekday patterns|How do shipment volume, late delivery rate, and transaction value vary by pickup weekday?|One row per ISO weekday|Use ISO weekday numbers: 1 for Monday through 7 for Sunday.
61|Customers making their first shipment|How many new customers make their first shipment each month?|One row per first active month|New means the first observed shipment, not registration_date.
62|Next-month customer retention|What is customer retention in the month after the first-shipment month?|One row per mature cohort|Exclude cohorts in the final dataset month because their next-month activity is not yet observable.
63|Customers inactive for over 90 days|Which customers have been inactive for more than 90 days relative to the latest pickup date in the dataset?|One row per inactive customer|Include only customers who have shipped before. Use MAX(pickup_date) as the reference date, not the computer's current date.
64|Customer value contribution by decile|How does customer transaction value contribution vary by decile?|One row per decile|Decile 1 contains the highest-value customers. Include active customers only and break ties by customer_id ASC.
65|Customers using multiple services|What proportion of customers uses more than one service type?|One summary row|Use all customers who have made at least one shipment as the denominator.
66|Tracking status transition frequency|What tracking status transitions occur, and how frequently?|One row per status pair|Order by timestamp, then record_id. The first event has no preceding transition.
67|Time between tracking statuses|What is the average interval in hours between events for each origin and destination status pair?|One row per status pair|Include zero-hour intervals. Exclude the first event from interval calculations.
68|Recovery after failed delivery|How many shipments have a failed delivery event followed by a delivered event?|One summary row|A recovered shipment has a delivered timestamp strictly after its first failed-delivery timestamp. Do not use the final shipment status.
69|Consistency with the latest tracking status|How closely does shipment status match the latest tracking event?|One row per shipment status and latest event status|Map returned to returned_to_sender and use exact matches for other statuses. Missing history produces a NULL match value.
70|Missing tracking data by status|How many tracking events have a missing timestamp or location for each status?|One row per event status|A missing location is either NULL or an empty string.
71|Actual versus catalog prices|How does the transaction price per kg compare with the catalog price for regular and express services?|One row per regular or express service|Use a simple average across shipments, not a weighted average. A price gap does not necessarily indicate a billing error.
72|Same-day delivery estimates|How many same_day shipments have an estimated delivery date different from the pickup date?|One summary row|Check estimated_delivery, not actual_delivery. Count missing dates separately.
73|Estimated duration versus route catalog|How do shipment duration estimates differ from route catalog estimates for regular and express services?|One row per regular or express service|Use calendar-day differences. Do not assume business days.
74|Top five route value contributions by service|Which five routes contribute the most transaction value within each service?|One row per service and selected route|Return exactly five routes per service. Use all routes within the service as the value-share denominator, not just the top five.
75|Reaching a 90% on-time target|How many additional shipments are needed to reach a 90% on-time rate if every additional shipment is on time?|One row per service|Solve (on_time + x) / (eligible + x) >= 0.90 for a nonnegative integer x. Assume every additional shipment is eligible and on time.
"""

ENGLISH = {int(parts[0]): dict(zip(('title','business_question','analytical_grain','contract'),parts[1:]))
           for line in ENGLISH_TEXT.strip().splitlines() if (parts := line.split('|'))}
assert set(ENGLISH) == set(range(1,76))
TOPICS = {'Tren & Window Functions':'Trends & Window Functions',
          'Tracking Lanjutan':'Advanced Tracking','Analitik Lanjutan':'Advanced Analytics'}
COMMON_LIMITATIONS = (' Transaction value is not profit. Round rates, percentages, and averages to 2 decimal places unless stated otherwise.'
    ' On time means status delivered with both actual_delivery and estimated_delivery present, and actual_delivery <= estimated_delivery.'
    ' Actual dates before pickup are audited separately rather than silently cleaned.')

def apply_english(exercises):
    for exercise in exercises:
        translation = ENGLISH[exercise['number']]
        exercise.update({k:translation[k] for k in ('title','business_question','analytical_grain')})
        exercise['topic'] = TOPICS.get(exercise['topic'],exercise['topic'])
        exercise['learning_objectives'] = [exercise['topic'],'PostgreSQL','Consistent analytical grain and denominators']
        exercise['limitations'] = translation['contract'] + COMMON_LIMITATIONS
        exercise['validation_policy'] = 'Column names and column order must match Expected output. Row order is ignored; duplicate rows are still counted.'
    return exercises

if __name__ == '__main__':
    root = Path(__file__).resolve().parent
    exercises = apply_english(json.loads((root/'exercises.json').read_text(encoding='utf-8')))
    (root/'exercises.json').write_text(json.dumps(exercises,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
    topics = [{'topic':topic,'exercise_ids':[e['id'] for e in exercises if e['topic']==topic]}
              for topic in dict.fromkeys(e['topic'] for e in exercises)]
    (root/'curriculum_topics.json').write_text(json.dumps(topics,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
    (root/'docs/business_questions.en.md').write_text('# Kirimlaju Business Questions\n\n'
        +'\n'.join(f"{e['number']}. {e['business_question']}" for e in exercises)+'\n',encoding='utf-8')
    print('Translated all 75 exercises and curriculum topics into English.')
