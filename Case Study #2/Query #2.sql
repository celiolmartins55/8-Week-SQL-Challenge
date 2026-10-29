--A. Pizza Metrics
-- Data Clean:
UPDATE customer_orders
SET exclusions = CASE
    WHEN exclusions LIKE 'null' THEN ' '
    ELSE exclusions
    END,
	extras = CASE
    WHEN extras is NULL or extras LIKE 'null' THEN ' '
    ELSE extras
	END;

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
--1. How many pizzas were ordered?
SELECT 
	COUNT(*) as pizzas
FROM customer_orders;
--2. How many unique customer orders were made?
SELECT
	 COUNT(DISTINCT order_id) as unique_oders
 FROM customer_orders;
--3. How many successful orders were delivered by each runner?
SELECT
	COUNT (*) as orders_delivered
FROM runner_orders
WHERE cancellation LIKE '';
--4. How many of each type of pizza was delivered?
SELECT
	pizza_id,
	COUNT (*)
FROM customer_orders
GROUP BY pizza_id;
--5. How many Vegetarian and Meatlovers were ordered by each customer?
--6. What was the maximum number of pizzas delivered in a single order?
--7. For each customer, how many delivered pizzas had at least 1 change and how many had no changes?
--8. How many pizzas were delivered that had both exclusions and extras?
--9. What was the total volume of pizzas ordered for each hour of the day?
--10. What was the volume of orders for each day of the week?
