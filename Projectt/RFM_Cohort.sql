-- ============================================================
-- RFM ANALYSIS — BASIC TO INDUSTRY LEVEL
-- ============================================================

-- 1. Calculate Recency, Frequency, and Monetary value for every customer.
-- Business use: Creates the base RFM dataset.


WITH ct1 as (

    SELECT [Customer Name],
    datediff(day,
        max([order date]),
        (
            SELECT max([order date]) FROM orders$
        )
    ) as Recency,
    COUNT(DISTINCT [Order ID]) as frequancy,
    SUM(sales) as monetary
    FROM orders$
    GROUP BY [customer name]
)

SELECT * FROM ct1

-- 2. Calculate Recency as the number of days since each customer's
-- latest purchase relative to the maximum order date in the dataset.
-- Business use: Measures how recently customers were active.


SELECT [customer name],datediff(day,max([Order Date]),(
    SELECT max([Order Date]) from Orders$
)) as recency FROM Orders$
GROUP BY [customer name]
ORDER by recency DESC


-- 3. Calculate Frequency as the number of distinct orders placed
-- by each customer.
-- Business use: Measures purchase frequency.

SELECT [Customer Name],Count(DISTINCT [Order ID]) as frequancy FROM
Orders$
GROUP BY [Customer Name]
ORDER by frequancy DESC

-- 4. Calculate Monetary value as the total Sales generated
-- by each customer.
-- Business use: Measures customer revenue contribution.

SELECT [Customer Name], sum(sales) as monetary FROM Orders$
GROUP BY  [Customer Name]
ORDER by monetary DESC

-- 5. Assign each customer a Recency score from 1 to 5.
-- Business use: Converts raw recency into customer segments.


WITH ct1 as (SELECT [Customer Name],DATEDIFF(day,max([Order Date]),(
    SELECT max([Order Date]) from orders$
))  as recency FROM Orders$
GROUP BY [Customer Name])
SELECT *,NTILE(5) OVER(ORDER BY recency DESC) as bucket FROM ct1


-- 6. Assign each customer a Frequency score from 1 to 5.
-- Business use: Identifies frequent customers.
WITH ct1 as (

    SELECT [customer name],count(DISTINCT [order id]) as frequancy FROM orders$
    GROUP BY [customer name]
)
SELECT *,NTILE(5 ) OVER(ORDER BY frequancy DESC) as bucket FROM ct1


-- 7. Assign each customer a Monetary score from 1 to 5.
-- Business use: Identifies high-value customers.

WITH ct1 as (

    SELECT [customer name],sum(sales) as monetary FROM orders$
    GROUP BY [customer name]
)
SELECT *,NTILE(5 ) OVER(ORDER BY monetary DESC) as bucket FROM ct1


-- 8. Create a combined RFM score for every customer.
-- Business use: Creates a single customer-value indicator.

WITH ct1 as (

        SELECT [customer name],
        datediff(day,
        max([order date]),
        (
            SELECT max([order date]) FROM orders$
        )) as recency,
        count(DISTINCT [order id]) as frequancy,
        sum(sales) as monetary FROM  orders$
        GROUP BY [customer name]
    
),
ct2 as (

        SELECT *,
        ntile(5) OVER(ORDER BY recency DESC) as R_Score,
        ntile(5) OVER(ORDER BY frequancy DESC) as F_Score,
        ntile(5) OVER(ORDER BY monetary DESC) as M_Score FROM ct1
),
ct3 as (
        SELECT *,
        concat(
            R_Score,
            F_Score,
            M_Score
        )as RFM_Score,

        CASE
    WHEN R_Score >= 4 AND F_Score >= 4 AND M_Score >= 4
        THEN 'Champion'

    WHEN R_Score >= 3 AND F_Score >= 4 AND M_Score >= 4
        THEN 'Loyal Customers'

    WHEN R_Score >= 4 AND F_Score BETWEEN 2 AND 3 AND M_Score >= 3
        THEN 'Potential Loyalist'

    WHEN R_Score = 5 AND F_Score <= 2
        THEN 'Recent Customers'

    WHEN R_Score BETWEEN 3 AND 4 AND F_Score <= 2
        THEN 'Promising'

    WHEN R_Score <= 2 AND F_Score >= 4 AND M_Score >= 4
        THEN 'Cannot Lose Them'

    WHEN R_Score <= 2 AND F_Score >= 3
        THEN 'At Risk'

    WHEN R_Score <= 2 AND F_Score <= 2 AND M_Score >= 4
        THEN 'Hibernating High Spenders'

    WHEN R_Score <= 2 AND F_Score <= 2 AND M_Score <= 2
        THEN 'Lost Customers'

    WHEN R_Score BETWEEN 2 AND 3
         AND F_Score BETWEEN 2 AND 3
         AND M_Score BETWEEN 2 AND 3
        THEN 'Need Attention'

    ELSE 'Others'
    END AS Customer_Segment

        FROM ct2

)

SELECT * FROM ct3



-- 9. Find customers with the highest possible RFM score.
-- Business use: Identifies the company's best customers.


WITH ct1 as (

        SELECT [customer name],
        datediff(day,
        max([order date]),
        (
            SELECT max([order date]) FROM orders$
        )) as recency,
        count(DISTINCT [order id]) as frequancy,
        sum(sales) as monetary FROM  orders$
        GROUP BY [customer name]
    
),
ct2 as (

        SELECT *,
        ntile(5) OVER(ORDER BY recency DESC) as R_Score,
        ntile(5) OVER(ORDER BY frequancy DESC) as F_Score,
        ntile(5) OVER(ORDER BY monetary DESC) as M_Score FROM ct1
),
ct3 as (
        SELECT *,
        concat(
            R_Score,
            F_Score,
            M_Score
        )as RFM_Score,

        CASE
    WHEN R_Score >= 4 AND F_Score >= 4 AND M_Score >= 4
        THEN 'Champion'

    WHEN R_Score >= 3 AND F_Score >= 4 AND M_Score >= 4
        THEN 'Loyal Customers'

    WHEN R_Score >= 4 AND F_Score BETWEEN 2 AND 3 AND M_Score >= 3
        THEN 'Potential Loyalist'

    WHEN R_Score = 5 AND F_Score <= 2
        THEN 'Recent Customers'

    WHEN R_Score BETWEEN 3 AND 4 AND F_Score <= 2
        THEN 'Promising'

    WHEN R_Score <= 2 AND F_Score >= 4 AND M_Score >= 4
        THEN 'Cannot Lose Them'

    WHEN R_Score <= 2 AND F_Score >= 3
        THEN 'At Risk'

    WHEN R_Score <= 2 AND F_Score <= 2 AND M_Score >= 4
        THEN 'Hibernating High Spenders'

    WHEN R_Score <= 2 AND F_Score <= 2 AND M_Score <= 2
        THEN 'Lost Customers'

    WHEN R_Score BETWEEN 2 AND 3
         AND F_Score BETWEEN 2 AND 3
         AND M_Score BETWEEN 2 AND 3
        THEN 'Need Attention'

    ELSE 'Others'
    END AS Customer_Segment

        FROM ct2

)

SELECT * FROM ct3
where RFM_Score>=333
ORDER BY RFM_Score DESC

-- 10. Find customers with the lowest possible RFM score.
-- Business use: Identifies customers requiring attention.



WITH ct1 as (

        SELECT [customer name],
        datediff(day,
        max([order date]),
        (
            SELECT max([order date]) FROM orders$
        )) as recency,
        count(DISTINCT [order id]) as frequancy,
        sum(sales) as monetary FROM  orders$
        GROUP BY [customer name]
    
),
ct2 as (

        SELECT *,
        ntile(5) OVER(ORDER BY recency DESC) as R_Score,
        ntile(5) OVER(ORDER BY frequancy DESC) as F_Score,
        ntile(5) OVER(ORDER BY monetary DESC) as M_Score FROM ct1
),
ct3 as (
        SELECT *,
        concat(
            R_Score,
            F_Score,
            M_Score
        )as RFM_Score,

        CASE
    WHEN R_Score >= 4 AND F_Score >= 4 AND M_Score >= 4
        THEN 'Champion'

    WHEN R_Score >= 3 AND F_Score >= 4 AND M_Score >= 4
        THEN 'Loyal Customers'

    WHEN R_Score >= 4 AND F_Score BETWEEN 2 AND 3 AND M_Score >= 3
        THEN 'Potential Loyalist'

    WHEN R_Score = 5 AND F_Score <= 2
        THEN 'Recent Customers'

    WHEN R_Score BETWEEN 3 AND 4 AND F_Score <= 2
        THEN 'Promising'

    WHEN R_Score <= 2 AND F_Score >= 4 AND M_Score >= 4
        THEN 'Cannot Lose Them'

    WHEN R_Score <= 2 AND F_Score >= 3
        THEN 'At Risk'

    WHEN R_Score <= 2 AND F_Score <= 2 AND M_Score >= 4
        THEN 'Hibernating High Spenders'

    WHEN R_Score <= 2 AND F_Score <= 2 AND M_Score <= 2
        THEN 'Lost Customers'

    WHEN R_Score BETWEEN 2 AND 3
         AND F_Score BETWEEN 2 AND 3
         AND M_Score BETWEEN 2 AND 3
        THEN 'Need Attention'

    ELSE 'Others'
    END AS Customer_Segment

        FROM ct2

)

SELECT * FROM ct3
where RFM_Score<=222
ORDER BY RFM_Score DESC

-- ============================================================
-- RFM SEGMENTATION
-- ============================================================

-- 11. Segment customers into Champions, Loyal Customers,
-- Potential Loyalists, At Risk, and Lost Customers using RFM scores.
-- Business use: Enables targeted customer strategies.

