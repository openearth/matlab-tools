###################################################
#This list contains functions that are used for the project
# "Betrouwbaarheid modellen"
# Author: Marc Weeber
###################################################

#####Small utilities#####################

#########################################
# Correct date implimitator
#rem: do to switch form standard Time to DST on 2102-03-25 problems
#with this date
#
#http://stackoverflow.com/questions/13865172/
#handling-data-on-the-days-when-we-switch-to-daylight-savings-time-and-back-in-r

as.POSIXct.no.dst <- function (x, tz = "", format="%Y-%m-%d %H:%M", offset="+0100", ...)
{
  x <- paste(x, offset)
  format <- paste(format, "%z")
  as.POSIXct(x, tz, format=format, ...)
}
#########################################

#########################################
# Replaces column values in a dataframe (character or logical to character)
ColumnReplacer <- function(dataframe,old, replacement){
  
  if(class(dataframe) != "data.frame"){stop(print("Dataframe should be of type data.frame."))}
  if(class(old) != "character" & class(old) != "logical"){stop(print("Old should be of class character or logical."))}
  if(class(replacement) != "character"){stop(print("Replacement should be of class character."))}
  if(is.na(old)){
    for(i in 1:length(colnames(dataframe))){
      select = is.na(dataframe[,i])
      dataframe[select,i] = as.character(dataframe[select,i])
      dataframe[select,i] <- replacement
    }
  }
  if(is.character(old)){
    for(i in 1:length(colnames(dataframe))){
      select = dataframe[,i] == old
      dataframe[select,i] = as.character(dataframe[select,i])
      dataframe[select,i] <- replacement
    }
  }
  return(dataframe)
}
##########################################

##########################################
# Changes the Column type of a dataframe
ColumnChanger <-function(dataframe,newcolumntypes){
  if(class(dataframe) != "data.frame"){stop(print("Dataframe should be of type data.frame."))}
  if(length(colnames(dataframe)) != length(newcolumntypes)){
    stop(print("Different length between nr of columns in dataframe and newcolumntypes."))
  }
  
  new_dataframe = dataframe
  for(i in 1:length(newcolumntypes)){
    new_dataframe[,i] = as(new_dataframe[,i],newcolumntypes[i])
  }
  return(new_dataframe)
}
##########################################

##########################################
# Replaces a column value in a dataframe
#based on a indicator (part of value)
TempSwitchOff <- function(dataframe,indicator,replacement){
  if(class(dataframe) != "data.frame"){stop(print("Dataframe should be of type data.frame."))}
  if(class(indicator) != "character"){stop(print("Indicator should be of class character."))}
  if(class(replacement) != "character"){stop(print("Replacement should be of class character."))}
  for(i in 1:length(colnames(dataframe))){
    select = 1:length(dataframe[,i]) %in% grep(indicator,dataframe[,i])
    dataframe[select,i] <- replacement
  }
  return(dataframe)
}
##########################################

##########################################
# Get time for date or datetime
GetDateOrDateTime <- function(character_time){
  
  if(!(is.character(character_time[1]))){
    stop(print("Character_time should be of class character!"))
  }
  
  #Test time format
  date_ind = grep("-",character_time[1])
  time_ind = grep(":",character_time[1])
  
  if(!(length(date_ind) == 0) & (length(time_ind) == 0)){
    # Get Date
    date_variable = strptime(character_time, format = "%y%y-%m-%d",tz = "GMT")
    format_strptime = "date"
  }
  if(!(length(date_ind) == 0) & !(length(time_ind) == 0)){
    # Get Date Time
    date_variable = strptime(character_time, format = "%y%y-%m-%d %H:%M:%S", tz = "GMT")
    format_strptime = "date_time"
  }
  if((length(date_ind) == 0) & (length(time_ind) == 0)){
    date_variable = rep(NA,length(character_time))
    format_strptime = "incorrect" 
  }
  
  #Check
  if(TRUE %in% is.na(date_variable)){
    stop(print(paste("Incorrect Date or datetime value sublied : ",
                     character_time[is.na(date_variable)][1],
                     ". This should be either format yyyy-mm-dd or yyyy-mm-dd hh:mm:ss !",
                     sep = "")))
  }
  
  # Return output
  output = list(date_variable,format_strptime)
  return(output)
}
##########################################



######Read Input File#####################

##########################################
# Read the Input file for specific
# configurations
ReadInputFile <- function(input_file){
    
  #read the file
  input_file = readLines(input_file)
  
  #omit_text
  select_text = grep("#",input_file)
  select_text_boolean = c(1:length(input_file)) %in% select_text
  without_text = input_file[!(select_text_boolean)]
  
  #omit row white space only
  without_whitespace = without_text[without_text != ""]
  
  #seperate by delimiter
  variable_name = unlist(lapply(str_split(without_whitespace,"   "), function(x) x[1]))
  input = unlist(lapply(str_split(without_whitespace,"   "), function(x) x[3]))
  
  
  # Start settings
  
  variables_dataframe = data.frame(variable_name,input, stringsAsFactors = FALSE)
  
  #Return the vaiarbles
  return(variables_dataframe)
}










######Read Mapping#######################

