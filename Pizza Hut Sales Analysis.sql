
-- Basic
-- Retrieve the total number of orders placed
select count(order_id) as total_orders from orders;

-- Calculate total revenue generated from pizza sales
SELECT 
    ROUND(SUM(od.quantity * p.price), 2) AS total_sales
FROM
    order_details od
        JOIN
    pizzas p ON p.pizza_id = od.pizza_id;

-- Identify the highest-priced pizza
SELECT 
    pt.name, p.price
FROM
    pizza_types pt
        JOIN
    pizzas p ON pt.pizza_type_id = p.pizza_type_id
ORDER BY p.price DESC
LIMIT 1;

-- Identify the most common pizza size ordered.
SELECT 
    p.size, COUNT(od.order_details_id) AS order_count
FROM
    pizzas p
        JOIN
    order_details od ON p.pizza_id = od.pizza_id
GROUP BY p.size
ORDER BY order_count DESC;

-- list 5 most ordered pizza types along with their quantities.
  SELECT 
    pt.name, SUM(od.quantity) AS quantity
FROM
    pizza_types pt
        JOIN
    pizzas p ON pt.pizza_type_id = p.pizza_type_id
        JOIN
    order_details od ON od.pizza_id = p.pizza_id
GROUP BY pt.name
ORDER BY quantity DESC
LIMIT 5;

-- Intermediate
-- join the necessary tables to find the total quantity of each pizza quantity ordered.
SELECT 
    pt.category, SUM(od.quantity) AS quantity
FROM
    pizza_types pt
        JOIN
    pizzas p ON pt.pizza_type_id = p.pizza_type_id
        JOIN
    order_details od ON od.pizza_id = p.pizza_id
GROUP BY pt.category
ORDER BY quantity DESC;

-- determine the distribution of orders by hour of the day
SELECT 
    HOUR(order_time), COUNT(order_id) AS no_of_orders
FROM
    orders
GROUP BY HOUR(order_time)
ORDER BY no_of_orders;

-- join relevant tables to find the category-wise distribution of pizzas.
SELECT 
    category, COUNT(*)
FROM
    pizza_types
GROUP BY category;

-- group the orders by date and calculate the average number of pizzas ordered per day
SELECT 
  ROUND(AVG(quantity), 0) as avg_pizza_per_day
FROM
    (SELECT 
        o.order_date as order_date, SUM(od.quantity) AS quantity
    FROM
        orders o
    JOIN order_details od ON o.order_id = od.order_id
    GROUP BY o.order_date) AS order_quantity
    group by order_date;
    
-- determine top 3 most ordered pizza types based on revenue.
SELECT 
    pt.name, SUM(od.quantity * p.price) AS revenue
FROM
    pizza_types pt
        JOIN
    pizzas p ON p.pizza_type_id = pt.pizza_type_id
        JOIN
    order_details od ON od.pizza_id = p.pizza_id
GROUP BY pt.name
ORDER BY revenue DESC
LIMIT 3;

-- Advanced
-- Calculate the percentage contribution of each pizza type to total revenue.
SELECT 
    pt.category,
    ROUND((SUM(od.quantity * p.price) / (SELECT 
                    ROUND(SUM(od.quantity * p.price), 2) AS total_sales
                FROM
                    order_details od
                        JOIN
                    pizzas p ON p.pizza_id = od.pizza_id)) * 100,
            2) AS revenue
FROM
    pizza_types pt
        JOIN
    pizzas p ON pt.pizza_type_id = p.pizza_type_id
        JOIN
    order_details od ON p.pizza_id = od.pizza_id
GROUP BY pt.category
ORDER BY revenue DESC;

-- analyse the cumulative revenue generated over time
select 
	order_date, 
	round(sum(revenue)over (order by order_date),2) as cum_revenue 
from 
(SELECT 
    o.order_date,
    ROUND(SUM(od.quantity * p.price), 2) AS revenue
FROM
    order_details od
        JOIN
    pizzas p ON od.pizza_id = p.pizza_id
        JOIN
    orders o ON o.order_id = od.order_id
GROUP BY o.order_date) 
as sales;

-- Determine the top 3 most ordered pizza types based on revenue for each pizza category.
select category,name, revenue from 
(select 
	category, 
	name,
	revenue,
    rank() over (partition by category order by revenue desc) as rn 
    from
(SELECT 
    pt.category, pt.name, SUM(od.quantity * p.price) AS revenue
FROM
    pizza_types pt
        JOIN
    pizzas p ON pt.pizza_type_id = p.pizza_type_id
        JOIN
    order_details od ON od.pizza_id = p.pizza_id
GROUP BY pt.category , pt.name) as sub) as sub1
where rn <= 3;



