USE SUPER_SAMPLESTORE;


GO
----  find customers who spending is growing month over month
WITH   ct1
AS     (SELECT   [Customer ID],
                 format([Order Date], 'yyyy-MM') AS monthtotal,
                 sum(Sales) AS currentmonthsales
        FROM     Orders$
        GROUP BY [Customer ID], format([Order Date], 'yyyy-MM')),
       ct2
AS     (SELECT *,
               lag(currentmonthsales) OVER (PARTITION BY [Customer ID] ORDER BY monthtotal) AS previmonth
        FROM   ct1)
SELECT *,
       (currentmonthsales - previmonth) / previmonth * 100 AS mom
FROM   ct2
WHERE  previmonth IS NOT NULL;

---------sub-quary-----
-- find the employee whose salary is greather than average salary
USE TraningYa;


GO
SELECT EmployeeName,
       Salary
FROM   Employees
WHERE  Salary > (SELECT avg(salary) AS overallavg
                 FROM   Employees);

---- find the employee who are working in the same department
SELECT *
FROM   Employees
WHERE  Department = (SELECT Department AS Employees
                     WHERE  EmployeeName = 'Amit');

--- find the orders with maximum sales values
USE SUPER_SAMPLESTORE;


GO
SELECT DISTINCT [Order ID],
                Sales
FROM   Orders$
WHERE  Sales = (SELECT max(Sales) AS maxsales
                FROM   Orders$);

---- find customers who never ordered from office suplies
SELECT [Customer ID]
FROM   Orders$
WHERE  [Customer ID] NOT IN (SELECT DISTINCT [Customer ID]
                             FROM   Orders$
                             WHERE  Category = 'office Supplies');

---- find orders where sales matches any sales from east 
SELECT DISTINCT [Order ID]
FROM   Orders$
WHERE  Sales IN (SELECT Sales
                 FROM   Orders$
                 WHERE  Region = 'east');

--- find the second highest sales
SELECT MAX(Sales) AS SecondHighestSales
FROM   Orders$
WHERE  Sales < (SELECT MAX(Sales)
                FROM   Orders$);

---find  the third highest sales
SELECT MAX(Sales) AS ThirdHighestSales
FROM   Orders$
WHERE  Sales < (SELECT MAX(Sales)
                FROM   Orders$
                WHERE  sales < (SELECT max(Sales)
                                FROM   Orders$));

----- find product those sales is  greather than  all sales in furniture
SELECT [Product ID],
       Sales
FROM   Orders$
WHERE  sales > ALL (SELECT Sales
                    FROM   Orders$
                    WHERE  Category = 'Furniture');

----- find orders where sales is greather than any sales in technology
SELECT [Order ID],
       Sales
FROM   Orders$
WHERE  Sales > ANY (SELECT sales
                    FROM   Orders$
                    WHERE  Category = 'Technology');

----find customer whose total saler are  higher than avg of total sales per custoemr
SELECT   [Customer ID],
         sum(Sales) AS totalsales
FROM     Orders$
GROUP BY [Customer ID]
HAVING   sum(Sales) > (SELECT avg(totalsales)
                       FROM   (SELECT   sum(Sales) AS totalsales
                               FROM     Orders$
                               GROUP BY [Customer ID]) AS customerpersales);

--====== find all orders where sales are greather than thr average of the all sales of orders
USE SUPER_SAMPLESTORE;


GO
SELECT   [Order ID],
         Sales
FROM     Orders$
WHERE    sales > ALL (SELECT avg(Sales)
                      FROM   Orders$)
ORDER BY Sales ASC;

--- find all orders where profit is grather than average profit
SELECT [Order ID],
       Profit
FROM   Orders$
WHERE  Profit > ALL (SELECT avg(Profit)
                     FROM   Orders$);

--- find customers whose sales total sales is greather than the average product sales 
SELECT   [Customer ID],
         sum(Sales) AS totalsales
FROM     Orders$
GROUP BY [Customer ID]
HAVING   sum(Sales) > ALL (SELECT   avg(Sales)
                           FROM     Orders$
                           GROUP BY [Product ID]);

--- find orders whose sales is greather than  the minumum sales in dataset
SELECT   [Order ID],
         round(sales, 2) AS sales
FROM     Orders$
WHERE    round(Sales, 2) > ALL (SELECT round(min(Sales), 2) AS minsales
                                FROM   Orders$)
ORDER BY Sales ASC;

--- find order whose sales is less than maximum sales in the dataset
SELECT   [Order iD],
         Sales
FROM     Orders$
WHERE    sales < ALL (SELECT max(Sales) AS maxsales
                      FROM   Orders$)
ORDER BY sales DESC;

-- Find the customer who placed the order with the highest sales
SELECT [Customer ID],
       [customer name],
       [Order ID],
       Sales
FROM   Orders$
WHERE  Sales = (SELECT MAX(Sales) AS maxsales
                FROM   Orders$);

-- 8. Find the customer(s) who placed the order with the lowest Sales.
USE SUPER_SAMPLESTORE;


GO
SELECT [Customer ID],
       [Customer Name],
       Sales
FROM   Orders$
WHERE  Sales IN (SELECT min(Sales) AS minsales
                 FROM   Orders$);

-- 9. Find the product(s) with the highest Sales.
SELECT [Customer ID],
       [Customer Name],
       Region,
       [Product ID],
       Sales
FROM   Orders$
WHERE  Sales IN (SELECT max(Sales)
                 FROM   Orders$);

-- 10. Find the product(s) with the highest Profit.
SELECT [Product Name],
       Profit
FROM   Orders$
WHERE  Profit IN (SELECT max(Profit)
                  FROM   orders$);

-- 11. Find orders whose Sales is greater than the Sales of a specific Order ID.
SELECT   DISTINCT [Order ID],
                  sum(Sales)
