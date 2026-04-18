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

---

## 3. How many successful orders were delivered by each runner?

---

## 4. How many of each type of pizza was delivered?

---

## 5. How many Vegetarian and Meatlovers were ordered by each customer?

---

## 6. What was the maximum number of pizzas delivered in a single order?

---

## 7. For each customer, how many delivered pizzas had at least 1 change and how many had no changes?

---

## 8. How many pizzas were delivered that had both exclusions and extras?

---

## 9. What was the total volume of pizzas ordered for each hour of the day?

---

## 10. What was the volume of orders for each day of the week?
