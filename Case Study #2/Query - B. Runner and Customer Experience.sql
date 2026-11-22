-- B. Runner and Customer Experience
-- Data Cleaning
-- Removing NULL records within the customer_orders table
UPDATE customer_orders
SET exclusions = CASE
    WHEN exclusions LIKE 'null' THEN ''
    ELSE exclusions
    END,
	extras = CASE
    WHEN extras is NULL or extras LIKE 'null' THEN ''
    ELSE extras
	END;

-- Removing NULL values and standardising records within the runner_orders table
UPDATE runner_orders
SET pickup_time = CASE
    WHEN pickup_time = 'null' THEN ''
    ELSE pickup_time
	END,
	distance = CASE
	WHEN distance LIKE '%km' THEN TRIM('km' FROM distance)
    when distance LIKE 'null' THEN ''
    ELSE distance
    END,
    duration = CASE
	WHEN duration LIKE '%minutes' THEN TRIM('minutes' FROM duration)
    WHEN duration LIKE '%mins' THEN TRIM('mins' FROM duration)
    WHEN duration LIKE '%minute' THEN TRIM('minute' FROM duration)
    WHEN duration LIKE 'null' THEN ''
    ELSE duration
    END,
    cancellation = CASE
    WHEN cancellation LIKE 'null' OR cancellation IS NULL THEN ''
    ELSE cancellation
    END;

-- Altering the type of several columns
ALTER TABLE runner_orders
ALTER COLUMN pickup_time TYPE TIMESTAMP USING NULLIF(pickup_time, '')::TIMESTAMP,
ALTER COLUMN distance TYPE NUMERIC USING NULLIF(distance, '')::NUMERIC,
ALTER COLUMN duration TYPE INTEGER USING NULLIF(duration, '')::INTEGER;


-- 2.What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?
WITH table_two AS (
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
FROM table_two
GROUP BY runner_id
ORDER BY runner_id;

-- 3.Is there any relationship between the number of pizzas and how long the order takes to prepare?
WITH table_three AS (
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
FROM table_three
ORDER BY pizza_numbers;

-- 4.What was the average distance travelled for each customer?
SELECT
  	c.customer_id,
    ROUND(AVG(r.distance),3)
FROM customer_orders c LEFT JOIN  runner_orders r ON c.order_id=r.order_id
GROUP BY c.customer_id
ORDER BY c.customer_id;
-- 5.What was the difference between the longest and shortest delivery times for all orders?
SELECT
	MAX(DURATION)-MIN(DURATION) AS difference_max_min
 FROM runner_orders;
-- 6.What was the average speed for each runner for each delivery and do you notice any trend for these values?
SELECT
	runner_id,
	order_id,
    ROUND((distance/ (duration::numeric/60)),2) AS avg_speed
FROM runner_orders
WHERE distance IS NOT NULL
ORDER BY runner_id;

SELECT
	runner_id,
    ROUND(AVG((distance/ (duration::numeric/60))),2) AS avg_speed
FROM runner_orders
WHERE distance IS NOT NULL
GROUP BY runner_id
ORDER BY runner_id;

SELECT
    ROUND(AVG((distance/ (duration::numeric/60))),3)  AS avg_speed
FROM runner_orders
WHERE distance IS NOT NULL;
-- 7.What is the successful delivery percentage for each runner?
WITH table_seven AS (
  SELECT
	runner_id,
    COUNT(order_id) AS order_suc
  FROM runner_orders
  WHERE duration IS NOT NULL
  GROUP BY runner_id)

SELECT
	r.runner_id,
	ROUND(100.0*t.order_suc/COUNT(r.order_id),2) || '%' AS successful_delivery_percentage
FROM runner_orders r LEFT JOIN table_seven t ON r.runner_id = t.runner_id
GROUP BY r.runner_id, t.order_suc
ORDER BY r.runner_id;
