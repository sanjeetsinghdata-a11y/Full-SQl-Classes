use SUPER_SAMPLESTORE
GO


--- find the order where sales is  greather than the average saless

SELECT [Order ID],Sales
from Orders$
where Sales>(
    SELECT avg(Sales) as avgsales FROM Orders$
)
ORDER BY sales  ASC


use TraningYa
GO
--- find  the employee who are earning the highest salary in their
SELECT EmployeeID,EmployeeName,Salary,Department from  Employees
WHERE Salary  IN (
    SELECT max(Salary) as maxsalry from Employees
    GROUP BY Department
)



---  second highest salary

SELECT max(Salary) as secondmax FROM Employees
where Salary<(
    SELECT max(Salary) as maxsalary FROM Employees
)


-- third highest salary

SELECT max(Salary) as thirdsalry from Employees
where Salary<(
    
SELECT max(Salary) as secondmax FROM Employees
where Salary<(
    SELECT max(Salary) as maxsalary FROM Employees
)

)



---- find employee earning more than every hr employee
SELECT EmployeeID,EmployeeName,Department from Employees
where Salary>all(
    SELECT Salary from Employees
where Department='HR'


)



---  find custoomer who placed order more than the average of the order of percustomer


use SUPER_SAMPLESTORE
GO


SELECT [Customer ID],[Customer Name],COUNT([Order ID]) as totalorders FROM Orders$
GROUP BY [Customer ID],[Customer Name]
HAVING COUNT([Order ID])>
(
    
sELECT avg(totalorders) as avgorder FROM (
    
    SELECT COUNT( DISTINCT [Order ID]) as totalorders FROM  Orders$
    GROUP BY [Customer ID]
) as t



)



--- find the customers who belong to the same region as the region of 'andrew Allen'
use TraningYa
GO

use SUPER_SAMPLESTORE
GO

SELECT [Customer ID],[Customer Name],Region FROM Orders$
where Region IN
(
SELECT DISTINCT Region from Orders$
where [Customer Name]='andrew Allen'
)



-----find the name of the Region highest number of customers

SELECT Region ,COUNT(DISTINCT [Customer ID]) as totalcus
FROM Orders$
GROUP BY Region
HAVING COUNT(DISTINCT [Customer ID]) in
(
    SELECT max(totalcust) as maxcus FROM(
         SELECT 
    count(DISTINCT [Customer ID]) as totalcust from Orders$
    GROUP BY Region

    )as Regioncust
   
)



----- list the depts 
use TraningYa 
GO

SELECT  EmployeeID,EmployeeName,Department,sum(Salary) as totalsalary  FROM Employees
GROUP BY Department,EmployeeID,EmployeeName
HAVING sum(Salary)>(
    SELECT avg(totalsalary) as avgsalary FROM(
        SELECT sum(Salary) as totalsalary
        from Employees
        GROUP BY Department
    ) as deptsalary
)
ORDER BY totalsalary DESC





---  list  the dept whose avg salary  is grether than overall average salary



    SELECT Department,avg(Salary) as avgsalary from Employees
    GROUP BY Department
    HAVINg avg(salary)>
    (
    SELECT avg(Salary) from Employees
    )





----- correlated sub-quary


SELECT * FROM orders$

use TraningYa
go



---  find the dept who are having atleat 5 employee
SELECT DISTINCT Department FROM employees as r1
where Salary>(
    SELECT avg(Salary) as avgsalary
    from Employees as r2
    where r2.Department=r1.Department
)



--- find the employee who is the only one employee in their dept
SELECT * FROM Employees as e1
WHERE (
    SELECT from Employees as e2
    WHERE e2.Department=e1.Department


)




--- 

use SUPER_SAMPLESTORE
GO



----find the product  sales is greather than the avg sales of their  catgrory


SELECT [Product ID],[Product Name],sum(Sales) from orders$
GROUP BY [Product ID],[Product Name]
HAVING  sum(Sales)>(
    SELECT avg(totalsales) as avgsales FROM(
        SELECT sum(sales) as totalsales FROM Orders$ 
        GROUP BY Category 
    )as t
)



---- find the customers who have placed orders  on more than one diff dates


--- find the product that were never  ordered

SELECT [Product Name] FROM Orders$ as O
WHERE [Product ID] NOT IN(
    SELECT [Product Name] from Orders$ as p
    where p.[Product ID]=o.[Product ID]
)



-- find the first order of the  every customer

SELECT DISTINCT [Customer Name],[Order ID] FROM Orders$ as o

WHERE [Order Date]= (
    SELECT min([Order Date]) from Orders$ as o2
    WHERE o2.[Customer ID]=o.[Customer ID]

)



---- find the customers whose latesr orders sales exceeds 2000

SELECT [Customer ID],[Order Date],sum(Sales) as ts FROM Orders$ as o
where [Order Date]= (
    SELECT max([Order Date]) FROM orders$ as c
    WHERE c.[Customer ID]=o.[Customer ID]        
)
GROUP BY [Customer ID],[Order Date]
HAVING sum(Sales)>2000
ORDER BY sum(Sales) ASC



--- find customer whose profit purchase was furtnitue

SELECT DISTINCT [Customer ID],[Order Date],Category  FROM Orders$ as o

where category='Furniture'
AND [Order Date] =(
    SELECT min([Order Date]) FROM Orders$ as d
    WHERE d.[Customer ID]=o.[Customer ID]

)




 ---- find the customer who never bought  the same product twice

 SELECT [Customer ID],[Customer Name]FROM
 Orders$ as o
where EXISTS(
    SELECT 1 FROM Orders$ as p
    WHERE  p.[Customer ID]=o.[Customer ID]
    GROUP BY [Product ID]
    HAVING count(DISTINCT [Product ID])=1
    )
 



-----  