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

  /* insight: 
- từ 1/2019-4/2022, mặc dù có sự biến động nhưng nhìn chung, cả 2 chỉ số ‘tổng số lượng người mua’ và ‘tổng số lượng đơn hàng’ đều tăng dần theo thời gian
- trong đó, tháng 7/2021 có sự tăng đột biến */

--Q2
, Q2 as (
  select
    month_year,
    count(distinct user_id) as distinct_users,
    round(sum(sale_price)/count(order_id),2) as average_order_value
  from clean1
  where month_year between '2019-01' and '2022-04'
  group by month_year
  order by month_year)

  /* insights:
- ‘tổng số người dùng khác nhau’ tăng chậm và có sự dao động từ 1/2019-4/2022 (4-341 users)
- ‘giá trị đơn hàng trung bình’ ở 2 tháng: 2/2019 & 4/2019 cao vượt trội hơn so với các tháng còn lại cùng giai đoạn (lần lượt $164 và $108.13)
- mặc dù distinct_users ở tháng 3/2019 hơn gấp đôi distinct_users ở tháng 2/2019 (10>4), ‘giá trị đơn hàng trung bình’ giảm mạnh vào tháng 3/2019 từ $164 xuống $36
- từ 3/2019 - 4/2022, ‘giá trị đơn hàng trung bình’ dao động trong khoảng $50 ~ $60 */

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
        from bigquery-public-data.thelook_ecommerce.users
        where FORMAT_DATE('%Y-%m',date(created_at)) between '2019-01' and '2022-04') as h
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
        from bigquery-public-data.thelook_ecommerce.users
        where FORMAT_DATE('%Y-%m',date(created_at)) between '2019-01' and '2022-04') as j
  where age=oldest)
, Q3 as (
  select
    count(case when tag='youngest' then 1 else 0 end) as youngest_cnt,
    count(case when tag='oldest' then 1 else 0 end) as oldest_cnt
  from (
      select * from young
      union all
      select * from old) as k)

  /* insights:
- trẻ nhất: 12 tuổi, số lượng: 1786
- lớn nhất: 70 tuổi, số lượng: 1786 */

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
    group by FORMAT_DATE('%Y-%m',date(sold_at)), product_id, product_name) as l
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
