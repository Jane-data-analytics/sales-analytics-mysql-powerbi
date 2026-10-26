-----queries-----

1.total sales----
select quantity, unitprice, quantity*unitprice as Total_sales from sales_analysis;
alter table sales_analysis add total_sales int;
update sales_analysis set total_sales= quantity*unitprice ;

---How many sales records are there?---
select count(orderid) from sales_analysis;

2.What is the total quantity sold?----
select sum(quantity) from sales_analysis;

3.----sales revenew----
select sum(total_sales) from sales_analysis;

4. maximum,minimum and average sales----
What is the average unit price?
select avg(unitprice) from sales_analysis;
select max(total_sales), min(total_sales), Avg(total_sales) from sales_analysis;

------What is the highest and lowest unit price?---
select max(unitprice) from sales_analysis;
select min(unitprice) from sales_analysis; 


5.What are the top 10 highest-value sales records?
select total_sales from sales_analysis order by total_sales desc limit 10;

6.What are the total sales for each product?

select sum(total_sales),product from sales_analysis group by product order by sum(total_sales) desc;

7.Which products have an average price above 100?

select avg(total_sales),product from sales_analysis 
group by product having avg(total_sales)>=100;


8.What are the top 5 products by revenue?
select rank() over(order by max(total_sales)) as 'Rank',
product ,sum(total_sales) from sales_analysis 
group by product limit 5;

9.What percentage of total sales comes from each product?

select product, sum(total_sales) as product_sales,
    round(
        sum(total_sales) / sum(sum(total_sales)) over () * 100,1
		 ) as percentage_of_total_sales from sales_analysis
    group by product order by percentage_of_total_sales desc;

10.What is the cumulative sales revenue over time?

select order_date, total_sales,
sum(total_sales) over (order by order_date) as cumulative_sales from sales_analysis order by order_date;

11.What is the monthly sales growth percentage?

with monthly_sales as (
    select
        DATE_FORMAT(order_date, '%Y-%m') as sales_month,
        SUM(total_sales) as revenue
    from sales_analysis
    group by DATE_FORMAT(order_date, '%Y-%m')
),
previous_month as (
    select
        sales_month,
        revenue,
        lag(revenue) over (
            order by  sales_month
        ) as previous_revenue
    from monthly_sales
)
select
    sales_month,
    revenue,
    previous_revenue,
    round(
        (revenue - previous_revenue) * 100.0
        / NULLIF(previous_revenue, 0),
        2
    ) as growth_percentage
from previous_month
order by sales_month;

select * from sales_analysis;