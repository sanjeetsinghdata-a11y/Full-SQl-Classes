use TraningYa
go



CREATE TABLE emp_buckets (
    id INT,
    name VARCHAR(50),
    buckets INT
);

INSERT INTO emp_buckets (id, name, buckets)
VALUES
(1, 'emp1', 1),
(2, 'emp2', 1),
(3, 'emp3', 1),
(4, 'emp4', 2),
(5, 'emp5', 3),
(6, 'emp6', 3),
(7, 'emp7', 4),
(8, 'emp8', 4);

SELECT * FROM emp_buckets;



CREATE TABLE travel_distances (
    source VARCHAR(50),
    destination VARCHAR(50),
    distance INT
);

INSERT INTO travel_distances (source, destination, distance)
VALUES
('Bangalore', 'Hyderabad', 400),
('Hyderabad', 'Bangalore', 400),
('Mumbai', 'Delhi', 700),
('Delhi', 'Mumbai', 700),
('Pune', 'Chennai', 550),
('Chennai', 'Pune', 550);

SELECT *
FROM travel_distances;



SELECT t1.source,t1.destination,t1.distance from travel_distances as t1
JOIN travel_distances as t2
on t1.source=t2.source
AND t1.destination=t2.destination
and t1.distance=t2.distance
where t1.source<t2.destination
 



CREATE TABLE employees_ (
    emp_id INT,
    ename VARCHAR(50),
    manager_id INT
);

INSERT INTO employees_ (emp_id, ename, manager_id)
VALUES
(1, 'JOHN', 5),
(2, 'MARK', 8),
(3, 'STEVE', 8),
(4, 'TOM', 3),
(5, 'LARA', 8),
(6, 'SIMON', 2),
(7, 'DAVID', 4),
(8, 'BEN', NULL),
(9, 'STACY', 2),
(10, 'SAM', 5);

SELECT * FROM employees_;


SELECT *from employees_

-- Display employee name and their manager name


SELECT
    e1.ename AS employee_name,
    e2.ename AS manager_name
FROM employees_ AS e1
JOIN employees_ AS e2
    ON e1.manager_id = e2.emp_id;



DECLARE @Emp_id int
set @Emp_id=7

WITH ct1 AS
(
    -- Anchor query: Start with employees who have no manager
    SELECT
        emp_id,
        ename AS employee_name,
        manager_id
    FROM employees_
    WHERE Emp_id=@Emp_id

    UNION ALL

    -- Recursive query: Find employees working under each manager
    SELECT
        e.emp_id,
        e.ename AS employee_name,
        e.manager_id
    FROM employees_ AS e
    JOIN ct1 AS c
        ON e.manager_id = c.emp_id
)
SELECT
    c1.emp_id,
    c1.employee_name,
    c1.manager_id
     
FROM ct1 as c1





------ part 2---



-- Create the table
CREATE TABLE car_distances (
    car VARCHAR(20),
    trip INT,
    cumulative_distance DECIMAL(10, 1)
);

-- Insert the data
INSERT INTO car_distances (car, trip, cumulative_distance)
VALUES
('CarA', 1, 100),
('CarA', 2, 180.5),
('CarA', 3, 250),
('CarB', 1, 0),
('CarB', 2, 170.2),
('CarC', 1, 60),
('CarC', 2, 120.5),
('CarC', 3, 120.5),
('CarC', 4, 260);

-- Display the data
SELECT *
FROM car_distances;


EXEC sp_rename 'car_distances.trip', 'Days', 'COLUMN';



SELECT car,Days,cumulative_distance,
cumulative_distance-lag(cumulative_distance,1,0) over(PARTITION BY car ORDER BY  cumulative_distance ASC) as final_
FROM car_distances
ORDER BY car,days




create table em(
    id int,
    name varchar(20)
)

INSERT INTO em (id, name)
VALUES
(1, 'emp1'),
(2, 'emp2'),
(3, 'emp3'),
(4, 'emp4'),
(5, 'emp5'),
(6, 'emp6'),
(7, 'emp7'),
(8, 'emp8');

SELECT * FROM em

with ct1 as (

    SELECT *,ntile(4) OVER(ORDER BY id ASC) as b FROM em
)
SELECT STRING_AGG(name,',') as output FROM ct1
GROUP BY b

 
 