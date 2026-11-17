use TraningYa
go


SELECT * FROM [Bank customer churn]

--  churn Amount

SELECT sum(balance) as Churn_Balance FROM [Bank customer churn]
WHERE IsActiveMember=0

--  final Amount (rest of amount after Churn Balance)

SELECT sum(Balance) as total_Balance,sum(Balance)-(SELECT sum(balance) as Churn_Balance FROM [Bank customer churn]
WHERE IsActiveMember=0) as final_amount ,(SELECT sum(balance) as Churn_Balance FROM [Bank customer churn]
WHERE IsActiveMember=0) as Churn_Balance
FROM [Bank customer churn]

--  total Balance

SELECT sum(Balance) as total_balance FROM [Bank customer churn]


-- total Estimated Salary
SELECT sum(EstimatedSalary) as estimated_Salaryy FROM [Bank customer churn]

-- total CUstomer
SELECT count(DISTINCT [CustomerId])  as total_customers FROM [Bank customer churn]

-- total Churn Customer
SELECT count(DISTINCT [CustomerId])  as total_churn_customer FROM [Bank customer churn]
where  IsActiveMember=0
ORDER BY total_churn_customer ASC

-- Total Product 
SELECT sum(NumOfProducts) as total_product  FROM [Bank customer churn]

-- total Creadit Score
SELECT sum(CreditScore) as tota_Score FROM [Bank customer churn]

-- total Earned Points
SELECT sum(Point_Earned) as Earned_points FROM [Bank customer churn]


-- card wise total Balace
SELECT Card_Type,round(sum(Balance),2) as total_balance FROM [Bank customer churn]
GROUP BY  Card_Type
ORDER BY total_balance DESC

-- card wise total customer 
SELECT Card_Type,count(DISTINCT [CustomerId]) as total_customer FROM [Bank customer churn]
GROUP BY Card_Type
ORDER by total_customer

-- card wise total churn
SELECT Card_Type,count(DISTINCT [CustomerId])  as total_churn ,(SELECT count(DISTINCT [CustomerId]) as total_customers FROM [Bank customer churn]) as total_customers,(SELECT count(DISTINCT [CustomerId]) as total_customers FROM [Bank customer churn])-count(DISTINCT [CustomerId]) as After_Churn FROM [Bank customer churn]
WHERE IsActiveMember=0
GROUP BY Card_Type
ORDER BY total_churn

--  Earned points wise Card

SELECT Card_Type,sum(Point_Earned) as Point_Earned FROM [Bank customer churn]
GROUP BY Card_Type
ORDER by Point_Earned


--  card contribution of total customers

SELECT Card_Type,count(DISTINCT [CustomerId]) as total_custmer,count(DISTINCT [CustomerId])*100.0/(
    SELECT count(DISTINCT [CustomerId]) from [Bank customer churn]
) as contr
FROM [Bank customer churn]
GROUP BY Card_Type
ORDER by contr

-- card contribution of total Balance
SELECT Card_Type,sum([Balance]) as total_balance,sum(Balance)*100.0/(
    SELECT sum(Balance) from [Bank customer churn]
) as contr
FROM [Bank customer churn]
GROUP BY Card_Type
ORDER by contr

-- country wise total balance
SELECT geography,round(sum(balance),2) as total_balance FROM [Bank customer churn]
GROUP BY [Geography]
ORDER BY total_balance  DESC

--  country wise Point_Earned

SELECT [Geography],sum(Point_Earned) as Point_Earned FROM [Bank customer churn]
GROUP BY [Geography]
ORDER BY Point_Earned  

-- country wise total customers
SELECT [Geography],count(DISTINCT [CustomerId]) as total_customers FROM [Bank customer churn]
GROUP BY [Geography]
ORDER BY  total_customers

-- country wise total churn customer
SELECT [Geography],count(DISTINCT [CustomerId]) as total_customers ,( SELECT count(DISTINCT [CustomerId]) from [Bank customer churn]) as total_customer FROM [Bank customer churn]
where IsActiveMember=0
GROUP BY [Geography]
ORDER BY  total_customers

-- country wise total customer contribution
SELECT [Geography],count(DISTINCT [CustomerId])  as total_customer,count(DISTINCT [CustomerId])*100.0/(
    SELECT count(DISTINCT [CustomerId]) 
    from [Bank customer churn]
)as contr 
FROM [Bank customer churn]
GROUP BY [Geography]
ORDER by contr

