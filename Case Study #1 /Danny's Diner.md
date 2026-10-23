# 🍽 Case Study #1 - Danny's Diner

<p align="center">
    <img src="https://8weeksqlchallenge.com/images/case-study-designs/1.png" width="200">
</p>



**1. What is the total amount each customer spent at the restaurant?**
    
    SELECT
        s.customer_id,
        sum(m.price) as total_amount_spent
    FROM sales s 
    LEFT JOIN 
    menu m ON s.product_id=m.product_id
    GROUP BY s.customer_id
    ORDER BY s.customer_id ASC;

| customer_id | total_amount_spent |
| ----------- | ------------------ |
| A           | 76                 |
| B           | 74                 |
| C           | 36                 |

---
**2. How many days has each customer visited the restaurant?**
    
    SELECT
        s.customer_id,
        COUNT(DISTINCT s.order_date) as Days_Visited
    FROM sales s
    GROUP BY customer_id;

| customer_id | days_visited |
| ----------- | ------------ |
| A           | 4            |
| B           | 6            |
| C           | 2            |

---
**3. What was the first item from the menu purchased by each customer?**
    
    SELECT DISTINCT
        s.customer_id,
        m.product_name
    FROM sales s 
    LEFT JOIN
    menu m ON s.product_id=m.product_id
    WHERE s.order_date = (SELECT MIN(s2.order_date)
                        FROM sales s2
                        WHERE s.customer_id=s2.customer_id);

| customer_id | product_name |
| ----------- | ------------ |
| A           | curry        |
| A           | sushi        |
| B           | curry        |
| C           | ramen        |

---
**4. What is the most purchased item on the menu and how many times was it purchased by all customers?**
    
    SELECT
        m.product_name,
        COUNT(s.customer_id) as total_purchases
    FROM sales s 
    LEFT JOIN
    menu m ON s.product_id=m.product_id
    GROUP BY m.product_name
    ORDER BY total_purchases DESC
    LIMIT 1;

| product_name | total_purchases |
| ------------ | --------------- |
| ramen        | 8               |

---
**5. Which item was the most popular for each customer?**

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

| customer_id | most_popular | quantity |
| ----------- | ------------ | -------- |
| A           | ramen        | 3        |
| B           | ramen        | 2        |
| B           | curry        | 2        |
| B           | sushi        | 2        |
| C           | ramen        | 3        |

---
**6. Which item was purchased first by the customer after they became a member?**

    WITH posmember AS(
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
    FROM posmember b
    LEFT JOIN menu m ON b.product_id = m.product_id
    WHERE b.order_date = (
      						SELECT MIN(s2.order_date)
                            FROM posmember s2
                            WHERE b.customer_id=s2.customer_id);

| product_name | customer_id | order_date |
| ------------ | ----------- | ---------- |
| ramen        | A           | 2021-01-10 |
| sushi        | B           | 2021-01-11 |

---
**7. Which item was purchased just before the customer became a member?**

    WITH premember AS(
    	SELECT
      	 	s.customer_id,
            s.product_id,
      		s.order_date,
      		DENSE_RANK() OVER(
            	PARTITION BY s.customer_id
            	ORDER BY s.order_date DESC 
            ) AS ranking
     	FROM sales s
        LEFT JOIN members me ON s.customer_id = me.customer_id
        WHERE s.order_date<me.join_date  
    )
    
    SELECT
    	m.product_name,
        b.customer_id,
        b.order_date
    FROM premember b
    LEFT JOIN menu m ON b.product_id = m.product_id
    WHERE RANKING = 1
    ORDER BY b.customer_id ASC;

| product_name | customer_id | order_date |
| ------------ | ----------- | ---------- |
| sushi        | A           | 2021-01-01 |
| curry        | A           | 2021-01-01 |
| sushi        | B           | 2021-01-04 |

---
**8. What is the total items and amount spent for each member before they became a member?**

    WITH premember AS(
    	SELECT
      	 	s.customer_id,
            s.product_id,
      		s.order_date,
      		DENSE_RANK() OVER(
            	PARTITION BY s.customer_id
            	ORDER BY s.order_date DESC 
            ) AS ranking
     	FROM sales s
        LEFT JOIN members me ON s.customer_id = me.customer_id
        WHERE s.order_date<me.join_date  
    )
    
    SELECT
    	b.customer_id,
        count(b.product_id) AS Total_Items,
        SUM(m.price) AS Amount_Spent
    FROM premember b
    LEFT JOIN menu m ON b.product_id = m.product_id
    GROUP BY customer_id
    ORDER BY customer_id;

| customer_id | total_items | amount_spent |
| ----------- | ----------- | ------------ |
| A           | 2           | 25           |
| B           | 3           | 40           |

---

**9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?**

    WITH cte_point AS(
    	SELECT
      		product_id,
      		CASE
      			WHEN product_name = 'sushi' THEN price*20
      			ELSE price*10 END AS points
      	FROM menu
    )
    
    SELECT 
    	s.customer_id,
        SUM(p.points) AS Total_Points
    FROM sales s
    LEFT JOIN cte_point p ON s.product_id = p.product_id
    GROUP BY s.customer_id
    ORDER BY s.customer_id;

| customer_id | total_points |
| ----------- | ------------ |
| A           | 860          |
| B           | 940          |
| C           | 360          |

---
**10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?**
    SELECT
        s.customer_id,
        SUM(
            CASE
                WHEN s.order_date BETWEEN mem.join_date AND (mem.join_date + 6) THEN m.price * 20
                WHEN m.product_name = 'sushi' THEN m.price * 20
                ELSE m.price * 10
            END
        ) AS total_points
    FROM sales s
    JOIN menu m ON s.product_id = m.product_id
    JOIN members mem ON s.customer_id = mem.customer_id
    WHERE s.order_date <= '2021-01-31'
    GROUP BY s.customer_id
    ORDER BY s.customer_id

| customer_id | total_points |
| ----------- | ------------ |
| A           | 1370         |
| B           | 820          |

---



