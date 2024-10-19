# Pizza Hut Sales Analysis

## Project Overview

This project involves analyzing pizza sales data from multiple tables including `orders`, `order_details`, `pizzas`, and `pizza_types`. The dataset contains information on pizza orders, pizza types, sizes, prices, and order timings. The analysis is divided into basic, intermediate, and advanced SQL queries to provide insights into sales performance, revenue, order patterns, and pizza preferences.

### Files Included:

1. **orders.csv**: Contains details about each order placed, including the order ID, order time, and order date.
2. **order_details.csv**: Contains specific details of each order, including pizza ID, quantity, and order ID.
3. **pizzas.csv**: Contains pizza details such as pizza ID, type, size, and price.
4. **pizza_types.csv**: Contains types of pizzas including their name, category, and ingredients.

---

## Analysis Breakdown

### Basic Queries:
1. **Total Orders**: Retrieves the total number of orders placed.
   ```sql
   SELECT COUNT(order_id) AS total_orders FROM orders;
   ```

2. **Total Revenue**: Calculates the total revenue generated from pizza sales.
   ```sql
   SELECT ROUND(SUM(od.quantity * p.price), 2) AS total_sales
   FROM order_details od
   JOIN pizzas p ON p.pizza_id = od.pizza_id;
   ```

3. **Highest-Priced Pizza**: Identifies the most expensive pizza type.
   ```sql
   SELECT pt.name, p.price 
   FROM pizza_types pt
   JOIN pizzas p ON pt.pizza_type_id = p.pizza_type_id 
   ORDER BY p.price DESC 
   LIMIT 1;
   ```

4. **Most Common Pizza Size**: Finds the most commonly ordered pizza size.
   ```sql
   SELECT p.size, COUNT(od.order_details_id) AS order_count 
   FROM pizzas p 
   JOIN order_details od ON p.pizza_id = od.pizza_id 
   GROUP BY p.size 
   ORDER BY order_count DESC;
   ```

5. **Top 5 Ordered Pizza Types**: Lists the top 5 most ordered pizza types along with their quantities.
   ```sql
   SELECT pt.name, SUM(od.quantity) AS quantity 
   FROM pizza_types pt 
   JOIN pizzas p ON pt.pizza_type_id = p.pizza_type_id 
   JOIN order_details od ON od.pizza_id = p.pizza_id 
   GROUP BY pt.name 
   ORDER BY quantity DESC 
   LIMIT 5;
   ```

### Intermediate Queries:
1. **Pizza Quantities by Category**: Calculates the total quantity of each pizza category ordered.
   ```sql
   SELECT pt.category, SUM(od.quantity) AS quantity 
   FROM pizza_types pt 
   JOIN pizzas p ON pt.pizza_type_id = p.pizza_type_id 
   JOIN order_details od ON od.pizza_id = p.pizza_id 
   GROUP BY pt.category 
   ORDER BY quantity DESC;
   ```

2. **Order Distribution by Hour**: Analyzes the distribution of orders based on the hour of the day.
   ```sql
   SELECT HOUR(order_time), COUNT(order_id) AS no_of_orders 
   FROM orders 
   GROUP BY HOUR(order_time) 
   ORDER BY no_of_orders;
   ```

3. **Category-wise Pizza Distribution**: Displays the number of pizzas ordered based on their category.
   ```sql
   SELECT category, COUNT(*) 
   FROM pizza_types 
   GROUP BY category;
   ```

4. **Average Pizzas Ordered per Day**: Calculates the average number of pizzas ordered per day.
   ```sql
   SELECT ROUND(AVG(quantity), 0) AS avg_pizza_per_day 
   FROM (
      SELECT o.order_date, SUM(od.quantity) AS quantity 
      FROM orders o 
      JOIN order_details od ON o.order_id = od.order_id 
      GROUP BY o.order_date
   ) AS daily_orders;
   ```

5. **Top 3 Pizzas by Revenue**: Identifies the top 3 most ordered pizza types based on revenue.
   ```sql
   SELECT pt.name, SUM(od.quantity * p.price) AS revenue 
   FROM pizza_types pt 
   JOIN pizzas p ON pt.pizza_type_id = p.pizza_type_id 
   JOIN order_details od ON od.pizza_id = p.pizza_id 
   GROUP BY pt.name 
   ORDER BY revenue DESC 
   LIMIT 3;
   ```

### Advanced Queries:
1. **Revenue Contribution by Pizza Type**: Calculates the percentage contribution of each pizza type to the total revenue.
   ```sql
   SELECT pt.category, 
      ROUND((SUM(od.quantity * p.price) / (SELECT ROUND(SUM(od.quantity * p.price), 2) FROM order_details od JOIN pizzas p ON p.pizza_id = od.pizza_id)) * 100, 2) AS revenue_percentage 
   FROM pizza_types pt 
   JOIN pizzas p ON pt.pizza_type_id = p.pizza_type_id 
   JOIN order_details od ON p.pizza_id = od.pizza_id 
   GROUP BY pt.category 
   ORDER BY revenue_percentage DESC;
   ```

2. **Cumulative Revenue Over Time**: Analyzes how revenue accumulates over time.
   ```sql
   SELECT order_date, 
      ROUND(SUM(revenue) OVER (ORDER BY order_date), 2) AS cumulative_revenue 
   FROM (
      SELECT o.order_date, ROUND(SUM(od.quantity * p.price), 2) AS revenue 
      FROM orders o 
      JOIN order_details od ON o.order_id = od.order_id 
      JOIN pizzas p ON p.pizza_id = od.pizza_id 
      GROUP BY o.order_date
   ) AS sales_data;
   ```

3. **Top 3 Pizzas by Category Revenue**: Determines the top 3 pizzas in each category based on revenue.
   ```sql
   SELECT category, name, revenue 
   FROM (
      SELECT category, name, revenue, 
         RANK() OVER (PARTITION BY category ORDER BY revenue DESC) AS rank 
      FROM (
         SELECT pt.category, pt.name, SUM(od.quantity * p.price) AS revenue 
         FROM pizza_types pt 
         JOIN pizzas p ON pt.pizza_type_id = p.pizza_type_id 
         JOIN order_details od ON od.pizza_id = p.pizza_id 
         GROUP BY pt.category, pt.name
      ) AS revenue_data
   ) AS ranked_data 
   WHERE rank <= 3;
   ```

---

## How to Run the Queries

1. Import the CSV files into MySQL database tables.
2. Use the provided SQL queries to perform the analysis.
3. Adjust the queries if needed to fit the schema of your database.

---

## Results and Insights

- **Top Pizzas**: The most expensive pizza and the top-selling pizza categories can help tailor marketing strategies.
- **Revenue Patterns**: Analyzing cumulative revenue over time helps in identifying peak sales periods.
- **Order Trends**: Insights from the hour-of-day analysis could guide promotions during high-demand hours.

---

## Conclusion

This project demonstrates how SQL queries can be used to derive actionable insights from a pizza sales dataset. By analyzing sales data, you can inform business decisions and optimize performance.
