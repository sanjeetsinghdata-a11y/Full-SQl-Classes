-- 61. Find the top 10 customers by total sales.

SELECT top 10 [Customer Name] ,sum(Sales) as Revanue  from  Orders$
GROUP BY [Customer Name]
ORDER BY Revanue DESC


-- 62. Find the most profitable products.
SELECT  top 1 [Product Name],sum(Sales) as Revaneu FROM Orders$
GROUP BY [Product Name]
ORDER BY Revaneu DESC

-- 63. Find products generating negative profit.
SELECT   [Product Name],sum(Profit) as Revaneu FROM Orders$
GROUP BY [Product Name]
HAVING sum(Profit)<0


-- 64. Calculate monthly revenue.
SELECT MONTH([Order Date]) as month,sum(sales) as revanue FROM Orders$
GROUP BY MONTH([Order Date])
order by month ASC


-- 65. Calculate the average order value for each month.
SELECT MONTH([Order Date]) as month,sum(sales)*1.0/COUNT(DISTINCT [order id]) as avgordervalue FROM Orders$
GROUP BY MONTH([Order Date])
ORDER by MONTH ASC

-- 66. Find customers who placed more than one order.
SELECT [Customer Name] FROM Orders$
GROUP BY [Customer ID]
HAVING Count(DISTINCT [Order ID])>1

-- 67. Find products whose sales are above average.

SELECT [product name],sum(sales) as total_Sales,avg(sales) as avg_sales FROM  orders$
GROUP BY [product name]
HAVING sum(sales)>(    
SELECT avg(total_sales) as  avg_Sales   from(
    select sum(sales) as total_sales from Orders$
    GROUP BY [Product Name]
) as t
 
)




-- 68. Find products purchased in at least five different regions.

SELECT [Product Name],sum(Sales) as total_sales,count(DISTINCT Region) as  total_region FROM orders$
GROUP BY [Product Name]
HAVING Count(DISTINCT Region)>1


-- 69. Find products whose sales are above average but profit is below average.
SELECT [Product Name],sum(sales) as total_sales,sum(profit) as total_profit,avg(Profit)  as below_avg FROM Orders$
GROUP BY [Product Name]
having sum(Sales) >(
    SELECT avg(total_sales) as avg_sales FROM(
        SELECT sum(sales) as total_sales FROM  Orders$
        GROUP BY [Product Name]
    )as t
)
and sum(profit)<(
    SELECT avg(total_profit) as avg_profit FROM (
        SELECT sum(Profit) as total_profit FROM orders$
        GROUP BY [Product Name]
    )as t
)

ORDER by total_sales DESC

-- 70. Find products whose profit margin is above the average margin of their category.

WITH ct1 as (

        SELECT Category,[Product Name],sum(Profit)/nullif(sum(sales),0) as profit_margin,(
            SELECT round(avg(profit_margin),2) FROM(
                     SELECT sum(Profit)/sum(Sales) as profit_margin FROM  Orders$ as o2
                     WHERE o2.Category=o1.Category
                     
            )as t
           
        ) as avg_profit_margin  FROM  orders$  as o1
        GROUP BY  [Product Name],Category
)
SELECT
Category,
[Product Name],
round(profit_margin,2) as profit_margin,
round(avg_profit_margin,2) as avg_profit_margin
FROM  ct1 as c1
WHERE  c1.profit_margin>(

    SELECT avg(c2.profit_margin)  from ct1  as c2
    WHERE c2.Category=c1.Category
    
)
ORDER BY profit_margin  DESC


-- 71. Find the product with the highest revenue in each year.

WITH  ct1 as (

    SELECT year([order date]) as year, [Product Name],sum(sales) as total_Sales FROM Orders$
    GROUP BY  [Product Name],year([order date])

),
ct2 as (

    SELECT *,ROW_NUMBER() OVER(PARTITION BY  YEAR ORDER BY  total_sales DESC) as rk FROM  ct1
)
SELECT * FROM ct2
WHERE rk=1


-- 72. Find products whose revenue increased for two consecutive years.


WITH ct1 as 
(
    SELECT year([order date]) as year ,[product name],sum(sales) as total_sales FROM  orders$
    GROUP BY year([order date]),[Product Name]
),
ct2 as (

        SELECT *,
        lag(total_sales) OVER(PARTITION BY [product name] ORDER BY year) as prevsales
        FROM ct1

)
SELECT * FROM ct2
where total_sales>prevsales
ORDER by year ASC,total_sales DESC



-- 73. Find customers whose total sales are above the average customer sales.

SELECT [Customer Name],sum(Sales) as total_sales,avg(sales) as avg_sales from orders$
GROUP BY [Customer Name]
HAVING sum(sales)>(

        SELECT avg(total_sales) FROM(
                SELECT [Customer Name],sum(sales) as total_sales FROM orders$
                GROUP BY [Customer Name]
        )as t
        
)

-- 74. Find the region with the highest profit.

WITH ct1 as (

        SELECT Region, sum(profit) as total_profit FROM Orders$
        GROUP BY Region
),
ct2 as (
    SELECT *,row_number() OVER(ORDER BY total_profit  DESC) as rk FROM ct1

)
SELECT * FROM ct2
where rk=1

-- 75. Find pairs of products purchased together in the same Order ID.
SELECT o.[Order ID],o.[product name],o2.[Product Name] FROM  Orders$ as o
JOIN orders$ as o2
ON o.[order id]=o2.[order id]
and  o.[product name]<o2.[Product Name]



-- 76. Find the most frequently purchased product pairs.

SELECT 
o1.[Product Name],
o2.[Product Name],
Count(*) as comman_purchased
FROM Orders$ as o1
JOIN Orders$ as o2
ON o1.[Order ID]=o2.[Order ID]
and o1.[Product Name]<o2.[Product Name]
GROUP BY o1.[Product Name],o2.[Product Name]
ORDER BY comman_purchased DESC


-- 77. Find customers who purchased products from at least three different categories.
SELECT DISTINCT [Customer Name] ,count(DISTINCT category  )  as  totalcategory from Orders$
GROUP BY  [Customer Name]
HAVING Count(DISTINCT Category)>1
ORDER by totalcategory DESC



-- 78. Find customers who purchased from every category.
SELECT DISTINCT [Customer Name] ,count(DISTINCT category  )  as  totalcategory from Orders$
GROUP BY  [Customer Name]
HAVING Count(DISTINCT Category)=3


-- 79. Find the most common category combinations purchased by customers.
 
SELECT
    o1.Category AS Category1,
    o2.Category AS Category2,
    COUNT(*) AS purchased_pair
FROM Orders$ o1
JOIN Orders$ o2
    ON o1.[Order ID] = o2.[Order ID]
    AND o1.Category < o2.Category
GROUP BY
    o1.Category,
    o2.Category
ORDER BY purchased_pair DESC;




-- 80. Find products whose sales declined for three consecutive years.
WITH ct1 as (

    SELECT YEAR([Order Date]) as year,[Product Name],sum(sales) as total_sales FROM Orders$
    GROUP BY [Product Name],YEAR([Order Date])
),
ct2 as (
    SELECT *, 
    LAG(total_sales,1) OVER(PARTITION BY [product name] ORDER BY year ASC) as prevyear,
    LAG(total_sales,2) OVER(PARTITION BY [product name] ORDER BY year ASC) as prevyear2 FROM
    ct1
)
SELECT * FROM ct2
WHERE total_sales<prevyear
and prevyear<prevyear2
ORDER by [year] ASC
