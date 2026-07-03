/*
=============================================================
Create Database and Schemas
=============================================================
Script Purpose:
    This script creates a new database named 'DataWarehouseAnalytics' after checking if it already exists. 
    If the database exists, it is dropped and recreated. Additionally, this script creates a schema called gold
	
WARNING:
    Running this script will drop the entire 'DataWarehouseAnalytics' database if it exists. 
    All data in the database will be permanently deleted. Proceed with caution 
    and ensure you have proper backups before running this script.
*/

USE master;
GO

-- Drop and recreate the 'DataWarehouseAnalytics' database
IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'DataWarehouseAnalytics')
BEGIN
    ALTER DATABASE DataWarehouseAnalytics SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE DataWarehouseAnalytics;
END;
GO

-- Create the 'DataWarehouseAnalytics' database
CREATE DATABASE DataWarehouseAnalytics;
GO

USE DataWarehouseAnalytics;
GO

-- Create Schemas

CREATE SCHEMA gold;
GO

CREATE TABLE gold.dim_customers(
	customer_key int,
	customer_id int,
	customer_number nvarchar(50),
	first_name nvarchar(50),
	last_name nvarchar(50),
	country nvarchar(50),
	marital_status nvarchar(50),
	gender nvarchar(50),
	birthdate date,
	create_date date
);
GO

CREATE TABLE gold.dim_products(
	product_key int ,
	product_id int ,
	product_number nvarchar(50) ,
	product_name nvarchar(50) ,
	category_id nvarchar(50) ,
	category nvarchar(50) ,
	subcategory nvarchar(50) ,
	maintenance nvarchar(50) ,
	cost int,
	product_line nvarchar(50),
	start_date date 
);
GO

CREATE TABLE gold.fact_sales(
	order_number nvarchar(50),
	product_key int,
	customer_key int,
	order_date date,
	shipping_date date,
	due_date date,
	sales_amount int,
	quantity tinyint,
	price int 
);
GO
drop table gold.dim_products
select * from gold.dim_product

TRUNCATE TABLE gold.dim_customers;
GO

BULK INSERT gold.dim_customers
FROM "C:\Users\asdf\Downloads\sql_data_analytics_project\sql-data-analytics-project\datasets\flat-files\dim_customers.csv"
WITH (
	FIRSTROW = 2,
	FIELDTERMINATOR = ',',
	TABLOCK
);
GO

TRUNCATE TABLE gold.dim_products;
GO

BULK INSERT gold.dim_products
FROM "C:\Users\asdf\Downloads\sql_data_analytics_project\sql-data-analytics-project\datasets\flat-files\dim_products.csv"
WITH (
	FIRSTROW = 2,
	FIELDTERMINATOR = ',',
	TABLOCK
);
GO

TRUNCATE TABLE gold.fact_sales;
GO
drop table gold.fact_sales;
GO

BULK INSERT gold.fact_sales
FROM "C:\Users\asdf\Downloads\sql_data_analytics_project\sql-data-analytics-project\datasets\flat-files\fact_sales.csv"
WITH (
	FIRSTROW = 2,
	FIELDTERMINATOR = ',',
	TABLOCK
);
GO

select * from gold.dim_customers;
select * from gold.dim_products ;
select * from gold.fact_sales ;

select count(*) from gold.fact_sales
---------------------------------------------------------------------------------------------------------
--1.database exploration - for basic understanding of database,tables,views,columns
--------------------------------------------------------------------------------------------------------------

--explore all objects in database
SELECT * FROM INFORMATION_SCHEMA.TABLES;

--explore all colmns in tables
SELECT * FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME ='dim_customers'

-------------------------------------------------------------------------------------------------------------
--2.dimentions exploration - identifying unique values/categories in each dimention.  
--recognizing how data might be grouped and segmented.
---------------------------------------------------------------------------------------------------------

--exlore all countries our customers come from
SELECT DISTINCT country FROM gold.dim_customers;

--explore all categories "the majar divisions"
SELECT *FROM gold.dim_products;

SELECT 
    category,
    subcategory,
    product_name 
FROM gold.dim_products
ORDER BY 1,2,3;


---------------------------------------------------------------------------------------------------------
--3.date exploration -identifying earliest and latest dates and understand scope of data and timespan.
----------------------------------------------------------------------------------------------------------

