# Case Study #2- B.Runner and Customer Experience

### Following the `Data Cleaning` phase, the case study advances to the second analytical area: Runner and Customer Experience.

---

**1.How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)**

    SELECT 
        (DATE_TRUNC('week', registration_date + 3)::DATE)  AS week_start_date,
        ((DATE_TRUNC('week', registration_date + 3)::DATE) ) + 6 AS week_end_date,
        COUNT(runner_id) AS runners_signed_up
    FROM runners
    GROUP BY week_start_date, week_end_date
    ORDER BY week_start_date;

| week_start_date | week_end_date | runners_signed_up |
| --------------- | ------------- | ----------------- |
| 2021-01-04      | 2021-01-10    | 2                 |
| 2021-01-11      | 2021-01-17    | 1                 |
| 2021-01-18      | 2021-01-24    | 1                 |

---
**2.What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?**

    WITH cte_two AS (
      SELECT 
      	DISTINCT r.order_id,
      	c.order_time,
      	r.pickup_time,
      	r.runner_id
      FROM customer_orders c RIGHT JOIN  runner_orders r ON c.order_id=r.order_id
      WHERE r.pickup_time IS NOT NULL
      ORDER BY r.order_id
    )
     
    
    SELECT
    	runner_id,
        ROUND(AVG(EXTRACT(EPOCH FROM (pickup_time-order_time))/60)::NUMERIC,3) AS average_minutes
    FROM cte_two
    GROUP BY runner_id
    ORDER BY runner_id;

| runner_id | average_minutes |
| --------- | --------------- |
| 1         | 14.329          |
| 2         | 20.011          |
| 3         | 10.467          |

---
**3.Is there any relationship between the number of pizzas and how long the order takes to prepare?**

    WITH cte_three AS (
      SELECT 
      	DISTINCT r.order_id,
      	COUNT(c.customer_id) AS pizza_numbers,
      	c.order_time,
      	r.pickup_time
      FROM customer_orders c RIGHT JOIN  runner_orders r ON c.order_id=r.order_id
      WHERE r.pickup_time IS NOT NULL
      GROUP BY r.order_id, c.order_time, r.pickup_time
      ORDER BY r.order_id
    )
     
    SELECT
    	pizza_numbers,
        ROUND(EXTRACT(EPOCH FROM (pickup_time-order_time)/60)::NUMERIC,3) AS long_order
    FROM cte_three
    ORDER BY pizza_numbers;

| pizza_numbers | long_order |
| ------------- | ---------- |
| 1             | 10.533     |
| 1             | 10.033     |
| 1             | 10.467     |
| 1             | 10.267     |
| 1             | 20.483     |
| 2             | 21.233     |
| 2             | 15.517     |
| 3             | 29.283     |

---
**4.What was the average distance travelled for each customer?**

    SELECT
      	c.customer_id,
        ROUND(AVG(r.distance),3)
    FROM customer_orders c LEFT JOIN  runner_orders r ON c.order_id=r.order_id
    GROUP BY c.customer_id
    ORDER BY c.customer_id;

| customer_id | round  |
| ----------- | ------ |
| 101         | 20.000 |
| 102         | 16.733 |
| 103         | 23.400 |
| 104         | 10.000 |
| 105         | 25.000 |

---
**5.What was the difference between the longest and shortest delivery times for all orders?**

    SELECT
    	MAX(DURATION)-MIN(DURATION) AS difference_max_min
     FROM runner_orders;

| difference_max_min |
| ------------------ |
| 30                 |

---
**6.What was the average speed for each runner for each delivery and do you notice any trend for these values?**

    SELECT
    	runner_id,
    	order_id,
        ROUND((distance/ (duration::numeric/60)),2) AS avg_speed
    FROM runner_orders
    WHERE distance IS NOT NULL
    ORDER BY runner_id;

| runner_id | order_id | avg_speed |
| --------- | -------- | --------- |
| 1         | 1        | 37.50     |
| 1         | 2        | 44.44     |
| 1         | 3        | 40.20     |
| 1         | 10       | 60.00     |
| 2         | 7        | 60.00     |
| 2         | 8        | 93.60     |
| 2         | 4        | 35.10     |
| 3         | 5        | 40.00     |

    SELECT
    	runner_id,
        ROUND(AVG((distance/ (duration::numeric/60))),2) AS avg_speed
    FROM runner_orders
    WHERE distance IS NOT NULL
    GROUP BY runner_id
    ORDER BY runner_id;

| runner_id | avg_speed |
| --------- | --------- |
| 1         | 45.54     |
| 2         | 62.90     |
| 3         | 40.00     |

    SELECT
        ROUND(AVG((distance/ (duration::numeric/60))),3)  AS avg_speed
    FROM runner_orders
    WHERE distance IS NOT NULL;

| avg_speed |
| --------- |
| 51.356    |

---
**7.What is the successful delivery percentage for each runner?**

    WITH cte_seven AS (
      SELECT
    	runner_id,
        COUNT(order_id) AS order_suc
      FROM runner_orders
      WHERE duration IS NOT NULL
      GROUP BY runner_id)
    
    SELECT
    	r.runner_id,
    	ROUND(100.0*t.order_suc/COUNT(r.order_id),2) || '%' AS successful_delivery_percentage
    FROM runner_orders r LEFT JOIN cte_seven t ON r.runner_id = t.runner_id
    GROUP BY r.runner_id, t.order_suc
    ORDER BY r.runner_id;

| runner_id | successful_delivery_percentage |
| --------- | ------------------------------ |
| 1         | 100.00%                        |
| 2         | 75.00%                         |
| 3         | 50.00%                         |

---

