-- ==========================================
-- BASIC CTE QUESTIONS
-- ==========================================
-- 1. Total Sales by Customer
-- Create a CTE to calculate total sales for each customer.
-- Display the top 10 customers based on total sales.
WITH   ct1
AS     (SELECT   [Customer ID],
                 sum(Sales) AS totalSales
        FROM     Orders$
        GROUP BY [Customer ID]),
       ct2
AS     (SELECT *,
               DENSE_RANK() OVER (ORDER BY totalSales DESC) AS CustomerWiseSales
        FROM   ct1)
SELECT *
FROM   ct2
WHERE  CustomerWiseSales <= 10;

-- 2. Average Profit by Category
-- Create a CTE to calculate the average profit for each category.
-- Display only those categories where average profit > 100.
WITH   AvgProfit
AS     (SELECT   Category,
                 AVG(Profit) AS Average_Profit
        FROM     Orders$
        GROUP BY Category)
SELECT Category,
       Average_Profit
FROM   AvgProfit
WHERE  Average_Profit > 100;

-- 3. Customers with Multiple Orders
-- Create a CTE to count distinct orders for each customer.
-- Find customers who have placed more than 5 orders.
WITH   ct1
AS     (SELECT   DISTINCT [Customer ID],
                          count(DISTINCT [Order ID]) AS total_order
        FROM     Orders$
        GROUP BY [Customer ID]),
       ct2
AS     (SELECT *,
               DENSE_RANK() OVER (ORDER BY total_order ASC) AS top5
        FROM   ct1)
SELECT *
FROM   ct2
WHERE  top5 >= 5;

-- ==========================================
-- INTERMEDIATE CTE QUESTIONS
-- ==========================================
-- 4. Highest-Selling Category in Each Region
-- Create a CTE to calculate total sales by region and category.
-- Use a ranking function to find the highest-selling category
-- in each region.
WITH   ct1
AS     (SELECT   Region,
                 Category,
                 sum(Sales) AS total_sales
        FROM     Orders$
        GROUP BY Region, Category),
       ct2
AS     (SELECT *,
               dense_rank() OVER (PARTITION BY [Region] ORDER BY total_sales DESC) AS topsellingcategory
        FROM   ct1)
SELECT *
FROM   ct2
WHERE  topsellingcategory = 1;

-- 5. Customers with Above-Average Sales
-- Create a CTE to calculate total sales for each customer.
-- Find customers whose total sales are greater than
-- the average total sales of all customers.
USE TraningYa;


GO
WITH   ct1
AS     (SELECT   avg(Salary) AS aboveAvgSalary
        FROM     Employees
        GROUP BY EmployeeID),
       ct2
AS     (SELECT avg(Salary) AS OverAllAvgSalary
        FROM   Employees)
SELECT *
FROM   ct1 CROSS JOIN ct2
WHERE  aboveAvgSalary > OverAllAvgSalary;

-- 6. Category-Wise Profit Ranking
-- Create a CTE to calculate total profit by category and sub-category.
-- Rank sub-categories within each category based on total profit.
USE SUPER_SAMPLESTORE;


GO
WITH   ct1
AS     (SELECT   Category,
                 [Sub-Category],
                 sum(Profit) AS totalProfit
        FROM     Orders$
        GROUP BY Category, [Sub-Category]),
       ct2
AS     (SELECT *,
               DENSE_RANK() OVER (PARTITION BY [Category] ORDER BY totalProfit DESC) AS rk
        FROM   ct1)
SELECT *
FROM   ct2;