FROM     Orders$
GROUP BY [Order ID]
HAVING   sum(sales) > ALL (SELECT   sum(Sales) AS totalsalesoforder
                           FROM     Orders$
                           WHERE    [Order ID] = 'CA-2016-152156'
                           GROUP BY [Order ID]);

SELECT *
FROM   Orders$;

-- 12. Find customers who have purchased products from the Technology category
SELECT DISTINCT [Customer ID],
                [Customer Name],
                Category
FROM   Orders$
WHERE  [Customer ID] IN (SELECT DISTINCT [Customer ID]
                         FROM   Orders$
                         WHERE  Category = 'Technology')
       AND Category = 'Technology';

-- 13. Find customers who have never purchased products from the Technology category.
SELECT [Customer ID],
       Category,
       [Product Name]
FROM   Orders$
WHERE  [Customer ID] NOT IN (SELECT DISTINCT [Customer ID]
                             FROM   orders$
                             WHERE  Category = 'Technology');

-- 14. Find products that have been ordered by customers from the Consumer segment.
SELECT [Customer ID],
       Segment,
       [Product Name]
FROM   orders$
WHERE  [Customer ID] IN (SELECT DISTINCT [Customer ID]
                         FROM   Orders$
                         WHERE  Segment = 'Consumer');

-- 15. Find orders placed by customers who have made
--     at least one order in the West region.
SELECT [Order ID],
       [Customer ID],
       [Customer Name],
       Region,
       Sales
FROM   Orders$
WHERE  [Customer ID] IN (SELECT DISTINCT [Customer ID]
                         FROM   Orders$
                         WHERE  Region = 'West');

-- =========================
-- 🟡 LEVEL 2 — IN, NOT IN, ANY, ALL
-- =========================
-- 16. Find customers who have purchased from both Furniture and Technology.
SELECT [Customer ID],
       [Customer Name],
       Category
FROM   Orders$
WHERE  [Customer ID] IN (SELECT [Customer ID]
                         FROM   orders$
                         WHERE  Category = 'Furniture'
                                AND Category = 'Technolohy');

-- 17. Find customers who have purchased from Technology but never from Furniture.
SELECT [Customer ID],
       Category
FROM   Orders$
WHERE  [Customer ID] IN (SELECT [Customer ID]
                         FROM   Orders$
                         WHERE  Category = 'Technology'
                                AND [Customer ID] NOT IN (SELECT [Customer ID]
                                                          FROM   orders$
                                                          WHERE  Category = 'Furniture'));

-- 18. Find products whose Sales are greater than ANY Sales in the Furniture category.
SELECT [Product Name],
       Sales
FROM   Orders$
WHERE  sales > ANY (SELECT Sales
                    FROM   Orders$
                    WHERE  Category = 'Furniture');

-- 19. Find products whose Sales are greater than ALL Sales in the Furniture category.
SELECT [Product Name],
       Sales
FROM   Orders$
WHERE  sales > ALL (SELECT Sales
                    FROM   orders$
                    WHERE  Category = 'Furniture');

-- 20. Find orders whose Profit is greater than ANY Profit from the Technology category.
SELECT [Order ID],
       Profit
FROM   Orders$
WHERE  Profit > ANY (SELECT Profit
                     FROM   Orders$
                     WHERE  Category = 'Technology');

-- 21. Find orders whose Profit is greater than ALL Profits from the Technology category.
SELECT [Order ID],
       Profit
FROM   Orders$
WHERE  Profit > ALL (SELECT Profit
                     FROM   Orders$
                     WHERE  Category = 'Technology');

-- there is no any such orders which is  greather than  to all profit of the Technology
-- 22. Find customers whose total Sales are greater than ALL
--     individual customer Sales in the Consumer segment.
SELECT   [Customer ID],
         [Customer Name],
         SUM(Sales) AS TotalSales
FROM     Orders$
GROUP BY [Customer ID], [Customer Name]
HAVING   SUM(Sales) > ALL (SELECT   SUM(Sales) AS ConSales
                           FROM     Orders$
                           WHERE    Segment = 'Consumer'
                           GROUP BY [Customer ID]);

-- 23. Find products whose total Sales are greater than ANY product Sales
--     in the Office Supplies category.
SELECT   [Product ID],
         [Product Name],
         sum(Sales) AS Highersalesproduct
FROM     Orders$
GROUP BY [Product ID], [Product Name]
HAVING   sum(sales) > ANY (SELECT   sum(Sales) AS Offsales
                           FROM     orders$
                           WHERE    Category = 'Office Supplies'
                           GROUP BY [Product ID])
ORDER BY Highersalesproduct DESC;

-- 24. Find categories whose total Sales are greater than ANY category Sales
--     in a comparison.
SELECT   Category,
         sum(Sales) AS CathighsalesGen
FROM     orders$
GROUP BY Category
HAVING   sum(sales) > ANY (SELECT   sum(Sales) AS catsales
                           FROM     orders$
                           GROUP BY Category);

-- 25. Find regions whose total Sales are greater than ALL Sales
--     of a specified region's individual orders.
SELECT   Region,
         sum(sales) AS HigherSalesGenRegion
FROM     Orders$
GROUP BY Region
HAVING   sum(Sales) > ALL (SELECT Sales
                           FROM   Orders$
                           WHERE  Region = 'West');

-- 26. Find customers who have ordered every category present in the dataset.
SELECT   [Customer ID],
         [Customer Name]
FROM     Orders$
GROUP BY [Customer ID], [Customer Name]
HAVING   COUNT(DISTINCT Category) = (SELECT COUNT(DISTINCT Category)
                                     FROM   Orders$);

-- 27. Find customers who have ordered from all three categories:
--     Furniture, Office Supplies, and Technology.
SELECT DISTINCT [Customer ID],
                [Customer Name],
                Category
