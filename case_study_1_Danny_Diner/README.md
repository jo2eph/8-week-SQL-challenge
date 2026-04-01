# Case Study 1 - Danny's Diner

![image](https://8weeksqlchallenge.com/images/case-study-designs/1.png)

Link: [Case Study 1 - Danny's Diner](https://8weeksqlchallenge.com/case-study-1/)

---

## Contents

- [Introduction](#introduction)
- [Entity Relationship Diagram](#entity-relationship-diagram)
- [Case Study Questions](#case-study-questions)
- [Question 1](#1-what-is-the-total-amount-each-customer-spent-at-the-restaurant)
- [Question 2](#2-how-many-days-has-each-customer-visited-the-restaurant)

---

## Introduction

Danny loves Japanese food, so he decides to open up a restaurant that sells his three favorite foods: sushi, curry, and ramen.

Danny's Diner is in need of assistance. The restaurant has captured some very basic data from the first few months of operation, but have no idea how to use their data to help them run the business.

## Entity Relationship Diagram

![image](./image/diagram.png)

## Case Study Questions

In this case study, we will answer the following questions, plus a bonus question.

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

---

### 1. What is the total amount each customer spent at the restaurant?

In this question, we want to find the total amount.
In this case, we are interested in how much each customer spent at Danny's Diner.

First, let's look at the `sales` table.

``` sql
SELECT *
FROM dannys_diner.sales;
```

| customer_id | order_date | product_id |
| ----------- | ---------- | ---------- |
| A           | 2021-01-01 | 1          |
| A           | 2021-01-01 | 2          |
| A           | 2021-01-07 | 2          |
| A           | 2021-01-10 | 3          |
| A           | 2021-01-11 | 3          |
| A           | 2021-01-11 | 3          |
| B           | 2021-01-01 | 2          |
| B           | 2021-01-02 | 2          |
| B           | 2021-01-04 | 1          |
| B           | 2021-01-11 | 1          |
| B           | 2021-01-16 | 3          |
| B           | 2021-02-01 | 3          |
| C           | 2021-01-01 | 3          |
| C           | 2021-01-01 | 3          |
| C           | 2021-01-07 | 3          |

We can see that each row represent a single sale, with the `customer_id`, `order_date`, and `product_id`.

Since we want to know how much in total *each* customer spent, we know that we need to eventually group this data by `customer_id`.

Next, we are going to examine the `product_id`.

Notice that `product_id` in `sales` is a foreign key for the `product_id` in the `menu` table.

```sql
SELECT *
FROM dannys_diner.menu;
```

| product_id | product_name | price |
| ---------- | ------------ | ----- |
| 1          | sushi        | 10    |
| 2          | curry        | 15    |
| 3          | ramen        | 12    |

Since we are interested in the total amount spent by each customer, we want to get the `price` from the `menu`.

For this, we need to combine `price` to the `sales` table corresponding to the `product_id`.

Furthermore, we are going to only focus on `customer_id` and `product_id`.

```sql
SELECT *
FROM dannys_diner.sales
INNER JOIN dannys_diner.menu
    ON sales.product_id = menu.product_id;
```

*The output table is omitted for simplicity.*

Then, we want to compute the total price for each of the customers.
To do this, we use the `SUM` function on the `price` column.

After that, we have to use the `GROUP BY` on the `customer_id` column.

```sql
SELECT 
    customer_id,
    SUM(price) as total_sales
FROM dannys_diner.sales
INNER JOIN dannys_diner.menu
    ON menu.product_id = sales.product_id
GROUP BY customer_id;
```

| customer_id | total_sales |
| ----------- | ----------- |
| B           | 74          |
| C           | 36          |
| A           | 76          |

And just for personal preference, let's sort the data by `customer_id` to ensure that it is in alphabetical order, using `ORDER BY`.
Not strictly necessary, but it looks nicer this way.

Thus, our final query for Question 1 is as follows:

```sql
SELECT 
    customer_id,
    SUM(price) as total_sales
FROM dannys_diner.sales
INNER JOIN dannys_diner.menu
    ON menu.product_id = sales.product_id
GROUP BY customer_id
ORDER BY customer_id ASC;
```

| customer_id | total_sales |
| ----------- | ----------- |
| A           | 76          |
| B           | 74          |
| C           | 36          |

**ANSWER:**

- Customer A spent a total of $76.
- Customer B spent a total of $74.
- Customer C spent a total of $36.

---

### 2. How many days has each customer visited the restaurant?

In this question, we are interested in how many days.
For this, we are going to examine the `sales` table. In particular, we are going to focus only on the columns `customer_id` and `order_date`.

```sql
SELECT
    customer_id,
    order_date
FROM dannys_diner.sales;
```

| customer_id | order_date |
| ----------- | ---------- |
| A           | 2021-01-01 |
| A           | 2021-01-01 |
| A           | 2021-01-07 |
| A           | 2021-01-10 |
| A           | 2021-01-11 |
| A           | 2021-01-11 |
| B           | 2021-01-01 |
| B           | 2021-01-02 |
| B           | 2021-01-04 |
| B           | 2021-01-11 |
| B           | 2021-01-16 |
| B           | 2021-02-01 |
| C           | 2021-01-01 |
| C           | 2021-01-01 |
| C           | 2021-01-07 |

From the first few rows, we can already see that we have duplicates of dates.
This is due to the fact that some customers have ordered more than one item on the same date.

For example, if we look at the first two rows, we see that Customer A have ordered Product 1 (sushi) and Product 2 (curry) on January 1, 2021.

Since we are interested in how many days each customer visited the restaurant rather than the total number of visits, we want to remove duplicate dates.

For this, we are going to use `DISTINCT` to ensure we remove the duplicate dates.

Next, we use `COUNT` so that we get the total count of unique visit dates, which we will save as the column `total_visits`.

Then, we need to group them by `customer_id`.
Finally, just like the previous quesiton, we use `ORDER BY` for alphabetical order.

Thus, our final SQL query is as follows:

```sql
SELECT
    customer_id,
    COUNT(DISTINCT order_date) AS total_vists
FROM dannys_diner.sales
GROUP BY customer_id
ORDER BY customer_id ASC;
```

| customer_id | total_vists |
| ----------- | ----------- |
| A           | 4           |
| B           | 6           |
| C           | 2           |

**ANSWER:**

- Customer A visited a total of 4 days.
- Customer B visited a total of 6 dys.
- Customer C visited a total of 2 days.

### 3. What was the first item from the menu purchased by each customer?

### 4. What is the most purchased item on the menu and how many times was it purchased by all customers?

### 5. Which item was the most popular for each customer?

### 6. Which item was purchased first by the customer after they became a member?

### 7. Which item was purchased just before the customer became a member?

### 8. What is the total items and amount spent for each member before they became a member?

### 9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?

### 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have
