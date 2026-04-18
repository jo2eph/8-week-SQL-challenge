/*
Answer for bonus question for Danny Diner case study.
*/

-- Join All The Things
SELECT
    sales.customer_id,
    sales.order_date,
    menu.product_name,
    menu.price,
    CASE
        WHEN (
            members.join_date IS NOT NULL AND
            sales.order_date >= members.join_date) THEN 'Y'
        WHEN (
            members.join_date IS NOT NULL AND
            sales.order_date < members.join_date) THEN 'N'
        ELSE 'N'        
    END AS member
FROM dannys_diner.sales
INNER JOIN dannys_diner.menu
    ON menu.product_id = sales.product_id
LEFT JOIN dannys_diner.members
    ON sales.customer_id = members.customer_id
ORDER BY sales.customer_id, sales.order_date, menu.product_name;

-- Rank All The Things
WITH members_cte AS (
    SELECT
        sales.customer_id,
        sales.order_date,
        menu.product_name,
        menu.price,
        CASE
            WHEN (
              members.join_date IS NOT NULL AND
              sales.order_date >= members.join_date) THEN 'Y'
            WHEN (
              members.join_date IS NOT NULL AND
              sales.order_date < members.join_date) THEN 'N'
            ELSE 'N'        
        END AS member
    FROM dannys_diner.sales
    INNER JOIN dannys_diner.menu
        ON menu.product_id = sales.product_id
    LEFT JOIN dannys_diner.members
        ON sales.customer_id = members.customer_id
    ORDER BY sales.customer_id, sales.order_date, menu.product_name
),
members_ranking_cte AS (
    SELECT
        *,
        DENSE_RANK() OVER (
            PARTITION BY cte1.customer_id, cte1.member
            ORDER BY cte1.order_date ASC
        ) AS ranking
    FROM members_cte AS cte1
)

SELECT
    cte2.customer_id,
    cte2.order_date,
    cte2.product_name,
    cte2.price,
    cte2.member,
    CASE
        WHEN (cte2.member = 'Y') THEN cte2.ranking
        ELSE NULL
    END AS ranking
FROM members_ranking_cte AS cte2;
