/*
SQL query to clean the datasets for Case Study 2 Pizza Runner
*/

-- Drop cleaned tables if they already exist --
DROP TABLE IF EXISTS customer_orders_cleaned;
DROP TABLE IF EXISTS runner_orders_cleaned;

-- Cleaning customer_orders dataset
CREATE TABLE customer_orders_cleaned AS (
    SELECT
        co.order_id,
        co.customer_id,
        co.pizza_id,
        -- Replace nulls in exclusions
        CASE
            WHEN co.exclusions IS NULL OR co.exclusions LIKE 'null' THEN ''
            ELSE co.exclusions
        END AS exclusions,
        -- Replace nulls in extras
        CASE
            WHEN co.extras IS NULL OR co.extras LIKE 'null' THEN ''
            ELSE co.extras
        END AS extras,
        co.order_time
    FROM pizza_runner.customer_orders AS co
);

-- Cleaning runner_orders dataset
