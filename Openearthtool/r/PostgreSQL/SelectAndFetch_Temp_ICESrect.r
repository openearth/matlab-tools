## Opens connection to ICES oceanographic database (online PostGreSQL database, copy of original <2010)
## hosted by Deltares, The Netherlands
## Sends a query to the database and fetches table with selected entries.
## In this case table with spatially and temporally aggregated temperature
## temp contains average temperature per ICES rectangle, and month 
## for depth <30m and depth >30m 

library(RPostgreSQL)

## loads the PostgreSQL driver
drv <- dbDriver("PostgreSQL")

## Open a connection
con <- dbConnect(drv, dbname="ICES", host="postgresx03.infra.xtr.deltares.nl", user="dbices", password="vectors")

## Submits a statement
strSql <- 
res <- dbSendQuery(con, "select 
 icesname as icesname,
 st_x(st_centroid(the_geom)) as x,
 st_y(st_centroid(the_geom)) as y,
 year,month,
 0 as mindepth,30 as maxdepth,
 avg(temperature) as avg_temp,
 min(temperature) as min_temp,
 max(temperature) as max_temp,
 stddev_pop(temperature) as stdev_temp,
 count(temperature) as count
from 
 icesraster_ns
 ,ocean
where 
 st_contains(the_geom,the_point)
 AND year = 1970
 AND sdepth < 30
 AND temperature > 0
GROUP BY icesname,x,y,year,month
UNION
select 
 icesname as icesname,
 st_x(st_centroid(the_geom)) as x,
 st_y(st_centroid(the_geom)) as y,
 year,month,
 30 as mindepth,2000 as maxdepth,
 avg(temperature) as avg_temp,
 min(temperature) as min_temp,
 max(temperature) as max_temp,
 stddev_pop(temperature) as stdev_temp,
 count(temperature) as count
from 
 icesraster_ns
 ,ocean
where 
 st_contains(the_geom,the_point)
 AND year = 1970
 AND sdepth >= 30
 AND temperature > 0
group by icesname,x,y,year,month")


## fetch n elements from the resultSet into a data.frame (n=-1: all data)
df <- fetch(res, n = 10)

## check dimensions
dim(df)

## write comma-separated data to file
write.csv(df, file = "d:/CheckOuts/CH_VECTORS/TempSelectionTool/temp_icesrect_1970.csv")
#write.csv(df, file = "d:/CheckOuts/CH_VECTORS/TempSelectionTool/temp_XY_1970.csv")


## Closes the connection
dbDisconnect(con)

## Frees all the resources on the driver
dbUnloadDriver(drv)