FROM   orders$
WHERE  [Customer ID] IN (SELECT DISTINCT [Customer ID]
                         FROM   Orders$
                         WHERE  Category = 'Furniture'
                                AND [Customer ID] IN (SELECT DISTINCT [Customer ID]
                                                      FROM   Orders$
                                                      WHERE  Category = 'Technology'
                                                             AND [Customer ID] IN (SELECT DISTINCT [Customer ID]
                                                                                   FROM   orders$
                                                                                   WHERE  Category = 'Office Supplies')));

-- =========================
-- 🟠 LEVEL 3 — AGGREGATE + SUBQUERIES
-- =========================
-- 28. Find customers whose total Sales is greater than the average total Sales per customer.
SELECT   [Customer ID],
         [Customer Name],
         SUM(Sales) AS TotalSales
FROM     Orders$
GROUP BY [Customer ID], [Customer Name]
HAVING   SUM(Sales) > (SELECT AVG(TotalSales)
                       FROM   (SELECT   [Customer ID],
                                        SUM(Sales) AS TotalSales
                               FROM     Orders$
                               GROUP BY [Customer ID]) AS cussales);

-- 29. Find customers whose total Profit is greater than the average total Profit per customer.
SELECT   [Customer ID],
         [Customer Name],
         SUM(Profit) AS TotalSales
FROM     Orders$
GROUP BY [Customer ID], [Customer Name]
HAVING   SUM(Profit) > (SELECT AVG(TotalSales)
                        FROM   (SELECT   [Customer ID],
                                         SUM(Profit) AS TotalSales
                                FROM     Orders$
                                GROUP BY [Customer ID]) AS cussales);

-- 30. Find products whose total Sales is greater than the average total Sales per product.
SELECT   [Product ID],
         [Product Name],
         SUM(Sales) AS TotalSales
FROM     Orders$
GROUP BY [Product ID], [Product Name]
HAVING   SUM(Sales) > (SELECT AVG(TotalSales)
                       FROM   (SELECT   [Product ID],
                                        SUM(Sales) AS TotalSales
                               FROM     Orders$
                               GROUP BY [Product ID]) AS ProductSales);

-- 31. Find categories whose average order Sales is greater than the overall average order Sales.
SELECT   Category,
         AVG(Sales) AS AvgCategorySales
FROM     Orders$
GROUP BY Category
HAVING   AVG(Sales) > (SELECT AVG(Sales)
                       FROM   Orders$);

-- 32. Find sub-categories whose total Profit is greater than the average total Profit
--     of all sub-categories.
SELECT   [Sub-Category],
         sum(Profit) AS totalprofit
FROM     Orders$
GROUP BY [Sub-Category]
HAVING   sum(Profit) > (SELECT avg(totalprofit)
                        FROM   (SELECT   [Sub-Category],
                                         sum(Profit) AS totalprofit
                                FROM     Orders$
                                GROUP BY [Sub-Category]) AS t);

-- 33. Find regions whose total Sales is greater than the average Sales across all regions.
SELECT   Region,
         sum(sales) AS regionalsales
FROM     Orders$
GROUP BY Region
HAVING   sum(Sales) > (SELECT avg(regiontotal) AS regoinalsales
                       FROM   (SELECT   sum(sales) AS regiontotal
                               FROM     orders$
                               GROUP BY Region) AS region);

-- 34. Find customers whose order count is greater than the average order count per customer.
SELECT   [Customer ID],
         [Customer Name],
         COUNT([Order ID]) AS orders
FROM     Orders$
GROUP BY [Customer ID], [Customer Name]
HAVING   COUNT([Order ID]) > (SELECT avg(orderpercustomer)
                              FROM   (SELECT   count([Order ID]) AS orderpercustomer
                                      FROM     Orders$
                                      GROUP BY [Customer ID]) AS totalorders)
ORDER BY orders ASC;

-- 35. Find products whose order count is greater than the average product order count.
SELECT   [Product Name],
         COUNT([Order ID]) AS highestorders
FROM     orders$
GROUP BY [Product ID], [Product Name]
HAVING   count([Order ID]) > (SELECT avg(totalorders)
                              FROM   (SELECT   COUNT([Order ID]) AS totalorders
                                      FROM     Orders$
                                      GROUP BY [Product ID]) AS totalorerd)
ORDER BY highestorders ASC;

-- 36. Find customers whose average order Sales is greater than the overall average order Sales.
SELECT   [Customer ID],
         [Customer Name],
         sum(Sales) AS totalsales
FROM     Orders$
GROUP BY [Customer ID], [Customer Name]
HAVING   sum(Sales) > (SELECT avg(totalsales)
                       FROM   (SELECT   sum(sales) AS totalsales
                               FROM     Orders$
                               GROUP BY [Customer ID]) AS t)
ORDER BY totalsales ASC;

-- 37. Find sub-categories whose average Profit is greater than the overall average Profit.
SELECT   [Sub-Category],
         sum(Profit) AS totalprofit
FROM     Orders$
GROUP BY [Sub-Category]
HAVING   sum(Profit) > (SELECT avg(totalprofit)
                        FROM   (SELECT   sum(profit) AS totalprofit
                                FROM     Orders$
                                GROUP BY [Sub-Category]) AS t)
ORDER BY totalprofit ASC;

-- 38. Find categories where total Sales is greater than the average category Sales.
SELECT   Category,
         sum(Sales) AS totalsales
FROM     Orders$
GROUP BY Category
HAVING   sum(Sales) > (SELECT avg(totalsales)
                       FROM   (SELECT   sum(Sales) AS totalsales
                               FROM     Orders$
                               GROUP BY Category) AS t);

-- 39. Find regions where total Profit is greater than the average region Profit.
SELECT   Region,
         sum(Profit) AS totalprofit
FROM     Orders$
GROUP BY Region
HAVING   sum(Profit) > (SELECT avg(totalprofit)
                        FROM   (SELECT   sum(Profit) AS totalprofit
                                FROM     Orders$
                                GROUP BY Region) AS t)
ORDER BY totalprofit ASC;

-- 40. Find customers whose maximum order Sales is greater than the average maximum
SELECT   [Customer ID],
         [Customer Name],
         max(sales) AS maxsales
