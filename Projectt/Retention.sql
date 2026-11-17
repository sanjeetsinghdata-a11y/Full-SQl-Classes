-- Active: 1776684353461@@127.0.0.1@3306
use SUPER_SAMPLESTORE
go
 



    -- Find the percentage of customers who placed
    -- another order within 90 days of their first order
    with ct1 as(

        SELECT 
        [Customer ID],
        min([Order Date]) as firstOrderDate
        FROM Orders$
        GROUP BY [Customer ID]

    ),
    Retention as (
        SELECT 
        DISTINCT
        f.[Customer ID],
        f.firstOrderDate
        FROM ct1 as f
        JOIN Orders$ as o 
        ON f.[Customer ID]=o.[Customer ID]
        AND o.[Order Date]> f.firstOrderDate
        and o.[Order Date]<=DATEADD(DAY,90,
            f.firstOrderDate
        )
    )
    SELECT 
        count(*)*100.0/(
        SELECT COUNT(*) FROM ct1 ) as RetentionRate
        FROM Retention




    -- Find customers who purchased in one year
    -- but made no purchase in the following year.

    WITH customer_years AS (
            SELECT DISTINCT
            [Customer ID],
            YEAR([Order Date]) AS OrderYear
        FROM [Orders$]
    )
    SELECT
        a.[Customer ID],
        a.OrderYear AS LastPurchaseYear
    FROM customer_years a
    WHERE NOT EXISTS (
        SELECT 1
        FROM customer_years b
        WHERE b.[Customer ID] = a.[Customer ID]
        AND b.OrderYear = a.OrderYear + 1
    );



    -- Find customers whose revenue increased
    -- for at least 3 consecutive months.

    with ct1 as(

        SELECT 

        [Customer ID],
        [Customer Name],
        DATEFROMPARTS(year([Order Date]),
        MONTH([Order Date]),1) as MonthStart,
        sum(Sales)as Revanues
        FROM  Orders$
        GROUP BY
        [Customer ID],
        [Customer Name],
        year([Order Date]),
        MONTH([Order Date])

    ),
    MonthlySales as (

        SELECT*,
        lag(Revanues) OVER(PARTITION BY [customer id] ORDER BY MonthStart) as MonthlyRevanue
        FROM ct1

    ),
    flag as(
            SELECT *,
            CASE 
                WHEN Revanues>MonthlyRevanue THEN  1
                ELSE 0 
            END as Isincreasing
            FROM MonthlySales 

    )
    SELECT 
    [Customer ID],
    count(*) as IncreasingMonths
    FROM flag
    WHERE Isincreasing=1
    GROUP BY [Customer ID],[Customer Name]
    HAVING count(*)>=3





    -- Find customers whose total revenue is greater than
    -- the average revenue of all customers.


    WITH ct1 as (

        SELECT 
        [Customer ID],
        [Customer Name],
        sum(sales) as Revanue
        FROM Orders$
        GROUP BY [Customer ID],[Customer Name]

    )
    SELECT 
    [Customer ID],
    [Customer Name],
    Revanue
    FROM ct1
    where Revanue>(
        SELECT avg(Revanue) FROM ct1
    )




    -- Calculate Customer Lifetime Value using:
    -- Total Revenue / Number of Orders



    with ct1 as(

        SELECT 
        [Customer ID],
        [Customer Name],
        sum(Sales) as Revanue,
        ROUND(sum(Sales)/nullif(
            COUNT(DISTINCT [order id]),0
        ),2)as RevenuePerOrder
        FROM  Orders$
        GROUP BY
        [Customer Name],
        [Customer ID]
    )

    SELECT * FROM ct1



        -- Find customers whose profit decreased compared
        -- with their previous year.

    WITH ct1 as(

        SELECT 
        [Customer ID],
        [Customer Name],
        year([order date]) as years,
        sum(Profit) as Profit
        FROM Orders$
        GROUP BY [Customer ID],
        [Customer Name],YEAR([Order Date])
    ),
    PrevyearProfit as (

            SELECT *,
            LAG(Profit) OVER(PARTITION BY [customer id] ORDER BY years) as PrevyearProfit
            FROM ct1
    )
    SELECT
    [customer id],
    [customer name],
    profit,
    PrevyearProfit
    FROM PrevyearProfit
    where PrevyearProfit is not NULL
    AND Profit<PrevyearProfit



    -- Identify products generating high revenue
    -- but losing money.

    with  ct1 as (

            SELECT 
            [Product ID],[Product Name],
            sum(sales) as totalSales,
            sum(Profit) as totalProfit
            FROM Orders$
            GROUP BY [Product ID],[Product Name]

    )
    SELECT 
    [Product ID],
    [Product Name],
    totalSales,
    totalProfit
    FROM ct1
    where totalSales>(
        SELECT avg(totalSales) FROM ct1
    )
    and totalProfit<0