-- 7. Customers with Both Positive and Negative Profit
-- Create a CTE to calculate total profit for each customer.
-- Identify customers who have at least one order with positive profit
-- and at least one order with negative profit.



 with ct1 as (
        SELECT [Customer ID],
        sum([Profit]) as totalProfit, 
        max(
            CASE 
                WHEN Profit>0 THEN  1
                ELSE  0
            END
        ) as has_postive_profit,

        max(
            CASE 
                WHEN profit<0 THEN 1 
                ELSE 0
            END
        )as has_negative_profit 

        FROM Orders$
        GROUP BY [Customer ID] 

 )  
 SELECT totalProfit FROM ct1
 WHERE has_negative_profit=1
 and has_negative_profit=1

 
-- ==========================================
-- ADVANCED CTE QUESTIONS
-- ==========================================
-- 8. Running Sales Total by Region
-- Create a CTE to calculate daily sales for each region.
-- Use a window function to calculate cumulative sales
-- for each region based on order date.




 


 
 
WITH RegionWiseDailySales as(
    SELECT Region,
    [Order Date],
    sum(Sales) as DaliySales
    FROM  Orders$
    GROUP BY Region,[Order Date]
),
commulativesum as (
    SELECT Region,
    [Order Date],
    DaliySales,

    sum(DaliySales) OVER(
        PARTITION BY  [Region] 
        ORDER BY [Order Date] 
    ) RunningSum FROM  RegionWiseDailySales


)
SELECT Region,[Order Date],DaliySales,RunningSum FROM commulativesum


-- 9. Top 3 Customers in Each Segment
-- Create a CTE to calculate total sales for each customer
-- within each segment.
-- Use DENSE_RANK() to find the top 3 customers in each segment.

WITH ct1
AS     (SELECT   Segment,
                 [Customer ID],
                 sum(Sales) AS totalsales
        FROM     Orders$
        GROUP BY Segment, [Customer ID]),
       rankedCustomerBasedonSales
AS     (SELECT *,
               dense_rank() OVER (PARTITION BY [Segment] ORDER BY totalsales DESC) AS rnk
        FROM   ct1)
SELECT *
FROM   rankedCustomerBasedonSales
WHERE  rnk <= 3;





-- 10. Customer Sales Growth Between First and Last Order
-- Create a CTE to identify each customer's first and last order dates.
-- Find the sales amount on the first order and the last order.
-- Display the customer ID, first order date, last order date,
-- first order sales, and last order sales.



WITH CustomerOrders AS (
    -- Step 1: Assign a row number to each order
    -- for every customer based on the order date

    SELECT
        [Customer ID],
        [Order Date],
        Sales,

        ROW_NUMBER() OVER (
            PARTITION BY [Customer ID]
            ORDER BY [Order Date], [Order ID]
        ) AS First_Order_Rank,

        ROW_NUMBER() OVER (
            PARTITION BY [Customer ID]
            ORDER BY [Order Date] DESC, [Order ID] DESC
        ) AS Last_Order_Rank

    FROM Orders$
),
FirstLastOrders AS (
    -- Step 2: Extract the first and last order details
    SELECT
        [Customer ID],

        MAX(CASE
            WHEN First_Order_Rank = 1
            THEN [Order Date]
        END) AS First_Order_Date,

        MAX(CASE
            WHEN Last_Order_Rank = 1
            THEN [Order Date]
        END) AS Last_Order_Date,

        MAX(CASE
            WHEN First_Order_Rank = 1
            THEN Sales
        END) AS First_Order_Sales,

        MAX(CASE
            WHEN Last_Order_Rank = 1
            THEN Sales
        END) AS Last_Order_Sales

    FROM CustomerOrders
    GROUP BY [Customer ID]
)
-- Step 3: Display the final result
SELECT
    [Customer ID],
    First_Order_Date,
    Last_Order_Date,
    First_Order_Sales,
    Last_Order_Sales,
    ROUND(
        (Last_Order_Sales - First_Order_Sales)
        / NULLIF(First_Order_Sales, 0) * 100,
        2
    ) AS Growth_Percentage
FROM FirstLastOrders
ORDER BY [Customer ID]

 