-- country wise total balance contrbution
SELECT [Geography],sum(Balance) as total_balance,sum(Balance)*100.0/(
    SELECT sum(Balance) from [Bank customer churn]
) as contr
FROM [Bank customer churn]
GROUP BY [Geography]
ORDER BY contr



-- gender wise total churn
SELECT Gender,count(DISTINCT [CustomerId])  as total_churn FROM [Bank customer churn]
GROUP BY Gender
ORDER by total_churn

-- gender wise total balance
SELECT Gender,sum(Balance) as total_balance FROM [Bank customer churn]
GROUP BY Gender
ORDER BY total_balance

-- gender wise total estimated salary
SELECT Gender,sum(EstimatedSalary) as total_EstimatedSalary FROM [Bank customer churn]
GROUP BY Gender
ORDER BY total_estimatedSalary

-- gender wise contribution of total balance
SELECT Gender,count(DISTINCT [CustomerId]) as total_Churn FROM [Bank customer churn]
WHERE IsActiveMember=0
GROUP BY Gender
ORDER by total_Churn

-- gender wise contribution of total customers
SELECT Gender,count(DISTINCT [CustomerId]) as total_customer,(SELECT count(DISTINCT [CustomerId]) FROM [Bank customer churn]) as total_customer,COUNT(DISTINCT [CustomerId])*100.0/(
    SELECT count(DISTINCT [CustomerId]) FROM [Bank customer churn]
) as contribution FROM [Bank customer churn]
GROUP BY Gender
ORDER BY contribution DESC

-- gender wise total product sum
SELECT Gender,sum(NumOfProducts) as total_product FROM [Bank customer churn]
GROUP BY Gender
ORDER BY total_product

-- gender wise total satisfation

SELECT Gender,sum(Satisfaction_Score) as Satisfaction_Score  FROM [Bank customer churn]
GROUP BY gender
ORDER BY Satisfaction_Score DESC

-- gender wise Point_Earned
SELECT Gender,sum(Point_Earned) as Point_Earned  FROM [Bank customer churn]
GROUP BY Gender
ORDER by  Point_Earned 

-- gender wise balance contribution

SELECT Gender,sum(Balance) as total_balance,round(sum(Balance)*100.0/(
    SELECT sum(Balance) FROM [Bank customer churn]
),2 )as contr FROM  [Bank customer churn]
GROUP BY Gender
ORDER by contr



--  top 5 customer based on balance 

WITH ct1 as (
    SELECT DISTINCT [CustomerId],sum(Balance) as total_balance FROM [Bank customer churn]
    GROUP BY [CustomerId]
),
ct2 as (
    SELECT *,ROW_NUMBER() OVER(ORDER BY total_balance DESC) as rank FROM  ct1
)
SELECT * FROM ct2
WHERE rank<=5

--  top 5 customer based on EstimatedSalary

WITH ct1 as (
    SELECT DISTINCT [CustomerId],sum(EstimatedSalary) as EstimatedSalary FROM [Bank customer churn]
    GROUP BY [CustomerId]
),
ct2 as (
    SELECT *,ROW_NUMBER() OVER(ORDER BY EstimatedSalary DESC) as rank FROM  ct1
)
SELECT * FROM ct2
WHERE rank<=5

--  top 5 customer based on Tenur
WITH ct1 as (
    SELECT DISTINCT [CustomerId],sum(Tenure) as Tenure FROM [Bank customer churn]
    GROUP BY [CustomerId]
),
ct2 as (
    SELECT *,ROW_NUMBER() OVER(ORDER BY Tenure DESC) as rank FROM  ct1
)
SELECT * FROM ct2
WHERE rank<=5


-- all in one go



WITH ct1 AS (
    SELECT
        CustomerId,
        SUM(Balance) AS Balance,
        SUM(EstimatedSalary) AS EstimatedSalary,
        SUM(Tenure) AS Tenure
    FROM [Bank customer churn]
    GROUP BY CustomerId
),
ct2 AS (
    SELECT *,
        ROW_NUMBER() OVER(ORDER BY Balance DESC) AS Balance_Rank,
        ROW_NUMBER() OVER(ORDER BY EstimatedSalary DESC) AS Salary_Rank,
        ROW_NUMBER() OVER(ORDER BY Tenure DESC) AS Tenure_Rank
    FROM ct1
)
SELECT *
FROM ct2
WHERE Balance_Rank <= 5
   or Salary_Rank <= 5
   OR Tenure_Rank <= 5;





