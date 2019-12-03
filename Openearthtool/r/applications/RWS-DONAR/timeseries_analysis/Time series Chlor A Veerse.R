#Read in raw data
chlorAveerse<-file.path("D:/My Documents/Data from Donar/ChlorAVeerse.xlsx")
ChlorAVeerse<-readWorksheetFromFile(chlorAveerse,sheet=1)

#Convert data into correct format
ChlorAVeerse$Dates <- as.Date(as.character(ChlorAVeerse$datum), format = "%Y%m%d")
ChlorAVeerse$Values <- as.numeric(ChlorAVeerse$wrd)
ChlorAVeerse$Locations <- ChlorAVeerse$locoms

#Make subsets of dataframes
df <- data.frame(ChlorAVeerse$Dates,ChlorAVeerse$Values,ChlorAVeerse$Locations, ChlorAVeerse$bemhgt)
subset <- subset(df, ChlorAVeerse.Locations == "Soelekerkepolder oost" & ChlorAVeerse.bemhgt =="-100")

#events
name <- "Re-introduction of tides"
date <- as.Date("2004-07-23")
events <- data.frame(name,date)
baseline <- min(subset$ChlorAVeerse.Values)
delta <- 0.5 * diff(range(subset$ChlorAVeerse.Values))
events$ymin <- baseline
events$timelapse <- c(diff(events$date),Inf)
events$bump <- events$timelapse < 4*370 # ~4 years
offsets <- rle(events$bump)
events$offset <- unlist(mapply(function(l,v) {if(v){(l:1)+1}else{rep(1,l)}}, l=offsets$lengths, v=offsets$values, USE.NAMES=FALSE))
events$ymax <- events$ymin + events$offset * delta

#save plot in pdf
pdf("Timeserieschloraveerse.pdf", width=12, height=5.5)
print(ggplot(subset, aes(x=ChlorAVeerse.Dates, y=ChlorAVeerse.Values))+ 
        geom_line()+
        #scale_y_log10()+
        geom_segment(data = events, mapping=aes(x=date, y=ymin, xend=date, yend=ymax), colour = 'red') +
        geom_point(data = events, mapping=aes(x=date,y=ymax), size=3, colour = 'red') +
        geom_text(data = events, mapping=aes(x=date, y=ymax, label=name), hjust=-0.1, vjust=0.1, size=4, colour = 'red') +
        scale_x_date(labels = date_format("%Y"),breaks="5 years", minor_breaks = "1 year")+
        scale_y_continuous(breaks = seq(0,150,by=25), minor_breaks = seq(0,150,by=5))+
        ylab(expression(paste("Chlorophyll a Concentration (",mu,"g/L)")))+
        xlab("")+
        ggtitle("Lake Veere (Location Soelekerkepolder Oost)"))
dev.off()