----------

    --Compare each product's yearly Sales and Profit
    -- with the previous year.


with  ct1 as (

        SELECT
        [Product ID],
        YEAR([Order Date]) as years,
        sum(sales) as totalsales,
        sum(Profit) as totalprofit
        FROM Orders$
        GROUP BY [Product ID],YEAR([Order Date])

),
ct2 as (

        SELECT 
        [Product ID],
        totalprofit,
        totalsales,
        years,
        LAG(totalsales) OVER(PARTITION BY [product id] ORDER BY years) as PrevSales,
        lag(totalprofit) OVER(PARTITION BY [product id] ORDER BY years) as prevProfit
        FROM ct1

)
SELECT 
[Product ID],
years,
totalSales,
PrevSales,
totalprofit,
prevProfit
FROM ct2
WHERE totalSales>PrevSales
and totalProfit<prevProfit
ORDER BY years



-- Rank customers according to revenue
-- within each region.

WITH ct1 as(

        SELECT 
        [Customer ID],
        Region,
        sum(sales) as totalsales
        FROM Orders$
        GROUP BY
        [Customer ID],Region

),
ct2 as (

    SELECT *,
    row_number() OVER(PARTITION BY  [region] ORDER BY totalsales desc) as rk
    FROM ct1
)
SELECT * FROM ct2
where rk<=3
ORDER BY Region



-- Identify customers contributing to the first 80%
-- of cumulative company revenue.

with ct1 as (

        SELECT 
        [Customer ID],
        sum(sales) as totalsales
         FROM Orders$
        GROUP BY [Customer ID]

),
ct2 as(

    SELECT *,
    SUM(totalsales) OVER(ORDER BY totalsales desc rows UNBOUNDED PRECEDING) as runningRevanue,
    sum(totalsales) OVER() as totalRevanues
    FROM ct1

)
SELECT 
[customer id],
totalsales,
runningRevanue,
totalRevanues,
round(runningRevanue*100.0/totalRevanues,2) as commulativepercentage
FROM ct2
WHERE runningRevanue<=totalRevanues*0.80




-- Find customers whose gap between two consecutive
-- orders was greater than 90 days.


WITH ct1 as (

    SELECT DISTINCT
    [Customer ID],
    [Order Date]
    FROM Orders$
),
gaps as (

        SELECT
        [Customer ID],
        [Order Date],
        LAG([Order Date]) OVER(PARTITION BY [customer id] ORDER BY [order date]) as prevorderdate
        FROM ct1

)
SELECT 
[Customer ID],
prevorderdate,
[Order Date],
DATEDIFF(day,prevorderdate,[Order Date]) as gaps
FROM gaps
WHERE DATEDIFF(
    day,
    prevorderdate,
    [Order Date]
)>90
ORDER BY gaps ASC






-- Find product pairs that appear together
-- in the same order.




    SELECT a.[Product Name] as productA,
    b.[Product Name] as ProductB,
    COUNT(DISTINCT a.[Order ID])as ordertoghter
    FROM Orders$ as a
    JOIN Orders$ as b
    on a.[order id]=b.[order id]
    and a.[Product Name]<b.[Product Name]
    GROUP BY a.[Product name],
    b.[Product name]
    HAVING count(
        DISTINCT a.[order id]
    )>=2
    ORDER BY ordertoghter DESC



-- Find products where higher discounts are associated
-- with negative profitability.