#########################################
# Check the mapping for locations
# and variables
CreateMappingTable <- function(list_locations, list_variables){
  
  #Current mapping tables
  ##List locations
  loc_colnr = 3
  loc_colnam = c("location_his","location_nc","full_name")
  loc_class = c("character","character","character")
  loc_switchcolumns = c(2,3)
  min_list_loc = 1
  
  ##List variables
  var_colnr = 7
  var_colnam = c("variable_his","variable_nc","variable_csv",
                 "factor_on_measurement","combine_simulated","combine_measurement","remarks")
  var_class = c("character","character","character","numeric","character",
                "character","character")
  var_switchcolumns = c(2,3,5,6)
  min_list_var = 1
  HIScolumn = "variable_his" 
  NetCDFcolumn = "variable_nc"
  CSVcolumn = "variable_csv"
  factors = "factor_on_measurement"
  Combine_sim = "combine_simulated"
  Combine_meas = "combine_measurement"
  NetCDFandCSV = FALSE
  
  #Check datatype
  if(class(list_locations) != "data.frame"){
    stop(print("List locations should be of class data.frame"))
  }
  if(class(list_variables) != "data.frame"){
    stop(print("List variables should be of class data.frame"))
  }
  
  #Check locations
  if(length(colnames(list_locations)) != loc_colnr){
    stop(print(paste("List locations has to many/few columns : needed is ",loc_colnr,
                     ", current is", length(colnames(list_locations)),"!", sep = "")))
  }
  if(FALSE %in% (loc_colnam %in% colnames(list_locations))){
    stop(print(paste("List locations has incorrect columnnames : needed is ",
                     paste(loc_colnam, collapse = ";"),", current is ",
                     paste(colnames(list_locations), collapse = ";"),sep ="")))
  }
  
  if(length(list_locations[,1]) < min_list_loc){
    stop(print(paste("List locations is to short : rows needed is ",
                     min_list_loc,", current is ",
                     length(list_locations[,1]),sep ="")))
  }
  
  
  #Check variables
  if(length(colnames(list_variables)) != var_colnr){
    stop(print(paste("List variables has to many/few columns : needed is ",var_colnr,
                     ", current is", length(colnames(list_variables)),"!", sep = "")))
  }
  if(FALSE %in% (var_colnam %in% colnames(list_variables))){
    stop(print(paste("List variables has incorrect columnnames : needed is ",
                     paste(var_colnam, collapse = ";"),", current is ",
                     paste(colnames(list_variables), collapse = ";"),sep ="")))
  }
  if(length(list_variables[,1]) < min_list_var){
    stop(print(paste("List variables is to short : rows needed is ",
                     min_list_var,", current is ",
                     length(list_variables[,1]),sep ="")))
  }
  
  # Change content of columns
  list_locations[,c(1:3)] = ColumnReplacer(list_locations[,c(1:3)],NA,"")
  list_variables[,c(1:3,5:7)] = ColumnReplacer(list_variables[,c(1:3,5:7)],NA,"")
  
  #Check if the factor column is correct
  factorcolumnfilled = na.omit(list_variables[,factors])
  if(length(factorcolumnfilled) > 0 ){
    if(!(class(list_variables[,factors]) == "numeric" | class(list_variables[,factors]) == "integer")){
      stop(print(paste("List variables: column ",factors," contains non-numerics or non-integers." )))
    } 
  }
  
  
  ## Correct for the columns
  corr_list_locations = ColumnChanger(list_locations,loc_class)
  corr_list_variables = ColumnChanger(list_variables,var_class)
  
  
  ## Omit exclusions
  
  #locations
  corr_list_locations[,loc_switchcolumns] = TempSwitchOff(corr_list_locations[,loc_switchcolumns],"---","")
  
  #Variables
  corr_list_variables[,var_switchcolumns] = TempSwitchOff(corr_list_variables[,var_switchcolumns],"---","")
  
  
  ##Preform checks
  
  # Locations
  check_locations_vs1 = corr_list_locations[,1] == "" & 
    (corr_list_locations[,2] != "" | corr_list_locations[,3] != "")
  check_locations_vs2 = corr_list_locations[,2] == "" & corr_list_locations[,3] != ""
  check_locations_vs3 = corr_list_locations[,2] != "" & corr_list_locations[,3] == ""
  
  if(TRUE %in% check_locations_vs1){
    wrong_line = c(corr_list_locations[check_locations_vs1,1][1],corr_list_locations[check_locations_vs1,2][1],
                   corr_list_locations[check_locations_vs1,3][1])
    stop(print(paste("List locations : row with NA ;",wrong_line[2],";",wrong_line[3],
                     " is incorrect. First column should be filled.", sep ="")))
  }
  
  if(TRUE %in% check_locations_vs2){
    wrong_line = c(corr_list_locations[check_locations_vs2,1][1],corr_list_locations[check_locations_vs2,2][1],
                   corr_list_locations[check_locations_vs2,3][1])
    stop(print(paste("List locations : row with ",wrong_line[1],";",wrong_line[2],";",wrong_line[3],
                     " is incorrect. First all columns should be filled.",
                     " Last two columns should be empty in case of exclusion.", sep ="")))
  }
  
  if(TRUE %in% check_locations_vs3){
    wrong_line = c(corr_list_locations[check_locations_vs3,1][1],corr_list_locations[check_locations_vs3,2][1],
                   corr_list_locations[check_locations_vs3,3][1])
    stop(print(paste("List locations : row with ",wrong_line[1],";",wrong_line[2],";",wrong_line[3],
                     " is incorrect. First all columns should be filled.",
                     " Last two columns should be empty in case of exclusion.", sep ="")))
  }
  
  # Variables
  
  # Check on Combination no his and no combine meas
  check_variables_vs1 = corr_list_variables[,HIScolumn] == "" & corr_list_variables[,Combine_meas] == ""
  if(TRUE %in% check_variables_vs1){
    wrong_line = c(corr_list_variables[check_variables_vs1,1][1],corr_list_variables[check_variables_vs1,2][1],
                   corr_list_variables[check_variables_vs1,3][1])
    stop(print(paste("List variables : row with NA ;",wrong_line[2],";",wrong_line[3],
                     " is incorrect. First column or combine_meas should be filled.", sep ="")))
  }
  
  # Check on double measurement input per row
  Check_double_measurement = !(corr_list_variables[,NetCDFcolumn] == "") & 
    !(corr_list_variables[,CSVcolumn] == "")
  
  if(TRUE %in% Check_double_measurement){
    wrong_line = c(corr_list_variables[Check_double_measurement,HIScolumn][1],
                   corr_list_variables[Check_double_measurement,NetCDFcolumn][1],
                   corr_list_variables[Check_double_measurement,CSVcolumn][1],
                   corr_list_variables[Check_double_measurement,Combine_sim][1],
                   corr_list_variables[Check_double_measurement,Combine_meas][1])
    stop(print(paste("List variables: double measurement for the variable_his ",
                     wrong_line[1],", with variable_nc ",
                     wrong_line[2],", and variable_csv ",
                     wrong_line[3],", use only one as measurement.",
                     sep ="")))
  }
  
  # Multiple checks
  Check_no_meas = (corr_list_variables[,NetCDFcolumn] == "") & (corr_list_variables[,CSVcolumn] == "")
  Check_no_sim = corr_list_variables[,HIScolumn] == ""
  Check_combine_meas = !(corr_list_variables[,Combine_meas] == "")
  Check_combine_sim = !(corr_list_variables[,Combine_sim] == "")
  
  # Check on combine_meas and combine_sim
  wrong_combine_comb = Check_combine_meas & Check_combine_sim
  if(TRUE %in% (wrong_combine_comb)){
    wrong_line = c(corr_list_variables[wrong_combine_comb,HIScolumn][1],
                   corr_list_variables[wrong_combine_comb,NetCDFcolumn][1],
                   corr_list_variables[wrong_combine_comb,CSVcolumn][1],
                   corr_list_variables[wrong_combine_comb,Combine_sim][1],
                   corr_list_variables[wrong_combine_comb,Combine_meas][1])
    stop(print(paste("List variables: double combines for the variable_his ",
                     wrong_line[1],", with combine_sim ",wrong_line[4],", and combine_meas ",
                     wrong_line[5],". Only one combine permitted.",
                     sep ="")))
  }
  
  # Check on combine_meas and no meas
  wrong_combine_meas = Check_combine_meas & Check_no_meas
  if(TRUE %in% (wrong_combine_meas)){
    wrong_line = c(corr_list_variables[wrong_combine_meas,HIScolumn][1],
                   corr_list_variables[wrong_combine_meas,NetCDFcolumn][1],
                   corr_list_variables[wrong_combine_meas,CSVcolumn][1],
                   corr_list_variables[wrong_combine_meas,Combine_sim][1],
                   corr_list_variables[wrong_combine_meas,Combine_meas][1])
    stop(print(paste("List variables: wrong measurement combine with combine_meas ",
                     wrong_line[5],"and variable_nc",wrong_line[2]," and variable_csv",wrong_line[3],
                     ". Variable_nc or variable_csv should be filled.",
                     sep ="")))
  }
  
  # Check on combine_sim and no sim
  wrong_combine_sim = Check_combine_sim & Check_no_sim
  if(TRUE %in% (wrong_combine_sim)){
    wrong_line = c(corr_list_variables[wrong_combine_comb,HIScolumn][1],
                   corr_list_variables[wrong_combine_comb,NetCDFcolumn][1],
                   corr_list_variables[wrong_combine_comb,CSVcolumn][1],
                   corr_list_variables[wrong_combine_comb,Combine_sim][1],
                   corr_list_variables[wrong_combine_comb,Combine_meas][1])
    stop(print(paste("List variables: no variable_his ",
                     wrong_line[1],", with combine_sim ",wrong_line[4],
                     ". Variable_his should be filled.",
                     sep ="")))
  }
  
  # Check on combine_sim and a meas
  wrong_combine_sim_and_meas = Check_combine_sim & !(Check_no_meas)
  if(TRUE %in% (wrong_combine_sim_and_meas)){
    wrong_line = c(corr_list_variables[wrong_combine_sim_and_meas,HIScolumn][1],
                   corr_list_variables[wrong_combine_sim_and_meas,NetCDFcolumn][1],
                   corr_list_variables[wrong_combine_sim_and_meas,CSVcolumn][1],
                   corr_list_variables[wrong_combine_sim_and_meas,Combine_sim][1],
                   corr_list_variables[wrong_combine_sim_and_meas,Combine_meas][1])
    stop(print(paste("List variables: variable_nc ",
                     wrong_line[2]," or variable_csv ",wrong_line[3]," with combine_sim ",wrong_line[4],
                     ". Either csv or nc or combine_sim should be used.",
                     sep ="")))
  }
  
  # Check on combine_meas and a sim
  wrong_combine_meas_and_sim = Check_combine_meas & !(Check_no_sim)
  if(TRUE %in% (wrong_combine_meas_and_sim)){
    wrong_line = c(corr_list_variables[wrong_combine_meas_and_sim,HIScolumn][1],
                   corr_list_variables[wrong_combine_meas_and_sim,NetCDFcolumn][1],
                   corr_list_variables[wrong_combine_meas_and_sim,CSVcolumn][1],
                   corr_list_variables[wrong_combine_meas_and_sim,Combine_sim][1],
                   corr_list_variables[wrong_combine_meas_and_sim,Combine_meas][1])
    stop(print(paste("List variables: variable_his ",
                     wrong_line[1],", with combine_meas ",wrong_line[5],
                     ". Either his or combine_meas should be used.",
                     sep ="")))
  }
  
  #Check if simulation aggregation is correct
  Aggregations_sim = unique(corr_list_variables[corr_list_variables[,Combine_sim] != "", Combine_sim])
  if(length(Aggregations_sim) > 0){
    Check_aggregation_sim = (Aggregations_sim %in% corr_list_variables[,HIScolumn])
    if(FALSE %in% Check_aggregation_sim){
      missing_aggr_sim = Aggregations_sim[Check_aggregation_sim == FALSE][1]
      stop(print(paste("List variables:", Combine_sim,":",missing_aggr_sim," is not present in ",HIScolumn,".", sep = "")))
    }
  }
  
  #Check if measurement aggregation is correct
  Aggregations_meas = unique(corr_list_variables[corr_list_variables[,Combine_meas] != "", Combine_meas])
  if(length(Aggregations_meas) > 0){
    Check_aggregation_meas = (Aggregations_meas %in% corr_list_variables[,NetCDFcolumn])
    if(FALSE %in% Check_aggregation_meas){
      missing_aggr_meas = Aggregations_meas[Check_aggregation_meas == FALSE][1]
      stop(print(paste("List variables:", Combine_meas,":",missing_aggr_meas," is not present in ",NetCDFcolumn,".", sep = "")))
    }
  }
  
  
  
  ## Clean up 
  
  #Locations
  omit_locations = !((corr_list_locations[,loc_colnam[1]] == "") | (corr_list_locations[,loc_colnam[2]] == "")
                     | (corr_list_locations[,loc_colnam[3]] == ""))
  list_locations_filled = corr_list_locations[omit_locations,]
  
  #Variables
  wrong_empty_meas = (Check_no_meas & !(Check_combine_sim))
  list_variables_filled = corr_list_variables[!(wrong_empty_meas),]
  
  
  ## Working Set
  
  #Locations
  working_locations = list_locations_filled
  
  #variables
  Check_combine_sim_new = (list_variables_filled[,Combine_sim] != "")
  Check_combine_meas_new = (list_variables_filled[,Combine_meas] != "")
  select_work_var = !(Check_combine_sim_new | Check_combine_meas_new)
  working_variables = list_variables_filled[select_work_var,]
  
  # Return Working set and Cleaned up set
  output = list(working_locations, list_locations_filled, working_variables, list_variables_filled)
  
  return(output)
}
######################################

######################################
# Make a variable overview
FileVariableList <- function(list_var_used,list_var_comp){
  HIScolumn = "variable_his"
  NetCDFcolumn = "variable_nc"
  CSVcolumn = "variable_csv"
  Combine_sim = "combine_simulated"
  Combine_meas = "combine_measurement"
  Factor_meas = "factor_on_measurement"
  
  # Progress list_var
  for(i in 1:length(list_var_used[,1])){
    
    # Make HIS type
    variable_sim <- list_var_used[i,HIScolumn]
    
    if(list_var_used[i,HIScolumn] %in% list_var_comp[,Combine_sim]){
      variable_sim_type <- "Combine"
    }else{
      variable_sim_type <- "HIS"
    }
    
    # Make CSV type
    if(list_var_used[i,NetCDFcolumn] == "" & list_var_used[i,CSVcolumn] != ""){
      variable_meas <- list_var_used[i,CSVcolumn]
      variable_meas_type <- "CSV"
    }
    
    # Make NetCDF or combine type
    if(list_var_used[i,NetCDFcolumn] != "" & list_var_used[i,CSVcolumn] == ""){
      variable_meas <- list_var_used[i,NetCDFcolumn]
      if(list_var_used[i,NetCDFcolumn] %in% list_var_comp[,Combine_meas]){
        variable_meas_type <- "Combine"
      }else{
        variable_meas_type <- "NetCDF"
      }
    }
    
    # Give factor on measurement
    factor_measurement = list_var_used[i,Factor_meas]
    complete_set = data.frame(variable_sim, variable_sim_type,
                              variable_meas,variable_meas_type,
                              factor_on_measurement = factor_measurement, 
                              stringsAsFactors = FALSE)
    
    if(i == 1){
      overview = complete_set
    }else{
      overview = rbind(overview,complete_set)
    }
  }
  return(overview)
}


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
#########################################################################

################################
## Read His files