FROM     orders$
GROUP BY [Customer Name], [Customer ID]
HAVING   max(Sales) > (SELECT avg(maxsales)
                       FROM   (SELECT   max(Sales) AS maxsales
                               FROM     Orders$
                               GROUP BY [Customer ID]) AS t)
ORDER BY maxsales ASC;

--     order Sales across customers.
-- =========================
-- 🔴 LEVEL 4 — CORRELATED SUBQUERIES
-- =========================
-- 41. Find orders whose Sales is greater than the average Sales of orders
--     made by the same customer.
SELECT [Customer ID],
       [Order ID],
       Sales
FROM   Orders$ AS o
WHERE  Sales > (SELECT AVG(Sales)
                FROM   Orders$ AS o2
                WHERE  o2.[Customer ID] = o.[Customer ID]);

-- 42. Find orders whose Sales is greater than the average Sales
--     of orders in the same Region.
SELECT Region,
       [Order ID],
       Sales
FROM   Orders$ AS o
WHERE  Sales > (SELECT AVG(Sales)
                FROM   Orders$ AS o2
                WHERE  o2.Region = o.Region);

-- 43. Find products whose Sales is greater than the average Sales of products
--     in the same Category.
SELECT   [Product ID],
         [Product Name],
         Category,
         Sales
FROM     Orders$ AS o
WHERE    sales > (SELECT avg(sales) AS avgsales
                  FROM   Orders$ AS o2
                  WHERE  o2.Category = o.Category)
GROUP BY [Product ID], [Product Name], [Order ID], Category, Sales;

-- 44. Find orders whose Profit is greater than the average Profit
--     for their Category.
SELECT   [Order ID],
         sum(Profit) AS totalprofit
FROM     Orders$ AS o
WHERE    profit > (SELECT avg(profit) AS avgprofit
                   FROM   Orders$ AS o2
                   WHERE  o2.Category = o.Category)
GROUP BY [Order ID], Category
ORDER BY totalprofit DESC;

-- 45. Find customers whose total Sales is greater than the average total Sales
--     of customers in the same Region.
USE SUPER_SAMPLESTORE;


GO
SELECT   t1.[Customer ID],
         t1.[Customer Name],
         SUM(t1.Sales) AS totalsales,
         t1.Region
FROM     Orders$ AS t1
GROUP BY t1.[Customer ID], t1.[Customer Name], t1.Region
HAVING   SUM(sales) > (SELECT AVG(totalsales)
                       FROM   (SELECT   SUM(Sales) AS totalsales
                               FROM     Orders$ AS t2
                               WHERE    t2.Region = t1.Region
                               GROUP BY t2.[Customer ID]) AS regionsales);

-- 46. Find products whose total Sales is greater than the average product Sales
--     within their Sub-Category.
SELECT   t.[Product ID],
         t.[Product Name],
         t.[Sub-Category],
         SUM(t.Sales) AS totalsales
FROM     Orders$ AS t
GROUP BY t.[Product ID], t.[Product Name], t.[Sub-Category]
HAVING   SUM(Sales) > (SELECT AVG(totalsales) AS avgsales
                       FROM   (SELECT   SUM(sales) AS totalsales
                               FROM     orders$ AS t2
                               WHERE    t2.[Sub-Category] = t.[Sub-Category]
                               GROUP BY t2.[Product ID], t2.[Product Name]) AS productsales);

-- 47. Find orders whose Sales is greater than the average Sales of orders
--     placed by the same customer.
SELECT o.[Customer ID],
       [Customer Name],
       o.[Order ID],
       o.Sales
FROM   Orders$ AS o
WHERE  sales > (SELECT AVG(c.Sales) AS avgsales
                FROM   Orders$ AS C
                WHERE  c.[Customer ID] = o.[Customer ID]);

-- 48. Find customers who have at least one order whose Sales is greater
--     than the average Sales of that customer's orders.
SELECT DISTINCT o.[Customer ID],
                o.[Customer Name]
FROM   Orders$ AS o
WHERE  EXISTS (SELECT 1
               FROM   Orders$ AS c
               WHERE  c.[Customer ID] = o.[Customer ID]
                      AND c.Sales > (SELECT AVG(c2.Sales)
                                     FROM   Orders$ AS c2
                                     WHERE  c2.[Customer ID] = c.[Customer ID]));

-- 49. Find products that have at least one order with Profit greater than
--     the average Profit of orders for that product.
SELECT DISTINCT o.[Product ID],
                o.[Product Name]
FROM   Orders$ AS o
WHERE  EXISTS (SELECT 1
               FROM   Orders$ AS c
               WHERE  c.[Product ID] = o.[Product ID]
                      AND c.Profit > (SELECT AVG(c2.Profit) AS avgprofit
                                      FROM   Orders$ AS c2
                                      WHERE  c2.[Product ID] = c.[Product ID]));

-- 50. Find customers whose latest order Sales is greater than
--     their own average order Sales.
SELECT DISTINCT o.[Customer ID],
                o.[Customer Name],
                o.Sales
FROM   Orders$ AS o
WHERE  EXISTS (SELECT 1
               FROM   Orders$ AS c
               WHERE  c.[Customer ID] = o.[Customer ID]
                      AND c.Sales > (SELECT avg(c2.Sales) AS avgsales
                                     FROM   Orders$ AS c2
                                     WHERE  c2.[Customer ID] = c.[Customer ID]));

-- =========================
-- 🔥 LEVEL 5 — ADVANCED SUBQUERIES
-- =========================
-- 51. Find the second-highest Sales order using a subquery.
SELECT max(sales) AS secondhighest
FROM   orders$
WHERE  Sales < (SELECT max(Sales) AS firsthighest
                FROM   Orders$);

-- 52. Find the third-highest Sales order using a subquery.
SELECT max(Sales) AS thirdhighest
FROM   Orders$
WHERE  sales < (SELECT max(sales) AS secondhighest
                FROM   orders$
                WHERE  Sales < (SELECT max(Sales) AS firsthighest
                                FROM   Orders$));

