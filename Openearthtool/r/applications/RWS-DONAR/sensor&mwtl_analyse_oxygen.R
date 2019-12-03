rm(list = objects())

library("ncdf")
library("rgeos")
library("spatstat")
library("rgdal")
library("chron")

###Create buffers#################
## Numerous records (points) at once (buffer of 25m radius) 
CreateBuffersLATLONWGS <- function(coordinates_df, radius_m, value_df){
  
  library("spatstat")
  library("rgdal")
  library("rgeos")
  
  attach(coordinates_df)
  coordinates(coordinates_df) <- ~x+y
  detach(coordinates_df)
  proj4string(coordinates_df) <- CRS("+proj=longlat +datum=WGS84")
  coordinates_RD<-spTransform(coordinates_df,CRS = CRS("+init=epsg:28992"))
  coordinates_df <- as.data.frame(coordinates_RD)
  rownames(coordinates_df)<- c(1:nrow(coordinates_df))
  
  polys<-list() 
  
  for(i in 1:nrow(coordinates_df)) { 
    discbuff<-disc(radius=radius_m, centre=c(coordinates_df$x[i], coordinates_df$y[i])) 
    discpoly<-Polygon(rbind(cbind(discbuff$bdry[[1]]$x, 
                                  y=discbuff$bdry[[1]]$y), c(discbuff$bdry[[1]]$x[1], 
                                                             y=discbuff$bdry[[1]]$y[1]))) 
    polys<-c(polys, discpoly) 
  } 
  
  spolys<-list() 
  for(i in 1:length(polys)) { 
    spolybuff<-Polygons(list(polys[[i]]), ID=row.names(coordinates_df)[i]) 
    spolys<-c(spolys, spolybuff) 
  } 
  
  spolys
  polybuffs<-SpatialPolygonsDataFrame(SpatialPolygons(spolys, 1:nrow(coordinates_df)), data = value_df) 
  proj4string(polybuffs) <- CRS("+init=epsg:28992")
  polybuffs_original <- spTransform(polybuffs,CRS("+proj=longlat +datum=WGS84"))
  
  return(polybuffs_original)
}
##################################

###Select SpatialPointsOrPolygons
SelectSpatial <- function(spatial, selection){
  coord_spatial <- spatial@coords[selection,]
  data_spatial <- spatial@data[selection,]
  proj_spatial <- proj4string(spatial)
  class(coord_spatial)
  class(data_spatial)
  
  coord_spatial_sp <- SpatialPoints(coord_spatial)
  data_spatial <- SpatialPointsDataFrame(coord_spatial_sp,data = data_spatial)
  proj4string(data_spatial) <- proj_spatial
  
  return(data_spatial)
}
########################################

### MatchMWTLandData
MatchMWTLAndDATA<- function(time_data,time_MWTL, range_s){
  range_low = time_MWTL - range_s
  range_upper = time_MWTL + range_s
  
  time_data_df = data.frame(time_data = time_data)
  time_data_df$timeMWTLMATCH <- NA
  
  for(i in 1:length(time_MWTL)){
    
    time_data_df$timeMWTLMATCH[time_data_df$time_data >= range_low[i] & time_data_df$time_data <= range_upper[i]] <- i
    
  }
  return(time_data_df)
  
}
#######################################

#####DataFrameMWTLNCDF

