
use SUPER_SAMPLESTORE
go



--- find the second highest sales
--- without sub-quary,cte,window function,temp table


SELECT DISTINCT Sales
FROM Orders$
ORDER BY Sales DESC
OFFSET 1 ROW
FETCH NEXT 1 ROW ONLY;

--- by using join, we also can achieve the same result as we got it any method ,is offset row fetch rowno row

SELECT top 1 o1.Sales  as maxsales FROM Orders$ as o1
JOIN Orders$ as o2 
ON o1.sales<o2.Sales
ORDER by  o1.sales  DESC

 
    
    SELECT
        [Year],
        [Central],
        [East],
        [West],
        [South]
        into #pivot_sales
    FROM
    (
        SELECT
            YEAR([Order Date]) AS [Year],
            Region,
            Sales
        FROM Orders$
    ) AS X
    PIVOT
    (  
        SUM(Sales)
        FOR Region IN ([Central], [East], [West], [South])
    ) AS P


SELECT
    [Year],
    Region,
    Sales
    INTO #pivot_Sales_2
FROM
(
    SELECT
        [Year],
        [Central],
        [East],
        [West],
        [South]
    FROM
    (
        SELECT
            YEAR([Order Date]) AS [Year],
            Region,
            Sales
        FROM Orders$
    ) AS X
    PIVOT
    (
        SUM(Sales)
        FOR Region IN ([Central], [East], [West], [South])
    ) AS P
) AS X
UNPIVOT
(
    Sales
    FOR Region IN ([Central], [East], [West], [South])
) AS UP
ORDER BY [Year], Region;

SELECT p1.*,
sum(p2.Sales) as Grand_Total
FROM #pivot_sales as p1
JOIN #pivot_Sales_2 as p2
on p1.YEAR=p2.YEAR
GROUP BY p1.[Year],p1.[Central],p1.[East],p1.[South],p1.[West]


 


 
SELECT  [year]
       ,[east]
       ,[west]
       ,[south]
       ,[central]
      INTO #pivot_orderCount1
FROM
(
	SELECT  YEAR(o.[Order Date]) AS year
	       ,o.Region
	       ,o.[Order ID]         AS Orders_total
	FROM Orders$ AS o
	INNER JOIN Returns$ AS r
	ON o.[Order ID] = r.[Order ID]
)as x pivot( COUNT(Orders_total) for region IN ( [east], [west], [south], [central] ) )as pvt


SELECT 
[YEAR],
[region],
Orders_total
into #pivot_Countorder_orderTotal
FROM(

SELECT  [year]
       ,[east]
       ,[west]
       ,[south]
       ,[central]
      -- INTO #pivot_orderCount1
FROM
(
	SELECT  YEAR(o.[Order Date]) AS year
	       ,o.Region
	       ,o.[Order ID]         AS Orders_total
	FROM Orders$ AS o
	INNER JOIN Returns$ AS r
	ON o.[Order ID] = r.[Order ID]
)as x pivot( COUNT(Orders_total) for region IN ( [east], [west], [south], [central] ) 
)as pvt
)as pp
UNPIVOT(
    Orders_total
    for region in (
        [east], [west], [south], [central] 
    )
)as unp



SELECT
    p1.[Year],
    p1.[Central],
    p1.[East],
    p1.[West],
    p1.[South],
    SUM(p2.Orders_total) AS Grand_Total
FROM #pivot_orderCount1 AS p1
LEFT JOIN #pivot_Countorder_orderTotal AS p2
    ON p1.[Year] = p2.[Year]
GROUP BY
    p1.[Year],
    p1.[Central],
    p1.[East],
    p1.[West],
    p1.[South];


---- second way approach same problem using union and pivot table


SELECT 'total sales' as flag ,*,
        [2014]+
        [2015]+
        [2016]+
        [2017] as Grand_total
FROM (
    SELECT YEAR([Order Date]) as year,SUM(sales) as total_sales FROM Orders$
    GROUP by YEAR([Order Date])
)as x
PIVOT (
    sum(total_sales)
    for year in (
        [2014],
        [2015],
        [2016],
        [2017]
    )
)as pvt

UNION
SELECT 'total profit',*,
        [2014]+
        [2015]+
        [2016]+
        [2017] as Grand_total
