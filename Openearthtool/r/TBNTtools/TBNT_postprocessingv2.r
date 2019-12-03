############################################################################
##                                                                        ##
##                                                                        ##
##            Tool to plot nutrient distribution from different           ##
##                      sources in the North Sea                          ##
##            in: TBNT results on OSPAR target areas                      ##
##                 willem.stolte@deltares.nl                              ##
##                                                                        ##
############################################################################


require(maps)
require(maptools)
require(mapplots)
require(sp)

##Set Directory
setwd("d:/GIS_data/Noordzee/OSPAR2010")
## Areas2011 (n=40)
#areas<-c("UKC6","UKO5","NO2","DO1","DC1","UKC5","UKC4","DO2","UKC3","UKO4"
#  ,"NLO3","GO3","DWD1","UKO3","GO2","NLO2","DWD2","UKC2","UKO2","GO1"
#  ,"GC1","UKC1","GWD1","UKO1","NLO1a","NLO1b","UKC7","BO1","FO1","UKC8"
#  ,"BC1","NLC1","NLC2a","NLC2b","NLC3","UKC9","FC2","FC1","GWD2","NLWD")
## Areas2010 (n=38)
areas<-c("UKC6","UKO5","NO2","DO1","DC1","UKC5","UKC4","DO2","UKC3","UKO4"
  ,"NLO3","GO3","DWD1","UKO3","GO2","NLO2","DWD2","UKC2","UKO2","GO1"
  ,"GC1","UKC1","GWD1","UKO1","NLO1","UKC7","BO1","FO1","UKC8"
  ,"BC1","NLC1","NLC2","NLC3","UKC9","FC2","FC1","GWD2","NLWD")
##Nutrient sources as defined in Delwaq TBNT model
sources<-c("BE","FR","GM","NL1","NL2","UK1","UK2","CH","NA","ATM")
sortedsources<-sort(sources)
nareas<-length(areas)
nsources<-length(sources)

TBNT.sp <- readShapePoly("WGS/TargetAreas.shp",proj4string=CRS("+proj=longlat +datum=WGS84"))
TBNT.dat <- readShapePoints("WGS/AlgN_KH_01.shp")
#    proj4string <- CRS("+init=epsg:28992")

plot(TBNT.sp)

#rownames(TBNT.dat) <- TBNT.dat$area
#TBNT.dat[TBNT.dat$area != "Noordzee", ]
dim(TBNT.dat)
head(TBNT.dat)
points(TBNT.dat,col="red")
head(TBNT.dat)

TBNT.dat2<- NULL
TBNT.dat2<-data.frame(  TBNT.dat[2:11])

##TBNT.dat2 <- rbind(TBNT.dat2,data.frame(coordinates(TBNT.dat)))
head(TBNT.dat2)
TBNT.dat2<-subset(TBNT.dat2,select=c(coords.x1,coords.x2,be,fr,gm,nl1,nl2,uk1,uk2,ch,na,atm))
colnames(TBNT.dat2)<-c("lon","lat","BE","FR","GM","NL1","NL2","UK1","UK2","CH","NA","ATM")

## Make list with groups
TBNT.list <- reshape(TBNT.dat2, varying=list(3:12), direction='long',
ids=row.names(TBNT.dat2),
          times=sources
          )          
## add coordinates to list
##TBNT.list <- merge(TBNT.list,TBNT.coor,by.x=c("Area"), by.y=c("UID"),all.x=TRUE,)

################################################################################
##  Draw 2-dimensional barplots with uniform size in an existing plot         ##
################################################################################

xlim <- range(TBNT.dat2$lon)
ylim <- range(TBNT.dat2$lat)
xyz <- make.xyz(TBNT.list$lon,TBNT.list$lat,TBNT.list$BE,TBNT.list$time)
col <- rainbow(10)
basemap(xlim, ylim, main = "AlgN")
# werkt niet....:  draw.shape(TBNT.sp, col="black")    in plaats daarvan:
plot(TBNT.sp)
draw.barplot2D(xyz$x, xyz$y, xyz$z, width = 0.4, height = 0.4, col=col)
legend("topright", colnames(xyz$z), fill=col, bg="lightblue", inset=0.02)

