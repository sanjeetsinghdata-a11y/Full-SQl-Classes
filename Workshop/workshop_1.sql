
USE TraningYa
GO

CREATE TABLE EmployeeDetail (
    EmployeeID INT PRIMARY KEY,
    FirstName VARCHAR(50),
    LastName VARCHAR(50),
    Salary DECIMAL(10,2),
    JoiningDate DATETIME,
    Department VARCHAR(50),
    Gender VARCHAR(10)
);

INSERT INTO EmployeeDetail
(EmployeeID, FirstName, LastName, Salary, JoiningDate, Department, Gender)
VALUES
(1, 'Vikas', 'Ahlawat', 600000.00, '2013-02-15 11:16:28.290', 'IT', 'Male'),
(2, 'Nikita', 'Jain', 530000.00, '2014-01-09 17:31:07.793', 'HR', 'Female'),
(3, 'Ashish', 'Kumar', 1000000.00, '2014-01-09 09:00:07.793', 'IT', 'Male'),
(4, 'Nikhil', 'Sharma', 480000.00, '2014-01-09 10:05:07.793', 'HR', 'Male'),
(5, 'Anish', 'Kadian', 500000.00, '2014-01-04 09:31:07.793', 'Payroll', 'Male');




CREATE TABLE ProjectDetail (
    ProjectDetailID INT PRIMARY KEY,
    EmployeeDetailID INT,
    ProjectName VARCHAR(100),

    FOREIGN KEY (EmployeeDetailID)
        REFERENCES EmployeeDetail(EmployeeID)
);

INSERT INTO ProjectDetail
(ProjectDetailID, EmployeeDetailID, ProjectName)
VALUES
(1, 1, 'Task Track'),
(2, 1, 'CLP'),
(3, 1, 'Survey Management'),
(4, 2, 'HR Management'),
(5, 3, 'Task Track'),
(6, 3, 'GRS'),
(7, 3, 'DDS'),
(8, 4, 'HR Management');



use TraningYa
GO

SELECT * FROM EmployeeDetail
SELECT * FROM ProjectDetail


-- Q1. Write a query to get all employee details from the EmployeeDetail table.

SELECT * FROM EmployeeDetail


-- Q2. Write a query to get only the FirstName column from the EmployeeDetail table.
SELECT FirstName FROM EmployeeDetail

-- Q3. Write a query to display FirstName in uppercase as "First Name".
SELECT UPPER(FirstName) FROM  EmployeeDetail

-- Q4. Write a query to display FirstName in lowercase as "First Name".
SELECT LOWER(FirstName) FROM  EmployeeDetail

-- Q5. Write a query to combine FirstName and LastName and display them as "Name", including a space between them.
SELECT FirstName,LastName, concat(firstname,' ', lastname) FROM EmployeeDetail

-- Q6. Write a query to select employee details whose FirstName is 'Vikas'.
SELECT * FROM EmployeeDetail
where FirstName='vikas'

-- Q7. Write a query to get all employee details whose FirstName starts with 'A'.
SELECT * FROM EmployeeDetail
where FirstName like 'A%'

-- Q8. Write a query to get all employee details whose FirstName contains 'k'.
SELECT * FROM EmployeeDetail
where FirstName like '%k%'

-- Q9. Write a query to get all employee details whose FirstName ends with 'h'.
SELECT * FROM EmployeeDetail
where  FirstName like '%h'

-- Q10. Write a query to get all employee details whose FirstName has any single character between 'a' and 'p' as the second character.

SELECT * FROM EmployeeDetail
where FirstName like '_[a-p]%'

-- Q11. Write a query to get all employee details whose FirstName does not have any character between 'a' and 'p' as the second character.
SELECT * FROM EmployeeDetail
where FirstName NOT like '_[a-p]%'

-- Q12. Write a query to get all employee details whose FirstName starts with 'A' and contains exactly 5 letters.
SELECT * FROM  EmployeeDetail
where FirstName like 'A%'
and LEN(firstname)=5
 

-- Q14. Write a query to get all employee details whose FirstName contains the '%' character.

SELECT * FROM EmployeeDetail
where FirstName like '%[%]%'

-- Q15. Write a query to get all unique Department values from the EmployeeDetail table.

SELECT DISTINCT Department FROM EmployeeDetail


-- Q16. Write a query to find the highest Salary from the EmployeeDetail table.
SELECT top 1 * FROM EmployeeDetail
ORDER by Salary DESC


-- Q17. Write a query to find the lowest Salary from the EmployeeDetail table.

SELECT  top 1* FROM EmployeeDetail
ORDER BY Salary ASC

 
-- Q18. Write a query to display JoiningDate in 'dd MMM yyyy' format, for example, '15 Feb 2013'.

SELECT  format(cast(JoiningDate as date),'dd-MMM-yyyy') as joiningdate FROM EmployeeDetail

-- Q19. Write a query to display JoiningDate in 'yyyy/MM/dd' format.