DF_MWTL_NCDF <- function(substance_mwtl,list_locations_mwtl,workdir){
  library("ncdf")
  library("chron")
  
  file_name = substance_mwtl
  list_locations = list_locations_mwtl
    
  locations_present <- list.files(path = paste(workdir,file_name,"\\",sep = ""))
  
  for(f in 1:length(list_locations)){
    nr_file <- grep(paste(as.character(list_locations)[f],".nc",sep = ""),locations_present)
    
    #Skip locations that are not present in Netcdf
    if(length(nr_file) != 1){next}else{}
    
    
    setwd(paste(workdir,file_name,"\\",sep = ""))
    
    ################
    #Load NetCDF
    
    # Now open the file and read its data
    station <- open.ncdf(locations_present[nr_file], write=FALSE, readunlim=FALSE)
    
    # Get data
    cat(paste(station$filename,"has",station$nvars,"variables"), fill=TRUE)
    
    
    var_get = station[[10]][file_name]
    unit_for_plot = as.character(unlist(var_get[[file_name]]["units"]))
    
    time          = get.var.ncdf(nc=station,varid="time")   
    locations     = get.var.ncdf(nc=station,varid="locations") 
    name_strlen1  = get.var.ncdf(nc=station,varid="name_strlen1")  
    name_strlen2  = get.var.ncdf(nc=station,varid="name_strlen2")        
    platform_id   = get.var.ncdf(nc=station,varid="platform_id")
    platform_name = get.var.ncdf(nc=station,varid="platform_name")
    lon           = get.var.ncdf(nc=station,varid="lon")
    lat           = get.var.ncdf(nc=station,varid="lat")
    wgs_84        = get.var.ncdf(nc=station,varid="wgs84")
    epsg          = get.var.ncdf(nc=station,varid="epsg")
    x             = get.var.ncdf(nc=station,varid="x")
    y             = get.var.ncdf(nc=station,varid="y")
    z             = get.var.ncdf(nc=station,varid="z")
    value         = get.var.ncdf(nc=station,varid=file_name)
    
    datetime = strptime(as.character(chron(time, origin=c(month=1,day=1,year=1970))),format = "(%m/%d/%y %H:%M:%S)")
    
    if(length(platform_id) > 1){platform_id = platform_id}else{platform_id = rep(platform_id,length(value))}
    if(length(platform_name) > 1){platform_name = platform_name}else{platform_name = rep(platform_name,length(value))}
    if(length(lon) > 1){lon = lon}else{lon = rep(lon,length(value))}
    if(length(lat) > 1){lat = lat}else{lat = rep(lat,length(value))}
    if(length(lat) > 1){lat = lat}else{lat = rep(lat,length(value))}
    if(length(wgs_84) > 1){wgs_84 = wgs_84}else{wgs_84 = rep(wgs_84,length(value))}
    if(length(epsg) > 1){epsg = epsg}else{epsg = rep(epsg,length(value))}
    if(length(x) > 1){x = x}else{x = rep(x,length(value))}
    if(length(y) > 1){y = y}else{y = rep(y,length(value))}
    if(length(z) > 1){z = z}else{z = rep(z,length(value))}
    
    data_ncdf = data.frame(time = datetime,platform_id, platform_name ,
                           lon , lat , wgs_84 , epsg, x , y , 
                           z, value) 
  
    #Close NetCDF connection
    close.ncdf(station)
    
    if(!(exists("save_dataframe"))){save_dataframe = data_ncdf}else{save_dataframe = rbind(save_dataframe,data_ncdf)}
  }
  return(save_dataframe)
}
########################################################

####DataFrameSensorenNCDF

DF_Sens_NCDF <- function(file_sens,workdir){
  library("ncdf")
  
  setwd(workdir)
  FS = open.ncdf(file_sens, write=FALSE, readunlim=FALSE)
  
  # Get data
  time          = get.var.ncdf(nc=FS,varid="TIME")   
  lon           = get.var.ncdf(nc=FS,varid="lon")
  lat           = get.var.ncdf(nc=FS,varid="lat")
  z             = get.var.ncdf(nc=FS,varid="z")
  value         = get.var.ncdf(nc=FS,varid="oxygen")
  datetime      = as.POSIXlt(x = as.numeric(time*86400), origin="1970-01-01",tz="UTC")
  
  if(length(lon) > 1){lon = lon}else{lon = rep(lon,length(value))}
  if(length(lat) > 1){lat = lat}else{lat = rep(lat,length(value))}
  if(length(z) > 1){z = z}else{z = rep(z,length(value))}
  
  data_FS = data.frame(time = datetime,lon , lat , z, value) 
   
  return(data_FS)
}
####################################################

###PointsInBuffer
PointsInBuffer <- function(data_points,buffers){
  library("sp")
 
  attach(data_points)
  coordinates(data_points) <- c("lon","lat")
  detach(data_points)
  proj4string(data_points)<-CRS("+proj=longlat +datum=WGS84")
  
  Match_points <- over(data_points,buffer_plot)
  
  punten_correct <- Match_points[!(is.na(Match_points))]
    
  point_in_buffer <- SelectSpatial(data_points, !(is.na(Match_points)))
  return(point_in_buffer)
}
############################################################

workdirectory_mwtl = "d:\\kluijver\\R scripts\\3. Reference_data\\"

list_locations = c("NOORDWK1","NOORDWK10","NOORDWK2","NOORDWK20",
"NOORDWK30","NOORDWK4","NOORDWK50","NOORDWK70","TERSLG10","TERSLG100",
"TERSLG135","TERSLG175","TERSLG20","TERSLG235","TERSLG30","TERSLG4","TERSLG50",
"TERSLG70","WALCRN20")


