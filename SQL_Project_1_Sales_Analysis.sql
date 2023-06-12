/* Creating The Table */
create table if not exists store (
Row_ID serial,
Order_ID char(25),
Order_Date date,
Ship_Date date,
Ship_Mode varchar(50),
Customer_ID char(25),
Customer_Name varchar(75),
Segment varchar(25),
Country varchar(50),
City varchar(50),
States varchar(50),
Postal_Code int,
Region varchar(12),
Product_ID varchar(75),
Category varchar(25),
Sub_Category varchar(25),
Product_Name varchar(255),
Sales float,
Quantity int,
Discount float,
Profit float,
Discount_amount float,
Years int,
Customer_Duration varchar(50),
Returned_Items varchar(50),
Return_Reason varchar(255)
) 


/* checking the raw Table */
select * from store;




/* Importing csv file */
set client_encoding = 'ISO_8859_5';
copy store(Row_ID,Order_ID,Order_Date,Ship_Date,Ship_Mode,Customer_ID,Customer_Name,Segment,Country,City,States,Postal_Code,Region,Product_ID,Category,Sub_Category,Product_Name,Sales,Quantity,Discount,Profit,Discount_Amount,Years,Customer_Duration,Returned_Items,Return_Reason)
from 'C:\to path\Store.csv'
delimiter ','
csv 
header;


/* checking the dataset */
select * from store
limit 10;

/*Database Size*/
select pg_size_pretty(pg_database_size('SuperStore'));


/*Table Size*/
select pg_size_pretty(pg_relation_size('store'));

-- DATASET  INFORMATION
-- Customer_Name   : Customer's Name
-- Customer_Id  : Unique Id of Customers
-- Segment : Product Segment
-- Country : United States
-- City : City of the product ordered
-- State : State of product ordered
-- Product_Id : Unique Product ID
-- Category : Product category
-- Sub_Category : Product sub category
-- Product_Name : Name of the product
-- Sales : Sales contribution of the order
-- Quantity : Quantity Ordered
-- Discount : % discount given
-- Profit : Profit for the order
-- Discount_Amount : discount  amount of the product 
-- Customer Duration : New or Old Customer
-- Returned_Item :  whether item returned or not
-- Returned_Reason : Reason for returning the item

/* row count and column count of data */
select count(*) as row_count from store

select count(*) as column_count from information_schema.columns 
where table_name = 'store'


/* Checking datadset information (column names)*/
select * from information_schema.columns where table_name = 'store'

/* using a nested query to check null values of store data */

select * from store 
where
(select column_name from information_schema.columns where table_name = 'store') = NULL

/* No missing values found */

/* Dropping unnecessary column Row_ID */
alter table store drop column row_id;
select * from store limit 10

/* Product Analysis */
   
/* the unique product categories */
select distinct (Category) from store

/* number of products in each category? */
select category, count(distinct product_id) from store
order by  count(*) desc

/* number of Subcategories products that are divided. */
select count(distinct (Sub_Category)) from store

/* number of products in each sub-category. */
select sub_category, count(distinct product_id) from store
group by sub_category

/* number of unique product names. */
select count(distinct (Product_Name)) As No_of_unique_products
from store

/* Top 10 Products that are ordered frequently*/
select product_name, count(*) as order_count from store
group by product_name
order by count(*) desc
limit 10

/* cost for each Order_ID with respect to product name. */
select order_id, product_name, round(CAST(sales - profit as numeric), 2) as cost from store

/* % profit for each Order_ID with respect to product name. */
select order_id, product_name, round(cast((profit/(sales - profit))*100 as numeric), 2) as percentage_profit 
from store

/* the overall profit of the store. */
select round(cast((sum(profit)/(sum(sales) - sum(profit)))*100 as numeric), 2) from store

/* Calculate percentage profit and group by them with Product Name and Order_Id. */
select  order_id,Product_Name,((profit/((sales-profit))*100)) as percentage_profit
from store
group by order_id,Product_Name,percentage_profit

/* Calculating average sales and average profit*/

