
**Query #1**

    -- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?
    
    SELECT
        *,
        order_date + 365 AS uma_semana
    FROM sales

| customer_id | order_date | product_id | uma_semana |
| ----------- | ---------- | ---------- | ---------- |
| A           | 2021-01-01 | 1          | 2022-01-01 |
| A           | 2021-01-01 | 2          | 2022-01-01 |
| A           | 2021-01-07 | 2          | 2022-01-07 |
| A           | 2021-01-10 | 3          | 2022-01-10 |
| A           | 2021-01-11 | 3          | 2022-01-11 |
| A           | 2021-01-11 | 3          | 2022-01-11 |
| B           | 2021-01-01 | 2          | 2022-01-01 |
| B           | 2021-01-02 | 2          | 2022-01-02 |
| B           | 2021-01-04 | 1          | 2022-01-04 |
| B           | 2021-01-11 | 1          | 2022-01-11 |
| B           | 2021-01-16 | 3          | 2022-01-16 |
| B           | 2021-02-01 | 3          | 2022-02-01 |
| C           | 2021-01-01 | 3          | 2022-01-01 |
| C           | 2021-01-01 | 3          | 2022-01-01 |
| C           | 2021-01-07 | 3          | 2022-01-07 |

---

[View on DB Fiddle](https://www.db-fiddle.com/f/2rM8RAnq7h5LLDTzZiRWcd/138)
