-- 11. Find employees earning more than the company's average salary.

SELECT [Customer Name],sum(Sales) as Employee_Sales,(

    SELECT avg(sales) FROM Orders$
) as Company_avg
FROM orders$
GROUP BY [Customer Name]
HAVING sum(Sales)>(

    SELECT avg(sales) FROM Orders$
)


--using cte

WITH ct1 as (

    SELECT [customer name],sum(Sales) as Employee_Sales FROM Orders$
    GROUP BY [customer name]

)
SELECT c1.[Customer Name],c1.Employee_Sales from ct1 as  c1
WHERE c1.Employee_Sales>(
    SELECT avg(Sales) FROM Orders$
)


/*

ct2 as (

    SELECT  ,avg(sales) as Company_avg FROM Orders$
)

SELECT c1.[Customer Name],c1.Employee_Sales,c2.Company_avg FROM  ct1 as c1
CROSS JOIN ct2 as c2
WHERE c1.Employee_Sales>c2.Company_avg
ORDER BY c1.Employee_Sales ASC


*/


---


-- 12. Find the top five highest-paid employees.

WITH ct1 as (

    SELECT [Customer Name],sum(sales) as totalsales FROM Orders$
    GROUP BY [Customer Name]
),
ct2 as (

    SELECT *,
    ROW_NUMBER() OVER(ORDER BY totalsales DESC) as rk
    FROM  ct1
)
SELECT * FROM ct2
where rk<=5

-- 13. Find the third-highest distinct salary.

WITH ct1 as(
    
        SELECT [customer name],sales,row_number() OVER(ORDER BY sales DESC) as rk FROM Orders$
)
SELECT * FROM ct1
where rk=3


-- 14. Find the highest-paid employee in each department, including ties.

WITH ct1 as (

        
        SELECT EmployeeName,Department,Salary,dense_rank() OVER(PARTITION BY department ORDER BY salary DESC) as rk  FROM Employees
        
)
SELECT * FROM ct1
where rk=1
ORDER by salary DESC


-- 15. Find employees earning more than their department's average salary.


 
WITH ct1 as (

        SELECT department,avg(Salary) as avgsales FROM employees
        GROUP BY department
)
SELECT
e.EmployeeName,
e.Department,
e.Salary,
c1.avgsales
FROM ct1 as c1
INNER JOIN employees as e
ON c1.department=e.Department
WHERE e.Salary>c1.avgsales


 



-- 16. Find the department with the highest average salary.

WITH ct1 as (

    SELECT Department,avg(Salary) as avgsalary FROM employees
    GROUP BY Department
),
ct2 as (
    SELECT *,
    ROW_NUMBER() OVER(ORDER BY avgsalary DESC) as rk
    FROM ct1
)
SELECT * FROM ct2
WHERE rk=1




-- 17. Find employees earning more than their managers.


SELECT 
    e.EmployeeName,
    e.Salary AS EmployeeSalary,
    m.Salary AS ManagerSalary,
    m.EmployeeName AS ManagerName
FROM Employees AS e
JOIN Employees AS m
    ON e.ManagerID = m.EmployeeID
WHERE e.Salary > m.Salary;



 


 

-- 18. Find the highest salary without using MAX().

SELECT top 1 *,row_number() OVER(ORDER BY sales  desc) as rk FROM orders$




-- 19. Find employees who earn the same salary.
SELECT * FROM employees as e1
JOIN employees as e2
on e1.EmployeeID>e2.EmployeeID
and e1.Salary=e2.Salary


SELECT * FROM employees

 
-- 20. Find employees who joined in the last 12 months.

with ct1 as (

        SELECT cast('2024-01-01' as date) as joining_date
        UNION ALL
        SELECT DATEADD(day,1,joining_date)  FROM ct1
        WHERE  joining_date<CAST('2025-12-31' as date)
)
SELECT * FROM ct1
OPTION (MAXRECURSION 0);


 



WITH ct1 as (

        SELECT CAST(min([Order Date]) as date) as first_date FROM Orders$
        UNION ALL
        SELECT * FROM ct1
        where first_date<CAST('2017-12-31' as date)
)
SELECT * FROM ct1 as c
WHERE not EXISTS(

        SELECT 1 FROM Orders$ as o
        where  o.[Order Date]=c.first_date
)
OPTION(maxrecursion 0)