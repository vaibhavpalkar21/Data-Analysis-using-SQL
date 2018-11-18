SET GLOBAL sql_mode = 'ONLY_FULL_GROUP_BY';
select @@GLOBAL.sql_mode;

use superstoresdb;
show tables;
describe cust_dimen;
describe market_fact;
describe orders_dimen;
describe prod_dimen;
describe shipping_dimen;

-- Task 1: understanding data in one handler
/* 
Que. A:
This is super stores database all the data is stored in CSV file, the data tells about the superstore where it give idea about the sales of store product, where customers and its product order with all other details are mention, it gives the information about customer name, region, order, category, shipment details, profit and loss etc.
There are multiples files containing information, which are cust_dimen, market_fact, orders_dimen, prod_dimen, shipping dimen. Each file has it own data.
The cust_dimen has information about customers which include name, province, id, region, customer segment.
The market_fact This is biggest file containing the market facts for all the products customers and orders, it have information about order id, product id, shipment id, customer id, sales, discount, order quantity, profit, shipping cost, product base margin.
The order_dimen have order detail information like order id, order date, order priority.
The product_dimen have product detail information like product category, product sub category, product id.
The shipping_dimen have shipping details information about order id, shipping mode, shipping date, shipping id.
Every table has its primary key/s and tables also have foreign key to join.

Que. B:
Primary keys for
1. cust_dimen: cust_id
2. market_fact: No primary key avaialble
3. orders_dimen: order_id
4. prod_dimen: prod_id
5. shipping_dimen: ship_id

Foreign keys for 
cust_dimen
1. customer_dimen.cust_id to market_fact.cust_id

market_fact
1. market_fact.cust_id to customer_dimen.cust_id 
2. market_fact.ord_id to ord_dimen.order_id
3. market_fact.prod_id to prod_dimen.prod_id
4. market_fact.ship_id to shipping_dimen.ship_id

order_dimen
1. order_dimen.ord_id to market_fact.ord_id
2. order_dimen.order_id to shipping_dimen.order_id

prod_dimen
1. prod_dimen.prod_id to market_fact.prod_id

shipping_dimen
1. shipping_dimen.order_id to order_dimen.order_id
shipping_dimen.ship_id to market_fact.ship_id

There is no foreign key between
cust_dimen and order_dimen, cust_dimen and prod_dimen, cust_dimen and shipping_dimen, order_dimen to prod_dimen, prod_dimen to shipping_dimen.

*/

-- Task 2: Basic Analysis
-- Que. A. Find the total and the average sales (display total_sales and avg_sales) 
-- Total average sales
select sum(Sales)
from market_fact;

-- Average sales
select avg(Sales)
from market_fact;

-- Que. B. Display the number of customers in each region in decreasing order of no_of_customers. The result should contain columns Region, no_of_customers
select Region, count(*) as no_of_customer
from cust_dimen
where Region = 'Atlantic' or Region = 'Northwest Territories' or Region = 'Nunavut' or Region = 'Ontario' or Region = 'Prarie' or Region = 'Quebec' or Region = 'West' or Region = 'Yukon'
group by Region
order by no_of_customer desc;

-- Que. C. Find the region having maximum customers (display the region name and max(no_of_customers)
select Region, count(*) as no_of_customer
from cust_dimen
group by Region
order by no_of_customer desc
limit 1;

-- Que. D. Find the number and id of products sold in decreasing order of products sold (display product id, no_of_products sold)
select prod_id, sum(order_quantity) as no_of_products_sold
from market_fact
group by Prod_id, Order_Quantity
order by Order_Quantity desc;

-- Que. E. Find all the customers from Atlantic region who have ever purchased ‘TABLES’ and the number of tables purchased (display the customer name, no_of_tables purchased)

select Customer_Name, sum(Order_Quantity) as no_of_tables_purchased
from cust_dimen inner join market_fact on cust_dimen.Cust_id = market_fact.Cust_id
where Region = 'Atlantic' and Prod_id = 'Prod_11'
group by Customer_Name, Order_Quantity;

-- Task 3: Advance Analysis
-- Que. A. Display the product categories in descending order of profits (display the product category wise profits i.e. product_category, profits)?
select Product_category, sum(Profit) as Total_Profit
from prod_dimen inner join market_fact on prod_dimen.Prod_id = market_fact.Prod_id
group by Product_Category
order by Total_Profit desc;

-- Que. B. Display the product category, product sub-category and the profit within each sub-category in three columns.
select Product_category, Product_Sub_Category, sum(profit)
from prod_dimen inner join market_fact on prod_dimen.Prod_id = market_fact.Prod_id
group by Product_Category, Product_Sub_Category;

-- Que. C. Where is the least profitable product subcategory shipped the most? For the least profitable product sub-category, display the region-wise no_of_shipments and the profit made in each region in decreasing order of profits (i.e. region, no_of_shipments, profit_in_each_region)
-- Note: You can hardcode the name of the least profitable product sub-category

-- A. Where is the least profitable product subcategory shipped the most?
select Product_Sub_Category, sum(Profit), Region
from prod_dimen inner join market_fact on prod_dimen.Prod_id = market_fact.Prod_id inner join cust_dimen on cust_dimen.Cust_id = market_fact.Cust_id
group by Product_Sub_Category, Region
order by sum(Profit) asc
limit 1;

-- B. For the least profitable product sub-category, display the region-wise no_of_shipments and theprofit made in each region in decreasing order of profits 
-- (i.e. region, no_of_shipments, profit_in_each_region)
select Region, count(ship_id) as no_of_shipment, sum(Profit)
from cust_dimen inner join market_fact on cust_dimen.Cust_id = market_fact.Cust_id inner join prod_dimen on prod_dimen.Prod_id = market_fact.Prod_id
where product_Sub_category = 'BOOKCASES'
group by Region
order by sum(Profit) desc;
