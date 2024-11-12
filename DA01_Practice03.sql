--ex1
select
name
from students
where marks >75
order by right(name,3), ID;
--ex2 --> Cach 1
select user_id,
upper(left(name,1)) || lower(substring(name from 2 for 20)) as name
from users
order by user_id;
--ex2 --> Cach 2
select user_id,
upper(left(name,1)) || lower(right(name,length(name)-1)) as name
from users
order by user_id;
--ex3
SELECT manufacturer,
'$' || round(sum(total_sales)/1000000) || ' ' || 'million' as sales
from pharmacy_sales
group by manufacturer
order by sum(total_sales) desc, manufacturer;
--ex4
SELECT extract(month from submit_date) as mth, product_id,
round(avg(stars),2) as avg_stars
FROM reviews
group by product_id, extract(month from submit_date)
order by extract(month from submit_date), product_id;
--ex5
SELECT sender_id,
count(message_id)
FROM messages
where sent_date >= '08-01-2022'
group by sender_id
order by count(message_id) desc
limit 2;
