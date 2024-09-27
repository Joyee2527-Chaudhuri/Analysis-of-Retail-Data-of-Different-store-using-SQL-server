---DATA PREPARATION AND UNDERSTANDING
---1.	What is the total number of rows in each of the 3 tables in the database?
select count (*) as customer_count,
(select count (*) from dbo.prod_cat_info) as prod_cat_info_count,
(select count(*) from dbo.Transactions) as dbo_transaction_count
from dbo.Customer

----2. What is the total number of transactions that have a return?
select * from dbo.Customer
select * from dbo.prod_cat_info
select * from dbo.Transactions
select count(*) as Return_trans from dbo.Transactions where Qty<0

---3.	As you would have noticed, the dates provided across the datasets are not in a correct format. As first steps, 
---pls convert the date variables into valid date formats before proceeding ahead

select * from dbo.Transactions
select FORMAT(tran_date,'dd-MM-yyyy') as formatted_date 
from dbo.Transactions

---4.	What is the time range of the transaction data available for analysis? Show the output in number of days, 
---months and years simultaneously in different columns.
select * from dbo.Transactions
select min(tran_date) as min_date,
 max(tran_date) as max_date,
DATEDIFF(DAY,min(tran_date), max(tran_date)) as total_days,
 datediff(month,min(tran_date),max(tran_date)) as total_months,
 datediff(year,min(tran_date),max(tran_date)) as total_year
 from dbo.transactions

 ----5.	Which product category does the sub-category “DIY” belong to?
 select * from dbo.prod_cat_info
 where prod_subcat='DIY'

 ---DATA ANALYSIS
---1.	Which channel is most frequently used for transactions?
select * from dbo.Transactions
select top 1 store_type , count(*) as trans_count
from dbo.Transactions
group by Store_type
order by trans_count desc

---2.	What is the count of Male and Female customers in the database?
select * from dbo.customer
select gender, count(*) as gender_count
from dbo.customer
group by gender
order by gender_count desc

---3.	From which city do we have the maximum number of customers and how many?
select * from dbo.Customer
select top 1 city_code, count(*) as max_no_city
from dbo.Customer
group by city_code
order by max_no_city desc

---4.	How many sub-categories are there under the Books category?
select * from dbo.prod_cat_info
select  prod_cat, count(prod_cat) as sub_cat_count
from dbo.prod_cat_info
where prod_cat='books'
group by prod_cat

---5.	What is the maximum quantity of products ever ordered?
select max(qty) as max_qty
from dbo.Transactions

---6.	What is the net total revenue generated in categories Electronics and Books?   
select * from dbo.prod_cat_info
select * from dbo.Transactions
select prod_cat, sum(total_amt) as net_total_revenue
from dbo.Transactions as t
join dbo.prod_cat_info as p
on p.prod_cat_code= t.prod_cat_code
and
t.prod_subcat_code=p.prod_sub_cat_code
where prod_cat in ('Electronics', 'Books')
group by prod_cat

---7.	How many customers have >10 transactions with us, excluding returns?
select *from dbo.Transactions 
select count(*) as cust_count from( select cust_id, count(*) as trans_count
from dbo.Transactions
where qty>0
group by cust_id
having count(transaction_id)>10) as X

----8.	What is the combined revenue earned from the “Electronics” & “Clothing” categories, from “Flagship stores”?
select * from dbo.prod_cat_info
select * from dbo.Transactions
select 'Electronics & Clothing' as Category, SUM(total_revenue) as Combined_revenue from 
(select prod_cat, SUM(total_amt) as total_revenue
from dbo.Transactions as t
left join dbo.prod_cat_info as p
on t.prod_cat_code= p.prod_cat_code
and
t.prod_subcat_code=p.prod_sub_cat_code
where prod_cat in ('Electronics', 'Books')
and store_type='flagship store' 
group by prod_cat ) as X