-- 53. Find the second-highest customer by total Sales.
SELECT   [Customer ID],
         sum(Sales) AS third
FROM     Orders$
GROUP BY [Customer ID]
HAVING   sum(Sales) = (SELECT max(totalsales)
                       FROM   (SELECT   [Customer ID],
                                        sum(Sales) AS totalsales
                               FROM     orders$
                               GROUP BY [Customer ID]) AS t1
                       WHERE  totalsales < (SELECT max(totalsales)
                                            FROM   (SELECT   sum(sales) AS totalsales
                                                    FROM     Orders$
                                                    GROUP BY [Customer ID]) AS t2));

USE SUPER_SAMPLESTORE;


GO
-- 54. Find the third-highest customer by total Sales.
SELECT [Customer ID],
       totalsales
FROM   (SELECT   [Customer ID],
                 SUM(Sales) AS totalsales
        FROM     Orders$
        GROUP BY [Customer ID]) AS c
WHERE  totalsales = (SELECT max(totalsales)
                     FROM   (SELECT   sum(Sales) AS totalsales
                             FROM     Orders$
                             GROUP BY [Customer ID]) AS x
                     WHERE  totalsales < (SELECT max(totalsales)
                                          FROM   (SELECT   sum(sales) AS totalsales
                                                  FROM     Orders$
                                                  GROUP BY [Customer ID]) AS y
                                          WHERE  totalsales < (SELECT max(totalsales)
                                                               FROM   (SELECT   sum(sales) AS totalsales
                                                                       FROM     Orders$
                                                                       GROUP BY [Customer ID]) AS z)));

-- 55. Find the customer with the second-highest total Profit.
SELECT [Customer ID],
       totalprofit
FROM   (SELECT   [Customer ID],
                 SUM(Profit) AS totalprofit
        FROM     Orders$
        GROUP BY [Customer ID]) AS c
WHERE  totalprofit = (SELECT max(totalprofit)
                      FROM   (SELECT   sum([Profit]) AS totalprofit
                              FROM     Orders$
                              GROUP BY [Customer ID]) AS x
                      WHERE  totalprofit < (SELECT max(totalprofit)
                                            FROM   (SELECT   sum(Profit) AS totalprofit
                                                    FROM     Orders$
                                                    GROUP BY [Customer ID]) AS y));

-- 56. Find the highest-selling product in each Category using a correlated subquery.
SELECT   [Product ID],
         [Product Name],
         Category,
         SUM(Sales) AS TotalSales
FROM     Orders$ AS o
GROUP BY [Product ID], [Product Name], Category
HAVING   SUM(Sales) >= ALL (SELECT   SUM(Sales)
                            FROM     Orders$ AS o2
                            WHERE    o2.Category = o.Category
                            GROUP BY [Product ID]);

-- 57. Find the highest-profit product in each Sub-Category using a correlated subquery.
SELECT   [Product ID],
         [Product Name],
         [Sub-Category],
         SUM(Profit) AS TotalProfit
FROM     Orders$ AS o
GROUP BY [Product ID], [Product Name], [Sub-Category]
HAVING   SUM(Profit) >= ALL (SELECT   SUM(Profit)
                             FROM     Orders$ AS o2
                             WHERE    o2.[Sub-Category] = o.[Sub-Category]
                             GROUP BY [Product ID]);

-- 58. Find the customer who has placed the most orders in each Region.
SELECT   [Customer ID],
         Region,
         COUNT(DISTINCT [Order ID]) AS OrderCount
FROM     Orders$ AS o
GROUP BY [Customer ID], Region
HAVING   COUNT(DISTINCT [Order ID]) >= ALL (SELECT   COUNT(DISTINCT [Order ID])
                                            FROM     Orders$ AS o2
                                            WHERE    o2.Region = o.Region
                                            GROUP BY [Customer ID]);

-- 59. Find customers who have placed more orders than every customer
--     in the Consumer segment.
SELECT   DISTINCT [Customer ID],
                  COUNT(DISTINCT [Order ID]) AS totalord
FROM     Orders$ AS o
GROUP BY [Customer ID]
HAVING   COUNT(DISTINCT [Order ID]) > ALL (SELECT   COUNT(DISTINCT [Order ID]) AS totalord
                                           FROM     Orders$ AS c
                                           WHERE    c.Segment = 'Consumer'
                                           GROUP BY [Customer ID]);

-- 60. Find customers whose total Sales are greater than the average total Sales
--     of customers who have purchased Technology products.
SELECT   [Customer ID],
         [Customer Name],
         sum(sales) AS totalsales
FROM     Orders$
GROUP BY [Customer ID], [Customer Name]
HAVING   sum(sales) > (SELECT avg(totalsales)
                       FROM   (SELECT   sum(sales) AS totalsales
                               FROM     Orders$ AS o
                               WHERE    [Customer ID] IN (SELECT DISTINCT [Customer ID]
                                                          FROM   Orders$
                                                          WHERE  Category = 'Technology')
                               GROUP BY [Customer ID]) AS x)
ORDER BY totalsales DESC;

-- =========================
-- 💀 BONUS — INTERVIEW LEVEL
-- =========================
-- 61. Find customers who have never ordered Office Supplies.
SELECT [Customer ID],
       [Customer Name],
       [Order ID],
       Category
FROM   Orders$
WHERE  [Customer ID] NOT IN (SELECT DISTINCT [Customer ID]
                             FROM   Orders$
                             WHERE  Category = 'Office Supplies');

-- 62. Find customers who ordered Furniture but never Technology.
SELECT DISTINCT [Customer ID],
                category
FROM   orders$
WHERE  [Customer ID] IN (SELECT [Customer ID]
                         FROM   Orders$
                         WHERE  Category = 'Furniture')
       AND [Customer ID] NOT IN (SELECT [Customer ID]
                                 FROM   Orders$
                                 WHERE  category = 'Technology');