file_nc_cor = "O2"

###############
#NETCDF data

data_mwtl = DF_MWTL_NCDF(file_nc_cor,list_locations,workdirectory_mwtl)
    
buffer_set <- unique(data_mwtl[,c("platform_name","lon","lat")])
colnames(buffer_set)[2:3] <- c("x","y")

select <- data.frame(1:length(unique(data_mwtl[,c("platform_name","lon","lat")])[,1]))
buffer_plot <- CreateBuffersLATLONWGS(buffer_set, 1000, select)
  
### Ferryboxdata
workdirectory<-"p:/1209005-eutrotracks/helpdeskwater_delivery_2013/nc/ferry/"
FB<- "ferrybox_oxygen.nc"
FB_data <- DF_Sens_NCDF(FB,workdirectory)

#Test CSV
#setwd("p:/1209005-eutrotracks/helpdeskwater_delivery_2013/R validation analyses/")
#write.csv(FB_data,"FB_complete_chla.csv")

### Scanfish
workdirectory<-"p:/1209005-eutrotracks/helpdeskwater_delivery_2013/nc/meetv/"
SF<- "scanfish_oxygen.nc"
SF_data <- DF_Sens_NCDF(SF,workdirectory)

#Test CSV
#setwd("p:/1209005-eutrotracks/helpdeskwater_delivery_2013/R validation analyses/")
#write.csv(SF_data,"SF_complete_chla.csv")

###CTD
workdirectory<-"p:/1209005-eutrotracks/helpdeskwater_delivery_2013/nc/ctd/as_trajectory"
CTD<-"ctd_oxygen.nc"
CTD_data<- DF_Sens_NCDF(CTD,workdirectory)

head(FB_data)
head(SF_data)
head (CTD_data)

#Replace NA's
FB_data$value[FB_data$value == 1e30] <- NA
SF_data$value[SF_data$value == 1e30] <- NA
CTD_data$value[CTD_data$value == 1e30] <- NA

FB_data <- na.omit(FB_data)
FB_data$value[is.na(FB_data$value)]

SF_data <- na.omit(SF_data)
SF_data$value[is.na(SF_data$value)]

CTD_data <- na.omit(CTD_data)
CTD_data$value[is.na(CTD_data$value)]
#Add Coordinates
data_FB_MWTL <-PointsInBuffer(FB_data,buffer_plot)
data_SF_MWTL <-PointsInBuffer(SF_data,buffer_plot)
data_CTD_MWTL <-PointsInBuffer(CTD_data,buffer_plot)

head(data_CTD_MWTL@data)
head(data_CTD_MWTL@coords)
#plot(data_FB_MWTL)

# Test CSV output
#data = data_FB_MWTL@data
#coord = data_FB_MWTL@coords 
#datacoord = cbind(coord,data)
#setwd("p:/1209005-eutrotracks/helpdeskwater_delivery_2013/R validation analyses/")
#write.csv(datacoord,"FB_chla.csv")

#data = data_SF_MWTL@data
#coord = data_SF_MWTL@coords 
#datacoord = cbind(coord,data)
#setwd("p:/1209005-eutrotracks/helpdeskwater_delivery_2013/R validation analyses/")
#write.csv(datacoord,"SF_chla.csv")

head(data_SF_MWTL@data)
head(data_SF_MWTL@coords)
#plot(data_SF_MWTL, col = "red", add = TRUE)

## remove values outside depth range
data_SF_MWTL[data_SF_MWTL$z < 0,] # these are above the surface
data_SF_MWTLz<-data_SF_MWTL[data_SF_MWTL@data$z >= 0 & data_SF_MWTL@data$z <= 500,]

data_CTD_MWTL[data_CTD_MWTL$z < 0,]
data_CTD_MWTLz<-data_CTD_MWTL[data_CTD_MWTL@data$z >= 0 & data_CTD_MWTL@data$z <= 500,]

## select in time frame
data_mwtl_selectie<-data_mwtl[data_mwtl$time >= strptime("1998-01-01 01:00:00", format = "%y%y-%m-%d %H:%M:%S") &
  data_mwtl$time <=strptime("2011-12-31 23:00:00", format = "%y%y-%m-%d %H:%M:%S"),]
data_mwtl_selectie$z<-abs(data_mwtl_selectie$z) * 100