-- 10. Customer Sales Growth Between First and Last Order
-- Create a CTE to identify each customer's first and last order dates.
-- Find the sales amount on the first order and the last order.
-- Display the customer ID, first order date, last order date,
-- first order sales, and last order sales.


WITH ct1 as(
    SELECT [Customer ID],
    [Order Date],
    Sales,
    row_number() OVER(PARTITION BY [Customer ID] ORDER BY [Order Date],[Order ID]) as firstorder,
    row_number() OVER(PARTITION BY [Customer ID] ORDER BY [Order Date] DESC,[Order ID] DESC) as LastOrder
    FROM  Orders$
    
),
ct2 as (
    SELECT [Customer ID],
    max(CASE 
        WHEN firstorder=1 THEN  
        [Order Date]          
    END) as FirtOrderDate,

    max(
        CASE 
            WHEN LastOrder=1 THEN  
            [Order Date]
        END
    )as LastOrderDate,

    max(
        CASE 
            WHEN firstorder=1 THEN  
            Sales
        END
    )as FirtsOrderSales,
    
    max(

        CASE 
            WHEN LastOrder=1 THEN  
            Sales
        END
    )as lastOrderSales

    FROM ct1
    GROUP BY [Customer ID]
)
SELECT
 [Customer ID],
    FirtOrderDate,
    LastOrderDate,
    FirtsOrderSales,
        lastOrderSales,
    ROUND(lastOrderSales-FirtsOrderSales,2) as GrowthSales,
    ROUND(
        (lastOrderSales-FirtsOrderSales)/
        nullif(FirtsOrderSales,0)*100,2
    )as GrthPercentage

FROM ct2





-- ==========================================
-- QUESTION 12: HIGHEST AVERAGE PROFIT BY CATEGORY
-- ==========================================

-- Create a CTE to calculate the average profit
-- for each category.
-- Find the category with the highest average profit.

    WITH ct1 AS (
    SELECT
        Category,
        avg(Profit) as avgprofit
    from Orders$
    GROUP BY Category
    )
    SELECT top 1 
        Category,
        avgprofit
    FROM  ct1
    ORDER BY avgprofit DESC;


 
 

-- ==========================================
-- QUESTION 13: TOTAL ORDERS BY REGION
-- ==========================================

-- Create a CTE to calculate the total number
-- of distinct orders in each region.
-- Display regions with more than 500 orders.

    WITH ct1 
    AS(
        SELECT Region,
        count(DISTINCT [Order ID]) as totalOrders 
        FROM Orders$
        GROUP BY Region
    )
    SELECT * FROM ct1
    WHERE totalOrders>500


-- ==========================================
-- QUESTION 14: NEGATIVE PROFIT SUB-CATEGORIES
-- ==========================================

-- Create a CTE to calculate total profit
-- for each sub-category.
-- Find sub-categories with negative total profit.

WITH ct1
AS(
    SELECT [Sub-Category],
    sum(Profit) as totalprofit
    FROM Orders$
    GROUP BY [Sub-Category]
)
SELECT *from ct1
WHERE totalprofit<0

-- ==========================================
-- QUESTION 15: HIGHEST-SALES CUSTOMER IN EACH REGION
-- ==========================================

-- Create a CTE to calculate total sales for
-- each customer within each region.
-- Find the customer with the highest sales
-- in each region.

WITH ct1
AS(
    SELECT DISTINCT Region,
    [Customer ID],
    sum(Sales)as totalsales FROM Orders$
    GROUP by Region,[Customer ID]
    
),
ct2 
AS(
    SELECT *,dense_rank() OVER(PARTITION BY Region ORDER BY totalsales DESC) as rk FROM ct1
    
)
SELECT *from ct2
WHERE rk=1



-- ==========================================
-- QUESTION 16: ABOVE-AVERAGE SUB-CATEGORY PROFIT
-- ==========================================

-- Create a CTE to calculate total profit
-- for each sub-category.
-- Find sub-categories whose total profit is
-- greater than the average total profit
-- of all sub-categories.

