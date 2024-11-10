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
round(sum(item_count::decimal*order_occurrences)/sum(order_occurrences),1) as mean
FROM items_per_order;
--ex5
--ex6
SELECT user_id,
MAX(post_date::date)-MIN(post_date::date) as days_between
FROM posts
where post_date between '2021-01-01' and '2022-01-01'
group by user_id
having count(post_id) >1;
