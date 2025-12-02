create database textile_tales;
use  textile_tales; 
select * from sales;
select * from product_details;
select * from product_prices;
select * from product_hierarchy;


/*Q9 What are the total quantity, 
revenue and discount for each
segment?*/


SELECT 
    pd.segment_name,
    SUM(s.qty)                  AS total_qty,
    SUM(s.price)                AS total_price,       -- or remove if not meaningful
    SUM(s.discount)             AS total_discount,   
    SUM( CAST(s.qty AS int) * CAST(s.price AS decimal(18,2)) ) AS revenue
FROM sales s
JOIN product_details pd 
  ON pd.product_id = s.prod_id
GROUP BY pd.segment_name;        

/*Q10 What is the top selling product for each segment?*/

SELECT pd.segment_name,pd.product_name as top_selling_product,SUM(s.qty) AS total_quantity FROM product_details pd

JOIN sales s 
ON 
s.prod_id = pd.product_id

GROUP BY pd.segment_name, pd.product_name
HAVING SUM(s.qty) = (
    SELECT MAX(sub.total_qty)
    FROM (
        SELECT SUM(s2.qty) AS total_qty
        FROM sales s2
        JOIN product_details pd2 ON pd2.product_id = s2.prod_id
        WHERE pd2.segment_name = pd.segment_name
        GROUP BY pd2.product_name
    ) AS sub
)
ORDER BY pd.segment_name;

/*Q11 What are the total quantity, revenue and discount for each
category?*/

SELECT 
    pd.category_name,
    SUM(s.qty)                  AS total_qty,      
    SUM(s.discount)             AS total_discount,   
    SUM( CAST(s.qty AS int) * CAST(s.price AS decimal(18,2)) ) AS revenue
FROM sales s
JOIN product_details pd 
  ON pd.product_id = s.prod_id
GROUP BY pd.category_name; 

/*Q12 What is the top selling product for each category?*/

SELECT pd.category_name,pd.product_name as top_selling_product,SUM(s.qty) AS total_quantity FROM product_details pd

JOIN sales s 
ON 
s.prod_id = pd.product_id

GROUP BY pd.category_name, pd.product_name
HAVING SUM(s.qty) = (
    SELECT MAX(sub.total_qty)
    FROM (
        SELECT SUM(s2.qty) AS total_qty
        FROM sales s2
        JOIN product_details pd2 ON pd2.product_id = s2.prod_id
        WHERE pd2.category_name = pd.category_name
        GROUP BY pd2.product_name
    ) AS sub
)
ORDER BY pd.category_name;
