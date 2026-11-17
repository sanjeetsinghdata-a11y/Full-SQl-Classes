-- Active: 1776684353461@@127.0.0.1@3306
use SUPER_SAMPLESTORE
GO
SELECT * FROM Orders$

 
-- ============================================================
-- PROJECT: E-COMMERCE SALES & PROFIT ANALYSIS
-- DATASET: Orders$
-- ROLE: Data Analyst
-- ============================================================


-- ============================================================
-- 🟢 LEVEL 1 — BUSINESS BASICS
-- ============================================================

-- 1. Find the total Sales, total Profit, total Orders,
--    and Average Order Value.


SELECT  SUM(Sales)             AS totalsales
       ,SUM(Profit)            AS totalprofit
       ,COUNT(DISTINCT [Order ID])      AS totalordersUnique,
       sum(Sales)/COUNT( DISTINCT [Order ID]) as averageordervalue

    
FROM Orders$


-- 2. Find the top 10 customers by total Sales.
SELECT  top 10 [Customer ID]
       ,[Customer Name]
       ,sales
       ,Profit
       ,Region
       ,Category
FROM Orders$
ORDER BY Sales DESC


-- 3. Find the top 10 products by total Profit.
SELECT top 10  [Product ID]
       ,r.[Product Name]
r.       ,SUM(Profit) as totalprofit
FROM Orders$
GROUP BY  [Product ID]
         ,r.[Product Name]
r.ORDER BY  totalprofit DESC


-- 4. Find the Category generating the highest Sales and Profit.


SELECT Category,sum(Sales) as totalsales,sum(Profit)  as totalprofit FROM Orders$
GROUP BY Category
HAVING  sum(Sales) >=(
    SELECT max(totalsales) FROM (
        SELECT sum(Sales) as totalsales FROM  Orders$
        GROUP BY Category
        
    )as x
     
)
and sum(Profit)>=(
    SELECT max(totalprofit) FROM  (
        SELECT sum(Profit) as totalprofit FROM  Orders$
        GROUP BY Category
    )as y
)



-- 5. Find monthly Sales and Profit for each year.

SELECT  YEAR([Order Date])  AS year
       ,MONTH([Order Date]) AS month
       ,SUM(Sales)          AS totalsales
FROM Orders$
GROUP BY  YEAR([Order Date])
         ,MONTH([Order Date])
ORDER BY  YEAR([Order Date])
         ,MONTH([Order Date])




-- 6. Find the Region with the highest total Sales.

SELECT  Region
       ,SUM(sales) AS totalsales
FROM Orders$
GROUP BY  Region
HAVING SUM(Sales) >= (
SELECT  MAX(totalsales)
FROM
(
	SELECT  Region
	       ,SUM(sales) AS totalsales
	FROM Orders$
	GROUP BY  Region
)as x )


 


-- 8. Find customers who have never placed an order
--    with negative Profit.

SELECT  DISTINCT [Customer ID],[Customer Name]
FROM orders$ as o
WHERE NOT EXISTS(
    SELECT * FROM  Orders$ as c
    WHERE c.[Customer ID]=o.[Customer ID]
    and c.Profit<0
)


-- 9. Find products that generated Sales but resulted
--    in an overall loss.


SELECT DISTINCT [Product ID],r.[Product Name],r.sum(Sales),sum(Profit)
FROM orders$ as o
where EXISTS(
    SELECT * FROM Orders$ as c
    WHERE c.[Product ID]=o.[Product ID]
    and c.Sales>0
) 
GROUP BY [Product ID],r.[Product Name]
r.HAVING sum(Profit)<0





-- 10. Find the percentage contribution of each Category
--     to total Sales.


-- by  using cte
WITH ct1 as
(
	SELECT  Category
	       ,SUM(Sales) AS catsales
	FROM Orders$
	GROUP BY  Category
), ct2 AS
(
	SELECT  SUM(catsales) AS totalsales
	FROM ct1
)
SELECT  c.Category
       ,c.catsales
       ,catsales/totalsales*100 AS percentagecontribution
FROM ct1 AS c
CROSS JOIN ct2 AS c2


---- by using sub quary

SELECT  Category
       ,SUM(Sales)as totalsales
       ,SUM(sales)*100/(
SELECT  SUM(Sales)
FROM Orders$)as totalsales
FROM Orders$
GROUP BY  Category




-- ============================================================
-- 🟡 LEVEL 2 — CUSTOMER ANALYSIS
-- ============================================================

-- 11. Find each customer's first and latest Order Date.

SELECT  [Customer ID]
       ,MAX(CASE WHEN firstorder = 1 THEN [Order Date] END) AS firstorder
       ,MAX(CASE WHEN lastorder = 1 THEN [Order Date] END)as lastorder
FROM
(
	SELECT  [Customer ID]
	       ,[Order Date]
	       ,ROW_NUMBER() OVER(PARTITION BY [customer ID] ORDER BY  [Order Date ] ASC) AS firstorder
	       ,ROW_NUMBER() OVER(PARTITION BY [customer ID] ORDER BY [Order Date] DESC)  AS lastorder
	FROM Orders$
)as t
GROUP BY  [Customer ID]


-- 12. Find customers whose total Sales are above
--     the average customer Sales.

SELECT  [Customer ID]
       ,[Customer Name]
       ,SUM(Sales) AS totalsales
FROM orders$
GROUP BY  [Customer ID]
         ,[Customer Name]
HAVING SUM(Sales) > (
SELECT  AVG(totalsales)
FROM
(
	SELECT [Customer ID], SUM(sales) AS totalsales
	FROM Orders$
	GROUP BY  [Customer ID]
)as t )
ORDER BY totalsales ASC


-- 13. Find customers who purchased from all three Categories.

SELECT DISTINCT o.[Customer ID],o.[Customer Name]
 from Orders$ as o
WHERE EXISTS(
    SELECT 1
    FROM Orders$ as c
    WHERE c.[Customer ID]=o.[Customer ID]
    and c.Category='Furniture'

)
and EXISTS(  SELECT 1
from Orders$ as c1
WHERE c1.[Customer ID]=o.[Customer ID]
and c1.Category='Office Supplies '

)
and EXISTS(
    SELECT 1
     FROM Orders$ as c2
    WHERE c2.[Customer ID]=o.[Customer ID]
    and c2.Category='Technology'
)

 


-- 14. Find customers who purchased Technology
--     but never purchased Furniture.


