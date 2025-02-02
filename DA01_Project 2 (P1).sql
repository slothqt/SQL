--Q1
with clean1 as (
  select * from (
    select
      a.order_id as order_id,
      b.product_id,
      a.user_id as user_id,
      FORMAT_DATE('%Y-%m',date(a.delivered_at)) as month_year,
      round(b.sale_price,2) as sale_price,
      row_number() over(partition by a.order_id, b.product_id, a.num_of_item order by a.delivered_at) as stt
    from bigquery-public-data.thelook_ecommerce.orders as a
    join bigquery-public-data.thelook_ecommerce.order_items as b
      on a.order_id=b.order_id
    where a.status='Complete') as g
  where stt=1) -- có 1 dup
, Q1 as (
  select
    month_year,
    count(user_id) as total_user,
    count(order_id) as total_order
  from clean1
  where month_year between '2019-01' and '2022-04'
  group by month_year
  order by month_year)

--Q2
, Q2 as (
  select
    month_year,
    count(distinct user_id) as distinct_users,
    round(sum(sale_price)/count(order_id),2) as average_order_value
  from clean1
  group by month_year
  order by month_year)

--Q3
, young as (
  select
    first_name, last_name,
    gender,
    age,
    (case when age=youngest then 'youngest' else 'not youngest' end) as tag
  from (select
          gender,
          first_name, last_name, age,
          min(age) over(partition by gender order by gender) as youngest
        from bigquery-public-data.thelook_ecommerce.users) as h
  where age=youngest)
, old as (
  select
    first_name, last_name,
    gender,
    age,
    (case when age=oldest then 'oldest' else 'not oldest' end) as tag
  from (select
          gender,
          first_name, last_name, age,
          max(age) over(partition by gender order by gender) as oldest
        from bigquery-public-data.thelook_ecommerce.users) as h
  where age=oldest)
, Q3 as (
  select
    count(case when tag='youngest' then 1 else 0 end) as youngest_cnt,
    count(case when tag='oldest' then 1 else 0 end) as oldest_cnt
  from (
      select * from young
      union all
      select * from old) as j)

--Q4
, rank_table as (
  select *,
    dense_rank() over (partition by month_year order by profit desc) as rank_per_month
  from (
    select
      FORMAT_DATE('%Y-%m',date(sold_at)) as month_year,
      product_id, product_name,
      round(sum(product_retail_price),2) as sales,
      round(sum(cost),2) as cost,
      round(sum(product_retail_price-cost),2) as profit,
    from bigquery-public-data.thelook_ecommerce.inventory_items
    where sold_at is not null
    group by FORMAT_DATE('%Y-%m',date(sold_at)), product_id, product_name) as k
  order by month_year)
, Q4 as (
  select * from rank_table
  where rank_per_month <=5)

--Q5
select
  date(sold_at) as month_year,
  product_category,
  round(sum(product_retail_price),2) as revenue
from bigquery-public-data.thelook_ecommerce.inventory_items
where sold_at is not null
  and date(sold_at) between date_sub('2022-04-15',interval 3 month) and '2022-04-15'
group by month_year,product_category
order by month_year,product_category
