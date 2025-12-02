create database ecomm

CREATE TABLE products (
    product_id INT IDENTITY(1,1) PRIMARY KEY,
    product_name TEXT NOT NULL,
    unit_price   NUMERIC(10,2) NOT NULL CHECK (unit_price >= 0),
    currency     CHAR(3) NOT NULL DEFAULT 'INR'
);

INSERT INTO products (product_name, unit_price, currency)
VALUES
('Wireless Earbuds', 1999.00, 'INR'),
('Bluetooth Speaker', 2499.00, 'INR'),
('Gaming Laptop', 59999.00, 'INR'),
('Smartphone', 14999.00, 'INR'),
('Microwave Oven', 7999.00, 'INR'),
('Air Purifier', 12999.00, 'INR'),
('Smartwatch', 4999.00, 'INR'),
('Office Chair', 8999.00, 'INR'),
('Yoga Mat', 499.00, 'INR'),
('Power Bank', 999.00, 'INR');

CREATE TABLE customers (
    customer_id INT IDENTITY(1,1) PRIMARY KEY,  -- Auto-increment
    first_name VARCHAR(50) NOT NULL,
    last_name  VARCHAR(50) NOT NULL,
    email      VARCHAR(100) NOT NULL UNIQUE,
    phone      VARCHAR(15),
    created_at DATETIME DEFAULT GETDATE()
);

INSERT INTO customers (first_name, last_name, email, phone)
VALUES
('John', 'Smith', 'john.smith@example.com', '+1-202-555-0101'),
('Emily', 'Johnson', 'emily.johnson@example.com', '+1-202-555-0102'),
('Michael', 'Williams', 'michael.williams@example.com', '+1-202-555-0103'),
('Sarah', 'Brown', 'sarah.brown@example.com', '+1-202-555-0104'),
('David', 'Jones', 'david.jones@example.com', '+1-202-555-0105'),
('Jessica', 'Garcia', 'jessica.garcia@example.com', '+1-202-555-0106'),
('Daniel', 'Miller', 'daniel.miller@example.com', '+1-202-555-0107'),
('Ashley', 'Davis', 'ashley.davis@example.com', '+1-202-555-0108'),
('Matthew', 'Martinez', 'matthew.martinez@example.com', '+1-202-555-0109'),
('Olivia', 'Taylor', 'olivia.taylor@example.com', '+1-202-555-0110');

CREATE TABLE orders (
    order_id INT IDENTITY(1,1) PRIMARY KEY,  -- Auto-increment
    customer_id INT NOT NULL FOREIGN KEY REFERENCES customers(customer_id),
    product_id INT NOT NULL FOREIGN KEY REFERENCES products(product_id),
    quantity INT NOT NULL CHECK (quantity > 0),
    unit_price DECIMAL(10,2) NOT NULL CHECK (unit_price >= 0),
    order_total DECIMAL(12,2) NOT NULL CHECK (order_total >= 0),
    order_status VARCHAR(20) NOT NULL CHECK (order_status IN ('pending','paid','shipped','delivered','cancelled')),
    order_date DATETIME DEFAULT GETDATE()
);


INSERT INTO orders (customer_id, product_id, quantity, unit_price, order_total, order_status)
VALUES
(1, 3, 1, 59999.00, 59999.00, 'paid'),        -- John buys Gaming Laptop
(2, 1, 2, 1999.00, 3998.00, 'shipped'),       -- Emily buys 2 Wireless Earbuds
(3, 4, 1, 14999.00, 14999.00, 'delivered'),   -- Michael buys Smartphone
(4, 2, 1, 2499.00, 2499.00, 'pending'),       -- Sarah buys Bluetooth Speaker
(5, 7, 1, 4999.00, 4999.00, 'paid'),          -- David buys Smartwatch
(6, 10, 3, 999.00, 2997.00, 'delivered'),     -- Jessica buys 3 Power Banks
(7, 5, 1, 7999.00, 7999.00, 'shipped'),       -- Daniel buys Microwave Oven
(8, 6, 1, 12999.00, 12999.00, 'paid'),        -- Ashley buys Air Purifier
(9, 8, 1, 8999.00, 8999.00, 'pending'),       -- Matthew buys Office Chair
(10, 9, 2, 499.00, 998.00, 'delivered');      -- Olivia buys 2 Yoga Mats

