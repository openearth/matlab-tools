
#############################################################################
##                                                                         ##
##                              Example script                             ##
##                    by Willem Stolte, Gerrit Hendriksen                  ##
##                          DELTARES, THE NETHERLANDS                      ##
##                                                                         ##
#############################################################################
## Opens connection to ICES oceanographic database
## (online PostGreSQL database, copy of original <2010)
## hosted by Deltares, The Netherlands 
## Fetches table with selected entries. In this case Temperature
## Selects only data within a certain sea region (defined in database)

library(RPostgreSQL)

## load the PostgreSQL driver
drv <- dbDriver("PostgreSQL")

## Open a connection
con <- dbConnect(drv, dbname="ICES", host="postgresx03.infra.xtr.deltares.nl", user="dbices", password="vectors")

## Submits a statement and declare variable result set (rs)
rs <- dbSendQuery(con, "SELECT year, month, sdepth, ST_X(the_point), ST_y(the_point), temperature
  FROM ocean, seas 
  WHERE year = 1970 
    AND name = 'North Sea'
    AND temperature IS NOT NULL")

#      AND name = 'Baltic Sea'
#      AND name = 'Mediterranean Sea'
#      AND ST_Contains(s.the_geom)


## fetch all elements from the result set into a data.frame
## n = number of records, n=-1 means all records
df <- fetch(rs, n = -1)

## Check number of records
dim(df)

##show first lines
head(df)

## write comma-separated data to file
write.table(df, file = "Filename.txt", sep = ",")

## Closes the connection
dbDisconnect(con)

## Frees all the resources on the driver
dbUnloadDriver(drv)

