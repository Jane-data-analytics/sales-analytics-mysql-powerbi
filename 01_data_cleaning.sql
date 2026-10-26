use kaggle;
select * from sales_data;
create table clean 
like sales_data;

--need raw datas so create new table---

select * from clean;

insert clean 
select * from sales_data;

select * ,row_number() over (partition by
OrderID,order_date, Product, Quantity, UnitPrice,Region, SalesRep) as row_num
from clean;

with cte as
(
select * ,row_number() over (partition by
OrderID,order_date, Product, Quantity, UnitPrice,Region, SalesRep, `status`) as row_num
from clean
)
select *  from cte where row_num>1;

select * from clean where Orderid='ORD-100347';

CREATE TABLE sales_analysis (
  `OrderID` text,
  `Order_Date` text,
  `Product` text,
  `Quantity` double DEFAULT NULL,
  `UnitPrice` text,
  `Region` text,
  `SalesRep` text,
  `Status` text,
  `row_num` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

select * from sales_analysis;

insert into sales_analysis 
select * ,row_number() over (partition by
OrderID,order_date, Product, Quantity, UnitPrice,Region, SalesRep, `status`) as row_num
from clean;


delete from sales_analysis where row_num>1;

select * from sales_analysis where Orderid='ORD-100347';

--order_date data type--

select order_date from sales_analysis limit 20;

---differnet date format ----

select order_date from sales_analysis where order_date is null or trim(order_date) = '';
alter table sales_analysis add column order_date date;

update sales_analysis set order_date=
    case
        when trim(order_date) regexp '^[0-9]{2}-[0-9]{2}-[0-9]{4}$'
            then str_to_date(trim(order_date), '%d-%m-%Y')

        when trim(order_date) regexp '^[0-9]{2}/[0-9]{2}/[0-9]{4}$'
            then str_to_date(trim(order_date), '%m/%d/%Y')

        when trim(order_date) regexp '^[0-9]{4}/[0-9]{2}/[0-9]{2}$'
            then str_to_date(trim(order_date), '%Y/%m/%d')

        when trim(order_date) regexp '^[0-9]{4}-[0-9]{2}-[0-9]{2}$'
            then str_to_date(trim(order_date), '%Y-%m-%d')

        when trim(order_date) regexp '^[A-Za-z]{3} [0-9]{1,2}, [0-9]{4}$'
            then str_to_date(trim(order_date), '%b %d, %Y')
        else null
    end;
alter table sales_analysis drop order_date;
alter table sales_analysis modify order_date date after orderid;
alter table sales_analysis modify  total_sales int after unitprice;

---standardize the data using window function---

select region,trim( lower(region)) from sales_analysis;
update sales_analysis set region= trim(lower(region));
select salesrep,trim( lower(salesrep)) from sales_analysis;
update sales_analysis set salesrep=trim( lower(salesrep));
update sales_analysis set region="null" where region='';

select `status` ,trim(lower(`status`)) from sales_analysis;
update sales_analysis set `status`=trim(lower(`status`));
update sales_analysis set product =trim(lower(product));
update sales_analysis set `status`="null" where `status`='';
update sales_analysis set salesrep = "null" where salesrep='';
update sales_analysis set product="null" where product='';
update sales_analysis set unitprice =0 where unitprice='N/A';

select replace(unitprice, '$', '') as unitprice from sales_analysis;
update sales_analysis set unitprice=replace(unitprice, '$', '') 
where unitprice like '%$%';

select * from sales_analysis;