####################################
#Import function ReadHis
## Script by Ype van der Velde 2011 08 10
## Commented and updated by Fedor Baart 2013 10 04
## Updated by Willem Stolte 2013 11 01 
require("stringr")
read.his2 <- function(filename){
  ## Open file in binary mode
  zz <- file(filename, "rb")
  ## Read header lines
  readChar(zz,40)
  readChar(zz,40)
  readChar(zz,40)
  readChar(zz,4)
  ## reads time origin from Delwaq his file
  timeorigin <- readChar(zz,19)
  readChar(zz,17)
  ## Read 2 integers
  afm <- readBin(zz,integer(),n=2)
  ## reserve some memory
  syname <- vector("character",afm[1])
  idump <- vector("integer",afm[2])
  duname <- vector("integer",afm[2])
  ## Now a row of characters
  for(i in 1:afm[1]){
    syname[i] <- readChar(zz,20)
  }
  ## Now a few rows of integers and strings
  for(i in 1:afm[2]){
    idump[i] <- readBin(zz,integer(),n=1)
    duname[i] <- readChar(zz,20)
  }
  
  loc <- seek(zz)
  it <- -1
  itn <- vector("integer",0)
  tel<-0
  ## Keep reading until we no longer have data
  while(length(it)>0){
    tel<-tel+1
    it<-readBin(zz,integer(),n=1)
    if (length(it)>0){
      itn<-c(itn,it)
      conc<-readBin(zz,"double",n=afm[1]*afm[2],size=4)
    }
  }
  ## rewind
  seek(zz, where=loc)
  concar <- array(dim=c(length(itn),afm[2],afm[1]))
  for(i in 1:length(itn)){
    it <- readBin(zz,integer(),n=1)
    concar[i,,] <- matrix(readBin(zz,"double",n=afm[1]*afm[2],size=4),nrow=afm[2],ncol=afm[1],byrow=T)
  }
  ## close file connection
  close(zz)
  ### adapt date names using timeorigin in his file
  timeorigin <- str_replace_all(timeorigin,"[.]","-")
  itn2 <- as.character(as.POSIXct(x=as.numeric(itn), origin = timeorigin, tz = "GMT"))  
  dimnames(concar) <- list(itn2,str_trim(duname),str_trim(syname))
  return(concar)
}

###################################

####################################
#Get info from array
#  copied from : http://stackoverflow.com/questions/14500707/select-along-one-of-n-dimensions-in-array
index_array <- function(x, dim, value, drop = FALSE) { 
  # Create list representing arguments supplied to [
  # bquote() creates an object corresponding to a missing argument
  indices <- rep(list(bquote()), length(dim(x)))
  indices[[dim]] <- value
  
  # Generate the call to [
  call <- as.call(c(
    list(as.name("["), quote(x)),
    indices,
    list(drop = drop)))
  # Print it, just to make it easier to see what's going on
  print(call)
  
  # Finally, evaluate it
  eval(call)
}
#####################################



####################################
#Convert his to dataframe
ConvertArraytoDataframe <- function(array,column_names){
  
  layers <- dim(array)[2]
  
  if(length(column_names) == layers){
    for(i in 1:layers){
      data <- data.frame(array[1:dim(array)[1],1:dim(array)[2],i],stringsAsFactors = FALSE)
      colnames(data)<-column_names[i]
      if(i == 1){tot_data = data}else{tot_data <- cbind(tot_data,data)}
    }
  }else{"Number of names incorrect"}
  return(tot_data)
}

####################################

####################################
# Extract data from His file
LoadHisFile <- function(his_file, path){
  
  setwd(path)
  
  #Load HIS file
  data_his = read.his2(his_file)
  
  #Get data of Hisfile
  date_names = dimnames(data_his)[[1]]
  
  #Get date (special format)
  if(nchar(date_names[1]) == 8){
    datetime = strptime(date_names,format = "%y-%m-%d", tz = "GMT")
  } 
  
  #Get date 
  if(nchar(date_names[1]) == 10){
    datetime = strptime(date_names,format = "%Y-%m-%d", tz = "GMT")
  }
  
  #Get datetime 
  if(nchar(date_names[1]) == 19){
    datetime = strptime(date_names,format = "%Y-%m-%d %H:%M:%S", tz = "GMT")
  }
  
  #Preform test on datetime
  test_datetime_bad = TRUE
  if(exists("datetime")){
    test_datetime_bad = TRUE %in% is.na(datetime)
  }
  
  #Check on date or datetime
  if(test_datetime_bad){
    stop(print(paste("His file ",his_file," contains incorrect time format.",
                     " Allowed formats are yy-mm-dd, yyyy-mm-dd and yyyy-mm-dd hh:mm:ss .")))
  }
  
  #Get year of Hisfile
  year = min(as.numeric(format(datetime,"%Y")))
  
  #Select data
  for(g in 1:dim(data_his)[3]){
    data_set_his =  data.frame(index_array(data_his,3,g))
    colnames(data_set_his) <- unlist(dimnames(data_his)[2])
    rownames(data_set_his) <- datetime
    list_set = c(list(unlist(dimnames(data_his)[3])[g]),list(data_set_his))
    if(g == 1){save_list = list(list_set)}else{save_list = c(save_list,list(list_set))}
  }
  temp_his = c(list(files_his[i]),list(save_list))
  save_his = list(temp_his)
  
  # Get possible variables from his
  for(j in 1:length(save_his[[1]][[2]])){
    if(j == 1){set1 = save_his[[1]][[2]][[j]][[1]]}else{set1 = c(set1,save_his[[1]][[2]][[j]][[1]])}
  }
  
  # Get possible locations from his
  #for(k in 1:length(save_his[[1]][[2]])){
  #  if(k == 1){set2 = colnames(save_his[[1]][[2]][[j]][[2]])}else{set2 = c(set2,colnames(save_his[[1]][[2]][[j]][[2]]))}
  #}
  extract_data_his = list(save_his,set1,year)
  
  return(extract_data_his)
}
############################################

############################################
# Get required HIS data from object
GetRequiredHisData <- function(variable_his,list_locations_comp,set1, save_his){
  
  loc_HIS_column = "location_his"
  
  ##Create the simulated dataset
  temp_var_his = paste("^",gsub(" ","",as.character(variable_his)),"_",sep="")
  correct_set1 = as.character(set1)
  
  #Trim set
  correct_set1 = unlist(lapply(set1, FUN = str_trim))
  
  # Compare set and var_his
  nr_var = grep(temp_var_his,correct_set1)
  
  #Check one with exact name
  if(length(nr_var) == 0){
    temp_var_his = paste("^",gsub(" ","",as.character(variable_his)),sep="")
    nr_var = grep(temp_var_his,correct_set1)
  }else{}
  
  #Delwaq seems to work with several standards on variable naming, here we test for the standard without "_"
  if(length(nr_var) == 0 | length(nr_var) > 1){
    temp_var_his = gsub(" ","",as.character(variable_his))
    nr_var = match(temp_var_his,correct_set1)
  }else{}
  
  #Delwaq seems to work with several standards on variable naming, here we test for the standard without "_"
  if(length(nr_var) == 0 | length(nr_var) > 1){
    stop(print(paste("Non or several variables matched to this variable ",as.character(variable_his),sep = "")))
  }else{}
  
  library("reshape")
  
  # !!! K can be changed if multiple his files should be loaded
  k = 1
  # Format data to required form
  #for(k in 1:length(files_his))
  simulated_dataset1 = save_his[[1]][[k]][[2]][[nr_var]][[2]]
  
  #Get date and time
  datetime_set = rownames(simulated_dataset1)
  #Try date
  if(nchar(datetime_set[1]) == 10){
    datesim = strptime(as.character(datetime_set),format = "%y%y-%m-%d", tz = "GMT")
  }
  #Try DateTime
  if(nchar(datetime_set[1]) == 19){
    datesim = strptime(as.character(rownames(simulated_dataset1)),format = "%y%y-%m-%d %H:%M:%S", tz = "GMT")
  }
  
  if(!(exists("datesim"))){
    stop(print("In GetRequiredHisFile date not of format yyyy-mm-dd or yyyy-mm-dd HH:MM:SS."))
  }
  if(TRUE %in% is.na(datesim)){
    stop(print("In GetRequiredHisFile date contains missing values."))
  }
  
  simulated_dataset1 = cbind(datesim,simulated_dataset1)
  simulated_dataset = melt.data.frame(data = simulated_dataset1,id.vars = c("datesim"))
  simulated_dataset$variable = str_trim(as.character(simulated_dataset$variable))
  if(k == 1){simulated_set_temp = simulated_dataset}else{simulated_set_temp = rbind(simulated_set_temp,simulated_dataset)}
  #}
  
  #Select simulated results for locations present
  simulated_set = simulated_set_temp[str_trim(as.character(simulated_set_temp$variable)) %in% list_locations_comp[,loc_HIS_column],]
  
  #Test if HIS is empty due to missing of correct locations
  if((length(simulated_set_temp[,1]) > 0) & (length(simulated_set[,1]) == 0)){
    stop(print("Locations in 'list_of_locations_linked' are not present in the HIS file!"))
  }
  
  return(simulated_set)
} 
############################################


############################################
# Prepare for Simulated data from HIS or Combine
ProgressHisData <- function(cur_file_var, list_var_comp, list_loc_comp, set1, save_his){
  
  HIS_column = "variable_his"
  
  Combine_sim = "combine_simulated"
  
  time_column = "datesim"
  
  # Check if combine
  if(cur_file_var$variable_sim_type == "Combine"){
    combine_files = list_var_comp[list_var_comp[,Combine_sim] %in% cur_file_var$variable_sim,]
    
    list_sim_combine_files = data.frame(variable_sim = combine_files[,HIS_column],
                                        variable_sim_type = rep("HIS",length(combine_files[,1])),
                                        variable_meas = rep("",length(combine_files[,1])), 
                                        variable_meas_type = rep("",length(combine_files[,1])),
                                        factor_on_measurement = rep("",length(combine_files[,1])),
                                        stringsAsFactors = FALSE)
    
    for(i in 1:length(list_sim_combine_files[,1])){ 
      file_output = GetRequiredHisData(list_sim_combine_files[i,"variable_sim"], list_loc_comp, set1 , save_his)
      
      if(i == 1){
        combined_file = file_output
        
      }else{
        file_output[,time_column] <- as.character(file_output[,time_column])
        combined_file[,time_column] <- as.character(combined_file[,time_column])
        by_list = c("datesim","variable")
        new_combined_file = merge(x = combined_file,y = file_output, by = by_list, sort = FALSE, all = TRUE)
        new_combined_file$value_total = new_combined_file$value.x + new_combined_file$value.y 
        combined_file = new_combined_file[,c("datesim","variable","value_total")]
        colnames(combined_file)<-colnames(file_output)
      }
    }
    meas_file = combined_file[!(duplicated(combined_file)),]
  }
  
  #Check if HIS
  if(cur_file_var$variable_sim_type == "HIS"){
    meas_file = GetRequiredHisData(cur_file_var$variable_sim, list_locations_comp, set1 , save_his)
  }
  
  #Check for other
  if(!(cur_file_var$variable_sim_type %in% c("HIS","Combine"))){
    stop(print(paste("List variable: simulation type ",cur_file_var$variable_sim_type,
                     " not implemented. Please use HIS or Combine.", sep = "")))
  }
  return(meas_file)
}
################################################

