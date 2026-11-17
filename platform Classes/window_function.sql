use TraningYa
use SUPER_SAMPLESTORE

SELECT * FROM Orders$

--- running sum()_____


SELECT *,
sum(Sales) OVER(ORDER BY Sales ROWS BETWEEN  UNBOUNDED PRECEDING and CURRENT row) as runningTotalSales FROM Orders$


--moving average()


SELECT *,
avg(Sales) OVER(ORDER BY Sales rows BETWEEN UNBOUNDED  PRECEDING and CURRENT row) as moving_Avg
from Orders$


-- category wise total sales 


SELECT Category,sales,
sum(Sales) OVER(PARTITION BY [Category]   ) as categoryWiseSales
 FROM Orders$
ORDER BY categoryWiseSales ASC


--- Region wise total average profit

SELECT DISTINCT Region,
avg(Profit) OVER(PARTITION BY [Region] ) as regionWiseAvgProfit FROM Orders$
ORDER BY regionWiseAvgProfit  ASC


----- customer wise total order count

SELECT DISTINCT
    [Customer Name],Sales,Profit,
    COUNT([Order ID]) OVER (
        PARTITION BY [Customer Name]
    ) AS Total_Order_Count
FROM [Orders$]
ORDER BY Total_order_Count desc

---Category wuse minumum sales

SELECT Category,Sales,
min(Sales) OVER(PARTITION BY [Category]) as minumumSales
FROM Orders$
ORDER BY minumumSales ASC



---category wise maximum profit

SELECT Category ,
max(Profit) OVER(PARTITION BY [Category]  ) as max_profit
FROM Orders$
 

---show the total sales for each  customers
SELECT DISTINCT [Customer ID],
sum(Sales) OVER(PARTITION BY [Customer ID] ) as total_Sales  FROM  Orders$


---display state wise total sales

SELECT DISTINCT [State],
sum(Sales) OVER(PARTITION BY  [State]) as StateSales
 FROM Orders$

---segment wise total average discount
SELECT DISTINCT  Segment,
avg([Discount]) OVER(PARTITION BY [Segment]) as SegmenSales
FROM Orders$

---minimum profit for region

SELECT DISTINCT Region,
min(profit) OVER(PARTITION BY [Region])as regionMinSales
 FROM  Orders$

---highest Discount

SELECT DISTINCT
100*max(Discount) OVER(ORDER BY [Discount] desc) as HighestDiscount
 FROM Orders$


--- category wise row  numbering

SELECT Category,Sales,
row_number() OVER(PARTITION BY [Category] ORDER BY Sales DESC) as CatwIsenumbering
FROM Orders$

--- customer orders Numbering

SELECT [Customer ID],[Order ID], 
row_number() OVER(ORDER BY [Customer ID]) as CustomeOrder
 FROM Orders$

---  profit Numbering 
SELECT Profit ,
row_number() OVER(ORDER BY [profit] DESC) as ProfitNm
 FROM Orders$


--- Lastest Orders
SELECT [Order ID],[Order Date],
max([Order Date]) OVER(ORDER BY [Order ID]) as LatesOrders
FROM Orders$


--==================================
--=================--=================

--- Rank()

--- Sales Rank
SELECT Sales,
rank() OVER(ORDER BY [Sales] desc) as SalesRank
FROM Orders$

-- Category Wise Sales Rank
SELECT Category,
sum(Sales) as total_Sales,
rank()  OVER( ORDER BY sum(Sales) DESC )  as catSalesRank FROM Orders$
GROUP BY  Category
ORDER BY catSalesRank 


-- profit Rank

--- Customer Rank

---  region Rank


--========--========
--========--========

----Dense rank


--  dense rank Sales
SELECT Sales,
dense_rank() OVER(ORDER BY Sales DESC) as DenseRank
 FROM Orders$
 
