-- ============================================================
-- Pizza Sales Analysis — SQL Queries (MS SQL Server)
-- Dataset: pizza_sales (2015)
-- ============================================================

-- ------------------------------------------------------------
-- DATA PREP: Normalize mixed order_date formats
-- ------------------------------------------------------------
alter table pizza_sales
add cleaned_date date;

update pizza_sales
set cleaned_date =
    coalesce(
        try_convert(date, order_date, 23),   -- yyyy-mm-dd
        try_convert(date, order_date, 105)   -- dd-mm-yyyy
    );

select order_date, cleaned_date
from pizza_sales;

alter table pizza_sales
drop column order_date;

select *
from pizza_sales;


-- ============================================================
-- PROBLEM STATEMENTS — KPIs
-- ============================================================

-- A1. Total Revenue
--    What is the total revenue generated from all pizza orders?
select sum(total_price) as total_revenue
from pizza_sales;

-- A2. Average Order Value (AOV)
--    What is the average amount spent per order?
select sum(total_price) / count(distinct order_id) as avg_order_value
from pizza_sales;

-- A3. Total Pizzas Sold
--    How many pizzas were sold in total?
select sum(quantity) as total_pizza_sold
from pizza_sales;

-- A4. Total Orders
--    How many distinct orders were placed?
select count(distinct order_id) as total_orders
from pizza_sales;

-- A5. Average Pizzas Per Order
--    On average, how many pizzas are included in each order?
select
    cast(sum(quantity) as decimal(10, 2))
    / cast(count(distinct order_id) as decimal(10, 2)) as avg_pizzas_per_order
from pizza_sales;


-- ============================================================
-- PROBLEM STATEMENTS — HOME PAGE CHARTS
-- ============================================================

-- B1. Daily Trend for Total Orders
--    How do total orders vary by day of the week?
select
    datename(dw, cleaned_date) as order_day,
    count(distinct order_id) as total_orders
from pizza_sales
group by datename(dw, cleaned_date);

-- B2. Monthly Trend for Total Orders
--    How do total orders vary by month?
select
    datename(month, cleaned_date) as month_name,
    count(distinct order_id) as total_orders
from pizza_sales
group by datename(month, cleaned_date)
order by total_orders desc;

-- B3. % of Sales by Pizza Category
--    What share of total revenue does each pizza category contribute?
select
    pizza_category,
    cast(sum(total_price) as decimal(10, 2)) as total_revenue,
    cast(
        sum(total_price) * 100.0
        / (select sum(total_price) from pizza_sales)
        as decimal(10, 2)
    ) as pct
from pizza_sales
group by pizza_category
order by pct desc;

-- B4. % of Sales by Pizza Size
--    What share of total revenue does each pizza size contribute?
select
    pizza_size,
    cast(sum(total_price) as decimal(10, 2)) as total_revenue,
    cast(
        sum(total_price) * 100.0
        / (select sum(total_price) from pizza_sales)
        as decimal(10, 2)
    ) as pct
from pizza_sales
group by pizza_size
order by pizza_size;

-- B5. Total Pizzas Sold by Pizza Category
--    How many pizzas were sold in each category?
select
    pizza_category,
    sum(quantity) as total_quantity_sold
from pizza_sales
group by pizza_category
order by total_quantity_sold desc;

-- B5b. Total Pizzas Sold by Category (filtered example — February)
--    Same as B5, restricted to one month (uses cleaned_date after rename).
select
    pizza_category,
    sum(quantity) as total_quantity_sold
from pizza_sales
where month(cleaned_date) = 2
group by pizza_category
order by total_quantity_sold desc;


-- ============================================================
-- PROBLEM STATEMENTS — BEST / WORST SELLERS
-- ============================================================

-- C1. Top 5 Pizzas by Revenue
select top 5
    pizza_name,
    sum(total_price) as total_revenue
from pizza_sales
group by pizza_name
order by total_revenue desc;

-- C2. Bottom 5 Pizzas by Revenue
select top 5
    pizza_name,
    sum(total_price) as total_revenue
from pizza_sales
group by pizza_name
order by total_revenue asc;

-- C3. Top 5 Pizzas by Quantity
select top 5
    pizza_name,
    sum(quantity) as total_pizza_sold
from pizza_sales
group by pizza_name
order by total_pizza_sold desc;

-- C4. Bottom 5 Pizzas by Quantity
select top 5
    pizza_name,
    sum(quantity) as total_pizza_sold
from pizza_sales
group by pizza_name
order by total_pizza_sold asc;

-- C5. Top 5 Pizzas by Total Orders
select top 5
    pizza_name,
    count(distinct order_id) as total_orders
from pizza_sales
group by pizza_name
order by total_orders desc;

-- C6. Bottom 5 Pizzas by Total Orders
select top 5
    pizza_name,
    count(distinct order_id) as total_orders
from pizza_sales
group by pizza_name
order by total_orders asc;
