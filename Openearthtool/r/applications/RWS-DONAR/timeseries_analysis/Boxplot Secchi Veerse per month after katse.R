#Read in raw data
secchiveerse<-file.path("D:/My Documents/Data from Donar/SecchiVeerse.xlsx")
SecchiVeerse<-readWorksheetFromFile(secchiveerse,sheet=1)

#Convert data into correct format
SecchiVeerse$Value <- as.numeric(SecchiVeerse$wrd)
SecchiVeerse$Date <- as.Date(as.character(SecchiVeerse$datum), format = "%Y%m%d")
SecchiVeerse$Month <- as.POSIXlt(SecchiVeerse$Date)$mon+1
SecchiVeerse$Location <- SecchiVeerse$locoms

#Make subsets of dataframes
SecchiSoele <- subset(SecchiVeerse, SecchiVeerse$Location == "Soelekerkepolder oost")
subset <- subset(SecchiSoele, as.Date(Date) >= "2004-07-01" & as.Date(Date)<="2014-01-01")

#write subset to Excel
write.xlsx(x = subset, file = "secchisoelepermonthafterkatse.xlsx", sheetName = "TestSheet", row.names = FALSE)

#make reverse log scale
reverselog_trans <- function(base = exp(1)) {
  trans <- function(x) -log(x, base)
  inv <- function(x) base^(-x)
  trans_new(paste0("reverselog-", format(base)), trans, inv, 
            log_breaks(base = base), 
            domain = c(1e-100, Inf))
}

#save plot in pdf
pdf("Secchiveerseafterkatsepermonth.pdf", width=10, height=8)
print(ggplot(subset)+
        ggtitle("Lake Veere (Location Soelekerkepolder Oost)")+
        geom_boxplot(aes(x=Month, y=Value, group=Month))+
        ylab("Secchi depth (dm)")+
        theme(axis.text=element_text(size=24),axis.title=element_text(size=26),plot.title=element_text(size=26,face="bold"))+
        #scale_y_log10(limits = c(0.5,100),breaks = c(0.5,1,2,5,10,20,50,100))+
        #scale_y_reverse(limits = c(100,0.5))+
        scale_y_continuous(trans=reverselog_trans(base=10), breaks = c(1,2,3,4,5,6,7,8,9,10,20,30,40,50,60,70,80,90,100))+  
        #annotation_logticks(sides = "l")+
        scale_x_continuous(breaks = c(1,2,3,4,5,6,7,8,9,10,11,12))+
        theme(axis.text = element_text(size =16)))
dev.off()