SELECT DISTINCT [Product ID],[Product Name],avg(Discount) as avgdiscount,
sum(sales) as totalsales,
sum(profit ) as totalprofit,
sum(Profit)/nullif(sum(sales),0) as profitmargin
FROM Orders$
GROUP by [Product ID],[Product Name]
HAVING  avg(Discount)>0.20
and sum(Profit)<0
ORDER BY profitmargin



-- Find the first order where each customer
-- generated more than 1000 in Sales.

WITH ct1 as (

    SELECT DISTINCT
    [Customer ID],
    [Customer Name],
    [Order ID],
    [Order Date],
    sum(sales ) as totalsales
    FROM Orders$
    GROUP BY [Customer ID],[Customer Name],[Order ID],[Order Date]
    HAVING sum(sales)>1000

),
Ranked as(

    SELECT *,
    row_number() OVER(PARTITION BY [customer id] ORDER BY  [order date] ) as rk
    FROM ct1

)

SELECT * FROM Ranked
where rk=1



-- Find customers whose first order was below 500
-- but later placed an order above 2000.


WITH order_total as (

    SELECT DISTINCT
    [Customer ID],[Customer Name],[Order ID],[Order Date],
    sum(Sales) as totalsales
    FROM Orders$
    GROUP BY [Customer ID],[Customer Name],[Order ID],[Order Date]


),
first_order as (

        SELECT  *,
        ROW_NUMBER() OVER(PARTITION BY [customer id] ORDER BY [order date]) as rk
        FROM order_total

)
SELECT 
o.[Customer ID]
FROM first_order as f
JOIN order_total as o
on f.[Customer ID]=o.[Customer ID]
WHERE f.rk=1
AND f.totalsales<500
AND o.totalsales>200


-- Find the percentage of customers who placed
-- another order within 90 days of their first order.

with FirstOrder_Date as (

    SELECT DISTINCT
    [Customer ID],
    [Customer Name],
    min([Order Date]) as firstorderdate
    FROM Orders$
    GROUP BY [Customer ID],[Customer Name]


),
Retention as (
    SELECT DISTINCT
    f.[Customer ID]
    FROM FirstOrder_Date as f
    JOIN Orders$ as o
    on f.[Customer ID]=o.[Customer ID]
    AND o.[Order Date]>f.firstorderdate
    AND o.[order date]<=DATEADD(day,90,f.firstorderdate)
    

) 
SELECT COUNT(*) * 100.0 /
    (SELECT COUNT(*) FROM FirstOrder_Date) AS RetentionRate
FROM Retention;



--Calculate Recency, Frequency and Monetary value
-- for every customer.

WITH ct1 as (

        --recency latest  order
        SELECT  [customer id], max([Order Date]) as Recency,
        --frequency count of order per customer 
        count(DISTINCT [order id]) as Frequncy,
        --- monetry sum of sales or  revanue
        sum(sales) as monetry
        frOM  orders$
        GROUP BY
        [Customer ID]
),
ct2 as (

        SELECT *,
        ntile(5) OVER(Order BY recency) as R,
        ntile(5) OVER(ORDER BY frequncy) as f,
        ntile(5) OVER(ORDER BY monetry) as m
        FROM ct1


)
SELECT * FROM ct2


-- Find customers whose Sales increased
-- in at least 3 consecutive orders.

WITH  ct1 as (

        SELECT  [customer id]
       ,[order id]
       ,[order date]
       ,SUM(Sales) AS totalsales
FROM orders$
GROUP BY  [customer id]
         ,[order id]
         ,[order date]
),
ct2 as (

        SELECT *,
        lag(totalsales,1) OVER(PARTITION BY  [customer id] ORDER BY [order date]) as PrevOrd1,
        lag(totalsales,2) OVER(PARTITION BY [customer id] ORDER BY [order date]) as prevOrd2
        FROM  ct1

)
SELECT * FROM  ct2
where totalsales>prevOrd1
and prevOrd1>prevOrd2



-- Find orders where Sales are more than
-- 2 standard deviations above the average.



with ct1 as (

        SELECT 
        avg(sales) as avgsales,
        stdev(Sales) as stdvsales
        FROM orders$
)
SELECT 
o.[customer id],
o.[order id],
o.sales
FROM orders$ as o
CROSS JOIN ct1 as c
where o.sales>c.avgsales+(2*c.stdvsales)




