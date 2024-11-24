--ex1
with tam as
  (select extract(year from transaction_date) as year, product_id,
    sum(spend) as total_spend
  from user_transactions
  group by product_id, year
  order by product_id, year)

select *,
  lag(total_spend) over(partition by product_id order by year) 
  as previous_year_spend,
  round((total_spend-lag(total_spend) over(partition by product_id order by year))
  /lag(total_spend) over(partition by product_id order by year)*100,2) 
  as yoy_rate
from tam;

--ex2
with gop as
  (SELECT card_name,
    make_date(issue_year,issue_month,'1') as date,
    issued_amount
  from monthly_cards_issued)

select distinct card_name,
  first_value(issued_amount) over(partition by card_name order by date)
  as launch_amt
from gop
order by launch_amt desc;

--ex3
with tam as
  (SELECT user_id, spend, date(transaction_date) as date,
    RANK() over(partition by user_id order by transaction_date) as stt
  from transactions)
select user_id, spend, date
from tam
where stt=3;

--ex4
with t1 as
	(SELECT
		first_value(transaction_date) over(partition by user_id order by transaction_date desc)
		as most_recent_date,
		row_number() over(partition by user_id order by transaction_date desc) as rank,
		user_id,
		count(product_id) as purchase_count
	from user_transactions
	group by user_id, transaction_date)
select most_recent_date, user_id, purchase_count
from t1
where rank=1
order by most_recent_date;

--ex5
SELECT user_id, tweet_date,
round(avg(tweet_Count) over(partition by user_id order by tweet_date
rows between 2 preceding and current row),2)
FROM tweets;

--ex6
with q as (
  select merchant_id,
      extract(epoch from 
      (transaction_timestamp-lag(transaction_timestamp) 
          over(partition by merchant_id, credit_card_id, amount 
          order by transaction_timestamp)))/60 as time_diff
  from transactions)
select count(*)
from q
where time_diff <=10;

--ex7
with q as
	(SELECT category, product, sum(spend) as total_spend,
	  rank() over (partition by category order by sum(spend) desc) as rank
	from product_spend
	where extract(year from transaction_date) =2022
	group by category, product)
select category, product, total_spend from q
where rank <=2;

--ex8
with cte1 AS
	(select a.artist_name, count(c.rank) as frequency,
    dense_rank() over(order by count(c.rank) desc) as artist_rank
  from artists a
  join songs b on a.artist_id=b.artist_id
  join global_song_rank c on b.song_id=c.song_id
  where c.rank <=10
  group by a.artist_name)
select artist_name, artist_rank
from cte1
where artist_rank <=5;
