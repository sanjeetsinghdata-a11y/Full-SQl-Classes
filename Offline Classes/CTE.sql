use TraningYa
go  
use SUPER_SAMPLESTORE


CREATE Table #locala(id int ,name VARCHAR(20))



--find the  depts whose  avg  salary  is grather than overall avg salary

use TraningYa
GO

    WITH ct1 as (
        SELECT  Department,avg(Salary) as deptavgsalary FROM Employees
        
        GROUP BY Department
    ),
    ct2 as (
        SELECT avg(Salary) as overallsalary from Employees
        )

    SELECT * FROM ct1 CROSS JOIN ct2
    where deptavgsalary>overallsalary




--- find the highest   selling product in each region

use SUPER_SAMPLESTORE
GO

    WITH product as(
        SELECT Region,
        [Product ID],
        sum(Sales)as total_sales
        FROM Orders$
        GROUP BY Region,[Product ID]
    ),
    ct2 as (
        SELECT *, dense_rank() OVER(PARTITION BY Region ORDER BY total_sales desc) as highestsellingproduct FROM product
    )
    SELECT * FROM ct2
    where highestsellingproduct=1
    






use TraningYa
go


--find the  depts whose  avg  salary  is grather than overall avg salary
WITH ct1 as (SELECT 
                Department,avg(Salary) as deptavgSalary from Employees
                GROUP BY Department
            ),
ct2 as (SELECT avg(Salary) as overallavg FROM Employees )

SELECT * FROM ct1 
CROSS JOIN ct2 
where deptavgSalary>overallavg


----  top 5 customers in each regino who have not returned any order
use SUPER_SAMPLESTORE


        WITH ct1 as(SELECT [Customer ID],Region,sum(Sales) as total_Sales from Orders$ as O
                    LEFT JOIN Returns$ as r
                    on o.[Order ID]=r.[Order ID]
                    where r.[Order ID] is NULL
                    GROUP BY Region,[Customer ID]
                    ),

        ct2 as (SELECT *,dense_rank() OVER(PARTITION BY Region ORDER BY total_sales DESC) as top_5 from ct1
                    
                    )
        SELECT * FROM ct2
        where top_5<=5


--- find the customers who have placed highest number of order in each  segment
         WITH  CustomerOrder as (

            SELECT [Customer ID],
            Segment,            
            count( DISTINCT [Order ID]) as total_orders FROM Orders$
            GROUP BY Segment,[Customer ID]
         ) ,
        
        RankedCustomersOrders as (SELECT *,
        row_number() OVER(PARTITION BY [Segment] ORDER BY total_orders DESC) as RankedOrder  FROM CustomerOrder)
        
        SELECT *from  RankedCustomersOrders
        where RankedOrder=1


 
         
         
--- find the highest   selling product in each region

    WITH products as (
        SELECT Region,[Product ID],sum(Sales) as highestsales from Orders$
        GROUP BY [Product ID],Region
    ),

    highestsellingproduct as(SELECT *,dense_rank()  OVER(PARTITION BY [Region] ORDER BY highestsales DESC) as highest
                             FROM
                 products)
    
    SELECT * FROM highestsellingproduct
    where highest=1



--- find the order that are not returned---

use SUPER_SAMPLESTORE
GO
WITH ct1 as(
    SELECT o.[Order ID] FROM Orders$ as O
    LEFT  JOIN Returns$ as R
    on o.[Order ID]=r.[Order ID]
    where r.[Order ID] is null  
    
)
SELECT * FROM ct1





-- 3. Regional Order Analysis
-- Create a CTE to count distinct orders for each region.
-- Find the region with the highest order count.
 
WITH ct1

AS(
    SELECT Region,
    count(DISTINCT [Order ID]) as totalorder
    FROM Orders$
    GROUP BY Region
),
ct2 AS(
    SELECT *,row_number() OVER( ORDER BY totalorder DESC
    ) as rk FROM ct1
     
)
SELECT * FROM ct2
WHERE rk=1
ORDER BY totalorder DESC



-- 4. Product Sales Filter
-- Create a CTE to calculate total sales for each product.
-- Find the top 10 products by total sales.

WITH ct1
AS(
    SELECT [Product ID],
    sum(Sales) as totalsales FROM Orders$
    GROUP BY [Product ID]   
),
ct2 AS(
    SELECT *,ROW_NUMBER() OVER(ORDER BY totalsales desc) as top10product FROM ct1
)
SELECT top 10 * FROM ct2


-- 5. Customer Profitability
-- Create a CTE to calculate total sales and total profit
-- for each customer.
-- Find customers whose profit margin is greater than 20%.

WITH ct1
AS(
    SELECT DISTINCT [Customer ID],sum(Sales) as totalsales ,
    
    sum(Profit) as totalprofit  FROM Orders$
    GROUP BY [Customer ID]
)
SELECT 
   [Customer ID],
    totalsales,
    totalprofit,
    totalprofit/totalsales*100 as profitmargin

