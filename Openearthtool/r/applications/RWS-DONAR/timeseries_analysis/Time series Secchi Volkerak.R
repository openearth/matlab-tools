#Read in raw data
secchivolkerak<-file.path("D:/My Documents/Data from Donar/SecchiVolkerak.xlsx")
SecchiVolkerak<-readWorksheetFromFile(secchivolkerak,sheet=1)

#Convert data into correct format
SecchiVolkerak$Dates <- as.Date(as.character(SecchiVolkerak$datum), format = "%Y%m%d")
SecchiVolkerak$Values <- as.numeric(SecchiVolkerak$wrd)
SecchiVolkerak$Locations <- SecchiVolkerak$locoms

#Make subsets of dataframes
df <- data.frame(SecchiVolkerak$Dates,SecchiVolkerak$Values,SecchiVolkerak$Locations, SecchiVolkerak$bemhgt)
subset <- subset(df, SecchiVolkerak.Locations == "Steenbergen (Roosendaalsevliet)" & SecchiVolkerak.bemhgt =="-100")
subset1 <- subset(subset, as.Date(SecchiVolkerak.Dates) >= "1970-01-01" & as.Date(SecchiVolkerak.Dates)<="1986-01-01")
subset2<- subset(subset, as.Date(SecchiVolkerak.Dates) >= "1986-01-01" & as.Date(SecchiVolkerak.Dates)<="2014-01-01")

#events
name <- "Closure of Lake Volkerak-Zoom"
date <- as.Date("1987-01-01")
events <- data.frame(name,date)
baseline <- 0
delta <- 0.02 * diff(range(subset$SecchiVolkerak.Values))
events$ymin <- baseline
events$timelapse <- c(diff(events$date),Inf)
events$bump <- events$timelapse < 4*370 # ~4 years
offsets <- rle(events$bump)
events$offset <- unlist(mapply(function(l,v) {if(v){(l:1)+1}else{rep(1,l)}}, l=offsets$lengths, v=offsets$values, USE.NAMES=FALSE))
events$ymax <- events$ymin + events$offset * delta

#save plot in pdf
pdf("Timeseriessecchivolkerak.pdf", width=12, height=5.5)
print(ggplot()+ 
        geom_line(data=subset1, aes(x=SecchiVolkerak.Dates, y=SecchiVolkerak.Values))+
        geom_line(data=subset2, aes(x=SecchiVolkerak.Dates, y=SecchiVolkerak.Values))+
        #scale_y_log10()+
        geom_segment(data = events, mapping=aes(x=date, y=ymin, xend=date, yend=ymax), colour = 'red') +
        geom_point(data = events, mapping=aes(x=date,y=ymax), size=3, colour = 'red') +
        geom_text(data = events, mapping=aes(x=date, y=ymax, label=name), hjust=-0.1, vjust=0.1, size=4, colour = 'red') +
        scale_x_date(labels = date_format("%Y"),breaks="5 years", minor_breaks = "1 year")+
        scale_y_reverse(limits = c(50,0.5))+
        #scale_y_continuous(breaks = seq(0,50,by=10), minor_breaks = seq(0,50,by=2))+
        ylab("Secchi depth (dm)")+
        xlab("")+
        ggtitle("Lake Volkerak-Zoom (Location Steenbergen)"))
dev.off()