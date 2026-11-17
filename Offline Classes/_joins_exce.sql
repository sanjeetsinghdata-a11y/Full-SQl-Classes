

use SUPER_SAMPLESTORE
go





SELECT o.[Order ID],o.[product name],o1.[Product Name] FROM Orders$ as o
JOIN Orders$ as o1
on o.[Order ID]=o1.[Order ID]
AND o.[Product Name]<o1.[Product Name]


use TraningYa
go


SELECT * FROM car_distances



SELECT 
o1.source,o1.destination,o1.distance,o2.source,o2.destination,o2.distance
from [dbo].[travel_distances]  as o1
JOIN travel_distances as o2
on o1.source=o2.SOURCE
and o1.destination=o2.destination
and o1.distance=o2.distance
and o1.source<o2.destination

create Table text (
    id  int ,
    name VARCHAR(20)
)

INSERT INTO text (id, name)
VALUES
    (1, 'Siddharth'),
    (2, 'Rahul'),
    (3, 'Amit'),
    (4, 'Priya'),
    (5, 'Neha');

-- Display all records
SELECT * FROM text;



CREATE table text2(
    id int,
    name VARCHAR(20)
)



INSERT INTO text2 (id, name)
VALUES
    (1, 'Siddharth')
    

-- Display all records
SELECT * FROM text2;


SELECT * FROM text as t
CROSS JOIN text2 as t2
where t.name<>t2.name

SELECT * FROM text2



SELECT d1.source , D.destination ,d.distance FROM  travel_distances d join travel_distances d1
on d1.source  = d.source
and d1.distance = d.distance
and d1.destination = d.destination
and d1.SOURCE< d.destination



use SUPER_SAMPLESTORE
GO



SELECT  o.[order id],o.[product name],p.[product name] FROM Orders$ o join Orders$ P
on o.[Order ID] = p.[Order ID]
and o.[Product Name]<p.[Product Name]


SELECT  o.[order id],o.[product name],p.[product name] FROM Orders$ o join Orders$ P
on o.[Order ID] = p.[Order ID]
and o.[Product Name]=p.[Product Name]
and o.[Product id]<p.[Product id]



CREATE TABLE Orders (
    order_date DATE,
    size VARCHAR(10),
    ordered_qty INT
);




INSERT INTO Orders (order_date, size, ordered_qty)
VALUES
('2026-10-01', 'S', 15),
('2026-10-01', 'M', 20),
('2026-10-01', 'L', 10),
('2026-10-02', 'S', 20),
('2026-10-02', 'M', 10),
('2026-10-02', 'L', 12),
('2026-10-03', 'S', 10),
('2026-10-03', 'M', 8),
('2026-10-03', 'L', 2),
('2026-10-04', 'L', 5);



CREATE TABLE Inventory (
    size VARCHAR(10),
    initial_stock INT
);


INSERT INTO Inventory (size, initial_stock)
VALUES
('S', 40),
('M', 35),
('L', 25);



SELECT * FROM  Inventory
SELECT * FROM Orders

-- =========================================================
-- Objective:
-- For each product size, determine whether it is out of stock
-- or still available.
-- If out of stock, identify the depletion date.
-- Otherwise, calculate the remaining available quantity.


SELECT order_date,size, sum(ordered_qty) as total_qty  into #temp_ord from Orders
GROUP BY [size],order_date

SELECT * FROM #temp_ord



select* from inventory


with ct1 as (

SELECT t.order_date,i.[size],i.initial_stock,t.total_qty,i.initial_stock-t.total_qty as Remaning_orde 
FROM Inventory as i
LEFT JOIN #temp_ord as t
on i.[size]=t.[size]
),
ct2 as(

    SELECT *, lag(Remaning_orde) OVER(PARTITION BY size ORDER BY order_date ASC) as prevOrde FROM ct1
),
ct3 as (
    SELECT *,prevOrde-total_qty as final_qty
FROM ct2
),
ct4 as 
(
SELECT *,
CASE 
    WHEN   final_qty>0 THEN  'in stock'
    WHEN  final_qty<=0 THEN 'out of stock'
END as flag
FROM ct3
)

SELECT * FROM ct4







SELECT * FROM Inventory
SELECT * FROM Orders



-- Determine stock status for each product (size),
-- identify the depletion date if out of stock,
-- otherwise calculate the remaining available quantity.
-- Determine stock status for each product (size),
-- identify the depletion date if out of stock,
-- otherwise calculate the remaining available quantity.

WITH daily_orders AS (

    -- Step 1: Calculate total ordered quantity for each size on each date
    SELECT
        order_date,
        size,
        SUM(ordered_qty) AS total_ordered
    FROM Orders
    GROUP BY order_date, size

),

running_stock AS (

    -- Step 2: Calculate cumulative ordered quantity for each size
    SELECT
        d.order_date,
        d.size,
        i.initial_stock,
        d.total_ordered,

        -- Calculate cumulative orders date-wise
        SUM(d.total_ordered) OVER (
            PARTITION BY d.size
            ORDER BY d.order_date
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS cumulative_ordered

    FROM daily_orders d
    JOIN Inventory i
        ON d.size = i.size

),
final_result AS (

    -- Step 3: Determine the date when stock gets depleted
    SELECT
        size,
        initial_stock,

        -- Find the first date when cumulative orders reach initial stock
        MIN(
            CASE
                WHEN cumulative_ordered >= initial_stock
                THEN order_date
            END
        ) AS depletion_date,

        -- Calculate total quantity ordered
        MAX(cumulative_ordered) AS total_ordered

    FROM running_stock
    GROUP BY size, initial_stock

)
-- Step 4: Display final inventory status
SELECT
    size,
    initial_stock,

    CASE
        WHEN total_ordered >= initial_stock
            THEN 'Out of Stock'
        ELSE 'Available'
    END AS stock_status,

    depletion_date,

    CASE
        WHEN total_ordered < initial_stock
            THEN initial_stock - total_ordered
        ELSE 0

    END AS remaining_quantity

FROM final_result
ORDER BY size;





SELECT * FROM  inventory
SELECT *from orders


with ct1 as(


            SELECT order_date,size,sum(ordered_qty) as used_qty from orders
            GROUP BY size,order_date
),
Running_stock as (

        SELECT o.order_date,i.initial_Stock,i.size,o.used_qty,
        sum(o.used_qty) OVER(PARTITION BY o.size  ORDER BY order_date ASC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) as Running_qty
        FROM  inventory as i
        JOIN  ct1 as o
        on i.size=o.size
),
final_result as (

        SELECT size,initial_stock,
        min(
            CASE 
                WHEN running_qty>=initial_stock THEN  order_date
               
            END
        ) as deplection_date,

        max(running_qty) as total_qty
        FROM running_stock
        GROUP BY initial_stock,size
)
SELECT size,initial_stock,
CASE 
    WHEN total_qty>=initial_stock THEN  
     'out  of stock'
    ELSE  'available'
END as Stock_Availability,
deplection_date,

CASE 
    WHEN total_qty<initial_stock THEN  
        initial_stock - total_qty 
    else 0
END as   remaining_Stock

FROM final_result

