create database citibank;

use citibank;
show tables;


DESCRIBE customers;

SELECT *
FROM customers
LIMIT 10;


SELECT date_of_birth
FROM customers
WHERE date_of_birth IS NOT NULL
LIMIT 10;


SELECT
    COUNT(*) AS total_customers,
    COUNT(date_of_birth) AS non_null_dob,
    COUNT(DISTINCT date_of_birth) AS unique_dob_values
FROM customers;	


SELECT
    COUNT(*) AS total_customers,
    SUM(CASE
        WHEN date_of_birth IS NULL THEN 1
        ELSE 0
    END) AS null_dob,
    SUM(CASE
        WHEN TRIM(date_of_birth) = '' THEN 1
        ELSE 0
    END) AS blank_dob,
    SUM(CASE
        WHEN TRIM(date_of_birth) <> '' THEN 1
        ELSE 0
    END) AS non_blank_dob
FROM customers;


SELECT DISTINCT TRIM(date_of_birth) AS dob_value
FROM customers
WHERE date_of_birth IS NOT NULL
  AND TRIM(date_of_birth) <> ''
LIMIT 15;






ALTER TABLE customers
ADD COLUMN new_dob DATE;


UPDATE customers
SET new_dob = STR_TO_DATE(
    TRIM(date_of_birth),
    '%d-%m-%Y'
)
WHERE TRIM(date_of_birth) <> '';


SELECT
    date_of_birth,
    new_dob
FROM customers
LIMIT 15;



SELECT
    COUNT(*) AS total_customers,
    COUNT(new_dob) AS converted_dob,
    SUM(new_dob IS NULL) AS missing_or_unconverted_dob
FROM customers;
describe customers;

/* Identify the date range covered in the Citibank customer and transaction data by finding:
The earliest and latest customer account creation dates
The earliest and latest recorded transaction dates */

SELECT
    MIN(STR_TO_DATE(created_at, '%d-%m-%Y %H:%i:%s')) AS earliest_date,
    MAX(STR_TO_DATE(created_at, '%d-%m-%Y %H:%i:%s')) AS latest_date
FROM customers;

	SELECT
		MIN(STR_TO_DATE(transaction_date, '%d-%m-%Y %H:%i:%s'))
			AS earliest_transaction,
		MAX(STR_TO_DATE(transaction_date, '%d-%m-%Y %H:%i:%s'))
			AS latest_transaction
	FROM transactions;
    
    SELECT
    MIN(STR_TO_DATE(c.created_at, '%d-%m-%Y %H:%i:%s'))
        AS earliest_account_creation,
    MAX(STR_TO_DATE(c.created_at, '%d-%m-%Y %H:%i:%s'))
        AS latest_account_creation,
    MIN(STR_TO_DATE(t.transaction_date, '%d-%m-%Y %H:%i:%s'))
        AS earliest_transaction,
    MAX(STR_TO_DATE(t.transaction_date, '%d-%m-%Y %H:%i:%s'))
        AS latest_transaction
FROM customers c
JOIN accounts a
    ON c.customer_id = a.customer_id
JOIN transactions t
    ON a.account_id = t.account_id;

/*list the name of each branch,the type of account,and the status of the account along with the total number of account for each 
combination and show the results sorted by branch name and then by the number of accounts from highest to lowest 
*/
select b.branch_name,a.account_type, a.status,count(a.account_id) as total_account
from accounts as a inner join branches as b on a.branch_id=b.branch_id
group by b.branch_name,a.account_type,a.status
order by b.branch_name asc,total_account desc;

/*2.Customer Behaviour Analysis*/
/*Objective:understand customer enagagement and transaction pattern to improve retention and product pffering
*/

/*2A.Are high-balance accounts associated with higher transaction frequency?
Find the average number of transaction for each customer balance category(high balance >50,
medium balance 10k-50k,low balance <=10k)along with the number of customers and average balance in each catagory
sorted by average transaction count from highest to lowest */

with acc_txn as (
select
 a.account_id,a.customer_id,a.balance,
case
   when a.balance >50000 then "high balance (>50k)"
   when a.balance between 10000 and 50000 then "medium Balance(10k-50k)"
   else "low Balance (<=10K)"
   end as balance_category, 
   count(t.transaction_id)as txn_count
from accounts a left join transactions t on a.account_id=t.account_id
group by a.account_id,a.customer_id,a.balance
)