--Q63. Products whose total Sales are greater than the average total Sales of products in their Category
SELECT   DISTINCT [Product ID],
                  [Product Name],
                  Category,
                  SUM(Sales) AS totalsales
FROM     Orders$ AS o
GROUP BY Category, [Product ID], [Product Name]
HAVING   SUM(sales) > (SELECT AVG(totalsales)
                       FROM   (SELECT   [Product ID],
                                        Category,
                                        SUM(sales) AS totalsales
                               FROM     Orders$
                               GROUP BY Category, [Product ID]) AS x
                       WHERE  x.category = o.category);

-- 64. Find the Category having the highest average order Sales.
SELECT   Category,
         AVG(Sales) AS totalsales
FROM     Orders$
GROUP BY Category
HAVING   AVG(sales) = (SELECT MAX(avgsales)
                       FROM   (SELECT   AVG(sales) AS avgsales
                               FROM     Orders$
                               GROUP BY Category) AS x);

-- 65. Find the Sub-Category having the highest total Profit.
SELECT   [Sub-Category],
         sum(profit) AS totalprofit
FROM     Orders$
GROUP BY [Sub-Category]
HAVING   sum(Profit) = (SELECT max(totalprofit)
                        FROM   (SELECT   sum(Profit) AS totalprofit
                                FROM     Orders$
                                GROUP BY [Sub-Category]) AS x);

-- 66. Find the customer with the highest Sales in each Region.
SELECT   [Customer ID],
         [Customer Name],
         Region,
         SUM(Sales) AS totalsales
FROM     Orders$ AS o
GROUP BY [Customer Name], [Customer ID], Region
HAVING   SUM(Sales) >= ALL (SELECT   SUM(sales) AS totalsales
                            FROM     Orders$ AS c
                            WHERE    c.Region = o.Region
                            GROUP BY [Customer Name], [Customer ID]);

-- 67. Find the customer with the highest Profit in each Category.
SELECT   [Customer ID],
         [Customer Name],
         Category,
         SUM(Profit) AS totalprofit
FROM     Orders$ AS o
GROUP BY [Customer ID], [Customer Name], Category
HAVING   SUM(Profit) >= ALL (SELECT   SUM(profit)
                             FROM     Orders$ AS c
                             WHERE    c.Category = o.Category
                             GROUP BY [Customer ID]);

-- 68. Find orders whose Sales is equal to the maximum Sales within their Region.
SELECT DISTINCT [Order ID],
                Region,
                Sales
FROM   orders$ AS o
WHERE  sales = (SELECT MAX(sales)
                FROM   Orders$ AS c
                WHERE  c.Region = o.Region);

-- 69. Find products whose total Sales is equal to the maximum product Sales
--     within their Category.
SELECT   [Product ID],
         [Product Name],
         Category,
         SUM(Sales) AS ts
FROM     Orders$ AS o
GROUP BY [Product ID], [Product Name], Category
HAVING   SUM(Sales) = (SELECT MAX(totalsales)
                       FROM   (SELECT   [Product ID],
                                        Category,
                                        SUM(sales) AS totalsales
                               FROM     Orders$ AS c
                               GROUP BY [Product ID], Category) AS x
                       WHERE  x.Category = o.Category);

-- 70. Find customers whose total Sales is greater than the average total Sales
--     of customers who placed more than 5 orders.
SELECT   DISTINCT [Customer ID],
                  [Customer Name],
                  sum(Sales) AS totalsales
FROM     Orders$
GROUP BY [Customer Name], [Customer ID]
HAVING   SUM(Sales) > (SELECT AVG(totalsales) AS avgsales
                       FROM   (SELECT   sum(sales) AS totalsales
                               FROM     Orders$
                               GROUP BY [Customer ID]
                               HAVING   count(DISTINCT [Order ID]) > 5) AS x)
ORDER BY totalsales ASC;

-- =========================================================
-- LEVEL 1 — BASIC EXISTS
-- =========================================================
-- 1. Find customers who have placed at least one order.
SELECT   [Customer ID],
         COUNT(DISTINCT [Order ID]) AS orders
FROM     orders$ AS o
WHERE    EXISTS (SELECT 1
                 FROM   Orders$ AS c
                 WHERE  c.[Customer ID] = o.[Customer ID])
GROUP BY [Customer ID];

-- 2. Find customers who have purchased at least one product
--    from Technology.
SELECT DISTINCT [Customer Name]
FROM   Orders$ AS o
WHERE  EXISTS (SELECT 1
               FROM   Orders$ AS p
               WHERE  p.[Customer ID] = o.[Customer ID]
                      AND p.Category = 'Technology');

-- 3. Find customers who have purchased at least one product
--    from Furniture.
SELECT DISTINCT [Customer Name]
FROM   Orders$ AS o
WHERE  EXISTS (SELECT 1
               FROM   Orders$ AS c
               WHERE  c.[Customer ID] = o.[Customer ID]
                      AND c.Category = 'Furniture');

-- 4. Find products that have been ordered by at least one customer.
SELECT DISTINCT [Product Name]
FROM   Orders$ AS o
WHERE  EXISTS (SELECT 1
               FROM   Orders$ AS c
               WHERE  c.[Product ID] = o.[Product ID]);

-- 5. Find orders placed by customers who have at least one
--    other order.
SELECT DISTINCT [Order ID],
                [Customer ID]
FROM   Orders$ AS o
WHERE  EXISTS (SELECT 1
               FROM   Orders$ AS c
               WHERE  c.[Customer ID] = o.[Customer ID]
                      AND c.[Order ID] <> o.[Order ID]);

-- 6. Find customers who have placed an order with Sales greater than 1,000.
SELECT DISTINCT [Customer ID]
FROM   Orders$ AS o
WHERE  EXISTS (SELECT 1
               FROM   Orders$ AS c
               WHERE  c.[Customer ID] = o.[Customer ID]
                      AND c.sales > 1000);

