-- Active: 1776684353461@@127.0.0.1@3306
-- SQLBook: Code

use  TraningYa

SELECT *from INFORMATION_SCHEMA.TABLES
where TABLE_TYPE = 'BASE TABLE'

SELECT *from Departments$
SELECT * FROM Employees$
SELECT * FROM EmployeesProject$
 
SELECT * FROM Projects$


----  show all the  project and the name of the  employee working on them

SELECT p.ProjectName,Em.FirstName
from Projects$ p
LEFT join EmployeesProject$ E
on p.ProjectID=E.ProjectID
LEFT JOIN Employees$ as Em
on E.EmployeeID=Em.EmployeeID



--- find employee who are not working on anu project

SELECT E.FirstName,Emp.ProjectID as notworking
from Employees$ as E
LEFT JOIN EmployeesProject$ Emp
on E.EmployeeID=Emp.EmployeeID
where Emp.ProjectID is  NULL



-- CROSS JOIN------
SELECT * FROM sheet

--- find thne  edepartment name of the manager ----

SELECT s1.name as managername ,s2.deptname as manager_dept
 FROM  sheet as s1
JOIN  sheet  as s2
ON  s1.managerID=s2.empid






SELECT
From selfjoin

---find the name of the managers ---

SELECT s1.*,s2.EmployeeName as managerName
from selfjoin as s1
JOIN selfjoin as s2
on s1.ManagerID=s2.EmployeeID



---- self join ----

--- find the employee name and their manager names

SELECT s.Employeename,sm.Employeename
from selfjoin as s
LEFT  join selfjoin as sm
on s.ManagerID=sm.EmployeeID


--- find the employee who are earning more than  their manager  
SELECT s.Employeename,s.Salary  ,sm.Employeename,sm.Salary
from selfjoin  as s
left  JOIN  selfjoin as sm
on s.ManagerID=sm.EmployeeID
where s.salary>sm.salary



---  find the employee and manager working in the same dept----


SELECT s.Employeename ,s.Department,sm.Employeename AS Managername,sm.Department
from selfjoin as s
left join selfjoin as sm
on s.ManagerID=sm.EmployeeID
where s.Department=sm.Department



SELECT s1.EmployeeName as managername , s1.Department as managerdept, s1.EmployeeName as employename ,s2.Department as employeeDept
selfjoin as s1
JOIN selfjoin as s2
on s1.ManagerID=s2.EmployeeID
where s1.Department=s2.Department





use TraningYa
GO
SELECT  *from selfjoin



----- find the employee whose manager belong to  different dept

SELECT 
    s.EmployeeName,
    s.Department,
    sm.EmployeeName AS ManagerName,
    sm.Department AS ManagerDepartment
FROM selfjoin AS s
LEFT JOIN selfjoin AS sm
    ON s.ManagerID = sm.EmployeeID
WHERE s.Department <> sm.Department;



---  find manager who have the more than  one direct reportee

SELECT 
    sm.EmployeeID AS ManagerID,
    sm.EmployeeName AS ManagerName,
    COUNT(s.EmployeeID) AS DirectReportees
FROM selfjoin AS s
LEFT JOIN selfjoin AS sm
    ON s.ManagerID = sm.EmployeeID
GROUP BY 
    sm.EmployeeID,
    sm.EmployeeName
HAVING COUNT(s.EmployeeID) > 1;







SELECT *from selfjoin
 
