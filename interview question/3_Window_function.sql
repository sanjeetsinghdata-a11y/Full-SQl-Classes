-- 31. Assign a row number to employees according to salary.

with ct1 as (

        SELECT *,row_number() OVER(ORDER by salary DESC) as rk FROM Employees
)
SELECT * FROM ct1





SELECT e1.[employeeName],e1.salary,e1.rk, e2.[EmployeeName],e2.salary,e2.rk  FROM 
(SELECT *,row_number() OVER(ORDER by salary DESC) as rk
FROM employees as e1
)as e1
LEFT JOIN (
    SELECT * FROM
    (
            SELECT *,ROW_NUMBER() OVER(ORDER BY salary ASC) as rk FROM employees

    ) as t
    
)as e2
ON e1.rk=e2.rk
where e1.rk<=5



WITH HighestSalary AS
(
    SELECT *,
        ROW_NUMBER() OVER(ORDER BY Salary DESC) AS rk
    FROM Employees
),
LowestSalary AS
(
    SELECT *,
        ROW_NUMBER() OVER(ORDER BY Salary ASC) AS rk
    FROM Employees
)
SELECT
    h.EmployeeName AS Highest_Paid_Employee,
    h.Salary AS Highest_Salary,
    h.rk AS High_Rank,
    l.EmployeeName AS Lowest_Paid_Employee,
    l.Salary AS Lowest_Salary,
    l.rk AS Low_Rank
FROM HighestSalary AS h
LEFT JOIN LowestSalary AS l
    ON h.rk = l.rk
WHERE h.rk <= 5;





-- 32. Find the top three salaries in each department.

with ct1 as (
    SELECT *,row_number() OVER(PARTITION BY department order by salary  DESC) as rk FROM employees

)
SELECT * FROM ct1
where rk<=3




-- 33. Compare each employee's salary with the previous employee's salary.
WITH ct1 as (
    SELECT *,lag(Salary) OVER(ORDER BY salary) as prevsalary FROM employees
)
SELECT * FROM ct1
where Salary>prevsalary


-- 34. Calculate the running total of salaries.

WITH ct1 as (
        SELECT *,sum(Salary) OVER(ORDER BY salary ROWS BETWEEN UNBOUNDED PRECEDING and CURRENT ROW)as running_total FROM employees
)
SELECT * FROM ct1



-- 35. Calculate each department's percentage contribution to total salary expenditure.

WITH ct1 as (
    SELECT Department,sum(salary) as department_salary FROM employees
    GROUP BY Department
),
ct2 as (
    SELECT sum(department_salary) as total_salary FROM ct1
)
SELECT c1.*,c2.total_salary,ROUND((c1.department_salary*100.0)/c2.total_salary,2) as contribution FROM ct1 as c1
CROSS JOIN ct2 as c2 

-- 36. Find the second-highest salary in each department.
WITH ct1 as (
    SELECT *,dense_rank() OVER(ORDER BY salary DESC) as rk FROM employees
)
SELECT * FROM ct1
WHERE rk=2


-- 37. Find employees whose salary is higher than the previous employee's salary.

WITH ct1 as (
    SELECT *,lag(Salary) OVER(ORDER BY salary) as prevsalary FROM employees
)
SELECT * FROM ct1
where Salary>prevsalary

-- 38. Calculate the difference between each employee's salary and the department's highest salary.

WITH ct1 as (
    SELECT Department,max(Salary) as department_salary FROM employees
    GROUP BY Department
)
SELECT c.Department,e.salary,c.department_salary,c.department_salary-e.Salary as DIFFERENCE  FROM employees as e
INNER JOIN ct1 as c
on e.[Department]=c.[Department]



-- 38. Calculate the difference between each employee's salary and the department's highest salary.

WITH ct1 AS (
    SELECT
        Department,
        MAX(Salary) AS highest_salary
    FROM Employees
    GROUP BY Department
)
SELECT
    e.EmployeeID,
    e.EmployeeName,
    e.Department,
    e.Salary,
    c.highest_salary,
    c.highest_salary - e.Salary AS Difference
FROM Employees AS e
INNER JOIN ct1 AS c
    ON e.Department = c.Department;


-- 39. Find the top three customers by revenue in each region.


WITH ct1 as (
    SELECT region,[customer name],sales,
    row_number() OVER(PARTITION BY region order by sales DESC) as rk  from orders$
)
SELECT * FROM ct1
WHERE rk<=3





-- 40. Calculate the cumulative monthly sales.
WITH ct1 as (
    SELECT month([order date]) as month,round(sum(sales),2) as total_sales FROM orders$
    GROUP BY month([order date])
),
ct2 as (
    SELECT *,
    sum(total_sales) OVER(ORDER BY month ROWS BETWEEN UNBOUNDED PRECEDING and CURRENT ROW) as commulative_sum FROM ct1
)
SELECT * FROM ct2
ORDER BY month ASC

