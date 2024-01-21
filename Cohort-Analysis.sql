select * from OnlineRetail

--Delete CustomerID where CustomerID is null
delete from OnlineRetail where CustomerID is null

--Delete duplicates
with cte as (
    select *, 
            row_number() over (partition by InvoiceNo, StockCode, CustomerID, Description, Quantity, InvoiceDate, UnitPrice, Country order by (select 1)) as RowNumber
    from OnlineRetail    
)

delete from cte where RowNumber > 1;

--Format InvoiceDate
alter table OnlineRetail
add FormattedInvoiceDate VARCHAR(10);

update OnlineRetail
set FormattedInvoiceDate = CONVERT(VARCHAR, InvoiceDate, 23);

--Delete rows where quantity <= 0 or unit price < = 0
delete from OnlineRetail where (Quantity <= 0) or (UnitPrice <= 0)

--Create Cohort table
with min as (
select CustomerID, min(FormattedInvoiceDate) as Min_InvoiceDate
from OnlineRetail
group by CustomerID),

distinct_table as (
    select distinct CustomerID, FormattedInvoiceDate
    from OnlineRetail),

month_diff as (
    select d.CustomerID, d.FormattedInvoiceDate, m.Min_InvoiceDate, datediff(month, Min_InvoiceDate, FormattedInvoiceDate) as Month_diff
    from distinct_table d
    join min m
    on d.CustomerID = m.CustomerID)

select concat(month(Min_InvoiceDate),'-', year(Min_InvoiceDate)) as Corhort_month, count(distinct CustomerID)/count(distinct CustomerID)*100 as [New_customers],
    count(distinct case when [Month_diff] = 1 then CustomerID end)*100/count(distinct CustomerID) as Month_1,
    count(distinct case when [Month_diff] = 2 then CustomerID end)*100/count(distinct CustomerID) as Month_2,
    count(distinct case when [Month_diff] = 3 then CustomerID end)*100/count(distinct CustomerID) as Month_3,
    count(distinct case when [Month_diff] = 4 then CustomerID end)*100/count(distinct CustomerID) as Month_4,
    count(distinct case when [Month_diff] = 5 then CustomerID end)*100/count(distinct CustomerID) as Month_5,
    count(distinct case when [Month_diff] = 6 then CustomerID end)*100/count(distinct CustomerID) as Month_6,
    count(distinct case when [Month_diff] = 7 then CustomerID end)*100/count(distinct CustomerID) as Month_7,
    count(distinct case when [Month_diff] = 8 then CustomerID end)*100/count(distinct CustomerID) as Month_8,
    count(distinct case when [Month_diff] = 9 then CustomerID end)*100/count(distinct CustomerID) as Month_9,
    count(distinct case when [Month_diff] = 10 then CustomerID end)*100/count(distinct CustomerID) as Month_10,
    count(distinct case when [Month_diff] = 11 then CustomerID end)*100/count(distinct CustomerID) as Month_11,
    count(distinct case when [Month_diff] = 12 then CustomerID end)*100/count(distinct CustomerID) as Month_12
from month_diff
group by year(Min_InvoiceDate), month(Min_InvoiceDate)