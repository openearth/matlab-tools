#Read in raw data
chlorAveerse<-file.path("D:/My Documents/Data from Donar/ChlorAVeerse.xlsx")
ChlorAVeerse<-readWorksheetFromFile(chlorAveerse,sheet=1)

#Convert data into correct format
ChlorAVeerse$Value <- as.numeric(ChlorAVeerse$wrd)
ChlorAVeerse$Date <- as.Date(as.character(ChlorAVeerse$datum), format = "%Y%m%d")
ChlorAVeerse$Month <- as.POSIXlt(ChlorAVeerse$Date)$mon+1
ChlorAVeerse$Location <- ChlorAVeerse$locoms

#Make subsets of dataframes
ChlorASoele <- subset(ChlorAVeerse, ChlorAVeerse$Location == "Soelekerkepolder oost")
subset <- subset(ChlorASoele, as.Date(Date) >= "2004-07-01" & as.Date(Date)<="2014-05-01")

#write subset to Excel
write.xlsx(x = subset, file = "chlorasoelepermonthafterkatse.xlsx", sheetName = "TestSheet", row.names = FALSE)


#save plot in pdf
pdf("Chloraveerseafterkatsepermonth.pdf", width=10, height=8)
print(ggplot(subset)+
        ggtitle("Lake Veere (Location Soelekerkepolder Oost)")+
        geom_boxplot(aes(x=Month, y=Value, group=Month))+
        ylab(expression(paste("Chlorophyll a concentration (",mu,"g/L)")))+
        theme(axis.text=element_text(size=24),axis.title=element_text(size=26),plot.title=element_text(size=26,face="bold"))+
        scale_y_log10(limits = c(0.5,300))+
        annotation_logticks(sides = "l")+
        scale_x_continuous(breaks = c(1,2,3,4,5,6,7,8,9,10,11,12)))
dev.off()