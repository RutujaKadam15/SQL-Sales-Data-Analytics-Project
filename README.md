# SQL Sales Data Analytics Project

## Overview
This project is an end-to-end Sales Data Analytics project built using SQL Server. It focuses on designing a data warehouse, importing sales datasets, and performing advanced SQL analysis to extract business insights.

---

## Database Schema

The project follows a Star Schema model:

### Dimension Tables:
- dim_customers
- dim_products

### Fact Table:
- fact_sales

Schema:
```sql
gold
```

---

## Project Workflow

### 1. Database Setup
- Created database
- Created schema
- Designed fact and dimension tables

### 2. Data Loading
Loaded CSV files using BULK INSERT:
- Customers data
- Products data
- Sales data

### 3. Data Exploration
- Table exploration
- Column exploration
- Unique values exploration
- Date analysis

### 4. Measure Analysis
Calculated:
- Total sales
- Total orders
- Total products
- Total customers
- Average selling price

### 5. Magnitude Analysis
Analyzed:
- Revenue by category
- Customers by country
- Product distribution
- Country-wise sales

### 6. Ranking Analysis
Used:
- TOP
- ROW_NUMBER()
- RANK()
- DENSE_RANK()

To identify:
- Top products
- Top customers
- Worst-performing products

### 7. Change Over Time Analysis
Analyzed:
- Monthly sales trends
- Customer growth
- Quantity trends

### 8. Cumulative Analysis
Calculated:
- Running total sales

### 9. Data Segmentation
Segmented:
- Products by cost
- Customers by spending

### 10. Part-to-Whole Analysis
Calculated category contribution to total sales.

---

## SQL Concepts Used

- DDL Commands
- BULK INSERT
- Aggregate Functions
- JOINS
- CTEs
- Window Functions
- Date Functions
- CASE Statements

---

## Key Insights

✔ Top-performing products identified  
✔ High-value customers analyzed  
✔ Monthly trends tracked  
✔ Customer segments created  
✔ Category-wise contribution measured  

---

## Tools Used

- SQL Server
- SSMS
- GitHub

---

## Author

Rutuja Kadam  
AIML Engineer | SQL Developer | Data Analytics