-- Dense Rank category
SELECT Category,
sum(Sales)  as total_Sales,
dense_rank() OVER(ORDER BY sum(Sales) DESC) as CatDenseRank
FROM Orders$
GROUP by Category


-- Profit Dense rank
SELECT Profit,
dense_rank() OVER(ORDER BY [Profit] DESC) as profitDenseRank
FROM Orders$

-- Customer Dense Rank

SELECT [Customer Name],
sum(Sales) as total_Sales,
dense_rank() OVER( ORDER BY sum(Sales) DESC) as Ranking FROM Orders$
GROUP BY [Customer Name]
ORDER BY Ranking;


---- Ntile --Divide all Orders into 4 Sales Group

SELECT [Order ID],Sales,
ntile(4) OVER(ORDER BY Sales DESC) as Sales_group
 FROM Orders$

 




 use TraningYa

SELECT *from ORDERS$



--region wise total sales ---
SELECT 
    REGION,
    Sales,
    SUM(Sales) OVER (PARTITION BY REGION) AS region_total_sales
FROM ORDERS$;


--  assigning  the row number to each  column of  the data

SELECT *,
row_number() OVER(ORDER BY Sales DESC) as row_number FROM ORDERS$


--- assing the rank to each sales ----


SELECT * ,
rank() OVER (ORDER BY Sales DESC) as rank FROM ORDERS$


--dense rank --- there is no gap between tide value

SELECT *,
dense_rank() OVER(ORDER BY Sales)as dense_rank FROM  ORDERS$


-- lead--

SELECT *,
lead(round(Sales,0),1) OVER ( ORDER BY Sales ) as lead FROM ORDERS$


---  lead()--- to find the next value  from the  current row


SELECT [EmployeeID],EmployeeName,Salary ,
lead(Salary) OVER(ORDER by [EmployeeID]) as next_Emp_Salary
FROM Employees


----second next employee salary 

SELECT [EmployeeID],EmployeeName,Salary,
lead(Salary,2,0) OVER(ORDER BY  [EmployeeID]) as second_next_EmpSalary
FROM
Employees





--- LAG--- to find the  previous  value from the current row
-- find the previus emp dept
SELECT [EmployeeID],EmployeeName,Department,
lag(Department) OVER(ORDER BY [EmployeeID]) as previous_EmpDept
FROM Employees



-- find the third previous  emp name

SELECT [EmployeeID],EmployeeName,
lag([EmployeeName],3) OVER (ORDER BY [EmployeeID]) as third_Emp_dept
FROM Employees


----- Running total sales --

SELECT [EmployeeID],EmployeeName,Department,Salary,
sum(Salary) OVER ( ORDER BY Salary  ASC) as runnig_TotalSales
FROM Employees


SELECT [EmployeeID],EmployeeName,Salary,Department,
sum(Salary) OVER(ORDER by Salary rows BETWEEN UNBOUNDED PRECEDING and CURRENT  row) as runnng_total_sum
FROM Employees


--- 1  preeciding and current row  sum---

SELECT [EmployeeID],EmployeeName,Salary,Department,
sum(Salary) OVER(ORDER by Salary rows BETWEEN 1 PRECEDING and CURRENT  row) as runnng_total_sum
FROM Employees


-- moving avg ---

SELECT * ,
avg(Salary) OVER (ORDER BY Salary rows BETWEEN UNBOUNDED PRECEDING and CURRENT row ) as moving_avg 
FROM Employees

---- 1 preeciding and current row average ------


SELECT *,
avg(Salary) OVER (ORDER by Salary rows BETWEEN 1 PRECEDING and CURRENT row) 
as preeciding_movingAvg FROM Employees

--- moving avg 2 preeciding and 3 following -----

SELECT *,
avg(Salary) OVER(ORDER by Salary rows BETWEEN 2 PRECEDING and 3  FOLLOWING )
as preeciding2_3FollowingMovingAvg FROM Employees


---firts_value() 

