--HW 1
--ex1
select name from city
where countrycode ="USA"
and population >120000;
--ex2
select * from city
where countrycode ="JPN";
--ex3
select city, state from station;
--ex4
select distinct city from station
where city like 'a%' or city like 'e%' or city like 'i%' or city like 'o%' or city like 'u%';
--ex5
select distinct city from station
where city like '%a' or city like '%e' or city like '%i' or city like '%o' or city like '%u';
--ex6
select distinct city from station
where not (city like 'a%' or city like 'e%' or city like 'i%' or city like 'o%' or city like 'u%');
--ex7
select name from employee
order by name;
--ex8
select name from employee
where salary >2000 and months <10
order by employee_id;
--ex9
select product_id from products
where low_fats ='y' and recyclable ='y';
--ex10
select name from customer
where referee_id <>2 or referee_id is null;

