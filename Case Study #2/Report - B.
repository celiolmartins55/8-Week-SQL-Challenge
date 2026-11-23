**Schema (PostgreSQL v13)**

    CREATE SCHEMA pizza_runner;
    SET search_path = pizza_runner;
    
    DROP TABLE IF EXISTS runners;
    CREATE TABLE runners (
      "runner_id" INTEGER,
      "registration_date" DATE
    );
    INSERT INTO runners
      ("runner_id", "registration_date")
    VALUES
      (1, '2021-01-01'),
      (2, '2021-01-03'),
      (3, '2021-01-08'),
      (4, '2021-01-15');
    
    
    DROP TABLE IF EXISTS customer_orders;
    CREATE TABLE customer_orders (
      "order_id" INTEGER,
      "customer_id" INTEGER,
      "pizza_id" INTEGER,
      "exclusions" VARCHAR(4),
      "extras" VARCHAR(4),
      "order_time" TIMESTAMP
    );
    
    INSERT INTO customer_orders
      ("order_id", "customer_id", "pizza_id", "exclusions", "extras", "order_time")
    VALUES
      ('1', '101', '1', '', '', '2020-01-01 18:05:02'),
      ('2', '101', '1', '', '', '2020-01-01 19:00:52'),
      ('3', '102', '1', '', '', '2020-01-02 23:51:23'),
      ('3', '102', '2', '', NULL, '2020-01-02 23:51:23'),
      ('4', '103', '1', '4', '', '2020-01-04 13:23:46'),
      ('4', '103', '1', '4', '', '2020-01-04 13:23:46'),
      ('4', '103', '2', '4', '', '2020-01-04 13:23:46'),
      ('5', '104', '1', 'null', '1', '2020-01-08 21:00:29'),
      ('6', '101', '2', 'null', 'null', '2020-01-08 21:03:13'),
      ('7', '105', '2', 'null', '1', '2020-01-08 21:20:29'),
      ('8', '102', '1', 'null', 'null', '2020-01-09 23:54:33'),
      ('9', '103', '1', '4', '1, 5', '2020-01-10 11:22:59'),
      ('10', '104', '1', 'null', 'null', '2020-01-11 18:34:49'),
      ('10', '104', '1', '2, 6', '1, 4', '2020-01-11 18:34:49');
    
    
    DROP TABLE IF EXISTS runner_orders;
    CREATE TABLE runner_orders (
      "order_id" INTEGER,
      "runner_id" INTEGER,
      "pickup_time" VARCHAR(19),
      "distance" VARCHAR(7),
      "duration" VARCHAR(10),
      "cancellation" VARCHAR(23)
    );
    
    INSERT INTO runner_orders
      ("order_id", "runner_id", "pickup_time", "distance", "duration", "cancellation")
    VALUES
      ('1', '1', '2020-01-01 18:15:34', '20km', '32 minutes', ''),
      ('2', '1', '2020-01-01 19:10:54', '20km', '27 minutes', ''),
      ('3', '1', '2020-01-03 00:12:37', '13.4km', '20 mins', NULL),
      ('4', '2', '2020-01-04 13:53:03', '23.4', '40', NULL),
      ('5', '3', '2020-01-08 21:10:57', '10', '15', NULL),
      ('6', '3', 'null', 'null', 'null', 'Restaurant Cancellation'),
      ('7', '2', '2020-01-08 21:30:45', '25km', '25mins', 'null'),
      ('8', '2', '2020-01-10 00:15:02', '23.4 km', '15 minute', 'null'),
      ('9', '2', 'null', 'null', 'null', 'Customer Cancellation'),
      ('10', '1', '2020-01-11 18:50:20', '10km', '10minutes', 'null');
    
    
    DROP TABLE IF EXISTS pizza_names;
    CREATE TABLE pizza_names (
      "pizza_id" INTEGER,
      "pizza_name" TEXT
    );
    INSERT INTO pizza_names
      ("pizza_id", "pizza_name")
    VALUES
      (1, 'Meatlovers'),
      (2, 'Vegetarian');
    
    
    DROP TABLE IF EXISTS pizza_recipes;
    CREATE TABLE pizza_recipes (
      "pizza_id" INTEGER,
      "toppings" TEXT
    );
    INSERT INTO pizza_recipes
      ("pizza_id", "toppings")
    VALUES
      (1, '1, 2, 3, 4, 5, 6, 8, 10'),
      (2, '4, 6, 7, 9, 11, 12');
    
    
    DROP TABLE IF EXISTS pizza_toppings;
    CREATE TABLE pizza_toppings (
      "topping_id" INTEGER,
      "topping_name" TEXT
    );
    INSERT INTO pizza_toppings
      ("topping_id", "topping_name")
    VALUES
      (1, 'Bacon'),
      (2, 'BBQ Sauce'),
      (3, 'Beef'),
      (4, 'Cheese'),
      (5, 'Chicken'),
      (6, 'Mushrooms'),
      (7, 'Onions'),
      (8, 'Pepperoni'),
      (9, 'Peppers'),
      (10, 'Salami'),
      (11, 'Tomatoes'),
      (12, 'Tomato Sauce');

---

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