--- Identify the top 10% customers based on revenue.

with  ct1 as(

    SELECT DISTINCT [customer id],
    sum(sales) as totalsales
    FROM Orders$
    GROUP BY [customer id]
),
ranked as (

        SELECT *,
        ntile(10) OVER(ORDER BY totalsales desc) as rk
        FROM ct1
)
SELECT * FROM ranked
where  rk=1





--- Find customers who purchased from
-- every available Category.

SELECT DISTINCT
[customer id]
FROM Orders$
GROUP BY [customer id]
HAVING count(DISTINCT [order id])=(
    SELECT count(DISTINCT category) FROM Orders$
    
)


-- Find the month with the highest total Profit.

with  ct1 as (

       SELECT 
       year([order date])  AS year
       ,month([order date]) AS month
       ,SUM(profit)  AS totalsales
FROM orders$
GROUP BY 
         year([order date])
         ,month([order date])
        
),
ct2 as (

    SELECT *,
    dense_rank() OVER(  ORDER BY totalsales desc) as rk
    FROM ct1

)
SELECT *from ct2
where rk=1



--- Calculate monthly revenue growth percentage.

with ct1 as (

        SELECT 
        datefromparts( year([order date]),
        month([order date]),
        1) as MonthStart,
        sum(sales) as totalsales
        FROM orders$
        GROUP BY year([order date]),month([order date])

),
ct2 as (

        SELECT *,
        lag(totalsales) OVER(ORDER BY  MonthStart) as prevmonthsales
        FROM ct1
        

)
SELECT *,
(totalsales-prevmonthsales)*100.0/nullif(prevmonthsales,0)as growthrate
FROM ct2



-- Find products contributing to the first
-- 50% of total revenue.

WITH ct1 as (

        SELECT 
        [product id],
        sum(sales ) as totalsales
        FROM orders$
        GROUP BY [product id]

),
ct2 as (
    SELECT *,
    sum(totalsales) OVER( ORDER BY totalsales DESC rows UNBOUNDED PRECEDING) as runningsum,
    sum(totalsales) OVER() as totalRevanue
    FROM  ct1

)
SELECT *,
round(runningsum*100/totalRevanue,2) as COntribution
FROM ct2
where runningsum<=totalRevanue*0.50




-- Identify potentially inactive customers.

SELECT
    [Customer ID],
    MAX([Order Date]) AS LastOrderDate
FROM [Orders$]
GROUP BY [Customer ID]
HAVING MAX([Order Date]) <
       DATEADD(
           MONTH,
           -6,
           (SELECT MAX([Order Date]) FROM [Orders$])
       );



--- Find the highest-revenue product
-- within every Category.

WITH ct1 as(

        SELECT  
        [product id],
        category,
        sum(sales) as totalsales
        FROM orders$
        GROUP BY [product id],category

),
ct2 as(

    SELECT *,
    row_number() OVER(PARTITION BY [category] ORDER BY totalsales DESC) as rk
    FROM ct1

)

SELECT * FROM ct2
where rk=1



-- Identify customers who purchased in
-- consecutive calendar months. " continue or following month"


with ct1 as (

        SELECT 
        DISTINCT
        [customer id],
        [order id],

        datefromparts(
            year([order date]),
            month([order date]),
            1
        )as months

        FROM orders$
        GROUP BY [customer id],datefromparts(
            year([order date]),
            month([order date]),
            1
        ),[order id]

),
ct2 as (

    SELECT *,
    lag(months) OVER(PARTITION BY [customer id] ORDER BY months )as prevmonth
    FROM ct1

)
SELECT * FROM ct2
WHERE datediff(month,prevmonth,months)=1

 


-- Find the maximum number of days between
-- two consecutive orders for every customer.

WITH orders AS (
    SELECT DISTINCT
        [Customer ID],
        [Order Date]
    FROM [Orders$]
),
gaps AS (
    SELECT
        [Customer ID],
        [Order Date],
        LAG([Order Date]) OVER (
            PARTITION BY [Customer ID]
            ORDER BY [Order Date]
        ) AS PreviousOrder
    FROM orders
)
SELECT
    [Customer ID],
    MAX(
        DATEDIFF(
            DAY,
            PreviousOrder,
            [Order Date]
        )
    ) AS MaximumGapDays
