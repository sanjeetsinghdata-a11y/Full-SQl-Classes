use TraningYa
GO


-- Create Table_1
CREATE TABLE Table_1 (
    ID INT,
    Name VARCHAR(50)
);

-- Insert data into Table_1
INSERT INTO Table_1 (ID, Name)
VALUES
(1, 'Vikas Ahlawat'),
(2, 'Sachin Aggarwal'),
(3, 'Manoj Kumar');


-- Create Table_2
CREATE TABLE Table_2 (
    ID INT,
    Name VARCHAR(50)
);

-- Insert data into Table_2
INSERT INTO Table_2 (ID, Name)
VALUES
(1, 'Vikas Ahlawat'),
(4, 'Sanjay Kumar'),
(5, 'Sachin Aggarwal'),
(3, 'Sandeep Kumar');


--- inner join

SELECT * FROM Table_1 as t1
INNER JOIN Table_2 as t2
on t1.ID=t2.ID


---- left outer join

SELECT * FROM Table_1 as t1
left OUTER JOIN Table_2 as t2
on t1.ID=t2.ID

---- right outer join

SELECT * FROM Table_1 as t1
RIGHT OUTER JOIN Table_2 as t2
on t1.ID=t2.ID

--- 

SELECT * FROM Table_1 as t1
INNER JOIN Table_2  as t2
on t1.ID in (1)


SELECT * FROM Table_1 as t1
INNER JOIN Table_2  as t2
on NOT(t1.ID)=t2.ID


SELECT  EmployeeID,FirstName,ProjectName   FROM EmployeeDetail as e
INNER JOIN ProjectDetail as p
on e.EmployeeID=p.EmployeeDetailID
where EmployeeID in (
    SELEcT EmployeeDetailID from ProjectDetail 
    GROUP BY EmployeeDetailID
    HAVING count(ProjectDetailID)>1
)



 

 