FROM ct1
WHERE totalprofit/totalsales*100>20
ORDER BY profitmargin ASC

-- 6. Monthly Sales Analysis
-- Create a CTE to calculate total sales for each month.
-- Find months where sales exceeded 100,000.

WITH ct1
AS(
    SELECT year([Order Date]) as YEAR , MONTH([Order Date]) as MONTH,
    sum(Sales)as totalsales
    FROM Orders$
    GROUP BY  YEAR([Order Date]),MONTH([Order Date])
     
)
SELECT  [YEAR],[MONTH],totalsales FROM ct1
WHERE totalsales>100000
ORDER BY [MONTH],[YEAR]

-- 7. Sub-Category Performance
-- Create a CTE to calculate average sales for each sub-category.
-- Find sub-categories whose average sales are above
-- the overall average sales of all sub-categories.

WITH ct1
AS(
    SELECT [Sub-Category],
    avg(sales) as avgsales
    FROM Orders$ 
    GROUP BY [Sub-Category]
),
ct2 
AS(
    SELECT avg(Sales) as overallavg FROM  Orders$
)
SELECT * FROM ct1 CROSS JOIN
ct2
WHERE avgsales>overallavg

-- 8. Customer Order Frequency
-- Create a CTE to count distinct orders for each customer.
-- Find customers who placed more than 10 orders.

WITH ct1
AS(
    SELECT [Customer ID],
    COUNT(DISTINCT [Order ID]) as totalorders FROM Orders$
    GROUP BY [Customer ID]
)
SELECT *from ct1
where totalorders>=10
ORDER BY totalorders ASC
 


-- 10. Discount Analysis
-- Create a CTE to calculate the average discount for each category.
-- Find categories with an average discount greater than 15%.

WITH ct1
AS(
    SELECT Category,
    avg(Discount)*100 as totaldiscount
    FROM Orders$
    GROUP BY Category
)
SELECT * FROM ct1
WHERE totaldiscount>15



-- 11. Regional Sales Ranking
-- Create a CTE to calculate monthly sales for each region.
-- Use a window function to rank months by sales
-- within each region.
-- Return the top 3 months per region.

WITH ct1
AS(
    SELECT Region, MONTH([Order Date]) as month,
    sum(Sales) as totalsales
    FROM Orders$
    GROUP BY month([Order Date]),Region
),
ct2 
AS(
    SELECT *, dense_rank() OVER(
        PARTITION BY [Region]
        ORDER BY totalsales DESC
    )as rk FROM ct1
)
SELECT * FROM ct2
WHERE rk<=3


-- 12. Customer's First Order
-- Create a CTE to identify the first order date for each customer.
-- Find customers whose first order was placed in the year 2014.

WITH ct1
AS(
    SELECT [Customer ID], min([Order Date])  as firstorderdate FROM Orders$
    GROUP BY [Customer ID]
)
SELECT * FROM ct1
WHERE year(firstorderdate)=2014


-- 13. Customer Retention
-- Create a CTE to find each customer's first and last order dates.
-- Find customers who placed orders in at least two different years.

WITH ct1
AS(
    SELECT   [Customer ID],

    min([Order Date]) as firstorderdate,
    max([Order Date])as lastorderdate
    ,
    count( DISTINCT YEAR([Order Date])) as differentyear
    FROM Orders$
    GROUP BY [Customer ID]
)
SELECT * FROM ct1
where differentyear>=2
ORDER BY differentyear ASC



-- 14. Category Sales Contribution
-- Create a CTE to calculate total sales for each category.
-- Calculate each category's percentage contribution
-- to overall sales.
-- Return categories contributing more than 25%.
WITH ct1
AS(
   SELECT Category, sum(Sales) as catsales
   FROM Orders$
   GROUP BY Category
),
ct2
AS(
    SELECT  sum(catsales) as totalsales FROM ct1
)
SELECT 
Category,
catsales,
totalsales,
catsales/totalsales*100 as contribution  from ct1 CROSS JOIN ct2
WHERE catsales/totalsales*100>25




-- 15. Profitable Customer Ranking
-- Create a CTE to calculate total profit for each customer.
-- Use a window function to rank customers within each region
-- by total profit.
-- Return the top 3 customers per region.

WITH ct1
AS(
    SELECT Region,[Customer ID],
    sum(Profit) as totalprofit FROM Orders$
    GROUP BY [Customer ID],Region
),
ct2 as (
    SELECT *,DENSE_RANK() OVER(
        PARTITION BY [Region] ORDER BY totalprofit DESC
    )  as rk FROM ct1
    
)

SELECT  * FROM ct2
where rk<=3

-- 16. Monthly Sales Growth
-- Create a CTE to calculate total sales for each month.
-- Use LAG() to calculate the previous month's sales.
-- Calculate the month-over-month growth percentage.

