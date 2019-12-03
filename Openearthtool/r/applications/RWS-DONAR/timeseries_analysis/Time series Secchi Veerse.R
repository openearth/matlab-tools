#Read in raw data
secchiveerse<-file.path("D:/My Documents/Data from Donar/SecchiVeerse.xlsx")
SecchiVeerse<-readWorksheetFromFile(secchiveerse,sheet=1)

#Convert data into correct format
SecchiVeerse$Dates <- as.Date(as.character(SecchiVeerse$datum), format = "%Y%m%d")
SecchiVeerse$Values <- as.numeric(SecchiVeerse$wrd)
SecchiVeerse$Locations <- SecchiVeerse$locoms

#Make subsets of dataframes
df <- data.frame(SecchiVeerse$Dates,SecchiVeerse$Values,SecchiVeerse$Locations)
subset <- subset(df, SecchiVeerse.Locations == "Soelekerkepolder oost")
subset1 <- subset(subset, as.Date(SecchiVeerse.Dates) >= "1970-01-01" & as.Date(SecchiVeerse.Dates)<="2014-01-01")

#events
name <- "Re-introduction of tides"
date <- as.Date("2004-07-23")
events <- data.frame(name,date)
baseline <- 0
delta <- 0.02 * diff(range(subset$SecchiVeerse.Values))
events$ymin <- baseline
events$timelapse <- c(diff(events$date),Inf)
events$bump <- events$timelapse < 4*370 # ~4 years
offsets <- rle(events$bump)
events$offset <- unlist(mapply(function(l,v) {if(v){(l:1)+1}else{rep(1,l)}}, l=offsets$lengths, v=offsets$values, USE.NAMES=FALSE))
events$ymax <- events$ymin + events$offset * delta

#save plot in pdf
pdf("Timeseriessecchiveerse.pdf", width=12, height=5.5)
print(ggplot()+ 
        geom_line(data=subset1, aes(x=SecchiVeerse.Dates, y=SecchiVeerse.Values))+
        #scale_y_log10()+
        geom_segment(data = events, mapping=aes(x=date, y=0, xend=date, yend=50), colour = 'red') +
        geom_point(data = events, mapping=aes(x=date,y=ymax), size=3, colour = 'red') +
        geom_text(data = events, mapping=aes(x=date, y=ymax, label=name), hjust=-0.1, vjust=0.1, size=4, colour = 'red') +
        scale_x_date(labels = date_format("%Y"),breaks="5 years", minor_breaks = "1 year")+
        scale_y_reverse(limits = c(100,0.5))+
        #scale_y_continuous(breaks = seq(0,150,by=25), minor_breaks = seq(0,150,by=5))+
        ylab("Secchi depth (dm)")+
        xlab("")+
        ggtitle("Lake Veere (Location Soelekerkepolder oost)"))
dev.off()