--ex1
SELECT 
sum(CASE
  when device_type in ('tablet','phone') then 1
  else 0
END) as mobile_views,
SUM(CASE
  when device_type ='laptop' then 1
  else 0
END) as laptop_views
FROM viewership;
--ex2
select x,y,z,
case 
    when x+y >z and x+z >y and y+z >x then 'Yes'
    else 'No'
end as Triangle
from triangle;
--ex3 --> Cach 1
SELECT 
ROUND(100*sum(CASE
  when call_category is null or call_category ='n/a' then 1
  else 0
END)/count(case_id)::decimal,1) as uncategorised_call_pct
FROM callers;
--ex3 --> Cach 2
SELECT 
ROUND(100*sum(CASE
  when call_category is null or call_category ='n/a' then 1
  else 0
END)/cast(count(case_id) as decimal),1) as uncategorised_call_pct
FROM callers;
--ex4
select
name
from customer
where referee_id <>2 or referee_id is null;
--ex5
select survived,
sum(case
    when pclass=1 and survived =0 then 1
    when pclass=1 and survived =1 then 1
end) as first_class,
sum(case
    when pclass=2 and survived =0 then 1
    when pclass=2 and survived =1 then 1
end) second_class,
sum(case
    when pclass=3 and survived =0 then 1
    when pclass=3 and survived =1 then 1
end) as third_class
from titanic
group by survived;