################################################################################
##            Draw 2-dimensional scaled barplots in an existing plot          ##
################################################################################
   xxlim <- range(TBNT.dat2$lon)
   yylim <- range(TBNT.dat2$lat)
   xyz <- make.xyz(TBNT.list$lon,TBNT.list$lat,TBNT.list$BE,TBNT.list$time)
## file type and dimensions for saving (uncomment next two lines, and the line with "dev.off())
#   png(file="test.png",bg="transparent"
#         ,units = "px", pointsize = 12,res=300)
   col <- rainbow(10)
   basemap(xxlim,yylim,main="Title")
   map('world',fill=T,col="grey",resolution=T,xlim=xxlim,ylim=yylim,border="black",add=T)
   plot(TBNT.sp,add=T)
   draw.barplot2D(xyz$x, xyz$y, xyz$z, width = 1, height = 1, scale=TRUE, col=col)
   legend("bottomright", colnames(xyz$z), fill=col, bg="lightblue", inset=0.02)
#dev.off()
#### Schaal lijkt nog niet helemaal goed...
   TBNT.GE <- GE_SpatialGrid(TBNT.sp)
   kmlOverlay(TBNT.GE,kmlfile="test.kml", imagefile="test.png", name="TBNT_AlgN_01")

################################################################################
##            Draw 2-dimensional scaled barplots as KML                       ##
################################################################################
xxlim <- range(TBNT.dat2$lon)
yylim <- range(TBNT.dat2$lat)
xyz <- make.xyz(TBNT.list$lon,TBNT.list$lat,TBNT.list$BE,TBNT.list$time)
## file type and dimensions for saving (uncomment next two lines, and the line with "dev.off())
   png(file="test.png",bg="transparent"
         ,units = "px", pointsize = 12,res=20)
col <- rainbow(10)
basemap(xxlim,yylim,bg="transparent",axes=F,frame.plot=F,xlab=F,ylab=F)
plot(TBNT.sp, add=T)
draw.barplot2D(xyz$x, xyz$y, xyz$z, width = 1, height = 1, scale=TRUE, col=col)
legend("left", colnames(xyz$z), fill=col, bg="lightblue",inset=0.02,cex=5)
dev.off()
#### De resolutie kan nog beter... En de legenda moet groter.. hoe?
TBNT.GE <- GE_SpatialGrid(TBNT.sp)
kmlOverlay(TBNT.GE,kmlfile="test.kml", imagefile="test.png", name="TBNT_AlgN_01")

################################################################################
##                Draw scaled pieplots in existing plot                       ##
################################################################################

xxlim <- range(TBNT.dat2$lon)
yylim <- range(TBNT.dat2$lat)
xyz <- make.xyz(TBNT.list$lon,TBNT.list$lat,TBNT.list$BE,TBNT.list$time)
## file type and dimensions for saving (uncomment next two lines, and the line with "dev.off())
#png(file="testpie.png",width = 1440, height = 1440, bg="transparent"
#    ,units = "px", pointsize = 12,res=NA)
col <- rainbow(10)
basemap(xxlim,yylim,bg="transparent",axes=F,frame.plot=F)
map('world',fill=T,col="grey",resolution=T,xlim=xxlim,ylim=yylim,border="black",add=T)
plot(TBNT.sp, add=T)
draw.pie(xyz$x, xyz$y, xyz$z, radius = 0.3, col=col)
legend.pie(-2,52,labels=sortedsources, radius=0.5, bty="n", col=col,
           cex=0.7, label.dist=1.3)
legend.z <- round(max(rowSums(xyz$z,na.rm=TRUE)),0)
legend.bubble(3,50,z=legend.z,round=1,maxradius=1,bty="n",txt.cex=1)
text(1,49,"AlgN (mg/m3)",cex=1)

