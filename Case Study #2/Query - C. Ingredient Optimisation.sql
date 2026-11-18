-- C. Ingredient Optimisation
-- 1.What are the standard ingredients for each pizza?
WITH table_one AS (
    SELECT 
        pizza_id,
        TRIM(UNNEST(STRING_TO_ARRAY(toppings, ',')))::INTEGER AS topping_id
    FROM pizza_recipes 
)
SELECT
	pizza_name,
	STRING_AGG(topping_name, ', ') AS standard_ingredients
FROM table_one t1 
LEFT JOIN pizza_toppings pt ON t1.topping_id = pt.topping_id
LEFT JOIN pizza_names pn ON t1.pizza_id = pn.pizza_id
GROUP BY pizza_name
ORDER BY pizza_name;
-- 2.What was the most commonly added extra?
-- 3.What was the most common exclusion?
-- 4.Generate an order item for each record in the customers_orders table in the format of one of the following:
-- Meat Lovers
-- Meat Lovers - Exclude Beef
-- Meat Lovers - Extra Bacon
-- Meat Lovers - Exclude Cheese, Bacon - Extra Mushroom, Peppers
-- 5.Generate an alphabetically ordered comma separated ingredient list for each pizza order from the customer_orders table and add a 2x in front of any relevant ingredients
-- For example: "Meat Lovers: 2xBacon, Beef, ... , Salami"
-- 6.What is the total quantity of each ingredient used in all delivered pizzas sorted by most frequent first?
