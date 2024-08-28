create database Pizzahut;
use Pizzahut;

create table orders
(
order_id int not null,
order_date date not null,
order_time time not null,
primary key(order_id)
);
SELECT * FROM ORDERS;

create table order_details
(
order_details_id int not null,
order_id int not null,
pizza_id text not null,
quantity int not null,
primary key(order_details_id)
);



SELECT 
    *
FROM
    pizza_types;


SELECT * FROM pizzas;







#BASIC



#1.Retrieve the total number of orders placed.
SELECT 
    COUNT(order_id) AS NO_OF_ORDERS
FROM
    orders;







#2.Calculate the total revenue generated from pizza sales.
SELECT 
    ROUND(SUM(P.price * OD.quantity), 2) AS Total_Revenue
FROM
    pizzas P
        INNER JOIN
    order_details OD ON OD.pizza_id = P.pizza_id; 



#3.Identify the highest-priced pizza.
SELECT 
    name, P.pizza_type_id, P.pizza_id, price
FROM
    pizzas P
        INNER JOIN
    pizza_types PT ON P.pizza_type_id = PT.pizza_type_id
ORDER BY price DESC
LIMIT 1;


#4.Identify the most common pizza size ordered.
SELECT 
    size, COUNT(order_details_id) AS most_ordered
FROM
    order_details OD
        INNER JOIN
    pizza_types PT
        INNER JOIN
    pizzas P ON PT.pizza_type_id = P.pizza_type_id
        AND OD.pizza_id = P.pizza_id
GROUP BY size
ORDER BY most_ordered DESC
LIMIT 1;





#5.List the top 5 most ordered pizza types along with their quantities.
SELECT 
    name, PT.pizza_type_id, SUM(quantity) AS QUANTITY
FROM
    pizzas P
        INNER JOIN
    order_details OD
        INNER JOIN
    pizza_types PT ON OD.pizza_id = P.pizza_id
        AND PT.pizza_type_id = P.pizza_type_id
GROUP BY pizza_type_id , name
ORDER BY QUANTITY DESC
LIMIT 5; 

#Intermediate:
#6.Join the necessary tables to find the total quantity of each pizza category ordered.

SELECT 
    category, SUM(quantity) AS TOTAL_QUANTITY
FROM
    pizzas P
        INNER JOIN
    order_details OD
        INNER JOIN
    pizza_types PT ON OD.pizza_id = P.pizza_id
        AND PT.pizza_type_id = P.pizza_type_id
GROUP BY category
ORDER BY TOTAL_QUANTITY DESC;

#7.Determine the distribution of orders by hour of the day.
SELECT 
    HOUR(order_time) AS HOURS, COUNT(order_id) AS ORDER_COUNT
FROM
    orders
GROUP BY HOURS;

#8.Join relevant tables to find the category-wise distribution of pizzas.
SELECT 
    category, COUNT(name)
FROM
    pizza_types
GROUP BY category;

#9.Group the orders by date and calculate the average number of pizzas ordered per day.
SELECT 
    ROUND(AVG(NO_OF_ORDERS), 0) AS AVG_PIZZAS_ORDERED_PER_DAY
FROM
    (SELECT 
        order_date, SUM(quantity) AS NO_OF_ORDERS
    FROM
        orders O
    INNER JOIN order_details OD ON OD.order_id = O.order_id
    GROUP BY order_date) AS XYZ;


#10.Determine the top 3 most ordered pizza types based on revenue.
SELECT 
    name, SUM(quantity * price) AS REVENUE
FROM
    order_details OD
        INNER JOIN
    pizzas P
        INNER JOIN
    pizza_types PT ON OD.pizza_id = P.pizza_id
        AND PT.pizza_type_id = P.pizza_type_id
GROUP BY name
ORDER BY REVENUE DESC
LIMIT 3;

#Advanced:
#11.Calculate the percentage contribution of each pizza type to total revenue.
SELECT category,ROUND(ROUND(SUM(quantity * price), 0) / 
(SELECT ROUND(SUM(P.price * OD.quantity), 2) AS Total_revenue
FROM pizzas P
INNER JOIN order_details OD 
ON OD.pizza_id = P.pizza_id) * 100,1) AS PERCENTAGE
FROM order_details OD
INNER JOIN pizzas P
INNER JOIN pizza_types PT 
ON OD.pizza_id = P.pizza_id
AND PT.pizza_type_id = P.pizza_type_id
GROUP BY category
ORDER BY ROUND(SUM(quantity * price), 0) DESC;

