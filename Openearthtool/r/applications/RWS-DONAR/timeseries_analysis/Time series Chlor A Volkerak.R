#Read in raw data
chlorAvolkerak<-file.path("D:/My Documents/Data from Donar/ChlorAVolkerak.xlsx")
ChlorAVolkerak<-readWorksheetFromFile(chlorAvolkerak,sheet=1)

#Convert data into correct format
ChlorAVolkerak$Dates <- as.Date(as.character(ChlorAVolkerak$datum), format = "%Y%m%d")
ChlorAVolkerak$Values <- as.numeric(ChlorAVolkerak$wrd)
ChlorAVolkerak$Locations <- ChlorAVolkerak$locoms

#Make subsets of dataframes
df <- data.frame(ChlorAVolkerak$Dates,ChlorAVolkerak$Values,ChlorAVolkerak$Locations, ChlorAVolkerak$bemhgt)
subset <- subset(df, ChlorAVolkerak.Locations == "Steenbergen (Roosendaalsevliet)" & ChlorAVolkerak.bemhgt =="-100")
before <- subset(subset, as.Date(ChlorAVolkerak.Dates) >= "1978-01-01" & as.Date(ChlorAVolkerak.Dates)<="1986-01-01")
after<- subset(subset, as.Date(ChlorAVolkerak.Dates) >= "1986-01-01" & as.Date(ChlorAVolkerak.Dates)<="2014-01-01")

#events
name <- "Closure of Lake Volkerak-Zoom"
date <- as.Date("1987-01-01")
events <- data.frame(name,date)
baseline <- min(subset$ChlorAVolkerak.Values)
delta <- 0.5 * diff(range(subset$ChlorAVolkerak.Values))
events$ymin <- baseline
events$timelapse <- c(diff(events$date),Inf)
events$bump <- events$timelapse < 4*370 # ~4 years
offsets <- rle(events$bump)
events$offset <- unlist(mapply(function(l,v) {if(v){(l:1)+1}else{rep(1,l)}}, l=offsets$lengths, v=offsets$values, USE.NAMES=FALSE))
events$ymax <- events$ymin + events$offset * delta

#save plot in pdf
pdf("Timeserieschloravolkerak.pdf", width=12, height=5.5)
print(ggplot()+ 
        geom_line(data = before, aes(x=ChlorAVolkerak.Dates, y=ChlorAVolkerak.Values))+
        geom_line(data = after, aes(x=ChlorAVolkerak.Dates, y=ChlorAVolkerak.Values))+
        #scale_y_log10()+
        geom_segment(data = events, mapping=aes(x=date, y=ymin, xend=date, yend=ymax), colour = 'red') +
        geom_point(data = events, mapping=aes(x=date,y=ymax), size=3, colour = 'red') +
        geom_text(data = events, mapping=aes(x=date, y=ymax, label=name), hjust=-0.1, vjust=0.1, size=4, colour = 'red') +
        scale_x_date(labels = date_format("%Y"),breaks="5 years", minor_breaks = "1 year")+
        scale_y_continuous(breaks = seq(0,400,by=50), minor_breaks = seq(0,400,by=10))+
        ylab(expression(paste("Chlorophyll a Concentration (",mu,"g/L)")))+
        xlab("")+
        ggtitle("Lake Volkerak-Zoom (Location Steenbergen)"))
dev.off()