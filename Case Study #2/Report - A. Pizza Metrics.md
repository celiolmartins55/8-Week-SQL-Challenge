# Case Study #2- A.Pizza Metrics

### Following the `Data Cleaning` phase, the case study advances to the first analytical area: Pizza Metrics.
---

**1. How many pizzas were ordered?**
    
    SELECT 
    	COUNT(*) as pizzas
    FROM customer_orders;

| pizzas |
| ------ |
| 14     |

The total of pizzas ordered was 14.

---
**2. How many unique customer orders were made?**
    
    SELECT
    	 COUNT(DISTINCT order_id) as unique_oders
     FROM customer_orders;

| unique_oders |
| ------------ |
| 10           |

Given a total volume of 14 pizzas across 10 distinct orders, it is evident that several orders contained multiple items.

---
**3. How many successful orders were delivered by each runner?**

    SELECT
    	runner_id,
    	COUNT (*) as orders_delivered
    FROM runner_orders
    WHERE cancellation LIKE ''
    GROUP BY runner_id
    ORDER BY runner_id;;

| runner_id | orders_delivered |
| --------- | ---------------- |
| 1         | 4                |
| 2         | 3                |
| 3         | 1                |

---
**4. How many of each type of pizza was delivered?**

    SELECT
    	pizza_id,
    	COUNT (*)
    FROM customer_orders
    GROUP BY pizza_id;

| pizza_id | count |
| -------- | ----- |
| 2        | 4     |
| 1        | 10    |

---
**5. How many Vegetarian and Meatlovers were ordered by each customer?**

    SELECT
        customer_id,
        COUNT(pizza_id) FILTER (WHERE pizza_id = 2) AS vegetarian_ordered,
        COUNT(pizza_id) FILTER (WHERE pizza_id = 1) AS meatlovers_ordered
    FROM customer_orders
    GROUP BY customer_id
    ORDER BY customer_id;

| customer_id | vegetarian_ordered | meatlovers_ordered |
| ----------- | ------------------ | ------------------ |
| 101         | 1                  | 2                  |
| 102         | 1                  | 2                  |
| 103         | 1                  | 3                  |
| 104         | 0                  | 3                  |
| 105         | 1                  | 0                  |

---
**6. What was the maximum number of pizzas delivered in a single order?**

    WITH maxi_order AS (
      SELECT
          c.order_id,
          COUNT(*) AS pizzas_delivered
      FROM customer_orders c
      LEFT JOIN runner_orders r ON c.order_id=r.order_id
      WHERE cancellation LIKE ''
      GROUP BY c.order_id
      ORDER BY c.order_id
    )
    
    SELECT
        order_id,
        pizzas_delivered
    FROM maxi_order
    WHERE pizzas_delivered = (SELECT MAX(pizzas_delivered) FROM maxi_order);

| order_id | pizzas_delivered |
| -------- | ---------------- |
| 4        | 3                |

---
**7. For each customer, how many delivered pizzas had at least 1 change and how many had no changes?**

    SELECT
    	c.customer_id,
    	SUM(CASE WHEN c.exclusions = '' AND c.extras = '' THEN 1
            ELSE 0
           END) AS no_change,
        SUM(CASE WHEN c.exclusions != '' OR c.extras != '' THEN 1
            ELSE 0
            END) AS one_change_at_least
    FROM customer_orders c
    LEFT JOIN runner_orders r ON c.order_id=r.order_id
    WHERE cancellation = ''
    GROUP BY c.customer_id
    ORDER BY c.customer_id;

| customer_id | no_change | one_change_at_least |
| ----------- | --------- | ------------------- |
| 101         | 2         | 0                   |
| 102         | 3         | 0                   |
| 103         | 0         | 3                   |
| 104         | 1         | 2                   |
| 105         | 0         | 1                   |

---
**8. How many pizzas were delivered that had both exclusions and extras?**

    WITH odboth AS (
        SELECT 
            order_id,
            CASE 
                WHEN exclusions != '' AND extras != '' THEN 'Both'
      			WHEN exclusions = '' AND extras != '' THEN 'Just extras'
      			WHEN exclusions != '' AND extras = '' THEN 'Just exclusions'
                ELSE 'No' 
            END AS order_with_both
        FROM customer_orders
    )
    
    SELECT COUNT(*) 
    FROM odboth
    WHERE order_with_both = 'Both';

| count |
| ----- |
| 2     |

---
**9. What was the total volume of pizzas ordered for each hour of the day?**

     SELECT
     	EXTRACT(HOUR FROM order_time) AS hour,
     	COUNT(*)
    FROM customer_orders
    GROUP BY EXTRACT(HOUR FROM order_time)
    ORDER BY hour;

| hour | count |
| ---- | ----- |
| 11   | 1     |
| 13   | 3     |
| 18   | 3     |
| 19   | 1     |
| 21   | 3     |
| 23   | 3     |

---
**10. What was the volume of orders for each day of the week?**

    SELECT 
        TO_CHAR(order_time, 'Day') AS day_week, 
        COUNT(order_id) AS volume_orders
    FROM 
        customer_orders
    GROUP BY TO_CHAR(order_time, 'Day')
    ORDER BY volume_orders DESC;

| day_week  | volume_orders |
| --------- | ------------- |
| Saturday  | 5             |
| Wednesday | 5             |
| Thursday  | 3             |
| Friday    | 1             |


