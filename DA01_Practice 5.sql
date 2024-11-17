--ex1
select b.continent, floor(avg(a.population))
from city as a
left join country as b
on a.countrycode=b.code
where b.continent is not null
group by b.continent;
--ex2
SELECT
round(sum(case when a.signup_action ='Confirmed' then 1 else 0 end)/
count(b.user_id)::decimal,2)
as activation_rate
FROM emails as b
inner join texts as a
on a.email_id=b.email_id;
--ex3
SELECT a.age_bucket,
round(sum(CASE when b.activity_type ='send' then time_spent else 0 end)*100.0/
sum(b.time_spent),2) as send_perc,
round(sum(CASE when b.activity_type ='open' then time_spent else 0 end)*100.0/
sum(b.time_spent),2) as open_perc
from age_breakdown as a
inner join activities as b
on a.user_id=b.user_id
where b.activity_type in ('open','send')
group by a.age_bucket;
--ex4
SELECT b.customer_id
from products as a
inner join customer_contracts as b
on a.product_id=b.product_id
group by b.customer_id
having count(distinct a.product_category)=3;
--ex5
select mng.employee_id, mng.name, count(mng.employee_id) as reports_count,
round(avg(emp.age)) as average_age
from employees emp
join employees mng
on emp.reports_to=mng.employee_id
group by mng.employee_id, mng.name
order by mng.employee_id;
--ex6
select a.product_name, sum(b.unit) as unit
from products a
left join orders b
on a.product_id=b.product_id
where to_char(b.order_date,'yyyy-mm') ='2020-02'
group by a.product_id, a.product_name
having sum(b.unit) >=100;
--ex7
SELECT a.page_id
FROM pages a
left join page_likes b
on a.page_id=b.page_id
where user_id is null
order by a.page_id;
