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