####################################
#Read Hisdata of KRW_V (per parts)

ReadWFDHis <- function(name_his,parts, column_names){
  library("abind")
  for(i in 1:length(parts)){
    array <- read.his2(paste(name_his,parts[i],".his",sep = ""))
    part <- ConvertArraytoDataframe(array, column_names)
    part_array<-array(data = as.vector(as.matrix(part)), dim = dim(part), dimnames = c(list(rownames(part)), list(colnames(part))))
    if(i == 1){tot_array = part_array}else{
      if(i == 2){tot_array = abind(tot_array,part_array, rev.along = 0)}else{tot_array = abind(tot_array,part_array, rev.along = 1)}
    }
  }
  return(tot_array)
}
#####################################

#####################################
# Check and Read CSV data
ReadCSVMWTLFormat <- function(csv_file, name_file){
  
  #Current mapping tables
  ##List locations
  csv_colnr = 13
  csv_colnam = c("time","platform_id","platform_name","lon","lat","wgs_84","epsg",         
                 "x","y","z","value","unit","location_name")
  csv_class = c("character","character","character","numeric",
                "numeric","numeric","numeric","numeric","numeric","numeric",
                "numeric","character","character")
  min_list_csv = 1
  csv_time_column = "time"
  
  #Check datatype
  if(class(csv_file) != "data.frame"){
    stop(print(paste("CSV file ", name_file," should be of class data.frame",sep = "")))
  }
  
  #Check locations
  if(length(colnames(csv_file)) != csv_colnr){
    stop(print(paste("CSV file ",name_file," has to many/few columns : needed is ",csv_colnr,
                     ", current is", length(colnames(csv_file)),"!", sep = "")))
  }
  if(FALSE %in% (csv_colnam %in% colnames(csv_file))){
    stop(print(paste("CSV file ",name_file," has incorrect columnnames : needed is ",
                     paste(csv_colnam, collapse = ";"),", current is ",
                     paste(colnames(csv_file), collapse = ";"),sep ="")))
  }
  
  if(length(csv_file[,1]) < min_list_csv){
    stop(print(paste("CSV file ", name_file,"is to short : rows needed is ",
                     min_list_csv,", current is ",
                     length(csv_file[,1]),sep ="")))
  }
  
  ## Correct for the columns
  corr_csv_file = ColumnChanger(csv_file,csv_class)
  
  return(corr_csv_file)
}
#############################################################
# Check for reading NetCDF and CSV and applying factors
ReadMeasInput <- function(cur_file_var,list_loc_comp,path){
  folder_netcdf = "NetCDF"
  folder_csv = "CSV"
  
  value_column = "value"
  factor_column = "factor_on_measurement"
  
  loc_indicator = "location_nc"
  loc_csv = "location_name"
  
  
  #Check type and preform actions
  
  #CSV
  if(cur_file_var$variable_meas_type == "CSV"){
    path_file = file.path(path,folder_csv)
    get_files = list.files(path_file)
    
    cur_csv_file = paste(cur_file_var$variable_meas,".csv",sep="")
    
    if(cur_csv_file %in% get_files){
      csv_file = read.csv(file.path(path_file,cur_csv_file),sep = ";")
      checked_csv_file = ReadCSVMWTLFormat(csv_file,cur_file_var[,"variable_meas"])
      
      # Multiply by factor
      if(!(is.na(cur_file_var[,factor_column])) & cur_file_var[,factor_column] != ""){
        checked_csv_file[,value_column] = checked_csv_file[,value_column] * cur_file_var[,factor_column]
      }
      
      #Check locations in file
      locations_not_present = !(list_loc_comp[,loc_indicator] %in% checked_csv_file[,loc_csv])
      if(TRUE %in% locations_not_present){
        stop(print(paste("Location ",list_loc_comp[,loc_indicator][locations_not_present][1],
                         " missing in NetCDF files for variable ",cur_file_var$variable_meas,
                         ".",sep = "" )))
      }
      new_file = checked_csv_file
    }else{
      stop(print(paste("CSV file ",cur_csv_file,
                       " is missing in the folder ",folder_csv,
                       ".",sep = "" )))
    }
  }
  
  # NetCDF
  if(cur_file_var$variable_meas_type == "NetCDF"){
    
    path_folder = file.path(path,folder_netcdf)
    get_folders = list.dirs(path_folder, full.names = FALSE)
    
    # Check for folders
    check_folders = cur_file_var$variable_meas %in% get_folders
    if(FALSE %in% check_folders){
      stop(print(paste("Folder ",cur_file_var$variable_meas,
                       " is missing in the folder ",folder_netcdf,
                       ".",sep = "" )))
    }
    
    # Get files
    path_files = file.path(path_folder,cur_file_var$variable_meas)
    get_files = list.files(path_files)
    
    ##Check for presence of locations
    for(presence in 1:length(list_loc_comp[,loc_indicator])){
      presence_location <- grep(paste(as.character(list_loc_comp[presence,loc_indicator]),".nc",sep = ""),get_files)
      if(presence ==1){tot_presence = presence_location}else{tot_presence = c(tot_presence,presence_location)}
    }
    
    #Check for missing locations
    missing_locations = is.na(tot_presence)
    if(TRUE %in% missing_locations){
      stop(print(paste("Location ",list_loc_comp[,loc_indicator][missing_locations][1],
                       " missing in NetCDF files for variable ",cur_file_var$variable_meas,
                       ".",sep = "" )))
    }  
    
    ##Get MWTL NetCDF data to dataframe
    save_dataframe <- DF_MWTL_NCDF(substance_mwtl = cur_file_var$variable_meas, list_locations_mwtl = list_loc_comp[,loc_indicator],
                                   workdir = path_folder)
    
    # Multiply by factor
    if(!(is.na(cur_file_var[,factor_column])) & cur_file_var[,factor_column] != ""){
      save_dataframe[,value_column] = save_dataframe[,value_column] * cur_file_var[,factor_column]
    }
    new_file = save_dataframe
  }
 return(new_file)  
}
##########################################################

##########################################################
# Preperation for progressing combines, CSV and NetCDF
PrepareMeas <- function(cur_file_var,list_var_comp,list_loc_comp,path){
  
  NetCDF_meas = "variable_nc"
  CSV_meas = "variable_csv"
  factor_column = "factor_on_measurement"
  
  Combine_meas = "combine_measurement"
  
  time_column = "time"
  
  # Check if combine
  if(cur_file_var$variable_meas_type == "Combine"){
    combine_files = list_var_comp[list_var_comp[,Combine_meas] %in% cur_file_var$variable_meas,]
    
    list_meas_combine_files = data.frame(variable_sim = rep("",length(combine_files[,1])),
                                         variable_sim_type = rep("",length(combine_files[,1])),
                                         variable_meas = combine_files[,NetCDF_meas], 
                                         variable_meas_type = rep("NetCDF",length(combine_files[,1])),
                                         factor_on_measurement = combine_files[,factor_column],
                                         stringsAsFactors = FALSE)
    
    csv_select = combine_files[,CSV_meas] != ""
    list_meas_combine_files$variable_meas[csv_select] = combine_files[csv_select,CSV_meas]
    list_meas_combine_files$variable_meas_type[csv_select] <- "CSV"
    
    for(i in 1:length(list_meas_combine_files[,1])){ 
      file_output = ReadMeasInput(list_meas_combine_files[i,], list_loc_comp, path)
      list_meas_combine_files[1,]
      
      if(i == 1){
        combined_file = file_output
        
      }else{
        file_output[,time_column] <- as.character(file_output[,time_column])
        combined_file[,time_column] <- as.character(combined_file[,time_column])

        
        by_list = c("time","location_name","platform_id",
                    "platform_name","lon","lat","wgs_84","epsg","x","y","z","unit")
        
	############################################
	#Tijdelijke oplossing voor de foutieve NETCDF files
        col_names_combined_file = colnames(combined_file)
        col_names_file_output = colnames(file_output)
        
        combined_file = combined_file[,colnames(combined_file) != "platform_id"]
        file_output = file_output[,colnames(file_output) != "platform_id"]
        
        combined_file$platform_id = combined_file$location_name
	      file_output$platform_id = file_output$location_name
        combined_file = combined_file[,col_names_combined_file]
        file_output = file_output[,col_names_file_output]
	############################################
	

        
        new_combined_file = merge(x = combined_file,y = file_output, by = by_list, sort = FALSE, all = TRUE)
        new_combined_file$value_total = new_combined_file$value.x + new_combined_file$value.y 
        combined_file = new_combined_file[,c("time","platform_id","platform_name","lon","lat","wgs_84",
                                             "epsg","x","y","z","value_total","unit","location_name")]
        combined_file$new_time = strptime(combined_file[,time_column], format = "%y%y-%m-%d %H:%M:%S", tz = "GMT")
        combined_file = combined_file[,c("new_time","platform_id","platform_name","lon","lat","wgs_84",
                                         "epsg","x","y","z","value_total","unit","location_name")]
        colnames(combined_file)<-colnames(file_output)
      }
    }
    meas_file = combined_file[!(duplicated(combined_file)),]
  }
  
  #Check if NetCDF or CSV
  if(cur_file_var$variable_meas_type == "NetCDF" | 
       cur_file_var$variable_meas_type == "CSV"){
    meas_file = ReadMeasInput(cur_file_var, list_loc_comp, path)
  }
  
  #Check for other
  if(!(cur_file_var$variable_meas_type %in% c("NetCDF","CSV","Combine"))){
    stop(print(paste("List variable: measurement type ",cur_file_var$variable_meas_type,
                     " not implemented. Please use NetCDF,CSV or Combine.", sep = "")))
  }
  meas_file$time = gsub(" GMT","",meas_file$time)
  
  return(meas_file)
}
###############################################




