# Pizza Runner Part 1: Pizza Metrics

[Case Study 2](https://github.com/jo2eph/8-week-SQL-challenge/tree/main/case_study_2_Pizza_Runner)

[Prev](https://github.com/jo2eph/8-week-SQL-challenge/blob/main/case_study_2_Pizza_Runner/0_Data_Cleaning.md) | [Next](https://github.com/jo2eph/8-week-SQL-challenge/blob/main/case_study_2_Pizza_Runner/2_Runner_and_Customer_Experience.md)

---

## Contents

- [Abstract](#abstract)
- [Question 1](#1-how-many-pizzas-were-ordered)
- [Question 2](#2-how-many-unique-customer-orders-were-made)
- [Question 3](#3-how-many-successful-orders-were-delivered-by-each-runner)
- [Question 4](#4-how-many-of-each-type-of-pizza-was-delivered)
- [Question 5](#5-how-many-vegetarian-and-meatlovers-were-ordered-by-each-customer)
- [Question 6](#6-what-was-the-maximum-number-of-pizzas-delivered-in-a-single-order)
- [Question 7](#7-for-each-customer-how-many-delivered-pizzas-had-at-least-1-change-and-how-many-had-no-changes)
- [Question 8](#8-how-many-pizzas-were-delivered-that-had-both-exclusions-and-extras)
- [Question 9](#9-what-was-the-total-volume-of-pizzas-ordered-for-each-hour-of-the-day)
- [Question 10](#10-what-was-the-volume-of-orders-for-each-day-of-the-week)

---

## Abstract

In this section, we will answer questions related to pizza metrics.
In particular, we are going to answer the following ten questions:

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

---

## 1. How many pizzas were ordered?

To calculate how many pizzas were ordered, we simply count how many rows are in `customer_orders_cleaned`.

```sql
SELECT
    COUNT(*) AS total_pizzas_ordered
FROM pizza_runner.customer_orders_cleaned;
```

| total_pizzas_ordered |
|----------------------|
|                   14 |

**Answer:**

A total of 14 pizzas were ordered.

---

## 2. How many unique customer orders were made?

To find how many unique customer orders were made, we are going to count how many distinct `order_id` there are in `customer_orders_cleaned`, since each `order_id` represent an individual order.

```sql
SELECT
    COUNT(DISTINCT co.order_id) AS unique_customer_orders
FROM pizza_runner.customer_orders_cleaned AS co;
```

| unique_customer_orders |
|------------------------|
|                     10 |

**Answer:**

10 unique customer orders were made.

---

## 3. How many successful orders were delivered by each runner?

We want to know how many successful orders were delivered by each runner.

What does that mean? If we look at the `runner_orders_cleaned` table, we can see that each row corresponds to an individual order delivery by a runner. We can also see that there is a column called `cancellation`, which gives a reason (if applicable) for the cancellation.
Thus, we define a successful order as an order that is not cancelled, i.e., does not have a value in the `cancellation` column.

Thus, we will use the aggregate `COUNT` to count the total number of deliveries where `cancellation` is null or an empty string.

Lastly, we use `GROUP BY` to group by `runner_id`.

Thus, our SQL query is as follows:

```sql
SELECT
    ro.runner_id,
    COUNT(*) AS total_successful_orders
FROM pizza_runner.runner_orders_cleaned AS ro
WHERE ro.cancellation = '' OR ro.cancellation IS NULL
GROUP BY ro.runner_id
ORDER BY ro.runner_id;
```

| runner_id | total_successful_orders |
|-----------|-------------------------|
|         1 |                       4 |
|         2 |                       3 |
|         3 |                       1 |

**Answer:**

- Runner 1 made 4 successful orders.
- Runner 2 made 3 successful orders.
- Runner 3 made 1 successful orders.

---

## 4. How many of each type of pizza was delivered?

In this question, we want to know how many of each type of pizza was delivered.

We are going to perform two `JOIN`.
We are going to join `customer_orders_cleaned` with `pizza_names` on `pizza_id` in order to get the name of the pizza.
We are also going to join `customer_orders_cleaned` on `runner_orders_cleaned` so we know which orders are successful and which are cancelled.

Then, we use `WHERE` to select only the orders that were successful, i.e. there is no value in the `cancellation` column.

Since we want to know how many of each type of pizza was delivered, we are going to use `GROUP BY` to group by `pizza_id` and `pizza_name`. Note that it's fine to use just `pizza_name`.

Next, we finish it off by using the aggregate function `COUNT` to get the actual total count for each type of pizza.

Thus, our final SQL query is as follows:

```sql
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
```

| pizza_id | pizza_name | total_delivered |
|----------|------------|-----------------|
|        1 | Meatlovers |               9 |
|        2 | Vegetarian |               3 |

**Answer:**

- Meat lovers pizza was delivered 9 times.
- Vegetarian pizza was delivered 3 times.

---

## 5. How many Vegetarian and Meatlovers were ordered by each customer?

Here, we want to know how many of both types of pizzas each customer ordered.

So, first thing we will do is perform `JOIN` to join `customer_orders_cleaned` with `pizza_names` on `pizza_id` to get the name of the pizzas (`pizza_name`).

And since we want to know how many *each* customer ordered, we know that we are going to perform `GROUP BY` to group the orders by `customer_id`.

To get the actual count of both pizzas for each customers, we will use the aggregate function `COUNT`. This time, we will use a conditional count.
We will count the total number of rows for each customer where `pizza_name = 'Vegetarian'`, and we will save that as `vegetarian_count`.
Similarly, we will also count the total number of rows for each customer where `pizza_name = 'Meatlovers'`, and we will save that as `meatlovers_count`.

Thus, our final SQL query:

```sql
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
```

| customer_id | vegetarian_count | meatlovers_count |
|-------------|------------------|------------------|
|         101 |                1 |                2 |
|         102 |                1 |                2 |
|         103 |                1 |                3 |
|         104 |                0 |                3 |
|         105 |                1 |                0 |

**Answers:**

- Customer 101 ordered 1 Vegetarian and 2 Meatlovers pizzas.
- Customer 102 ordered 1 Vegetarian and 2 Meatlovers pizzas.
- Customer 103 ordered 1 Vegetarian and 3 Meatlovers pizzas.
- Customer 104 ordered 0 Vegetarian and 3 Meatlovers pizzas.
- Customer 105 ordered 1 Vegetarian and 0 Meatlovers pizzas.

---

## 6. What was the maximum number of pizzas delivered in a single order?

Here, we want to know what the maximum number of pizzas was delivered in a single order.

Recall that in the table `customer_orders_cleaned`, each `order_id` corresponds to a single order. So we know that we will need to do `GROUP BY` eventually.

We also need only the orders that were delivered successfully. To get that data, we need to perform `JOIN` to join `customer_orders_cleaned` with `runner_orders_cleaned` on `order_id`.

Next, we use `WHERE` to filter only the rows where the delivery was successful, i.e. `cancellation = '' OR cancellation IS NULL`.

Then, as mentioned previously, we will use `GROUP BY` to group these rows by `order_id`.

Lastly, we will use `ORDER BY` to sort the values in *descending* (`DESC`) order so that the maximum value is at the top of the output table.

Thus, our final SQL query is as follows:

```sql
SELECT
    co.order_id,
    COUNT(*) AS pizzas_delivered
FROM pizza_runner.customer_orders_cleaned AS co
JOIN pizza_runner.runner_orders_cleaned AS ro
    ON co.order_id = ro.order_id
WHERE ro.cancellation = '' OR ro.cancellation IS NULL
GROUP BY co.order_id
ORDER BY pizzas_delivered DESC;
```

| order_id | pizzas_delivered |
|----------|------------------|
|        4 |                3 |
|        3 |                2 |
|       10 |                2 |
|        5 |                1 |
|        2 |                1 |
|        8 |                1 |
|        7 |                1 |
|        1 |                1 |

**Answer:**

The maximum number of pizzas delivered in a single order is 3 (which corresponds to `order_id` 4).

---

## 7. For each customer, how many delivered pizzas had at least 1 change and how many had no changes?

In this question, we want to find how many delivered pizzas had at least one change and how many delivered pizzas with no changes were delivered for each customer.

The first thing we will do is create a CTE containing the orders that were successfully delivered, and we will call it `delivered_cte`.

```sql
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
/* ... */
```

This CTE gives us the following table:

| order_id | customer_id | pizza_id | exclusions | extras |
|----------|-------------|----------|------------|--------|
|        1 |         101 |        1 |            |        |
|        2 |         101 |        1 |            |        |
|        3 |         102 |        1 |            |        |
|        3 |         102 |        2 |            |        |
|        4 |         103 |        1 | 4          |        |
|        4 |         103 |        1 | 4          |        |
|        4 |         103 |        2 | 4          |        |
|        5 |         104 |        1 |            | 1      |
|        7 |         105 |        2 |            | 1      |
|        8 |         102 |        1 |            |        |
|       10 |         104 |        1 |            |        |
|       10 |         104 |        1 | 2, 6       | 1, 4   |

Now, we want to get the count of delivered pizzas with at least one change, and the count of delivered pizzas with no change.

What it means for a pizza to have at least one change in this case is to have a non-empty value in either the `exclusions` or the `extras` column.

Thus, what we want to do is for each customer:

- Count the number of rows where *either* the `exclusions` *or* `extras` is not equal to the empty string '', and we will save that as `pizza_with_changes`.
- Count the number of rows where *both* `exclusions` *and* `extras` are equal to the empty string '', and we will save that as `pizza_without_changes`.

We also want to use `GROUP BY` to group according to `customer_id`.

Lastly, we will use `ORDER BY` to sort by `customer_id`.

Thus, our final SQL query for this problem is as follows:

```sql
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
```

| customer_id | pizzas_with_changes | pizzas_without_changes |
|-------------|---------------------|------------------------|
|         101 |                   0 |                      2 |
|         102 |                   0 |                      3 |
|         103 |                   3 |                      0 |
|         104 |                   2 |                      1 |
|         105 |                   1 |                      0 |

**Answer:**

- Customer 101 had **no** pizza with at least one change, and **2** pizzas without changes delivered.
- Customer 102 had **no** pizza with at least one change, and **3** pizzas without changes delivered.
- Customer 103 had **3** pizzas with at least one change, and **no** pizzas without changes delivered.
- Customer 104 had **2** pizzas with at least one change, and **1** pizzas without changes delivered.
- Customer 105 had **1** pizza with at least one change, and **no** pizzas without changes delivered.

---

## 8. How many pizzas were delivered that had both exclusions and extras?

In this question, we want to know how many pizzas were delivered that had both exclusions and extras.

Similar to Problem 7, we are going to create a CTE called `delivered_cte` that contains only the orders that were delivered successfully.

Next, we want to find how many delivered pizzas had both extras and exclusions.

For this, we will simply use `COUNT` and `CASE` to count the total number of rows in our CTE where *both* `exclusions` and `extras` are not equal to the empty string.
We will save that as `pizzas_with_exclusions_and_extras`.

Thus, our final SQL query for this problem is as follows:

```sql
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
```

| pizzas_with_exclusions_and_extras |
|-----------------------------------|
|                                 1 |

**Answer:**

Only 1 pizza delivered had both exclusions and extras.

---

## 9. What was the total volume of pizzas ordered for each hour of the day?

We want to find the total volume of pizzas ordered for each hour of the day.

To get the hour of the day from `co.order_time`, we use `EXTRACT`, which would look like the following: `EXTRACT(HOUR FROM order_time)`.
We will save this as `order_hour`.

Since we want to know the total number of pizzas ordered for each hour, we will be using `GROUP BY` to group our data by `order_hour`.
And since we want the total volume of pizzas ordered for each `order_hour`, we will use the aggregate function `COUNT`, which we will save as `total_pizzas_ordered`.

Lastly, we will `ORDER BY` to sort the data by `order_hour`.

Thus, our final SQL query is as follows:

```sql
SELECT
    EXTRACT(HOUR FROM co.order_time) AS order_hour,
    COUNT(*) AS total_pizzas_ordered
FROM pizza_runner.customer_orders_cleaned AS co
GROUP BY order_hour
ORDER BY order_hour;
```

| order_hour | total_pizzas_ordered |
|------------|----------------------|
|         11 |                    1 |
|         13 |                    3 |
|         18 |                    3 |
|         19 |                    1 |
|         21 |                    3 |
|         23 |                    3 |

**Answer:**

- A total of 1 pizza was ordered at the hour of 11 AM.
- A total of 3 pizzas were ordered at the hour of 13 (1 PM).
- A total of 3 pizzas were ordered at the hour of 18 (6 PM).
- A total of 1 pizza was ordered at the hour of 19 (7 PM).
- A total of 3 pizzas were ordered at the hour of 21 (9 PM).
- A total of 3 pizzas were ordered at the hour of 23 (11 PM).

---

## 10. What was the volume of orders for each day of the week?

To get the day of the week in PostgreSQL, we are going to use `EXTRACT` to extract `DOW` (day of the week) from `order_time`, and we will save it as `order_day_of_week`.

Note that in PostgreSQL, this gives an integer from 0 to 6, where 0 represents Sunday and 6 represents Saturday.

And since we want to know the total volume of orders for each day of the week, we are going to use the aggregate function `COUNT` to count how many individual orders are made for each day of the week, and we will save it as `total_orders`.

Lastly, we need to use `GROUP BY` to group our data by `order_day_of_week`.
Then, we can use `ORDER BY` to sort the values by `order_day_of_week`.

```sql
SELECT
    EXTRACT(DOW FROM co.order_time) AS order_day_of_week,
    COUNT(*) AS total_orders
FROM pizza_runner.customer_orders_cleaned AS co
GROUP BY order_day_of_week
ORDER BY order_day_of_week;
```

| order_day_of_week | total_orders |
|-------------------|--------------|
|                 3 |            5 |
|                 4 |            3 |
|                 5 |            1 |
|                 6 |            5 |

**Answer:**

- Wednesday (3): A total of 5 pizzas were ordered.
- Thursday (4): A total of 3 pizzas were ordered.
- Friday (5): A total of 1 pizza was ordered.
- Saturday (6): A total of 5 pizzas were ordered.

---

End of Case Study 2 Pizza Metrics questions.
Click [this link](https://github.com/jo2eph/8-week-SQL-challenge/blob/main/case_study_2_Pizza_Runner/2_Runner_and_Customer_Experience.md)
for the next set of questions, Runner and Customer Experience.

---

[Return to Top](#pizza-runner-part-1-pizza-metrics)

Prev | [Next](https://github.com/jo2eph/8-week-SQL-challenge/blob/main/case_study_2_Pizza_Runner/2_Runner_and_Customer_Experience.md)
