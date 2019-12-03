#######################################################################
##                                                                   ##
##         Opens connection to ICES oceanographic database           ##
##       (online PostGreSQL database, copy of original <2010)        ##
##                  willem.stolte@deltares.nl                        ##
##                gerrit.hendriksen@deltares.nl                      ##
##                                                                   ##
#######################################################################
##
## Database hosted by Deltares, The Netherlands 
## Script fetches table with selected entries. 
## In this case nitrate+nitrite sum according to SQL statement below
## Option to aggregate per ICES rectangles in the North Sea (icesraster_ns)
## Install the library "RPostgreSQL" before running the script

library(RPostgreSQL)

## load the PostgreSQL driver
drv <- dbDriver("PostgreSQL")

## Open a connection using VECTORS project credentials
con <- dbConnect(drv, dbname="ICES", host="postgresx03.infra.xtr.deltares.nl", user="dbices", password="vectors")

## Submit an SQL statement that selects all points where nitrate concentration >0
rs <- dbSendQuery(con,"select 
  latitude,longitude,year,month,(ntra+COALESCE(ntri,0)) as NOx
from 
   ocean
where 
  year > 2002 AND year < 2009 AND ntra IS NOT NULL"
                  )

## Submit an SQL statement
# rs <- dbSendQuery(con, "select 
#  st_x(st_centroid(the_geom)) as x,
#   st_y(st_centroid(the_geom)) as y,
#   year,month,
#    0 as mindepth,30 as maxdepth,
#      avg(ntra+COALESCE(ntri,0)) as "avg_NOx",
#       min(ntra+COALESCE(ntri,0)) as "min_NOx",
#        max(ntra+COALESCE(ntri,0)) as "max_NOx",
#         stddev_pop(ntra+COALESCE(ntri,0)) as "stdev_NOx",
#  count(ntra+COALESCE(ntri,0)) as count
# (ntra+COALESCE(ntri,0)) as "NOx"
#  from 
#   icesraster_ns
#    ,
#    ocean
#    where 
#  st_contains(the_geom,the_point)
#  AND 
#  year > 2002
#  AND year < 2009
#  AND sdepth < 30
#  AND ntra IS NOT NULL
# group by x,y,year,month
# order by year,month 
# ")

## fetch all elements from the resultSet into a data.frame
df <- fetch(rs, n = 100)

## Check number of records
dim(df)

## write comma-separated data to file
write.table(df, file = "Filename.txt", sep = ",")

## Closes the connection
dbDisconnect(con)

## Frees all the resources on the driver
dbUnloadDriver(drv)

