
use TraningYa
go

SELECT * FROM 
[dbo].[car_distances]



----- 

WITH ct1 as (

        SELECT car, days,sum(cumulative_distance) as total_disc FROM car_distances
        GROUP BY car,days
        
),
ct2 as (

    SELECT *,
    LAG(total_disc,1,0) OVER(PARTITION BY car ORDER BY days ) as prev_dis
    FROM ct1
)
SELECT car,days,total_disc,prev_dis,
total_disc-prev_dis as cover_dist
FROM ct2 
where prev_dis is NOT NULL



-----

-- Create table
CREATE TABLE sales_product (
    year INT,
    brand VARCHAR(20),
    amount INT
);

-- Insert records
INSERT INTO sales_product (year, brand, amount)
VALUES
(2018, 'apple', 45000),
(2019, 'apple', 35000),
(2020, 'apple', 75000),
(2018, 'samsung', 15000),
(2019, 'samsung', 20000),
(2020, 'samsung', 25000),
(2018, 'nokia', 21000),
(2019, 'nokia', 17000),
(2020, 'nokia', 14000);

-- Display data
SELECT * FROM sales_product;

WITH ct1 as (

        SELECT *,
        lag(amount) OVER(PARTITION BY brand ORDER BY year ASC) as prev_amount
        FROM sales_product as s1
    

)
SELECT * FROM ct1
where amount>prev_amount


 


 


SELECT
    s1.brand,
    s1.[year],
    s1.amount,
    s2.amount AS prev_amount
FROM sales_product AS s1
JOIN sales_product AS s2
    ON s1.brand = s2.brand
    AND s1.[year] = s2.[year] + 1
WHERE s1.amount > s2.amount; 





--------

-- Create table
CREATE TABLE travel_distance_route (
    source VARCHAR(10),
    destination VARCHAR(10),
    distance DECIMAL(10,2)
);

-- Insert records
INSERT INTO travel_distance_route (source, destination, distance)
VALUES
('a', 'b', 21.00),
('b', 'a', 28.00),
('a', 'b', 19.00),
('c', 'd', 15.00),
('c', 'd', 17.00),
('d', 'c', 16.50),
('d', 'c', 18.00);

-- Display data
SELECT * FROM travel_distance_route;




WITH ct1 as (

        SELECT *,
        CASE 
            WHEN source='a' and destination='b' or SOURCE='b' and destination='a' THEN  'a to b'
            WHEN SOURCE='c' and destination='d' or SOURCE='d' and destination='c' THEN 'c to d'
        END as GROUP_destination
        FROM travel_distance_route
)
SELECT GROUP_destination,avg(distance) as avg_dis  FROM ct1
    GROUP BY GROUP_destination

-------

WITH ct1 as (

        SELECT source,destination,sum(distance) as total_disc,count(1) as count,
        row_number() OVER(ORDER BY source ASC) as rk
        FROM travel_distance_route
        GROUP BY source,destination
)
SELECT c2.source,c1.destination,(c1.total_disc+c2.total_disc)/(c1.count+c2.count) as avgs FROM ct1 as c1
JOIN ct1 as c2
ON c1.SOURCE=c2.destination
and c1.rk<c2.rk




-------


SELECT t1.source,t1.destination,t1.distance from travel_distances as t1
JOIN travel_distances as t2
ON t1.source=t2.source
and t1.destination=t2.destination
and t1.distance=t2.distance
and t1.source<t2.destination



------ 

with ct1 as (
    SELECT 1 as i
    UNION ALL
    SELECT i+1
    from ct1
    WHERE i<=100
)
SELECT *FROM ct1

------


WITH ct1 as (

           SELECT CAST(MIN([ORDERDATE]) AS DATE) AS mindate
    FROM ORDERS$

    UNION ALL

    SELECT DATEADD(DAY, 1, mindate)
    FROM ct1
    WHERE mindate < CONVERT(DATE, '2016-10-19', 23)
)

SELECT  format(mindate,'dd-MM-yyyy') as dates FROM ct1
OPTION (MAXRECURSION 0)



--
SELECT format(max([ORDERDATE]),'dd-MM-yy') as lst_date FROM ORDERS$


DECLARE @id int
set @id=5

WITH ct1 as(

        SELECT top 10 emp_id,ename,manager_id FROM employees_
        where emp_id=@id
        UNION ALL
        SELECT e.emp_id,e.ename,e.manager_id  FROM ct1 as c
        JOIN employees_ as e
        on c.emp_id=e.manager_id

)
SELECT e.ename ISNULL(e.ename,'no boss') as managarname
FROM ct1 as c
LEFT JOIN employees_ as e
on c.emp_id=e.emp_id



DECLARE @id int;
set @id=5;

WITH ct1 as (

    SELECT e.emp_id,e.ename,e.manager_id FROM employees_ as e
    WHERE e.emp_id=@id

    UNION ALL

    SELECT e.emp_id,e.ename,e.manager_id 
    FROM employees_ as e
    JOIN ct1 as c
    ON e.emp_id=c.manager_id


)
SELECT e.ename, ISNULL(e.ename ,'no boss') as manegarname FROM employees_ as e
LEFT JOIN ct1 as c
on e.manager_id=c.emp_id



DECLARE @id INT;
SET @id = 5;

WITH ct1 AS (
    -- Anchor query
    SELECT top 10
        e.emp_id,
        e.ename,
        e.manager_id
    FROM employees_ AS e
    WHERE e.emp_id = @id

    UNION ALL

    -- Recursive query: Fetch managers
    SELECT
        e.emp_id,
        e.ename,
        e.manager_id
    FROM employees_ AS e
    JOIN ct1 AS c
        ON e.emp_id = c.manager_id
)
SELECT
    c.emp_id,
    c.ename AS employee_name,
    m.ename AS manager_name
FROM ct1 AS c
LEFT JOIN employees_ AS m
    ON c.manager_id = m.emp_id;