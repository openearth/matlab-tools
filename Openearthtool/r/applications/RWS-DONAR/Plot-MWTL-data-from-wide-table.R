
######################################################################################################
####                                                                                              ####
####             Script by willem.stolte@deltares.nl for plotting MWTL data                       ####
####            Script changes date text to data format and plots all parameters                  ####
####                   not generic, manually adjust number of parameters to plot                  ####
####                                                                                              ####
######################################################################################################

# Read data ---------------------------------------------------------------
require(ggplot2)
require(scales)
setwd("p:/1205711-edspa/Data/RWS-MWTL/")
filename<-"all-data"
datwide<-read.csv(paste(filename,".wide.csv",sep=""))
datwide$date<-as.character(datwide$date)
datwide$date<-as.Date(datwide$date,"%Y%m%d")
datwide[datwide==-999] <- NA
datwide[datwide>1e+10] <- NA

# Plot data one by one --------------------------------------------------
p <- ggplot(datwide,aes(date,O2_mg.l))
p + geom_point(aes(color=loccod),size=3) + geom_line(aes(color=loccod)) +
  scale_x_date(labels = date_format("%b%y"),breaks=date_breaks("months"))

# Plot and save all data ------------------------------------------------
#  plotdir<-"p:/1205711-edspa/Data/RWS-MWTL/plots"
plotdir<-"d:/Netwerk/Internationaal/KRW Eems Dollard/ModelInData/RWS-MWTL/plots/"

for(ii in 5:27) {
  ii=7
              p <- ggplot(datwide,aes(date,datwide[,ii]))
             # p <- ggplot(data=datwide[!is.na(datwide[ii]),],aes(date,datwide[,ii]))
              p+
                geom_point(aes(color=loccod),size=3)+
                geom_line(aes(color=loccod))+  # does not connect between missing points
        #    geom_line(data=datwide[!is.na(datwide[,ii]),],aes(color=loccod))+  ## connects all points
                labs(y=colnames(datwide[ii]))+ labs(color = "Locations")+
                scale_x_date(labels = date_format("%b%y"),breaks=date_breaks("months"))
                    
              ggsave(file=paste(plotdir,colnames(datwide[ii]),".png",sep=""),
                     width=10,height=4,dpi=300)
     }

#####################################################################################################