WITH ct1 as (

        SELECT [customer name],
        datediff(day,
        max([order date]),
        (
            SELECT max([order date]) FROM orders$
        )) as recency,
        count(DISTINCT [order id]) as frequancy,
        sum(sales) as monetary FROM  orders$
        GROUP BY [customer name]
    
),
ct2 as (

        SELECT *,
        ntile(5) OVER(ORDER BY recency DESC) as R_Score,
        ntile(5) OVER(ORDER BY frequancy DESC) as F_Score,
        ntile(5) OVER(ORDER BY monetary DESC) as M_Score FROM ct1
),
ct3 as (
        SELECT *,
        concat(
            R_Score,
            F_Score,
            M_Score
        )as RFM_Score,

        CASE
    WHEN R_Score >= 4 AND F_Score >= 4 AND M_Score >= 4
        THEN 'Champion'

    WHEN R_Score >= 3 AND F_Score >= 4 AND M_Score >= 4
        THEN 'Loyal Customers'

    WHEN R_Score >= 4 AND F_Score BETWEEN 2 AND 3 AND M_Score >= 3
        THEN 'Potential Loyalist'

    WHEN R_Score = 5 AND F_Score <= 2
        THEN 'Recent Customers'

    WHEN R_Score BETWEEN 3 AND 4 AND F_Score <= 2
        THEN 'Promising'

    WHEN R_Score <= 2 AND F_Score >= 4 AND M_Score >= 4
        THEN 'Cannot Lose Them'

    WHEN R_Score <= 2 AND F_Score >= 3
        THEN 'At Risk'

    WHEN R_Score <= 2 AND F_Score <= 2 AND M_Score >= 4
        THEN 'Hibernating High Spenders'

    WHEN R_Score <= 2 AND F_Score <= 2 AND M_Score <= 2
        THEN 'Lost Customers'

    WHEN R_Score BETWEEN 2 AND 3
         AND F_Score BETWEEN 2 AND 3
         AND M_Score BETWEEN 2 AND 3
        THEN 'Need Attention'

    ELSE 'Others'
    END AS Customer_Segment

        FROM ct2

)

SELECT * FROM ct3







-- 12. Find the number of customers in each RFM segment.
-- Business use: Understands customer portfolio composition.

WITH ct1 as (

        SELECT [customer name],
        datediff(day,
        max([order date]),
        (
            SELECT max([order date]) FROM orders$
        )) as recency,
        count(DISTINCT [order id]) as frequancy,
        sum(sales) as monetary FROM  orders$
        GROUP BY [customer name]
    
),
ct2 as (

        SELECT *,
        ntile(5) OVER(ORDER BY recency DESC) as R_Score,
        ntile(5) OVER(ORDER BY frequancy DESC) as F_Score,
        ntile(5) OVER(ORDER BY monetary DESC) as M_Score FROM ct1
),
ct3 as (
        SELECT *,
        concat(
            R_Score,
            F_Score,
            M_Score
        )as RFM_Score,

        CASE
    WHEN R_Score >= 4 AND F_Score >= 4 AND M_Score >= 4
        THEN 'Champion'

    WHEN R_Score >= 3 AND F_Score >= 4 AND M_Score >= 4
        THEN 'Loyal Customers'

    WHEN R_Score >= 4 AND F_Score BETWEEN 2 AND 3 AND M_Score >= 3
        THEN 'Potential Loyalist'

    WHEN R_Score = 5 AND F_Score <= 2
        THEN 'Recent Customers'

    WHEN R_Score BETWEEN 3 AND 4 AND F_Score <= 2
        THEN 'Promising'

    WHEN R_Score <= 2 AND F_Score >= 4 AND M_Score >= 4
        THEN 'Cannot Lose Them'

    WHEN R_Score <= 2 AND F_Score >= 3
        THEN 'At Risk'

    WHEN R_Score <= 2 AND F_Score <= 2 AND M_Score >= 4
        THEN 'Hibernating High Spenders'

    WHEN R_Score <= 2 AND F_Score <= 2 AND M_Score <= 2
        THEN 'Lost Customers'

    WHEN R_Score BETWEEN 2 AND 3
         AND F_Score BETWEEN 2 AND 3
         AND M_Score BETWEEN 2 AND 3
        THEN 'Need Attention'

    ELSE 'Others'
    END AS Customer_Segment

        FROM ct2

)

SELECT RFM_Score,count(DISTINCT [customer name]) as total_customers FROM ct3
GROUP BY RFM_Score
ORDER BY total_customers DESC

-- 13. Calculate the percentage of total customers in each RFM segment.
-- Business use: Measures the size of each customer group.


WITH ct1 AS (
    SELECT
        [Customer Name],
        DATEDIFF(
            DAY,
            MAX([Order Date]),
            (SELECT MAX([Order Date]) FROM orders$)
        ) AS Recency,
        COUNT(DISTINCT [Order ID]) AS Frequency,
        SUM(Sales) AS Monetary
    FROM orders$
    GROUP BY [Customer Name]
),

ct2 AS (
    SELECT *,
        NTILE(5) OVER (ORDER BY Recency DESC) AS R_Score,
        NTILE(5) OVER (ORDER BY Frequency DESC) AS F_Score,
        NTILE(5) OVER (ORDER BY Monetary DESC) AS M_Score
    FROM ct1
),

ct3 AS (
    SELECT *,
        CONCAT(R_Score, F_Score, M_Score) AS RFM_Score,

        CASE
            WHEN R_Score >= 4 AND F_Score >= 4 AND M_Score >= 4
                THEN 'Champion'

            WHEN R_Score >= 3 AND F_Score >= 4 AND M_Score >= 4
                THEN 'Loyal Customers'

            WHEN R_Score >= 4 AND F_Score BETWEEN 2 AND 3 AND M_Score >= 3
                THEN 'Potential Loyalist'

            WHEN R_Score = 5 AND F_Score <= 2
                THEN 'Recent Customers'

            WHEN R_Score BETWEEN 3 AND 4 AND F_Score <= 2
                THEN 'Promising'

            WHEN R_Score <= 2 AND F_Score >= 4 AND M_Score >= 4
                THEN 'Cannot Lose Them'

            WHEN R_Score <= 2 AND F_Score >= 3
                THEN 'At Risk'

            WHEN R_Score <= 2 AND F_Score <= 2 AND M_Score >= 4
                THEN 'Hibernating High Spenders'

            WHEN R_Score <= 2 AND F_Score <= 2 AND M_Score <= 2
                THEN 'Lost Customers'

            WHEN R_Score BETWEEN 2 AND 3
                 AND F_Score BETWEEN 2 AND 3
                 AND M_Score BETWEEN 2 AND 3
                THEN 'Need Attention'

            ELSE 'Others'
        END AS Customer_Segment
    FROM ct2
)

SELECT
    Customer_Segment,
    COUNT(*) AS Segment_Total_Customers,
    SUM(COUNT(*)) OVER () AS Total_Customers,
    CAST(
        COUNT(*) * 100.0 / SUM(COUNT(*)) OVER ()
        AS DECIMAL(10,2)
    ) AS Contribution_Percentage
FROM ct3
GROUP BY Customer_Segment
ORDER BY Segment_Total_Customers DESC;



-- 14. Calculate total revenue generated by each RFM segment.
-- Business use: Measures the financial value of each segment.


WITH ct1 AS (
    SELECT
        [Customer Name],
        DATEDIFF(
            DAY,
            MAX([Order Date]),
            (SELECT MAX([Order Date]) FROM orders$)
        ) AS Recency,
        COUNT(DISTINCT [Order ID]) AS Frequency,
        SUM(Sales) AS Monetary
    FROM orders$
    GROUP BY [Customer Name]
),

ct2 AS (
    SELECT *,
        NTILE(5) OVER (ORDER BY Recency DESC) AS R_Score,
        NTILE(5) OVER (ORDER BY Frequency DESC) AS F_Score,
        NTILE(5) OVER (ORDER BY Monetary DESC) AS M_Score
    FROM ct1
),

ct3 AS (
    SELECT *,
        CONCAT(R_Score, F_Score, M_Score) AS RFM_Score,

        CASE
            WHEN R_Score >= 4 AND F_Score >= 4 AND M_Score >= 4
                THEN 'Champion'

            WHEN R_Score >= 3 AND F_Score >= 4 AND M_Score >= 4
                THEN 'Loyal Customers'

            WHEN R_Score >= 4 AND F_Score BETWEEN 2 AND 3 AND M_Score >= 3
                THEN 'Potential Loyalist'

            WHEN R_Score = 5 AND F_Score <= 2
                THEN 'Recent Customers'

            WHEN R_Score BETWEEN 3 AND 4 AND F_Score <= 2
                THEN 'Promising'

            WHEN R_Score <= 2 AND F_Score >= 4 AND M_Score >= 4
                THEN 'Cannot Lose Them'

            WHEN R_Score <= 2 AND F_Score >= 3
                THEN 'At Risk'

            WHEN R_Score <= 2 AND F_Score <= 2 AND M_Score >= 4
                THEN 'Hibernating High Spenders'

            WHEN R_Score <= 2 AND F_Score <= 2 AND M_Score <= 2
                THEN 'Lost Customers'

            WHEN R_Score BETWEEN 2 AND 3
                 AND F_Score BETWEEN 2 AND 3
                 AND M_Score BETWEEN 2 AND 3
                THEN 'Need Attention'

            ELSE 'Others'
        END AS Customer_Segment
    FROM ct2
)

SELECT
    Customer_Segment,sum(Monetary) as Segement_Total_Revanue
FROM ct3
GROUP BY Customer_Segment
ORDER BY  Segement_Total_Revanue DESC;

-- 15. Calculate the percentage of total revenue contributed
-- by each RFM segment.
-- Business use: Identifies segments driving company revenue.

WITH ct1 AS (
    SELECT
        [Customer Name],
        DATEDIFF(
            DAY,
            MAX([Order Date]),
            (SELECT MAX([Order Date]) FROM orders$)
        ) AS Recency,
        COUNT(DISTINCT [Order ID]) AS Frequency,
        SUM(Sales) AS Monetary
    FROM orders$
    GROUP BY [Customer Name]
),

ct2 AS (
    SELECT *,
        NTILE(5) OVER (ORDER BY Recency DESC) AS R_Score,
        NTILE(5) OVER (ORDER BY Frequency DESC) AS F_Score,
        NTILE(5) OVER (ORDER BY Monetary DESC) AS M_Score
    FROM ct1
),

ct3 AS (
    SELECT *,
        CONCAT(R_Score, F_Score, M_Score) AS RFM_Score,

        CASE
            WHEN R_Score >= 4 AND F_Score >= 4 AND M_Score >= 4
                THEN 'Champion'

            WHEN R_Score >= 3 AND F_Score >= 4 AND M_Score >= 4
                THEN 'Loyal Customers'

            WHEN R_Score >= 4 AND F_Score BETWEEN 2 AND 3 AND M_Score >= 3
                THEN 'Potential Loyalist'

            WHEN R_Score = 5 AND F_Score <= 2
                THEN 'Recent Customers'

            WHEN R_Score BETWEEN 3 AND 4 AND F_Score <= 2
                THEN 'Promising'

            WHEN R_Score <= 2 AND F_Score >= 4 AND M_Score >= 4
                THEN 'Cannot Lose Them'

            WHEN R_Score <= 2 AND F_Score >= 3
                THEN 'At Risk'

            WHEN R_Score <= 2 AND F_Score <= 2 AND M_Score >= 4
                THEN 'Hibernating High Spenders'

            WHEN R_Score <= 2 AND F_Score <= 2 AND M_Score <= 2
                THEN 'Lost Customers'

            WHEN R_Score BETWEEN 2 AND 3
                 AND F_Score BETWEEN 2 AND 3
                 AND M_Score BETWEEN 2 AND 3
                THEN 'Need Attention'

            ELSE 'Others'
        END AS Customer_Segment
    FROM ct2
)