FROM gaps
WHERE PreviousOrder IS NOT NULL
GROUP BY [Customer ID]
ORDER BY MaximumGapDays DESC;





-- Find products whose yearly Sales declined
-- for three consecutive years.


WITH ct1 AS
(
	SELECT  [product id]
	       ,year([order date]) AS years
	       ,SUM(sales)         AS yearlysales
	FROM orders$
	GROUP BY  year([order date])
	         ,[product id]
), ct2 AS
(
	SELECT  *
	       ,lag(yearlysales,1) OVER(PARTITION BY [product id] ORDER BY  years) AS prevyearsales1
	       ,lag(yearlysales,2) OVER(PARTITION BY [product id] ORDER BY years)  AS prevyearsales2
	FROM ct1
)
SELECT  *
FROM ct2
WHERE yearlysales < prevyearsales1
AND prevyearsales1 < prevyearsales2



 -- Compare each customer's profit margin
-- with the average margin of their Region.

WITH customer_margin AS (
    SELECT
        Region,
        [Customer ID],
        SUM([Profit]) / NULLIF(SUM([Sales]), 0)
            AS ProfitMargin
    FROM [Orders$]
    GROUP BY
        Region,
        [Customer ID]
),
region_average AS (
    SELECT
        Region,
        AVG(ProfitMargin) AS AvgRegionMargin
    FROM customer_margin
    GROUP BY Region
)
SELECT
    c.[Customer ID],
    c.Region,
    c.ProfitMargin,
    r.AvgRegionMargin
FROM customer_margin c
JOIN region_average r
    ON c.Region = r.Region
WHERE c.ProfitMargin < r.AvgRegionMargin;




----- find recency ,frquncy  and monetry


with RFM as(

        SELECT 
        [customer id],
        datediff(
            day,
            max([order date]),
            (SELECT max([order date]) FROM orders$)
        ) as  recency,
        count(DISTINCT [order id]) as frequncy,
        sum(sales) as monetry
        FROM orders$
        GROUP BY [customer id]

),
RFM_Score as (

        SELECT *,
        ntile(5) OVER(ORDER BY recency  ) as r_score,
        ntile( 5) OVER(ORDER BY frequncy  )  as f_score,
        ntile( 5) OVER(ORDER BY  monetry  ) as m_score
        FROM RFM


)
,fincal_ as (

            SELECT
            recency,
            frequncy,
            monetry,
            r_score,
            f_score,
            m_score,
            concat(
                r_score,
               f_score,
               m_score
            )as RFM_Scores,

            CASE 
                 WHEN r_score>=4
                 AND f_score>=4
                 and  m_score>=4
                 THEN 'champion'

                 WHEN r_score>=4
                 and f_score>=3
                 and m_score>=3
                 THEN  'loyal customer'

                 WHEN  r_score>=4
                 and f_score<=2
                 THEN ' potentialy customer'

                 WHEN r_score<=2
                 and f_score>=4
                 and  m_score>=4
                 THEN 'at high risk'

                WHEN  r_score<=2
                and f_score<=2
                and m_score<=2
                THEN 'lost'

            else 'need attention'


            END as customersegment

            from RFM_Score

),
ct3 as (


            SELECT *,
            sum(
                CASE 
                    WHEN customersegment='champion' THEN 1
                    ELSE  0
                END
            )as totalchap,

            sum(
                CASE 
                    WHEN customersegment='potential customer' THEN  1
                    ELSE  0
                END
            ) as potentialcuscount,

            sum(

                CASE 
                    WHEN customersegment='loyal  customer' THEN  1
                    ELSE  0
                END

            )as totalloyal,

            sum(

                CASE 
                    WHEN customersegment='at high risk' THEN  1
                    ELSE  0
                END
            ) as athigh_Riskcus,


            sum(

                CASE 
                    WHEN customersegment='lost' THEN  1
                    ELSE  0
                END
            ) as lostcustom
            
            FROM fincal_

)

