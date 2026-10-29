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
--1. How many pizzas were ordered?
SELECT COUNT(*) as pizzas
FROM customer_orders
--2. How many unique customer orders were made?
--3. How many successful orders were delivered by each runner?
--4. How many of each type of pizza was delivered?
--5. How many Vegetarian and Meatlovers were ordered by each customer?
--6. What was the maximum number of pizzas delivered in a single order?
--7. For each customer, how many delivered pizzas had at least 1 change and how many had no changes?
--8. How many pizzas were delivered that had both exclusions and extras?
--9. What was the total volume of pizzas ordered for each hour of the day?
--10. What was the volume of orders for each day of the week?
