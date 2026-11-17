use SUPER_SAMPLESTORE
GO


--views 

--- creating the view table to stor  the data in the  form of table i dosnt make any changes if you  are  creating a view and storing the data in, 
--- mainly used of view , is to stored data of specific condition/ 

CREATE View C_Data AS
SELECT  *
FROM Orders$
WHERE [State] = 'California'


---- altering  the view table by using the alter view table_name this commande is  used  to altering the defination of the view table 
ALTER View C_Data AS
SELECT  YEAR([Order Date]) AS year
       ,[Customer ID]
       ,[Customer Name]
       ,Country
       ,[State]
       ,Sales
       ,Profit
       ,Quantity
FROM Orders$
WHERE [State] = 'California'
AND YEAR([Order Date]) <= 2016


--- updating the name of the view by using exec sp_rename 'oldname','newName'


EXEC sp_rename 'C_Data', 'California_Data_till_2016';



