#Read in raw data
spmveerse<-file.path("D:/My Documents/Data from Donar/SPMVeerse.xlsx")
SPMVeerse<-readWorksheetFromFile(spmveerse,sheet=1)

#Convert data into correct format
SPMVeerse$Dates <- as.Date(as.character(SPMVeerse$datum), format = "%Y%m%d")
SPMVeerse$Values <- as.numeric(SPMVeerse$wrd)
SPMVeerse$Locations <- SPMVeerse$locoms


#Make subsets of dataframes
df <- data.frame(SPMVeerse$Dates,SPMVeerse$Values,SPMVeerse$Locations, SPMVeerse$bemhgt,SPMVeerse$anacod)
subset <- subset(df, SPMVeerse.Locations == "Soelekerkepolder oost" & SPMVeerse.bemhgt =="-100")
subset1 <- subset(subset, as.Date(SPMVeerse.Dates) >= "1970-01-01" & as.Date(SPMVeerse.Dates)<="1980-01-01")
subset2<- subset(subset, as.Date(SPMVeerse.Dates) >= "1980-01-01" & as.Date(SPMVeerse.Dates)<="2014-01-01")

#events
name <- "Re-introduction of tides"
date <- as.Date("2004-07-23")
events <- data.frame(name,date)
baseline <- min(subset$SPMVeerse.Values)
delta <- 0.5 * diff(range(subset$SPMVeerse.Values))
events$ymin <- baseline
events$timelapse <- c(diff(events$date),Inf)
events$bump <- events$timelapse < 4*370 # ~4 years
offsets <- rle(events$bump)
events$offset <- unlist(mapply(function(l,v) {if(v){(l:1)+1}else{rep(1,l)}}, l=offsets$lengths, v=offsets$values, USE.NAMES=FALSE))
events$ymax <- events$ymin + events$offset * delta

#save plot in pdf
pdf("Timeseriesspmveerse.pdf", width=12, height=5.5)
print(ggplot()+ 
        geom_line(data=subset1, aes(x=SPMVeerse.Dates, y=SPMVeerse.Values))+
        geom_line(data=subset2, aes(x=SPMVeerse.Dates, y=SPMVeerse.Values))+
        #scale_y_log10()+
        geom_segment(data = events, mapping=aes(x=date, y=ymin, xend=date, yend=ymax), colour = 'red') +
        geom_point(data = events, mapping=aes(x=date,y=ymax), size=3, colour = 'red') +
        geom_text(data = events, mapping=aes(x=date, y=ymax, label=name), hjust=-0.1, vjust=0.1, size=4, colour = 'red') +
        scale_x_date(labels = date_format("%Y"),breaks="5 years", minor_breaks = "1 year")+
        scale_y_continuous(breaks = seq(0,90,by=10), minor_breaks = seq(0,90,by=5))+
        ylab("SPM Concentration (mg/L)")+
        xlab("")+
        ggtitle("Lake Veere (Location Soelekerkepolder Oost)"))
dev.off()