######################################################################################################
####                                                                                              ####
####             Script by willem.stolte@deltares.nl for reading helpdeskwater csv's              ####
####            Reads MWTL csv and converts to wide table for Delwaqinput                         ####
####            Script separates units, and methods for each parameter                            ####
####                     forexample  part-TP and  diss-TP                                         ####
####                                                                                              ####
######################################################################################################

wd<-setwd("d:/Netwerk/Internationaal/KRW Eems Dollard/ModelInData/RWS-MWTL/")
## reads 4 different csv's, and combines them into one (names hardcoded)
dat<-read.table("docetc.csv",sep=";",header=T)
dat<-rbind(dat,read.table("eufyt.csv",sep=";",header=T))
dat<-rbind(dat,read.table("tsalzs.csv",sep=";",header=T))
dat<-rbind(dat,read.table("zusto.csv",sep=";",header=T))
## When necessary, save all data in new file
#write.csv(dat,"all-data.csv")
## Make unique names for parameters-method-unit combinations
dat$parhdhehd<-paste(dat$parcod,dat$hdhcod,dat$ehdcod,sep="_")
## Define columns to keep
keeps<-c("loccod","datum","tijd","parhdhehd","wrd")
dat<-dat[keeps]
dat<-dat[order(dat$loccod,dat$datum),]
## Reshape table from long to wide
require(reshape)
#datwide<-reshape(datsh,direction="wide",v.names=c("wrd"),idvar=c("loccod","parcod"),timevar="datum")
datwide<-reshape(dat,direction="wide",v.names=c("wrd")
,idvar=c("loccod","datum"),timevar=c("parhdhehd"))
datwide[datwide>1e10]<--NA
#datwide[datwide==NA]<--999  # This does not work. :-(
colnames(datwide)<-c("loccod","date","time",
                     "DOC_mg/l","POC_mg/l","TOC_mg/l",
                     "PartP_mg/l","TP_mg/l","TN_mg/l",
                     "DissN_mg/l","DissP_mg/l","PartN_pg_mg/l",
                     "Transparancy_dm","CHLPHa_ug/l","s_NO3NO2_N_mg/l",
                     "NO2_N_mg/l","NH4_N_mg/l","PO4_P_mg/l",
                     "NO3_N_mg/l","SiO2_Si_mg/l","KjN_N_mg/l",
                     "T_oC","SALNTT_DIMSLS","SPM_mg/l",
                     "O2_mg/l","O2_perc")
write.csv(datwide,file=paste("all-data",".wide.csv",sep=""))