SELECT 
    FORMAT(JoiningDate, 'yyyy/MM/dd') AS JoiningDate
FROM EmployeeDetail;



-- Q20. Write a query to display only the time part of JoiningDate.
SELECT CAST(JoiningDate as time) fROM EmployeeDetail

-- Q21. Write a query to get only the year part of JoiningDate.
SELECT YEAR(JoiningDate) as JoiningYear FROM  EmployeeDetail

-- Q22. Write a query to get only the month part of JoiningDate.
SELECT YEAR(JoiningDate) as Year, MONTH(JoiningDate) as JoiningMonth FROM EmployeeDetail

-- Q23. Write a query to get the current system date and time.
SELECT GETDATE() FROM EmployeeDetail

-- Q24. Write a query to get the current UTC date and time.
SELECT GETUTCDATE() as UTC_Date  FROM  EmployeeDetail

-- Q25. Write a query to display FirstName, current date, JoiningDate, and the difference between the current date and JoiningDate in months.

SELECT FirstName,GETDATE() as currentdate , joiningDate ,DATEDIFF(DAY,GETDATE(),joiningDate) as diff FROM  EmployeeDetail



-- Q27. Write a query to get all employee details whose joining year is 2013.

SELECT * FROM  EmployeeDetail
where YEAR(JoiningDate)=2013

-- Q28. Write a query to get all employee details whose joining month is January (month number 1).

SELECT * FROM EmployeeDetail
where MONTH(JoiningDate)=1

-- Q29. Write a query to get all employee details whose JoiningDate is between '2013-01-01' and '2013-12-01'.
SELECT *
FROM EmployeeDetail
WHERE JoiningDate >= '20130101'
  AND JoiningDate < '20131202';

-- Q30. Write a query to count how many employees exist in the EmployeeDetail table.
SELECT count(EmployeeID) as numberofemplyee FROM EmployeeDetail


-- Q31. Write a query to select only the top 1 record from the EmployeeDetail table.

SELECT top 1 * FROM EmployeeDetail
ORDER by Salary DESC

-- Q32. Write a query to get employee details for Vikas, Ashish, Anish, and Nikhil.

SELECT * FROM EmployeeDetail
where  FirstName  in ('vikas','anish','nikhil')

-- Q33. Write a query to get employee details whose FirstName is not Vikas, Ashish, or Nikhil.

SELECT * FROM EmployeeDetail
where  FirstName NOT in ('vikas','anish','nikhil')


-- Q34. Write a query to remove white spaces from the right side of FirstName

SELECT RTRIM(FirstName) AS RemoveSpace
FROM EmployeeDetail;

-- Q35. Write a query to remove white spaces from the left side of FirstName.

SELECT LTRIM(FirstName) AS RemoveSpace
FROM EmployeeDetail;

-- Q36. Write a query to display FirstName and Gender as M for Male and F for Female.
SELECT FirstName,Gender,
CASE 
    WHEN Gender='Male' THEN  'M'
    WHEN Gender='Female' THEN 'F'
    else  ''
END  as x
FROM  EmployeeDetail


-- Q37. Write a query to display FirstName prefixed with 'Hello'.

SELECT CONCAT('Hello',' ', firstname) as c FROM EmployeeDetail


-- Q38. Write a query to get employee details whose Salary is greater than 600000.
SELECT * FROM EmployeeDetail
where Salary>600000

-- Q39. Write a query to get employee details whose Salary is less than 700000.

SELECT * FROM EmployeeDetail
where Salary<700000

-- Q40. Write a query to get employee details whose Salary is between 500000 and 600000.
SELECT * FROM EmployeeDetail
where Salary>=500000
and Salary<=600000

-- Q41. Write a query to find the second-highest salary from the EmployeeDetail table.


SELECT max(Salary) as thirdhighest FROM EmployeeDetail
where Salary<(


   SELECT  max(Salary) as secondhigest from EmployeeDetail
   where Salary<(
    SELECT   max(Salary) FROM EmployeeDetail
     
    )

)

-- Q42. Write a query to get the department and department-wise total salary from the EmployeeDetail table.


SELECT  Department,sum(Salary) as totalsalary FROM EmployeeDetail
GROUP BY Department

-- Q43. Write a query to get department-wise total salary and display it in ascending order of salary.

SELECT Department,sum(Salary) as Department_TotalSalary FROM EmployeeDetail
GROUP by Department
ORDER by Department_TotalSalary ASC


-- Q44. Write a query to get department-wise total salary and display it in descending order of salary.

SELECT Department,sum(Salary) as Department_TotalSalary FROM EmployeeDetail
GROUP by Department
ORDER by Department_TotalSalary DESC

-- Q45. Write a query to get each department, the total number of employees, and the total salary.

SELECT Department,count(*)  as total_employee, sum(Salary) as Department_TotalSalary FROM EmployeeDetail
GROUP by Department
ORDER by Department_TotalSalary ASC

-- Q46. Write a query to get the department-wise average salary and order the results by salary in ascending order.