select balance_category,
       count(distinct customer_id) as num_customer,
       round(avg(txn_count),2) as avg_transaction_count,
       round(avg(balance),2)as avg_balance
from acc_txn
group by balance_category
order by avg_transaction_count desc;

/*2.b Find the top 2 months with the highest transaction counts for each account type in 2025,showing 
the account type,month name,transaction count, and total transaction amount,sorted by account type and rank
*/
with monthly as (
select 
     a.account_type,
     month(STR_TO_DATE(t.transaction_date, '%d-%m-%Y %H:%i:%s') )as month_num,
     monthname(STR_TO_DATE(t.transaction_date, '%d-%m-%Y %H:%i:%s')) as month_name,
     count(t.transaction_id) as transaction_count,
     sum(t.amount) as transaction_amount
from transactions t inner join accounts a on t.account_id = a.account_id
where year(STR_TO_DATE(t.transaction_date, '%d-%m-%Y %H:%i:%s'))= 2025
Group by a.account_type,month_num,month_name),
ranked as (
select *, rank() over (partition by account_type order by transaction_count desc) as Rnk
from monthly
)	
select account_type,month_name,transaction_count,transaction_count,transaction_amount,rnk as rank_num
from ranked
where rnk<=2
order by account_type,rnk;

/*count the total number of credit card of each age group(under 30,30-50,over 50)as of june1,2025,and
list them in order from highest to lowest transaction count
*/

select case
            when datediff('2025-06-01',c.new_dob)/365.25<30
                then 'under_30'
			when datediff('2025-06-01',c.new_dob)/365.25 
                   between 30 and 50 
                then '30-50' else 'over50'
			end as age_group,
	count(t.transaction_id) as credit_card_transaction_count
from transactions t inner join  accounts a on t.account_id = a.account_id
					inner join cards cd on cd.account_id= a.account_id
                    inner join customers c on c.customer_id = a.customer_id
where c.new_dob is not null
group by age_group
order by credit_card_transaction_count;

/*List the top 10 customers with the highest total balance across their active accounts
showing their name,email,total balance, number of account and earliest account opening date 
sort by the total balance highest to lowest 
*/
select
	c.customer_id,
    concat(c.first_name,' ' ,c.last_name) as customer_name,
    c.email,
round(sum(a.balance),2)as total_balance,
    count(a.account_id) as num_accounts,
    min(a.opened_date) as earliest_account_opening
from accounts a  
                inner join 
                          customers c 
                          on a.customer_id=c.customer_id
where a.status = "active"
group by c.customer_id,c.first_name,c.last_name,c.email
order by total_balance desc
limit 10;

/*list the customer with more than one active loans,
showing their customer id,name,number of active loans,
total_loan_amount sorted by total_loan_amount to highest to lowest
*/
select c.customer_id,
    concat(c.first_name,' ' ,c.last_name) as customer_name,
    count(l.loan_id) as no_of_active_loans,
    sum(l.loan_amount) as total_loans_amount
from loans l inner join customers c on l.customer_id=c.customer_id
where l.status="active"
group by c.customer_id, c.first_name, c.last_name
having count(l.loan_id)>1
order by total_loans_amount desc;

/*Branch performance Analysis
*/
/*3a.list the top two branches with the highest number of accounts 
opened each year,showing branch name , no of accounts,year and sorted by years and 
then no of accounts from highest ot lowest.
*/
with yearly as (
select 
      b.branch_name,
      YEAR(STR_TO_DATE(a.opened_date, '%d-%m-%Y %H:%i:%s'))as yr,
      count(a.account_id) as num_accounts
from accounts a inner join branches b on b.branch_id=a.branch_id
where a.opened_date is not null
group by b.branch_name,yr),
ranked as (
select *,rank() over (partition by yr order by num_accounts desc) as rnk
from yearly
)
select branch_name,yr as year,num_accounts
from ranked
where rnk <=2
order by year,num_accounts desc;

/*3.b. show the name of ech branch along with the number of employees,
number of accounts,total transaction amount and a performance rank based on
total transaction sorted by performance rank from highest to lowest
*/
with branch_stats as (select 
       b.branch_id,
       b.branch_name,
       (select count(*)
          from employees e 
          where e.branch_id=b.branch_id) as num_emp,
          (select count(*)
             from accounts a 
             where a.branch_id = b.branch_id) as num_acc,
             coalesce((select sum(t.amount)
                       from transactions t inner join accounts a on
                             t.account_id=a.account_id
						where a.branch_id=b.branch_id),0) as total_transaction_amount
				from branches b)