SELECT
    Customer_Segment,sum(Monetary) as Segement_Total_Revanue,
    (
        SELECT sum(Monetary) FROM ct2
    ) as total_Revanue,
    sum(Monetary)*100.0/(
        SELECT sum(Monetary) FROM ct2
    )as cont
FROM ct3
GROUP BY Customer_Segment
ORDER BY  Segement_Total_Revanue DESC;



-- 16. Calculate average revenue per customer for every RFM segment.
-- Business use: Compares customer value across segments.

WITH ct1 AS (
    SELECT
        [Customer Name],
        DATEDIFF(
            DAY,
            MAX([Order Date]),
            (SELECT MAX([Order Date]) FROM orders$)
        ) AS Recency,
        COUNT(DISTINCT [Order ID]) AS Frequency,
        SUM(Sales) AS Monetary
    FROM orders$
    GROUP BY [Customer Name]
),

ct2 AS (
    SELECT *,
        NTILE(5) OVER (ORDER BY Recency DESC) AS R_Score,
        NTILE(5) OVER (ORDER BY Frequency DESC) AS F_Score,
        NTILE(5) OVER (ORDER BY Monetary DESC) AS M_Score
    FROM ct1
),

ct3 AS (
    SELECT *,
        CONCAT(R_Score, F_Score, M_Score) AS RFM_Score,

        CASE
            WHEN R_Score >= 4 AND F_Score >= 4 AND M_Score >= 4
                THEN 'Champion'

            WHEN R_Score >= 3 AND F_Score >= 4 AND M_Score >= 4
                THEN 'Loyal Customers'

            WHEN R_Score >= 4 AND F_Score BETWEEN 2 AND 3 AND M_Score >= 3
                THEN 'Potential Loyalist'

            WHEN R_Score = 5 AND F_Score <= 2
                THEN 'Recent Customers'

            WHEN R_Score BETWEEN 3 AND 4 AND F_Score <= 2
                THEN 'Promising'

            WHEN R_Score <= 2 AND F_Score >= 4 AND M_Score >= 4
                THEN 'Cannot Lose Them'

            WHEN R_Score <= 2 AND F_Score >= 3
                THEN 'At Risk'

            WHEN R_Score <= 2 AND F_Score <= 2 AND M_Score >= 4
                THEN 'Hibernating High Spenders'

            WHEN R_Score <= 2 AND F_Score <= 2 AND M_Score <= 2
                THEN 'Lost Customers'

            WHEN R_Score BETWEEN 2 AND 3
                 AND F_Score BETWEEN 2 AND 3
                 AND M_Score BETWEEN 2 AND 3
                THEN 'Need Attention'

            ELSE 'Others'
        END AS Customer_Segment
    FROM ct2
)

SELECT  DISTINCT [customer name],
    Customer_Segment,avg(Monetary) as Segement_Total_Revanue
    
FROM ct3
GROUP BY [customer name],Customer_Segment
ORDER BY  Segement_Total_Revanue ,[customer name] DESC;


-- 17. Find the segment with the highest average order frequency.
-- Business use: Identifies the most engaged customer group.

WITH ct1 AS (
    SELECT
        [Customer Name],
        DATEDIFF(
            DAY,
            MAX([Order Date]),
            (SELECT MAX([Order Date]) FROM orders$)
        ) AS Recency,
        COUNT(DISTINCT [Order ID]) AS Frequency,
        SUM(Sales) AS Monetary
    FROM orders$
    GROUP BY [Customer Name]
),

ct2 AS (
    SELECT *,
        NTILE(5) OVER (ORDER BY Recency DESC) AS R_Score,
        NTILE(5) OVER (ORDER BY Frequency DESC) AS F_Score,
        NTILE(5) OVER (ORDER BY Monetary DESC) AS M_Score
    FROM ct1
),

ct3 AS (
    SELECT *,
        CONCAT(R_Score, F_Score, M_Score) AS RFM_Score,

        CASE
            WHEN R_Score >= 4 AND F_Score >= 4 AND M_Score >= 4
                THEN 'Champion'

            WHEN R_Score >= 3 AND F_Score >= 4 AND M_Score >= 4
                THEN 'Loyal Customers'

            WHEN R_Score >= 4 AND F_Score BETWEEN 2 AND 3 AND M_Score >= 3
                THEN 'Potential Loyalist'

            WHEN R_Score = 5 AND F_Score <= 2
                THEN 'Recent Customers'

            WHEN R_Score BETWEEN 3 AND 4 AND F_Score <= 2
                THEN 'Promising'

            WHEN R_Score <= 2 AND F_Score >= 4 AND M_Score >= 4
                THEN 'Cannot Lose Them'

            WHEN R_Score <= 2 AND F_Score >= 3
                THEN 'At Risk'

            WHEN R_Score <= 2 AND F_Score <= 2 AND M_Score >= 4
                THEN 'Hibernating High Spenders'

            WHEN R_Score <= 2 AND F_Score <= 2 AND M_Score <= 2
                THEN 'Lost Customers'

            WHEN R_Score BETWEEN 2 AND 3
                 AND F_Score BETWEEN 2 AND 3
                 AND M_Score BETWEEN 2 AND 3
                THEN 'Need Attention'

            ELSE 'Others'
        END AS Customer_Segment
    FROM ct2
)
SELECT TOP 1
    Customer_Segment,
    AVG(CAST(Frequency AS FLOAT)) AS Avg_Frequency
FROM ct3
GROUP BY Customer_Segment
ORDER BY Avg_Frequency DESC;




-- 18. Find the segment with the highest average customer revenue.
-- Business use: Identifies the most valuable customer group.

WITH ct1 AS (
    SELECT
        [Customer Name],
        DATEDIFF(
            DAY,
            MAX([Order Date]),
            (SELECT MAX([Order Date]) FROM orders$)
        ) AS Recency,
        COUNT(DISTINCT [Order ID]) AS Frequency,
        SUM(Sales) AS Monetary
    FROM orders$
    GROUP BY [Customer Name]
),

ct2 AS (
    SELECT *,
        NTILE(5) OVER (ORDER BY Recency DESC) AS R_Score,
        NTILE(5) OVER (ORDER BY Frequency DESC) AS F_Score,
        NTILE(5) OVER (ORDER BY Monetary DESC) AS M_Score
    FROM ct1
),

ct3 AS (
    SELECT *,
        CONCAT(R_Score, F_Score, M_Score) AS RFM_Score,

        CASE
            WHEN R_Score >= 4 AND F_Score >= 4 AND M_Score >= 4
                THEN 'Champion'

            WHEN R_Score >= 3 AND F_Score >= 4 AND M_Score >= 4
                THEN 'Loyal Customers'

            WHEN R_Score >= 4 AND F_Score BETWEEN 2 AND 3 AND M_Score >= 3
                THEN 'Potential Loyalist'

            WHEN R_Score = 5 AND F_Score <= 2
                THEN 'Recent Customers'

            WHEN R_Score BETWEEN 3 AND 4 AND F_Score <= 2
                THEN 'Promising'

            WHEN R_Score <= 2 AND F_Score >= 4 AND M_Score >= 4
                THEN 'Cannot Lose Them'

            WHEN R_Score <= 2 AND F_Score >= 3
                THEN 'At Risk'

            WHEN R_Score <= 2 AND F_Score <= 2 AND M_Score >= 4
                THEN 'Hibernating High Spenders'

            WHEN R_Score <= 2 AND F_Score <= 2 AND M_Score <= 2
                THEN 'Lost Customers'

            WHEN R_Score BETWEEN 2 AND 3
                 AND F_Score BETWEEN 2 AND 3
                 AND M_Score BETWEEN 2 AND 3
                THEN 'Need Attention'

            ELSE 'Others'
        END AS Customer_Segment
    FROM ct2
)
SELECT TOP 1
    Customer_Segment,
    AVG(CAST(Monetary AS FLOAT)) AS Avg_Monetary
FROM ct3
GROUP BY Customer_Segment
ORDER BY Avg_Monetary DESC;


--19. Find high-frequency customers whose monetary value is below average.
-- Business use: Identifies frequent but low-spending customers.

WITH ct1 AS (
    SELECT
        [Customer Name],
        DATEDIFF(
            DAY,
            MAX([Order Date]),
            (SELECT MAX([Order Date]) FROM orders$)
        ) AS Recency,
        COUNT(DISTINCT [Order ID]) AS Frequency,
        SUM(Sales) AS Monetary
    FROM orders$
    GROUP BY [Customer Name]
),

ct2 AS (
    SELECT *,
        NTILE(5) OVER (ORDER BY Recency DESC) AS R_Score,
        NTILE(5) OVER (ORDER BY Frequency DESC) AS F_Score,
        NTILE(5) OVER (ORDER BY Monetary DESC) AS M_Score
    FROM ct1
),

ct3 AS (
    SELECT *,
        CONCAT(R_Score, F_Score, M_Score) AS RFM_Score,
        CASE
            WHEN R_Score >= 4 AND F_Score >= 4 AND M_Score >= 4
                THEN 'Champion'
            WHEN R_Score >= 3 AND F_Score >= 4 AND M_Score >= 4
                THEN 'Loyal Customers'
            WHEN R_Score >= 4 AND F_Score BETWEEN 2 AND 3 AND M_Score >= 3
                THEN 'Potential Loyalist'
            WHEN R_Score = 5 AND F_Score <= 2
                THEN 'Recent Customers'
            WHEN R_Score BETWEEN 3 AND 4 AND F_Score <= 2
                THEN 'Promising'
            WHEN R_Score <= 2 AND F_Score >= 4 AND M_Score >= 4
                THEN 'Cannot Lose Them'
            WHEN R_Score <= 2 AND F_Score >= 3
                THEN 'At Risk'
            WHEN R_Score <= 2 AND F_Score <= 2 AND M_Score >= 4
                THEN 'Hibernating High Spenders'
            WHEN R_Score <= 2 AND F_Score <= 2 AND M_Score <= 2
                THEN 'Lost Customers'
            WHEN R_Score BETWEEN 2 AND 3
                 AND F_Score BETWEEN 2 AND 3
                 AND M_Score BETWEEN 2 AND 3
                THEN 'Need Attention'
            ELSE 'Others'
        END AS Customer_Segment
    FROM ct2
),

ct4 AS (
    SELECT
        AVG(CAST(Monetary AS FLOAT)) AS Avg_Monetary,
        AVG(CAST(Frequency AS FLOAT)) AS Avg_Frequency
    FROM ct3
)

