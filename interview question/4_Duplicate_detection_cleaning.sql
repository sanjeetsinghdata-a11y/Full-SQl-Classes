-- 41. Find duplicate records in a table.

select [EmployeeID],count(*) as total_dup from Employees_A
GROUP BY [employeeId]
HAVING count([EmployeeID])>1


-- altering the table so we can get the result as per the  requirement couse our table doesn't contain any duplicated values ,i'm just manually updating the value
UPDATE Employees_A
set EmployeeID=1
where EmployeeID=7;

---- duplicated records along with employee details


SELECT *
FROM (
    SELECT *,
        COUNT(*) OVER(PARTITION BY EmployeeID) AS total_dup
    FROM Employees_A
) AS t
WHERE total_dup > 1;


-- 43. Find duplicate customer IDs.
SELECT  DISTINCT*
FROM (
    SELECT  [customer id],
        COUNT(*) OVER(PARTITION BY [customer id]) AS total_dup
    FROM orders$
) AS t
WHERE total_dup > 1
ORDER by total_dup DESC



-- 42. Delete duplicate records while retaining one copy.

WITH ct1 as (

    SELECT *,
        row_number() OVER(PARTITION BY EmployeeID ORDER BY employeeID ASC) AS total_dup
        FROM Employees_A
)
delete FROM ct1
WHERE total_dup>1



SELECT * FROM Employees_A



-- 44. Replace NULL values with a default value.
UPDATE employees_A 
set EmployeeName=ISNULL(EmployeeName, 'Singh')
where EmployeeName is NULL

SELECT * FROM Employees_A
ORDER by EmployeeID ASC


SELECT * FROM Employees_A
-- 45. Find rows where required columns contain NULL values.

update  Employees_A
set EmployeeID=NULL
where EmployeeID=1


SELECT * FROM Employees_A
where EmployeeID is NULL
ORDER BY EmployeeID ASC



-- 46. Find employees with invalid or missing joining dates.


ALTER TABLE Employees_A
ADD  JoiningDate VARCHAR(20);

UPDATE Employees_A
SET JoiningDate = CASE EmployeeID
    WHEN 1 THEN '2022-01-15'
    WHEN 2 THEN '2021-05-20'
    WHEN 3 THEN NULL
    WHEN 4 THEN '2023-13-45'
    WHEN 5 THEN '2020-08-10'
    WHEN 6 THEN 'Invalid Date'
    WHEN 7 THEN ''
    WHEN 8 THEN '2024-02-30'
    WHEN 9 THEN '2022-11-25'
    WHEN 10 THEN NULL
END;

SELECT * FROM employees_A
WHERE NULLif(trim(joiningDate),'') is NULL;


-- 47. Find customers whose names appear with different customer IDs.
SELECT [Customer Name],count(DISTINCT [Customer ID]) as total_customers FROM orders$
GROUP BY [customer name]
HAVING Count(DISTINCT [Customer id])>1


-- 48. Identify leading or trailing spaces in employee names.

UPDATE Employees_A
SET EmployeeName = CASE EmployeeID
    WHEN 1 THEN ' Amit'
    WHEN 2 THEN 'Rahul '
    WHEN 3 THEN ' Priya '
    WHEN 4 THEN 'Neha'
    WHEN 5 THEN ' Karan'
    WHEN 6 THEN 'Sneha '
    ELSE EmployeeName
END;


SELECT len(employeeName)-LEN(trim(EmployeeName)) as leading_ from Employees_A


SELECT
    DATALENGTH(EmployeeName) - DATALENGTH(RTRIM(EmployeeName))
    AS Trailing_Spaces
FROM Employees_A;


-- 49. Find duplicate orders based on Order ID.

select [Order ID],COUNT(*) as total_orders from orders$
GROUP BY [Order ID]
HAVING Count([Order ID])>1
ORDER by total_orders


-- 50. Find records where the same employee has multiple salary entries.


use TraningYa_practice
GO
 

SELECT  employeeID, STRING_AGG(ROUND(Salary,1) ,', ') as salary  ,count(*) as duplicated_salary from employeeSalary
GROUP BY [employeeID]
HAVING count(Salary)>1

SELECT * FROM employeeSalary