################################################################################
##                    Draw scaled pieplots as KML                             ##
################################################################################
xxlim <- range(TBNT.dat2$lon)
yylim <- range(TBNT.dat2$lat)
xyz <- make.xyz(TBNT.list$lon,TBNT.list$lat,TBNT.list$BE,TBNT.list$time)
## file type and dimensions for saving (uncomment next two lines, and the line with "dev.off())
png(file="testpie.png",width = 1440, height = 1440, bg="transparent"
    ,units = "px", pointsize = 12,res=NA)
col <- rainbow(10)
basemap(xxlim,yylim,bg="transparent",axes=F,frame.plot=F,xlab=F,ylab=F)
plot(TBNT.sp, add=T)

#draw.barplot2D(xyz$x, xyz$y, xyz$z, width = 1, height = 1, scale=TRUE, col=col)
#legend("left", colnames(xyz$z), fill=col, bg="lightblue",inset=0.02,cex=5)
draw.pie(xyz$x, xyz$y, xyz$z, radius = 0.5, col=col)
legend.pie(-1,49,labels=sources, radius=0.5, bty="n", col=col,
           cex=1, label.dist=1.3)
legend.z <- round(max(rowSums(xyz$z,na.rm=TRUE)*1000),0)
legend.bubble(0,49,z=legend.z,round=1,maxradius=0.5,bty="n",txt.cex=1)
text(1,49,"AlgN (mg/m3)",cex=1)
dev.off()
TBNT.GE <- GE_SpatialGrid(TBNT.sp)
kmlOverlay(TBNT.GE,kmlfile="testpie.kml", imagefile="testpie.png", name="TBNT_AlgN_01")


###############################  Scrap block  #######################################

### examples from package "mapplot"

plot(NA,NA, xlim=c(-1,1), ylim=c(-1,1) )
barplot2D(z=rpois(6,10), x=-0.5, y=0.5, width=0.75, height=0.75, colour=rainbow(6))
barplot2D(z=rpois(4,10), x=0.5, y=-0.5, width=0.5, height=0.5, colour=rainbow(4))

## Draw 2-dimensional barplots in an existing plot
data(landings)
data(coast)
xlim <- c(-15,0)
ylim <- c(50,56)
xyz <- make.xyz(landings$Lon,landings$Lat,landings$LiveWeight,landings$Species)
col <- rainbow(5)
basemap(xlim, ylim, main = "Species composition of gadoid landings")
draw.shape(coast, col="cornsilk")
draw.barplot2D(xyz$x, xyz$y, xyz$z, width = 0.8, height = 0.4, col=col)
legend("topright", colnames(xyz$z), fill=col, bg="lightblue", inset=0.02)

## Draw 2-dimensional scaled barplots in an existing plot
basemap(xlim, ylim, main = "Species composition of gadoid landings")
draw.shape(coast, col="cornsilk")
draw.barplot2D(xyz$x, xyz$y, xyz$z, width = 1, height = 0.5, scale=TRUE, col=col)
#legend("topright", colnames(xyz$z), fill=col, bg="lightblue", inset=0.02)

## Draw bubble plots in an existing plot
data(landings)
data(coast)
xlim <- c(-12,-5)
ylim <- c(50,56)
agg <- aggregate(list(z=landings$LiveWeight),list(x=landings$Lon,y=landings$Lat),sum)
basemap(xlim, ylim, main = "Gadoid landings")
draw.shape(coast, col="cornsilk")
draw.bubble(agg$x, agg$y, agg$z, maxradius=0.5, pch=21, bg="#00FF0050")
legend.z <- round(max(agg$z)/1000,0)
legend.bubble("topright", z=legend.z, maxradius=0.5, inset=0.02, bg="lightblue", txt.cex=0.8,
pch=21, pt.bg="#00FF0050")

## Display a grd object as a heatmap
data(coast)
data(landings)
byx = 1
byy = 0.5
xlim <- c(-15.5,0)
ylim <- c(50.25,56)
grd <- make.grid(landings$Lon,landings$Lat,landings$LiveWeight, byx, byy, xlim, ylim)
breaks <- breaks.grid(grd,zero=FALSE)
basemap(xlim, ylim, main = "Gadoid landings")
draw.grid(grd,breaks)
draw.shape(coast, col="darkgreen")
legend.grid("topright", breaks=breaks/1000, type=2, inset=0.02, title="tonnes")


