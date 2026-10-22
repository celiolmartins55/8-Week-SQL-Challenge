/* --------------------
   Case Study Questions
   --------------------*/

-- 1. What is the total amount each customer spent at the restaurant?
SELECT
	s.customer_id,
    sum(m.price) as total_amount_spent
FROM sales s 
LEFT JOIN 
menu m ON s.product_id=m.product_id
GROUP BY s.customer_id
ORDER BY s.customer_id ASC;
-- 2. How many days has each customer visited the restaurant?
SELECT
	s.customer_id,
    COUNT(DISTINCT s.order_date) as Days_Visited
FROM sales s
GROUP BY customer_id;
-- 3. What was the first item from the menu purchased by each customer?
SELECT DISTINCT
	s.customer_id,
    m.product_name
FROM sales s 
LEFT JOIN
menu m ON s.product_id=m.product_id
WHERE s.order_date = (
  						SELECT MIN(s2.order_date)
                        FROM sales s2
                        WHERE s.customer_id=s2.customer_id);                                 
-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?
SELECT
	m.product_name,
    COUNT(s.customer_id) as total_purchases
FROM sales s 
LEFT JOIN
menu m ON s.product_id=m.product_id
GROUP BY m.product_name
ORDER BY total_purchases DESC
LIMIT 1;
-- 5. Which item was the most popular for each customer?
WITH RankProdutos AS (
    SELECT
        s.customer_id,
        m.product_name,
        COUNT(s.product_id) AS quantity,
        DENSE_RANK() OVER (
            PARTITION BY s.customer_id 
            ORDER BY COUNT(s.product_id) DESC
        ) AS ranking
    FROM sales s
    LEFT JOIN menu m ON s.product_id = m.product_id
    GROUP BY s.customer_id, m.product_name
)

SELECT
	customer_id,
    product_name as most_popular,
    quantity
FROM RankProdutos
WHERE ranking=1;
-- 6. Which item was purchased first by the customer after they became a member?
WITH memb AS(
	SELECT
  	 	s.customer_id,
        s.product_id,
        s.order_date
 	FROM sales s
    LEFT JOIN members me ON s.customer_id = me.customer_id
    WHERE s.order_date>me.join_date  
)

SELECT
	m.product_name,
    b.customer_id,
    b.order_date
FROM memb b
LEFT JOIN menu m ON b.product_id = m.product_id
WHERE b.order_date = (
  						SELECT MIN(s2.order_date)
                        FROM memb s2
                        WHERE b.customer_id=s2.customer_id); 
-- 7. Which item was purchased just before the customer became a member?
-- 8. What is the total items and amount spent for each member before they became a member?
-- 9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?

