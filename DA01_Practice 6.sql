--ex1
with bangtam AS
	(select company_id,title,description,
	count(job_id) as dem
	from job_listings
	group by company_id,title,description)
select count(company_id) as duplicate_companies
from bangtam
where dem>1;

--ex2
with ele AS
  (select category, product, sum(spend) as total_spend
  from product_spend
  where category ='electronics' 
  and extract(year from transaction_date) ='2022'
  group by category, product
  order by total_spend desc
  limit 2),
app AS
  (select category, product, sum(spend) as total_spend
  from product_spend
  where category ='appliance'
  and extract(year from transaction_date) ='2022'
  group by category, product
  order by total_spend desc
  limit 2)
select category, product, total_spend from app
UNION ALL
select category, product, total_spend from ele;

--ex3
with a AS
  (select policy_holder_id,
  count(case_id) as call_count
  from callers
  group by policy_holder_id
  having count(case_id) >=3)
select count(policy_holder_id) from a;

--ex4
select a.page_id
from pages a
left join page_likes b on a.page_id=b.page_id
where b.user_id is NULL
order by a.page_id;

--ex5
with tb1 AS
  (select user_id, event_type, extract(month from event_date) as ex
  from user_actions
  where extract(month from event_date) in ('6','7')
  group by user_id, event_type, extract(month from event_date)),
tb2 AS
  (select user_id, ex as month from tb1
  where ex in ('6','7')
  group by user_id, month
  HAVING count(ex) =2)
select month, count(user_id) as monthly_active_users from tb2
where month='7'
group by month;

--ex6
select 
	to_char(trans_date,'yyyy-mm') as month, country,
	count(id) as trans_count, 
	sum(case when state='approved' then 1 else 0 end) as approved_count,
	sum(amount) as trans_total_amount,
	sum(case when state='approved' then amount else 0 end) as approved_total_amount
from Transactions
group by month, country;

--ex7
select a.*, b.quantity, b.price
from
    (select distinct product_id,
    min(year) as first_year
    from sales
    group by product_id
    order by product_id) as a
join sales as b on a.product_id=b.product_id
where b.year=a.first_year
group by a.product_id, a.first_year, b.quantity, b.price;

--ex8
select customer_id from customer
group by customer_id
having count(distinct product_key) = (select count(distinct product_key) from product);

--ex9
select employee_id from Employees
where salary <30000
and manager_id not in (select employee_id from Employees)
order by employee_id;

--ex10
select COUNT(company_id)
FROM
	(select company_id, title, description,
	COUNT(job_id) as dem
	from job_listings
	group by company_id, title, description) as a
where dem >1;

--ex11
with u1 as
    (select b.name as results,
    count(a.movie_id) as dem
    from MovieRating as a
    join users as b on a.user_id=b.user_id
    group by b.name
    order by dem desc, name
    limit 1),
m1 as
    (select c.title as results,
    avg(a.rating) as avgrating
    from Movies as c
    join MovieRating as a on a.movie_id=c.movie_id
    where to_char(a.created_at,'yyyy-mm') ='2020-02'
    group by c.title
    order by avgrating desc, results
    limit 1)
select results from u1
union all
select results from m1;

--ex12
with allid as
    (SELECT requester_id as id,
    count(*) as count
    from RequestAccepted
    group by requester_id
union all
    SELECT accepter_id as id,
    count(*) as count
    from RequestAccepted
    group by accepter_id)
select id, sum(count) as num from allid
group by id
order by num desc
limit 1;
