######Read Data#######################


############################################################
## Read MWTL NetCDF and convert it to a Dataframe

DF_MWTL_NCDF <- function(substance_mwtl,list_locations_mwtl,workdir){
  library("ncdf")
  library("chron")
  
  file_name = substance_mwtl
  list_locations = list_locations_mwtl
  
  locations_present <- list.files(path = file.path(workdir,file_name))
  
  if(exists("save_dataframe")){rm("save_dataframe")}
  
  for(f in 1:length(list_locations)){
    
    nr_file <- grep(paste(as.character(list_locations)[f],".nc",sep = ""),locations_present)
    
    #Skip locations that are not present in Netcdf
    if(length(nr_file) != 1){next}else{}
    
    
    setwd(file.path(workdir,file_name))
    
    ################
    #Load NetCDF
    
    # Now open the file and read its data
    station <- open.ncdf(locations_present[nr_file], write=FALSE, readunlim=FALSE)
    
    # Get data
    cat(paste(station$filename,"has",station$nvars,"variables"), fill=TRUE)
    
    
    var_get = station[[10]][file_name]
    unit_for_plot = as.character(unlist(var_get[[file_name]]["units"]))
    
    time_ncdf     = get.var.ncdf(nc=station,varid="time")   
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
    
    datetime = strptime(as.character(chron(time_ncdf, origin=c(month=1,day=1,year=1970))),format = "(%m/%d/%y %H:%M:%S)",tz = "GMT")
    
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
                           z, value, unit = rep(unit_for_plot,length(value)), stringsAsFactors = FALSE) 
    
    data_ncdf$location_name <- as.character(list_locations)[f]
    data_ncdf_corr = data_ncdf[!(duplicated(data_ncdf)),]
    
    if(TRUE %in% duplicated(data_ncdf[,c("time","location_name")])){
      stop(print(paste("NetCDF file: Duplicates on time and location_name in netcdf file ",
                       substance_mwtl," for file ",locations_present[nr_file]," . Please correct this file.",
                       sep = "" )))
    }
    
    #Close NetCDF connection
    close.ncdf(station)
    
    if(!(exists("save_dataframe"))){
      save_dataframe = data_ncdf
    }else{
      save_dataframe = rbind(save_dataframe,data_ncdf_corr)
    }
  }
  if(!(exists("save_dataframe"))){
    save_dataframe = data.frame(time = 0,platform_id = NA, platform_name = NA,
                                lon = 0 , lat = 0 , wgs_84 = NA , epsg = NA, x = 0 , y = 0 , 
                                z = 0, value = 0, unit = NA)
  }
  return(save_dataframe)
}