SELECT  
*
from fincal_
ORDER BY r_score desc,
f_score DESC,
m_score DESC

Segment
 ↓
Customer Count
 ↓
Revenue by Segment
 ↓
% Revenue Contribution
 ↓
Average Order Value
 ↓
Average Recency
 ↓
Average Frequency



 SELECT *from orders$


 -- 81. Find customers whose first purchase occurred
--     in each year of the dataset.

WITH FirstPurchase AS (
    SELECT
        [Customer ID],

        -- Find the first purchase date of each customer
        MIN([Order Date]) AS FirstPurchaseDate

    FROM [Orders$]
    GROUP BY [Customer ID]
)

SELECT
    [Customer ID],
    FirstPurchaseDate,
    YEAR(FirstPurchaseDate) AS FirstPurchaseYear
FROM FirstPurchase

-- Sort customers by the year they first purchased
ORDER BY
    FirstPurchaseYear,
    [Customer ID];



-- 48. Find orders whose Sales are greater than
--     the average Order Sales.

SELECT  DISTINCT [order id]
       ,SUM(sales) AS totalsales
FROM orders$
GROUP BY  [order id]
HAVING SUM(sales) > (
SELECT  AVG(totalsales)
FROM
(
	SELECT  SUM(sales) AS totalsales
	FROM Orders$
	GROUP BY  [order id]
)as x )




-- 51. Find the first month in which each customer
--     generated more than 5,000 in cumulative revenue.


with ct1 as (

    SELECT 
    [customer id],
    year([order date]) as year,
    month([order date]) as month,
    sum(sales) as MonthlyRevanue
    from orders$
    GROUP BY 

    [customer id],
    year([order date]), 
    month([order date]) 

)
,commulativeRevanues as (

        SELECT *,
        sum(MonthlyRevanue) OVER( PARTITION BY [customer id] ORDER BY year,month ROWS UNBOUNDED PRECEDING ) as CommulativeRevanue   
        FROM ct1
),
Cummulative_Revanues_rk as (

        SELECT *,
        row_number() OVER(PARTITION BY [customer id] ORDER BY year,month ASC ) as rk
        FROM commulativeRevanues
        where CommulativeRevanue>5000
)

SELECT * FROM Cummulative_Revanues_rk
where rk=1



---52. Find customers whose cumulative revenue
--     contributes to more than 1% of total company revenue.

with CustomerRevanues as (

    SELECT 
    [customer id],
    sum(sales) as Revanues
    FROM orders$
    GROUP BY [customer id]

),
Commulative_sum as(

    SELECT
    sum(Revanues) as TotalRevanues
    FROM CustomerRevanues
),
Commulative_contribution as (

        SELECT 
        cr.[customer id],
        cr.Revanues as Revanues,
        cs.TotalRevanues as TotalRevanues,
        Revanues*100/nullif(TotalRevanues,0)   as contribution
        FROM CustomerRevanues as cr
        CROSS JOIN Commulative_sum as cs
        WHERE   round(cr.Revanues*100/nullif(cs.TotalRevanues,0),2)>1
         

)
SELECT * FROM Commulative_contribution


-- 53. Find the percentage contribution of each Region
--     to total company revenue.


with ct1 as (

    SELECT Region,sum(sales) as regionalsales
    FROM orders$
    GROUP BY Region
)
SELECT 
Region,
regionalsales,
regionalsales*100/sum(regionalsales) OVER() as conrti
FROM ct1



-- using cross join


with RegionSales as (


        SELECT 
        Region,
        sum(sales) as Regionalsales 
        FROM  orders$
        GROUP BY Region

),
Revanues as (

            SELECT sum(sales) as totalsales FROM orders$


)
, contribution as (

        SELECT rs.Region,
        rs.Regionalsales,
        r.totalsales,
        rs.Regionalsales*100/nullif(r.totalsales,0) as contributionRegion
        FROM RegionSales as rs
        CROSS JOIN Revanues as r

)

SELECT * FROM contribution



-- 55. Find the percentage contribution of each Product
--     to its Category's total revenue.


