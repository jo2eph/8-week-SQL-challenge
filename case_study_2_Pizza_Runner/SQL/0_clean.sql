/*
SQL query to clean the datasets for Case Study 2 Pizza Runner
*/

-- Drop cleaned tables if they already exist --
DROP TABLE IF EXISTS pizza_runner.customer_orders_cleaned;
DROP TABLE IF EXISTS pizza_runner.runner_orders_cleaned;

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
CREATE TABLE runner_orders_cleaned AS (
    SELECT
        ro.order_id,
        ro.runner_id,
        -- Replace nulls in pickup_time
        CASE
            WHEN ro.pickup_time IS NULL OR ro.pickup_time LIKE 'null' THEN NULL
            ELSE ro.pickup_time
        END AS pickup_time,
        -- Clean distance
        CASE
            WHEN ro.distance IS NULL OR ro.distance LIKE 'null' THEN NULL
            WHEN ro.distance LIKE '%km' THEN TRIM('km' FROM ro.distance)
            ELSE ro.distance
        END AS distance_km,
        -- Clean duration
        CASE 
            WHEN ro.duration IS NULL OR ro.duration LIKE 'null' THEN NULL
            WHEN ro.duration LIKE '%min' THEN TRIM('min' FROM ro.duration)
            WHEN ro.duration LIKE '%mins' THEN TRIM('mins' FROM ro.duration)
            WHEN ro.duration LIKE '%minute' THEN TRIM('minute' FROM ro.duration)
            WHEN ro.duration LIKE '%minutes' THEN TRIM('minutes' FROM ro.duration)
            ELSE ro.duration
        END AS duration_min,
        -- Clean cancellation
        CASE
            WHEN ro.cancellation IS NULL OR ro.cancellation LIKE 'null' THEN ''
            ELSE ro.cancellation
        END AS cancellation
    FROM pizza_runner.runner_orders AS ro
);

-- Changing data types in runner_orders_cleaned
ALTER TABLE runner_orders_cleaned
    ALTER COLUMN pickup_time TYPE TIMESTAMP WITHOUT TIME ZONE 
        USING pickup_time::TIMESTAMP WITHOUT TIME ZONE,
    ALTER COLUMN distance_km TYPE FLOAT 
        USING distance_km::FLOAT,
    ALTER COLUMN duration_min TYPE INT 
        USING duration_min::INT;
