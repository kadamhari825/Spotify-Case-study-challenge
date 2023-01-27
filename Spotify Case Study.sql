-- 1. find the total active users each day.

SELECT event_date, 
       COUNT(DISTINCT(user_id)) as user_count
FROM activity
GROUP BY event_date;


-- 2. find the total active users each week.

WITH cte as(
       SELECT *, 
            week(event_date) as week
	   FROM activity)

SELECT week, COUNT(DISTINCT(user_id)) AS user_id
FROM cte
GROUP BY week;


-- 3. Date wise number of users who purchased the app on same day they installed the app.

SELECT a.event_date, 
       COUNT(*) AS user_count
FROM activity as a
JOIN activity as b
ON a.user_id  = b.user_id 
WHERE a.event_date = b.event_date 
     AND a.event_name  = 'app-purchase' AND b.event_name = 'app-installed'
GROUP BY a.event_date;


-- 4. find the percentage of users who purchased the subscription and group them in new category 'Others' except country 'India' and 'USA'

WITH  cte AS (
	  SELECT country, 
                count(*) purchase_count 
      FROM activity
	  WHERE event_name = 'app-purchase'
      GROUP BY  country),
      
cte2 AS ( SELECT sum(purchase_count) AS total 
      FROM cte), 
      
cte3 AS (
      SELECT CASE WHEN country IN ('India', 'USA') THEN country ELSE 'Others' END AS new_col, 
            SUM(purchase_count) AS premium_users, total
     FROM cte, cte2
	 GROUP BY (CASE WHEN country IN ('India', 'USA') THEN country ELSE 'Others' END))

SELECT new_col , 
       ROUND(premium_users / total  *100) AS percentage
FROM cte3;


-- 5. Among all the users who installed the app, how many of them purchased the subscription on very next day?

WITH cte as(
       SELECT *, 
             LAG(event_name) OVER(PARTITION BY user_id ORDER BY  event_date) AS pre_event,
             
             LAG(event_date) OVER(PARTITION BY user_id) AS previous_date
FROM activity)

SELECT event_date, 
       COUNT(DISTINCT(user_id)) AS count FROM cte 
WHERE event_name = 'app-purchase' AND 
      pre_event = 'app-installed' AND 
      datediff(event_date, previous_date)  = 1