SELECT
    c3.[Customer Name],
    c3.Customer_Segment,
    c3.Frequency,
    c3.Monetary,
    c4.Avg_Frequency,
    c4.Avg_Monetary
FROM ct3 AS c3
CROSS JOIN ct4 AS c4
WHERE c3.Frequency > c4.Avg_Frequency
  AND c3.Monetary < c4.Avg_Monetary
ORDER BY c3.Frequency DESC;


-- 20. Find low-frequency customers whose monetary value is above average.
-- Business use: Identifies occasional high-value customers.


 

WITH ct1 AS (
    SELECT
        [Customer Name],
        DATEDIFF(
            DAY,
            MAX([Order Date]),
            (SELECT MAX([Order Date]) FROM orders$)
        ) AS Recency,
        COUNT(DISTINCT [Order ID]) AS Frequency,
        SUM(Sales) AS Monetary
    FROM orders$
    GROUP BY [Customer Name]
),

ct2 AS (
    SELECT *,
        NTILE(5) OVER (ORDER BY Recency DESC) AS R_Score,
        NTILE(5) OVER (ORDER BY Frequency DESC) AS F_Score,
        NTILE(5) OVER (ORDER BY Monetary DESC) AS M_Score
    FROM ct1
),

ct3 AS (
    SELECT *,
        CONCAT(R_Score, F_Score, M_Score) AS RFM_Score,
        CASE
            WHEN R_Score >= 4 AND F_Score >= 4 AND M_Score >= 4
                THEN 'Champion'
            WHEN R_Score >= 3 AND F_Score >= 4 AND M_Score >= 4
                THEN 'Loyal Customers'
            WHEN R_Score >= 4 AND F_Score BETWEEN 2 AND 3 AND M_Score >= 3
                THEN 'Potential Loyalist'
            WHEN R_Score = 5 AND F_Score <= 2
                THEN 'Recent Customers'
            WHEN R_Score BETWEEN 3 AND 4 AND F_Score <= 2
                THEN 'Promising'
            WHEN R_Score <= 2 AND F_Score >= 4 AND M_Score >= 4
                THEN 'Cannot Lose Them'
            WHEN R_Score <= 2 AND F_Score >= 3
                THEN 'At Risk'
            WHEN R_Score <= 2 AND F_Score <= 2 AND M_Score >= 4
                THEN 'Hibernating High Spenders'
            WHEN R_Score <= 2 AND F_Score <= 2 AND M_Score <= 2
                THEN 'Lost Customers'
            WHEN R_Score BETWEEN 2 AND 3
                 AND F_Score BETWEEN 2 AND 3
                 AND M_Score BETWEEN 2 AND 3
                THEN 'Need Attention'
            ELSE 'Others'
        END AS Customer_Segment
    FROM ct2
),

ct4 AS (
    SELECT
        AVG(CAST(Monetary AS FLOAT)) AS Avg_Monetary,
        AVG(CAST(Frequency AS FLOAT)) AS Avg_Frequency
    FROM ct3
)

SELECT
    c3.[Customer Name],
    c3.Customer_Segment,
    c3.Frequency,
    c3.Monetary,
    c4.Avg_Frequency,
    c4.Avg_Monetary
FROM ct3 AS c3
CROSS JOIN ct4 AS c4
WHERE c3.Frequency < c4.Avg_Frequency
  AND c3.Monetary > c4.Avg_Monetary
ORDER BY c3.Frequency DESC;




-- ============================================================
-- RFM — CHAMPIONS & LOYAL CUSTOMERS
-- ============================================================

-- 21. Find customers who purchased recently, frequently,
-- and generated high revenue.
-- Business use: Identifies Champions.

WITH ct1 AS (
    SELECT
        [Customer Name],
        DATEDIFF(
            DAY,
            MAX([Order Date]),
            (SELECT MAX([Order Date]) FROM orders$)
        ) AS Recency,
        COUNT(DISTINCT [Order ID]) AS Frequency,
        SUM(Sales) AS Monetary
    FROM orders$
    GROUP BY [Customer Name]
),

ct2 AS (
    SELECT *,
        NTILE(5) OVER (ORDER BY Recency DESC) AS R_Score,
        NTILE(5) OVER (ORDER BY Frequency DESC) AS F_Score,
        NTILE(5) OVER (ORDER BY Monetary DESC) AS M_Score
    FROM ct1
),

ct3 AS (
    SELECT *,
        CONCAT(R_Score, F_Score, M_Score) AS RFM_Score,

CASE
    WHEN R_Score >= 4 AND F_Score >= 4 AND M_Score >= 4
        THEN 'Champions'

    WHEN R_Score >= 3 AND F_Score >= 4 AND M_Score >= 3
        THEN 'Loyal Customers'
    
     WHEN R_Score = 5 AND F_Score <= 2
                THEN 'Recent Customers'

    WHEN R_Score >= 4 AND F_Score BETWEEN 2 AND 3 AND M_Score >= 3
        THEN 'Potential Loyalist'

    WHEN R_Score BETWEEN 2 AND 3
         AND F_Score BETWEEN 2 AND 3
         AND M_Score BETWEEN 2 AND 3
        THEN 'Need Attention'

    WHEN R_Score <= 2 AND F_Score <= 2 AND M_Score <= 2
        THEN 'Lost Customers'

    ELSE 'Others'
END AS Customer_Segment
    FROM ct2
)
SELECT * FROM ct3
where RFM_Score>344







-- 22. Find customers with high Frequency and high Monetary value
-- but poor Recency.
-- Business use: Identifies valuable customers at risk.

WITH ct1 AS (
    SELECT
        [Customer Name],
        DATEDIFF(
            DAY,
            MAX([Order Date]),
            (SELECT MAX([Order Date]) FROM orders$)
        ) AS Recency,
        COUNT(DISTINCT [Order ID]) AS Frequency,
        SUM(Sales) AS Monetary
    FROM orders$
    GROUP BY [Customer Name]
),

ct2 AS (
    SELECT *,
        NTILE(5) OVER (ORDER BY Recency DESC) AS R_Score,
        NTILE(5) OVER (ORDER BY Frequency DESC) AS F_Score,
        NTILE(5) OVER (ORDER BY Monetary DESC) AS M_Score
    FROM ct1
),

ct3 AS (
    SELECT *,
        CONCAT(R_Score, F_Score, M_Score) AS RFM_Score,

CASE
    WHEN R_Score >= 4 AND F_Score >= 4 AND M_Score >= 4
        THEN 'Champions'

    WHEN R_Score >= 3 AND F_Score >= 4 AND M_Score >= 3
        THEN 'Loyal Customers'
    
     WHEN R_Score = 5 AND F_Score <= 2
                THEN 'Recent Customers'

    WHEN R_Score >= 4 AND F_Score BETWEEN 2 AND 3 AND M_Score >= 3
        THEN 'Potential Loyalist'

    WHEN R_Score BETWEEN 2 AND 3
         AND F_Score BETWEEN 2 AND 3
         AND M_Score BETWEEN 2 AND 3
        THEN 'Need Attention'

    WHEN R_Score <= 2 AND F_Score <= 2 AND M_Score <= 2
        THEN 'Lost Customers'

    ELSE 'Others'
END AS Customer_Segment
    FROM ct2
)
SELECT * FROM ct3
where R_Score<=2
and F_Score>=4
and M_Score>=4





-- 23. Find customers with high Recency score but low Frequency score.
-- Business use: Identifies recently acquired customers.


WITH ct1 AS (
    SELECT
        [Customer Name],
        DATEDIFF(
            DAY,
            MAX([Order Date]),
            (SELECT MAX([Order Date]) FROM orders$)
        ) AS Recency,
        COUNT(DISTINCT [Order ID]) AS Frequency,
        SUM(Sales) AS Monetary
    FROM orders$
    GROUP BY [Customer Name]
),

ct2 AS (
    SELECT *,
        NTILE(5) OVER (ORDER BY Recency DESC) AS R_Score,
        NTILE(5) OVER (ORDER BY Frequency DESC) AS F_Score,
        NTILE(5) OVER (ORDER BY Monetary DESC) AS M_Score
    FROM ct1
),

ct3 AS (
    SELECT *,
        CONCAT(R_Score, F_Score, M_Score) AS RFM_Score,

CASE
    WHEN R_Score >= 4 AND F_Score >= 4 AND M_Score >= 4
        THEN 'Champions'

    WHEN R_Score >= 3 AND F_Score >= 4 AND M_Score >= 3
        THEN 'Loyal Customers'
    
     WHEN R_Score = 5 AND F_Score <= 2
                THEN 'Recent Customers'

    WHEN R_Score >= 4 AND F_Score BETWEEN 2 AND 3 AND M_Score >= 3
        THEN 'Potential Loyalist'

    WHEN R_Score BETWEEN 2 AND 3
         AND F_Score BETWEEN 2 AND 3
         AND M_Score BETWEEN 2 AND 3
        THEN 'Need Attention'

    WHEN R_Score <= 2 AND F_Score <= 2 AND M_Score <= 2
        THEN 'Lost Customers'

    ELSE 'Others'
END AS Customer_Segment
    FROM ct2
)
SELECT * FROM ct3
where R_Score>=4
and F_Score<=2




-- 24. Find customers with high Monetary value but poor Recency.
-- Business use: Identifies high-value customers who may churn.

WITH ct1 AS (
    SELECT
        [Customer Name],
        DATEDIFF(
            DAY,
            MAX([Order Date]),
            (SELECT MAX([Order Date]) FROM orders$)
        ) AS Recency,
        COUNT(DISTINCT [Order ID]) AS Frequency,
        SUM(Sales) AS Monetary
    FROM orders$
    GROUP BY [Customer Name]
),

ct2 AS (
    SELECT *,
        NTILE(5) OVER (ORDER BY Recency DESC) AS R_Score,
        NTILE(5) OVER (ORDER BY Frequency DESC) AS F_Score,
        NTILE(5) OVER (ORDER BY Monetary DESC) AS M_Score
    FROM ct1
),

ct3 AS (
    SELECT *,
        CONCAT(R_Score, F_Score, M_Score) AS RFM_Score,

CASE
    WHEN R_Score >= 4 AND F_Score >= 4 AND M_Score >= 4
        THEN 'Champions'

    WHEN R_Score >= 3 AND F_Score >= 4 AND M_Score >= 3
        THEN 'Loyal Customers'
    
     WHEN R_Score = 5 AND F_Score <= 2
                THEN 'Recent Customers'

    WHEN R_Score >= 4 AND F_Score BETWEEN 2 AND 3 AND M_Score >= 3
        THEN 'Potential Loyalist'

    WHEN R_Score BETWEEN 2 AND 3
         AND F_Score BETWEEN 2 AND 3
         AND M_Score BETWEEN 2 AND 3
        THEN 'Need Attention'

    WHEN R_Score <= 2 AND F_Score <= 2 AND M_Score <= 2
        THEN 'Lost Customers'

    ELSE 'Others'
END AS Customer_Segment
    FROM ct2
)
SELECT * FROM ct3
where R_Score<2
and M_Score>4