## Draw pie plots in an existing plot
data(landings)
data(coast)
xlim <- c(-12,-5)
ylim <- c(50,56)
xyz <- make.xyz(landings$Lon,landings$Lat,landings$LiveWeight,landings$Species)
col <- rainbow(5)
basemap(xlim, ylim, main = "Species composition of gadoid landings")
draw.shape(coast, col="cornsilk")
draw.pie(xyz$x, xyz$y, xyz$z, radius = 0.3, col=col)
legend.pie(-13.25,54.8,labels=c("cod","had","hke","pok","whg"), radius=0.3, bty="n", col=col,
cex=0.8, label.dist=1.3)
legend.z <- round(max(rowSums(xyz$z,na.rm=TRUE))/10^6,0)
legend.bubble(-13.25,55.5,z=legend.z,round=1,maxradius=0.3,bty="n",txt.cex=0.6)
text(-13.25,56,"landings (kt)",cex=0.8)

## Draw ICES rectangles in an existing plot
xlim <- c(-15,0)
ylim <- c(50,56)
basemap(xlim, ylim)
draw.rect()

## Draw shapefiles in an existing plot
library(shapefiles)
shp.file <- file.path(system.file(package = "mapplots", "extdata"), "Ireland")
irl <- read.shapefile(shp.file)
xlim <- c(-11,-5.5)
ylim <- c(51.5,55.5)
basemap(xlim, ylim)
draw.shape(irl, col="cornsilk")

##Draw xy sub-plots in an existing plot
data(effort)
data(coast)
xlim <- c(-12,-5)
ylim <- c(51,54)
col <- terrain.colors(12)
effort$col <- col[match(effort$Month,1:12)]
basemap(xlim, ylim, main = "Monthly trends in haddock landings and fishing effort")
draw.rect(lty=1, col=1)
draw.shape(coast, col="cornsilk")
draw.xy(effort$Lon, effort$Lat, effort$Month, effort$LiveWeight, width=1, height=0.5,
col=effort$col, type="h",lwd=3, border=NA)
draw.xy(effort$Lon, effort$Lat, effort$Month, effort$Effort, width=1, height=0.5, col="red",
type="l", border=NA)
draw.xy(effort$Lon, effort$Lat, effort$Month, effort$Effort, width=1, height=0.5, col="red",
type="p",cex=0.4,pch=16, border=NA)
legend("topleft", c(month.abb,"Effort"), pch=c(rep(22,12),16), pt.bg=c(col,NA),
pt.cex=c(rep(2,12),0.8),col=c(rep(1,12),2), lty=c(rep(NA,12),1), bg="lightblue",
inset=0.02, title="Landings", cex=0.8)

## Export a grd object as geotiff
library(rgdal)
data(landings)
data(coast)
byx = 1
byy = 0.5
xlim <- c(-15.5,0)
ylim <- c(50.25,56)
grd <- make.grid(landings$Lon, landings$Lat, landings$LiveWeight, byx, byy, xlim, ylim)
breaks <- breaks.grid(grd,zero=FALSE)
basemap(xlim, ylim, main = ’Gadoid landings’)
draw.grid(grd,breaks)
draw.shape(coast, col=’darkgreen’)
legend.grid(’topright’, breaks=breaks/1000, type=2, round=1)
## Not run:
geoTiff(grd,’c:/test1.tiff’)
geoTiffRgb(grd,breaks,file=’c:/test2.tiff’)
## End(Not run)



##Open data Knowseas
Mondrian\PO4_02wint.txt
## define CRS/projection
  grid.01 <- grid
  coordinates(grid.01) <- ~lon+lat
  proj4string(grid.01) <-CRS("+proj=longlat +datum=WGS84")
#
##Make world map of North Sea section
 map('world',fill=T,col="grey",resolution=T,xlim=range(lo),ylim=range(la),border="black",add=T)
        title(monthlist[j],sub=NULL,cex.main = 1,font.main= 4,col.main= "blue",cex.sub = 0.75, font.sub = 3, col.sub = "red")
        }