--Find date of first and last order
SELECT MIN(order_date)AS first_order_date,MAX(order_date) AS last_order_date 
FROM gold.fact_sales;

--How many years of sales are available
SELECT DATEDIFF( YEAR,MIN(order_date),MAX(order_date))AS years_of_sales
FROM gold.fact_sales;;


--Find the youngest and oldest customer 
SELECT 
MAX(birthdate)AS youngest_customer,
MIN(birthdate)AS oldest_customer
FROM gold.dim_customers;

--Find the age of youngest and oldest customer
SELECT
MAX(birthdate)AS youngest_customer,
DATEDIFF(YEAR,MAX(birthdate),GETDATE())AS younghest_customer_age,
MIN(birthdate)AS oldest_customer,
DATEDIFF(YEAR,MIN(birthdate),GETDATE())AS oldest_customer_age
FROM gold.dim_customers;
----------------------------------------------------------------------------------------------------------
--4.measure exploration-for aggregating data - used COUNT(), SUM(), AVG() functions.
----------------------------------------------------------------------------------------------------------

--Find the total sales
SELECT SUM(sales_amount)AS Total_sales
FROM gold.fact_sales;

--Find how many items are sold
SELECT COUNT(quantity)AS Total_items_sold
FROM gold.fact_sales;

--Find the avrage selling price
SELECT AVG(price)AS avg_sellig_price 
FROM gold.fact_sales;

--Find the total number of orders
SELECT COUNT(DISTINCT order_number)AS total_orders
FROM gold.fact_sales;

--Find the total number of products
SELECT COUNT(product_name)AS total_products 
FROM gold.dim_products;

--Find the total number of customers
SELECT COUNT (customer_key)AS total_customers
FROM gold.dim_customers;

--find the total number of customers who has placed an orders
SELECT COUNT(DISTINCT customer_key)AS total_cust_orders
FROM gold.dim_customers;

-- Generate a Report that shows all key metrics of the business
SELECT 'sales_amount'AS measure_name,SUM(sales_amount)AS measure_value FROM  gold.fact_sales
UNION ALL
SELECT 'Total Quantity', SUM(quantity) FROM gold.fact_sales
UNION ALL
SELECT 'Average Price', AVG(price) FROM gold.fact_sales
UNION ALL
SELECT 'Total Orders', COUNT(DISTINCT order_number) FROM gold.fact_sales
UNION ALL
SELECT 'Total Products', COUNT(DISTINCT product_name) FROM gold.dim_products
UNION ALL
SELECT 'Total Customers', COUNT(customer_key) FROM gold.dim_customers;

-------------------------------------------------------------------------------------------------------------
/* 5.Magnitude Analysis -Understanding data distribution across categories and group result by dimentions
Use Aggregate Functions with Group By,Order By */
------------------------------------------------------------------------------------------------------------

-- Find total customers by countries
SELECT
    country,
    COUNT(customer_key) AS total_customers
FROM gold.dim_customers
GROUP BY country
ORDER BY total_customers DESC;
 
 -- Find total customers by gender
 SELECT
    gender,
    COUNT(customer_key) AS total_customers
FROM gold.dim_customers
GROUP BY gender
ORDER BY total_customers DESC;

-- Find total products by category
select * from gold.dim_products
SELECT
    category,
    COUNT(product_key) AS total_products
FROM gold.dim_products
GROUP BY category
ORDER BY total_products DESC;

-- What is the average costs in each category?
SELECT
    category,
    AVG(cost) AS avg_cost
FROM gold.dim_products
GROUP BY category
ORDER BY avg_cost DESC;

-- What is the total revenue generated for each category?
select * from gold.fact_sales;
select * from gold.dim_products;
SELECT
    p.category,
    SUM(f.sales_amount) AS total_revenue
FROM gold.fact_sales f
LEFT JOIN gold.dim_products p
    ON p.product_key = f.product_key
GROUP BY p.category
ORDER BY total_revenue DESC;

-- What is the total revenue generated by each customer?
SELECT * FROM gold.dim_customers;
SELECT
    c.customer_key,
    c.first_name,
    c.last_name,
    SUM(f.sales_amount) AS total_revenue
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c
    ON c.customer_key = f.customer_key
GROUP BY 
    c.customer_key,
    c.first_name,
    c.last_name
