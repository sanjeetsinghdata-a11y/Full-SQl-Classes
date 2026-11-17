use TraningYa

SELECT *from Employees

-- find those employees salary are higher than maager salary
SELECT s.EmployeeName as managername ,s.Salary as managersalary ,sm.EmployeeName as employename,s.Salary as employeesalary
from selfjoin as s
left JOIN selfjoin as sm
on s.ManagerID=sm.EmployeeID
where sm.salary>s.Salary


---- dense_rank ()------

SELECT 
*,
dense_rank() over (PARTITION BY  Department ORDER BY salary  DESC)  from selfjoin 



--- lead () -next  row to  the current row ----

SELECT * ,
LEAD(Salary)  over( ORDER BY EmployeeID)  as nextemplosalary FROM  selfjoin



--- lag()-- first row to the current row---
SELECT *,
lag(Salary) over(ORDER by EmployeeID) as firtssalaryemp

from selfjoin


---- show next emp salry  in  each dept---
        --"note ":0 used to replace null with it
SELECT * 
,lead(Salary,1,0)  over(PARTITION BY  Department ORDER BY Salary  DESC ) as nextempsalary  from  selfjoin 




--- lag  ()- previous row  from the current row---

SELECT *,
lag(Salary)  OVER( ORDER BY EmployeeID ASC) as previouSalaryEmp  FROM selfjoin  


--- show previous Emp name-----

SELECT EmployeeName,
lag(EmployeeName) over(ORDER BY EmployeeID) as preEmpName from selfjoin


----show previous emp  salary in each dept


SELECT EmployeeID,EmployeeName,JobTitle,Department,Salary
,lag(Salary,1,0) OVER(PARTITION BY Department ORDER by EmployeeID ASC ) as preEmpSalary FROM selfjoin  





---- RUNNING TOTAL -----

USE SUPER_SAMPLESTORE


SELECT [Order ID],[Customer ID],[Customer Name],Sales,
sum(sales) over(ORDER BY [customer ID] ROWS
 BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) as running_Total
FROM Orders$



---- MOVING AVERAGE ----


SELECT Sales, 
avg(Sales) over(ORDER by  [customer ID] rows BETWEEN  3 PRECEDING and CURRENT row) as moving_average
FROM Orders$



use TraningYa;
go 
SELECT * FROM  sheet1$



---- Row_number()----

SELECT
*,row_number() over (PARTITION BY Dept_name ORDER BY SALARY ) AS RS  FROM  sheet1$


--- RANK()----

-- gives unique numbering to each row, in case of duplicates, same nummber gets 

SELECT * ,
RANK() OVER (ORDER BY SALARY ASC) AS RANKING
FROM sheet1$


---DENSE RANK  --- GIVES UNIQUE TO EACH ROW ,
--  IN CASE OF DUPLICATES ,SAME NUMBER GETS  SAME RANKING AND NEXT NUMMBER IS NOT SKIPPED---

SELECT *,
DENSE_RANK()  OVER ( PARTITION BY DEPT_NAME ORDER BY SALARY ASC) AS DENSE_RANK FROM sheet1$




--- RUNNING TOTAL ------

SELECT  *,
sum(SALARY)
 OVER  
(ORDER BY [emp_id ] ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW  ) as runningtotal from  sheet1$



-- PERTITION BY SUM OF SALARY  TO GET THE VISUAL WHICH DEPT IS PAYING HIGH SALARY TO EMPLOYEE ---


SELECT  *,
sum(SALARY)
 OVER  
( PARTITION BY DEPT_NAME ORDER BY [emp_id ] ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW  ) as runningtotal from  sheet1$



--- MOVING AVERAGE --


SELECT *,
avg(SALARY  ) OVER(  ORDER BY emp_id ) as moving_avg FROM sheet1$



-- 2 above row and 2 bottom row moving avg


SELECT *,
avg(SALARY) OVER(ORDER BY emp_id  rows BETWEEN 2 PRECEDING and  2 FOLLOWING  ) as precingand2following from sheet1$



----1 assing a row number to  each order within each region sorted by desc sales
WITH CTE AS  (SELECT  *,
row_number() OVER ( PARTITION BY [CUSTID], [PRODUCTID], SALES, PROFIT  order by [ORDERDATE] DESC ) as RN
FROM  ORDERS$)

DELETE FROM CTE 
WHERE  RN > 1
SELECT *from ORDERS$


        ---2 RANK CUSTOMERS WITHIN EACH REGION BY  TOTAL SALES

        SELECT 
    CUSTID,
    REGION,
    SUM(SALES) AS TOTAL_SALES,
    RANK() OVER (
        PARTITION BY REGION
        ORDER BY SUM(SALES) DESC
    ) AS RK
FROM ORDERS$
GROUP BY CUSTID, REGION;











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



use TraningYa
go
use SUPER_SAMPLESTORE

--4. Find the previous order's profit by the same customer. 


SELECT  [Customer Name],[Order Date],Profit,
lag([Profit]) over(PARTITION BY [Customer Name] ORDER BY [Order Date]) as previOrderProfit

    FROM Orders$




 