SELECT *,
first_value(Salary)
 OVER(ORDER BY [EmployeeID]) 
 as first_value FROM Employees



--- assign a row number to each order within each region sorted by desc sales

SELECT Region,Sales,
row_number()  OVER(PARTITION BY Region ORDER BY Sales desc) as regionSales FROM  Orders$

-- rank customer within each region by total sales

SELECT [CUSTID],Region,
sum(Sales) as total_sales,
rank() OVER (PARTITION BY [Region] ORDER BY sum(Sales) DESC) as rank FROM ORDERS$
GROUP BY Region,CUSTID

--- find the dence rank of each order date  by the same customer 

SELECT [CUSTID],[ORDERID],[ORDERDATE],
dense_rank() OVER(PARTITION BY [CUSTID] ORDER BY [ORDERDATE] DESC) as dense_rank FROM ORDERS$

SELECT * FROM ORDERS$ 







SELECT *FROM Orders$




--  for each order find the previous  order profit  by the same customer

use SUPER_SAMPLESTORE

SELECT  [Customer ID],[Order ID],Profit,
lag(Profit ) OVER(PARTITION BY  [Customer ID] ORDER BY [Profit ] desc) as PrevoiousProfit
FROM ORDERS$


-- find the  running total of sales for  each  region by  order date

SELECT Region,Sales,
sum(Sales) OVER(PARTITION BY [Region] ORDER BY [Order Date] rows BETWEEN UNBOUNDED
 PRECEDING  and CURRENT  ROW) as  RegionRuningTotal
 FROM Orders$



