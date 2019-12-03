## Opens connection to ICES oceanographic database (online PostGreSQL database, copy of original <2010)
## hosted by Deltares, The Netherlands 
## Fetches table with selected entries. 

library(RPostgreSQL)

## loads the PostgreSQL driver
drv <- dbDriver("PostgreSQL")

## Open a connection
con <- dbConnect(drv, dbname="ICES", host="postgresx03.infra.xtr.deltares.nl", user="dbices", password="vectors")

## Submits a statement
rs <- dbSendQuery(con, "select 
  latitude,longitude,year,month,day,hr,sdepth,
temperature,salinity,doxy,phos,tphs,slca,ntra,ntri,amon,ntot,cphl
 from 
   ocean
   where 
 year > 2002
 AND year < 2008
AND st_within(the_point,st_setsrid(ST_MakePolygon(ST_GeomFromText('LINESTRING(-4 49,-4 57.5,10 57.5, 10 49, -4 49)')),4326))
 AND ntra IS NOT NULL
")

## fetch all elements from the resultSet into a data.frame
df <- fetch(rs, n = -1)

## Check number of records
dim(df)

## write comma-separated data to file
write.table(df, file = "All_Nutrients_North_Sea.csv", sep = ",")

## Closes the connection
dbDisconnect(con)

## Frees all the resources on the driver
dbUnloadDriver(drv)

