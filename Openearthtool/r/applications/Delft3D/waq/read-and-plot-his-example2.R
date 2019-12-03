setwd("D:/REPOS-CHECK-OUTS/OpenEarthTools/r/applications/Delft3D/waq")
library(ggplot2)
library(reshape2)
source("read.his2.R")

filename <- file.path("Reproducible example", "delwaq.his")
arr <- read.his2(filename)

## Select locations and relevant substances ================================
locmod=c("Upstream pipe", "Near pipe", "Far field")
submod=c("Temp", "NH4", "CBOD5")

# make data frame ========================================================================
## Use melt to convert between array and data.frame
## similar to "as.data.frame.table"
df <- melt(arr[,locmod, submod], varnames=c("time", "location", "substance"))

### 2. convert dimname (char) to POSIX format

df$datetime <- as.POSIXct(x=df$time)

### 3. include choice of time step, perhaps interval (relatively easy)

df.filtered <- subset(df, datetime >as.POSIXct("2010-01-02 00:00:00"))

# Start plotting==========================================================
p <- ggplot(df.filtered,aes(datetime, value, color=substance))
p + geom_line() +
     labs(x="",y="units?",title=locmod) +
     #scale_x_datetime(breaks="12 hours",format="%H%M") +
    facet_grid(location~.)

ggsave("forwillem2.pdf")