-- 25. Find customers with high Frequency but low Monetary value.
-- Business use: Identifies frequent low-value buyers.

WITH ct1 AS (
    SELECT
        [Customer Name],
        DATEDIFF(
            DAY,
            MAX([Order Date]),
            (SELECT MAX([Order Date]) FROM orders$)
        ) AS Recency,
        COUNT(DISTINCT [Order ID]) AS Frequency,
        SUM(Sales) AS Monetary
    FROM orders$
    GROUP BY [Customer Name]
),

ct2 AS (
    SELECT *,
        NTILE(5) OVER (ORDER BY Recency DESC) AS R_Score,
        NTILE(5) OVER (ORDER BY Frequency DESC) AS F_Score,
        NTILE(5) OVER (ORDER BY Monetary DESC) AS M_Score
    FROM ct1
),

ct3 AS (
    SELECT *,
        CONCAT(R_Score, F_Score, M_Score) AS RFM_Score,

CASE
    WHEN R_Score >= 4 AND F_Score >= 4 AND M_Score >= 4
        THEN 'Champions'

    WHEN R_Score >= 3 AND F_Score >= 4 AND M_Score >= 3
        THEN 'Loyal Customers'
    
     WHEN R_Score = 5 AND F_Score <= 2
                THEN 'Recent Customers'

    WHEN R_Score >= 4 AND F_Score BETWEEN 2 AND 3 AND M_Score >= 3
        THEN 'Potential Loyalist'

    WHEN R_Score BETWEEN 2 AND 3
         AND F_Score BETWEEN 2 AND 3
         AND M_Score BETWEEN 2 AND 3
        THEN 'Need Attention'

    WHEN R_Score <= 2 AND F_Score <= 2 AND M_Score <= 2
        THEN 'Lost Customers'

    ELSE 'Others'
END AS Customer_Segment
    FROM ct2
)
SELECT * FROM ct3
where M_Score<2
and F_Score>4



-- 26. Find customers with low Frequency but high Monetary value.
-- Business use: Identifies occasional high-value buyers.

WITH ct1 AS (
    SELECT
        [Customer Name],
        DATEDIFF(
            DAY,
            MAX([Order Date]),
            (SELECT MAX([Order Date]) FROM orders$)
        ) AS Recency,
        COUNT(DISTINCT [Order ID]) AS Frequency,
        SUM(Sales) AS Monetary
    FROM orders$
    GROUP BY [Customer Name]
),

ct2 AS (
    SELECT *,
        NTILE(5) OVER (ORDER BY Recency DESC) AS R_Score,
        NTILE(5) OVER (ORDER BY Frequency DESC) AS F_Score,
        NTILE(5) OVER (ORDER BY Monetary DESC) AS M_Score
    FROM ct1
),

ct3 AS (
    SELECT *,
        CONCAT(R_Score, F_Score, M_Score) AS RFM_Score,

CASE
    WHEN R_Score >= 4 AND F_Score >= 4 AND M_Score >= 4
        THEN 'Champions'

    WHEN R_Score >= 3 AND F_Score >= 4 AND M_Score >= 3
        THEN 'Loyal Customers'
    
     WHEN R_Score = 5 AND F_Score <= 2
                THEN 'Recent Customers'

    WHEN R_Score >= 4 AND F_Score BETWEEN 2 AND 3 AND M_Score >= 3
        THEN 'Potential Loyalist'

    WHEN R_Score BETWEEN 2 AND 3
         AND F_Score BETWEEN 2 AND 3
         AND M_Score BETWEEN 2 AND 3
        THEN 'Need Attention'

    WHEN R_Score <= 2 AND F_Score <= 2 AND M_Score <= 2
        THEN 'Lost Customers'

    ELSE 'Others'
END AS Customer_Segment
    FROM ct2
)
SELECT * FROM ct3
where R_Score>=4
and F_Score<=2


-- 27. Find customers whose RFM score improved compared with
-- the previous year.
-- Business use: Identifies customers becoming more valuable.


WITH ct1 AS (
    SELECT
        [Customer Name],
        year([order date]) as order_year,
        DATEDIFF(
            DAY,
            MAX([Order Date]),
            (SELECT MAX([Order Date]) FROM orders$)
        ) AS Recency,
        COUNT(DISTINCT [Order ID]) AS Frequency,
        SUM(Sales) AS Monetary
    FROM orders$
    GROUP BY [Customer Name],year([order date])
),

ct2 AS (
    SELECT *,
        NTILE(5) OVER (ORDER BY Recency DESC) AS R_Score,
        NTILE(5) OVER (ORDER BY Frequency DESC) AS F_Score,
        NTILE(5) OVER (ORDER BY Monetary DESC) AS M_Score
    FROM ct1
),

ct3 AS (
    SELECT *,
        CONCAT(R_Score, F_Score, M_Score) AS RFM_Score,

CASE
    WHEN R_Score >= 4 AND F_Score >= 4 AND M_Score >= 4
        THEN 'Champions'

    WHEN R_Score >= 3 AND F_Score >= 4 AND M_Score >= 3
        THEN 'Loyal Customers'
    
     WHEN R_Score = 5 AND F_Score <= 2
                THEN 'Recent Customers'

    WHEN R_Score >= 4 AND F_Score BETWEEN 2 AND 3 AND M_Score >= 3
        THEN 'Potential Loyalist'

    WHEN R_Score BETWEEN 2 AND 3
         AND F_Score BETWEEN 2 AND 3
         AND M_Score BETWEEN 2 AND 3
        THEN 'Need Attention'

    WHEN R_Score <= 2 AND F_Score <= 2 AND M_Score <= 2
        THEN 'Lost Customers'

    ELSE 'Others'
END AS Customer_Segment
    FROM ct2
),
ct4 as (

        SELECT *,
        lag(RFM_Score) OVER(PARTITION BY [customer name] ORDER BY order_year) as prev_rfm
        FROM ct3

)

SELECT * FROM ct4
where RFM_Score>prev_rfm


-- 28. Find customers whose RFM score declined compared with
-- the previous year.
-- Business use: Identifies customers losing engagement.



WITH ct1 AS (
    SELECT
        [Customer Name],
        year([order date]) as order_year,
        DATEDIFF(
            DAY,
            MAX([Order Date]),
            (SELECT MAX([Order Date]) FROM orders$)
        ) AS Recency,
        COUNT(DISTINCT [Order ID]) AS Frequency,
        SUM(Sales) AS Monetary
    FROM orders$
    GROUP BY [Customer Name],year([order date])
),

ct2 AS (
    SELECT *,
        NTILE(5) OVER (ORDER BY Recency DESC) AS R_Score,
        NTILE(5) OVER (ORDER BY Frequency DESC) AS F_Score,
        NTILE(5) OVER (ORDER BY Monetary DESC) AS M_Score
    FROM ct1
),

ct3 AS (
    SELECT *,
        CONCAT(R_Score, F_Score, M_Score) AS RFM_Score,

CASE
    WHEN R_Score >= 4 AND F_Score >= 4 AND M_Score >= 4
        THEN 'Champions'

    WHEN R_Score >= 3 AND F_Score >= 4 AND M_Score >= 3
        THEN 'Loyal Customers'
    
     WHEN R_Score = 5 AND F_Score <= 2
                THEN 'Recent Customers'

    WHEN R_Score >= 4 AND F_Score BETWEEN 2 AND 3 AND M_Score >= 3
        THEN 'Potential Loyalist'

    WHEN R_Score BETWEEN 2 AND 3
         AND F_Score BETWEEN 2 AND 3
         AND M_Score BETWEEN 2 AND 3
        THEN 'Need Attention'

    WHEN R_Score <= 2 AND F_Score <= 2 AND M_Score <= 2
        THEN 'Lost Customers'

    ELSE 'Others'
END AS Customer_Segment
    FROM ct2
),
ct4 as (

        SELECT *,
        lag(RFM_Score) OVER(PARTITION BY [customer name] ORDER BY order_year) as prev_rfm
        FROM ct3

)

SELECT * FROM ct4
where RFM_Score<prev_rfm


-- 29. Find customers who moved from a low-value segment
-- to a high-value segment.
-- Business use: Measures customer development.

WITH ct1 AS (
    SELECT
        [Customer Name],
        year([order date]) as order_year,
        DATEDIFF(
            DAY,
            MAX([Order Date]),
            (SELECT MAX([Order Date]) FROM orders$)
        ) AS Recency,
        COUNT(DISTINCT [Order ID]) AS Frequency,
        SUM(Sales) AS Monetary
    FROM orders$
    GROUP BY [Customer Name],year([order date])
),

ct2 AS (
    SELECT *,
        NTILE(5) OVER (ORDER BY Recency DESC) AS R_Score,
        NTILE(5) OVER (ORDER BY Frequency DESC) AS F_Score,
        NTILE(5) OVER (ORDER BY Monetary DESC) AS M_Score
    FROM ct1
),

ct3 AS (
    SELECT *,
        CONCAT(R_Score, F_Score, M_Score) AS RFM_Score,

CASE
    WHEN R_Score >= 4 AND F_Score >= 4 AND M_Score >= 4
        THEN 'Champions'

    WHEN R_Score >= 3 AND F_Score >= 4 AND M_Score >= 3
        THEN 'Loyal Customers'
    
     WHEN R_Score = 5 AND F_Score <= 2
                THEN 'Recent Customers'

    WHEN R_Score >= 4 AND F_Score BETWEEN 2 AND 3 AND M_Score >= 3
        THEN 'Potential Loyalist'

    WHEN R_Score BETWEEN 2 AND 3
         AND F_Score BETWEEN 2 AND 3
         AND M_Score BETWEEN 2 AND 3
        THEN 'Need Attention'

    WHEN R_Score <= 2 AND F_Score <= 2 AND M_Score <= 2
        THEN 'Lost Customers'

    ELSE 'Others'
END AS Customer_Segment
    FROM ct2
),
ct4 as (

        SELECT *,
        lag(Customer_Segment) OVER(PARTITION BY [customer name] ORDER BY order_year) as Previous_Segment
        FROM ct3

)

SELECT * FROM ct4
WHERE Previous_Segment IN ('Lost Customers', 'Need Attention', 'Others')
  AND Customer_Segment IN ('Champions', 'Loyal Customers');








-- 30. Find customers who moved from a high-value segment
-- to a low-value segment.
-- Business use: Detects potential churn.

