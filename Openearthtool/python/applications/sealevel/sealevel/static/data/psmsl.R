library(plyr)
library(rjson)
library(ncdf4)
library(reshape2)
library(circular)




records.df <-  read.table("records_annual.csv", sep=",", header=T)
overview.df <-  read.table("overview.csv", sep=",", header=T, quote='"')
stations <- dlply(overview.df, names(overview.df), function(x){
    station <- as.list(x)
    station$data <- subset(records.df, records.df$id == x$id)
    return(station)
}, .progress = "text")
names(stations) <- as.numeric(overview.df$id)

stations.sel <- c("VLISSINGEN", "HOEK VAN HOLLAND", "DEN HELDER", "DELFZIJL",  "HARLINGEN", "IJMUIDEN")
stations.dutch <- Filter(function(station){station$name %in% stations.sel}, stations)
stations.dutch.df <- ldply(stations.dutch, function(station){station$data})


na.fill <- colwise(function(d){
    d[is.na(d)] <- mean(d,na.rm=TRUE)
    return(d)
})

# replace missings by mean for IB, u_i and v_i, u2 and v2
stations.dutch.df[,c("ib", "u_i", "v_i", "u2", "v2")] <- na.fill(stations.dutch.df[,c("ib", "u_i", "v_i", "u2", "v2")])

## Make a mean station
station.mean <- list()
station.mean$id <- max(as.numeric(names(stations)))+1
station.mean$latitude <- mean(laply(stations.dutch, function(station){station$latitude}))
station.mean$longitude <- mean(laply(stations.dutch, function(station){station$longitude}))
station.mean$name <- "DUTCH MEAN"
station.mean$coastline.code <- 150
station.mean$station.code <- 10000
station.mean$quality.flag <- "N"
station.mean$data <- aggregate(cbind(waterlevel,ib, u_i, v_i, u2, v2) ~ year.month, data=stations.dutch.df, FUN=mean)
station.mean$data$days.missing <- "N"
station.mean$data$flag <- 0
station.mean$peltier <-  mean(laply(stations.dutch, function(station){station$peltier}))
stations[[as.character(station.mean$id)]] <- station.mean


## Simplify the element
stations.l <- llply(stations, function(station) {
    df <- station$data[,c("year.month", "waterlevel", "ib", "u2", "v2")]

    df$waterlevel <- round(df$waterlevel - 7000,2)
    df$ib <- round(df$ib,2)
    df$u2 <- round(df$u2, 2)
    df$v2 <- round(df$v2, 2)

    df$year.month <- df$year.month - 1970
    fit <- lm(waterlevel ~ year.month, df)
    wl1970 <- predict(fit, newdata=data.frame(year.month=0, waterlevel=0))
    wl1900 <- predict(fit, newdata=data.frame(year.month=-70, waterlevel=0))
    ## Recalculate the fit, with the changed waterlevel
    fit <- lm(waterlevel ~ year.month, df)


    colnames(df)[1:5] <- c("y", "h", "ib", "u2", "v2")

    l <- as.list(df)
    l["wl1900"] <- wl1900
    l["wl1970"] <- wl1970
    l["lat"] <- station$latitude
    l["lon"] <- station$longitude
    l["peltier"] <- station$peltier
    l["name"] <- as.character(station$name)
    l["id"] <- station$id
    l[["coef"]] <- as.list(coef(fit))

    return(l)
}, .parallel=FALSE, .progress="text")


## drop the element names
names(stations.l) <- NULL
## dump to json
json = toJSON(stations.l)
## store in file
cat(json, file="psmsl.json")

# no need to save data here...
stations.l <- llply(stations.l, function(station) {
    station$y <- station$y + 1970
    return(station)
})

## For the Rdata we want to index by names
names(stations.l) <- laply(stations.l, function(station){station$name})
## Save to file, for faster access.
save(stations.l, file="stations.l.rdata")