SELECT DISTINCT o.[Customer ID],o.Category FROM  Orders$ as o
where  EXISTS(
    SELECT 1
     FROM Orders$  as c
    where c.[Customer ID]=o.[Customer ID]
    and c.Category='Technology'
)
and not  EXISTS(
    SELECT 1
     FROM Orders$  as c2
    WHERE c2.[Customer ID]=o.[Customer ID]
    and c2.Category='Furniture'
)

-- 15. Find customers whose latest order had lower Sales
--     than their previous order.

with  ct1 as(
    SELECT 
    [Customer ID]
    [Order Date],
    Sales,
    lag(Sales) OVER(PARTITION BY [customer ID] ORDER BY [Order Date]) as prevsales
    FROM orders$

)
SELECT 
[Customer ID]
[Order Date] as latesorder,
Sales as latestordersales,
prevsales 
from ct1
where prevsales is NOT NULL
and [Order Date]=(
    SELECT max([Order Date]) FROM Orders$ as o2
    WHERE o2.[Customer ID]=ct1.[Customer ID]

)
and sales<prevsales



 



-- 16. Find customers whose Sales increased every year.

WITH ct1 AS
(
	SELECT  [Customer ID]
	       ,[Customer Name]
	       ,SUM(Sales)         AS totalsales
	       ,YEAR([Order Date]) AS years
	FROM Orders$
	GROUP BY  [Customer ID]
	         ,[Customer Name]
	         ,YEAR([Order Date])
) , ct2 AS
(
	SELECT  [Customer ID]
	       ,[Customer Name]
	       ,years
	       ,totalsales
	       ,LAG([totalsales]) OVER(PARTITION BY [customer ID] ORDER BY  years) AS prevsales
	FROM ct1
)
SELECT  [Customer ID]
       ,[Customer Name]
       ,prevsales
       ,years
FROM ct2
GROUP BY  [Customer ID]
         ,[Customer Name]
HAVING COUNT(*) > 1 AND 
    SUM(CASE 
    WHEN prevsales is not NULL 
    AND totalsales <= prevsales THEN 
    1 ELSE 0
    END) = 0;






 


    -- 17. Find customers who placed orders in at least
    --     3 different years.

  SELECT  [Customer ID]
       ,[Customer Name]
FROM Orders$
GROUP BY  [Customer ID]
         ,[Customer Name]
HAVING COUNT(DISTINCT YEAR([Order Date])) >= 3



-- 18. Find the customer with the longest gap between
--     two consecutive orders.

with  orderdata as(
    SELECT  DISTINCT [Customer ID]
       ,[Customer Name]
       ,[Order Date]
       ,[Order ID]
        FROM Orders$    
),
calculategaps as (
    SELECT 
    [Customer ID]
    [Order Date],
    LAG([Order Date]) OVER(PARTITION BY [customer ID] ORDER BY [order Date])as prevorderdate
    FROM orderdata
)
,
gapb as (

    SELECT 
    [Customer ID]
    [Order Date],
    prevorderdate,
    DATEDIFF(DAY,prevorderdate,[Order Date]) as highestgap
     FROM calculategaps

)

SELECT  top 4 [Customer ID]
[Order Date] as lastordete,
prevorderdate,
highestgap
FROM gapb
ORDER BY highestgap DESC

 
 

-- 19. Find customers who placed another order within
--     30 days of their previous order.

    WITH OrderData as
(
	SELECT  DISTINCT [Customer ID]
	       ,[Customer Name]
	       ,[Order Date]
	       ,[Order ID]
	FROM Orders$
), calculatedaygap as(
SELECT  [Customer ID]
       ,[Customer Name]
       ,[Order Date]
       ,[Order ID]
       ,lag([Order Date]) OVER(PARTITION BY [Customer ID] ORDER BY  [Order Date]) AS prevorder
FROM OrderData ), daygap AS
(
	SELECT  [Customer ID]
	       ,[Customer Name]
	       ,[Order Date]
	       ,prevorder
	       ,DATEDIFF(day,prevorder,[order Date]) AS gapbetweenorder
	FROM calculatedaygap
)
SELECT  [Customer ID]
       ,[Customer Name]
       ,[Order Date] AS currentDate
       ,prevorder
       ,gapbetweenorder
FROM daygap
WHERE gapbetweenorder <= 30
AND prevorder is NOT NULL
 
 

-- 20. Find customers whose total Profit is negative
--     despite having total Sales above 50,000.