WITH ct1 AS (
    SELECT
        [Customer Name],
        year([order date]) as order_year,
        DATEDIFF(
            DAY,
            MAX([Order Date]),
            (SELECT MAX([Order Date]) FROM orders$)
        ) AS Recency,
        COUNT(DISTINCT [Order ID]) AS Frequency,
        SUM(Sales) AS Monetary
    FROM orders$
    GROUP BY [Customer Name],year([order date])
),

ct2 AS (
    SELECT *,
        NTILE(5) OVER (ORDER BY Recency DESC) AS R_Score,
        NTILE(5) OVER (ORDER BY Frequency DESC) AS F_Score,
        NTILE(5) OVER (ORDER BY Monetary DESC) AS M_Score
    FROM ct1
),

ct3 AS (
    SELECT *,
        CONCAT(R_Score, F_Score, M_Score) AS RFM_Score,

CASE
    WHEN R_Score >= 4 AND F_Score >= 4 AND M_Score >= 4
        THEN 'Champions'

    WHEN R_Score >= 3 AND F_Score >= 4 AND M_Score >= 3
        THEN 'Loyal Customers'
    
     WHEN R_Score = 5 AND F_Score <= 2
                THEN 'Recent Customers'

    WHEN R_Score >= 4 AND F_Score BETWEEN 2 AND 3 AND M_Score >= 3
        THEN 'Potential Loyalist'

    WHEN R_Score BETWEEN 2 AND 3
         AND F_Score BETWEEN 2 AND 3
         AND M_Score BETWEEN 2 AND 3
        THEN 'Need Attention'

    WHEN R_Score <= 2 AND F_Score <= 2 AND M_Score <= 2
        THEN 'Lost Customers'

    ELSE 'Others'
END AS Customer_Segment
    FROM ct2
),
ct4 as (

        SELECT *,
        lag(Customer_Segment) OVER(PARTITION BY [customer name] ORDER BY order_year) as Previous_Segment
        FROM ct3

)

SELECT * FROM ct4
WHERE Previous_Segment IN (
    'Champions',
    'Loyal Customers',
    'Potential Loyalist'
)
AND Customer_Segment IN (
    'Lost Customers',
    'Need Attention',
    'Others'
);


-- ============================================================
-- RFM — BUSINESS DECISION QUESTIONS
-- ============================================================

-- 31. Find high-value customers who have not purchased
-- in the last 90 days.
-- Business use: Creates a high-priority retention list.


SELECT [customer name],max([order date]) as recency,datediff(
    day,max([order date]),(
        SELECT max([order date]) FROM orders$
    )
),
sum(sales ) as Monetary,
avg(sales) as avg_sales
FROM orders$
GROUP BY [customer name]
HAVING datediff(day,max([order date]),(
    SELECT max([order date]) FROM orders$
))>90
and sum(sales) > (
    SELECT avg(total_sales) FROM 
    (SELECT sum(Sales) as total_sales FROM orders$
    GROUP BY [customer name]) as x

)








-- 32. Find high-value customers who have not purchased
-- in the last 180 days.
-- Business use: Identifies customers at serious churn risk.


SELECT [customer name],max([order date]) as recency,datediff(
    day,max([order date]),(
        SELECT max([order date]) FROM orders$
    )
) as day_diff,
sum(sales ) as Monetary
FROM orders$
GROUP BY [customer name]
HAVING datediff(day,max([order date]),(
    SELECT max([order date]) FROM orders$
))>180

ORDER BY day_diff ASC

-- 33. Find customers with high Frequency but declining Monetary value.
-- Business use: Detects decreasing customer spending.

WITH ct1 AS (
    SELECT
        [Customer Name],
        year([order date]) as order_year,
        DATEDIFF(
            DAY,
            MAX([Order Date]),
            (SELECT MAX([Order Date]) FROM orders$)
        ) AS Recency,
        COUNT(DISTINCT [Order ID]) AS Frequency,
        SUM(Sales) AS Monetary
    FROM orders$
    GROUP BY [Customer Name],year([order date])
),

ct2 AS (
    SELECT *,
        NTILE(5) OVER (ORDER BY Recency DESC) AS R_Score,
        NTILE(5) OVER (ORDER BY Frequency DESC) AS F_Score,
        NTILE(5) OVER (ORDER BY Monetary DESC) AS M_Score
    FROM ct1
),

ct3 AS (
    SELECT *,
        CONCAT(R_Score, F_Score, M_Score) AS RFM_Score,

CASE
    WHEN R_Score >= 4 AND F_Score >= 4 AND M_Score >= 4
        THEN 'Champions'

    WHEN R_Score >= 3 AND F_Score >= 4 AND M_Score >= 3
        THEN 'Loyal Customers'
    
     WHEN R_Score = 5 AND F_Score <= 2
                THEN 'Recent Customers'

    WHEN R_Score >= 4 AND F_Score BETWEEN 2 AND 3 AND M_Score >= 3
        THEN 'Potential Loyalist'

    WHEN R_Score BETWEEN 2 AND 3
         AND F_Score BETWEEN 2 AND 3
         AND M_Score BETWEEN 2 AND 3
        THEN 'Need Attention'

    WHEN R_Score <= 2 AND F_Score <= 2 AND M_Score <= 2
        THEN 'Lost Customers'

    ELSE 'Others'
END AS Customer_Segment
    FROM ct2
),
ct4 as (

        SELECT *,
        lag(Monetary) OVER(PARTITION BY [customer name] ORDER BY order_year) as Previous_monetary
        FROM ct3

)

SELECT * FROM ct4
where Monetary>Previous_monetary
and F_Score>4

 
-- 34. Find customers whose Recency improved but Frequency decreased.
-- Business use: Identifies customers who returned but buy less often.


WITH ct1 AS (
    SELECT
        [Customer Name],
        year([order date]) as order_year,
        DATEDIFF(
            DAY,
            MAX([Order Date]),
            (SELECT MAX([Order Date]) FROM orders$)
        ) AS Recency,
        COUNT(DISTINCT [Order ID]) AS Frequancy,
        SUM(Sales) AS Monetary
    FROM orders$
    GROUP BY [Customer Name],year([order date])
),

ct2 AS (
    SELECT *,
        NTILE(5) OVER (ORDER BY Recency DESC) AS R_Score,
        NTILE(5) OVER (ORDER BY Frequancy DESC) AS F_Score,
        NTILE(5) OVER (ORDER BY Monetary DESC) AS M_Score
    FROM ct1
),

ct3 AS (
    SELECT *,
        CONCAT(R_Score, F_Score, M_Score) AS RFM_Score,

CASE
    WHEN R_Score >= 4 AND F_Score >= 4 AND M_Score >= 4
        THEN 'Champions'

    WHEN R_Score >= 3 AND F_Score >= 4 AND M_Score >= 3
        THEN 'Loyal Customers'
    
     WHEN R_Score = 5 AND F_Score <= 2
                THEN 'Recent Customers'

    WHEN R_Score >= 4 AND F_Score BETWEEN 2 AND 3 AND M_Score >= 3
        THEN 'Potential Loyalist'

    WHEN R_Score BETWEEN 2 AND 3
         AND F_Score BETWEEN 2 AND 3
         AND M_Score BETWEEN 2 AND 3
        THEN 'Need Attention'

    WHEN R_Score <= 2 AND F_Score <= 2 AND M_Score <= 2
        THEN 'Lost Customers'

    ELSE 'Others'
END AS Customer_Segment
    FROM ct2
),
ct4 as (

        SELECT *,
        lag(Recency) OVER(PARTITION BY [customer name] ORDER BY order_year) as Previous_recency,
        lag(Frequancy) OVER(PARTITION BY [customer name] ORDER BY order_year) as Previous_frequancy
        FROM ct3

)

SELECT * FROM ct4
WHERE Recency>Previous_recency
and Frequancy<Previous_frequancy




-- 35. Find customers whose Frequency improved but Monetary value decreased.
-- Business use: Detects lower-value repeat purchases.

WITH ct1 AS (
    SELECT
        [Customer Name],
        year([order date]) as order_year,
        DATEDIFF(
            DAY,
            MAX([Order Date]),
            (SELECT MAX([Order Date]) FROM orders$)
        ) AS Recency,
        COUNT(DISTINCT [Order ID]) AS Frequancy,
        SUM(Sales) AS Monetary
    FROM orders$
    GROUP BY [Customer Name],year([order date])
),

ct2 AS (
    SELECT *,
        NTILE(5) OVER (ORDER BY Recency DESC) AS R_Score,
        NTILE(5) OVER (ORDER BY Frequancy DESC) AS F_Score,
        NTILE(5) OVER (ORDER BY Monetary DESC) AS M_Score
    FROM ct1
),

ct3 AS (
    SELECT *,
        CONCAT(R_Score, F_Score, M_Score) AS RFM_Score,

CASE
    WHEN R_Score >= 4 AND F_Score >= 4 AND M_Score >= 4
        THEN 'Champions'

    WHEN R_Score >= 3 AND F_Score >= 4 AND M_Score >= 3
        THEN 'Loyal Customers'
    
     WHEN R_Score = 5 AND F_Score <= 2
                THEN 'Recent Customers'

    WHEN R_Score >= 4 AND F_Score BETWEEN 2 AND 3 AND M_Score >= 3
        THEN 'Potential Loyalist'

    WHEN R_Score BETWEEN 2 AND 3
         AND F_Score BETWEEN 2 AND 3
         AND M_Score BETWEEN 2 AND 3
        THEN 'Need Attention'

    WHEN R_Score <= 2 AND F_Score <= 2 AND M_Score <= 2
        THEN 'Lost Customers'

    ELSE 'Others'
END AS Customer_Segment
    FROM ct2
),
ct4 as (

        SELECT *,
        lag(Monetary) OVER(PARTITION BY [customer name] ORDER BY order_year) as Previous_monetary,
        lag(Frequancy) OVER(PARTITION BY [customer name] ORDER BY order_year) as Previous_frequancy
        FROM ct3

)

SELECT * FROM ct4
WHERE Monetary<Previous_monetary
and Frequancy>Previous_frequancy


-- 36. Find customers whose Monetary value increased
-- while Recency deteriorated.
-- Business use: Identifies valuable but inactive customers.



WITH ct1 AS (
    SELECT
        [Customer Name],
        year([order date]) as order_year,
        DATEDIFF(
            DAY,
            MAX([Order Date]),
            (SELECT MAX([Order Date]) FROM orders$)
        ) AS Recency,
        COUNT(DISTINCT [Order ID]) AS Frequancy,
        SUM(Sales) AS Monetary
    FROM orders$
    GROUP BY [Customer Name],year([order date])
),

