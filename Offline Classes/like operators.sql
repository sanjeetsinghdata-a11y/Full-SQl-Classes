
USE SUPER_SAMPLESTORE


----  FIND THE DATA WHERE STATE IS  CALIFORNIA


-- note": use double quetation when  you need to see the  name of the column not the value , but if you want to see the value of the column use single quetation 
SELECT
[Order ID],
[Order Date],
[State],
Sales
FROM   Orders$
WHERE [State] = 'California'


-- FIND THE DATA WHERE CATEGORY IS FURNITURE

SELECT
[Order ID],
[Order Date],
Sales,
Category
FROM Orders$
WHERE  Category='FURNITURE'


--- FIND THE DATA WHERE STATE IS COLIFORNIA ,TEXAS ,NEW YORK

SELECT
[Order ID],
[Order Date],
[State]
 FROM Orders$
 WHERE STATE IN ( 'CALIFORNIA','TEXAS','NEW YORK')


 -- FIND THE DATA WHERE  POSTAL CODE IS 94122

 -- note : there  is  not valid  "" is not  snytax "" if you are filtering the data on specific condition to be performed prefer "  not in"
 SELECT 
    [Order ID],
    [Postal Code] ,
    MONTH([Order Date]) months,
    YEAR([Order Date]) yearoforder,
    DAY([Order Date]) orderday,
    round(Sales,0) totalSales
FROM Orders$
 WHERE [Postal Code] ='94122'




--  FIND THE DATA WHERE REGION IS NOT EAST,WEST M SOUTH

SELECT 
[Order ID],
[Order Date],
Region,
round(Sales,0) AS TOTAL_SALES
FROM Orders$
WHERE Region  NOT IN ('east','west','SOUTH')


--  FIND  THE DATA WHERE SALES IS GREATHER THAN 10000


SELECT
[Order ID],
[Order Date],
round(Sales,0)AS TOTOAL_SALES
FROM Orders$
WHERE Sales>=1000   
ORDER BY sales ASC

---  FIND THE DATA WHERE PROFIT IS LESS THAN 50


SELECT
[Order ID],
[Order Date],
round(Profit,0) total_profit
FROM Orders$
where Profit<=50
ORDER BY Profit DESC


--- FIND THE DATA WHERE QUANTITY IS GREATHER THAN OR EQUAL  TO  7


SELECT
[Order ID],
[Order Date],
Quantity
FROM Orders$
where Quantity>=7
ORDER BY Quantity ASC




--  FIND THE DATA WHERE DISOCUNT IS LESS THAN OR  EQUAL TO  5

SELECT 
[Order ID],
[Order Date],
Discount  total_discount
from Orders$
WHERE Discount <= 0.5
ORDER BY Discount DESC



---- FIND THE ORDER WHERE REGION IS SOUTH AND SUB -CATEGORY IS  CHAIR,TABLE

SELECT
[Order ID],
FORMAT([Order Date], 'dd-MM-yyyy'),
Region,
[Sub-Category],
round(Sales,0) TOTAL_SALES
FROM Orders$
WHERE Region = 'South'
 AND ([Sub-Category] = 'Chairs'
    OR [Sub-Category] = 'Tables');


--- FIND  THE ORDERS WHERE REGION IS CENTRAL OR STATE IS  CALIFORNIA 

SELECT
[Order ID],
[Order Date],
Region,
[State],
round(Sales,0) total_Sales
FROM Orders$
WHERE Region ='CENTRAL ' or  [State]='CALIFORNIA'



--- FIND THE  DATA WHERE SALES IS BETWEEN 500 TO 1000
-- note: if you are filtering data using between  bear it  in your mind while assining the range you want to  see the value mention and after one value 
---- syntax : condition  between 100 and 2000

SELECT 
[Order ID],
[Order Date],
ROUND(Sales,0) total_sales
FROM Orders$
WHERE Sales BETWEEN 500 AND 1000
ORDER BY Sales



--- FIND  THE ORDER PLACED IN 2024
SELECT
[Order ID],
format([Order Date],'dd-MM-yy')  orderdate

FROM Orders$
--where [Order Date] BETWEEN '2014 ' and '2015'
WHERE [Order Date] BETWEEN '2014-01-01' and  '2014-12-31'
ORDER BY [Order Date]  ASC

 

 --- LIKE OPERATOR

 --- FIND THE CUSTOMER NAMES STARTS  WITH A 

 SELECT
 [Customer ID],
 [Customer Name]
FROM Orders$
WHERE [Customer Name] LIKE 'A%'


---- FIND THE CUSTOMER NAME STARTING WITH N

SELECT  
[Customer ID],
[Customer Name]
FROM Orders$
WHERE [Customer Name] LIKE 'N%'



