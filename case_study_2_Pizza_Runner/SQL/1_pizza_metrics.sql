/*
SQL file for answering Part A: Pizza Metrics of Case Study 2: Pizza Runner

Questions:

1. How many pizzas were ordered?
2. How many unique customer orders were made?
3. How many successful orders were delivered by each runner?
4. How many of each type of pizza was delivered?
5. How many Vegetarian and Meatlovers were ordered by each customer?
6. What was the maximum number of pizzas delivered in a single order?
7. For each customer, how many delivered pizzas had at least 1 change and how many had no changes?
8. How many pizzas were delivered that had both exclusions and extras?
9. What was the total volume of pizzas ordered for each hour of the day?
10. What was the volume of orders for each day of the week?
*/

-- 1. How many pizzas were ordered?
SELECT
    COUNT(*) AS total_pizzas_ordered
FROM pizza_runner.customer_orders_cleaned;

-- 2. How many unique customer orders were made?
SELECT
    COUNT(DISTINCT co.order_id) AS unique_customer_orders
FROM pizza_runner.customer_orders_cleaned AS co;

-- 3. How many successful orders were delivered by each runner?
SELECT
    ro.runner_id,
    COUNT(*) AS total_successful_orders
FROM pizza_runner.runner_orders_cleaned AS ro
WHERE ro.cancellation = '' OR ro.cancellation IS NULL
GROUP BY ro.runner_id
ORDER BY ro.runner_id;

-- 4. How many of each type of pizza was delivered?
SELECT
    co.pizza_id,
    pizza.pizza_name,
    COUNT(*) AS total_delivered
FROM pizza_runner.customer_orders_cleaned AS co
JOIN pizza_runner.pizza_names AS pizza
    ON co.pizza_id = pizza.pizza_id
JOIN pizza_runner.runner_orders_cleaned AS ro
    ON co.order_id = ro.order_id
WHERE ro.cancellation = '' OR ro.cancellation IS NULL
GROUP BY co.pizza_id, pizza.pizza_name
ORDER BY co.pizza_id;

-- 5. How many Vegetarian and Meatlovers were ordered by each customer?
SELECT
    co.customer_id,
    COUNT(
        CASE WHEN pizza.pizza_name = 'Vegetarian' THEN 1 END
    ) AS vegetarian_count,
    COUNT (
        CASE WHEN pizza.pizza_name = 'Meatlovers' THEN 1 END
    ) AS meatlovers_count
FROM pizza_runner.customer_orders_cleaned AS co
JOIN pizza_runner.pizza_names AS pizza
    ON co.pizza_id = pizza.pizza_id
GROUP BY co.customer_id
ORDER BY co.customer_id;

-- 6. What was the maximum number of pizzas delivered in a single order?
SELECT
    co.order_id,
    COUNT(*) AS pizzas_delivered
FROM pizza_runner.customer_orders_cleaned AS co
JOIN pizza_runner.runner_orders_cleaned AS ro
    ON co.order_id = ro.order_id
WHERE ro.cancellation = '' OR ro.cancellation IS NULL
GROUP BY co.order_id
ORDER BY pizzas_delivered DESC;

-- 7. For each customer, how many delivered pizzas had at least 1 change and how many had no changes?
WITH delivered_cte AS (
    SELECT
        co.order_id,
        co.customer_id,
        co.pizza_id,
        co.exclusions,
        co.extras
    FROM pizza_runner.customer_orders_cleaned AS co
    JOIN pizza_runner.runner_orders_cleaned AS ro
        ON co.order_id = ro.order_id
    WHERE ro.cancellation = '' OR ro.cancellation IS NULL
)
SELECT
    customer_id,
    COUNT(
        CASE WHEN cte.exclusions <> '' OR cte.extras <> '' THEN 1 END
    ) AS pizzas_with_changes,
    COUNT(
        CASE WHEN cte.exclusions = '' AND cte.extras = '' THEN 1 END
    ) AS pizzas_without_changes
FROM delivered_cte AS cte
GROUP BY cte.customer_id
ORDER BY cte.customer_id;

-- 8. How many pizzas were delivered that had both exclusions and extras?
WITH delivered_cte AS (
    SELECT
        co.order_id,
        co.pizza_id,
        co.exclusions,
        co.extras
    FROM pizza_runner.customer_orders_cleaned AS co
    JOIN pizza_runner.runner_orders_cleaned AS ro
        ON co.order_id = ro.order_id
    WHERE ro.cancellation = '' OR ro.cancellation IS NULL
)
SELECT
    COUNT(
        CASE WHEN cte.exclusions <> '' AND cte.extras <> '' THEN 1 END
    ) AS pizzas_with_exclusions_and_extras
FROM delivered_cte AS cte;

-- 9. What was the total volume of pizzas ordered for each hour of the day?
SELECT
    EXTRACT(HOUR FROM co.order_time) AS order_hour,
    COUNT(*) AS total_pizzas_ordered
FROM pizza_runner.customer_orders_cleaned AS co
GROUP BY order_hour
ORDER BY order_hour;

-- 10. What was the volume of orders for each day of the week?
SELECT
    EXTRACT(DOW FROM co.order_time) AS order_day_of_week,
    COUNT(*) AS total_orders
FROM pizza_runner.customer_orders_cleaned AS co
GROUP BY order_day_of_week
ORDER BY order_day_of_week;