match_FB <- MatchMWTLAndDATA(data_FB_MWTL@data$time,data_mwtl_selectie$time, 1.5*60*60)
match_SF <- MatchMWTLAndDATA(data_SF_MWTLz@data$time,data_mwtl_selectie$time, 1.5*60*60)
match_CTD <- MatchMWTLAndDATA(data_CTD_MWTLz@data$time,data_mwtl_selectie$time, 1.5*60*60)

FB1 = cbind(data_FB_MWTL@data,timeMWTLMATCH = match_FB$timeMWTLMATCH)
FB1$MWTL_time = data_mwtl_selectie$time[FB1$timeMWTLMATCH]
FB1$Locatie   = data_mwtl_selectie$platform_id[FB1$timeMWTLMATCH]
FB1 = FB1[!(is.na(FB1$timeMWTLMATCH)),]
FB1$class = "FB"
FB2 <- FB1[,c("class","Locatie","MWTL_time","time","z","value")]
head(FB2)

SF1 = cbind(data_SF_MWTLz@data,timeMWTLMATCH = match_SF$timeMWTLMATCH)
SF1$MWTL_time = data_mwtl_selectie$time[SF1$timeMWTLMATCH]
SF1$Locatie   = data_mwtl_selectie$platform_id[SF1$timeMWTLMATCH]
SF1 = SF1[!(is.na(SF1$timeMWTLMATCH)),]
SF1$class = "SF"
SF2 <- SF1[,c("class","Locatie","MWTL_time","time","z","value")]
head(SF2)

CTD1 = cbind(data_CTD_MWTLz@data,timeMWTLMATCH = match_CTD$timeMWTLMATCH)
CTD1$MWTL_time = data_mwtl_selectie$time[CTD1$timeMWTLMATCH]
CTD1$Locatie   = data_mwtl_selectie$platform_id[CTD1$timeMWTLMATCH]
CTD1 = CTD1[!(is.na(CTD1$timeMWTLMATCH)),]
CTD1$class = "CTD"
CTD2 <- CTD1[,c("class","Locatie","MWTL_time","time","z","value")]
head(CTD2)
colnames(data_mwtl_selectie)
data_mwtl_selectie$class = "MWTL"
data2sub = data_mwtl_selectie[,c("class","platform_id","time","time","z","value")]
head(data_mwtl_selectie)
colnames(data2sub) <- colnames(FB2)

head(data2sub)

data_total <- rbind(FB2,SF2,CTD2,data2sub)

plot(data2sub$value~data2sub$MWTL_time, col = "red")
points(SF2$value~SF2$MWTL_time, col = "blue")
points(FB2$value~FB2$MWTL_time, col = "green")
points(CTD2$value~CTD2$MWTL_time,col="grey")

### Set twee voor ggplot2
data_total_FB <- cbind(data_FB_MWTL@data,data_mwtl_selectie[match_FB[,2],c(1,2,10,11)])
data_total_FB <- na.omit(data_total_FB)
colnames(data_total_FB) <- c("time_sens","z_sens","value_sens","time_mwtl","location","z_mwtl","value_mwtl")
data_tot_FB <- data_total_FB[data_total_FB$value_sens >= 0,] ## remove values outside range
data_total_SF <- cbind(data_SF_MWTLz@data,data_mwtl_selectie[match_SF[,2],c(1,2,10,11)])
data_total_SF <- na.omit(data_total_SF)
             

colnames(data_total_SF) <- c("time_sens","z_sens","value_sens","time_mwtl","location","z_mwtl","value_mwtl")
data_tot_SF   <- data_total_SF[data_total_SF$value_sens >= 0,] ## remove values outside range

data_total_CTD <- cbind(data_CTD_MWTLz@data,data_mwtl_selectie[match_CTD[,2],c(1,2,10,11)])
data_total_CTD <- na.omit(data_total_CTD)
colnames(data_total_CTD) <- c("time_sens","z_sens","value_sens","time_mwtl","location","z_mwtl","value_mwtl")
data_tot_CTD   <- data_total_CTD[data_total_CTD$value_sens >= 0,] ## remove values outside range

data_tot_FB$year<-as.numeric(as.POSIXlt(data_tot_FB$time_mwtl)$year+1900)
data_tot_FB$year<-as.factor(data_tot_FB$year)
data_tot_SF$year<-as.numeric(as.POSIXlt(data_tot_SF$time_mwtl)$year+1900)                
data_tot_SF$year<-as.factor(data_tot_SF$year)  
data_tot_CTD$year<-as.numeric(as.POSIXlt(data_tot_CTD$time_mwtl)$year+1900)                
data_tot_CTD$year<-as.factor(data_tot_CTD$year)  