--- FIND  THE CUSTOMER NAME ENDS WITH T

SELECT
[Customer ID],
[Customer Name]
FROM Orders$
WHERE [Customer Name] LIKE '%T'

--- FIND THE CITY  STARTING WITH J AND ENDING  WITH E

SELECT 
[Customer ID],
[Customer Name],
[State]
FROM Orders$
WHERE [State] LIKE 'J%E'

---- FIND THE STATE NAMES THAT CONTAINS 0

SELECT 
[Customer ID],
[Customer Name],
[State]
FROM Orders$
WHERE  [State] LIKE  '%O%'


---- FIND THE NAMES THAT CONTAINS S OR T OR BOTH

SELECT
[Customer ID],
[Customer Name]
FROM Orders$
WHERE [Customer Name]  like 'S%R%'  


---  FIND THE CUSTOMER NAMEES  THATS CONTAINS S OR T OR BOTH

SELECT
[Customer ID],
[Customer Name]
FROM Orders$
WHERE  [Customer Name] LIKE '%S%' OR 
[Customer Name] LIKE '%T%'


--- FIND THE NAMES THAT CONTAINS VOWEL 

SELECT
[Customer ID],
[Customer Name]
FROM Orders$
WHERE [Customer Name] LIKE '%A%E%I%O%U%'


---  FIND  THE NAMES WHOSE  FIRST  NAME STARTS WITH  S AND LAST NAME STARTS WITH  T

SELECT 
FIRST_NAME,
LAST_NAME
FROM(
SELECT
    [Customer ID],
    [Customer Name],
CASE 
    WHEN CHARINDEX(' ',[Customer Name])>0  THEN 
    LEFT([Customer Name],CHARINDEX(' ',[Customer Name])-1)
    ELSE [Customer Name]
END AS FIRST_NAME,
CASE
        WHEN [Customer Name] LIKE '% % %'
        THEN SUBSTRING(
            [Customer Name],
            CHARINDEX(' ', [Customer Name]) + 1,
            CHARINDEX(
                ' ',
                [Customer Name],
                CHARINDEX(' ', [Customer Name]) + 1
            ) - CHARINDEX(' ', [Customer Name]) - 1
        )
        ELSE ' '
    END AS Middle_Name,
CASE 
    WHEN CHARINDEX(' ',[Customer Name])>0
    THEN SUBSTRING([Customer Name],CHARINDEX(' ',[Customer Name])+1,LEN([Customer Name]))
    ELSE ''
    END LAST_NAME
FROM Orders$
)t where 
    FIRST_NAME like 'S%' AND
    LAST_NAME like '%T'

 

--- FIND THE CUSTOMET NAME THAT HAS 15  CHARACHTER 

SELECT
DISTINCT
[Customer Name]
FROM Orders$
WHERE  [Customer Name] LIKE '_______________'



--  FIND THE NAME  WHOSE SECOND NAME STARTS WITH V
SELECT
[Customer ID],
[Customer Name]
FROM Orders$
WHERE [Customer Name] LIKE '_V%'


---  FIND THE NAME THAT CONTAINS SH TOGHTER

SELECT 
[Customer ID],
[Customer Name]
FROM Orders$
WHERE [Customer Name] LIKE '%SH%'


-- FIND THE NAME CONATINS S AND H AT  ANY  PLACES
SELECT
[Customer ID],
[Customer Name]
FROM Orders$
WHERE [Customer Name]  LIKE '%S%' AND 
[Customer Name] LIKE '%H%'

---FIND THE NAME THAT CONTAINS VOWES IN 

SELECT
[Customer Name]
FROM Orders$
WHERE  [Customer Name] LIKE '%[AEIOU]%'

 SELECT  
 'total_sales' as flag,
 *,
 [2014]+[2015]+[2016]+[2017] as grand_total
 from 
 (
    select 
    YEAR([Order Date]) as years,
    Round(sum(Sales),0) total_sales
    from Orders$
    group  by YEAR([Order Date])
 )as SOURCE_table
 PIVOT(max(total_sales) for  years in ([2014],[2015],[2016],[2017])) as pivot_table



 ---  FIND THE MISSING DATES IN TABLE
  -- Missing date = No order was placed/recorded on that date.


WITH DATERANGE AS
(
    SELECT MIN(CAST([Order Date] AS DATE)) AS DT
    FROM Orders$

    UNION ALL

    SELECT DATEADD(DAY, 1, DT)
    FROM DATERANGE
    WHERE DT < '2017-12-31'
)

SELECT DT AS MissingDate
FROM DATERANGE
WHERE DT NOT IN
(
    SELECT DISTINCT CAST([Order Date] AS DATE)
    FROM Orders$
)
OPTION (MAXRECURSION 0);



