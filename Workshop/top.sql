with ct1 (
    SELECT *,
    row_number() OVER(PARTITION BY subcategory ORDER BY sales DESC)as rk FROM  ORDERS$
    
)
SELECT * FROM ct1
where rk=1



SELECT top 1 * FROM ORDERS$
ORDER BY Sales DESC

SELECT * FROM ORDERS$
where [sub_category]='phone'
and profit>0
ORDER by sales DESC




SELECT    *  FROM ORDERS$
where YEAR([order date])=2014
AND state in ('california','new york')
AND segment='consumer'
and profit>0


SELECT Count(*)as total FROM Orders$ 
WHERE LEFT([State], 1) IN ('A','E','I','O','U','a','e','i','o','u')  and  RIGHT([State],1) IN ('A','E','I','O','U','a','e','i','o','u')

