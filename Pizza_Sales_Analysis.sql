CREATE DATABASE pizza;

create table order_details (
order_details_id int not null,
order_id int not null,
pizza_id text not null,
quantity int not null,
primary key (order_details_id));

-- 01 Retrieve the total number of orders placed.
SELECT 
    COUNT(order_id) Total_orders
FROM
    orders;

-- 02 Calculate the total revenue generated from pizza sales.
SELECT 
    ROUND(SUM(od.quantity * p.price), 2) Total_sales
FROM
    order_details od
        JOIN
    pizzas p ON od.pizza_id = p.pizza_id;
    
-- 03 Identify the highest-priced pizza.

SELECT 
    pt.name, p.price
FROM
    pizza_types pt
        JOIN
    pizzas p ON pt.pizza_type_id = p.pizza_type_id
ORDER BY p.price DESC
LIMIT 1;

-- 04 Identify the most common pizza size ordered

SELECT 
    p.size, COUNT(od.quantity) total_orders
FROM
    order_details od
        JOIN
    pizzas p ON od.pizza_id = p.pizza_id
GROUP BY p.size
ORDER BY total_orders DESC;

-- 05 List the top 5 most ordered pizza types along with their quantities.
SELECT 
    pt.name, SUM(od.quantity) total_order_quantity
FROM
    order_details od
        JOIN
    pizzas p ON od.pizza_id = p.pizza_id
        JOIN
    pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
GROUP BY pt.name
ORDER BY total_order_quantity DESC
LIMIT 5;

-- 06 Join the necessary tables to find the total quantity of each pizza category ordered.

SELECT 
    pt.category, SUM(od.quantity) total_order_quantity
FROM
    order_details od
        JOIN
    pizzas p ON od.pizza_id = p.pizza_id
        JOIN
    pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
GROUP BY pt.category
ORDER BY total_order_quantity DESC;

-- 07 Determine the distribution of orders by hour of the day.

select hour(order_time) `Hour`, count(order_id) order_count
from orders 
group by `hour`;

-- 08 Determine the total orders by hour of the day.

select hour(o.order_time) `Hour`, count(od.quantity) total_orders
from orders o
join order_details od
on o.order_id = od.order_id
group by `hour`;

-- 09 Join relevant tables to find the category-wise distribution of pizzas.
-- Types od pizzas under each category

select category, count(name) 
from pizza_types
group by category;

-- 10 Group the orders by date and calculate the average number of pizzas ordered per day.

SELECT 
    ROUND(AVG(total_orders), 0) AVG_pizza_per_day
FROM
    (SELECT 
        o.order_date date, SUM(od.quantity) total_orders
    FROM
        orders o
    JOIN order_details od ON o.order_id = od.order_id
    GROUP BY date) AS Total_quantity_ordered;

-- 11 Group the orders by date and calculate the average number of orders per day.

SELECT 
    ROUND(AVG(total_orders), 0) AVG_orders
FROM
    (SELECT 
        o.order_date date, COUNT(od.order_id) total_orders
    FROM
        orders o
    JOIN order_details od ON o.order_id = od.order_id
    GROUP BY date) AS total_orders;
    
-- 12 Determine the top 3 most ordered pizza types based on revenue.

SELECT 
    pt.name, SUM(od.quantity * p.price) revenue
FROM
    order_details od
        JOIN
    pizzas p ON p.pizza_id = od.pizza_id
        JOIN
    pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
GROUP BY pt.name
ORDER BY revenue DESC
LIMIT 3;

-- 13 Calculate the percentage contribution of each pizza type to total revenue.

SELECT 
    pt.category, round(SUM(od.quantity * p.price)/ (select sum(od.quantity*p.price)
    FROM
    order_details od
        JOIN
    pizzas p ON p.pizza_id = od.pizza_id)* 100,2) as Percentage_revenue
FROM
    order_details od
        JOIN
    pizzas p ON p.pizza_id = od.pizza_id
        JOIN
    pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
GROUP BY pt.category
ORDER BY percentage_revenue DESC;

-- 14 Analyze the cumulative revenue generated over time.
select order_date, revenue,
sum(revenue) over(order by order_date) Cum_revenue
from
(SELECT 
    o.order_date, round(SUM(od.quantity * p.price),0) revenue
FROM
    order_details od
        JOIN
    pizzas p ON od.pizza_id = p.pizza_id
        JOIN
    orders o ON o.order_id = od.order_id
GROUP BY order_date) sales_per_day;

-- 15 Determine the top 3 most ordered pizza types based on revenue for each pizza category

select category, name, revenue
from
(select category, name, revenue,
rank() over (partition by category order by revenue Desc) rn
from 
(SELECT pt.category, pt.name, sum(od.quantity*p.price) revenue
FROM pizza_types pt
join pizzas p
on p.pizza_type_id = pt.pizza_type_id
join order_details od
on od.pizza_id = p.pizza_id 
group by 1, 2) as a ) b
where rn <= 3;
    