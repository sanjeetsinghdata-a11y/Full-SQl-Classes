
use TraningYa
go

SELECT *from input_clustred
SELECT * FROM clusted_detail



SELECT *, Destination_Latitude*Total_Demand as wt_latitude,Destination_Longitude*Total_Demand as wt_longitude into #temp_2 FROM clusted_detail

SELECT * FROM  #temp_2


with  ct1 as (

        SELECT ClusterNo, sum(Destination_Latitude) as total_latitude,sum(Destination_Longitude) as total_longtitude, count(*) as total_clustred ,sum(Total_Demand) as total_Demand 
        FROM  #temp_2
        GROUP BY ClusterNo
        HAVING count(*)>15
)
SELECT * into #Pivot_2 FROM ct1 



--locations

 
SELECT *,total_latitude/total_Demand as wh_lati,total_longtitude/total_Demand as wh_long into #Loc_table1 FROM #Pivot_2



SELECT * FROM #Loc_table1

SELECT wh_lati as wh_lat_0, wh_long as wh_lon_0  into #loc_1 from #Loc_table1
where ClusterNo=0


SELECT wh_lati as wh_lat_2 ,wh_long as wh_lon_2 into #loc_2 from #Loc_table1
where ClusterNo=2


SELECT wh_lati as wh_lat_3 ,wh_long as wh_lon_3 into #loc_3 from #Loc_table1
where ClusterNo=3

SELECT * FROM #loc_1
SELECT * FROM #loc_2
SELECT * FROM #loc_3



SELECT * into #final from input_clustred
CROSS JOIN #loc_1
CROSS JOIN #loc_2
CROSS JOIN #loc_3



WITH ct1 AS (
    SELECT *,
        2 * 6371 * ASIN(SQRT(
            POWER(SIN((wh_lat_0 - Destination_Latitude) * PI() / 360), 2) +
            COS(wh_lat_0 * PI() / 180) *
            COS(Destination_Latitude * PI() / 180) *
            POWER(SIN((wh_lon_0 - Destination_Longitude) * PI() / 360), 2)
        )) AS dist1,

        2 * 6371 * ASIN(SQRT(
            POWER(SIN((wh_lat_2 - Destination_Latitude) * PI() / 360), 2) +
            COS(wh_lat_2 * PI() / 180) *
            COS(Destination_Latitude * PI() / 180) *
            POWER(SIN((wh_lon_2 - Destination_Longitude) * PI() / 360), 2)
        )) AS dist2,

        2 * 6371 * ASIN(SQRT(
            POWER(SIN((wh_lat_3 - Destination_Latitude) * PI() / 360), 2) +
            COS(wh_lat_3 * PI() / 180) *
            COS(Destination_Latitude * PI() / 180) *
            POWER(SIN((wh_lon_3 - Destination_Longitude) * PI() / 360), 2)
        )) AS dist3
    FROM #final
)

SELECT *,
       m.mins AS Minimum_Distance
FROM ct1
CROSS APPLY (
    SELECT MIN(v.dist) AS mins
    FROM (VALUES (dist1), (dist2), (dist3)) AS v(dist)
) AS m;