with ct1
AS(
    SELECT YEAR([Order Date]) as year_order,
    MONTH([Order Date]) as month_order,
    sum(sales) as monthlysales
    FROM Orders$
    GROUP BY MONTH([Order Date]),year([Order Date]) 
    
),
ct2 AS(
    SELECT *,
    lag(monthlysales) OVER(ORDER BY year_order,month_order ) as prevmonthsales
     FROM ct1
    
)
SELECT 
    year_order,month_order,
    monthlysales as months,
    (monthlysales-prevmonthsales)/nullif(prevmonthsales,2)*100 as PercentageContribution
FROM ct2






-- 17. Repeat Customers
-- Create a CTE to count distinct orders for each customer.
-- Identify customers who placed more than one order.
-- Calculate their total sales.

WITH ct1 
AS(
    SELECT [Customer ID],sum(Sales)as totalsales,
    count(DISTINCT [Order ID]) as totalorders
    FROM Orders$
    GROUP BY [Customer ID]
)
SELECT *FROM ct1
WHERE totalorders>1
ORDER BY totalorders ASC


-- 18. Sub-Category Rank Within Category
-- Create a CTE to calculate total profit for each category
-- and sub-category.
-- Rank sub-categories by profit within each category
-- using a window function.
-- Return the highest-profit sub-category from each category.


WITH ct1
AS(

    SELECT Category,
    [Sub-Category],
    sum(Profit)as totalprofit FROM Orders$ 
    GROUP BY Category,[Sub-Category]
) ,
ct2 
AS(

    SELECT *,DENSE_RANK()
    OVER(
        PARTITION BY [Category] ORDER BY totalprofit DESC
    ) as rk FROM ct1
    
) 
SELECT * FROM ct2



-- 19. Loss-Making Products
-- Create a CTE to calculate total sales and total profit
-- for each product.
-- Find products that generated positive sales but negative profit.
-- Return the top 10 products with the largest losses.


WITH ct1
AS(
    SELECT [Product ID],
    sum(Sales)as totalsales,
    sum(Profit) as totalprofit,
    sum(Profit)/sum(Sales)*100 as profitmargin 
    FROM Orders$
    GROUP BY [Product ID]
)
SELECT top 10 *from ct1
where totalsales>0
and totalprofit<0
ORDER BY totalprofit DESC





-- 20. Customer Purchase Gap
-- Create a CTE to identify each customer's order dates.
-- Use LAG() to calculate the gap in days between consecutive orders.
-- Find customers whose average order gap exceeds 30 days.


WITH ct1 AS (
    SELECT
        [Customer ID],
        [Order Date] AS order_date
    FROM Orders$
    GROUP BY
        [Customer ID],
        [Order Date]
),
ct2 AS (
    SELECT
        *,
        LAG(order_date) OVER (
            PARTITION BY [Customer ID]
            ORDER BY order_date
        ) AS previous_date
    FROM ct1
),
ct3 AS (
    SELECT
        [Customer ID],
        DATEDIFF(DAY, previous_date, order_date) AS gap_days
    FROM ct2
    WHERE previous_date IS NOT NULL
)
SELECT
    [Customer ID],
    AVG(gap_days * 1.0) AS average_gap_days
FROM ct3
GROUP BY [Customer ID]
HAVING AVG(gap_days * 1.0) > 30
ORDER BY average_gap_days DESC;




use SUPER_SAMPLESTORE
GO


----- find the monthly sales usign cte

with ct1 as(
    SELECT 
     YEAR([Order Date]) as years,MONTH([Order Date]) as months , sum(Sales ) as totalsales FROM Orders$
     GROUP BY  YEAR([Order Date]) ,MONTH([Order Date]) 


)
SELECT  *from ct1
ORDER BY years,months  




-----running total of 



with ct1 as(
    SELECT 
     YEAR([Order Date]) as years,MONTH([Order Date]) as months , sum(Sales ) as totalsales FROM Orders$
     GROUP BY  YEAR([Order Date]) ,MONTH([Order Date]) 

),
ct2 as (
    SELECT years,months, sum(totalsales) OVER(ORDER BY years,months rows BETWEEN UNBOUNDED PRECEDING and CURRENT row ) as runnnigtotal  from ct1

)
SELECT  *from ct2
ORDER BY years,months



---- find year over year growht


 use SUPER_SAMPLESTORE

 GO

with  ct1 as(
    SELECT Region, YEAR([Order Date]) as years,  sum(sales) as totalsales from Orders$
    GROUP BY YEAR([Order Date]),Region
    
),
ct2 as (
    SELECT *, LAG(years) OVER( PARTITION BY Region ORDER BY totalsales ) as previ FROM ct1

)
SELECT Region,years,ROUND(totalsales-previ,2) as growth from ct2

ORDER BY years