ORDER BY total_revenue DESC;

-- What is the distribution of sold items across countries?
SELECT
    c.country,
    SUM(f.quantity) AS total_sold_items
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c
    ON c.customer_key = f.customer_key
GROUP BY c.country
ORDER BY total_sold_items DESC;


-------------------------------------------------------------------------------------------------------------
/*6.Ranking Analysis - To rank items (e.g., products, customers) based on performance or other metrics.
-To identify top performers - Window Ranking Functions: RANK(), DENSE_RANK(), ROW_NUMBER(), TOP
-Clauses: GROUP BY, ORDER BY*/
--------------------------------------------------------------------------------------------------------------

-- Which 5 products Generating the Highest Revenue? we can use product_name or subcategory
SELECT TOP 5
    p.subcategory,
    SUM(f.sales_amount) AS total_revenue
FROM gold.fact_sales f
LEFT JOIN gold.dim_products p
    ON p.product_key = f.product_key
GROUP BY  p.subcategory
ORDER BY total_revenue  DESC;

-- Complex but Flexibly Ranking Using Window Functions - same question
SELECT * FROM
(SELECT
    p.product_name,
    SUM(f.sales_amount) AS total_revenue,
    ROW_NUMBER ()OVER(ORDER BY SUM(f.sales_amount) DESC)AS product_rank
FROM gold.fact_sales f
LEFT JOIN gold.dim_products p
    ON p.product_key = f.product_key
GROUP BY  p.product_name)t 
WHERE product_rank <= 5;

-- What are the 5 worst-performing products in terms of sales
SELECT TOP 5
    p.product_name,
    SUM(f.sales_amount) AS total_revenue
FROM gold.fact_sales f
LEFT JOIN gold.dim_products p
    ON p.product_key = f.product_key
GROUP BY  p.product_name
ORDER BY total_revenue;

-- Find the top 10 customers who have generated the highest revenue
SELECT TOP 10
    c.customer_key,
    c.first_name,
    c.last_name,
    SUM(f.sales_amount) AS total_revenue
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c
    ON c.customer_key = f.customer_key
GROUP BY 
    c.customer_key,
    c.first_name,
    c.last_name
ORDER BY total_revenue DESC;

-- The 3 customers with the fewest orders placed
SELECT TOP 3
    c.customer_key,
    c.first_name,
    c.last_name,
    COUNT(DISTINCT order_number) AS total_orders
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c
    ON c.customer_key = f.customer_key
GROUP BY 
    c.customer_key,
    c.first_name,
    c.last_name
ORDER BY total_orders;

------------------------------------------------------------------------------------------------------------
/* 7.Change Over Time Analysis
    - To track trends, growth, and changes in key metrics over time.
    - For time-series analysis and identifying seasonality.
    - To measure growth or decline over specific periods.

SQL Functions Used:
    - Date Functions: DATEPART(), DATETRUNC(), FORMAT()
    - Aggregate Functions: SUM(), COUNT(), AVG() */
-----------------------------------------------------------------------------------------------------------

-- Analyse sales performance over time
-- Date Functions
SELECT
      YEAR(order_date)AS order_year,
	  MONTH(order_date)AS order_month,
	  SUM(sales_amount)AS total_revenue,
	  COUNT(distinct customer_key)  AS total_customers,
	  SUM(quantity)AS  total_quantity
FROM gold.fact_sales
WHERE order_date is not null
GROUP BY YEAR(order_date),MONTH(order_date)
ORDER BY YEAR(order_date),MONTH(order_date);

--DATETRUNC()
SELECT DATETRUNC(MONTH,order_date) AS  order_date,
       SUM(sales_amount) AS total_sales,
	   COUNT(distinct customer_key)AS total_customers,
	   SUM(quantity) AS total_quantity
FROM  gold.fact_sales
WHERE order_date is not null
GROUP BY DATETRUNC(MONTH,order_date)
ORDER BY DATETRUNC(MONTH,order_date);

-- FORMAT()
SELECT 
     FORMAT(order_date,'yyyy-mm')AS order_date,
	 SUM(sales_amount)AS total_sales,
	 COUNT( distinct customer_key)AS total_customers,
	 SUM(quantity) AS total_quantity