data_tot_CTD_a<-data_tot_CTD[!(data_tot_CTD$location=="noordwk4"),]

## analyses in ggplot2
library(ggplot2)
library(RColorBrewer)
theme_set(theme_bw(15))  
                  
plotdir<-"p:/1209005-eutrotracks/helpdeskwater_delivery_2013/R validation analyses/plots"

#scatterplots per year and location                  
p<-ggplot(data_tot_SF,aes(value_mwtl, value_sens,color=year))
p + geom_point() + 
  labs(xlab="values MWTL", ylab="values SF", title="Oxygen SF") + facet_wrap(~location)
ggsave(file=paste(plotdir,)

p<-ggplot(data_tot_FB,aes(value_mwtl, value_sens,color=year))
p + geom_point()  + scale_colour_brewer(palette="Accent") +
    labs(x=expression(MWTL~waarde~O[2]~(mg/l)), y=expression(MWTL~waarde~O[2]~(mg/l)), title="Zuurstof Ferrybox") + 
    facet_wrap(~location)
    

p<-ggplot(data_tot_CTD_a,aes(value_mwtl, value_sens,color=year))
p + geom_point()  +
  labs(xlab="values MWTL", ylab="values CTD", title=" Oxygen CTD") + facet_wrap(~location)

##plot all with regression
cor.test(data_tot_SF$value_sens,data_tot_SF$value_mwtl)
p<-ggplot(data_tot_SF,aes(value_mwtl, value_sens))
p + geom_point() +  
  labs(xlab="values MWTL", ylab="values SF", title=" Oxygen SF")+
  stat_smooth(aes(value_mwtl, value_sens),method = "lm") +
   annotate("text", x = 5, y = 15, label = "r=0.92")

cor.test(data_tot_FB$value_mwtl,data_tot_FB$value_sens)
p<-ggplot(data_tot_FB,aes(value_mwtl, value_sens))
p + geom_point() + 
  labs(xlab="values MWTL", ylab="values FB", title=" Oxy FB")+
  stat_smooth(aes(value_sens, value_mwtl),method = "lm")+
  annotate("text", x = 7.5, y = 20, label = "r=0.75")

cor.test(data_tot_CTD$value_mwtl,data_tot_CTD$value_sens)
p<-ggplot(data_tot_CTD,aes(value_mwtl, value_sens))
p + geom_point() + 
  labs(xlab="values MWTL", ylab="values CTD", title=" Oxy CTD")+
  stat_smooth(aes(value_sens, value_mwtl),method = "lm")+
  annotate("text", x = 7.5, y = 15, label = "r=0.90")

## per time
p<-ggplot(data_total,aes(MWTL_time, value,color=class))
p + geom_line() +scale_y_log10() + 
labs(xlab="time", ylab="values", title=" Chla and sensors") + facet_wrap(~Locatie)
                  
# with median and percentiles
require(plyr)

FB_stat<-ddply(data_tot_FB,"time_mwtl", summarise,
               n_sens=length(unique(value_sens)),
               value_mwtl=unique(value_mwtl),
               location=unique(location),
               year=unique(year),
               median_sens=median(value_sens),
               low_sens=quantile(value_sens,probs=0.1),
               high_sens=quantile(value_sens,probs=0.9))

cor.test(FB_stat$value_mwtl,FB_stat$median_sens)

ggplot(FB_stat,aes(value_mwtl,median_sens,ymin=low_sens,ymax=high_sens))+
  geom_linerange(col="grey")+
  geom_point()+ xlim(7,20)+ylim(7,20)+
  labs(x=expression(MWTL~waarde~O[2]~(mg/l)), y=expression(Sensorwaarde~O[2]~(mg/l)), title="Zuurstof Ferrybox")+ 
  stat_smooth(aes(value_mwtl,median_sens),se=FALSE, method = "lm",size=1)+
  annotate("text", x =7, y =20 , label = "r=0.79")+
  geom_abline(slope=1,linetype="dashed",col="black")
  ggsave(file="Oxy_FB_all_median.png",path=plotdir,width=8,height=6)


ggplot(FB_stat,aes(value_mwtl,median_sens,ymin=low_sens,ymax=high_sens))+
  geom_linerange(col="grey",size=.75)+
  geom_point(aes(colour=year))+
  xlim(7,20)+ylim(7,20)+
  facet_wrap(~location)+
  labs(x=expression(MWTL~waarde~O[2]~(mg/l)), y=expression(Sensorwaarde~O[2]~(mg/l)), title="Zuurstof Ferrybox")+
  stat_smooth(method = "lm",se=FALSE,size=.75)+
  geom_abline(slope=1,linetype="dashed",col="black")
  ggsave(file="Oxy_FB_perloc&year_median.png",path=plotdir,width=8,height=6)     

SF_stat<-ddply(data_tot_SF,"time_mwtl", summarise,
               n_sens=length(unique(value_sens)),
               value_mwtl=unique(value_mwtl),
               location=unique(location),
               year=unique(year),
               median_sens=median(value_sens),
               low_sens=quantile(value_sens,probs=0.1),
               high_sens=quantile(value_sens,probs=0.9))

cor.test(SF_stat$value_mwtl,SF_stat$median_sens)

ggplot(SF_stat,aes(value_mwtl,median_sens,ymin=low_sens,ymax=high_sens))+
  geom_linerange(col="grey")+
  geom_point()+
  xlim(5,15.5)+ylim(5,15.5)+
  labs(x=expression(MWTL~waarde~O[2]~(mg/l)), y=expression(Sensorwaarde~O[2]~(mg/l)), title="Zuurstof Meetvis")+
  stat_smooth(aes(value_mwtl,median_sens),method = "lm",se=FALSE,size=1)+
  annotate("text", x =5, y = 15.5, label = "r=0.89")+
  geom_abline(slope=1,linetype="dashed",col="black")
  ggsave(file="Oxy_SF_all_median.png",path=plotdir,width=8,height=6)      

ggplot(SF_stat,aes(value_mwtl,median_sens,ymin=low_sens,ymax=high_sens))+
  geom_linerange(col="grey",size=.75)+
  geom_point(aes(colour=year))+
  xlim(5,15.5)+ylim(5,15.5)+
  facet_wrap(~location)+
  labs(x=expression(MWTL~waarde~O[2]~(mg/l)), y=expression(Sensorwaarde~O[2]~(mg/l)), title="Zuurstof Meetvis")+
  stat_smooth(method = "lm",se=FALSE,size=0.75)+
  geom_abline(slope=1,linetype="dashed",col="black")
  ggsave(file="Oxy_SF_perloc&year_median.png",path=plotdir,width=8,height=6) 

CTD_stat<-ddply(data_tot_CTD_a,"time_mwtl", summarise,
                n_sens=length(unique(value_sens)),
                value_mwtl=unique(value_mwtl),
                location=unique(location),
                year=unique(year),
                median_sens=median(value_sens),
                low_sens=quantile(value_sens,probs=0.1),
                high_sens=quantile(value_sens,probs=0.9))

cor.test(CTD_stat$value_mwtl,CTD_stat$median_sens)

ggplot(CTD_stat,aes(value_mwtl,median_sens,ymin=low_sens,ymax=high_sens))+
  geom_linerange(col="grey")+
  geom_point()+
  xlim(5,15)+ylim(5,15)+
  labs(x=expression(MWTL~waarde~O[2]~(mg/l)), y=expression(Sensorwaarde~O[2]~(mg/l)), title="Zuurstof CTD")+
  stat_smooth(aes(value_mwtl,median_sens),method = "lm",se=FALSE,size=1)+
  annotate("text", x =5, y = 15, label = "r=0.85")+
  geom_abline(slope=1,linetype="dashed",col="black")
  ggsave(file="Oxy_CTD_all_median.png",path=plotdir,width=8,height=6)     

ggplot(CTD_stat,aes(value_mwtl,median_sens,ymin=low_sens,ymax=high_sens))+
  geom_linerange(col="grey",size=.75)+
  geom_point(aes(colour=year))+
  xlim(5,15)+ylim(5,15)+
  facet_wrap(~location)+
  labs(x=expression(MWTL~waarde~O[2]~(mg/l)), y=expression(Sensorwaarde~O[2]~(mg/l)), title="Zuurstof CTD")+
  stat_smooth(method = "lm",se=FALSE,size=0.75)+
  geom_abline(slope=1,linetype="dashed",col="black")
  ggsave(file="Oxy_CTD_perloc&year_median.png",path=plotdir,width=8,height=6)                   