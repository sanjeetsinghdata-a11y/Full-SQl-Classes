
use TraningYa

use  SUPER_SAMPLESTORE

----1 Assign a row  to each order within each  region sorted by  desc sales---

SELECT
row_number() over(ORDER BY Salary  Desc) as EmplSalary,*
from selfjoin

----2 Rank Customers within each  regioin by total sales----

 SELECT Region,[Customer ID] ,
sum(Sales) as total_sales,
rank() OVER(PARTITION BY Region ORDER BY sum(Sales)) FROM Orders$
GROUP BY region,[Customer ID]

----3 find the Dense rank  of each  product by profit in each category----

SELECT Category, [Product ID], sum(Profit),
dense_rank() OVER(PARTITION BY category ORDER by sum(Profit) DESC) as prodid
from Orders$
GROUP BY Category,[Product ID]

----4 for each , find the next order date by the  same Customer----

SELECT DISTINCT [Customer ID],[Order ID],[Order Date],
lead([Order Date]) OVER(PARTITION BY [Customer ID]   ORDER by [order Date]) as nextorderdate FROM
Orders$



----5 for each  order, find the previous order profit by the same customer---

SELECT [Customer ID],[Order Date],sum(Profit) as total_profit
,lag(sum(Profit))  over (PARTITION BY [Customer ID] ORDER BY [order Date] ) as preProfit
from Orders$
GROUP BY [Customer ID],[Order Date]





USE SUPER_SAMPLESTORE
--- 6 find the dense rank of  each product by profit in each category


 SELECT 
    Category,
    [Product ID],
    SUM(Profit) AS Total_Profit,
    DENSE_RANK() OVER (
        PARTITION BY Category
        ORDER BY SUM(Profit) DESC
    ) AS Category_Profit_Rank
FROM Orders$
GROUP BY Category, [Product ID];




--- 7 for each order, find the next order date by  the same customer

 
SELECT 
    [Customer ID],
    [Order Date],
    [Order ID]
    ,
     
    LEAD([Order Date]) OVER (
        PARTITION BY [Customer ID]
        ORDER BY [Order Date] ASC
    ) AS Next_Order_Date
FROM Orders$;

--- 8 for each 0rder, find the previous order's profit by the  same customer

SELECT 
    [Customer ID],
    [Order Date],
    [Order ID],
    SUM(Profit) AS Total_Profit,
    LAG(SUM(Profit)) OVER (
        PARTITION BY [Customer ID]
        ORDER BY [Order Date]
    ) AS Previous_Order_Profit
FROM Orders$
GROUP BY 
    [Customer ID],
    [Order ID],
    [Order Date];


---- 9 find the running total of sales for each region by order date


SELECT Region,[Order Date],
sum(Sales) as DailySales,
sum(sum(Sales)) OVER (PARTITION BY Region ORDER BY [Order Date] rows BETWEEN UNBOUNDED PRECEDING and CURRENT ROW) as runningSum
FROM Orders$
GROUP BY Region,[Order Date]
ORDER BY Region,[Order Date]


--- 10 find the cummulative average profit for each sub category based on order date

SELECT [Sub-Category],[Order Date],
sum(Profit) as total_profit ,
avg(sum(Profit)) OVER(PARTITION BY [Sub-Category] ORDER BY [Order Date] rows BETWEEN UNBOUNDED PRECEDING and  CURRENT ROW) as CummulativeAvg
 FROM orders$
 GROUP by [Sub-Category],[Order Date]
ORDER BY [Sub-Category],[Order Date]

--- 11 find the diff between each order sales and previous  order sales for  each  customer


SELECT [Order ID],[Order Date],
sum(Sales)as total_sales,
sum(Sales) -lag(sum(Sales))  OVER(PARTITION BY [Customer ID] ORDER BY [Order Date]) as Diff_between_prevOrdrandCurrentOrderSales
from Orders$
GROUP by [Customer ID],
    [Order Date],
    [Order ID]
    ORDER BY [Customer ID],
    [Order Date]
    



SELECT * FROM Orders$

SELECT Region,
sum(Sales) as total_sales,
CUME_DIST() OVER (PARTITION BY [Region] ORDER BY sum(Sales) asc)  as cummulativePre 
FROM Orders$
GROUP BY Region