WITH ct1
AS(
    SELECT [Sub-Category],
    sum(Profit) as totalprofit
    from Orders$
    GROUP BY [Sub-Category]
),
ct2 
as ( 

    SELECT avg(totalprofit) as overallavg FROM ct1
     
)
SELECT *
 from  ct1
CROSS JOIN ct2
where totalprofit>overallavg



-- ==========================================
-- QUESTION 17: CUSTOMERS WITH ORDERS IN MULTIPLE REGIONS
-- ==========================================
-- Create a CTE to count the distinct regions
-- in which each customer has placed orders.
-- Find customers who have ordered from
-- more than one region.

WITH ct1
AS(
    SELECT [Customer ID],
    COUNT(DISTINCT  Region) as countregion FROM Orders$
    GROUP BY [Customer ID]
)
SELECT * FROM ct1
WHERE countregion>1


-- ==========================================
-- QUESTION 18: MONTHLY SALES AND MONTHLY RANKING
-- ==========================================

-- Create a CTE to calculate total sales
-- for each region and month.
-- Rank each region's monthly sales from
-- highest to lowest using a window function.

WITH  ct1
AS(
    SELECT Region,YEAR([Order Date]) as year,MONTH([Order Date]) as MONTHS,sum(Sales) as totalsales FROM Orders$
    GROUP BY Region,year([Order Date]),MONTH([Order Date]) 
),
ct2
AS(
    SELECT *,dense_rank() OVER(PARTITION BY [Region] ORDER BY totalsales DESC) as rk FROM ct1

)
SELECT * FROM ct2



-- ==========================================
-- QUESTION 19: FIRST PROFITABLE ORDER OF EACH CUSTOMER
-- ==========================================

-- Create a CTE to identify each customer's
-- first order that generated positive profit.
-- Use a window function to find the earliest
-- profitable order for each customer.

WITH ct1
AS(
    SELECT [Customer ID],
    [Order ID],
    sum(Profit) as totalprofit FROM Orders$
    GROUP BY [Customer ID],[Order ID]
    HAVING sum(Profit)>0
),
ct2
AS(
    SELECT *,row_number() OVER(PARTITION BY [Customer ID] ORDER BY [Order ID])as rn FROM ct1
        
)
SELECT * FROM ct2
WHERE rn=1

 

 


-- ==========================================
-- QUESTION 20: REGION-WISE SALES CONTRIBUTION
-- ==========================================

-- Create a CTE to calculate total sales
-- for each region.
-- Calculate each region's percentage contribution
-- to the overall sales.
-- Display the region, total sales, and
-- sales contribution percentage


WITH ct1
AS(
    SELECT Region,
    sum(Sales) as regionsales FROM Orders$
    GROUP BY Region
),
ct2 
AS(
    SELECT sum(Sales) as totalsales  FROM Orders$

)
SELECT Region,
ROUND(regionsales,2) as regionalsales,
ROUND(totalsales,2) as totalsales,
ROUND(
        ct1.regionsales * 100.0 / NULLIF(ct2.totalsales, 0),
        2) as contribution FROM ct1
CROSS JOIN ct2






-- 1. Customer Sales Analysis
-- Create a CTE to calculate total sales for each customer.
-- Find customers whose total sales exceed 50,000.

WITH ct1 
AS  (
    SELECT DISTINCT [Customer ID],
    sum(Sales) as totalsales FROM Orders$
    GROUP BY [Customer ID]
)
SELECT * FROM ct1
WHERE totalsales>50000


-- 2. Category Profit Analysis
-- Create a CTE to calculate total profit for each category.
-- Find categories with negative total profit.

WITH ct1
AS (
    SELECT Category,sum(Profit ) as catprofit FROM Orders$
    GROUP BY Category
)
SELECT *FROM ct1 
WHERE catprofit<0




------- 