FROM gold.fact_sales
WHERE order_date is not null
GROUP BY  FORMAT(order_date,'yyyy-mm')
ORDER BY FORMAT(order_date,'yyyy-mm');

---------------------------------------------------------------------------------------------------------
/* 8.Cumulative Analysis
    - To calculate running totals or moving averages for key metrics.
    - To track performance over time cumulatively.
    - Useful for growth analysis or identifying long-term trends.
	SQL Functions Used:
    - Window Functions: SUM() OVER(), AVG() OVER()*/
----------------------------------------------------------------------------------------------------------

-- Calculate the total sales per month 
-- and the running total of sales over time 
SELECT 
order_date,
total_sales,
SUM(total_sales)OVER(ORDER BY order_date) AS runnig_total_sales
FROM 
(SELECT
DATETRUNC (month,order_date) AS order_date,
SUM(sales_amount)AS total_sales
FROM gold.fact_sales
WHERE ORDER_DATE IS NOT NULL
GROUP BY DATETRUNC (month,order_date)
)t

-------------------------------------------------------------------------------------------------------------
/*9.Data Segmentation Analysis
Purpose:
    - To group data into meaningful categories for targeted insights.
    - For customer segmentation, product categorization, or regional analysis.
SQL Functions Used:
    - CASE: Defines custom segmentation logic.
    - GROUP BY: Groups data into segments.*/
------------------------------------------------------------------------------------------------------------

/*Segment products into cost ranges and 
count how many products fall into each segment*/

WITH product_segments AS (
    SELECT
        product_key,
        product_name,
        cost,
        CASE 
            WHEN cost < 100 THEN 'Below 100'
            WHEN cost BETWEEN 100 AND 500 THEN '100-500'
            WHEN cost BETWEEN 500 AND 1000 THEN '500-1000'
            ELSE 'Above 1000'
        END AS cost_range
    FROM gold.dim_products
)
SELECT 
    cost_range,
    COUNT(product_key) AS total_products
FROM product_segments
GROUP BY cost_range
ORDER BY total_products DESC;

/*Group customers into three segments based on their spending behavior:
	- VIP: Customers with at least 12 months of history and spending more than €5,000.
	- Regular: Customers with at least 12 months of history but spending €5,000 or less.
	- New: Customers with a lifespan less than 12 months.
And find the total number of customers by each group
*/
WITH customer_spending AS (
    SELECT
        c.customer_key,
        SUM(f.sales_amount) AS total_spending,
        MIN(order_date) AS first_order,
        MAX(order_date) AS last_order,
        DATEDIFF(month, MIN(order_date), MAX(order_date)) AS lifespan
    FROM gold.fact_sales f
    LEFT JOIN gold.dim_customers c
        ON f.customer_key = c.customer_key
    GROUP BY c.customer_key
)
SELECT 
    customer_segment,
    COUNT(customer_key) AS total_customers
FROM (
    SELECT 
        customer_key,
        CASE 
            WHEN lifespan >= 12 AND total_spending > 5000 THEN 'VIP'
            WHEN lifespan >= 12 AND total_spending <= 5000 THEN 'Regular'
            ELSE 'New'
        END AS customer_segment
    FROM customer_spending
) AS segmented_customers
GROUP BY customer_segment
ORDER BY total_customers DESC;

------------------------------------------------------------------------------------------------------------
/* 10.Part-to-Whole Analysis
Purpose:
    - To compare performance or metrics across dimensions or time periods.
    - To evaluate differences between categories.
    - Useful for A/B testing or regional comparisons.
SQL Functions Used:
    - SUM(), AVG(): Aggregates values for comparison.
    - Window Functions: SUM() OVER() for total calculations.*/
---------------------------------------------------------------------------------------------------------------

-- Which categories contribute the most to overall sales?
WITH category_sales AS (
    SELECT
        p.category,
        SUM(s.sales_amount) AS total_sales
    FROM gold.fact_sales s
    LEFT JOIN gold.dim_products p
        ON p.product_key = s.product_key
    GROUP BY p.category
)
SELECT
    category,
    total_sales,
    SUM(total_sales) OVER () AS overall_sales,
    ROUND((CAST(total_sales AS FLOAT) / SUM(total_sales) OVER ()) * 100, 2) AS percentage_of_total
FROM category_sales
ORDER BY total_sales DESC;



 
