-- Tạo metric trước khi dựng dashboard 
create view project2.vw_ecommerce_analyst as (
with t1 as (
  select
    FORMAT_DATE('%Y-%m',date(a.created_at)) as Month,
    FORMAT_DATE('%Y',date(a.created_at)) as Year,
    c.category as Product_category,
    b.sale_price,
    b.order_id,
    c.cost
  from
    bigquery-public-data.thelook_ecommerce.orders a
  join 
    bigquery-public-data.thelook_ecommerce.order_items b
    on a.order_id=b.order_id
  join 
    bigquery-public-data.thelook_ecommerce.products c
    on b.product_id=c.id
  where a.status='Complete')
, t2 as (
select 
  Month,
  Year,
  TPV,
  TPO,
  concat(round((next_month_TPV-TPV)/TPV*100.00,2),'%') as Revenue_growth,
  concat(round((next_month_TPO-TPO)/TPO*100.00,2),'%') as Order_growth
from (
  select
    Month,
    Year,
    round(sum(sale_price),2) as TPV,
    lead(round(sum(sale_price),2)) over(order by Month, Year) as next_month_TPV,
    count(order_id) as TPO,
    lead(count(order_id)) over(order by Month, Year) as next_month_TPO
  from t1
  group by Month, Year
  order by Month, Year) as h)
, t3 as (
  select
    Month,
    Year,
    round(sum(cost),2) as Total_cost
  from t1
  group by Month, Year)
select 
  d.Month,
  d.Year,
  d.Product_category,
  e.TPV,
  e.TPO,
  e.Revenue_growth,
  e.Order_growth,
  f.Total_cost,
  round(e.TPV-f.Total_cost,2) as Total_profit,
  round((e.TPV-f.Total_cost)/f.Total_cost,2) as Profit_to_cost_ratio
from 
  t1 d
join
  t2 e
  on d.Month=e.Month
join
  t3 f
  on e.Month=f.Month
order by d.Month, d.Year)

--Tạo retention cohort analysis
with clean as (
select
  order_id,
  product_id,
  sale_price,
  date(created_at) as order_date,
  user_id
from
  bigquery-public-data.thelook_ecommerce.order_items
where status='Complete')
, cohort_draft as (
  select
    user_id,
    sale_price,
    FORMAT_DATE('%Y-%m',first_purchase_date) as cohort_date,
    order_date,
    (extract(year from order_date)-extract(year from first_purchase_date)) * 12 +
    (extract(month from order_date)-extract(month from first_purchase_date)) + 1 as index
  from (
    select
      user_id,
      sale_price,
      min(order_date) over (partition by user_id) as first_purchase_date,
      order_date
    from
      clean) as m
  order by user_id)

, z as (
select
  cohort_date,
  index,
  count(distinct user_id) as customer_count,
  round(sum(sale_price),2) as total_revenue
from
  cohort_draft
where
  index<=4
group by 
  cohort_date, index
order by
  cohort_date)

, customer_cohort as (
select
  cohort_date,
  sum(case when index=1 then customer_count else 0 end) as m1,
  sum(case when index=2 then customer_count else 0 end) as m2,
  sum(case when index=3 then customer_count else 0 end) as m3,
  sum(case when index=4 then customer_count else 0 end) as m4
from z
group by
  cohort_date
order by
  cohort_date)

-- retention cohort
select
  cohort_date,
  concat(round(m1/m1*100.00),'%') as m1,
  concat(round(m2/m1*100.00),'%') as m2,
  concat(round(m3/m1*100.00),'%') as m3,
  concat(round(m4/m1*100.00),'%') as m4
from
  customer_cohort
