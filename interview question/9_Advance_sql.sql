-- 91. Find the top 10% of customers by revenue and calculate their percentage contribution to total revenue.

with  customer_revanue as (
    SELECT [customer name],sum(sales)as revanue from orders$
    GROUP BY [customer name]
),
bucket as (

    SELECT *,NTILE(10) OVER(order by revanue DESC) as top_10 FROM customer_revanue
),
top_10_customer as (
    SELECT * FROM bucket
    WHERE top_10=1

),
total_Revanue as (
    SELECT sum(revanue) as total_revanue FROM customer_revanue
),
contribution as (
    SELECT t.*,round(t.revanue*100.0/r.total_revanue ,2) as cont FROM top_10_customer as t
    CROSS JOIN total_Revanue as r
)
SELECT * FROM contribution


--- two different approach to achieve this 

WITH customer_revenue AS (
    SELECT 
        [Customer Name],
        SUM(Sales) AS Revenue
    FROM Orders$
    GROUP BY [Customer Name]
),
customer_bucket AS (
    SELECT *,
        NTILE(10) OVER(ORDER BY Revenue DESC) AS bucket_no
    FROM customer_revenue
),
total_revenue AS (
    SELECT SUM(Sales) AS total_revenue
    FROM Orders$
)
SELECT 
    c.[Customer Name],
    c.Revenue,
    ROUND(c.Revenue * 100.0 / t.total_revenue, 2) 
        AS revenue_contribution
FROM customer_bucket AS c
CROSS JOIN total_revenue AS t
WHERE c.bucket_no = 1
ORDER BY c.Revenue DESC;


-- 92. Calculate average order value for each month.

WITH ct1 as (
    SELECT year([order date]) as year,month([order date]) as month,sum(sales)*1.0/count(DISTINCT [order id]) as average_ordervalue FROM orders$
    GROUP BY year([order date]),month([order date])
)
SELECT * FROM  ct1
ORDER BY year,month ASC


-- by  using the  simple quary concept to achieve this 


SELECT  year([order date]) as year,month([order date]) as month,sum(sales)*1.0/count(DISTINCT [order id]) as average_ordervalue  FROM orders$
GROUP BY year([order date]),month([order date])
ORDER BY year,month ASC



-- 93. Find months where revenue increased but average order value decreased.


WITH ct1 as (
    SELECT year([order date]) as year,month([order date]) as month,sum(sales) as revanue,sum(sales)*1.0/count(DISTINCT [order id]) as average_ordervalue FROM orders$
    GROUP BY year([order date]),month([order date])
),
ct2 as (
    SELECT *,lag(average_ordervalue) OVER(ORDER BY year,month ASC) as prev_AOV,
    lag(revanue) OVER(ORDER BY year,month asc) as prev_revanue FROM ct1
)
SELECT * FROM ct2
where average_ordervalue<prev_AOV
and revanue>prev_revanue
ORDER BY year,month ASC

-- 94. Find customers whose average order value is higher than the overall company AOV.

WITH ct1 as (
    SELECT [customer name],sum(sales)*1.0/count(DISTINCT [order id]) as Customer_AOV FROM orders$
    GROUP BY [customer name]
),
ct2 as (
    SELECT sum(sales)*1.0/count(DISTINCT [order id]) as overall_AOV FROM orders$
)
SELECT * FROM ct1 as c1
CROSS JOIN ct2 as c2
where c1.Customer_AOV>c2.overall_AOV
ORDER BY c1.Customer_AOV ASC



-- 95. Find the first year in which each customer generated more than $5,000 in cumulative revenue.

WITH yearly_revenue AS (
    SELECT
        [Customer Name],
        YEAR([Order Date]) AS Order_Year,
        SUM(Sales) AS Yearly_Revenue
    FROM Orders$
    GROUP BY
        [Customer Name],
        YEAR([Order Date])
),
cumulative_revenue AS (
    SELECT *,
        SUM(Yearly_Revenue) OVER (
            PARTITION BY [Customer Name]
            ORDER BY Order_Year
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS Cumulative_Revenue
    FROM yearly_revenue
),
first_year AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY [Customer Name]
            ORDER BY Order_Year
        ) AS rn
    FROM cumulative_revenue
    WHERE Cumulative_Revenue > 5000
)
SELECT
    [Customer Name],
    Order_Year AS First_Year,
    Cumulative_Revenue
FROM first_year
WHERE rn = 1
ORDER BY First_Year;



-- 96. Find customers whose latest year's revenue is higher than their historical average yearly revenue.


WITH ct1 AS (
    SELECT
        YEAR([Order Date]) AS order_year,
        [Customer Name],
        SUM(Sales) AS revenue
    FROM Orders$
    GROUP BY
        [Customer Name],
        YEAR([Order Date])
),
ct2 AS (
    SELECT *,
        ROW_NUMBER() OVER(
            PARTITION BY [Customer Name]
            ORDER BY order_year DESC
        ) AS rn
    FROM ct1
),
ct3 AS (
    SELECT
        [Customer Name],
        AVG(revenue) AS avg_revenue
    FROM ct1
    GROUP BY [Customer Name]
)
SELECT
    c2.[Customer Name],
    c2.order_year AS latest_year,
    c2.revenue AS latest_revenue,
    c3.avg_revenue
FROM ct2 AS c2
INNER JOIN ct3 AS c3
    ON c2.[Customer Name] = c3.[Customer Name]
WHERE c2.rn = 1
AND c2.revenue > c3.avg_revenue
ORDER BY c2.revenue DESC;


-- 97. Find regions where sales increased but customer count decreased.

WITH ct1 as (
    SELECT year([order date])as year, region,sum(sales) as revanue,count(DISTINCT [customer id]) as total_customer FROM orders$
    GROUP BY region,year([order date])
),
ct2 as (
    SELECT *,
    lag(revanue) OVER(ORDER BY year ASC) as prev_revanue,
    lag(total_customer) OVER(ORDER BY year) as prev_customer FROM ct1
)
SELECT * FROM ct2
where revanue>prev_revanue
and total_customer<prev_customer



-- 100. Find customers who generated more than 1% of the company's total revenue and calculate their contribution percentage.
WITH ct1 as (
    SELECT [customer name],sum(sales) as customer_revanue FROM orders$
    GROUP BY [customer name]
),
ct2 as (
    SELECT sum(customer_revanue) as total_revanue FROM ct1
)
SELECT c1.*,round(c1.customer_revanue*100.0/c2.total_revanue,2)as cont FROM ct1 as c1
CROSS JOIN ct2 as c2
where c1.customer_revanue*100.0/c2.total_revanue >1
ORDER BY cont DESC

