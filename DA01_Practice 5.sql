--ex1
select b.continent, floor(avg(a.population))
from city as a
left join country as b
on a.countrycode=b.code
where b.continent is not null
group by b.continent;
--ex2
