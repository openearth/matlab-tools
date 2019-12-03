library(ggplot2)
library(reshape2)
source("read.his.R")

filename <- file.path("Reproducible example", "delwaq.his")
arr <- read.his(filename)

## Select locations and relevant substances ================================
locmod=c("Upstream pipe", "Near pipe", "Far field")
submod=c("Temp", "NH4", "CBOD5")

# make data frames ========================================================================
### uses a function "frame.data" from source delwaq.rpj (see beginning)
### Quite sure the function can be improved:
### 1. no loops but some kind of apply function?

## Use melt to convert between array and data.frame
## similar to "as.data.frame.table"
df <- melt(arr[,locmod, submod], varnames=c("time", "location", "substance"))


### 2. include choice of time step, perhaps interval (relatively easy)

df.filtered <- subset(df, time<10000)

### 3. Use time stamp for POSIX (even better: include in readhis function)

df$date <- as.POSIXct.numeric(x=df$time, origin="1970-01-01")


# Start plotting==========================================================
p <- ggplot(df,aes(date, value, color=substance))
p + geom_line() +
    labs(xlab="", ylab=submod[1], title=locmod) +
    facet_grid(location~.)

ggsave("forwillem.pdf")
