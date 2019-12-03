## ================================================================##
##                                                                 ##
##  Example script for target diagram                              ##
##  By Willem.Stolte@Deltares.nl                                   ##
##                                                                 ##
##=================================================================##

workdir <- "d:/REPOS-CHECK-OUTS/OpenEarthTools/r/applications/Delft3D/waq/"
setwd(workdir)
source("target-function2.r")

## Load some test data to test the function:
df.stat <- read.table("stattable.csv",sep=",")
df.target <- make.target.table2(~ substance + location + season, df.stat, val_obs = "value.x", val_mod = "value.y")

## Make a unity circle with diameter 2 and center at 0,0
circleFun <- function(center = c(0,0),diameter = 1, npoints = 100){
  r = diameter / 2
  tt <- seq(0,2*pi,length.out = npoints)
  xx <- center[1] + r * cos(tt)
  yy <- center[2] + r * sin(tt)
  return(data.frame(x = xx, y = yy))
}
df.circle <- cbind(circleFun(c(0,0),2,npoints = 100), circleFun(c(0,0),2*0.67,npoints = 100)); colnames(df.circle) = c("x1","y1","x2","y2")

## Plot targetdiagram voor all groups
library(ggplot2)

zz <- ifelse(max(df.target$uRMSD)>max(df.target$nBIAS),df.target$uRMSD,df.target$nBIAS) # maximum scale
p <- ggplot(df.target,aes(uRMSD,nBIAS))
p + 
  geom_point(aes(color=location),size=4) + 
  geom_path(data=df.circle,aes(x,y)) +
  geom_path(data=df.circle,aes(x,y), type = 2) +
  xlim(c(-zz,zz)) + ylim(c(-zz,zz)) + 
#  xlim(c(-6,6)) + ylim(c(-6,6)) +   # manual scale setting replacing maximum scale
  facet_grid(substance~season)

## plot only selected parameters
ecol=c("Chlfa","SecchiDept","OXY","Salinity","SS")
ecolsel<-df.target$substance %in% ecol
df.target3<-df.target[ecolsel,]

scale=c(-3,3)
q <- ggplot(df.target3,aes(uRMSD,nBIAS))
q + geom_point(aes(color=location),size=4) + geom_path(data=df.circle,aes(x,y)) +
  xlim(scale) + ylim(scale) + 
  facet_grid(season ~ substance,scales="free") +
#  theme_classic(base_size = 14, base_family = "") +
  theme(aspect.ratio = 1) +
  theme(panel.grid.major = element_line(colour = "darkgrey")) +
  theme(legend.position = "bottom")

## to save last graph:
# plotdir=file.path(moddir,"TargetDiagrams")
# ggsave(file=paste(plotdir,"/target_all",".png",sep=""),
#        width=15,height=5,dpi=300)  
