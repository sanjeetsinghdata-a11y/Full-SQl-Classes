-- 1. Find all employees from the Employees table.

SELECT *from employees_B

-- 2. Find employees whose salary is greater than ₹50,000.
SELECT * FROM EmployeeSalary
where Salary>50000

-- 3. Find the second-highest salary.
SELECT max(Salary) FROM EmployeeSalary
where Salary<(
    SELECT max(Salary) from EmployeeSalary
)


-- 4. Find the highest salary in each department.
SELECT top 1 * FROM EmployeeSalary
ORDER by Salary DESC


SELECT EmployeeName,max(Salary) as highest_salary FROM EmployeeSalary
GROUP BY EmployeeName


-- 5. Find employees whose names start with 'A'.
SELECT * FROM  EmployeeSalary
where EmployeeName like 'A%'


-- 6. Find employees whose salary is between ₹30,000 and ₹60,000.
SELECT * FROM  EmployeeSalary
where  Salary BETWEEN 30000 and 60000
ORDER by Salary ASC



-- 7. Count the number of employees in each department.
SELECT Department,count(*) as total_emp FROM Employees_B
GROUP BY Department

-- 8. Find duplicate employee names.
SELECT * FROM
(SELECT EmployeeID,row_number() OVER(PARTITION BY employeeID ORDER BY employeeID ASC
) as dupli FROM Employees_B
)as t
where dupli BETWEEN 1 AND 2


SELECT * FROM Employees_B
UPDATE Employees_B
SET EmployeeID=1
WHERE EmployeeID=4


SELECT *
FROM
(
    SELECT *,
        COUNT(*) OVER (
            PARTITION BY EmployeeID
            ORDER BY EmployeeID
        ) AS dupli
    FROM Employees_B
) AS t
WHERE dupli > 1;