###############################
## Install Libraries
InstallLib<- function(){
  install.packages(c("Rmisc","solaR","ggplot2","e1071","lattice","stringr","chron","ncdf","reshape","gplots","Hmisc","plotrix","lubridate","scales"))
}

###############################




######DATA############################


################################
## Confidence interval
ConvidenceInterval<-function(data_value){
  library("Rmisc")
  return(CI(data_value, ci = 0.95))
}
################################

################################
## Boxplot
BoxPlotBetweenYears <-function(data,date,main = NULL, xlab = NULL, ylab = NULL)
{
  library("solaR")
  if( 0 == sum((class(date) != "POSIXct") + (class(date) != "POSIXlt") + 
    (class(date) != "POSIXt") + (class(date) != "Date"))){stop("Date should be set in POSIXct")}else{}
  if(class(data) != "numeric"){stop("Data is not numeric")}else{}
  year_data <- year(date)
  boxplot(data ~ year_data, xlab = xlab,ylab = ylab, main = main, outline = FALSE)
}
      
BoxPlotBetweenPeriods <- function(data,date,breaks,main = NULL, xlab = NULL, ylab = NULL)
{
  library("solaR")
  if( 0 == sum((class(date) != "POSIXct") + (class(date) != "POSIXlt") + 
    (class(date) != "POSIXt") + (class(date) != "Date"))){stop("Date should be set in POSIXct")}else{}
  if(class(data) != "numeric"){stop("Data is not numeric")}else{}
  data_set <- data.frame(data)
  data_set$nr <- 0
  for(i in 1:(length(breaks)+1)){
    if(i == 1){
      selection = as.numeric(date) >= as.numeric(min(date)) & as.numeric(date) < as.numeric(breaks[i])
    }else{
      if(i == (length(breaks)+1)){
       selection = as.numeric(date) >= as.numeric(breaks[i-1]) & as.numeric(date) <= as.numeric(max(date)) 
      }else{
        selection = as.numeric(date) >= as.numeric(breaks[i-1]) & as.numeric(date) < as.numeric(breaks[i])
      }
    }
    data_set$nr[selection] <- i
  }
  set = data_set$nr
  set
  boxplot(data ~ set, xlab = xlab,ylab = ylab, main = main, outline = FALSE)
}
      
BoxPlotBetweenSummerHalfYear <- function(data , date , start_day = "-05-01", end_day = "-09-01", main = NULL, xlab = NULL, ylab = NULL)
{
  library("solaR")
  if( 0 == sum((class(date) != "POSIXct") + (class(date) != "POSIXlt") + 
    (class(date) != "POSIXt") + (class(date) != "Date"))){stop("Date should be set in POSIXct")}else{}
  if(class(data) != "numeric"){stop("Data is not numeric")}else{}
  year_data <- year(date)
  for(i in 1: length(unique(year_data))){
    dates <- as.Date(date[year_data == unique(year_data)[i]], format = "%y%y-%m-%d")        
    selection = as.numeric(dates) < as.numeric(as.Date(paste(unique(year_data)[i],end_day,sep = ""), format = "%y%y-%m-%d")) &
      as.numeric(dates) > as.numeric(as.Date(paste(unique(year_data)[i],start_day,sep = ""), format = "%y%y-%m-%d"))
    if(i == 1){comp = selection}else{comp = c(comp,selection)}
  }
  data_frame = data.frame(data = data[comp], year_data = year_data[comp])
  data_frame = na.omit(data_frame)
  if(length(data_frame[,1]) > 0){
    #If data in summertime
    boxplot(data ~ year_data, data = data_frame, xlab = xlab ,ylab = ylab, main = main, outline = FALSE)
  }else{
    #If no data in summertime
    no_data_frame = data.frame(data = -999, year_data = year_data)
    boxplot(data ~ year_data, data = no_data_frame, xlab = xlab ,ylab = ylab, main = main, outline = FALSE)
  }
}
      
BoxPlotBetweenMonths <- function(data,date,main = NULL, xlab = NULL, ylab = NULL)
{
    library("solaR")
    if( 0 == sum((class(date) != "POSIXct") + (class(date) != "POSIXlt") + 
      (class(date) != "POSIXt") + (class(date) != "Date"))){stop("Date should be set in POSIXct")}else{}
    if(class(data) != "numeric"){stop("Data is not numeric")}else{}
    month_data <- month(date)
    for(i in 1:12){
      data_set = data[as.character(month_data) == as.character(i)]
      if(length(data_set) == 0){data_set = 0}else{}
      if(i == 1){data_frame = data.frame(month_nr = i, value = data_set)}else{
        data_frame = rbind(data_frame,data.frame(month_nr = i, value = data_set))
      }
    }
    boxplot(value ~ month_nr, data = data_frame, xlab = xlab,ylab = ylab, main = main, outline = FALSE)
}

BoxPlotLinesBetweenYears <-function(observed_value, simulated_value,date_obs,date_sim,main = NULL, xlab = NULL, ylab = NULL)
{
  library("solaR")
  
  if(length(observed_value) == 0 & length(simulated_value) == 0){
    stop(print("Both observed and simulated data are missing"))
  }
  
  #required dates
  year_nr = year(as.Date(date_sim[1], format = "%y%y-%m-%d"))
  
  if(length(observed_value) == 0){
    observed_value = rep(-999,length(date_sim))
    date_obs = date_sim
  }
  
  if(length(simulated_value) == 0){
    simulated_value = rep(-999,length(observed_value))
    date_sim = date_obs
  }
  
  observed = data.frame(date_obs = as.character(date_obs),observed_value)
  simulated = data.frame(date_sim = as.character(date_sim),simulated_value)
  
  if( 0 == sum((class(date) != "POSIXct") + (class(date) != "POSIXlt") + 
                 (class(date) != "POSIXt") + (class(date) != "Date"))){stop("Date should be set in POSIXct")}else{}
  
  upper_ylim = max(c(observed_value,simulated_value),na.rm = TRUE)
  
  observed$year_data_obs <- year(as.Date(date_obs, format = "%y%y-%m-%d"))
  
  years_plot = seq(year_nr-5,year_nr+5)
  
  if(FALSE %in% (years_plot %in% observed$year_data_obs)){
    missings = !(years_plot %in% observed$year_data_obs)
    missing_years = data.frame(date_obs = as.factor(paste(years_plot[missings],"-01-01",sep = "")),
                               observed_value = rep(-999,length(years_plot[missings])),
                               year_data_obs = years_plot[missings])
    observed = rbind(observed,missing_years)
    observed = observed[order(observed$year_data_obs),]
  }
  simulated$year_data_sim <- year(as.Date(date_sim, format = "%y%y-%m-%d"))
  boxplot(as.numeric(observed_value) ~ year_data_obs, data = observed, outline = FALSE, ylim = c(0,upper_ylim))
  
  #lines(as.numeric(simulated_value) ~ year_data_sim, data = simulated)
  aline <- aggregate(simulated[,2], by = data.frame(simulated[,3]), median)
  aline = aline[aline[,1] >= min(observed$year_data_obs) & aline[,1] <= max(observed$year_data_obs),]
  segments(match(aline[,1],unique(observed$year_data_obs)) - 0.2, aline[,2],
           match(aline[,1],unique(observed$year_data_obs)) + 0.2, aline[,2],
           lwd = 2, col = "red")
}

BoxPlotSegBetweenMonths <-function(observed_value_dec,observed_value_mod, simulated_value,date_obs_dec,date_obs_mod,date_sim,main = NULL, xlab = NULL, ylab = NULL)
{
  data = observed_value_dec
  library("solaR")
  if( 0 == sum((class(date) != "POSIXct") + (class(date) != "POSIXlt") + 
    (class(date) != "POSIXt") + (class(date) != "Date"))){stop("Date should be set in POSIXct")}else{}
  if(class(data) != "numeric"){stop("Data is not numeric")}else{}
  month_data <- month(date_obs_dec)
  for(i in 1:12){
    data_set = observed_value_dec[as.character(month_data) == as.character(i)]
    if(length(data_set) == 0){data_set = 0}else{}
    if(i == 1){data_frame = data.frame(month_nr = i, value = data_set)}else{
      data_frame = rbind(data_frame,data.frame(month_nr = i, value = data_set))
    }
  }
  month_data_sim <- month(date_sim)
  for(i in 1:12){
    data_set_sim = simulated_value[as.character(month_data_sim) == as.character(i)]
    if(length(data_set_sim) == 0){data_set_sim = 0}else{}
    if(i == 1){data_frame_sim = data.frame(month_nr = i, value = data_set_sim)}else{
      data_frame_sim = rbind(data_frame_sim,data.frame(month_nr = i, value = data_set_sim))
    }
  }
  month_data_obs_mod <- month(date_obs_mod)
  for(i in 1:12){
    data_set_obs = observed_value_mod[as.character(month_data_obs_mod) == as.character(i)]
    if(length(data_set_sim) == 0){data_set_obs = 0}else{}
    if(i == 1){data_frame_obs = data.frame(month_nr = i, value = data_set_obs)}else{
      data_frame_obs = rbind(data_frame_obs,data.frame(month_nr = i, value = data_set_obs))
    }
  }
  boxplot(value ~ month_nr, data = data_frame, xlab = xlab,ylab = ylab, main = main, outline = FALSE, xlim = c(0,max(observed_value_dec,observed_value_mod,simulated_value)))
  #lines(as.numeric(simulated_value) ~ year_data_sim, data = simulated)
  aline <- aggregate(data_frame_sim$value, by = data.frame(data_frame_sim$month_nr), median)
  segments(match(aline[,1],(1:12)) - 0.2, aline[,2],
         match(aline[,1],(1:12)) + 0.2, aline[,2],
         lwd = 2, col = "red")
  points(x = data_frame_obs$month_nr, y = data_frame_obs$value, pch = 2, cex = 0.75, col = "blue")
}

      
BoxPlotLinesBetweenMonths <-function(observed_value_dec,observed_value_mod, simulated_value,date_obs_dec,date_obs_mod,date_sim,main = NULL, xlab = NULL, ylab = NULL)
{
  library("solaR")
  library(scales)
  if( 0 == sum((class(date) != "POSIXct") + (class(date) != "POSIXlt") + 
                 (class(date) != "POSIXt") + (class(date) != "Date"))){stop("Date should be set in POSIXct")}else{}
  month_data <- month(date_obs_dec)
  
  if(length(observed_value_dec) == 0 & length(observed_value_mod) == 0 & length(simulated_value) == 0){
    stop(print("Both observed and simulated data are missing"))
  }
  
  if(length(observed_value_dec) == 0){
    year = year(as.Date(date_sim[1], format = "%y%y-%m-%d"))
    start = paste(year-5,"-01-01",sep = "")
    end = paste(year+5,"-12-31",sep = "")
    date_obs_dec = seq(as.Date(start), as.Date(end), by="1 day")
    observed_value_dec = rep(-999,length(date_obs_dec))
  }
  
  if(length(observed_value_mod) == 0){
    observed_value_mod = rep(-999,length(simulated_value))
    date_obs_mod = date_sim
  }
  if(length(simulated_value) == 0){
    simulated_value = rep(-999,length(observed_value_mod))
    date_sim = date_obs_mod
  }
    
  for(i in 1:12){
      data_set = observed_value_dec[as.character(month_data) == as.character(i)]
      if(length(data_set) == 0){data_set = 0}else{}
      if(i == 1){data_frame = data.frame(month_nr = i, value = data_set)}else{
          data_frame = rbind(data_frame,data.frame(month_nr = i, value = data_set))
      }
  }
  upper_ylim = max(c(observed_value_dec,observed_value_mod,simulated_value),na.rm = TRUE)              
  boxplot(value ~ month_nr, data = data_frame, xlab = xlab,ylab = ylab, main = main, outline = FALSE, ylim = c(0,max(observed_value_dec,observed_value_mod,simulated_value)))
  #lines(as.numeric(simulated_value) ~ year_data_sim, data = simulated)
  lines(x = ((doy(date_sim)/365)*12)+0.5, y = simulated_value, cex = 1, col = "red")
  colorpoint <- ifelse(length(observed_value_mod) < 40, "blue", alpha("blue",5/length(observed_value_mod)))
  points(x = ((doy(date_obs_mod)/365)*12)+0.5, y = observed_value_mod, pch = 2, cex = 0.75, col = colorpoint)
}
      