-- category wise total sales----

SELECT Category,Sales,
sum(Sales) OVER(PARTITION BY [Category] ORDER BY Sum(Sales)  asc)  as CategoryWiseSales
FROM Orders$
GROUP BY [Category]


use SUPER_SAMPLESTORE

SELECT * FROM Orders$









---- find the dense rank of each profit in each category

SELECT Category,
sum(Profit) as total_profit,
dense_rank() OVER( PARTITION BY Category ORDER BY sum(Profit) DESC) as categorywisetotalSales
FROM Orders$
GROUP BY Category,[Product ID]


-- calcule the running total of sales for each regio by order date

SELECT Region,Sales,
sum(Sales) OVER(PARTITION BY [Region] ORDER BY [Order Date] rows BETWEEN UNBOUNDED PRECEDING and CURRENT row ) as rnn FROM Orders$




--- calculate the cummulative avg profit for each sub -category  based on the order date

SELECT [Sub-Category],Profit ,
avg(Profit) OVER(PARTITION BY  [Sub-Category] ORDER BY [Order Date] rows BETWEEN UNBOUNDED PRECEDING and CURRENT  row) as movinf_avg
FROM Orders$



-- lead and lag

SELECT DISTINCT [Customer Name] ,
lead([Customer Name]) OVER(ORDER BY [Customer ID] )as lead FROM Orders$

-- find the previous value from the current row

use TraningYa
GO

SELECT *,lag(EmployeeName) OVER(ORDER BY [EmployeeID]) as lag FROM Employees



--- first employee to join organization


SELECT *,
first_value([EmployeeID]) OVER(ORDER BY [EmployeeID])as FIRST FROM Employees


--dept wise  first employee to  join department

SELECT Department,EmployeeName,EmployeeID,
first_value([EmployeeName]) OVER(PARTITION BY [Department] ORDER BY [EmployeeID] rows BETWEEN UNBOUNDED PRECEDING and  CURRENT row) as firstemp
FROM  Employees

--last emloyee to join the organization

SELECT *,
last_value(EmployeeName ) 
over( ORDER BY [EmployeeID] rows BETWEEN UNBOUNDED PRECEDING and UNBOUNDED FOLLOWING) as last_value FROM Employees 


-- last employee who joined department in last 


SELECT *,
last_value(EmployeeName ) 
over( PARTITION BY [Department] ORDER BY [EmployeeID] rows BETWEEN UNBOUNDED PRECEDING and UNBOUNDED FOLLOWING) as last_value FROM Employees




--- ntile 

SELECT * ,
ntile(3) OVER(ORDER BY Salary DESC) as Bucket,
    case WHEN ntile(3) OVER(ORDER BY Salary DESC)=1 then 'high salary'
        WHEN ntile(3) OVER(ORDER BY Salary DESC)=2 THEN 'mediumn salary'
        WHEN   ntile(3) OVER(ORDER BY Salary DESC)=3 THEN 'low  salary'
    END salary_bucket
FROM  Employees
 SELECT * FROM 



---  find the first product sold by order date in each  region

use SUPER_SAMPLESTORE
GO

SELECT Region,[Order Date],[Product Name],
first_value([Product ID]) OVER(PARTITION BY [Region] ORDER BY [Order Date]  ) as firts_productSold
FROM Orders$



-- find the  last product sold in each category

 
SELECT Category,[Product Name],
last_value([Product Name]) OVER(ORDER BY [Order Date] rows BETWEEN UNBOUNDED PRECEDING and UNBOUNDED FOLLOWING)as lastSold_productBycat
FROM Orders$
GROUP BY Category 
 

--3. find the next order date by the same customer.

SELECT [Customer Name],[Order Date],[Order ID],
lead([Order ID]) OVER(PARTITION BY [Customer ID] ORDER BY [Order Date]) as nextOrder
FROM Orders$



--4. Find the previous order's profit by the same customer. 


SELECT  [Customer Name],[Order Date], [Order ID],
lag([Order ID]) over(PARTITION BY [Customer Name] ORDER BY [Order Date]) as previOrder
    FROM Orders$
    GROUP BY [Customer Name],[Order ID],[Order Date]



SELECT * FROM Orders$