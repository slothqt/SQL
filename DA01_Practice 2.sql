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
