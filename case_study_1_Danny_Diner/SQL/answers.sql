/*
Answers to Case Study 1: Danny's Diner

Questions:

1. What is the total amount each customer spent at the restaurant?
2. How many days has each customer visited the restaurant?
3. What was the first item from the menu purchased by each customer?
4. What is the most purchased item on the menu and how many times was it purchased by all customers?
5. Which item was the most popular for each customer?
6. Which item was purchased first by the customer after they became a member?
7. Which item was purchased just before the customer became a member?
8. What is the total items and amount spent for each member before they became a member?
9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?

*/

-- 1. What is the total amount each customer spent at the restaurant?
SELECT 
    customer_id,
    SUM(price) as total_sales
FROM dannys_diner.sales
INNER JOIN dannys_diner.menu
    ON menu.product_id = sales.product_id
GROUP BY customer_id
ORDER BY customer_id ASC;

-- 2. How many days has each customer visited the restaurant?
SELECT
    customer_id,
    COUNT(DISTINCT order_date) AS total_vists
FROM dannys_diner.sales
GROUP BY customer_id
ORDER BY customer_id ASC;

-- 3. What was the first item from the menu purchased by each customer?
WITH sales_cte AS (
    SELECT
        sales.customer_id,
        sales.order_date,
        menu.product_name,
        DENSE_RANK() OVER (
            PARTITION BY sales.customer_id
            ORDER BY sales.order_date
        ) AS rank
    FROM dannys_diner.sales
    INNER JOIN dannys_diner.menu
        ON menu.product_id = sales.product_id
)
SELECT
    customer_id,
    product_name
FROM sales_cte
WHERE rank = 1;

-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?
SELECT 
    menu.product_name,
    COUNT(product_name) AS total_purchased
FROM dannys_diner.sales
INNER JOIN dannys_diner.menu
    ON sales.product_id = menu.product_id
GROUP BY product_name
ORDER BY total_purchased DESC;

-- 5. Which item was the most popular for each customer?
WITH cte AS (
    SELECT
        sales.customer_id,
        menu.product_name,
        COUNT(sales.product_id) AS total_purchased,
        DENSE_RANK() OVER (
            PARTITION BY customer_id
            ORDER BY COUNT(sales.product_id) DESC
        ) AS rank
    FROM dannys_diner.sales
    INNER JOIN dannys_diner.menu
        ON menu.product_id = sales.product_id
    GROUP BY customer_id, product_name
)
SELECT
    customer_id,
    product_name,
    total_purchased
FROM cte
WHERE rank = 1;

-- 6. Which item was purchased first by the customer after they became a member?
WITH cte AS (
    SELECT
        sales.customer_id,
        sales.order_date,
        members.join_date,
        sales.product_id,
        menu.product_name,
        DENSE_RANK() OVER (
            PARTITION BY sales.customer_id
            ORDER BY sales.order_date ASC
        ) AS rank
    FROM dannys_diner.sales
    INNER JOIN dannys_diner.members
        ON sales.customer_id = members.customer_id
    INNER JOIN dannys_diner.menu
        ON sales.product_id = menu.product_id
    WHERE sales.order_date > members.join_date
    ORDER BY sales.customer_id, sales.order_date
)
SELECT
    customer_id,
    order_date,
    join_date,
    product_name
FROM cte
WHERE rank = 1;

-- 7. Which item was purchased just before the customer became a member?
WITH cte AS (
    SELECT
        sales.customer_id,
        members.join_date,
        sales.order_date,
        menu.product_name,
        DENSE_RANK() OVER (
            PARTITION BY sales.customer_id
            ORDER BY sales.order_date DESC
        ) AS rank
    FROM dannys_diner.sales
    INNER JOIN dannys_diner.menu
        ON menu.product_id = sales.product_id
    INNER JOIN dannys_diner.members
        ON members.customer_id = sales.customer_id
    WHERE sales.order_date < members.join_date
)
SELECT
    customer_id,
    product_name
FROM cte
WHERE rank = 1;

-- 8. What is the total items and amount spent for each member before they became a member?
WITH purchase_before_membership AS (
    SELECT
        sales.customer_id,
        members.join_date,
        sales.order_date,
        menu.product_name,
        menu.price
    FROM dannys_diner.sales
    INNER JOIN dannys_diner.menu
        ON menu.product_id = sales.product_id
    INNER JOIN dannys_diner.members
        ON members.customer_id = sales.customer_id
    WHERE sales.order_date < members.join_date
    ORDER BY sales.customer_id, sales.order_date
)
SELECT
    cte.customer_id,
    COUNT(cte.product_name) AS total_items,
    SUM(cte.price) AS total_price
FROM purchase_before_membership AS cte
GROUP BY customer_id;

-- 9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
WITH points_cte AS (
    SELECT
        sales.customer_id,
        menu.product_name,
        menu.price,
        CASE
            WHEN sales.product_id = 1 THEN menu.price * 20
            ELSE menu.price * 10
        END AS points
    FROM dannys_diner.sales
    INNER JOIN dannys_diner.menu
        ON menu.product_id = sales.product_id
    ORDER BY sales.customer_id
)
SELECT
    cte.customer_id,
    SUM(points) AS total_points
FROM points_cte AS cte
GROUP BY cte.customer_id;

-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?
WITH members_cte AS (
    SELECT
        sales.customer_id,
        members.join_date,
        sales.order_date,
        sales.product_id,
        menu.price,
        (
            sales.order_date >= members.join_date AND
            sales.order_date <= members.join_date + 6
        ) AS is_valid
    FROM dannys_diner.sales
    INNER JOIN dannys_diner.members
        ON members.customer_id = sales.customer_id
    INNER JOIN dannys_diner.menu
        ON menu.product_id = sales.product_id
    WHERE (
        EXTRACT(MONTH FROM sales.order_date) = 1
    )
    ORDER BY sales.customer_id, sales.order_date
),
points_cte AS (
    SELECT
        *,
        CASE
            WHEN (cte1.is_valid) THEN cte1.price * 20
            WHEN (NOT cte1.is_valid AND cte1.product_id = 1) THEN cte1.price * 20
            ELSE cte1.price * 10
        END AS points
    FROM members_cte AS cte1
)
SELECT
    cte2.customer_id,
    SUM(cte2.points) AS total_points
FROM points_cte AS cte2
GROUP BY cte2.customer_id;