ct2 AS (
    SELECT *,
        NTILE(5) OVER (ORDER BY Recency DESC) AS R_Score,
        NTILE(5) OVER (ORDER BY Frequancy DESC) AS F_Score,
        NTILE(5) OVER (ORDER BY Monetary DESC) AS M_Score
    FROM ct1
),

ct3 AS (
    SELECT *,
        CONCAT(R_Score, F_Score, M_Score) AS RFM_Score,

CASE
    WHEN R_Score >= 4 AND F_Score >= 4 AND M_Score >= 4
        THEN 'Champions'

    WHEN R_Score >= 3 AND F_Score >= 4 AND M_Score >= 3
        THEN 'Loyal Customers'
    
     WHEN R_Score = 5 AND F_Score <= 2
                THEN 'Recent Customers'

    WHEN R_Score >= 4 AND F_Score BETWEEN 2 AND 3 AND M_Score >= 3
        THEN 'Potential Loyalist'

    WHEN R_Score BETWEEN 2 AND 3
         AND F_Score BETWEEN 2 AND 3
         AND M_Score BETWEEN 2 AND 3
        THEN 'Need Attention'

    WHEN R_Score <= 2 AND F_Score <= 2 AND M_Score <= 2
        THEN 'Lost Customers'

    ELSE 'Others'
END AS Customer_Segment
    FROM ct2
),
ct4 as (

        SELECT *,
        lag(Monetary) OVER(PARTITION BY [customer name] ORDER BY order_year) as Previous_monetary,
        lag(Recency) OVER(PARTITION BY [customer name] ORDER BY order_year) as Previous_recency
        FROM ct3

)

SELECT * FROM ct4
WHERE Monetary>Previous_monetary
and Recency<Previous_recency

-- 37. Find the top 10% of customers based on RFM score.
-- Business use: Creates a premium customer segment.


WITH ct1 AS (
    SELECT
        [Customer Name],
        year([order date]) as order_year,
        DATEDIFF(
            DAY,
            MAX([Order Date]),
            (SELECT MAX([Order Date]) FROM orders$)
        ) AS Recency,
        COUNT(DISTINCT [Order ID]) AS Frequancy,
        SUM(Sales) AS Monetary
    FROM orders$
    GROUP BY [Customer Name],year([order date])
),

ct2 AS (
    SELECT *,
        NTILE(5) OVER (ORDER BY Recency DESC) AS R_Score,
        NTILE(5) OVER (ORDER BY Frequancy DESC) AS F_Score,
        NTILE(5) OVER (ORDER BY Monetary DESC) AS M_Score
    FROM ct1
),

ct3 AS (
    SELECT *,
        CONCAT(R_Score, F_Score, M_Score) AS RFM_Score,

CASE
    WHEN R_Score >= 4 AND F_Score >= 4 AND M_Score >= 4
        THEN 'Champions'

    WHEN R_Score >= 3 AND F_Score >= 4 AND M_Score >= 3
        THEN 'Loyal Customers'
    
     WHEN R_Score = 5 AND F_Score <= 2
                THEN 'Recent Customers'

    WHEN R_Score >= 4 AND F_Score BETWEEN 2 AND 3 AND M_Score >= 3
        THEN 'Potential Loyalist'

    WHEN R_Score BETWEEN 2 AND 3
         AND F_Score BETWEEN 2 AND 3
         AND M_Score BETWEEN 2 AND 3
        THEN 'Need Attention'

    WHEN R_Score <= 2 AND F_Score <= 2 AND M_Score <= 2
        THEN 'Lost Customers'

    ELSE 'Others'
END AS Customer_Segment
    FROM ct2
),
ct4 as (

        SELECT *,ntile(10) OVER(ORDER BY RFM_Score DESC) as bucket
        FROM ct3

),
ct5  as (

        SELECT sum(Monetary) as Sum_Monetary FROM ct4
        WHERE bucket=1
)

SELECT c4.*,c5.Sum_Monetary FROM ct4 as c4
CROSS JOIN ct5 as c5
where bucket=1


 


-- 38. Find customers whose Monetary value is in the top 20%
-- but Recency is in the bottom 20%.
-- Business use: Identifies high-value churn risks.

WITH ct1 AS (
    SELECT
        [Customer Name],
        year([order date]) as order_year,
        DATEDIFF(
            DAY,
            MAX([Order Date]),
            (SELECT MAX([Order Date]) FROM orders$)
        ) AS Recency,
        COUNT(DISTINCT [Order ID]) AS Frequancy,
        SUM(Sales) AS Monetary
    FROM orders$
    GROUP BY [Customer Name],year([order date])
),

ct2 AS (
    SELECT *,
        NTILE(5) OVER (ORDER BY Recency DESC) AS R_Score,
        NTILE(5) OVER (ORDER BY Frequancy DESC) AS F_Score,
        NTILE(5) OVER (ORDER BY Monetary DESC) AS M_Score
    FROM ct1
),

ct3 AS (
    SELECT *,
        CONCAT(R_Score, F_Score, M_Score) AS RFM_Score,

CASE
    WHEN R_Score >= 4 AND F_Score >= 4 AND M_Score >= 4
        THEN 'Champions'

    WHEN R_Score >= 3 AND F_Score >= 4 AND M_Score >= 3
        THEN 'Loyal Customers'
    
     WHEN R_Score = 5 AND F_Score <= 2
                THEN 'Recent Customers'

    WHEN R_Score >= 4 AND F_Score BETWEEN 2 AND 3 AND M_Score >= 3
        THEN 'Potential Loyalist'

    WHEN R_Score BETWEEN 2 AND 3
         AND F_Score BETWEEN 2 AND 3
         AND M_Score BETWEEN 2 AND 3
        THEN 'Need Attention'

    WHEN R_Score <= 2 AND F_Score <= 2 AND M_Score <= 2
        THEN 'Lost Customers'

    ELSE 'Others'
END AS Customer_Segment
    FROM ct2
),
ct4 as (

        SELECT *,ntile(5) OVER(PARTITION BY order_year ORDER BY Monetary DESC) as bucket_monetary,
        ntile(5) OVER(PARTITION BY order_year ORDER BY Recency DESC) as bucket_recency
        FROM ct3

),
ct5 as (

    SELECT sum(Monetary) as Sum_Monetary FROM ct4
    where bucket_monetary=1
    and bucket_recency=1
)

SELECT * FROM ct4
WHERE bucket_monetary=1
and bucket_recency=1


-- 39. Find customers whose Frequency is in the top 20%
-- but Monetary value is in the bottom 20%.
-- Business use: Identifies frequent low-value buyers.

WITH ct1 AS (
    SELECT
        [Customer Name],
        year([order date]) as order_year,
        DATEDIFF(
            DAY,
            MAX([Order Date]),
            (SELECT MAX([Order Date]) FROM orders$)
        ) AS Recency,
        COUNT(DISTINCT [Order ID]) AS Frequancy,
        SUM(Sales) AS Monetary
    FROM orders$
    GROUP BY [Customer Name],year([order date])
),

ct2 AS (
    SELECT *,
        NTILE(5) OVER (ORDER BY Recency DESC) AS R_Score,
        NTILE(5) OVER (ORDER BY Frequancy DESC) AS F_Score,
        NTILE(5) OVER (ORDER BY Monetary DESC) AS M_Score
    FROM ct1
),

ct3 AS (
    SELECT *,
        CONCAT(R_Score, F_Score, M_Score) AS RFM_Score,

CASE
    WHEN R_Score >= 4 AND F_Score >= 4 AND M_Score >= 4
        THEN 'Champions'

    WHEN R_Score >= 3 AND F_Score >= 4 AND M_Score >= 3
        THEN 'Loyal Customers'
    
     WHEN R_Score = 5 AND F_Score <= 2
                THEN 'Recent Customers'

    WHEN R_Score >= 4 AND F_Score BETWEEN 2 AND 3 AND M_Score >= 3
        THEN 'Potential Loyalist'

    WHEN R_Score BETWEEN 2 AND 3
         AND F_Score BETWEEN 2 AND 3
         AND M_Score BETWEEN 2 AND 3
        THEN 'Need Attention'

    WHEN R_Score <= 2 AND F_Score <= 2 AND M_Score <= 2
        THEN 'Lost Customers'

    ELSE 'Others'
END AS Customer_Segment
    FROM ct2
),
ct4 as (

        SELECT *,
        ntile(5) OVER(PARTITION BY order_year ORDER BY Monetary ASC) as bucket_monetary,
        ntile(5) OVER(PARTITION BY order_year ORDER BY Frequancy DESC) as bucket_recency
        FROM ct3

)
SELECT * FROM ct4
WHERE bucket_monetary=1
and bucket_recency=1


-- 40. Find customers who are above the average in all three
-- RFM dimensions.
-- Business use: Identifies consistently strong customers.



WITH ct1 AS (
    SELECT
        [Customer Name],
        YEAR([Order Date]) AS Order_Year,

        DATEDIFF(
            DAY,
            MAX([Order Date]),
            (SELECT MAX([Order Date]) FROM orders$)
        ) AS Recency,

        COUNT(DISTINCT [Order ID]) AS Frequency,
        SUM(Sales) AS Monetary

    FROM orders$
    GROUP BY
        [Customer Name],
        YEAR([Order Date])
),

ct2 AS (
    SELECT *,
        NTILE(5) OVER (ORDER BY Recency DESC) AS R_Score,
        NTILE(5) OVER (ORDER BY Frequency DESC) AS F_Score,
        NTILE(5) OVER (ORDER BY Monetary DESC) AS M_Score
    FROM ct1
),

ct3 AS (
    SELECT *,
        CONCAT(R_Score, F_Score, M_Score) AS RFM_Score,

        CASE
            WHEN R_Score >= 4 AND F_Score >= 4 AND M_Score >= 4
                THEN 'Champions'

            WHEN R_Score >= 3 AND F_Score >= 4 AND M_Score >= 3
                THEN 'Loyal Customers'

            WHEN R_Score = 5 AND F_Score <= 2
                THEN 'Recent Customers'

            WHEN R_Score >= 4 AND F_Score BETWEEN 2 AND 3
                 AND M_Score >= 3
                THEN 'Potential Loyalist'

            WHEN R_Score BETWEEN 2 AND 3
                 AND F_Score BETWEEN 2 AND 3
                 AND M_Score BETWEEN 2 AND 3
                THEN 'Need Attention'

            WHEN R_Score <= 2 AND F_Score <= 2 AND M_Score <= 2
                THEN 'Lost Customers'

            ELSE 'Others'
        END AS Customer_Segment

    FROM ct2
),

ct4 AS (
    SELECT *,
        NTILE(5) OVER (
            PARTITION BY Order_Year
            ORDER BY Monetary DESC
        ) AS Bucket_Monetary,

        NTILE(5) OVER (
            PARTITION BY Order_Year
            ORDER BY Recency DESC
        ) AS Bucket_Recency

    FROM ct3
),