-- 7. Find customers who have placed at least one order
--    in the West region.
SELECT DISTINCT [Customer ID]
FROM   Orders$ AS o
WHERE  EXISTS (SELECT *
               FROM   Orders$ AS r
               WHERE  r.[Customer ID] = o.[Customer ID]
                      AND r.Region = 'West');

-- 8. Find products that have generated positive Profit
--    in at least one order.
SELECT DISTINCT [Product ID],
                [Product Name],
                Profit
FROM   Orders$ AS o
WHERE  EXISTS (SELECT *
               FROM   Orders$ AS p
               WHERE  p.[Product ID] = o.[Product ID]
                      AND p.[Profit] > 0);

-- =========================================================
-- LEVEL 2 — EXISTS + NOT EXISTS
-- =========================================================
-- 9. Find customers who have never purchased Technology.
SELECT DISTINCT [Customer ID],
                [Customer Name],
                Category
FROM   Orders$ AS o
WHERE  NOT EXISTS (SELECT 1
                   FROM   Orders$ AS c
                   WHERE  c.[Customer ID] = o.[Customer ID]
                          AND c.Category = 'Technology');

-- 10. Find customers who have purchased Furniture
--     but never purchased Technology.
SELECT DISTINCT [Customer ID],
                [Customer Name],
                Category
FROM   Orders$ AS o
WHERE  EXISTS (SELECT 1
               FROM   Orders$ AS c
               WHERE  c.[Customer ID] = o.[Customer ID]
                      AND c.Category = 'Furniture')
       AND NOT EXISTS (SELECT *
                       FROM   Orders$ AS c
                       WHERE  c.[Customer ID] = o.[Customer ID]
                              AND c.Category = 'Technology');

-- 11. Find customers who have never placed an order
--     for the Consumer segment.
SELECT DISTINCT [Customer ID],
                Segment
FROM   Orders$ AS o
WHERE  NOT EXISTS (SELECT 1
                   FROM   Orders$ AS c
                   WHERE  c.[Customer ID] = o.[Customer ID]
                          AND c.Segment = 'Consumer');

-- 12. Find products that have never generated negative Profit.
SELECT DISTINCT [Product ID],
                [Product Name]
FROM   Orders$ AS o
WHERE  NOT EXISTS (SELECT 1
                   FROM   Orders$ AS c
                   WHERE  c.[Product ID] = o.[Product ID]
                          AND c.Profit < 0);

-- 13. Find customers who have never placed an order
--     with Sales below 100.
SELECT DISTINCT [Customer ID],
                [Customer Name],
                Sales
FROM   Orders$ AS o
WHERE  NOT EXISTS (SELECT 1
                   FROM   Orders$ AS c
                   WHERE  c.[Customer ID] = o.[Customer ID]
                          AND c.Sales < 100);

-- 14. Find customers who purchased Technology
--     but never purchased Furniture.
SELECT DISTINCT [Customer ID],
                [Customer Name],
                Category
FROM   Orders$ AS o
WHERE  EXISTS (SELECT 1
               FROM   Orders$ AS c
               WHERE  c.[Customer ID] = o.[Customer ID]
                      AND c.Category = 'Technology')
       AND NOT EXISTS (SELECT 1
                       FROM   Orders$ AS c1
                       WHERE  c1.[Customer ID] = o.[Customer ID]
                              AND c1.Category = 'Furniture');

-- 15. Find products that were ordered but never
--     generated negative Profit.
SELECT DISTINCT [Product ID],
                [Product Name],
                Profit
FROM   Orders$ AS o
WHERE  EXISTS (SELECT 1
               FROM   Orders$ AS c
               WHERE  c.[Product ID] = o.[Product ID])
       AND NOT EXISTS (SELECT 1
                       FROM   Orders$ AS c2
                       WHERE  c2.[Product ID] = o.[Product ID]
                              AND c2.Profit < 0);

-- =========================================================
-- LEVEL 3 — CORRELATED EXISTS
-- =========================================================
-- 16. Find customers who have at least one order
--     with Sales greater than their own average Sales.
SELECT DISTINCT [Customer Name],
                Sales
FROM   orders$ AS o
WHERE  EXISTS (SELECT 1
               FROM   Orders$ AS c
               WHERE  c.[Customer ID] = o.[Customer ID]
                      AND c.sales > (SELECT AVG(sales) AS avgsales
                                     FROM   Orders$ AS o1
                                     WHERE  o1.[Customer ID] = o.[Customer ID]));



-- 17. Find customers who have at least one order
--     with Profit greater than their own average Profit.

SELECT DISTINCT [Customer ID] ,Profit FROM Orders$ as o
WHERE EXISTS(
        select 1
        from Orders$ as c
        WHERE c.[Customer ID]=o.[Customer ID]
        AND c.Profit>(
                select  avg(c1.Profit) from Orders$ as c1
                WHERE c1.[Customer ID]=o.[Customer ID]
        )
)





-- 18. Find customers who have at least one order
--     in every year present in the dataset.

SELECT * FROM Orders$ as o
WHERE EXISTS(
        SELECT 1
        FROM Orders$ as c1
        WHERE c1.[Customer ID]=o.[Customer ID]
        AND c1.[Customer ID] in(
                select [Customer ID] from Orders$  as c2
                WHERE c2.[Customer ID]=o.[Customer ID]
                GROUP BY c2.[Order Date]
        )
)




SELECT DISTINCT o.[Customer ID]
FROM Orders$ AS o
WHERE NOT EXISTS (
    SELECT 1
    FROM (
        SELECT DISTINCT YEAR([Order Date]) AS OrderYear
        FROM Orders$
    ) AS y
    WHERE NOT EXISTS (
        SELECT 1
        FROM Orders$ AS o2
        WHERE o2.[Customer ID] = o.[Customer ID]
          AND YEAR(o2.[Order Date]) = y.OrderYear
    )
);