################################

################################
## Multiple comparison

MultipleComparison <- function(observed_value,group, origin = "value", main = NULL, xlab = NULL, ylab = NULL){

  library("ggplot2")
  library("Rmisc")
  CI_0.95 <-function(x){CI(x,ci = 0.95)}
  data <- aggregate(observed_value, by = data.frame(group,origin), FUN = CI_0.95)
  data_unlist <- unlist(data.frame(data)[,"x"])
  data_new = data.frame(data_unlist)
  
  predicted.data <- data.frame(
    group = as.factor(data$group),
    origin = as.factor(data$origin),
    x.mean  = as.numeric(data_new[,c("mean")]),
    x.lower = as.numeric(data_new[,c("lower")]),
    x.upper = as.numeric(data_new[,c("upper")]))
 
  qplot(x=origin, facets=~group,
      y=x.mean, ymax=x.upper, ymin=x.lower,
      geom="pointrange", data=predicted.data, main = main, xlab = xlab, ylab = ylab)
    }
################################


######Model##########################


      
      

################################
## Scenario analysis

################################


######Calibration and Validation#####

################################
##Nash Sutcliff Model Efficienty
NashSutcliff <-function(observed_value,simulated_value){
  1- ( sum((observed_value - simulated_value)^2) / sum((observed_value - mean(observed_value))^2) )
}
################################

################################
## Percentage model bias
PercentageModelBias <- function(observed_value,simulated_value){
  error = sum(simulated_value - observed_value)
  bias = error / length(simulated_value)*100
  return(bias)
}
################################
      
################################
## ANOVA
ANOVA <- function(value, categorie){
      anova_data = data.frame(value,categorie)
      fit <- aov(value ~ categorie, data=anova_data)
      return(summary(fit))
}
################################

################################
##Shapiro-Wilk Test
ShapiroWilkTest<-function(values){
  
  #Get maximum 5000 values
  if(length(values) > 5000){
    test_values = sample(values,5000, replace = FALSE)
  }else{
    test_values = values
  }
  
  #Need minimum 4 values
  if(length(test_values) < 4){
    result <- "Lower than 4 values, Shapiro-Wilk Test is not preformed"
  }else{
    result <- shapiro.test(test_values)
  }
  return(result)
}
################################

################################
## Costfunction Binary 
CostfunctionFigure <- function(observed_bin,simulated_chance, all_lines = FALSE){
      value(observed_bin, simulated_chance ,cl = seq(0.01,0.99,0.05),
      main = "Relative Economic Value plot", 
      xlab = "cost/loss ratio r [-]", 
      ylab = "relative economic value v [-]", 
      lwd = 2, all = all_lines)
}
###############################

################################
## Costfunction calculation      
      Costfunction <- function(observed_value,simulated_value){
        Absol = abs(observed_value - simulated_value)
        summed = sum(Absol/sd(observed_value))
        cf = (1/length(observed_value))*summed
        return(cf)
}     
################################      
      
################################
## Skew
Skew <- function(data_value){
  library(e1071)
  return(skewness(data_value))
}
################################

################################
## R squared
Rsquared <- function(observed_value,simulated_value){
  DF <- data.frame(observed =observed_value, simulated=simulated_value)
  fit <- lm(simulated ~ observed, data=DF)
  RS = summary(fit)$adj.r.squared
  return(RS)
}
      
      
################################
## Receiver operator characteristic (ROC)
## Source: Jan Verkade and Fedor Baart (2009) Verifying probability 
#                        of precipitation - an example from Finland.
ROCmodelfit <- function(observed_bin, simulated_chance){
  roc.plot(observed_bin,simulated_chance, main="Hit/False ratio of the model")
}

ROCArea <- function(observed_bin, simulated_chance){
  Obs_bin <- vector(mode = "numeric", length = 365)
  a <- which(observed_bin)
  Obs_bin[a] <- 1
  return(roc.area(Obs_bin, simulated_chance))
}

################################

################################
## Correlation coefficient
CorrelationCoefficient<-function(observed_value,simulated_value){
  DF <- data.frame(observed =observed_value, simulated=simulated_value)
  with(DF, plot(observed, simulated))
  abline(fit <- lm(simulated ~ observed, data=DF), col='black')
  legend("topright", bty="n", legend=paste("R^2 is", 
           format(summary(fit)$adj.r.squared, digits=4)))
}
################################

################################
# Create Normal Fit data over period
# (it takes the most central value found within the search period, if even the lower central value)

NormalFitData <- function(comp_obs_origin, comp_obs_value,
                          comp_obs_date, comp_sim_origin, comp_sim_value, comp_sim_date,range_day){
  
  library("lubridate")
  
  if(length(comp_sim_date) > 0 & length(comp_obs_date) > 0){
    
    #Subset to simulation year
    year_sim = unique(year(comp_sim_date))
    year_obs = year(comp_obs_date)
    
    comp_obs_origin = comp_obs_origin[year_obs == year_sim]
    comp_obs_value = comp_obs_value[year_obs == year_sim]
    comp_obs_date = comp_obs_date[year_obs == year_sim]
    
    #
    
    data_sim = data.frame(comp_sim_origin, comp_sim_value, comp_sim_date, stringsAsFactors = FALSE)
    data_obs = data.frame(comp_obs_origin, comp_obs_value, comp_obs_date, stringsAsFactors = FALSE)
    
    range_sec = (range_day * 24 * 60 *60)
    
    unique_origin = unique(data_sim$comp_sim_origin)
    
    for(i in 1:length(unique_origin)){
      
      subset_data_sim = data_sim[data_sim$comp_sim_origin == unique_origin[i],]
      subset_data_obs = data_obs[data_obs$comp_obs_origin == unique_origin[i],]
      
      for(g in 1:length(subset_data_obs$comp_obs_date)){
        date = subset_data_obs$comp_obs_date[g]
        min_date = date - (range_sec)
        max_date = date + (range_sec)
        window_values = subset_data_sim$comp_sim_value[subset_data_sim$comp_sim_date >= min_date & 
                                                         subset_data_sim$comp_sim_date <= max_date] 
        if(length(window_values)>0){
          if((length(window_values) %% 2) == 0){
            sim_fitt = window_values[(length(window_values)/2)]
          }else{
            sim_fitt = window_values[ceiling(length(window_values)/2)]
          }
          
          combined = data.frame(origin = unique_origin[i], obs_date = date, 
                                obs_value = subset_data_obs$comp_obs_value[g], norm_fit_sim = sim_fitt, 
                                range_sec = range_sec, stringsAsFactors = FALSE)
          if(exists("sum_combined")){
            sum_combined = rbind(sum_combined,combined)
          }else{
            sum_combined = combined
          }
        }
      }
      if(exists("sum_combined")){
        if(exists("sum_origin_combined")){
          sum_origin_combined = rbind(sum_origin_combined,sum_combined)
        }else{
          sum_origin_combined = sum_combined
        }
        rm("sum_combined")
      }else{}
    }
    if(exists("sum_origin_combined")){
      return(sum_origin_combined)
    }else{
      stop(print(paste("No matches with current search window ",range_sec," for Normal fit. Try a larger search window.",sep = "")))
    }
  }else{
    print("Either there are no simulated values or no observed values in Normal fit.")
  }
}
################################


################################
# Create BestFit of data overperiod

