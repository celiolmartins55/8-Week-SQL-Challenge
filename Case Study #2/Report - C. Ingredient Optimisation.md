# 🥓Case Study #2 - C. Ingredient Optimisation

### Following the `Data Cleaning` phase, the case study advances to the third analytical area: Ingredient Optimisation.

---
**1. What are the standard ingredients for each pizza?**

    WITH table_one AS (
        SELECT 
            pizza_id,
            TRIM(UNNEST(STRING_TO_ARRAY(toppings, ',')))::INTEGER AS topping_id
        FROM pizza_recipes 
    )
    SELECT
    	pn.pizza_name,
    	STRING_AGG(pt.topping_name, ', ') AS standard_ingredients
    FROM table_one t1 
    LEFT JOIN pizza_toppings pt ON t1.topping_id = pt.topping_id
    LEFT JOIN pizza_names pn ON t1.pizza_id = pn.pizza_id
    GROUP BY pizza_name
    ORDER BY pizza_name;

| pizza_name | standard_ingredients                                                  |
| ---------- | --------------------------------------------------------------------- |
| Meatlovers | BBQ Sauce, Pepperoni, Cheese, Salami, Chicken, Bacon, Mushrooms, Beef |
| Vegetarian | Tomato Sauce, Cheese, Mushrooms, Onions, Peppers, Tomatoes            |

The default ingredient profiles for each pizza are entirely distinct.

---
**2. What was the most commonly added extra?**

    WITH table_two AS(
    	SELECT
        	TRIM(UNNEST(STRING_TO_ARRAY(extras, ',')))::INTEGER AS extras_id
    	FROM customer_orders)
    SELECT
    	topping_name AS most_commonly_extra,
        COUNT(t2.extras_id) AS count_extra
    FROM table_two t2 LEFT JOIN pizza_toppings pt ON extras_id = topping_id
    GROUP BY pt.topping_name
    ORDER BY count_extra DESC LIMIT 1;

| most_commonly_extra | count_extra |
| ------------------- | ----------- |
| Bacon               | 4           |

Although 'Meatlovers' already contains bacon in its default recipe, it was the most requested extra ingredient.

---
**3. What was the most common exclusion?**
    
    WITH table_three AS(
    	SELECT
        	TRIM(UNNEST(STRING_TO_ARRAY(exclusions, ',')))::INTEGER AS exclusions_id
    	FROM customer_orders)
    SELECT
    	topping_name AS most_common_exclusion,
        COUNT(t3.exclusions_id) AS count_exclusions
    FROM table_three t3 LEFT JOIN pizza_toppings pt ON exclusions_id = topping_id
    GROUP BY pt.topping_name
    ORDER BY count_exclusions DESC LIMIT 1;

| most_common_exclusion | count_exclusions |
| --------------------- | ---------------- |
| Cheese                | 4                |

The frequent exclusion of cheese can likely be attributed to dietary restrictions, such as lactose intolerance.

---
**4. Generate an order item for each record in the customers_orders table in the format of one of the following:** 
- *Meat Lovers*
- *Meat Lovers - Exclude Beef*
- *Meat Lovers - Extra Bacon*
- *Meat Lovers - Exclude Cheese, Bacon - Extra Mushroom, Peppers*

``` 
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
```

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

**5. Generate an alphabetically ordered comma separated ingredient list for each pizza order from the customer_orders table and add a 2x in front of any relevant ingredients.**
*For example: "Meat Lovers: 2xBacon, Beef, ... , Salami"*

    WITH numbered_orders AS (
        SELECT 
            order_id,
            pizza_id,
            exclusions,
            extras,
            ROW_NUMBER() OVER (ORDER BY order_id) AS record_id
        FROM customer_orders
    ),
    standard_recipe AS (
        SELECT 
            pizza_id,
            TRIM(UNNEST(STRING_TO_ARRAY(toppings, ',')))::INTEGER AS topping_id
        FROM pizza_recipes
    ),
    base_pizza_ingredients AS (
        SELECT 
            n.record_id,
            n.order_id,
            n.pizza_id,
            sr.topping_id
        FROM numbered_orders n
        JOIN standard_recipe sr 
            ON n.pizza_id = sr.pizza_id
    ),
    exclusions_cte AS (
        SELECT 
            record_id,
            TRIM(UNNEST(STRING_TO_ARRAY(exclusions, ',')))::INTEGER AS topping_id
        FROM numbered_orders
        WHERE exclusions IS NOT NULL AND exclusions != ''
    ),
    extras_cte AS (
        SELECT 
            record_id,
            order_id,
            pizza_id,
            TRIM(UNNEST(STRING_TO_ARRAY(extras, ',')))::INTEGER AS topping_id
        FROM numbered_orders
        WHERE extras IS NOT NULL AND extras != ''
    ),
    pizza_assembly AS (
        SELECT b.record_id, b.order_id, b.pizza_id, b.topping_id
        FROM base_pizza_ingredients b
        LEFT JOIN exclusions_cte exc 
            ON b.record_id = exc.record_id AND b.topping_id = exc.topping_id
        WHERE exc.topping_id IS NULL 
        UNION ALL
        SELECT record_id, order_id, pizza_id, topping_id 
        FROM extras_cte
    ),
    ingredient_counts AS (
        SELECT 
            pa.record_id,
            pa.order_id,
            pa.pizza_id,
            pt.topping_name,
            COUNT(pa.topping_id) AS count_ingred
        FROM pizza_assembly pa
        JOIN pizza_toppings pt 
            ON pa.topping_id = pt.topping_id
        GROUP BY pa.record_id, pa.order_id, pa.pizza_id, pt.topping_name
    )
    
    SELECT 
        ic.order_id,
        CONCAT(
            pn.pizza_name, 
            ': ', 
            STRING_AGG(
                CASE 
                    WHEN ic.count_ingred> 1 THEN ic.count_ingred || 'x' || ic.topping_name 
                    ELSE ic.topping_name 
                END, 
                ', ' ORDER BY ic.topping_name ASC 
            )
        ) AS ingredient_list
    FROM ingredient_counts ic
    JOIN pizza_names pn 
        ON ic.pizza_id = pn.pizza_id
    GROUP BY ic.record_id, ic.order_id, pn.pizza_name
    ORDER BY ic.order_id, ic.record_id;


