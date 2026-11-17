


use SUPER_SAMPLESTORE
GO



--- pivot table--

SELECT  YR
       ,[Office Supplies] ,[Furniture] ,[Technology]
FROM
(
	SELECT  YEAR([Order Date]) AS YR
	       ,Category
	       ,Profit
	FROM Orders$
)as source_table 
PIVOT( SUM(profit) for category IN ( [Office Supplies], [Furniture], [Technology]) )as pivot_table






---- show region wise total sales for every year

SELECT 
YR,
[South],
[West],
[Central],
[East]
FROM(
    SELECT year([Order Date]) as YR,Region,Sales FROM Orders$ 
)as source_table

PIVOT (sum(sales) for Region in ([South],
[West],
[Central],
[East])) as pivot_table



---stored procedures

---stored procedures without parameter

-- is used to store the qaury  inside the database ,to  use it in future insted writing the quary  again we create store procedure
-- to stored the quary inside the database so that we can use the qaury in future "Quary Data is permanently stored ,not templorary like temp tables ex - .....#table, ......##tables2"





----  to update the store procedure qaury  use after  before the procedure name and add what property or  fields you want to show  and apply


    ALTER PROCEDURE SP_Stored
    AS
    BEGIN
        SELECT 
            [Customer ID],
            [Customer Name],
            Sales,
            Profit,
            Region
        FROM Orders$
        WHERE Region = 'West'
        AND Sales > 200
        AND Profit > 200;
    END;


EXEC SP_Stored




---stored procedure with  parameter



ALTER Procedure sp_store2
@Region VARCHAR(40),
@Category VARCHAR(50)
AS
BEGIN
SELECT * FROM Orders$
WHERE Region=@Region
and Category=@Category
END

EXEC sp_store2 'west','Technology'






--------- index


--- clustred - one index per table
-- index key is stored in the same table
create CLUSTERED INDEX ords
ON orders$(sales)






--- non -clustred -can  be created many

-- index key is stored in the seprated table

use SUPER_SAMPLESTORE
GO

CREATE  NONCLUSTERED INDEX ords2
on orders$([Order ID])


SELECT 
    i.name AS IndexName,
    c.name AS ColumnName,
    i.type_desc AS IndexType
FROM sys.indexes i
JOIN sys.index_columns ic
    ON i.object_id = ic.object_id
    AND i.index_id = ic.index_id
JOIN sys.columns c
    ON ic.object_id = c.object_id
    AND ic.column_id = c.column_id
WHERE i.object_id = OBJECT_ID('Orders$')
  AND i.type = 1;





--- to  the indes of the clustred table
select 
i.name as IndexName,
c.name as ColumnName,
i.type_desc as IndexType
from sys.indexes as i
JOIN sys.index_columns as ic
on i.object_id=ic.object_id
AND i.index_id=ic.index_id
JOIN sys.columns as c
ON ic.object_id=c.object_id
AND ic.column_id=c.column_id
where i.object_id=OBJECT_ID('Orders$')
and i.type=1;




--- to  the indes of the non clustred table and to  see the both table  without passing any  value or filter  just remove the type=1 "remove the entire line "
select 
i.name as IndexName,
c.name as ColumnName,
i.type_desc as IndexType
from sys.indexes as i
JOIN sys.index_columns as ic
on i.object_id=ic.object_id
AND i.index_id=ic.index_id
JOIN sys.columns as c
ON ic.object_id=c.object_id
AND ic.column_id=c.column_id
where i.object_id=OBJECT_ID('Orders$')
and i.type=2;







----- find lastest 2 order per customer

SELECT *
FROM (
    SELECT
        [Customer ID],
        [Customer Name],
        [Order ID],
        [Order Date],
        Sales,
        ROW_NUMBER() OVER (
            PARTITION BY [Customer ID]
            ORDER BY [Order Date] DESC
        ) AS rn
    FROM Orders$
) AS t
WHERE rn <= 2;


---- find the  duplicate rows in the table