#12.Analyze the cumulative revenue generated over time.
SELECT order_date,REVENUE,SUM(REVENUE)OVER(ORDER BY order_date) AS CUMULATIVE_REVENUE
FROM
(SELECT order_date,ROUND(SUM(price*quantity),0) as REVENUE FROM pizzas P
inner join order_details OD
INNER JOIN orders O
on OD.pizza_id=P.pizza_id AND OD.order_id=O.order_id 
GROUP BY order_date)
AS XYZ;

#13.Determine the top 3 most ordered pizza types based on revenue for each pizza category.

SELECT name,revenue from (select category,name,revenue,
rank()over (partition by category order by REVENUE desc) as rn
 from (SELECT category,name,ROUND(SUM(price*quantity),1) as revenue FROM order_details OD
INNER JOIN pizza_types PT
INNER JOIN pizzas P
ON OD.pizza_id=P.pizza_id AND PT.pizza_type_id=P.pizza_type_id
GROUP BY category,name)as xyz)as ABC
where rn<=3;





SELECT * FROM order_details;
SELECT * FROM orders;
SELECT * FROM pizza_types ;
SELECT * FROM pizzas;


#BUSINESS QUESTIONS
#1.How many customers do we have each day?
USE pizzahut;
SELECT 
    ROUND(COUNT(order_id) / COUNT(DISTINCT order_date),
            0) AS AVERAGE_NO_OF_CUSTOMERS_PER_DAY
FROM
    orders;

 #2. Are there any peak hours?
SELECT COUNT(order_id) AS NO_OF_ORDERS,HOUR(order_time) AS HOURS
FROM orders
GROUP BY HOURS 
ORDER BY NO_OF_ORDERS DESC;


#THE BEST HOURS ARE 12A.M,1 P.M AND 6 P.M
#(THE TOTAL NO OF ORDERS DURING SPECIFIC HOURS)

#3.Are there any crest hours?
SELECT COUNT(order_id) AS NO_OF_ORDERS,HOUR(order_time) AS HOURS
FROM orders
GROUP BY HOURS 
ORDER BY NO_OF_ORDERS ASC;

#THE LEAST SALES WAS DURING 9A.M,10A.M,11P.M AND 10P.M

#4.Are there any peak Days?
 
SELECT COUNT(order_id) AS NO_OF_ORDERS,order_date AS DAYS FROM orders
GROUP BY DAYS
ORDER BY NO_OF_ORDERS DESC ;

#I DETERMINED THAT THE MOST SALES WAS ON NOVEMBER 11 2015



#5. Are there any crest Days?
SELECT COUNT(order_id) AS NO_OF_ORDERS,order_date AS DAYS FROM orders
GROUP BY DAYS
ORDER BY NO_OF_ORDERS ASC ;



#THE LEAST SALES WAS ON 29TH DECEMBER 2015.


#6.How many pizzas are typically in an order? Do we have any bestsellers?
SELECT pizza_id,COUNT(quantity) AS ORDERS FROM order_details
GROUP BY pizza_id
ORDER BY ORDERS DESC ;


# MORE SMALL_BIG_MEAT PIZZAS ARE SOLD,THAN ANY OTHER PIZZAS

#7.	Which pizza generated the most revenue? 
SELECT OD.pizza_id,ROUND(SUM(quantity*price),0)AS REVENUE FROM order_details OD
INNER JOIN pizzas P
ON OD.pizza_id=P.pizza_id
GROUP BY OD.pizza_id
ORDER BY REVENUE DESC
LIMIT 1;

#LARGE THAI CHICKEN PIZZA GENERATED THE MOST REVENUE


#8.	Which pizza generated the least revenue? 
SELECT OD.pizza_id,ROUND(SUM(quantity*price),0)AS REVENUE FROM order_details OD
INNER JOIN pizzas P
ON OD.pizza_id=P.pizza_id
GROUP BY OD.pizza_id
ORDER BY REVENUE ASC
LIMIT 1;

#ANS.THE GREEK EXTRA LARGE PIZZA HAS GENERATED THE LEAST REVENUE THAN ANY OTHER PIZZAS.