| order_id | ingredient_list                                                                     |
| -------- | ----------------------------------------------------------------------------------- |
| 1        | Meatlovers: BBQ Sauce, Bacon, Beef, Cheese, Chicken, Mushrooms, Pepperoni, Salami   |
| 2        | Meatlovers: BBQ Sauce, Bacon, Beef, Cheese, Chicken, Mushrooms, Pepperoni, Salami   |
| 3        | Meatlovers: BBQ Sauce, Bacon, Beef, Cheese, Chicken, Mushrooms, Pepperoni, Salami   |
| 3        | Vegetarian: Cheese, Mushrooms, Onions, Peppers, Tomato Sauce, Tomatoes              |
| 4        | Meatlovers: BBQ Sauce, Bacon, Beef, Chicken, Mushrooms, Pepperoni, Salami           |
| 4        | Meatlovers: BBQ Sauce, Bacon, Beef, Chicken, Mushrooms, Pepperoni, Salami           |
| 4        | Vegetarian: Mushrooms, Onions, Peppers, Tomato Sauce, Tomatoes                      |
| 5        | Meatlovers: BBQ Sauce, 2xBacon, Beef, Cheese, Chicken, Mushrooms, Pepperoni, Salami |
| 6        | Vegetarian: Cheese, Mushrooms, Onions, Peppers, Tomato Sauce, Tomatoes              |
| 7        | Vegetarian: Bacon, Cheese, Mushrooms, Onions, Peppers, Tomato Sauce, Tomatoes       |
| 8        | Meatlovers: BBQ Sauce, Bacon, Beef, Cheese, Chicken, Mushrooms, Pepperoni, Salami   |
| 9        | Meatlovers: BBQ Sauce, 2xBacon, Beef, 2xChicken, Mushrooms, Pepperoni, Salami       |
| 10       | Meatlovers: BBQ Sauce, Bacon, Beef, Cheese, Chicken, Mushrooms, Pepperoni, Salami   |
| 10       | Meatlovers: 2xBacon, Beef, 2xCheese, Chicken, Pepperoni, Salami                     |

---
**6. What is the total quantity of each ingredient used in all delivered pizzas sorted by most frequent first?**

    WITH numbered_orders AS (
        SELECT 
            order_id,
            pizza_id,
            exclusions,
            extras,
            ROW_NUMBER() OVER (ORDER BY order_id) AS record_id
        FROM customer_orders
    ),
    standard_recipe AS (
        SELECT 
            pizza_id,
            TRIM(UNNEST(STRING_TO_ARRAY(toppings, ',')))::INTEGER AS topping_id
        FROM pizza_recipes
    ),
    base_pizza_ingredients AS (
        SELECT 
            n.record_id,
            n.order_id,
            n.pizza_id,
            sr.topping_id
        FROM numbered_orders n
        JOIN standard_recipe sr 
            ON n.pizza_id = sr.pizza_id
    ),
    exclusions_cte AS (
        SELECT 
            record_id,
            TRIM(UNNEST(STRING_TO_ARRAY(exclusions, ',')))::INTEGER AS topping_id
        FROM numbered_orders
        WHERE exclusions IS NOT NULL AND exclusions != ''
    ),
    extras_cte AS (
        SELECT 
            record_id,
            order_id,
            pizza_id,
            TRIM(UNNEST(STRING_TO_ARRAY(extras, ',')))::INTEGER AS topping_id
        FROM numbered_orders
        WHERE extras IS NOT NULL AND extras != ''
    ),
    pizza_assembly AS (
        SELECT b.record_id, b.order_id, b.pizza_id, b.topping_id
        FROM base_pizza_ingredients b
        LEFT JOIN exclusions_cte exc 
            ON b.record_id = exc.record_id AND b.topping_id = exc.topping_id
        WHERE exc.topping_id IS NULL 
        UNION ALL
        SELECT record_id, order_id, pizza_id, topping_id 
        FROM extras_cte
    ),
    ingredient_counts AS (
        SELECT 
            pa.record_id,
            pa.order_id,
            pa.pizza_id,
            pt.topping_name,
            COUNT(pa.topping_id) AS count_ingred
        FROM pizza_assembly pa
        JOIN pizza_toppings pt 
            ON pa.topping_id = pt.topping_id
        GROUP BY pa.record_id, pa.order_id, pa.pizza_id, pt.topping_name
    )
    
    SELECT
        ic.topping_name AS ingredient,
        SUM(ic.count_ingred) AS quantity
    FROM ingredient_counts ic
    GROUP BY ingredient
    ORDER BY quantity DESC;

| ingredient   | quantity |
| ------------ | -------- |
| Bacon        | 14       |
| Mushrooms    | 13       |
| Chicken      | 11       |
| Cheese       | 11       |
| Pepperoni    | 10       |
| Salami       | 10       |
| Beef         | 10       |
| BBQ Sauce    | 9        |
| Tomato Sauce | 4        |
| Onions       | 4        |
| Tomatoes     | 4        |
| Peppers      | 4        |

As anticipated, since it is a standard ingredient and the most requested extra, bacon was the most frequently used item. Although it was the most common exclusion, cheese still ranked as the fourth highest ingredient by volume.