select round(cast(avg(sales) as numeric),2) as avg_sales
from store;
-- the average sales on any given product is 229.8, so approx. 230.

select round(cast(avg(Profit)as numeric),2) as avg_profit
from store;
-- the average profit on any given product is 28.6, or approx 29.


/* Average sales per sub-category */
select sub_category, round(cast(avg(sales) as numeric), 2) as average_sales from store
group by sub_category
order by average_sales
limit 9
--The sales of these Sub_category products are below the average sales.

/* Average profit per sub-category */
select sub_category, round(cast(avg(profit) as numeric), 2) as average_sales from store
group by sub_category
order by average_sales
limit 11

--The profit of these Sub_category products are below the average profit.

/* analysis of Customers*/

/* number of unique customer IDs */
select count(distinct (Customer_id)) as no_unique_cust_ID from store

/* Number of customers in each region in descending order. */
select Region, count(*) as No_of_Customers from store
group by region
order by no_of_customers desc

/* Top 10 customers who order frequently. */
select Customer_Name, count(*) as no_of_orders from store
group by Customer_Name
order by  count(*) desc
limit 10

/* Top 20 Customers who benefitted the store.*/
select Customer_Name, Profit, City, States from store
group by Customer_Name,Profit,City,States
order by  Profit desc
limit 20

/*states where the superstore is most succesful in*/
--Top 10 results:
select round(cast(sum(sales) as numeric),2) AS state_sales, States from store
group by States
order by state_sales desc

--Breakdown by Top vs Worst Sellers:
-- Top 10 Categories (in addition to the best sub-category within the category).:
select Category, Sub_Category , round(cast(sum(sales) as numeric),2) as sales from store
group by Category,Sub_Category
order by sales DESC;

--Top 10 Sub-Categories. :
select round(cast(sum(sales) as numeric),2) as prod_sales,Sub_Category from store
group by Sub_Category
order by prod_sales desc

--Worst 10 Categories.:
select round(cast(sum(sales) as numeric),2) as prod_sales, Category, Sub_Category from store
group by Category, Sub_Category
order by prod_sales;

-- Find Worst 10 Sub-Categories. :
select round(cast(sum(sales) as numeric),2) as prod_sales, sub_Category from store
group by Sub_Category
order by prod_sales;

/* RETURN ANALYSIS */
-- number of returned orders.:
select Returned_items, count(Returned_items)as Returned_Items_Count from store
group by Returned_items
Having Returned_items='Returned'

--Top 10 Returned Categories.:
select Returned_items, count(Returned_items) as no_of_returned ,Category, Sub_Category
from store
group by Returned_items,Category,Sub_Category
Having Returned_items='Returned'
order by count(Returned_items) desc
limit 10;

-- Top 10  Returned Sub-Categories.:
select Returned_items, count(Returned_items) as no_of_returned, Sub_Category
from store
group by Returned_items, Sub_Category
Having Returned_items='Returned'
order by Count(Returned_items) DESC
limit 10;

--Top 10 Customers Returned Frequently.:
select Returned_items, count(Returned_items) as Returned_Items_Count, Customer_Name, Customer_ID,Customer_duration, States,City
from store
group by Returned_items,Customer_Name, Customer_ID,customer_duration,states,city
having Returned_items='Returned'
order by count(Returned_items) desc
limit 10;

-- Top 20 cities and states having higher return.:
select Returned_items, count(Returned_items) as Returned_Items_Count,States,City
from store
group by Returned_items,states,city
having Returned_items='Returned'
order by count(Returned_items) desc
limit 20;


--Checking whether new customers are returning higher or not.:
select Returned_items, count(Returned_items) as Returned_Items_Count,Customer_duration
from store
group by Returned_items,Customer_duration
having Returned_items='Returned'
order by count(Returned_items) desc
limit 20;

--Top  Reasons for returning.:
select Returned_items, count(Returned_items) as Returned_Items_Count,return_reason
from store
group by Returned_items,return_reason
having Returned_items='Returned'
order by count(Returned_items) desc