ct5 AS (
    SELECT
        RFM_Score,
        AVG(Monetary) AS Avg_Monetary
    FROM ct4
    GROUP BY RFM_Score
)

SELECT
    c4.[Customer Name],
    c4.Order_Year,
    c4.Monetary,
    c4.RFM_Score,
    c4.Customer_Segment,
    c5.Avg_Monetary

FROM ct4 AS c4
INNER JOIN ct5 AS c5
    ON c4.RFM_Score = c5.RFM_Score

WHERE c4.Monetary > c5.Avg_Monetary;



-- ============================================================
-- COHORT ANALYSIS — CUSTOMER ACQUISITION
-- ============================================================

-- 41. Assign every customer to a cohort based on their first
-- purchase year.
-- Business use: Groups customers by acquisition period.




-- 42. Count the number of customers acquired in each cohort year.
-- Business use: Measures acquisition volume.

-- 43. Calculate the percentage of total customers belonging
-- to each cohort.
-- Business use: Measures acquisition contribution.

-- 44. Calculate total revenue generated by each customer cohort.
-- Business use: Measures cohort revenue contribution.

-- 45. Calculate average revenue per customer for every cohort.
-- Business use: Compares customer quality across acquisition periods.

-- 46. Find the cohort with the highest average customer revenue.
-- Business use: Identifies the most valuable acquisition period.

-- 47. Find the cohort with the lowest average customer revenue.
-- Business use: Identifies weaker acquisition periods.

-- 48. Find the cohort that generated the highest total revenue.
-- Business use: Identifies the strongest acquisition group.

-- 49. Find the number of customers acquired in each month.
-- Business use: Creates monthly acquisition cohorts.

-- 50. Find the revenue generated by customers acquired in each month.
-- Business use: Measures monthly cohort value.


-- ============================================================
-- COHORT RETENTION
-- ============================================================

-- 51. Calculate the number of customers from each cohort
-- who made another purchase in the following month.
-- Business use: Measures Month-1 retention.

-- 52. Calculate Month-1 retention percentage for every cohort.
-- Business use: Compares early retention across cohorts.

-- 53. Calculate Month-2 retention percentage for every cohort.
-- Business use: Measures medium-term retention.

-- 54. Calculate Month-3 retention percentage for every cohort.
-- Business use: Measures customer persistence.

-- 55. Calculate Month-6 retention percentage for every cohort.
-- Business use: Measures long-term customer retention.

-- 56. Calculate Month-12 retention percentage for every cohort.
-- Business use: Measures annual customer retention.

-- 57. Find the cohort with the highest Month-1 retention.
-- Business use: Identifies the strongest early-retention cohort.

-- 58. Find the cohort with the lowest Month-1 retention.
-- Business use: Identifies acquisition periods with poor customer quality.

-- 59. Find cohorts whose Month-1 retention is higher than
-- the overall average.
-- Business use: Identifies above-average acquisition cohorts.

-- 60. Find cohorts whose Month-6 retention is higher than
-- their Month-1 retention decline is below the company average.
-- Business use: Compares retention decay between cohorts.


-- ============================================================
-- COHORT REVENUE RETENTION
-- ============================================================

-- 61. Calculate Month-0 revenue for every customer cohort.
-- Business use: Measures initial customer value.

-- 62. Calculate Month-1 revenue for every customer cohort.
-- Business use: Measures early recurring revenue.

-- 63. Calculate Month-3 revenue retention for every cohort.
-- Business use: Measures revenue durability.

-- 64. Calculate Month-6 revenue retention for every cohort.
-- Business use: Measures long-term revenue retention.

-- 65. Calculate revenue retention percentage relative to Month-0
-- for every cohort.
-- Business use: Measures how much cohort revenue is retained.

-- 66. Find cohorts where Month-6 revenue is higher than Month-0 revenue.
-- Business use: Identifies cohorts with expanding customer value.

-- 67. Find cohorts where revenue declined by more than 50%
-- between Month-0 and Month-6.
-- Business use: Identifies weak customer cohorts.

-- 68. Find the cohort with the highest cumulative revenue
-- during its first 12 months.
-- Business use: Identifies the most valuable acquisition cohort.

-- 69. Calculate average monthly revenue per customer for every cohort.
-- Business use: Compares customer monetization across cohorts.

-- 70. Find cohorts whose average customer revenue increased
-- during their first six months.
-- Business use: Identifies cohorts with successful customer expansion.


-- ============================================================
-- CUSTOMER LIFETIME VALUE / CLV
-- ============================================================

-- 71. Calculate total lifetime revenue for every customer.
-- Business use: Measures customer lifetime value.

-- 72. Calculate average lifetime revenue by acquisition cohort.
-- Business use: Compares long-term customer value.

-- 73. Find customers whose lifetime revenue is above
-- the overall average.
-- Business use: Identifies high-value customers.

-- 74. Find the top 10 customers by lifetime revenue.
-- Business use: Identifies strategically important customers.

-- 75. Calculate lifetime revenue by region.
-- Business use: Compares customer value geographically.

-- 76. Calculate average customer lifetime revenue by region.
-- Business use: Identifies high-value markets.

-- 77. Calculate lifetime revenue by customer segment.
-- Business use: Compares value across segments.

-- 78. Find customers whose lifetime revenue exceeds $10,000.
-- Business use: Creates a high-value customer list.

-- 79. Find customers whose lifetime revenue is above
-- their region's average.
-- Business use: Identifies regional high-value customers.

-- 80. Find the percentage of total revenue generated
-- by high-lifetime-value customers.
-- Business use: Measures revenue dependency on valuable customers.


-- ============================================================
-- CUSTOMER CHURN
-- ============================================================

-- 81. Identify customers who have not purchased for 90 days.
-- Business use: Creates an early churn-risk list.

-- 82. Identify customers who have not purchased for 180 days.
-- Business use: Identifies likely churned customers.

-- 83. Identify customers who have not purchased for 365 days.
-- Business use: Identifies long-term inactive customers.

-- 84. Find customers who were previously high-value
-- but are now inactive.
-- Business use: Identifies high-priority churn cases.

-- 85. Find customers whose order frequency declined
-- for two consecutive periods.
-- Business use: Detects declining engagement.

-- 86. Find customers whose yearly revenue declined
-- for two consecutive years.
-- Business use: Identifies customer value deterioration.

-- 87. Find customers who purchased frequently in the past
-- but have made only one purchase recently.
-- Business use: Detects behavioral decline.

-- 88. Calculate the churn rate for each year.
-- Business use: Measures annual customer loss.

-- 89. Calculate churn rate by customer cohort.
-- Business use: Identifies cohorts with high customer loss.

-- 90. Find the cohort with the highest churn rate.
-- Business use: Identifies problematic acquisition periods.


-- ============================================================
-- CUSTOMER REACTIVATION
-- ============================================================

-- 91. Find customers who were inactive for more than 180 days
-- and then made a new purchase.
-- Business use: Identifies reactivated customers.

-- 92. Calculate the number of reactivated customers per year.
-- Business use: Measures successful win-back activity.

-- 93. Calculate revenue generated by reactivated customers.
-- Business use: Measures the value of win-back campaigns.

-- 94. Find customers whose gap between two purchases
-- was greater than 180 days.
-- Business use: Identifies reactivation events.

-- 95. Calculate the average revenue generated after reactivation.
-- Business use: Measures post-reactivation customer value.

-- 96. Find customers who were reactivated but did not purchase again.
-- Business use: Identifies unsuccessful reactivation cases.


-- ============================================================
-- CUSTOMER SEGMENTATION
-- ============================================================

-- 97. Segment customers into Low, Medium, and High-value groups
-- based on total revenue.
-- Business use: Creates simple customer value segments.

-- 98. Segment customers based on order frequency.
-- Business use: Identifies frequent and infrequent buyers.

-- 99. Segment customers based on recency.
-- Business use: Identifies active and inactive customers.

-- 100. Create a customer segment using both revenue and frequency.
-- Business use: Identifies high-value frequent customers.

-- 101. Find customers who are High Revenue + High Frequency.
-- Business use: Identifies VIP customers.

-- 102. Find customers who are High Revenue + Low Frequency.
-- Business use: Identifies occasional high-value customers.

-- 103. Find customers who are Low Revenue + High Frequency.
-- Business use: Identifies frequent low-value customers.

-- 104. Find customers who are Low Revenue + Low Frequency.
-- Business use: Identifies low-priority customers.

-- 105. Calculate revenue contribution of each customer segment.
-- Business use: Measures financial importance of each segment.


-- ============================================================
-- CUSTOMER BEHAVIOR CHANGE
-- ============================================================

-- 106. Find customers whose average order value increased
-- compared with the previous year.
-- Business use: Identifies customers increasing spend per transaction.

-- 107. Find customers whose average order value decreased
-- compared with the previous year.
-- Business use: Identifies declining customer spend.

-- 108. Find customers whose order frequency increased
-- but average order value decreased.
-- Business use: Detects customers buying more frequently
-- but spending less per order.

-- 109. Find customers whose order frequency decreased
-- but average order value increased.
-- Business use: Identifies customers buying less often
-- but spending more per transaction.

-- 110. Find customers whose revenue increased while
-- order count decreased.
-- Business use: Identifies customers shifting toward larger purchases.

-- 111. Find customers whose revenue decreased while
-- order count increased.
-- Business use: Identifies declining transaction value.


-- ============================================================
-- ADVANCED CUSTOMER ANALYTICS
-- ============================================================

-- 112. Find customers whose revenue in the latest year
-- is higher than their historical average yearly revenue.
-- Business use: Identifies currently growing customers.

-- 113. Find customers whose latest year's revenue is
-- lower than their historical average.
-- Business use: Identifies declining customers.

-- 114. Find customers who generated revenue in at least
-- three consecutive years.
-- Business use: Identifies long-term active customers.

-- 115. Find customers whose first order value was below average
-- but lifetime revenue is above average.
-- Business use: Identifies customers who grew significantly over time.

-- 116. Find customers whose first order value was above average
-- but lifetime revenue is below average.
-- Business use: Identifies customers with poor long-term conversion.

-- 117. Find customers whose first purchase occurred in the same year
-- but whose lifetime revenue differs significantly.
-- Business use: Measures variation in customer quality within cohorts.

-- 118. Find customers who became high-value within 12 months
-- of their first purchase.
-- Business use: Identifies fast-growing customers.

-- 119. Find customers who took more than 12 months
-- to become high-value customers.
-- Business use: Measures slow customer development.

-- 120. Find customers who generated more than 1% of total company
-- revenue individually.
-- Business use: Identifies strategically critical customers.