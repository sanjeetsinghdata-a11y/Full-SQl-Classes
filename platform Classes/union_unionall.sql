use TraningYa
GO
use SUPER_SAMPLESTORE
GO



-- if  dept is Amdin then A, HR then B ,IT then C and rest  is D

use TraningYa

SELECT EmployeeName,Department,
 case when Department='Admin' THEN 'A'

    WHEN  Department='HR' THEN 'B'
    WHEN Department='Finance' THEN 'C'
    else 'D'
END as DepartmentCategory
 FROM  Employees
 ORDER BY DepartmentCategory ASC





-- if  dept is admin or hr and salary  >3000  then list A
-- if dept ids finance and salay>6000 then list B
---else list C

SELECT Department,EmployeeName,Salary,
    case WHEN Department in  ('Admin','HR') and Salary>3000 THEN '  A'
        WHEN Department ='Finance ' and Salary>6000 THEN '  B'
        else '   C'
    END as  DepartmentCategriesWiseSalary
FROM Employees
ORDER BY Department ASC



---=====================================
-- TOPIC:   UNION , UNION ALL 
---=====================================


CREATE DATABASE UNIONS

CREATE TABLE Employees_A (
    Emp_ID INT,
    Emp_Name VARCHAR(50),
    Department VARCHAR(50)
);

INSERT INTO Employees_A VALUES
(101, 'Rahul', 'IT'),
(102, 'Amit', 'HR'),
(103, 'Priya', 'Finance'),
(104, 'Neha', 'IT'),
(105, 'Rohit', 'Sales');


CREATE TABLE Employees_B (
    Emp_ID INT,
    Emp_Name VARCHAR(50),
    Department VARCHAR(50)
);

INSERT INTO Employees_B VALUES
(103, 'Priya', 'Finance'),
(104, 'Neha', 'IT'),
(106, 'Karan', 'HR'),
(107, 'Sneha', 'Sales'),
(108, 'Arjun', 'IT');





-- UNION -- COMBINE DATA OF TWO OR MORE TABLES BASED ON THE ROWS BUT  REMOVES THE DUPLICATES ROWS
-- NUMBER OF COLUMNS SHOULD BE SAME
-- ORDER OF COLUMN  SHOULD BE SAME
-- DATA TYPE OF COLUMN  SHOULD BE SAME

-- SYNTAX--
-- SELECT *FROM TABLEA
-- UNION 
-- SELECT *FROM TABLEB


--1. Find  unique employees from both tables.
SELECT *FROM Employees_A
UNION 
SELECT * FROM Employees_B



---3. Find employees present in both tables.

SELECT Emp_Name,Department FROM Employees_A
UNION
SELECT  Emp_Name,Department FROM Employees_B





-- UNION ALL

-- COMBINE DATA  OF TWO  OR MORE TABLE BASED ON THE ROWS BUT DO NOT REMOVES DUPICATES ROWS 
-- NUMBER OF COLUMN SHOULD BE SAME 
-- ORDER  OF COLUMN SHOULD BE SAME
--DATA  TYPE OF COLUMN SHOULD BE SAME



"""
    SYNTAX--
        SELECT *FROM TABLEA
        UNION ALL 
        SELECT *FROM TABLEB
"""

---2. Combine both tables, including duplicates.

SELECT * FROM  Employees_A
UNION ALL
SELECT * FROM Employees_B

--  INTERSECT --- COMMON ROWS FROM THE BOTH TABLES
--  NUMBER OF COLUMN SHOULD BE SAME
--  ORDER OF COLUMN  SHOULD BE SAME
--  DATA  TYPE OF COLUMN  SHOULD BE SAME



"""
    SYNTAX--
        SELECT *FROM TABLEA
        INTERSECT
        SELECT *FROM TABLEB
"""

-- EXCEPT  --  ROWS IN TABLES 1 THAT ARE  NOT AVALABLE IN TABLES 2
--  NUMBER OF COLUMN SHOULD BE SAME
--  ORDER OF COLUMN  SHOULD BE SAME
--  DATA  TYPE OF COLUMN  SHOULD BE SAME


--- SYNTAX
        -- SELECT *FROM TABLES 1
        -- EXCEPT 
        ---  SELECT *FROM TABLES 2

-----4. Find employees present only in Employees_A.

SELECT * FROM Employees_A
EXCEPT 
SELECT * FROM Employees_B




--- Temporary table
-- local temporary-- available only  in  the  current window
--  denoted with  #
--- automatically  gets deleted when  the  current windows is called 


---  syntax of creating the local temporary tables

-- create table #A(int id ,name varchar )



-- how to  load data from one table to  another

SELECT *  INTO ##Region FROM ORDERS$
where region='west'




SELECT * FROM  ##Region


--  global temporary  tables-- available in all the  windows
-- denoted with ##
-- gets deleted when all the  windows are closes


---  syntax of creating the globla temporary tables

-- create table ##B(int id ,name varchar )