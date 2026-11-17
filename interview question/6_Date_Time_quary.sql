-- 51. Find employees who joined in a particular year.
use TraningYa_practice
go

CREATE TABLE Employees_A_joining_date (
    EmployeeID INT PRIMARY KEY,
    EmployeeName VARCHAR(50),
    Department VARCHAR(50),
    Salary DECIMAL(10,2),
    JoiningDate DATE
);

INSERT INTO Employees_A_joining_date VALUES
(101, 'Rahul Sharma', 'IT', 45000, '2020-05-12'),
(102, 'Amit Verma', 'HR', 35000, '2021-03-18'),
(103, 'Priya Singh', 'Finance', 50000, '2020-08-25'),
(104, 'Neha Gupta', 'IT', 55000, '2022-01-10'),
(105, 'Rohit Kumar', 'Sales', 30000, '2019-11-05'),
(106, 'Anjali Mehta', 'HR', 40000, '2021-07-22'),
(107, 'Vikas Yadav', 'IT', 60000, '2023-02-14'),
(108, 'Sneha Roy', 'Finance', 48000, '2020-12-30'),
(109, 'Karan Malhotra', 'Sales', 32000, '2022-06-19'),
(110, 'Pooja Sharma', 'IT', 52000, '2021-09-15'),
(111, 'Arjun Singh', 'Finance', 47000, '2019-04-21'),
(112, 'Simran Kaur', 'HR', 38000, '2023-10-08'),
(113, 'Deepak Joshi', 'Sales', 34000, '2020-02-11'),
(114, 'Kavita Rao', 'IT', 58000, '2022-12-01'),
(115, 'Manish Jain', 'Finance', 49000, '2021-05-27');


SELECT EmployeeName,year([joiningDate]) as Joiningdate FROM Employees_A_joining_date
where  YEAR([JoiningDate])=2021

-- 52. Calculate employees' years of service.
SELECT *,DATEDIFF(MONTH,joiningdate,getdate()) as service FROM  Employees_A_joining_date






-- 53. Find the latest orders  for each customer.
SELECT [customer name],YEAR(max([order date]))  as lates_ordedate fROM orders$
GROUP BY [customer name]


-- 54. Find customers who placed orders within 30 days of their first purchase.

WITH ct1 as (

    SELECT  DISTINCT [customer name],
    [order date],
    min([order date]) OVER(PARTITION BY [customer name] ) as firts_pur FROM  orders$
    
)
SELECT [customer name],firts_pur, DATEDIFF(day,firts_pur,[order date]) from ct1
where DATEDIFF(day,firts_pur,[order date])BETWEEN 1 and 30




-- 55. Find the number of orders placed each month.

SELECT MONTH([order date]) as month,count(*) as total_order FROM orders$
GROUP BY MONTH([order date])
ORDER BY [month] ASC


-- 56. Find the month with the highest revenue.
SELECT * FROM
(
    SELECT  *,row_number() OVER(ORDER BY Revanue DESC) as rk FROM

(   
    SELECT     MONTH([order date]) as month, round(sum(sales),2) as Revanue from orders$
    GROUP BY MONTH([order date])
) as t

) as t
where rk=1
--  using cte to solve this

WITH  ct1 as (

    SELECT MONTH(
    [order date]
    ) as month,round(sum(sales),2) as revanue FROM orders$
    GROUP BY MONTH([order date])
)
,ct2 as (
    SELECT *,row_number() OVER(ORDER BY revanue DESC) as rk FROM
     ct1
)
SELECT * FROM ct2
where rk=1

--- normal quary

SELECT top 1 MONTH([order date]) as month,round(sum(sales),2) as revanue FROM orders$
GROUP BY MONTH([order date])
ORDER BY revanue DESC



-- 57. Find customers who have not purchased in the last six months.
WITH ct1 as (
    SELECT DISTINCT [customer name],[order date],min([order date]) OVER
    (
        PARTITION BY [customer name] ORDER BY [order date] ASC
    ) as first_pur FROM orders$
    

)
SELECT [customer name],first_pur,[order date],DATEDIFF(MONTH,first_pur,[order date]) as Day_gap FROM ct1
where  DATEDIFF(MONTH
,first_pur,[order date])>6


-- 58. Calculate the number of days between consecutive orders for each customer.

WITH ct1 as (
    SELECT [customer name],DATEFROMPARTS(YEAR([order date]),MONTH([order date]),1) as order_Date,
    lag(DATEFROMPARTS(YEAR([order date]),month([order date]),1),1) OVER(PARTITION BY [customer name] ORDER BY DATEFROMPARTS(YEAR([order date]),MONTH([order date]),1)  ASC) as prevord
    FROM orders$
    
)
SELECT *,datediff(day,prevord,order_Date) as consecutive_Day_gap,
CASE 
    WHEN datediff(month,prevord,order_Date)>=12  THEN  CAST(datediff(month,prevord,order_Date)%12 as varchar(30))+' Month'
    WHEN  DATEDIFF(MONTH, prevord, order_Date) >= 12 THEN  CAST(DATEDIFF(MONTH, prevord, order_Date) / 12 AS VARCHAR(10))+ ' Years ' 
    else CAST(datediff(day,prevord,order_Date) as varchar(30))+' Days'
END as d 
FROM ct1
where  prevord is not NULL
and datediff(day,prevord,order_Date)>1




WITH ct1 AS
(
    SELECT
        [Customer Name],
        DATEFROMPARTS(YEAR([Order Date]), MONTH([Order Date]), 1) AS order_Date,

        LAG(
            DATEFROMPARTS(YEAR([Order Date]), MONTH([Order Date]), 1)
        ) OVER (
            PARTITION BY [Customer Name]
            ORDER BY DATEFROMPARTS(YEAR([Order Date]), MONTH([Order Date]), 1)
        ) AS prevord

    FROM Orders$
)
SELECT *,
    DATEDIFF(DAY, prevord, order_Date) AS consecutive_Day_gap,

    CASE
        WHEN DATEDIFF(MONTH, prevord, order_Date) >= 12
        THEN
            CAST(DATEDIFF(MONTH, prevord, order_Date) / 12 AS VARCHAR(10))
            + ' Years '
            + CAST(DATEDIFF(MONTH, prevord, order_Date) % 12 AS VARCHAR(10))
            + ' Months'

        WHEN DATEDIFF(MONTH, prevord, order_Date) >= 1
        THEN
            CAST(DATEDIFF(MONTH, prevord, order_Date) AS VARCHAR(10))
            + ' Months'

        ELSE
            CAST(DATEDIFF(DAY, prevord, order_Date) AS VARCHAR(10))
            + ' Days'

    END AS d

FROM ct1
WHERE prevord IS NOT NULL
  AND DATEDIFF(DAY, prevord, order_Date) > 1;


-- 59. Find products whose sales increased compared with the previous year.


WITH ct1 as(

    SELECT [product name],[order date],sum(sales) as Revanue
    FROM orders$
    GROUP BY [product name],[order date]

),
ct2 as (
    SELECT *,
    lag(Revanue) OVER(PARTITION BY [product name] ORDER BY [order date] ASC) as prev_productRevanue FROM ct1

)
SELECT * FROM  ct2
WHERE Revanue>prev_productRevanue



-- 60. Find the first purchase date of every customer.

SELECT DISTINCT [customer name],format(min([order date]),'dd-MM-yyyy') as first_order FROM orders$
GROUP BY  [customer name]