with  ct1 as(

    SELECT 
    [product id],
    [product name],
    category,
    sum(sales) as productRevanues
    FROM orders$
    GROUP BY [product id],
    [product name],
    [category]


),
ct2 as (

        SELECT 
        category,
        sum(sales) as categoryrevanues
        FROM orders$
        GROUP BY [category]

)
,
ct3 as (

        SELECT 
        c1.category,
        c1.productRevanues,
        c2.categoryrevanues,
        c1.productRevanues*100/ c2.categoryrevanues as cont
        FROM ct1 as c1
        CROSS JOIN ct2 as c2

)

SELECT * FROM ct3



-- 57. Find customers whose order frequency is above
--     the average customer order frequency.


select
[customer id],
[customer name],
count(DISTINCT [order id]) as CustomerOrders
from orders$
GROUP BY  [customer id ],[customer name]
HAVING count(DISTINCT [order id])>(
    SELECT avg(totalorders) FROM (

         SELECT 
        [customer id],
        [customer name],
        count(DISTINCT [order id]) as totalorders
        FROM orders$
        GROUP BY [customer id],
        [customer name]

    )as x
       
)




-- 59. Find customers who have both:
--     total Sales above average AND profit margin above average.


SELECT 

[customer id], 
[customer name],
round(sum(sales),2) as totalsales,
round(sum(profit)/sum(sales),2) as profitmargin
FROM orders$
GROUP BY [customer id],[customer name]
HAVING sum(sales)>(

        SELECT avg(sales ) as avgsales FROM  orders$
    
)
and sum(profit)/sum(sales)>(

        SELECT avg(totalprofitmargin) FROM(

            SELECT sum(profit)/sum(sales) as totalprofitmargin FROM  orders$
        )as y

)

SELECT avg(sales) FROM orders$




-- 63. Find pairs of products that were purchased
--     together in the same Order ID.

SELECT DISTINCT 
a.[product id],
b.[product id]
FROM 
orders$ as a
JOIN orders$ as b
ON a.[order id]=b.[order id]
AND
a.[product name]<b.[product name]





-- 64. Find the most frequently purchased product pairs.

with productPair as(

        SELECT 
        p1.[product name] as product1,
        p2.[product name] as product2
        FROM orders$ as p1
        JOIN orders$ as p2
        ON p1.[order id]=p2.[order id]
        and p1.[product name]<p2.[product name]

)
,
purchasedtogher as (

        SELECT 
        product1,
        product2,
        count(*) as MostFrequntlypur
        FROM productpair
        GROUP BY product1,
        product2
    

)

SELECT * FROM  purchasedtogher
ORDER BY MostFrequntlypur DESC


-- 66. Find customers whose latest order occurred
--     within 30 days of their previous order.

with CustomerOrderDate as(


    SELECT 
    [customer id],
    [order id],
    [order date],
    lag([order date]) over(PARTITION BY [customer id] ORDER BY [order date]) as prevorderdate    
    FROM orders$
    

),
latesorderdate as (


    SELECT *,
    row_number() OVER(PARTITION BY [customer id] ORDER BY [order date] desc) as rn
    from CustomerOrderDate

)
SELECT *,
datediff(day,prevorderdate,[order date]) as daydiff
FROM latesorderdate
where rn=1
and datediff(day,prevorderdate,[order date])<=30
ORDER BY daydiff DESC




-- 81. Find customers whose first purchase occurred
--     in each year of the dataset.


with firstpurchasesdate  as (


    SELECT 
    [customer id],
    min([order date]) as firstpurchaseddate
    FROM orders$
    GROUP BY [customer id]

),
ct2 as (

        SELECT *,
        year(firstpurchaseddate) as yr
        FROM  firstpurchasesdate
        GROUP BY firstpurchaseddate,
        [customer id]
)
SELECT * FROM ct2



WITH FirstPurchase AS (
    SELECT
        [Customer ID],
        MIN([Order Date]) AS FirstPurchaseDate
    FROM Orders$
    GROUP BY [Customer ID]
)

SELECT
    YEAR(FirstPurchaseDate) AS FirstPurchaseYear,
    COUNT(*) AS NewCustomers
FROM FirstPurchase
GROUP BY YEAR(FirstPurchaseDate)
ORDER BY FirstPurchaseYear;