BestFitData <- function(comp_obs_origin, comp_obs_value,
                        comp_obs_date, comp_sim_origin, comp_sim_value, comp_sim_date,range_day){
  
  library("lubridate")
  
  if(length(comp_sim_date) > 0 & length(comp_obs_date) > 0){
    
    #Subset to simulation year
    year_sim = unique(year(comp_sim_date))
    year_obs = year(comp_obs_date)
    
    comp_obs_origin = comp_obs_origin[year_obs == year_sim]
    comp_obs_value = comp_obs_value[year_obs == year_sim]
    comp_obs_date = comp_obs_date[year_obs == year_sim]
    
    #
    
    data_sim = data.frame(comp_sim_origin, comp_sim_value, comp_sim_date, stringsAsFactors = FALSE)
    data_obs = data.frame(comp_obs_origin, comp_obs_value, comp_obs_date, stringsAsFactors = FALSE)
    
    range_sec = (range_day * 24 * 60 *60)
    
    unique_origin = unique(data_sim$comp_sim_origin)
    
    for(i in 1:length(unique_origin)){
      
      subset_data_sim = data_sim[data_sim$comp_sim_origin == unique_origin[i],]
      subset_data_obs = data_obs[data_obs$comp_obs_origin == unique_origin[i],]
      
      for(g in 1:length(subset_data_obs$comp_obs_date)){
        date = subset_data_obs$comp_obs_date[g]
        min_date = date - (range_sec)
        max_date = date + (range_sec)
        window_values = subset_data_sim$comp_sim_value[subset_data_sim$comp_sim_date >= min_date & 
                                                         subset_data_sim$comp_sim_date <= max_date] 
        if(length(window_values)>0){
          difference = window_values - subset_data_obs$comp_obs_value[g] 
          sim_fitt = mean(window_values[which.min(abs(difference))])
          
          combined = data.frame(origin = unique_origin[i], obs_date = date, 
                       obs_value = subset_data_obs$comp_obs_value[g], best_fit_sim = sim_fitt, 
                       range_sec = range_sec, stringsAsFactors = FALSE)
          if(exists("sum_combined")){
            sum_combined = rbind(sum_combined,combined)
          }else{
            sum_combined = combined
          }
        }
      }
      if(exists("sum_combined")){
        if(exists("sum_origin_combined")){
          sum_origin_combined = rbind(sum_origin_combined,sum_combined)
        }else{
          sum_origin_combined = sum_combined
        }
        rm("sum_combined")
      }else{}
    }
    if(exists("sum_origin_combined")){
      return(sum_origin_combined)
    }else{
      stop(print(paste("No matches with current search window ",range_sec," for Best fit. Try a larger search window.",sep = "")))
    }
  }else{
    print("Either there are no simulated values or no observed values in Best fit")
  }
}
################################

################################
# Create Average of data overperiod
AverageData <- function(comp_obs_origin, comp_obs_value,
                        comp_obs_date, comp_sim_origin, comp_sim_value, comp_sim_date,range_day){

  library("lubridate")
  
  if(length(comp_sim_date) > 0 & length(comp_obs_date) > 0){
    
    #Subset to simulation year
    year_sim = unique(year(comp_sim_date))
    year_obs = year(comp_obs_date)
    
    comp_obs_origin = comp_obs_origin[year_obs == year_sim]
    comp_obs_value = comp_obs_value[year_obs == year_sim]
    comp_obs_date = comp_obs_date[year_obs == year_sim]
    
    #
    
    data_sim = data.frame(comp_sim_origin, comp_sim_value, comp_sim_date, stringsAsFactors = FALSE)
    data_obs = data.frame(comp_obs_origin, comp_obs_value, comp_obs_date, stringsAsFactors = FALSE)
    
    range_sec = (range_day * 24 * 60 *60)
    
    unique_origin = unique(data_sim$comp_sim_origin)
    
    for(i in 1:length(unique_origin)){
      
      subset_data_sim = data_sim[data_sim$comp_sim_origin == unique_origin[i],]
      subset_data_obs = data_obs[data_obs$comp_obs_origin == unique_origin[i],]
      
      for(g in 1:length(subset_data_obs$comp_obs_date)){
        date = subset_data_obs$comp_obs_date[g]
        min_date = date - (range_sec)
        max_date = date + (range_sec)
        window_values = subset_data_sim$comp_sim_value[subset_data_sim$comp_sim_date >= min_date & 
                                                               subset_data_sim$comp_sim_date <= max_date] 
        if(length(window_values)>0){
          obs_mean = mean(window_values,na.rm = TRUE)
          combined = data.frame(origin = unique_origin[i], obs_date = date, 
	                         obs_value = subset_data_obs$comp_obs_value[g], average_sim = obs_mean, 
                       		range_sec = range_sec, stringsAsFactors = FALSE)
          if(exists("sum_combined")){
            sum_combined = rbind(sum_combined,combined)
          }else{
            sum_combined = combined
          }
        }
      }
      if(exists("sum_combined")){
        if(exists("sum_origin_combined")){
          sum_origin_combined = rbind(sum_origin_combined,sum_combined)
        }else{
          sum_origin_combined = sum_combined
        }
        rm("sum_combined")
      }else{}
    }
    if(exists("sum_origin_combined")){
      return(sum_origin_combined)
    }else{
      stop(print(paste("No matches with current search window ",range_sec," for AveragedData. Try a larger search window.",sep = "")))
    }
  }else{
    print("Either there are no simulated values or no observed values in AveragedData")
  }
}
################################

################################
## Target diagram

make.target.table2 <- function (formulax, df.stat, val_obs, val_mod){
  ##=========================================================================##
  ##                                                                         ##
  ##                 Start function "make.target.table" version 2            ##
  ##                                 -----------------                       ##
  ##  Function to make a table suitable for target diagram plots containing  ##
  ##             nuRMSD and nBIAS for selected categories of data             ##
  ##                                                                         ##
  ##       Input:   formula: variables ~ .  (variables to be grouped by)     ##
  ##                 df.stat (dataframe containing data                      ##
  ##                 val_obs (column with observed values)                   ##
  ##                 val_mod (column with modelled values)                   ##
  ##      Output:    df.target (dataframe with nuRMSD and nbias)              ##
  ##   Reference:    Jolliff(2009) J Mar Sys, 76(1-2), 64-82                 ##
  ##      Author:    willem.stolte@deltares.nl                               ##
  ##  webaddress:    https://svn.oss.deltares.nl/repos/openearthtools/       ##
  ##                 trunk/r/applications/Delft3D/waq/target-function.R      ##
  ##  testscript:    https://svn.oss.deltares.nl/repos/openearthtools/       ##
  ##                 trunk/r/applications/Delft3D/waq/target-diagram.R       ##
  ##   copyright:    Deltares                                                ##
  ##                                                                         ##
  ##=========================================================================##
  
  #   TESTDATA TO RUN THE FUNCTION AS SCRIPT
  #   df.stat = read.csv("stattable.csv)  
  #   formulax = ~ substance + location 
  #   val_obs = "value.x"
  #   val_mod = "value.y"
  
  require(plyr)
  
  ## calculate square differences (SD)
  df.summary <- ddply(df.stat, formulax, here(summarise),
                      observed = get(val_obs),
                      modelled = get(val_mod),
                      SD = ((get(val_obs) - mean(get(val_obs))) - (get(val_mod) - mean(get(val_mod))))^2
  )
  
  ## calculate normalized root mean square difference (nuRMSD)
  ## and normalized bias (nBIAS)
  df.target <- ddply(df.summary, formulax, summarise,
                     nuRMSD = (sqrt(mean(SD))*sign(sd(modelled)-sd(observed)))/sd(observed),
                     nBIAS = (mean(modelled) - mean(observed))/sd(observed)
  )
  
  return(df.target)
} 



make.target.table3 <- function (compare_columns, df.stat, val_obs, val_mod){
  ##=========================================================================##
  ##                                                                         ##
  ##                 Start function "make.target.table" version 3            ##
  ##                                 -----------------                       ##
  ##                                                                         ##
  ##        Due to instability of the plyr package when used in a function   ##
  ##        I have created make.target.table3 in which plyr is not used.     ##
  ##                                                                         ##
  ##        Author: M.P. Weeber                                              ##
  ##        Date: 17-10-2014                                                 ##
  ##                                                                         ##
  #############################################################################
  
  #   TESTDATA TO RUN THE FUNCTION AS SCRIPT
  #   df.stat = read.csv("stattable.csv)  
  #   formulax = ~ substance + location 
  #val_obs = "value.x"
  #val_mod = "value.y"
  
  require(plyr)
  
  #Get mean of observed and modelled
  df.summary.mean.valobs = aggregate(df.stat[,val_obs],data = df.stat,by = df.stat[,compare_columns], FUN = mean)
  df.summary.mean.valmod = aggregate(df.stat[,val_mod],data = df.stat,by = df.stat[,compare_columns], FUN = mean)
  
  df.summary.mean.valobs$y = df.summary.mean.valmod$x
  df.summary.mean = df.summary.mean.valobs
  
  #Get required data according to compare columns from df.stat
  df.stat = df.stat[,c(compare_columns,val_obs,val_mod)]
  
  #Give columnames to df.stat and df.summary.mean
  colnames(df.stat)<-c(compare_columns,"observed","modelled")
  colnames(df.summary.mean)<-c(compare_columns,"observed","modelled")
  
  #Create columns for filling
  df.stat$SD = NA
  df.summary.mean$nuRMSD = NA
  df.summary.mean$nBIAS = NA
  df.summary.mean
  
  #Process the data per unique combination of compare_columns
  for(i in 1:length(df.summary.mean[,1])){
    for(g in 1:length(compare_columns)){
      if(g == 1){
        selection_data = as.character(df.stat[,compare_columns[g]]) == as.character(df.summary.mean[i,compare_columns[g]])
      }else{
        selection_new = as.character(df.stat[,compare_columns[g]]) == as.character(df.summary.mean[i,compare_columns[g]])
        selection_data = selection_data + selection_new
      }
    }
    subset_df = df.stat[selection_data == length(compare_columns),]
    
    #Calculate SD per tiemstap and nBIAS + nuRMSD for each compare_columns combination
    sd_calc = ((subset_df[,"observed"] - mean(subset_df[,"observed"])) - (subset_df[,"modelled"] - mean(subset_df[,"modelled"])))^2
    nBIAS = (mean(subset_df$modelled) - mean(subset_df$observed))/sd(subset_df$observed)
    nuRMSD = (sqrt(mean(sd_calc))*sign(sd(subset_df$modelled)-sd(subset_df$observed)))/sd(subset_df$observed)
    
    if(i == 1){
      list_nBIAS = nBIAS
      list_nuRMSD = nuRMSD
    }else{
      list_nBIAS = c(list_nBIAS,nBIAS)
      list_nuRMSD = c(list_nuRMSD,nuRMSD)
    }
  }
  
  #Add computed data
  df.summary.mean$nuRMSD = list_nuRMSD 
  df.summary.mean$nBIAS = list_nBIAS 
  
  return(df.summary.mean)
}