---9.	What is the total revenue generated from “Male” customers in “Electronics” category? Output should display total revenue by prod sub-cat.
select * from dbo.Transactions
select * from dbo.prod_cat_info
select * from dbo.Customer
select prod_subcat , sum(total_amt) as total_revenue
from dbo.Transactions as t 
left join dbo.Customer as c
on t.cust_id= c.customer_Id
join dbo.prod_cat_info as p
on t.prod_cat_code= p.prod_cat_code
and 
t.prod_subcat_code=p.prod_sub_cat_code
where Gender='M'
and prod_cat='electronics'
group by prod_subcat

----10.	What is percentage of sales and returns by product sub category; display only top 5 sub categories in terms of sales?

select * from dbo.prod_cat_info
select * from dbo.Transactions

select top 5 x.prod_subcat,sales_pct, return_pct from 
(select prod_subcat,round((SUM(total_amt)/(select sum(total_amt) from Transactions where total_amt>0)*100),2) as sales_pct
from dbo.Transactions as t
left join dbo.prod_cat_info as p
on t.prod_cat_code=p.prod_cat_code
and 
t.prod_subcat_code=p.prod_sub_cat_code
where total_amt>0
group by prod_subcat) as x
join
(select prod_subcat,round((SUM(total_amt)/(select SUM(total_amt) from Transactions where total_amt<0)*100),2) as return_pct
from Transactions as t
left join prod_cat_info as p
on t.prod_cat_code=p.prod_cat_code
and 
t.prod_subcat_code=p.prod_sub_cat_code
where total_amt<0
group by prod_subcat) as y
on x.prod_subcat=y.prod_subcat
order by sales_pct desc

----11.	For all customers aged between 25 to 35 years find what is the net total revenue generated by these consumers 
-----in last 30 days of transactions from max transaction date available in the data?
select * from dbo.Customer
select * from dbo.Transactions
select customer_id, sum(total_amt) as total_revenue
from(select * from dbo.Customer as C 
left join dbo.Transactions as t
on C.customer_Id=t.cust_id
where year(getdate())-year(dob) between 25 and 35) as x
where tran_date between DATEADD(day,-30,(select max(tran_date) from Transactions)) and (select MAX(tran_date) from Transactions)
group by customer_Id

----12.	Which product category has seen the max value of returns in the last 3 months of transactions?
select * from dbo.Transactions
select * from dbo.prod_cat_info
select top 1 t.prod_cat_code,p.prod_cat, count(total_amt) as no_of_return
from dbo.Transactions as t
join dbo.prod_cat_info as p
on t.prod_cat_code=p.prod_cat_code
and t.prod_subcat_code=p.prod_sub_cat_code
where total_amt<0
and
tran_date between DATEADD(MONTH,-3,(select max(tran_date) from dbo.Transactions)) and (select max(tran_date) from dbo.Transactions)
group by t.prod_cat_code, p.prod_cat
order by no_of_return desc

----13.	Which store-type sells the maximum products; by value of sales amount and by quantity sold?
select top 1 store_type, round(sum(total_amt),2) as total_sales , sum(qty) as quantity_sold
from dbo.Transactions
group by store_type
order by total_sales desc, quantity_sold desc

---14.	What are the categories for which average revenue is above the overall average.
select * from dbo.prod_cat_info
select * from dbo.Transactions

select p.prod_cat, t.prod_cat_code, avg(total_amt) as avg_revenue
from dbo.Transactions as t
left join dbo.prod_cat_info as p
on t.prod_cat_code=p.prod_cat_code
and
t.prod_subcat_code= p.prod_sub_cat_code
group by t.prod_cat_code,p.prod_cat
having avg(total_amt) > (select avg(total_amt) from dbo.Transactions)

----15.	Find the average and total revenue by each subcategory for the categories which are among top 5 categories in terms of quantity sold.
select * from dbo.prod_cat_info
select * from dbo.Transactions
	select  prod_cat_code ,prod_subcat_code, round(avg(total_amt),2) as avg_revenue, round(SUM(total_amt),2) as total_revenue
from dbo.Transactions
	where prod_cat_code in (select top 5 prod_cat_code
	from dbo.Transactions
	group by prod_cat_code
	order by sum(qty) desc)
group by prod_cat_code,prod_subcat_code
order by prod_cat_code asc