SELECT [Customer IDsum(Profit) totalprofit,sum(sales) as totalsales FROM Orders$
GROUP BY [Customer ID],[Customer Name]
HAVING sum(Profit)<0
and sum(Sales)>50000


-- with  cte

WITH ct1 AS
(
	SELECT  [Customer ID]
	       ,[Customer Name]
	       ,SUM(profit) AS totalprofit
	       ,SUM(sales )as totalsales
	FROM Orders$
	GROUP BY  [Customer ID]
	         ,[Customer Name]
)
SELECT  [Customer ID]
       ,[Customer Name]
       ,totalprofit
       ,totalsales
FROM ct1
WHERE totalprofit < 0
AND totalsales > 50000


---- by using sub quary

SELECT  [Customer ID]
       ,[Customer Name]
       ,totalprofit
       ,totalsales
FROM
(
	SELECT  [Customer ID]
	       ,[Customer Name]
	       ,SUM(Profit)as totalprofit
	       ,SUM(sales) AS totalsales
	FROM orders$
	GROUP BY  [Customer ID]
	         ,[Customer Name]
)as t
WHERE totalprofit < 0
AND totalsales > 50000



 
-- ============================================================
-- 🟠 LEVEL 3 — PRODUCT ANALYSIS
-- ============================================================

-- 21. Find the highest-selling product in each Category.


WITH ct1 AS
(
	SELECT  Category
	       ,r.[Product Name]
r.	       ,[Product ID]
	       ,SUM(sales) AS totalsales
	FROM orders$
	GROUP BY  Category
	         ,[Product ID]
	         ,r.[Product Name]
r.) , rankedtotalsalesproduct AS
(
	SELECT  *
	       ,ROW_NUMBER() OVER(PARTITION BY [Category] ORDER BY  totalsales DESC) AS rk
	FROM ct1
)
SELECT  *
FROM rankedtotalsalesproduct
WHERE rk = 1



-- 22. Find the highest-profit product in each Sub-Category.

WITH ct1 as (
    SELECT [Sub-Category],[Product ID],r.[Product Name],r.sum(Profit)as totalprofit FROM Orders$
    GROUP BY [Product ID],r.[Product Name],r.[Sub-Category]
),
rankedproductprofit as (
    SELECT *,
    ROW_NUMBER() OVER (PARTITION BY [Sub-Category] ORDER BY totalprofit desc)as rk
     FROM ct1
)
SELECT * FROM rankedproductprofit
WHERE rk=1


-- 23. Find products whose Sales are greater than the
--     average Sales of products in the same Category.

SELECT  DISTINCT [Product ID]
       ,r.[Product Name]
r.       ,SUM(Sales) AS totalsales
FROM Orders$ AS o
GROUP BY  [Product ID]
         ,r.[Product Name]
r.         ,Category
HAVING SUM(sales) > (
SELECT  AVG(totalsales)
FROM
(
	SELECT  SUM(c.sales) AS totalsales
	FROM Orders$   
    AS c
	WHERE c.Category = o.Category 
    GROUP BY c.[Product ID],c.r.[Product Name]
r.)as x
 )


-- 24. Find products whose Profit is negative in more
--     than 50% of their orders.
WITH ct1 as
(
	SELECT  [Product ID]
	       ,r.[Product Name]
r.	       ,COUNT(DISTINCT [Order ID])                                 AS totalorder
	       ,COUNT( DISTINCT CASE WHEN Profit < 0 THEN [Order ID] END ) AS negativeordertotal
	FROM orders$
	GROUP BY  [Product ID]
	         ,r.[Product Name]
r.)
SELECT  [Product ID]
       ,r.[Product Name]
r.       ,totalorder
       ,negativeordertotal
       ,negativeordertotal*100.0/totalorder AS precentage
FROM ct1
WHERE negativeordertotal*100.0/totalorder >50




    -- 25. Find the product with the highest Sales growth
    --     between consecutive years.

WITH ct1 AS
(
	SELECT  [Product ID]
	       ,r.[Product Name]
r.	       ,YEAR([Order Date]) AS year
	       ,SUM(sales)         AS totalsales
	FROM Orders$
	GROUP BY  [Product ID]
	         ,r.[Product Name]
r.	         ,YEAR([Order Date])
), calculateprevyearsales AS
(
	SELECT  [Product ID]
	       ,r.[Product Name]
r.	       ,[year]
	       ,totalsales
	       ,LAG(totalsales) OVER(PARTITION BY [Product ID] ORDER BY  [year]) AS prevyearsales
	FROM ct1
), salesgrowth AS
(
	SELECT  [Product ID]
	       ,r.[Product Name]
r.	       ,[year]
	       ,totalsales
	       ,prevyearsales
	       ,totalsales-prevyearsales AS growth
	FROM calculateprevyearsales
	WHERE prevyearsales is NOT NULL 
)
SELECT  top 1 *
FROM salesgrowth
ORDER BY growth DESC





-- 26. Find products that were sold in every Region.

SELECT DISTINCT o.[Product ID],o.[Product Name],o.Region FROM Orders$ as o
where  EXISTS(
    SELECT [Product ID],r.[Product Name],r.Region FROM Orders$ as r
    WHERE r.[Product ID]=o.[Product ID]
    AND r.Region='South'
    

)
AND
EXISTS(
    SELECT r.[Product ID],r.[Product Name],r.Region FROM Orders$ as r
    where r.[Product ID]=o.[Product ID]
    and r.Region='West'

)
AND
EXISTS(
    SELECT [Product ID],r.[Product Name],r.Region FROM Orders$ as r
      WHERE r.[Product ID]=o.[Product ID]
      and r.Region='Central'

)
AND
EXISTS(
    SELECT [Product ID],r.[Product Name],r.Region FROM Orders$  as r
    WHERE r.[Product ID]=o.[Product ID]
    and r.Region='East'

)



-- 27. Find the second-highest-selling product
--     in each Category.

WITH OrderData AS
(
	SELECT  Category
	       ,[Product ID]
	       ,[Product Name]
	       ,SUM(Sales) AS totalsales
	FROM Orders$
	GROUP BY  [Product ID]
	         ,[Product Name]
	         ,Category
), RankedProductSales AS
(
	SELECT  *
	       ,DENSE_RANK() OVER(PARTITION BY [Category] ORDER BY  totalsales DESC) AS rk
	FROM OrderData
)
SELECT  *
FROM RankedProductSales
WHERE rk = 2



-- 28. Find the top 3 products by Sales in each Region.

WITH OrderData AS
(
	SELECT  Region
	       ,[Product ID]
	       ,[Product Name]
	       ,SUM(sales) AS totalsales
	FROM Orders$
	GROUP BY  Region
	         ,[Product ID]
	         ,[Product Name]
), RankedRegionSales AS
(
	SELECT  *
	       ,DENSE_RANK() OVER(PARTITION BY [Region ] ORDER BY  totalsales DESC) AS rk
	FROM OrderData
)
SELECT  *
FROM RankedRegionSales
WHERE rk <= 3

-- 29. Find products whose Sales increased for at least
--     3 consecutive orders.


WITH OrderSales as
(
	SELECT  [Product ID]
	       ,[Product Name]
	       ,[Order Date]
	       ,[Order ID]
	       ,SUM(sales) AS Ordersalestotal
	FROM Orders$
	GROUP BY  [Product ID]
	         ,[Product Name]
	         ,[Order Date]
	         ,[Order ID]
), ct2 AS
(
	SELECT  [Product ID]
	       ,[product Name]
	       ,[order Date]
	       ,Ordersalestotal
	       ,LAG(Ordersalestotal,1) OVER(PARTITION BY [Product ID] ORDER BY  [Order Date]) AS oneOrderAgoSales
	       ,lag(Ordersalestotal,2) OVER(PARTITION BY [Product ID] ORDER BY [Order Date])  AS twoOrderAgoSales
	       ,lag(Ordersalestotal,3) OVER(PARTITION BY [Product ID] ORDER BY [Order Date])  AS threeOrderAgoSales
	FROM OrderSales
)
SELECT  DISTINCT [Product ID]
       ,[Product Name]    
FROM ct2
WHERE OrderSalestotal > oneOrderAgoSales
AND oneOrderAgoSales > twoOrderAgoSales
AND TwoOrderAgoSales > threeOrderAgoSales


-- 30. Find the longest increasing Sales sequence
--     for each Customer.

WITH CustomerSales AS
(
	SELECT  [Customer ID]
	       ,[Customer Name]
	       ,[Order Date]
	       ,[Order ID]
	       ,SUM(sales) AS totalsalesForOrder
	FROM Orders$
	GROUP BY  [Customer ID]
	         ,[Customer Name]
	         ,[Order Date]
	         ,[Order ID]
), Comparision AS
(
	SELECT  [Customer ID]
	       ,[Customer Name]
	       ,[Order Date]
	       ,totalsalesForOrder
	       ,lag(totalsalesForOrder) OVER(PARTITION BY [Customer ID] ORDER BY  [Order Date] ) AS prevOrderSales
	FROM CustomerSales
), IsEncreasingFlag AS
(
	SELECT  *
	       ,CASE WHEN totalsalesForOrder > prevOrderSales THEN 1  ELSE 0 END AS ISencreasing
	FROM Comparision
), groped AS
(
	SELECT  *
	       ,SUM(CASE WHEN ISencreasing = 0 THEN 1 ELSE 0 END) OVER(PARTITION BY [Customer ID] ORDER BY  [Order Date] rows UNBOUNDED PRECEDING) AS GropID
	FROM IsEncreasingFlag
), sequnce AS
(
	SELECT  [Customer ID]
	       ,[Customer Name]
           , GropID
	       ,COUNT(*) AS sequencecount
	FROM groped
	WHERE IsEncreasing = 1
	GROUP BY  [Customer ID]
	         ,[Customer Name]
	         ,GropID
), ranked_sequnce AS
(
	SELECT  *
	       ,dense_rank() OVER (PARTITION BY [Customer ID] ORDER BY  sequencecount DESC) AS ranking
	FROM sequnce
)
SELECT  [Customer IDsequencecount
FROM ranked_sequnce
WHERE ranking = 1
ORDER BY sequencecount DESC


 
-- ============================================================
-- 🔴 LEVEL 4 — ADVANCED DATA ANALYST PROBLEMS
-- ============================================================

-- 31. Calculate month-over-month (MoM) Sales growth.

WITH CalculateSales AS
(
    SELECT
        YEAR([Order Date]) AS Year,
        MONTH([Order Date]) AS Months,
        SUM(Sales) AS MonthlySales
    FROM Orders$
    GROUP BY
        YEAR([Order Date]),
        MONTH([Order Date])
),

CT2 AS
(
    SELECT
        *,
        LAG(MonthlySales) OVER
        (
            ORDER BY Year, Months
        ) AS PrevSales
    FROM CalculateSales
)

SELECT
    Year,
    Months,
    MonthlySales,
    PrevSales,
    (MonthlySales - PrevSales) * 100.0 / PrevSales AS GrowthPercentage
FROM CT2
ORDER BY
    Year,
    Months;

-- 32. Calculate year-over-year (YoY) Sales growth.

with  Calcultesales as (
    SELECT year([Order Date]) as year,sum(Sales) as Yearlysales FROM orders$
    GROUP BY year([Order Date])
),
ct2 as (
    SELECT *,
    lag(Yearlysales) OVER(ORDER BY year)as  prevyearsales
    FROM Calcultesales
)
SELECT year,Yearlysales,prevyearsales,(yearlysales-prevyearsales)*100.0/prevyearsales
FROM  ct2
ORDER BY year
 

-- 33. Find the month with the highest Sales growth
--     in each year.

with  ct1 as (
    SELECT year([Order Date]) as year,month([Order Date]) as months ,sum(sales)as monthlysales
    FROM orders$
    GROUP BY year([Order Date]),month([Order Date])
),
ct2 as (
    SELECT *,
    row_number() OVER(PARTITION BY year ORDER BY monthlysales desc) as rk
    FROM  ct1

)
SELECT * FROM  ct2
where rk=1
ORDER BY year,months DESC




--- to validate  the number  if we are  getting some wrong  number or on the way going right



SELECT year([Order Date ]) AS YEAR,month([Order Date])as month,sum(sales )as monylysales FROM orders$
where year([Order Date])=2017
GROUP BY year([Order Date]),month([Order Date])
HAVING  sum(sales)in(
    SELECT max(totalsales) FROM(
        SELECT year([Order Date]) as year,month([Order Date ]) as month,sum(sales) as totalsales FROM orders$
        where year([order Date])=2017
        GROUP BY year([Order Date]),Month([order Date])
    --ORDER BY year([Order Date]),Month([order Date])

    ) as x
)




-- 34. Find customers whose current order Sales is
--     greater than their previous order Sales.



WITH ct1 as
(
	SELECT  [Customer ID]
	       ,[Customer Name]
	       ,[Order ID]
	       ,[Order Date]
	       ,SUM(sales ) AS totalsales
	FROM orders$
	GROUP BY  [Customer ID]
	         ,[Customer Name]
	         ,[Order ID]
	         ,[Order Date]
), ct2 as(
SELECT  *
       ,lag(totalsales) OVER(PARTITION BY [Customer ID] ORDER BY  [Order Date])as prevOrderSales
FROM ct1 )
SELECT  [Customer ID]
       ,[Order Date]
       ,totalsales AS CurrentOrdeSales
       ,prevOrderSales
FROM ct2
WHERE totalsales > prevOrderSales



-- 35. Calculate the running Sales total for each Region.

WITH ct1 as (
    SELECT Region,year([Order Date]) as year,month([Order Date]) as month,sum(sales) as monhtlysales  from orders$
    GROUP BY Region,year([Order Date]),month([Order Date])
),
ct2 as (

    SELECT *,
    sum(monhtlysales) OVER(PARTITION BY Region ORDER BY year,month rows BETWEEN UNBOUNDED PRECEDING and CURRENT row) as regionrunningtotal
    FROM ct1

)
SELECT Region,year,month,monhtlysales,regionrunningtotal FROM ct2
ORDER BY Region,year,month


-- 36. Calculate the 3-month rolling average Sales
--     for each Region.

with ct1 as (
    SELECT Region,year([Order Date])as year,month([Order Date]) as month,sum(Sales) as totalsales FROM  Orders$
    GROUP BY Region,year([Order Date]),month([Order Date])
),
ct2 as (
    SELECT *,
    avg(totalsales) OVER(PARTITION BY Region ORDER BY year,month rows BETWEEN 3 PRECEDING and CURRENT row) as ThreemonthRollingAvg
    FROM ct1

)
SELECT Region,Year,month,totalsales, ThreemonthRollingAvg FROM  ct2
ORDER BY Region,year,month


-- 37. Find the first product purchased by every Customer.
with  ct1 as (
    SELECT [Customer ID[Product ID],[Product Name],
    row_number() OVER
    (PARTITION BY [Customer ID] ORDER BY [Order Date],[Order ID]) as rk
    FROM orders$

)
SELECT * FROM  ct1
WHERE rk=1



-- 38. Find the first order where each Customer
--     generated positive Profit.

WITH ct1 as (
    SELECT 
    [Customer ID],
        [Order ID],
        [Order Date],
        SUM(Profit) AS TotalProfit
    FROM Orders$
    GROUP BY
        [Customer ID],
        [Order ID],
        [Order Date]    

),
ct2 as (
    SELECT *,
    row_number() OVER(PARTITION BY [Customer ID] ORDER BY [Order Date],[Order ID])as rk
    FROM ct1
    where totalprofit>0
)

SELECT * FROM ct2
WHERE rk=1



-- 39. Find customers whose every order was profitable.

 
 SELECT  o.[Customer ID]
       ,o.[Customer Name]
FROM orders$ AS o
WHERE not EXISTS(
SELECT  1
FROM
(
	SELECT  [Customer ID]
	       ,[Order ID]
	       ,SUM(Profit) AS totalprofit
	FROM orders$
	GROUP BY  [Customer ID]
	         ,[Customer Name]
	         ,[Order ID]
)as x
WHERE x.[Customer ID] = o.[Customer ID]
AND totalprofit <= 0 )



  
     


-- 40. Find customers who had at least one order
--     with Sales greater than their own average order Sales.

/*Customer
   ↓
Calculate Sales for each Order
   ↓
Calculate that Customer's average Order Sales
   ↓
Find orders > that average
   ↓
DISTINCT Customer
*/


WITH ct1 AS
(
	SELECT  [Customer Name]
	       ,[Customer ID]
	       ,[Order ID]
	       ,[Order Date]
	       ,SUM(sales) AS totalsales
	FROM orders$
	GROUP BY  [Customer Name]
	         ,[Customer ID]
	         ,[Order ID]
	         ,[Order Date]
)
SELECT DISTINCT
              o.[Customer Name]
	       ,o.[Customer ID]
              --o.totalsales
FROM ct1 as o
 where o.totalsales>
(
       SELECT avg(c.totalsales) 
       FROM ct1 as c
       where c.[Customer ID]=o.[Customer ID]

)







-- ============================================================
-- 🔥 LEVEL 5 — REAL DATA ANALYST CASE STUDY
-- ============================================================

-- Business Problem:
-- "Our Sales increased, but Profit decreased.
--  Find out why."



-- 41. Find Categories where Sales increased
--     but Profit decreased year-over-year.

WITH ct1 AS
(
	SELECT  Category
	       ,year([Order Date]) AS year
	       ,SUM(Sales)         AS yearlyCategorysales
	       ,SUM(profit)        AS yearlyCategoryProfit
	FROM orders$
	GROUP BY  Category
	         ,year([order Date])
), ct2 AS
(
	SELECT  *
	       ,lag(yearlyCategorysales) OVER(PARTITION BY Category ORDER BY  year) AS prevCatSales
	       ,lag(yearlyCategoryprofit) OVER(PARTITION BY Category ORDER BY year) AS prevCatProfit
	FROM ct1
)
SELECT  [Category]
       ,year
       ,yearlyCategorysales
       ,yearlyCategoryProfit
       ,prevCatSales
       ,prevCatProfit
FROM ct2
WHERE yearlyCategorysales > prevCatSales
AND yearlyCategoryProfit < prevCatProfit



-- 42. Find Sub-Categories where Sales increased
--     but Profit became negative.
WITH ct1 AS
(
	SELECT  [Sub-Category],year([Order Date]) as year
	       ,SUM(sales)  AS  currentSales
	       ,SUM(profit) AS  currentprofit
	FROM orders$
	GROUP BY  [Sub-Category],year([Order Date])
), ct2 AS
(
	SELECT  [Sub-Category],year
	       , currentSales
	       , currentprofit
	       ,lag( currentSales) OVER(PARTITION BY [Sub-Category] ORDER BY  year)  AS prevsales
	       ,lag( currentprofit) OVER(PARTITION BY [Sub-Category] ORDER BY year) AS prevProfit
	FROM ct1
)
SELECT  DISTINCT [Sub-Category],year
       , currentSales
       , currentprofit
       ,prevsales
       ,prevProfit
FROM ct2
WHERE  currentSales > prevsales
AND  currentprofit < prevProfit









-- 43. Find the States responsible for the largest
--     Profit decline.


WITH ct1 AS
(
    SELECT
        State,
        YEAR([Order Date]) AS Year,
        SUM(Profit) AS CurrentProfit
    FROM Orders$
    GROUP BY
        State,
        YEAR([Order Date])
),
ct2 AS
(
    SELECT
        State,
        Year,
        CurrentProfit,
        LAG(CurrentProfit) OVER
        (
            PARTITION BY State
            ORDER BY Year
        ) AS PrevProfit
    FROM ct1
),
ct3 AS
(
    SELECT
        State,
        Year,
        CurrentProfit,
        PrevProfit,
        CurrentProfit - PrevProfit AS ProfitChange
    FROM ct2
    WHERE PrevProfit IS NOT NULL
)
SELECT TOP 1
    State,
    Year,
    CurrentProfit,
    PrevProfit,
    ProfitChange
FROM ct3
WHERE ProfitChange < 0
ORDER BY ProfitChange ASC;


-- 44. Find products with high Sales but consistently
--     negative Profit.

WITH ct1 as
(
	SELECT  [Product ID]
	       ,[Product Name]
	       ,year([Order Date]) as year
	       ,SUM(sales ) as   yearlySales
	       ,SUM(profit)  as YearlyProfit
	FROM orders$
	GROUP BY  [Product ID]
	         ,[Product Name]
	         ,year([Order Date])
), ct2 AS
(
	SELECT  [Product ID]
	       ,[Product Name],
              sum(yearlySales)as totalsales,
              sum(YearlyProfit)as totalprofit,
              count(*) as totalyear,
              sum(
                     CASE 
                            WHEN YearlyProfit<0 THEN  1
                            ELSE  0
                     END
              ) as Negativeprofityear
	        from ct1
               GROUP BY
               [Product ID],
               [Product Name]
)

SELECT  [Product ID]
       ,[Product Name]
       ,totalsales,
       totalprofit,
       totalyear
FROM ct2 
       where totalsales> (
              SELECT avg(totalsales) FROM ct2
       )
and Negativeprofityear=totalyear
ORDER BY totalyear DESC



-- 45. Find the top 10 Customers contributing
--     to Profit decline.

with ct1 as(

     SELECT  [Customer ID]
       ,[Customer Name]
       ,year([Order Date]) AS year
       ,SUM(profit)    AS yearlyProfit
FROM orders$
GROUP BY  [Customer ID]
       
         year([Order Date])
),
ct2 as (
       SELECT 
       [Customer ID]

       year,
       yearlyProfit,
       lag(yearlyProfit) OVER(PARTITION BY [Customer ID] ORDER BY year) as prevprofit
       FROM ct1

),
ct3 as(
       SELECT [Customer ID]

       yearlyProfit,
       prevprofit,
       yearlyProfit-prevprofit as yearlychangeprofit
        FROM ct2
       WHERE prevprofit IS NOT NULL
      AND yearlyProfit < prevprofit

)
SELECT top 10 [Customer ID]

       yearlyProfit,
       prevprofit,
       yearlychangeprofit
         FROM ct3
ORDER BY  yearlychangeprofit ASC

 

-- 46. Compare the average Discount between
--     profitable and loss-making orders.

-- 46. Compare the average Discount between
--     profitable and loss-making orders.

WITH OrderData AS
(
    SELECT
        [Order ID],
        SUM(Profit) AS TotalProfit,
        AVG(Discount) AS OrderDiscount
    FROM Orders$
    GROUP BY [Order ID]
)
SELECT
    CASE
        WHEN TotalProfit > 0 THEN 'Profitable'
        WHEN TotalProfit < 0 THEN 'Loss-Making'
    END AS OrderType,
    AVG(OrderDiscount) AS AverageDiscount,
    COUNT(*) AS NumberOfOrders
FROM OrderData
WHERE TotalProfit <> 0
GROUP BY
    CASE
        WHEN TotalProfit > 0 THEN 'Profitable'
        WHEN TotalProfit < 0 THEN 'Loss-Making'
    END;



use SUPER_SAMPLESTORE
GO



       -- 48. Find the Category with the highest
       --     average Discount.

       SELECT category,avg( Discount)*100 as avgdiscount FROM orders$
       GROUP BY category
       HAVING avg( Discount)>=(
              SELECT max(avgdiscount) FROM (
                     SELECT category,avg( Discount) as avgdiscount FROM orders$
                     GROUP BY category
              )as x
       )



       -- 49. Find Customers who received unusually high
       --     Discounts compared with the average Discount
       --     in their Region.

       with  ct1 as (
              SELECT [Customer ID],
[Region],sum( Discount) as totaldiscount
              FROM orders$
              GROUP BY [Customer ID],
[Region]
       ),
       ct2 as (
              SELECT *,
             avg(totaldiscount) OVER(PARTITION BY [Region] ) as avgdiscount
              FROM ct1 

       )
       SELECT * FROM ct2
       where totaldiscount>avgdiscount
       ORDER BY region,totaldiscount DESC
       


       -- 50. Find orders where Discount was higher than
       --     the average Discount for that Sub-Category.
SELECT [Order ID],avg(Discount),[Sub-Category] as avgdiscount FROM orders$ as o
GROUP BY [Sub-Category],[Order ID]
having avg(Discount)>(
       SELECT avg(totaldiscount) FROM (
              SELECT [Order ID],[Sub-Category],sum( Discount) as totaldiscount FROM orders$
              GROUP BY [Sub-Category],[Order ID]
       )as x
       WHERE x.[Sub-Category]=o.[Sub-Category]
)




SELECT [Order ID],avg( Discount) as avgdiscount,[Sub-Category] FROM  orders$ as o
GROUP BY  [Sub-Category],[Order ID]
HAVING avg( Discount)>(
       SELECT avg(c. Discount) FROM  orders$ as c
       where c.[Sub-Category]=o.[Sub-Category]
      
)





-- ============================================================
-- 🏆 LEVEL 6 — INTERVIEW-LEVEL SQL
-- ============================================================

-- 51. Find the second-highest Customer by total Sales
--     without using TOP.


with ct1 as(
       SELECT [Customer IDsum(sales) as totalsales FROM  orders$
       GROUP BY [Customer ID],[Customer Name]
) 
,
ct2 as (
       SELECT *,
       row_number() OVER(ORDER BY totalsales DESC) as rk
       FROM ct1

)

SELECT * FROM ct2
where rk=2
ORDER BY totalsales DESC



-- 52. Find the third-highest Customer in each Region.

with ct1 as (
       SELEC[Customer ID],[Region],sum(sales) as totalsales
        FROM orders$
       GROUP B[Customer ID],[Region]
),
ct2 as (
       SELECT *,
       row_number() OVER(PARTITION BY [Region] ORDER BY totalsales DESC) as rk
       FROM ct1

)

SELECT * FROM ct2
WHERE rk=3
ORDER BY totalsales desc


-- 53. Find Customers whose Sales are above the
--     average Sales of their Region.

 
SELECT [Region],[Customer IDsales FROM orders$ as o
where sales>(
       SELECT avg(totalsales) FROM (
              SELECT [Region],[Customer IDsum(sales) as totalsales FROM  orders$ as c
              where c.[Region]=o.[Region]
              GROUP BY [Region],[Customer ID],[Customer Name]
       )as x
)


-- 54. Find the top 3 Customers in every Region
--     using DENSE_RANK().

with ct1 as (
       SELECT [Customer ID[Region],sum(sales) as totalsales FROM  orders$
       GROUP BY [Customer ID[Region]
),
ct2 as(
       SELECT *,
       dense_rank() OVER(PARTITION BY Region ORDER BY totalsales desc ) as rk
       FROM ct1

)

SELECT * FROM  ct2
where rk=3
ORDER BY totalsales DESC


-- 55. Find the first and last order of every Customer
--     using window functions.

WITH ct1 as (
       SELECT [Customer ID[Order Date],[Order ID]
       FROM orders$
       GROUP BY [Customer ID[Order Date],[Order ID]
),
ct2 as(
       SELECT *,
       row_number() OVER(PARTITION BY [Customer ID] ORDER BY [Order Date]) as firstOrder,
       row_number() OVER(PARTITION BY [Customer ID] ORDER BY [Order Date] DESC) as lastorder
       FROM  ct1

),
ct3 as (
       SELECT [Customer ID
       max(
              CASE 
                     WHEN firstorder=1 THEN  [Order Date]
                      
              END
       )as firstorders,

       max(
              CASE 
                     WHEN lastorder=1 THEN  [Order Date]
                     
              END
       ) as lastorders

       FROM ct2
       GROUP BY
       [Customer ID],[Customer Name]
)


SELECT [Customer IDfirstorders,lastorders FROM ct3
 


-- 56. Find the percentage difference between each
--     Customer's Sales and their Region's average Sales.


SELECT 
o.[Customer ID],

o.[Region],
sum(o.sales) as customerSales,


       (
              SELECT avg(totalsales) FROM 
              (
                     SELECT sum(sales) as totalsales FROM orders$  as c
                     where c.[Customer ID]=o.[Customer ID]
                     GROUP BY Region,[Customer ID]

              )as x
       )as RegionalAverage,

       (
              (sum(o.sales)- (
                     SELECT avg(totalsales) FROM 
              (
                     SELECT sum(sales) as totalsales FROM orders$  as c
                     where c.[Customer ID]=o.[Customer ID]
                     GROUP BY Region,[Customer ID]

              )as x           
              )
              
              )
                /               
             ( 
              
              SELECT avg(totalsales) FROM 
              (
                     SELECT sum(sales) as totalsales FROM orders$  as c
                     where c.[Customer ID]=o.[Customer ID]
                     GROUP BY Region,[Customer ID]

              )as x

              )

       ) *100 as  percentageDiff
       
FROM orders$ as o
GROUP BY o.[Customer ID],o.[Region],o.[Customer Name]






-- 57. Find each Customer's longest consecutive
--     ordering streak

with  ct1 as(
       SELECT [Customer ID],CAST([Order Date] as Date) as OrderDate FROM orders$
       GROUP BY [Customer ID],[Order Date]
),
numbered as (
       SELECT 
       [Customer ID],
        OrderDate,
       dateadd(day,-row_number() OVER(PARTITION BY [Customer ID] ORDER BY OrderDate),OrderDate
       ) as gap

       FROM ct1
       

),
streak as (
       SELECT 
       [Customer ID],
       gap,
       count(*) as StreakCount
        FROM numbered 
        GROUP BY
        [Customer ID],
        gap
)

SELECT 
[Customer ID],
max(StreakCount) as LongestStreak
FROM streak
GROUP BY [Customer ID]
ORDER BY  LongestStreak DESC



-- 58. Find the longest sequence of consecutive months
--     with increasing Sales.


with  ct1 as (
       SELECT DATEFROMPARTS(
              year([Order Date]),
              month([Order Date]),
              1
       ) as MonthDate,
       sum(sales) as MonthlySales 
       FROM orders$
       GROUP BY year([Order Date]),month([Order Date])
       
),
ct2 as (
       SELECT 
       MonthDate,
       MonthlySales,
       lag(MonthlySales) OVER(ORDER BY MonthDate) as prevmonthSales
       FROM ct1 

),
IsIncreasings as (
       SELECT
        *
       ,
       CASE 
              WHEN MonthlySales > prevmonthSales THEN  1
              ELSE  0
       END as Isencreasing
       FROM ct2 
       
)
,
Grouped as (
       SELECT 
        *,
       sum(
              CASE 
                     WHEN Isencreasing=0 THEN  1
                     ELSE  0
              END 
       ) OVER(ORDER BY MonthDate) as GropedID
       FROM IsIncreasings 
)

SELECT 
max(StreakCount) as LongestMonthIncreasingSales
FROM(
       SELECT 
       GropedID,
       count(*) as StreakCount
       FROM  Grouped
       where Isencreasing=1
       GROUP BY GropedID
       
)as x ;



-- 59. Restart the running Sales total whenever
--     a negative-Profit transaction occurs.


with ct1 as(
       SELECT 
       
       [Customer ID],
       [Order Date],
       Sales,
       Profit,
       sum(
              CASE 
                     WHEN profit<0 THEN  1
                     ELSE  0
              END
       ) OVER(
              PARTITION BY [Customer ID] ORDER BY [Order Date] ROWS UNBOUNDED PRECEDING
       ) as gap

        FROM Orders$

),
ct2 as (
       SELECT 
       [Customer ID],
       [Order Date],
       Sales,
       profit,
       gap,
       sum(sales) OVER(
              PARTITION BY [Customer ID],gap ORDER BY [Order Date] ROWS UNBOUNDED PRECEDING
       )as negative_profit_restart_runningtotal
       
       
        FROM ct1
)
SELECT
[Customer ID]
Sales,
profit,
negative_profit_restart_runningtotal
FROM
ct2








-- 60. Identify Customers whose Sales increased for
--     3 consecutive orders and then dropped.

with ct1 as (
       SELECT [Customer IDsales,
       lag(sales,1) OVER(PARTITION BY  [Customer ID] ORDER BY [order Date]) as prev1,
       lag(sales,2) OVER(PARTITION BY  [Customer ID] ORDER BY [order Date]) as prev2,
       lag(sales,3) OVER(PARTITION BY  [Customer ID] ORDER BY [order Date]) as prev3

       FROM Orders$
       
)
SELECT DISTINCT [Customer ID],[Customer Name]  FROM ct1
WHERE sales<prev1
and prev1>prev2
and prev2>prev3







-- ============================================================
-- REAL INDUSTRY-BASED SQL PRACTICE QUESTIONS
-- ============================================================


-- =========================
-- LEVEL 1: BUSINESS REPORTING
-- =========================


-- 1. Find the top 10 customers by total revenue
--    during the last 12 months.

WITH  ct1 as (
       
       SELECT 
       
       [Customer ID],
       year([Order Date]) as year,
       month([Order Date]) as Months,
       sum(sales) as MonthlySales
             
        FROM Orders$
        GROUP BY

        [Customer ID],
       year([Order Date]),
       month([Order Date])
         
)

SELECT top 10
[Customer ID]
year,
Months,
MonthlySales
 from ct1
 where year=2017
 ORDER BY MonthlySales DESC



 SELECT TOP 10
    [Customer ID]
    month([Order Date]) as months,
    SUM(Sales) AS Revenue
FROM Orders$
WHERE YEAR([Order Date]) = 2017
GROUP BY
    [Customer ID]
     month([Order Date])
ORDER BY Revenue DESC;



SELECT month([Order Date])
from Orders$

-- 2. Calculate monthly revenue and compare it
--    with the previous month's revenue.


 WITH ct1 AS
(
    SELECT 
        YEAR([Order Date]) AS year,
        MONTH([Order Date]) AS month,
        SUM(Sales) AS monthlysales
    FROM Orders$
    GROUP BY 
        YEAR([Order Date]),
        MONTH([Order Date])
),

ct2 AS
(
    SELECT
        year,
        month,
        monthlysales,
        LAG(monthlysales) OVER(
            ORDER BY year, month
        ) AS prevmonthsales
    FROM ct1

),

ct3 AS
(
    SELECT
        *,
        CASE
            WHEN monthlysales > prevmonthsales
                THEN 'Increased Sales'
            WHEN monthlysales < prevmonthsales
                THEN 'Decreased Sales'
            WHEN monthlysales = prevmonthsales
                THEN 'No Change'
        END AS grop
    FROM ct2
),
ct4 as (
       SELECT
    SUM(CASE 
            WHEN grop = 'Increased Sales' THEN 1 
            ELSE 0 
        END) AS IncreasedSales,

    SUM(CASE 
            WHEN grop = 'Decreased Sales' THEN 1 
            ELSE 0 
        END) AS DecreasedSales
FROM ct3
WHERE prevmonthsales IS NOT NULL
)

SELECT * FROM ct4


-- 3. Calculate the month-over-month (MoM)
--    revenue growth percentage.


WITH ct1 as (

       SELECT 
       year([Order Date]) as year,
       month([Order Date]) as month,
       round(sum(sales),2) as MonthlySales       
       
        FROM Orders$
       GROUP BY year([Order Date]),month([Order Date])
       

),
ct2 as (
       SELECT *,
       lag(MonthlySales) OVER(
                ORDER BY year,month
       ) as prevsales
       
        FROM ct1

),

ct3 as(
       SELECT 
       *,
       round((MonthlySales-prevsales),2)/round(prevsales,2)*100 as contri
       
        FROM ct2

)

SELECT year,month,MonthlySales,prevsales,round(contri,2) FROM ct3




-- 4. Calculate the average order value (AOV)
--    for each customer segment.


SELECT 

Segment,
count(DISTINCT [Order ID]) as totalorder,
sum(sales)/count(DISTINCT [Order ID])  as AOV
 FROM Orders$
 GROUP BY Segment
 ORDER BY AOV DESC


-- 5. Find the top 5 products by revenue
--    within each product category.

with ct1 as (

       SELECT 
       [Product ID],
       [Product Name],
       [Category],
       sum(sales)as revanue 
       
        FROM Orders$
       GROUP BY
       [Product ID],
       [Product Name],
       [Category]
),
ct2 as (
       SELECT *,
       dense_rank() OVER(PARTITION BY [Category] ORDER BY revanue desc)as rk
       
        FROM ct1

)

SELECT * FROM ct2
WHERE rk<=5
ORDER BY [Category],revanue DESC





-- =========================
-- LEVEL 2: BUSINESS ANALYSIS
-- =========================


-- 6. Identify customers who purchased in the
--    previous year but have not placed any
--    order in the current year.


with ct1 as (

       SELECT 
         DISTINCT[Customer IDyear([Order Date]) as OrderDate
       
        FROM Orders$
       GROUP BY [Customer IDyear([Order Date])
)
SELECT  
o.[Customer ID],

o.OrderDate
from ct1 as o
where not EXISTS(
       SELECT 
       1
       FROM ct1 as c
       WHERE c.[Customer ID]=o.[Customer ID]
       and c.OrderDate=o.OrderDate+1
)


 


-- 7. Find customers who placed at least 3 orders
--    within 6 months of their first purchase.




WITH PurhadesOrderDate as (

       SELECT  [Customer ID],min([Order Date]) as FirstOrderDate FROM  Orders$
       GROUP BY [Customer ID]
),
CustomerOrderDate  as (

       SELECT
       o.[Customer ID],
       f.FirstOrderDate,
       count(DISTINCT o.[Order ID])  as totalOrder
       FROM Orders$  as o
       JOIN PurhadesOrderDate as f
       on o.[Customer ID]=f.[Customer ID]
       and o.[Order Date]>=f.firstOrderDate
       and o.[Order Date]<dateadd(month,6,f.FirstOrderDate)
       GROUP BY
       o.[Customer ID],
       f.FirstOrderDate
)

SELECT 
[Customer ID],
FirstOrderDate,
totalorder
 FROM  CustomerOrderDate
 WHERE totalorder>=3
 ORDER BY totalorder ASC


 



-- 8. Calculate the percentage of customers who
--    made another purchase within 90 days
--    of their first order.



with FirstOrder as (

       SELECT 
       [Customer ID],
       min([Order Date]) as FirstOrderDate
        FROM Orders$
       GROUP BY [Customer ID]
),
CustomerOrder as (

       SELECT 
       f.[Customer ID],
       f.FirstOrderDate,
       count(DISTINCT o.[Order ID]) as OrderWithin90Day
       FROM firstOrder as f
       JOIN Orders$ as o
       ON o.[Customer ID]=f.[Customer ID]
       and o.[Order Date]>f.FirstOrderDate
       AND o.[Order Date]<=dateadd(day,90,f.FirstOrderDate)
       GROUP BY 
       f.[Customer ID],
       f.FirstOrderDate

),
RepeatingCustomerper as (

       SELECT 
       [Customer ID]
       FROM CustomerOrder
       WHERE OrderWithin90Day>=1
)

SELECT
count(*)*100.0/(

       SELECT count(

              DISTINCT [Customer ID]
       )
       FROM Orders$
)as RepeatingCustomerPerCon

FROM  RepeatingCustomerper
 


-- 9. Compare the average profit margin of orders
--    where Discount > 20% with orders where
--    Discount <= 20%.

SELECT 

       CASE 
              WHEN Discount>0.20 THEN   '+20 Discount'
              else ' <=20 Discount'
       END as discountbuk,
       avg(profit/nullif(Sales,0))*100.0 as profitmargin


FROM  orders$

GROUP BY
CASE 
       WHEN   Discount>0.20 THEN  '+20 Discount'
        else ' <=20 Discount'
END



-- 10. Find products whose return rate is
--     greater than 10%.


SELECT
    o.[Product ID],
    COUNT(DISTINCT o.[Order ID]) AS Total_Orders,
    COUNT(DISTINCT CASE
        WHEN r.[Order ID] IS NOT NULL THEN o.[Order ID]
    END) AS Returned_Orders,

    CAST(
        COUNT(DISTINCT CASE
            WHEN r.[Order ID] IS NOT NULL THEN o.[Order ID]
        END) * 100.0
        / COUNT(DISTINCT o.[Order ID])
        AS DECIMAL(10,2)
    ) AS Return_Rate

FROM Orders$ o

LEFT JOIN Returns$ r
    ON o.[Order ID] = r.[Order ID]

GROUP BY o.[Product ID]

HAVING
    COUNT(DISTINCT CASE
        WHEN r.[Order ID] IS NOT NULL THEN o.[Order ID]
    END) * 100.0
    / COUNT(DISTINCT o.[Order ID]) > 10;