SELECT Department,avg(Salary) as Department_TotalSalary FROM EmployeeDetail
GROUP by Department
ORDER by Department_TotalSalary ASC

-- Q47. Write a query to get the department-wise maximum salary and order the results by salary in ascending order.

with ct1 as (

    SELECT Department,sum(Salary) as DepartmentWiseSalary FROM EmployeeDetail
    GROUP BY Department
),
Ranking as (
        SELECT *,
        ROW_NUMBER() OVER(PARTITION BY department ORDER BY DepartmentWiseSalary DESC) as rk
        FROM ct1
)
SELECT * FROM Ranking
where rk=1


-- Q48. Write a query to get the department-wise minimum salary and order the results by salary in ascending order.

with ct1 as (

    SELECT Department,sum(Salary) as DepartmentWiseSalary FROM EmployeeDetail
    GROUP BY Department
),
Ranking as (
        SELECT *,
        ROW_NUMBER() OVER(PARTITION BY department ORDER BY DepartmentWiseSalary ASC) as rk
        FROM ct1
)
SELECT * FROM Ranking
where rk=1


-- Q49. Write a query to find project names assigned to more than one employee.


SELECT
    ProjectName,
    COUNT(DISTINCT EmployeeDetailID) AS TotalEmployees
FROM ProjectDetail
GROUP BY ProjectName
HAVING COUNT(DISTINCT EmployeeDetailID) > 1;

-- Q50. Write a query to find employee names and project names, ordered by FirstName.

SELECT 
e.FirstName,
p.ProjectName
FROM EmployeeDetail as e
INNER JOIN ProjectDetail  as p
on e.EmployeeID=p.EmployeeDetailID
ORDER by e.EmployeeID



-- Q51. Write a query to get employee names and project names for employees who have been assigned projects.


SELECT
    e.FirstName,
    p.ProjectName
FROM EmployeeDetail AS e
INNER JOIN ProjectDetail AS p
    ON e.EmployeeID = p.EmployeeDetailID;

-- Q52. Write a query to get employee names and project names for all employees, including those who have not been assigned any project.
SELECT
e.EmployeeID,
e.FirstName,
p.ProjectName
FROM EmployeeDetail as e
LEFT JOIN ProjectDetail as p
ON e.EmployeeID=p.EmployeeDetailID

-- Q53. Write a query to display employee names and project names for all employees. If an employee has no project, display "No Project Assigned".
SELECT
e.EmployeeID,
e.FirstName,
p.ProjectName,
coalesce(p.ProjectName,'no project assigned')
FROM EmployeeDetail as e
LEFT JOIN ProjectDetail as p
ON e.EmployeeID=p.EmployeeDetailID

-- Q54. Write a query to get all project names, even if they do not have a matching EmployeeID in the EmployeeDetail table, ordered by FirstName.


SELECT 
p.ProjectName,
p.EmployeeDetailID,
e.FirstName,
e.EmployeeID
FROM ProjectDetail as p
RIGHT JOIN EmployeeDetail as e
on p.EmployeeDetailID=e.EmployeeID
ORDER by e.FirstName


-- Q55. Write a query to get complete records from both EmployeeDetail and ProjectDetail tables, including unmatched records. Display NULL where no match is found.

SELECT 
*FROM EmployeeDetail as e
FULL  OUTER JOIN ProjectDetail as p
on e.EmployeeID=p.EmployeeDetailID


-- Q56. Write a query to find employees who have not been assigned any project and display "No Project Assigned".

SELECT 
e.EmployeeID,
e.FirstName,
p.ProjectName,
coalesce(p.ProjectName,'no project assigned') as Project_Assigned
FROM EmployeeDetail as e
LEFT JOIN ProjectDetail as p
on e.EmployeeID=p.EmployeeDetailID
WHERE p.ProjectName is NULL

-- Q57. Write a query to find project names that are not assigned to any employee.

 SELECT p.ProjectName
FROM ProjectDetail AS p
LEFT JOIN EmployeeDetail AS e
    ON p.EmployeeDetailID = e.EmployeeID
WHERE e.EmployeeID IS NULL;


-- Q58. Write a query to fetch employee names and projects for employees who have been assigned more than one project.

SELECT
e.FirstName,
p.ProjectName
FROM EmployeeDetail as e
INNER JOIN ProjectDetail as p
on e.EmployeeID=p.EmployeeDetailID
where  e.EmployeeID in(
    SELECT EmployeeDetailID FROM ProjectDetail
    GROUP BY EmployeeDetailID
    HAVING count(DISTINCT ProjectDetailID)>1
)



-- Q59. Write a query to fetch project names on which more than one employee is working.

SELECT
    p.ProjectName,
    COUNT(DISTINCT p.EmployeeDetailID) AS TotalEmployees
FROM ProjectDetail AS p
GROUP BY p.ProjectName
HAVING COUNT(DISTINCT p.EmployeeDetailID) > 1;




