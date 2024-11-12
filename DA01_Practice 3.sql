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
--ex6
select tweet_id
from tweets
where length(content) >15;
--ex7
select activity_date as day, 
count(distinct user_id) as active_users
from activity
where activity_date >='2019-06-28' and activity_date <='2019-07-27' 
and activity_type in ('open_session','end_session','scroll_down','send_message')
group by activity_date
order by activity_date;
--ex8
select count(distinct id)
from employees
where extract(month from joining_date) between 1 and 7
and extract(year from joining_date) =2022;
--ex9
select
position('a' in first_name)
from worker
where first_name ='Amitah';
--ex10
select title, substring(title from length(winery)+2 for 4)
from winemag_p2
where country ='Macedonia';