/*Using the 'in' command */
select * from customers
where customer_id in (2,4,7);

select top 3 p.product_name, p.unit_price from products p
order by p.unit_price DESC;

/* Query to get top 3 product by price using joins*/
SELECT TOP 3 p.product_name, p.unit_price, c.first_name
FROM orders o
JOIN products p ON p.product_id = o.product_id
JOIN customers c ON c.customer_id = o.customer_id
ORDER BY p.unit_price DESC;

/*Count orders by status*/
select order_status, count(order_id) as count from orders
group by order_status;

/*Customer who spent the most money*/
select top 3  c.first_name, c.last_name,  o.order_total from customers c
join orders o 
on o.customer_id = c.customer_id
order by order_total desc;

/*all orders with customer name, product name, quantity, and total amount*/
select c.first_name, p.product_name, o.quantity, o.order_total as total_amount  from orders o
join customers c on c.customer_id = o.customer_id
join products p on p.product_id = o.customer_id
order by c.first_name;

/*List customers who bought products priced above ₹10,000*/
select c.first_name,o.order_total, p.product_name from customers c
join orders o on o.customer_id = c.customer_id
join products p on o.product_id = p.product_id
where o.order_total> 10000
order by c.first_name;

/*customer name, product name, and order status for all delivered orders.*/
select c.first_name, p.product_name, o.order_status from customers c
join orders o on c.customer_id=o.customer_id
join products p on o.product_id = p.product_id
where o.order_status = 'delivered'
order by c.first_name;

/*Using Subquery*/

/*all products priced above the average unit price*/
select p.product_name from products p
where p.unit_price > (select AVG(unit_price) from products);

/*Show all customers who placed an order for the most expensive product.*/
select first_name from customers 
where customer_id IN (select customer_id from orders 
where unit_price = (select max(unit_price) from orders));

/*the customer(s) who purchased the most expensive product 
AND also purchased at least one product priced 
below the average price of all products.*/


/*CTE- common table expressions*/

WITH customer_spending AS (
    SELECT customer_id, SUM(order_total) AS total_spent
    FROM orders
    GROUP BY customer_id
)
SELECT c.first_name, cs.total_spent
FROM customer_spending cs
JOIN customers c ON cs.customer_id = c.customer_id

/*Find the top 3 customers who spent the most money, but only include customers 
whose total spending is above the average spending of all customers. Use a CTE*/

with customer_spending as ( select customer_id, sum(quantity*unit_price) as total_spent 
from orders 
group by customer_id)

SELECT  c.first_name, cs.total_spent
FROM customer_spending cs
JOIN customers c ON cs.customer_id = c.customer_id
WHERE cs.total_spent > (SELECT AVG(total_spent) FROM customer_spending)
ORDER BY cs.total_spent DESC;



create view above_avg as
select product_id, product_name, unit_price 
from products
having unit_price>AVG(unit_price);

select * from above_avg;

create procedure select_orderdetails
as 
select * from orders
go;

exec select_orderdetails

create procedure high_username @username varchar(50)
as 
begin
select * from customers
where first_name = @username;
end;
EXEC high_username @username = 'John';



SELECT order_status, SUM(order_total) AS total_sales
FROM orders
GROUP BY order_status;


SELECT order_status, SUM(order_total) AS total_sales
FROM orders
GROUP BY ROLLUP(order_status);


SELECT  order_status,order_date, SUM(order_total) AS total_sales
FROM orders
GROUP BY ROLLUP(order_date, order_status);



select * from customers
select * from products
select * from orders

