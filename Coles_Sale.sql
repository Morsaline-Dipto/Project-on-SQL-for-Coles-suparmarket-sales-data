select * from data_1;


select (gross_sale_million - Sales_cost_million) as total_rev from data_1;

--Calculation of total revenue and creating another column as Total revenue in data_1

Alter table data_1
add column Total_revenue_millions int;
Update data_1
set Total_revenue_millions = (gross_sale_million - Sales_cost_million)
where Total_revenue_millions is null; 


--drop table data_2;

Create table data_2 (
List_no INT,
Coles_StoreID VARCHAR (15),
Store_Location VARCHAR (5),
Customer_Count INT,
Staff_Count INT,
Store_Area_in_square_meters INT );

Alter table data_2
Add column customer_staff_ratio float;

update data_2
set customer_staff_ratio= (customer_count/staff_count)
where customer_staff_ratio is null;

Alter table data_2
Rename column customer_stuff_ratio to customer_staff_ratio;

select * from data_2;



--5 most revenue earning stores in each state in each quarter


with cte as
(select d1.coles_storeidno, d1.expected_revenue_million,
       d1.total_revenue_millions,d1.targeted_quarter, d2.store_location
from data_1 d1
join data_2 d2
on d1.coles_storeidno = d2.Coles_StoreID) 

select * from (
select *,
row_number() over (partition by store_location,targeted_quarter 
				   order by total_revenue_millions desc) 
as Highest_rev_Rank
from cte) x
where x.Highest_rev_Rank < 6;

--sum of total revenue, cost, sale and expected revenue by each state in each quarter

with cte as
(select d1.coles_storeidno, d1.expected_revenue_million,
       d1.gross_sale_million, d1.sales_cost_million,d1.targeted_quarter,
       d1.total_revenue_millions,d2.store_location
from data_1 d1
join data_2 d2
on d1.coles_storeidno = d2.Coles_StoreID)

select
store_location,targeted_quarter,
sum(sales_cost_million) as Total_cost,
sum(gross_sale_million) as Total_sell,
sum(expected_revenue_million) as Total_expected_rev,
sum(total_revenue_millions) as Total_rev
from cte 
group by store_location,targeted_quarter
order by targeted_quarter;


--Find average customer_staff ratio in each state then find top most ratio and their store
--information from each state.

select 
store_location,
cast(avg(customer_staff_ratio) as int) as avarage_customer_staff_ratio
from data_2
Group by 1
order by 2 desc;

select * from data_2;

select * from
(select *, 
row_number() over (partition by store_location order by customer_staff_ratio desc  ) as rn
from data_2) y
where y.rn=1;

--maximum and average store area in each state

select 
store_location,
cast(avg(store_area_in_square_meters) as int) as average_store_area_in_sq_meters
from data_2
Group by 1
order by 2 desc;

select * from data_2;

select * from
(select *, 
row_number() over (partition by store_location order by store_area_in_square_meters desc ) as rn
from data_2) y
where y.rn=1;

select * from data_1;

--finding overall sale dashboard and then by each quarter and each state.

With cte as
(select d1.targeted_quarter,d1.coles_storeidno,d2.store_location,
        d1.expected_revenue_million, d1.total_revenue_millions,d1.coles_forecast 
from data_1 d1
join data_2 d2
on d1.coles_storeidno = d2.Coles_StoreID),


 cte2 as 
(select count(*) as Number_of_Stores_On_target 
from cte
where coles_forecast='On Target' and targeted_quarter='Q2 2023'),
 
 cte3 as 
(select  
count(*) as Number_of_Stores_Below_target
from cte
where coles_forecast='Below Target' and targeted_quarter='Q2 2023')

select * from 
cte2 cross join cte3;

---each quarter and each state.

With cte as
(select d1.targeted_quarter,d1.coles_storeidno,d2.store_location,
        d1.expected_revenue_million, d1.total_revenue_millions,d1.coles_forecast 
from data_1 d1
join data_2 d2
on d1.coles_storeidno = d2.Coles_StoreID)

select store_location,
count(*) as number_of_store
from cte
where coles_forecast='On Target'and targeted_quarter='Q2 2023'
group by 1
order by 1 desc;