FROM (
    SELECT YEAR([Order Date]) as year,SUM(Profit) as total_sales FROM Orders$
    GROUP by YEAR([Order Date])
)as x
PIVOT (
    sum(total_sales)
    for year in (
        [2014],
        [2015],
        [2016],
        [2017]
    )
)as pvt
UNION



SELECT 'total quantity',*,
        [2014]+
        [2015]+
        [2016]+
        [2017] as Grand_total
FROM (
    SELECT YEAR([Order Date]) as year,SUM(Quantity) as total_sales FROM Orders$
    GROUP by YEAR([Order Date])
)as x
PIVOT (
    sum(total_sales)
    for year in (
        [2014],
        [2015],
        [2016],
        [2017]
    )
)as pvt

UNION


SELECT 'total orders',*,
        [2014]+
        [2015]+
        [2016]+
        [2017] as Grand_total
FROM (
    SELECT YEAR([Order Date]) as year,Count([Order ID]) as total_sales FROM Orders$
    GROUP by YEAR([Order Date])
)as x
PIVOT (
    sum(total_sales)
    for year in (
        [2014],
        [2015],
        [2016],
        [2017]
    )
)as pvt


SELECT sum(Profit) as totalprofit from orders$




DECLARE @text VARCHAR(100) = 'abcd-1234-xyz-5678';

WITH ct1 AS
(
    SELECT @text AS text
)
SELECT
    LEFT(text, CHARINDEX('-', text) - 1) AS t,
    SUBSTRING(
    text,
    CHARINDEX('-', text) + 1,
    CHARINDEX('-', text, CHARINDEX('-', text) + 1)
       - CHARINDEX('-', text) - 1
) AS number
FROM ct1;



-- Create a table named 'users'
CREATE TABLE users (
    email VARCHAR(255) NOT NULL
);

-- Insert 20 random email IDs with Gmail and Outlook
INSERT INTO users (email)
VALUES
('john.doe@gmail.com'),
('jane.smith@outlook.com'),
('alice.white123@hotmail.com'),
('bob.jones@gmail.com'),
('carol.miller@outlook.com'),
('david.brown@hotmail.com'),
('emma.williams@gmail.com'),
('frank.moore@outlook.com'),
('george.taylor@hotmail.com'),
('hannah.jackson@gmail.com'),
('ian.wilson@outlook.com'),
('julia.scott@hotmail.com'),
('kelly.adams@gmail.com'),
('luke.evans@outlook.com'),
('maria.davis@hotmail.com'),
('nancy.clark@gmail.com'),
('oliver.martin@outlook.com'),
('paul.lewis@hotmail.com'),
('quincy.walker@gmail.com');


with ct1 as(

        SELECT email FROM users
)
SELECT LEFT(email,CHARINDEX('@',email)-1) as username,
SUBSTRING(email,CHARINDEX('@',email)+1,LEN(email)) as domain FROM ct1

 

SELECT *,SUBSTRING(email,CHARINDEX('@',email)+1,len(SUBSTRING(email,CHARINDEX('@',email)+1,LEN(email)))-4) FROM users

--- find the total sales of the apple product without using the like operator

SELECT [Product Name],sum(sales) as total_Sales FROM Orders$
where CHARINDEX('apple',[Product Name])>0
GROUP BY [product name]

---another way to achieve this 


SELECT [Product Name],sum(Sales) as totalSales FROM Orders$
where PATINDEX('%Apple%',[Product Name])>0
GROUP BY [Product Name]



--- find the top 5 customer for each year total sales wise


with ct1 as (

        SELECT YEAR([Order Date]) as Year,[Customer ID],sum(sales) as totalSales FROM Orders$
        GROUP BY YEAR([Order Date]),[Customer ID]
),
Ranking as (

    SELECT *,
    row_number() OVER(PARTITION BY YEAR order by totalSales DESC ) as rk FROM ct1
)
SELECT * FROM Ranking
where rk<=5


---without usign cte

SELECT  YEAR([Order Date]) year,[Customer ID] , format(sum(sales),'c','en-in') as Revanue ,
row_number() OVER(PARTITION BY year ORDER BY Revanue desc) as rk
FROM Orders$
where rk<=5
GROUP by [Customer ID],YEAR([Order Date])

datename('quarter',[order date])