/* 1. Chuyển đổi kiểu dữ liệu phù hợp cho các trường (sử dụng câu lệnh ALTER) */
alter table public.sales_dataset_rfm_prj
alter column ordernumber type numeric USING (trim(ordernumber)::numeric),
alter column quantityordered type smallint USING (trim(quantityordered)::smallint),
alter column priceeach type numeric USING (trim(priceeach)::numeric),
alter column orderlinenumber type smallint USING (trim(orderlinenumber)::smallint), 
alter column sales type numeric USING (trim(sales)::numeric),
alter column orderdate type timestamp USING (orderdate::timestamp with time zone),
alter column status type text USING (trim(status)::text),
alter column productline type text USING (trim(productline)::text),
alter column msrp type numeric USING (trim(msrp)::numeric),
alter column customername type text USING (trim(customername)::text),
alter column addressline1 type text USING (trim(addressline1)::text),
alter column addressline2 type text USING (trim(addressline2)::text),
alter column contactfullname type text USING (trim(contactfullname)::text);

/* 2. Check NULL/BLANK (‘’) ở các trường: ORDERNUMBER, QUANTITYORDERED, PRICEEACH, ORDERLINENUMBER, SALES, ORDERDATE. */
select * from sales_dataset_rfm_prj
where nullif(ORDERNUMBER::text,'') is null
   or nullif(QUANTITYORDERED::text,'') is null
   or nullif(PRICEEACH::text,'') is null
   or nullif(ORDERLINENUMBER::text,'') is null
   or nullif(SALES::text,'') is null
   or nullif(ORDERDATE::text,'') is null

/* 3. Thêm cột CONTACTLASTNAME, CONTACTFIRSTNAME được tách ra từ CONTACTFULLNAME.
Chuẩn hóa CONTACTLASTNAME, CONTACTFIRSTNAME theo định dạng chữ cái đầu tiên viết hoa, chữ cái tiếp theo viết thường. */
--- ADD COLUMN
alter table sales_dataset_rfm_prj
add column CONTACTLASTNAME text
add column CONTACTFIRSTNAME text

--- UPDATE
update sales_dataset_rfm_prj
set CONTACTFIRSTNAME=right(CONTACTFULLNAME,length(CONTACTFULLNAME)-position('-' in CONTACTFULLNAME))
set CONTACTLASTNAME=left(CONTACTFULLNAME,position('-' in CONTACTFULLNAME)-1)

--- STANDARDIZE
update sales_dataset_rfm_prj
set CONTACTLASTNAME=upper(left(CONTACTLASTNAME,1)) || right(CONTACTLASTNAME,length(CONTACTLASTNAME)-1)
set CONTACTFIRSTNAME=upper(left(CONTACTFIRSTNAME,1)) || right(CONTACTFIRSTNAME,length(CONTACTFIRSTNAME)-1)

/* 4. Thêm cột QTR_ID, MONTH_ID, YEAR_ID lần lượt là Qúy, tháng, năm được lấy ra từ ORDERDATE */
--- ADD COLUMN
alter table sales_dataset_rfm_prj
add column QTR_ID smallint,
add column MONTH_ID smallint,
add column YEAR_ID smallint

--- QTR_ID
update sales_dataset_rfm_prj
set QTR_ID=case 
	when to_char(ORDERDATE,'mm-dd') between '01-01' and '03-31' then 1
	when to_char(ORDERDATE,'mm-dd') between '04-01' and '06-30' then 2
	when to_char(ORDERDATE,'mm-dd') between '07-01' and '09-30' then 3
	when to_char(ORDERDATE,'mm-dd') between '10-01' and '12-31' then 4
else QTR_ID
end;

--- MONTH_ID & YEAR_ID
update sales_dataset_rfm_prj
set 
	MONTH_ID=extract(month from ORDERDATE),
	YEAR_ID=extract(year from ORDERDATE)

/* 5. Hãy tìm outlier (nếu có) cho cột QUANTITYORDERED và hãy chọn cách xử lý cho bản ghi đó (2 cách) ( Không chạy câu lệnh trước khi bài được review) */
with cte_minmax as
(select Q1-1.5*IQR as min, Q3+1.5*IQR as max from
(select
percentile_cont(0.25) within group (order by QUANTITYORDERED) as Q1,
percentile_cont(0.75) within group (order by QUANTITYORDERED) as Q3,
percentile_cont(0.75) within group (order by QUANTITYORDERED)-percentile_cont(0.25) within group (order by QUANTITYORDERED) as IQR
from sales_dataset_rfm_prj) as a),
cte_outlier as (
select *
from sales_dataset_rfm_prj
where QUANTITYORDERED<(select min from cte_minmax)
	or QUANTITYORDERED>(select max from cte_minmax))
	
update sales_dataset_rfm_prj
set QUANTITYORDERED=(select avg(QUANTITYORDERED) from sales_dataset_rfm_prj
where QUANTITYORDERED in (select QUANTITYORDERED from cte_outlier)
