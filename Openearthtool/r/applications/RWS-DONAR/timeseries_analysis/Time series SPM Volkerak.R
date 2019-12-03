#Read in raw data
spmvolkerak<-file.path("D:/My Documents/Data from Donar/SPMVolkerak.xlsx")
SPMVolkerak<-readWorksheetFromFile(spmvolkerak,sheet=1)

#Convert data into correct format
SPMVolkerak$Dates <- as.Date(as.character(SPMVolkerak$datum), format = "%Y%m%d")
SPMVolkerak$Values <- as.numeric(SPMVolkerak$wrd)
SPMVolkerak$Locations <- SPMVolkerak$locoms

#Make subsets of dataframes
df <- data.frame(SPMVolkerak$Dates,SPMVolkerak$Values,SPMVolkerak$Locations, SPMVolkerak$bemhgt)
subset <- subset(df, SPMVolkerak.Locations == "Steenbergen (Roosendaalsevliet)" & SPMVolkerak.bemhgt =="-100")
subset1 <- subset(subset, as.Date(SPMVolkerak.Dates) >= "1970-01-01" & as.Date(SPMVolkerak.Dates)<="1980-01-01")
subset2<- subset(subset, as.Date(SPMVolkerak.Dates) >= "1980-01-01" & as.Date(SPMVolkerak.Dates)<="1986-01-01")
subset3<- subset(subset, as.Date(SPMVolkerak.Dates) >= "1986-01-01" & as.Date(SPMVolkerak.Dates)<="2014-01-01")

#events
name <- "Closure of Lake Volkerak-Zoom"
date <- as.Date("1987-01-01")
events <- data.frame(name,date)
baseline <- min(subset$SPMVolkerak.Values)
delta <- 0.5 * diff(range(subset$SPMVolkerak.Values))
events$ymin <- baseline
events$timelapse <- c(diff(events$date),Inf)
events$bump <- events$timelapse < 4*370 # ~4 years
offsets <- rle(events$bump)
events$offset <- unlist(mapply(function(l,v) {if(v){(l:1)+1}else{rep(1,l)}}, l=offsets$lengths, v=offsets$values, USE.NAMES=FALSE))
events$ymax <- events$ymin + events$offset * delta

#save plot in pdf
pdf("Timeseriesspmvolkerak.pdf", width=12, height=5.5)
print(ggplot()+ 
        geom_line(data=subset1, aes(x=SPMVolkerak.Dates, y=SPMVolkerak.Values))+
        geom_line(data=subset2, aes(x=SPMVolkerak.Dates, y=SPMVolkerak.Values))+
        geom_line(data=subset3, aes(x=SPMVolkerak.Dates, y=SPMVolkerak.Values))+
                #scale_y_log10()+
        geom_segment(data = events, mapping=aes(x=date, y=ymin, xend=date, yend=ymax), colour = 'red') +
        geom_point(data = events, mapping=aes(x=date,y=ymax), size=3, colour = 'red') +
        geom_text(data = events, mapping=aes(x=date, y=ymax, label=name), hjust=-0.1, vjust=0.1, size=4, colour = 'red') +
        scale_x_date(labels = date_format("%Y"),breaks="5 years", minor_breaks = "1 year")+
        scale_y_continuous(breaks = seq(0,80,by=10), minor_breaks = seq(0,80,by=5))+
        ylab("SPM concentration (mg/L)")+
        xlab("")+
        ggtitle("Lake Volkerak-Zoom (Location Steenbergen)"))
dev.off()