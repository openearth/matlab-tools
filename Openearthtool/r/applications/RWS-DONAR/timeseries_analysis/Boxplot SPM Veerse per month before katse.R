#Read in raw data
spmveerse<-file.path("D:/My Documents/Data from Donar/SPMVeerse.xlsx")
SPMVeerse<-readWorksheetFromFile(spmveerse,sheet=1)

#Convert data into correct format
SPMVeerse$Value <- as.numeric(SPMVeerse$wrd)
SPMVeerse$Date <- as.Date(as.character(SPMVeerse$datum), format = "%Y%m%d")
SPMVeerse$Month <- as.POSIXlt(SPMVeerse$Date)$mon+1
SPMVeerse$Location <- SPMVeerse$locoms

#Make subsets of dataframes
SPMSoele <- subset(SPMVeerse, SPMVeerse$Location == "Soelekerkepolder oost")
subset <- subset(SPMSoele, as.Date(Date) >= "1972-01-01" & as.Date(Date)<="2004-07-01")

#write subset to Excel
write.xlsx(x = subset, file = "spmsoelepermonthbeforekatse.xlsx", sheetName = "TestSheet", row.names = FALSE)


#save plot in pdf
pdf("SPMveersebeforekatsepermonth.pdf", width=10, height=8)
print(ggplot(subset)+
        ggtitle("Lake Veere (Location Soelekerkepolder Oost)")+
        geom_boxplot(aes(x=Month, y=Value, group=Month))+
        ylab("SPM concentration(mg/L)")+
        theme(axis.text=element_text(size=24),axis.title=element_text(size=26),plot.title=element_text(size=26,face="bold"))+
        scale_y_log10(limits = c(0.5, 100))+
        annotation_logticks(sides = "l")+
        scale_x_continuous(breaks = c(1,2,3,4,5,6,7,8,9,10,11,12)))
dev.off()