-- 19. Find customers who have at least one order
--     in both Furniture and Technology.

SELECT DISTINCT [Customer ID],Category
FROM Orders$ as o
where EXISTS(
        SELECT 1
        FROM Orders$ as c
        WHERE c.[Customer ID]=o.[Customer ID]
        AND c.Category='Furniture'
)

and EXISTS(
        SELECT  1
         FROM Orders$ as c2
        WHERE c2.[Customer ID]=o.[Customer ID]
        AND c2.Category='Technology'
)



-- 20. Find customers who have at least one order
--     in Technology and at least one order
--     in Office Supplies.


SELECT DISTINCT [Customer Name] FROM Orders$ as  o
WHERE EXISTS(
        SELECT 1
         FROM Orders$ as c1
        WHERE c1.[Customer ID]=o.[Customer ID]
        and c1.Category='Technology'
)
AND EXISTS(
        SELECT 1
         FROM Orders$ as c2
        WHERE c2.[Customer ID]=o.[Customer ID]
        AND c2.Category='Office Supplies'
)


-- 21. Find customers who have at least one order
--     with Sales greater than 1,000 in their own Region.


SELECT DISTINCT [Customer ID],Region FROM Orders$  as o
WHERE EXISTS(
        SELECT Sales
        from Orders$ as c1
        WHERE c1.[Customer ID]=o.[Customer ID]
        AND c1.Region=o.Region
        and c1.sales>1000

)






-- 22. Find products that have at least one order
--     with Profit greater than the average Profit
--     for that product.

SELECT DISTINCT [Product ID],[Product Name] FROM  Orders$ as o
WHERE EXISTS(
        SELECT 1
        FROM  Orders$ as c
        where c.[Product ID]=o.[Product ID]
        and c.Profit>(
                SELECT avg(c2.Profit)  FROM Orders$ as c2
                WHERE c2.[Product ID]=o.[Product ID]

        )
)





-- =========================================================
-- LEVEL 4 — INTERVIEW / ADVANCED
-- =========================================================
-- 23. Find customers who have purchased all three Categories:
--     Furniture, Office Supplies, and Technology.

SELECT DISTINCT [Customer ID],[Customer Name],Category FROM Orders$ as o
WHERE  EXISTS(
        SELECT 1
        FROM Orders$ as c
        WHERE c.[Customer ID]=o.[Customer ID]
        AND
        c.category='Technology'
)
and EXISTS(
        SELECT * FROM Orders$ as c1
        WHERE c1.[Customer ID]=o.[Customer ID]
        AND
         c1.category='Office Supplies'
)
and EXISTS(
        SELECT * FROM Orders$ as c2
        WHERE c2.[Customer ID]=o.[Customer ID]
        AND
        c2.category='Furniture'
)





-- 24. Find customers who have purchased Furniture
--     but not Office Supplies or Technology.

SELECT DISTINCT [Customer Name],Category FROM  Orders$ as o
where EXISTS(
        SELECT * FROM Orders$ as c
        WHERE  c.[Customer ID]=o.[Customer ID]
        AND
        c.Category='Furniture'
)
and not EXISTS(
        SELECT 1
        from orders$ as c2
        WHERE c2.[Customer ID]=o.[Customer ID]
        AND c2.Category='Office Supplies'
)
and not EXISTS(
        SELECT 1
        FROM Orders$ as c3
        WHERE c3.[Customer ID]=o.[Customer ID]
        AND c3.Category='Technology'
)




-- 25. Find customers who have at least one returned order.
--     Use Returns$ if the Returns table is available.

SELECT DISTINCT [Customer Name] FROM Orders$ as o
WHERE EXISTS(
        SELECT 1
        FROM Returns$ as r
        WHERE r.[Order ID]=o.[Order ID] 
)




-- 26. Find customers who have placed at least one order
--     in the same Region as another customer.

SELECT DISTINCT o.[Customer Name] FROM  Orders$ as o
WHERE EXISTS(
        SELECT 1
         FROM Orders$ as c
        WHERE c.Region=o.Region
        and c.[Customer ID]<>o.[Customer ID]
)




-- 27. Find customers whose latest order has Sales
--     greater than their previous orders.

SELECT DISTINCT [Customer Name] FROM orders$ as o
where EXISTS(
        SELECT 1
        FROM Orders$ as latest
        WHERE latest.[Customer ID]=o.[Customer ID]
        and not EXISTS(
                SELECT 1
                FROM Orders$ as previous
                where previous.[Customer ID]=latest.[Customer ID]
                AND previous.[Order Date]<latest.[Order Date]
                AND previous.Sales>=latest.Sales
        )


)



-- 28. Find products that have been purchased by at least
--     one customer from every Region.

SELECT DISTINCT o.[Product ID], o.[Product Name]
FROM Orders$ AS o
WHERE NOT EXISTS (
    SELECT 1
    FROM (
        SELECT DISTINCT Region
        FROM Orders$
    ) AS r
    WHERE NOT EXISTS (
        SELECT 1
        FROM Orders$ AS o2
        WHERE o2.[Product ID] = o.[Product ID]
          AND o2.Region = r.Region
    )
);



-- 29. Find customers who have purchased a product
--     that no other customer purchased.
-- 30. Find customers who have placed an order with Sales
--     greater than every order they previously placed.
-- =========================================================
-- LEVEL 5 — CHALLENGE
-- =========================================================
-- 31. Find customers who purchased Technology
--     but never Furniture,
--     using only WHERE EXISTS and WHERE NOT EXISTS.
-- 32. Find customers who purchased all Categories,
--     using nested EXISTS.
-- 33. Find customers who have more than one order,
--     using EXISTS with a correlated condition.
-- 34. Find customers who have at least one order whose Sales
--     is greater than every other order of that customer.
-- 35. Find products whose total Sales is greater than
--     the total Sales of at least one other product
--     in the same Category, using EXISTS.