select 
      branch_name,num_emp,num_acc,total_transaction_amount,
      rank() over (order by total_transaction_amount desc)as performance_rank 
from branch_stats
order by performance_rank;
       
/*list each branch's name,year,totaltransaction amount ,cumulative transaction
amount over the year and theaverage transaction amount per year across all 
 branches,sorted by branch name and year 
*/
with branch_yearly as (
select 
      b.branch_name,
      year(str_to_date(transaction_date, '%d-%m-%Y %H:%i:%s')) as yr,
      sum(t.amount)as total_transaction_amount
from transactions t inner join accounts a on t.account_id=a.account_id
				 inner join branches b on a.branch_id=b.branch_id
group by  b.branch_name,yr)
select
      branch_name,
      yr as year,
      total_transaction_amount,
      sum(total_transaction_amount) over
                                (partition by branch_name order by yr)
                                     as cumulative_transaction_amount,
      round( avg(total_transaction_amount) over 
                                   (partition by branch_name order by yr),2)  
                                   as avg_transaction_per_year
 from branch_yearly 
order by branch_name, yr;

/*3.d List each branch's ID and name along with the total loan amount issued 
number of active loan,average interest rate ,and percentage of loan paid 
sorted by total loan amount from highest to lowest
*/
select 
      b.branch_id,
      b.branch_name,
      sum(l.loan_amount)as total_loan_amount_issued,
      sum(case when l.status ="active" then 1 else 0 end) as num_active_loans,
      round(avg(l.interest_rate),2)as avg_interest_rate,
      round(100*sum(case when l.status="paid"then 1 else 0 end)/count(*),2) 
                                                        as pct_loan_paid
from loans l inner join branches b on l.branch_id=b.branch_id
group by b.branch_id,b.branch_name
order by total_loan_amount_issued desc;

/*Financial Risk and Revenue Analysis 
*/
/*list the top three branches with highest loan default rate for each loan type,
show loantype,branch name ,total loan issued,number of defaults , and default 
rate perentage ,sorted by loan type and default rate from highest to lowest
*/
with loan_stats as (
select
      l.loan_type,
      b.branch_name,
      count(l.loan_id) as total_loans_issued,
      sum(case when l.status ="DEFAULTED" then 1 else 0 end)as num_defaults,
      round(100*sum(case when l.status ="DEFAULTED" then 1 else 0 end)/count(*),2)as
      default_rate_pct	
from loans l inner join branches b on l.branch_id=b.branch_id
group by l.loan_type,b.branch_name),
ranked as (
select *,rank() over (partition by loan_type order by default_rate_pct)as rnk
from loan_stats
)
select loan_type,branch_name,total_loans_issued,num_defaults,default_rate_pct
from ranked
where rnk <=3
order by loan_type,default_rate_pct desc;

/*List each branch's name, the total interest revenue from active loans,and the 
percentage contribution to the total interest revenue across all branches,sorted  
by interest revenue from highest to lowest
*/
with branch_interest as (
select b.branch_name,
      sum(l.loan_amount*l.interest_rate/100)as interest_revenue
from loans l inner join branches b on b.branch_id=l.branch_id 
where l.status = "Active"
group by b.branch_name
)
select branch_name,
        round(interest_revenue,2) as total_interest_revenue,
        round(100*interest_revenue/sum(interest_revenue)over (),2) as pct_contribution_to_total_revenue
from branch_interest
order by total_interest_revenue desc;

/*list the year, total transaction amount previuos year amount and the percentage increase in the transaction amount from january to august each year 
sorted by year excluding the first year increase 
*/

with  yearly as (
select 
      year(STR_TO_DATE(transaction_date, '%d-%m-%Y %H:%i:%s')) as yr,
      sum(t.amount)as total_amount
from transactions t 
where month(STR_TO_DATE(transaction_date, '%d-%m-%Y %H:%i:%s')) between 1 and 8
group by yr
),
with_prev as(
select 
       yr,total_amount,
       lag(total_amount) over (order by yr) as prev_year_amount
from yearly
)
select
      yr as year,
      total_amount as total_transaction_amount,
      prev_year_amount as previous_year_total_amount ,
      round(100*(total_amount-prev_year_amount)/prev_year_amount,2)as pct_increase
from with_prev
where prev_year_amount is not null
order by yr;