with ct1 as (
    SELECT *,
    row_number() OVER(PARTITION BY [Order ID],[Product ID],sales ,profit ORDER BY [Order Date])as rn
    FROM Orders$ 
)

SELECT * FROM ct1
WHERE rn>1





---- how  would you flag the first and last order for customer


WITH ct1 AS
(
	SELECT  [Customer ID]
	       ,[Order Date]
	       ,ROW_NUMBER() OVER(PARTITION BY [Customer ID] ORDER BY  [Order Date])     AS firstorder
	       ,ROW_NUMBER() OVER(PARTITION BY [Customer ID] ORDER BY [Order Date] DESC) AS lastorder
	FROM orders$
)
SELECT  DISTINCT c1.[Customer ID]
       ,c1.[Order Date] AS firstOrder
       ,c2.[Order Date] AS lastorder
FROM ct1 AS c1
JOIN ct1 AS c2
ON c1.[Customer ID] = c2.[Customer ID]
WHERE c1.firstorder = 1
AND c2.lastorder = 1



---- second way to do  this

WITH ct1
AS(

    SELECT [Customer ID],[Order Date],
    row_number() OVER(PARTITION BY [Customer ID] ORDER BY [Order Date] ASC) as firstorder
    FROM Orders$

),
ct2
AS(
    SELECT [Customer ID],[Order Date],
    row_number() OVER(PARTITION BY [Customer ID] ORDER BY [Order Date] DESC) as lastorder
    FROM Orders$
    
)
SELECT c1.[Customer ID],c1.[Order Date] as firstorder,c2.[Order Date] as lastorder FROM ct1 as c1
JOIN ct2 as c2
on c1.[Customer ID]=c2.[Customer ID]
where c1.firstorder=1
AND c2.lastorder=1





--- find the customer namees that are starting and ending with same letter


SELECT [Customer Name] from Orders$
where LEFT([Customer Name],1)=RIGHT([Customer Name],1)



------ find the highestt priced product in every order


SELECT  [Product ID]
       ,[Product Name]
       ,Sales
FROM
(
	SELECT  [Product ID]
	       ,[Product Name]
	       ,Sales
	       ,ROW_NUMBER() OVER(PARTITION BY [Order ID] ORDER BY  sales DESC)as rn
	FROM Orders$
)as t
WHERE rn = 1


use SUPER_SAMPLESTORE

GO

---- restart the running total after the negative transection

WITH CTE AS
(
    SELECT
        [Customer ID],
        [Order Date],
        Sales,

        SUM(CASE 
                WHEN Sales < 0 THEN 1 
                ELSE 0 
            END) OVER (
                PARTITION BY [Customer ID]
                ORDER BY [Order Date]
                ROWS UNBOUNDED PRECEDING
            ) AS grp
    FROM Orders$
)

SELECT
    [Customer ID],
    [Order Date],
    Sales,

    SUM(Sales) OVER (
        PARTITION BY [Customer ID], grp
        ORDER BY [Order Date]
        ROWS UNBOUNDED PRECEDING
    ) AS RunningTotal

FROM CTE
ORDER BY [Customer ID], [Order Date];



---- find the longest increasing sales sequance

 
with ct1
AS(
    SELECT [Order Date],Sales,
    lag(sales) OVER(ORDER BY [Order Date]) as prevsales FROM  Orders$

),
ct2 as (
    SELECT *,
    CASE 
        WHEN  Sales>prevsales THEN  1
        ELSE  0
    END as salesbucket
    FROM ct1
),
ct3 as (
    SELECT  *,
   SUM(salesbucket)  OVER(ORDER BY [Order Date] rows BETWEEN UNBOUNDED  PRECEDING  and CURRENT ROW) as flag
    FROM ct2
    
    
),
ct4 as (
        SELECT flag,
        COUNT(*) as  countsales
        FROM ct3
        GROUP BY flag
)
 
SELECT max(countsales ) as longesthighestsales from ct4


