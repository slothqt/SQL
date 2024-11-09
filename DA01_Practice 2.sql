--ex1
select distinct city
from station
where id%2 =0;
--ex2
select count(city)-count(distinct city)
from station;
--ex3
