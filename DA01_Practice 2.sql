--ex1
select distinct city
from station
where id%2 =0;
--ex2
select count(city)-count(distinct city)
from station;
--ex3
--ex4
SELECT 
round(CAST(sum(item_count*order_occurrences)/sum(order_occurrences) as decimal),1) as mean
FROM items_per_order;
--ex5
SELECT candidate_id
FROM candidates
where skill in ('Python','Tableau','PostgreSQL')
group by candidate_id
HAVING COUNT(skill) =3
order by candidate_id;
--ex6
SELECT user_id,
MAX(post_date::date)-MIN(post_date::date) as days_between
FROM posts
where post_date between '2021-01-01' and '2022-01-01'
group by user_id
having count(post_id) >1;
--ex7
SELECT card_name,
MAX(issued_amount)-min(issued_amount) as disparity
FROM monthly_cards_issued
group by card_name
order by disparity desc;
--ex8
--ex9
select *
from cinema
where id%2=1 and description <> "boring"
order by rating desc;
--ex10
select teacher_id,
count(distinct subject_id) as cnt
from teacher
group by teacher_id;
--ex11
select user_id,
    count(follower_id) as followers_count
from followers
group by user_id
order by user_id;
--ex12
select class
from courses
group by class
having count(student) >=5;
