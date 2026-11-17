-- 21. Display employee names along with their department names.

 SELECT e1.EmployeeName,e2.department FROM employees as e1
 INNER JOIN Employees as e2
 on e1.EmployeeID=e2.EmployeeID
 


-- 22. Find employees who do not belong to any department.

SELECT * FROM employees as e1
INNER JOIN employees as e2
on e1.EmployeeID=e2.EmployeeID
and e1.Department<>e2.Department


-- 23. Find departments that have no employees.

SELECT e1.Department,e1.EmployeeID FROM employees as e1
LEFT JOIN employees as e2
on e1.Department=e2.Department
where e1.EmployeeID is NULL



-- 24. Find pairs of employees working in the same department.


SELECT e1.Department,e1.EmployeeName  as total_emp from Employees as e1
INNER JOIN Employees as e2
ON e1.Department=e2.Department
ORDER BY e1.department ASC


-- 25. Find customers who have never placed an order.

SELECT *from orders$ as o1
inner JOIN Orders$ as o2 
ON o1.[Order ID]=o2.[Order ID]
and o1.[Customer ID] is NULL

-- 25. Find customers who have never placed an order.


SELECT * FROM customers_order as c
LEFT JOIN orders_customers as o
on c.[customer id]=o.[customer id]
WHERE o.[order id] is NULL



-- 26. Find products that have never been sold.


SELECT p.[product id],p.[product name] FROM Products as p
left JOIN orderDetails as o
ON o.[product id]=p.[product id]
WHERE o.[product id] is NULL





-- 27. Find customers who purchased products from multiple categories.


SELECT [customer name],count(DISTINCT category) as total_category FROM orders$
GROUP BY [customer name]
HAVING count(DISTINCT category)>1

--along with name of the category

SELECT 
[customer name],
string_agg(category,' ') as category_name,
count(DISTINCT category) as total_category
FROM 
(
    SELECT * FROM orders$
)as t
GROUP BY [customer name]
HAVING count(DISTINCT category)>1
ORDER BY total_category DESC



-- 28. Find orders that contain more than one product.

SELECT DISTINCT [order id],count(DISTINCT [product id])  as total_products FROM  orders$
GROUP BY [order id]
HAVING count(DISTINCT [product id])>1
ORDER BY total_products DESC


SELECT o1.[order id],o1.[product name],o2.[product name] FROM orders$ as o1
JOIN  orders$ as o2
on o1.[order id]=o2.[order id]
and o1.[product name]<o2.[product name]

-- 29. Find employees who earn more than at least one employee in another department.

SELECT e1.[EmployeeName],e1.salary, e2.[EmployeeName],e2.salary FROM employees as e1
JOIN employees  as e2
on e1.salary>e2.salary
AND  e1.department<>e2.department




-- 30. Find records present in one table but missing from another.




SELECT a.* FROM employees_A as a
where a.[employeeId] not in(
    SELECT b.[employeeId]  FROM employees_B as b

)



