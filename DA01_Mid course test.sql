--Q1
select distinct film_id, replacement_cost
from film
order by replacement_cost;
--Q2
select
	sum(case when replacement_cost between 9.99 and 19.99 then 1 else 0 end) as low,
	sum(case when replacement_cost between 20.00 and 24.99 then 1 else 0 end) as medium,
	sum(case when replacement_cost between 25.00 and 29.99 then 1 else 0 end) as high
from film;
--Q3
select a.title, a.length, c.name as category_name
from film a
join film_category b
on a.film_id=b.film_id
join category c
on b.category_id=c.category_id
where c.name in ('Drama','Sports')
order by a.length desc;
--Q4
select c.name as category_name,
count(a.title) as count
from film a
join film_category b
on a.film_id=b.film_id
join category c
on b.category_id=c.category_id
group by c.name
order by count(a.title) desc;
--Q5
select a.first_name, a.last_name, count(film_id) as film_count
from actor a
left join film_actor b
on a.actor_id=b.actor_id
group by a.first_name, a.last_name
order by count(film_id) desc;
--Q6
select
sum(case when b.customer_id is null then 1 else 0 end) as count
from address a
left join customer b
on a.address_id=b.address_id;
--Q7
select c.city as city_name, sum(d.amount) as doanh_thu
from customer a
join address b
on a.address_id=b.address_id
join city c
on b.city_id=c.city_id
join payment d
on a.customer_id=d.customer_id
group by c.city
order by doanh_thu desc;
--Q8
select c.city || ', ' || e.country as "city, country",
sum(d.amount) as doanh_thu
from customer a
join address b
on a.address_id=b.address_id
join city c
on b.city_id=c.city_id
join payment d
on a.customer_id=d.customer_id
join country as e
on c.country_id=e.country_id
group by "city, country"
order by doanh_thu;
