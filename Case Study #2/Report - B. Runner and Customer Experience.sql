
**Query #1**

    -- C. Ingredient Optimisation
    
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

There are no results to be displayed.

---
**Query #2**

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

There are no results to be displayed.

---
**Query #3**

    -- Altering the type of several columns
    ALTER TABLE runner_orders
    ALTER COLUMN pickup_time TYPE TIMESTAMP USING NULLIF(pickup_time, '')::TIMESTAMP,
    ALTER COLUMN distance TYPE NUMERIC USING NULLIF(distance, '')::NUMERIC,
    ALTER COLUMN duration TYPE INTEGER USING NULLIF(duration, '')::INTEGER;

There are no results to be displayed.

---
**Query #4**

    WITH numbered_orders AS (
        SELECT 
            order_id,
            customer_id,
            pizza_id,
            exclusions,
            extras,
            ROW_NUMBER() OVER (ORDER BY order_id) AS record_id
        FROM customer_orders
    ),
    exclusions_cte AS (
        SELECT 
            record_id,
            TRIM(UNNEST(STRING_TO_ARRAY(exclusions, ',')))::INTEGER AS topping_id
        FROM numbered_orders
        WHERE exclusions != ''
    ),
    exclusions_names AS (
        SELECT 
            e.record_id,
            STRING_AGG(pt.topping_name, ', ') AS exclusions_list
        FROM exclusions_cte e
        JOIN pizza_toppings pt ON e.topping_id = pt.topping_id
        GROUP BY e.record_id
    ),
    extras_cte AS (
        SELECT 
            record_id,
            TRIM(UNNEST(STRING_TO_ARRAY(extras, ',')))::INTEGER AS topping_id
        FROM numbered_orders
        WHERE extras != ''
    ),
    extras_names AS (
        SELECT 
            e.record_id,
            STRING_AGG(pt.topping_name, ', ') AS extras_list
        FROM extras_cte e
        JOIN pizza_toppings pt ON e.topping_id = pt.topping_id
        GROUP BY e.record_id
    )
    
    SELECT 
        n.order_id,
        n.customer_id,
        CONCAT(
            pn.pizza_name,
            CASE WHEN ex.exclusions_list IS NOT NULL THEN ' - Exclude ' || ex.exclusions_list ELSE '' END,
            CASE WHEN xt.extras_list IS NOT NULL THEN ' - Extra ' || xt.extras_list ELSE '' END
        ) AS order_item
    FROM numbered_orders n
    JOIN pizza_names pn 
        ON n.pizza_id = pn.pizza_id
    LEFT JOIN exclusions_names ex 
        ON n.record_id = ex.record_id
    LEFT JOIN extras_names xt 
        ON n.record_id = xt.record_id
    ORDER BY n.order_id, n.record_id;

| order_id | customer_id | order_item                                                      |
| -------- | ----------- | --------------------------------------------------------------- |
| 1        | 101         | Meatlovers                                                      |
| 2        | 101         | Meatlovers                                                      |
| 3        | 102         | Meatlovers                                                      |
| 3        | 102         | Vegetarian                                                      |
| 4        | 103         | Meatlovers - Exclude Cheese                                     |
| 4        | 103         | Meatlovers - Exclude Cheese                                     |
| 4        | 103         | Vegetarian - Exclude Cheese                                     |
| 5        | 104         | Meatlovers - Extra Bacon                                        |
| 6        | 101         | Vegetarian                                                      |
| 7        | 105         | Vegetarian - Extra Bacon                                        |
| 8        | 102         | Meatlovers                                                      |
| 9        | 103         | Meatlovers - Exclude Cheese - Extra Bacon, Chicken              |
| 10       | 104         | Meatlovers                                                      |
| 10       | 104         | Meatlovers - Exclude BBQ Sauce, Mushrooms - Extra Bacon, Cheese |

---

[View on DB Fiddle](https://www.db-fiddle.com/f/7VcQKQwsS3CTkGRFG7vu98/4369)