/*Customer Service and Interaction Analysis*/
/*Objective:optimize customer service processes and improve satisfaction
*/

/*List each branch name,total number of interaction,number of complaints,complaint_rate_percentage
number of employee and their position 
sorted by the complaint_rate_percentage from highest to lowest
*/

with branch_interaction as(
select
      b.branch_id,
      b.branch_name,
      count(ci.interaction_id) as total_interaction,
      sum(case when ci.interaction_type = "COMPLAINT" then 1 else 0 end) as num_complaint
from branches b left join employees e on e.branch_id=b.branch_id
     left join customer_interactions ci on ci.employee_id=e.employee_id
group by b.branch_id,b.branch_name
),
branch_employee as (
select 
      branch_id,
      count(*)as num_employee,
      group_concat(distinct position) as positions
from employees
group by branch_id
)
select
      bi.branch_name,
      bi.total_interaction,
      bi.num_complaint,
      round(100*bi.num_complaint/nullif(bi.total_interaction,0),2) as complaint_rate_pct,
      be.num_employee,
      be.positions
from branch_interaction bi join branch_employee be on be.branch_id=be.branch_id
order by complaint_rate_pct desc;

/*list customer who made at least one complaints in three or more months,
showing their ID,name,number of complaint months,total complaints and the month
they complained,sorted by number of months and total complaint from highesh to lowest
*/
with complaints as (
select 
      customer_id,
      date_format(str_to_date(interaction_date,'%d-%m-%Y %H:%i:%s'),'%Y-%m') as complaint_month
from customer_interactions
where interaction_type="COMPLAINT" 
),
agg as (
select
      customer_id,
      count(distinct complaint_month) as num_complaint_months,
      count(*) as total_complaints,
      group_concat(distinct complaint_month) as months
from complaints
group by customer_id
having count(distinct complaint_month) >=3
)
select
      a.customer_id,
      concat(c.first_name,' ',c.last_name)as customer_name,
      a.num_complaint_months,
      a.total_complaints,
      a.months
from agg a join customers c on
                              a.customer_id=c.customer_id
order by num_complaint_months desc, a.total_complaints desc;                              
                             
/*Card Portfolio Optimisation Analysis
*/
/*objective:optimize card offerings and usage to enhance customer value and financial performance
*/
 
 /*list the customer with an active credit card where the account balance is 90%
 or more of the credit limit,showing their id,name,cardnumber,creditlimit,balance,and percentage of credit used
*/
select c.customer_id,
       concat(c.first_name,' ',c.last_name) as customer_name,
       cd.card_number,
       cd.credit_limit,
       a.balance,
       round(100 * a.balance/cd.credit_limit,2) as pct_credit_used
from cards cd inner join accounts a on 
                                       a.account_id=cd.account_id
               inner join customers c on
										c.customer_id=a.customer_id			
where cd.card_status ='ACTIVE'
     and cd.card_type ="CREDIT"
     and cd.credit_limit is not null
     and a.balance/cd.credit_limit>=0.90
order by pct_credit_used desc;

/*list each card type and month in 2025,showing the total amount spend,
number of unique cardholders,and average transaction size for activecards,
sorted by cardtype and month
*/
select 
      cd.card_type,
      month(str_to_date(transaction_date, '%d-%m-%Y %H:%i:%s')) as month_num,
      round(sum(t.amount),2) as total_amount_spend,
      count(distinct a.customer_id) as unique_cardholders,
      round(avg(t.amount),2) as avg_transaction_size
from transactions t inner join accounts a on t.account_id=a.account_id
                   inner join cards cd on cd.account_id=a.account_id
where cd.card_status = 'ACTIVE'
      and year(STR_TO_DATE(transaction_date, '%d-%m-%Y %H:%i:%s')) = 2025
group by cd.card_type,month_num
order by cd.card_type,month_num;

/*list each card type and transaction type,showing the number of tranasactions,total transaction amount,
and average transaction amount,sorted by card type and transaction count from highest to lowest 
*/
select
       cd.card_type,
	   t.transaction_type,
       count(t.transaction_id) as num_transactions,
       round(sum(t.amount),2) as total_transaction_amount,
       round(avg(t.amount),2) as avg_transaction_amount
from transactions t inner join accounts  a on a.account_id=t.account_id
                    inner join cards cd on cd.account_id=a.account_id
group by cd.card_type,t.transaction_type
order by cd.card_type,num_transactions desc;