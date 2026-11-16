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
-- B. Runner and Customer Experience
-- 1.How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)
SELECT 
    (DATE_TRUNC('week', registration_date + 3)::DATE) - 3 AS week_start_date,
    COUNT(runner_id) AS runners_signed_up,
    (DATE_TRUNC('week', registration_date + 3)::DATE) + 3 AS week_end_date
FROM runners
GROUP BY week_start_date, week_end_date
ORDER BY week_start_date;
-- 2.What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?
-- 3.Is there any relationship between the number of pizzas and how long the order takes to prepare?
-- 4.What was the average distance travelled for each customer?
-- 5.What was the difference between the longest and shortest delivery times for all orders?
-- 6.What was the average speed for each runner for each delivery and do you notice any trend for these values?
-- 7.What is the successful delivery percentage for each runner?