-- find  the cummulative avg profit for each region by order sales
SELECT
    Region,
    [Order ID],
    Sales,
    Profit,

    AVG(Profit) OVER (
        PARTITION BY Region
        ORDER BY Sales
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS Cumulative_Avg_Profit

FROM Orders$

ORDER BY Region, Sales;



---- find the difference between each  order sales and previous order sales for each customer

SELECT  [Order ID],[Order Date],Sales,
lag(Sales) OVER(ORDER by [Order ID]) as PreviouSales,
Sales-lag(Sales) OVER(ORDER by [Order ID]) as DIFFERENCE
from Orders$



------- FIRST VALUES-----
use TraningYa
go 


-- first employee to join the organizatoin
SELECT *,
first_value(EmployeeName) OVER( ORDER BY [EmployeeID] ASC)  as firstEmp
 FROM  Employees


 -- first employee to  join the Department
 
SELECT [EmployeeID],[EmployeeName],[Department],[JobTitle],
first_value(EmployeeName) OVER(PARTITION BY [Department]  ORDER BY [EmployeeID] ) as First_emp
 FROM Employees
 ORDER BY First_emp ASC

-- last emp to join the department

SELECT *,
last_value(EmployeeName) OVER(ORDER BY [EmployeeID] rows BETWEEN UNBOUNDED PRECEDING and UNBOUNDED
FOLLOWING) as lastemp
from Employees


--- last employee salary in each dept

SELECT *,
last_value(Salary)
 OVER(PARTITION BY [Department] ORDER BY [EmployeeID] rows BETWEEN UNBOUNDED PRECEDING and UNBOUNDED FOLLOWING  )as lastEmpSalary FROM  Employees


--NTILE()
SELECT *,
ntile(3)   OVER(ORDER BY Salary) as bucket ,

     case WHEN  ntile(3)   OVER(ORDER BY Salary)=1 THEN 'Low'
        WHEN ntile(3)   OVER(ORDER BY Salary)=2 THEN 'Average'
        else 'high'
     END as BuckerIndicator 

FROM Employees


-- generate a column where dept is hr or it then category A 
--           where dept is finance then category B
--           else category C

SELECT *,
    case WHEN Department='HR' or Department='IT' THEN 'Category A'
    when Department='FInance' THEN 'category B'
    else 'categroy C'
    end  as Departmentcategory
FROM Employees
ORDER BY  Departmentcategory ASC


SELECT * FROM Employees$


---  find  the  first product sold by order date  in each Region

use TraningYa
use  SUPER_SAMPLESTORE

---  find  the  first product sold by order date  in each Region
    SELECT Region,[Product ID],[Order Date],
    first_value([Product ID]) OVER(PARTITION BY [Region] ORDER BY [Order Date] rows BETWEEN UNBOUNDED PRECEDING and UNBOUNDED FOLLOWING)as firstSOldOrder
    FROM Orders$
    
    ORDER BY Region,[Order Date]
    

--- find thne last product sold by  order date in each  category
  
SELECT Category,[Product ID],[Product Name],[Order Date],
last_value([Product Name])
 OVER(PARTITION BY [Category] ORDER BY [Order Date] rows BETWEEN UNBOUNDED PRECEDING and UNBOUNDED FOLLOWING )
 as lastSoldProdutct FROM  Orders$


---- for  each customer ,identify  their first and last order dates

SELECT  [Customer Name] ,
first_value([Order Date]) OVER  ( ORDER BY [Order Date] rows BETWEEN UNBOUNDED PRECEDING and UNBOUNDED FOLLOWING) as first_order,
last_value([Order Date]) OVER( ORDER BY [Order Date] ROWS  BETWEEN  UNBOUNDED PRECEDING and UNBOUNDED FOLLOWING ) as last_order 
FROM  Orders$
GROUP BY  [Customer Name],[Order Date]
ORDER BY [Order Date]

---  for  each order find previous  order profit by the same customer
SELECT [Customer ID],[Order ID],Profit,
lag(Profit) OVER(PARTITION BY [Customer ID] ORDER BY  [Order ID]) as PreviousProfit FROM  Orders$



---  find the  running total sales for each region by  the order date


SELECT Region,Sales ,
sum(Sales) OVER(PARTITION BY [Region] ORDER BY  [Order Date] ROWS BETWEEN UNBOUNDED PRECEDING  and CURRENT row) as RegionRunningTotalSales
FROM Orders$


SELECT * FROM  Orders$

-- find the cummulative avg profit for  each  sub category based on  order date

SELECT [Sub-Category],[Order ID],[Order Date],Profit,
avg(Profit) OVER(PARTITION BY [Sub-Category] ORDER BY [Order Date] rows  BETWEEN  UNBOUNDED PRECEDING and CURRENT  ROW) as cummulativeAvgSubProfit
 FROM Orders$



-- find the difference between  each order sales and  previous order sales  for each customer


SELECT
    [Customer ID],
    [Order Date],
    [Order ID],
    SUM(Sales) AS Total_Sales,

    LAG(SUM(Sales)) OVER (
        PARTITION BY [Customer ID]
        ORDER BY [Order Date]
    ) AS PVOrdSales,

    SUM(Sales) - LAG(SUM(Sales)) OVER (
        PARTITION BY [Customer ID]
        ORDER BY [Order Date]
    ) AS DIFFERENCE

FROM Orders$

GROUP BY
    [Customer ID],
    [Order ID],
    [Order Date];
 


--- find the cummulative avg  profit for each order sales and previous order sales for each  customers

WITH OrderData AS (
    SELECT
        [Customer ID],
        [Order ID],
        [Order Date],
        Sales,
        Profit,

        LAG(Sales) OVER (
            PARTITION BY [Customer ID]
            ORDER BY [Order Date]
        ) AS Previous_Order_Sales

    FROM Orders$
)

SELECT
    [Customer ID],
    [Order ID],
    [Order Date],
    Sales,
    Profit,
    Previous_Order_Sales,

    Sales - Previous_Order_Sales AS Sales_Difference,

    AVG(Profit) OVER (
        PARTITION BY [Customer ID]
        ORDER BY [Order Date]
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS Cumulative_Avg_Profit

FROM OrderData

ORDER BY [Customer ID], [Order Date];