TargetDiagramV1 <- function(model = "model", substance ,location, date, sim_value,
              obs_value,ref = NULL, color = NULL, cex = 1){
  ## ================================================================##
  ##                                                                 ##
  ##  Example script for target diagram                              ##
  ##  By Willem.Stolte@Deltares.nl                                   ##
  ##  Slightly editted by Marc.Weeber@Deltares.nl                    ##
  ##=================================================================##
      
  ##Select information for best fit
  library("lattice")
  library("solaR")
      
  df_data = data.frame(model = as.vector(model), substance = as.vector(substance), 
                       location = as.vector(location), date, value.y = sim_value, value.x = obs_value)
      
  summerhalfyear <-data.frame(month = month(date))
  summerhalfyear$season[summerhalfyear$month >3 & summerhalfyear$month <= 9] <- "summer"
  summerhalfyear$season[summerhalfyear$month >9 & summerhalfyear$month <= 12] <- "winter"
  summerhalfyear$season[summerhalfyear$month >=1 & summerhalfyear$month <= 3] <- "winter"
        
  df_data$season = as.vector(summerhalfyear$season)
      
  df.target <- make.target.table3(compare_columns = c("model","substance","location","season"),
                           df.stat = df_data, val_obs = "value.x", val_mod = "value.y")
	
	## Make a unity circle with diameter 2 and center at 0,0
	circleFun <- function(center = c(0,0),diameter = 1, npoints = 100){
	  r = diameter / 2
	  tt <- seq(0,2*pi,length.out = npoints)
	  xx <- center[1] + r * cos(tt)
    yy <- center[2] + r * sin(tt)
	  return(data.frame(x = xx, y = yy))
	}
      
	df.circle <- cbind(circleFun(c(0,0),2,npoints = 100), circleFun(c(0,0),2*0.67,npoints = 100)) 
  colnames(df.circle) = c("x1","y1","x2","y2")

  ## Plot targetdiagram voor all groups
  library(ggplot2)
                       
  ecolsel<-df.target$substance %in% substance
  df.target3<-df.target[ecolsel,]
        
  scale=c(-3,3)
  q <- ggplot(df.target3,aes(nuRMSD,nBIAS)) + 
  geom_point(aes(color=location),size=4) + 
  geom_path(data=df.circle,aes(x1,y1)) +
  geom_path(data=df.circle,aes(x2,y2)) +
  xlim(scale) + ylim(scale) + 
  facet_grid(season ~ substance + model,scales="free") +
  #  theme_classic(base_size = 14, base_family = "") +
  theme(aspect.ratio = 1) +
  theme(panel.grid.major = element_line(colour = "darkgrey")) +
  theme(legend.position = "right")
        
  print(q)
  result <- list(plot = q, stat = df.target)
  return(df.target)    
}

TargetDiagramV2 <- function (model = "model", substance ,location, date, sim_value,
                             obs_value,ref = NULL, color = NULL, cex = 1){
  # Partly borrowed from "solaR"
  
  library("lattice")
  
  df_data = data.frame(model = as.vector(model), substance = as.vector(substance), 
                       location = as.vector(location), date, value.y = sim_value, value.x = obs_value)
  
  df.target <- make.target.table3(compare_columns = c("model","substance","location"), df.stat = df_data, val_obs = "value.x", val_mod = "value.y")
  
  df.target = df.target[order(df.target$location),]
  
  Unitfc = factor(df.target$location)
  NDaysfc <- factor(df.target$location)
  Radio <- c(1,0.67)
  Circ <- expand.grid(Theta = seq(0, 2 * pi, length = 100), 
                      R = Radio)
  Circ$X <- with(Circ, R * sin(Theta))
  Circ$Y <- with(Circ, R * cos(Theta))
  my.pch = 1:nlevels(Unitfc)
  
  if (is.null(color)) {
    p <- xyplot(nBIAS ~ nuRMSD | model, data = df.target, 
                cex = cex, xlab = "nuRMSD", ylab = "nBias", ylim = c(-2,2),xlim = c(-2,2),
                aspect = "iso", 
                panel = function(x, y, cex = cex) {
                      col = my.fill[NDaysfc]
                      panel.xyplot(x,y, pch = c(1:16)[1:length(unique(df.target$location))], cex = 1, col = "black")
                      panel.abline(h = 0, v = 0, lty = 2, col = "gray")
                      for (i in 1:4) {
                            with(Circ, panel.xyplot(X[R == Radio[i]], Y[R == 
                            Radio[i]], lty = 2, type = "l", col = "grey"))
                      }
                      panel.text(x = Radio, y = 0, labels = signif(Radio, 
                                                               2), pos = 4, cex = 0.8)
                }, key = list(space = "right", adj = 1, title = "location", 
                             text = list(levels(NDaysfc)), points = list(pch = c(1:16)[1:length(unique(df.target$location))], 
                                                                         col = "black"), rep = FALSE))
  }else{
      my.fill = color 
      my.fill[NDaysfc]
      p <- xyplot(nBIAS ~ nuRMSD | model, data = df.target, 
                  cex = cex, xlab = "nuRMSD", ylab = "nBIAS", ylim = c(-2,2),xlim = c(-2,2),
                  aspect = "iso", 
                  panel = function(x, y, cex = cex) {
                    col = my.fill[NDaysfc]
                    panel.xyplot(x,y, pch = c(1:16)[1:length(unique(df.target$location))], cex = 1, col = col)
                    panel.abline(h = 0, v = 0, lty = 2, col = "gray")
                    for (i in 1:4) {
                      with(Circ, panel.xyplot(X[R == Radio[i]], Y[R == 
                        Radio[i]], lty = 2, type = "l", col = "grey"))
                    }
                    panel.text(x = Radio, y = 0, labels = signif(Radio, 
                                                                 2), pos = 4, cex = 0.8)
                  }, key = list(space = "right", adj = 1, title = "scenario", 
                                text = list(levels(NDaysfc)), points = list(pch = c(1:16)[1:length(unique(df.target$location))], 
                                                                            col = my.fill), rep = FALSE))
  }
  print(p)
  result <- list(plot = p, stat = df.target)
  return(df.target)
}

      
################################

################################
###Taylor Diagram

      
TaylorDiagram <- function(model = "model", substance ,location, date, sim_value,
                          obs_value, color = NULL, cex = 0.8){
  #partly taken from http://svitsrv25.epfl.ch/R-doc/library/plotrix/html/taylor.diagram.html
  
  library("plotrix")
  
  total <- data.frame(model, substance, location ,observed_value = obs_value,simulated_value = sim_value,
                      stringsAsFactors = FALSE)
  
  list_largest = aggregate(abs(total$observed_value - total$simulated_value), by = data.frame(location),sum) 
  list_largest = list_largest[order(-list_largest$x),]
  list_largest$location = as.character(list_largest$location)
  
  #Get correlation of locations
  for(i in 1:length(list_largest$location)){
    correlation = cor(total$observed_value[total$location == list_largest$location[i]],
                      total$simulated_value[total$location == list_largest$location[i]])
    
    if(exists("list_correlation")){
      list_correlation = c(list_correlation, correlation)
    }else{
      list_correlation = correlation
    }
  }
  
  if(TRUE %in% (list_correlation < 0)){part_plot = FALSE}else{part_plot = TRUE}
  
  # plot model estimate
  for(i in 1:length(list_largest$location)){
    if(i == 1){
      taylor.diagram(pos.cor= part_plot, ref = total$observed_value[total$location == list_largest$location[i]],
                     model = total$simulated_value[total$location == list_largest$location[i]],
                     col = color[i], normalize = T)
    }else{
      taylor.diagram(pos.cor= part_plot, ref = total$observed_value[total$location == list_largest$location[i]],
                     model = total$simulated_value[total$location == list_largest$location[i]],
                     col = color[i], add=TRUE, normalize = T)
    }
  }
  
  #Get axes length to place legend
  axes_length = par("usr")
  
  if(part_plot == TRUE){
    multiplier1 = 0.925
    multiplier2 = 1
  }else{
    multiplier1 = 0.61
    multiplier2 = 1
  }
  
  pos1 = axes_length[2] * multiplier1 
  pos2 = axes_length[4] * multiplier2
  
  # add a legend
  legend(pos1,pos2,legend=list_largest$location,pch= rep(19,length(total$location)),col=c(color), cex = cex)
}       
      
###EXTRA############################


################################
## Root mean squere error
rmse<-function(observed_value,simulated_value){
  tot <- cbind(observed_value,simulated_value)
  tot <- na.omit(tot)
  rmserror <-sqrt( sum((tot$observed_value - tot$simulated_value)^2) / length(tot$observed_value))
  return(rmserror)
}
################################

################################
#Force datetime values towards date values
AverageValuesOverDate <- function(origin,datetime,value){
  
  unique_origins = unique(origin)
  
  #asses the data per origin
  for(t in 1:length(unique_origins)){
    
    #seperate per origin 
    subset_datetime = datetime[origin == unique_origins[t]]
    
    #Convert to date (even for leaptime)
    date = strptime(as.character(as.Date(subset_datetime)),format = "%Y-%m-%d")
    if(TRUE %in% is.na(date)){
      date[is.na(date)] = as.POSIXct.no.dst(as.character(as.Date(datetime))[is.na(date)], 
                                                              format = "%y%y-%m-%d")    
    }
      
    dupl_times = datetime[grep("TRUE",duplicated(subset_datetime))]
    dupli_dates = as.Date(dupl_times)
    
    #remove duplicated dates from data
    unique_dupli_dates = unique(dupli_dates)
    
    selection_clean = !(date %in% unique_dupli_dates)
    date_clean = date[selection_clean]
    value_origin = value[origin == unique_origins[t]]
    value_clean = value_origin[selection_clean]
    
    if(length(unique_dupli_dates) > 0){
      #add average of duplicated date
      for(i in 1:length(unique_dupli_dates)){
        selection_dupli_date
        unique_dupli_dates[i]
        date
        value_origin[selection_dupli_date]
        selection_dupli_date = (date == unique_dupli_dates[i])
        averaged = mean(value_origin[selection_dupli_date])
        date_clean = c(date_clean,unique_dupli_dates[i])
        value_clean = c(value_clean,averaged)
      }
      #order on date
      value_comp = value_clean[sort(date_clean)]
      date_comp = sort(date_clean)
    }else{
      value_comp = value_clean
      date_comp = date_clean
    }
    
    #Add all the data back together
    if(t==1){
      collected_date = date_comp
      collected_value = value_comp
    }else{
      collected_date = c(collected_date,date_comp)
      collected_value = c(collected_value,value_comp)
    }
  }
  
  collected_date
  collected_value
  
  return(list(collected_date,collected_value))
}
################################




