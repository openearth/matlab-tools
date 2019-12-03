#################################################
#Model_Referance : Validation Model
#By: Marc Weeber
#################################################


#---get workdirectory--------------------
setwd("..")
workdirectory = getwd()


#---import functions---------------------
source('1_R_scripts/R_functions_for_Betrouwbaarheid_modellen.R',chdir = T)


#---import settings----------------------
settings_dataframe = ReadInputFile("2_Modelled_data/settings.inp")

#Add configuration
delimiter = settings_dataframe[grep("delimiter",settings_dataframe[,1]),2]
observation_as_date = as.logical(settings_dataframe[grep("observation_as_date",settings_dataframe[,1]),2])
observation_forced_as_date = as.logical(settings_dataframe[grep("observation_forced_as_date",settings_dataframe[,1]),2])
search_window_sec = as.numeric(settings_dataframe[grep("search_window_sec",settings_dataframe[,1]),2])
search_window_bestfit_sec = as.numeric(settings_dataframe[grep("search_window_bestfit_sec",settings_dataframe[,1]),2])
search_window_averaged_sec = as.numeric(settings_dataframe[grep("search_window_averaged_sec",settings_dataframe[,1]),2])
ignore_tests = as.logical(settings_dataframe[grep("ignore_tests",settings_dataframe[,1]),2])

#---set libraries------------------------
library("stringr")
library("chron")


#---find model results--------------------
files_modelled = list.files(path = paste(workdirectory,"/2_Modelled_data/",sep = ""))


#---get mapping files---------------------

locations_csv = "list_of_locations_linked.csv"
variables_csv = "list_of_variables_linked.csv"




#########START SCRIPT######################

setwd(paste(workdirectory,"/2_Modelled_data/",sep = ""))

# Load coupling locations
if(locations_csv %in% files_modelled){
  list_locations_csv = read.csv(locations_csv, sep = delimiter,stringsAsFactors = FALSE)
}else{
  stop(print("List_of_locations_linked.csv is missing in '2.Modelled_data'"))
}

# Load coupling locations
if(variables_csv %in% files_modelled){
  list_variables_csv = read.csv(variables_csv, sep = delimiter,stringsAsFactors = FALSE)
}else{
  stop(print("List_of_variables_linked.csv is missing in '2.Modelled_data'"))
}

#Check and remake mapping tables
collect_mapping = CreateMappingTable(list_locations_csv,list_variables_csv)
list_locations = data.frame(collect_mapping[1],stringsAsFactors = FALSE)
list_locations_comp = data.frame(collect_mapping[2],stringsAsFactors = FALSE)
list_variables = data.frame(collect_mapping[3],stringsAsFactors = FALSE)
list_variables_comp = data.frame(collect_mapping[4],stringsAsFactors = FALSE)

File_variable_list = FileVariableList(list_variables,list_variables_comp)

#-----invoer gegevens HIS--------------------

selection_hisfiles <- grep(".his",files_modelled)

#Check if HIS file is present
if(length(selection_hisfiles) == 0){
  stop(print("There is no his file present in the folder '2. Modelled data'!"))
}

files_his = files_modelled[selection_hisfiles]

# Prepare search windows
search_window_d = (search_window_sec / (24*60*60))
search_window_bestfit_d = (search_window_bestfit_sec / (24*60*60))
search_window_averaged_d = (search_window_averaged_sec / (24*60*60))

###############
#HIS data
for(i in 1:length(files_his)){
  
  setwd(paste(workdirectory,"/2_Modelled_data/",sep = ""))
  
  # Get HIS FILE
  extract_his_temp = LoadHisFile(files_his[i],paste(workdirectory,"/2_Modelled_data/",sep = ""))
  extract_save_his = extract_his_temp[1]
  extract_set1 = as.vector(unlist(extract_his_temp[2]))
  year_nr = unlist(extract_his_temp[3])
  
  file_nc_cor = File_variable_list[,3]
  
  ###############
  #Loop per MWTL substance
  for(s in 1:length(file_nc_cor)){
    
    setwd(paste(workdirectory,"/3_Reference_data",sep = ""))
    
    # Read and progress NetcDF's, CSV files and Combines
    save_dataframe_new <- PrepareMeas(File_variable_list[s,],list_variables_comp,
                                  list_locations_comp,file.path(workdirectory,"/3_Reference_data"))
    unit_for_plot = unique(save_dataframe_new$unit)
    file_name = File_variable_list[s,3]
    
    # Progress simulated HIS and Combines
    simulated_set = ProgressHisData(File_variable_list[s,], list_variables_comp, list_locations_comp, extract_set1, extract_save_his)
    
    # Remove -999 values from simulated_set
    simulated_set <- simulated_set[simulated_set$value != -999,]
    
    #############
    #Create folder structure
    
    #Clean up
    if(exists("mainDir")){rm(list = c("mainDir"))}else{}
    if(exists("subDir")){rm(list = c("subDir"))}else{}
    
    ####Write all results to the following folder
    mainDir = paste(workdirectory,"/4_Results",sep = "")
    subDir  = files_his[i]
    dir.create(file.path(mainDir , subDir), showWarnings = FALSE)
    setwd(file.path(mainDir, subDir))
    
    #####Write all results to the following folder
    mainDir = getwd()
    subDir  = "Validation analyses"
    dir.create(file.path(mainDir , subDir), showWarnings = FALSE)
    setwd(file.path(mainDir, subDir))
    
    ####Write all results to the following folder
    mainDir = getwd()
    subDir  = file_name
    dir.create(file.path(mainDir , subDir), showWarnings = FALSE)
    setwd(file.path(mainDir, subDir))
    
    
    ########################
    #Prepare data per substance
    
    #Data analysis
    data_set <- save_dataframe_new[!(is.na(save_dataframe_new$value)),] 
    
    #Go to next if no data
    if(length(data_set[,1]) == 0){next}
    
    # Place a selection
    name    = file_name
    y_label = "concentration"
    x_label = "date"
    
    observed_value = as.numeric(data_set$value)
    
    #Get date and time
    collect_time_obs = GetDateOrDateTime(as.character(data_set$time))
    date_obs = do.call(c,collect_time_obs[1])
    format_strptime_obs = unlist(collect_time_obs[2])
    
    ###ERROR prevention###
    #Some how the date can switch to hours with do.call
    #This is solved here
    if(format_strptime_obs == "date"){
      date_obs = trunc(date_obs,"days")
    }    
    
    #####################################################################
    #Restriction to data from 1980
    observed_value = observed_value[date_obs >= strptime("1980-01-01", format = "%y%y-%m-%d")]
    data_set       = data_set[date_obs >= strptime("1980-01-01", format = "%y%y-%m-%d"),]
    date_obs           = date_obs[date_obs >= strptime("1980-01-01", format = "%y%y-%m-%d")]
    ######################################################################
    
    group = "Observed"
    origin = data_set$location_name
    aggregate_list = data_set[,c("platform_id","platform_name","lon","lat","wgs_84","epsg","x","y","z")]
    
    simulated_value = as.numeric(simulated_set$value)
    
    #Get date and time of sim
    collect_time_sim = GetDateOrDateTime(as.character(simulated_set$datesim))
    date_sim = do.call(c,collect_time_sim[1])
    format_strptime_sim = unlist(collect_time_sim[2])
        
    ###ERROR prevention###
    #Some how the date can switch to hours with do.call
    #This is solved here
    if(format_strptime_sim == "date"){
      date_sim = trunc(date_sim,"days")
    }  
    
    group_sim = "Simulated"
    origin_sim = as.character(simulated_set$variable)
    aggregate_list_sim = simulated_set[,c("variable")]

    #Remove for a clean start
    if(exists("data_save_obs")){rm(list = c("data_save_obs"))}else{}
    if(exists("data_save_sim")){rm(list = c("data_save_sim"))}else{}
    if(exists("save_dec")){rm(list = c("save_dec"))}else{}
    
    ##PREFORM TIME CORRECTIONS
    
    #Check if sim is date and depicted as datetime
    #    Relevant for NetCDF files (can be switched on and Off)
    if(format_strptime_sim == "date"){
      date_sim_new = strptime(as.character(as.Date(date_sim)),format = "%Y-%m-%d")
      if(TRUE %in% is.na(date_sim_new)){
        date_sim_new[is.na(date_sim_new)] = as.POSIXct.no.dst(as.character(as.Date(date_sim))[is.na(date_sim_new)], 
                                                              format = "%y%y-%m-%d")
      }
      date_sim <-date_sim_new
    }
    
    # Check if datetime format is acctually date
    #     Relevant for NetCDF files (can be switched on and Off)
    date_obs_length = length(unique(cbind(as.character(as.Date(date_obs)),origin))[,1])
    if((length(date_obs) == date_obs_length) & observation_as_date){
      format_strptime_obs <- "date"
      date_obs_new = strptime(as.character(as.Date(date_obs)),format = "%Y-%m-%d")
      if(TRUE %in% is.na(date_obs_new)){
        date_obs_new[is.na(date_obs_new)] = as.POSIXct.no.dst(as.character(as.Date(date_obs))[is.na(date_obs_new)], 
                                                              format = "%y%y-%m-%d")
      }
      date_obs <- date_obs_new
    }
    
    # Check if datetime should be forced to date values
    #
    if(format_strptime_obs == "date_time" & observation_forced_as_date){
      observed_temp = AverageValuesOverDate(origin,date_obs,observed_value)
      date_obs = observed_temp[1][[1]]
      observed_value = unlist(observed_temp[2])
      format_strptime_obs <- "date"
    }

    #Check formats sim and obs
    if(!(format_strptime_sim == format_strptime_obs)){
      stop(print(paste("Time format of measurement and simulation differs: date_sim = ",
                       format_strptime_sim," and date_obs = ",format_strptime_obs,"!", sep = "")))
    }
    
    
    ###################
    #Analyse per location
    for(d in 1:length(list_locations[,2])){
      
      ####################
      #Create location folder
      
      ##Clean up
      if(exists("mainDir")){rm(list = c("mainDir"))}else{}
      if(exists("subDir")){rm(list = c("subDir"))}else{}
      
      old <- paste(workdirectory,"/4_Results/",files_his[i],"/Validation analyses/",file_name,sep = "")
      
      ##Create folder
      mainDir = old
      subDir  = as.character(list_locations[d,3])
      dir.create(file.path(mainDir , subDir), showWarnings = FALSE)
      setwd(file.path(mainDir, subDir))
      
      #######################
      #Prepare data per location
      
      observed_value_sub     =  observed_value[as.character(origin) == as.character(list_locations[d,2])]
      date_obs_sub           =  date_obs[as.character(origin) == as.character(list_locations[d,2])]
      
      simulated_value_sub    =  simulated_value[as.character(origin_sim) == as.character(list_locations[d,1])]
      date_sim_sub           =  date_sim[as.character(origin_sim) == as.character(list_locations[d,1])]
      
      observed_value_dec     = observed_value_sub[date_obs_sub > strptime(paste(year_nr-5,"-01-01",sep = ""), format = "%y%y-%m-%d") &
                                                    date_obs_sub < strptime(paste(year_nr+5,"-01-01",sep = ""), format = "%y%y-%m-%d")]
      date_obs_dec           = date_obs_sub[date_obs_sub > strptime(paste(year_nr-5,"-01-01",sep = ""), format = "%y%y-%m-%d") &
                                              date_obs_sub < strptime(paste(year_nr+5,"-01-01",sep = ""), format = "%y%y-%m-%d")]
      
      observed_value_sub_year     = observed_value_sub[date_obs_sub >= strptime(paste(year_nr,"-01-01",sep = ""), format = "%y%y-%m-%d") &
                                                         date_obs_sub < strptime(paste(year_nr+1,"-01-01",sep = ""), format = "%y%y-%m-%d")]
      date_obs_sub_year           = date_obs_sub[date_obs_sub >= strptime(paste(year_nr,"-01-01",sep = ""), format = "%y%y-%m-%d") &
                                                   date_obs_sub < strptime(paste(year_nr+1,"-01-01",sep = ""), format = "%y%y-%m-%d")]

     # Create Normal fit
      
     locations_obs_year = rep(as.character(list_locations[d,1]),length(observed_value_sub_year))
     locations_sim_year = rep(as.character(list_locations[d,1]),length(simulated_value_sub))
     normal_fit_data = NormalFitData(comp_obs_origin = locations_obs_year, comp_obs_value = observed_value_sub_year,
                                     comp_obs_date = date_obs_sub_year, comp_sim_origin = locations_sim_year, 
                                     comp_sim_value = simulated_value_sub, comp_sim_date = date_sim_sub,
                                     range_day = search_window_d)
        
     normal_fit_data <- na.omit(normal_fit_data)
        
     write.table(normal_fit_data,paste("Used_normal_fit_data_",list_locations[d,1],"_",name,".csv",sep=""),sep = ";",quote = FALSE, row.names = FALSE)
     
     #Test if Normal fit was filled
     if(length(colnames(normal_fit_data)) != 0){
       
       observed_value_sub_new   = normal_fit_data$obs_value
       date_obs_sub_new         = normal_fit_data$obs_date
       
       simulated_value_sub_new  = normal_fit_data$norm_fit_sim
       date_sim_sub_new         = normal_fit_data$obs_date
       
       #Save decade data
       if(!(exists("save_dec"))){save_dec = data.frame(location = rep(paste(as.character(list_locations[d,1])), length(observed_value_dec)), date = date_obs_dec, observed_value_dec)
       }else{ save_dec = rbind(save_dec, data.frame(location = rep(paste(as.character(list_locations[d,1])), length(observed_value_dec)), date = date_obs_dec, observed_value_dec) )
       }
       
       #Test if the location exists in the HIS file
       if(length(simulated_value_sub) == 0 & ignore_tests == FALSE){
         stop(print(paste("The location ",as.character(list_locations[d,1])," does not exists for ",file_name,"in the .his file",sep = "")))
       }
       
       # Check for amount of data when matched in time
       if(length(simulated_value_sub_new) == 1 & ignore_tests == FALSE){
         stop(print(paste("The location ",as.character(list_locations[d,1]),
                          " has only one value as match between simulated and measured ",
                          file_name,"! This is to low for statistics. Try increasing the search_window_sec.",sep = "")))
       }
       
       #######################
       #Preform analysis per location
       
       
       # NashSutcliff
       result1 <- NashSutcliff(observed_value = observed_value_sub_new ,simulated_value = simulated_value_sub_new)
       head(result1)
       write.table(result1,paste("NashSutcliff_",name,".csv",sep=""),sep = ";",quote = FALSE, row.names = FALSE)
       
       # PercentageModelBias
       result2 <- PercentageModelBias(observed_value = as.vector(observed_value_sub_new) ,simulated_value = as.vector(simulated_value_sub_new))
       head(result2)
       write.table(result2,paste("PercentageModelBias_",name,".csv",sep=""),sep = ";",quote = FALSE, row.names = FALSE)
       
       # Skew referentie data
       result4 <- Skew(data_value = observed_value_sub_new)
       head(result4)
       write.table(result4,paste("SkewObsdata_",name,".csv",sep=""),sep = ";",quote = FALSE, row.names = FALSE)
       
       #Skew model data
       result3 <- Skew(data_value = simulated_value_sub_new)
       head(result3)
       write.table(result3,paste("SkewSimdata_",name,".csv",sep=""),sep = ";",quote = FALSE, row.names = FALSE)
       
       #Cost function
       result5 <- Costfunction(observed_value_sub_new,simulated_value_sub_new)
       head(result4)
       write.table(result4,paste("CostFunction__",name,".csv",sep=""),sep = ";",quote = FALSE, row.names = FALSE)
       
       #R squared
       result6 <- Rsquared(observed_value_sub_new,simulated_value_sub_new)
       head(result6)
       write.table(result6,paste("Rsquared__",name,".csv",sep=""),sep = ";",quote = FALSE, row.names = FALSE)
       
       if(file_name == "Chlorophyl-A"){
         
         #Check for Lower than zero chlorofyll-A levels
         if(min(c(simulated_value_sub,simulated_value_sub_new), na.rm = TRUE) < 0){ 
           warning(print("Chlorofyll A levels lower than zero, zero assumed"))
           simulated_value_sub[simulated_value_sub < 0] <- 0
           simulated_value_sub_new[simulated_value_sub_new < 0] <- 0
         }else{}
         
         #Log tranform the data
         observed_value_log            = log(observed_value + 1)
         observed_value_sub_log        = log(observed_value_sub + 1)
         observed_value_sub_year_log   = log(observed_value_sub_year + 1)
         observed_value_sub_new_log    = log(observed_value_sub_new + 1)
         simulated_value_sub_log       = log(simulated_value_sub + 1)
         simulated_value_sub_new_log   = log(simulated_value_sub_new + 1)
         
         # CorrelationCoefficient
         jpeg(filename = paste("CorrelationCoefficient_", name,".jpg",sep = ""), width = 600, height = 480, units = "px",type = "windows")
         print({CorrelationCoefficient(observed_value = observed_value_sub_new_log ,simulated_value = simulated_value_sub_new_log)})
         dev.off()
         
         library("gplots")
         current_location_obs = rep(as.character(list_locations[d,3]), length(observed_value_sub_year_log))
         current_location_sim = rep(as.character(list_locations[d,3]), length(simulated_value_sub_log))
         
         #Best fit data
         best_fit_data = BestFitData(comp_obs_origin = current_location_obs, comp_obs_value = observed_value_sub_year_log,
                                     comp_obs_date = date_obs_sub_year, comp_sim_origin = current_location_sim, 
                                     comp_sim_value = simulated_value_sub_log, comp_sim_date = date_sim_sub,
                                     range_day = search_window_bestfit_d)
         
         write.table(best_fit_data,paste("Used_best_fit_data_",list_locations[d,1],"_",name,"_log_transformed.csv",sep=""),sep = ";",quote = FALSE, row.names = FALSE)
         
         #Average fit data
         average_data = AverageData(comp_obs_origin = current_location_obs, comp_obs_value = observed_value_sub_year_log,
                                    comp_obs_date = date_obs_sub_year, comp_sim_origin = current_location_sim, 
                                    comp_sim_value = simulated_value_sub_log, comp_sim_date = date_sim_sub,
                                    range_day = search_window_averaged_d)
         
         write.table(average_data,paste("Used_average_data_",list_locations[d,1],"_",name,"_log_transformed.csv",sep=""),sep = ";",quote = FALSE, row.names = FALSE)
         
         
       }else{
         
         # CorrelationCoefficient
         jpeg(filename = paste("CorrelationCoefficient_", name,".jpg",sep = ""), width = 600, height = 480, units = "px",type = "windows")
         print({CorrelationCoefficient(observed_value = observed_value_sub_new ,simulated_value = simulated_value_sub_new)})
         dev.off()
         
         library("gplots")
         current_location_obs = rep(as.character(list_locations[d,3]), length(observed_value_sub_year))
         current_location_sim = rep(as.character(list_locations[d,3]), length(simulated_value_sub))
         
         #Best fit data
         best_fit_data = BestFitData(comp_obs_origin = current_location_obs, comp_obs_value = observed_value_sub_year,
                                     comp_obs_date = date_obs_sub_year, comp_sim_origin = current_location_sim, 
                                     comp_sim_value = simulated_value_sub, comp_sim_date = date_sim_sub,
                                     range_day = search_window_bestfit_d)
         
         write.table(best_fit_data,paste("Used_best_fit_data_",list_locations[d,1],"_",name,".csv",sep=""),sep = ";",quote = FALSE, row.names = FALSE)
         
         #Average fit data
         average_data = AverageData(comp_obs_origin = current_location_obs, comp_obs_value = observed_value_sub_year,
                                    comp_obs_date = date_obs_sub_year, comp_sim_origin = current_location_sim, 
                                    comp_sim_value = simulated_value_sub, comp_sim_date = date_sim_sub,
                                    range_day = search_window_averaged_d)
         
         write.table(average_data,paste("Used_average_data_",list_locations[d,1],"_",name,".csv",sep=""),sep = ";",quote = FALSE, row.names = FALSE)
         
       }
       
       if(!(class(best_fit_data) == "character" & class(average_data) == "character")){
         
         #Give aditional information for plot
         best_fit_substance = rep(file_name,length(best_fit_data$origin))
         best_fit_color = rainbow(length(unique(list_locations[d,3])))
         average_substance = rep(file_name,length(average_data$origin))
         average_color = rainbow(length(unique(list_locations[d,3])))                            
         
         #TargetDiagram
         
         ## TargetDiagramV1BF
         jpeg(filename = paste("TargetDiagramV1BF_", name,".jpg",sep = ""), width = 600, height = 480, units = "px",type = "windows")
         print({TargetDiagramV1(model = "model", substance = best_fit_substance ,location = best_fit_data$origin
                                , date = best_fit_data$obs_date, sim_value = best_fit_data$best_fit_sim,
                                obs_value = best_fit_data$obs_value,ref = NULL, color = best_fit_color)})
         dev.off()                       
         
         result1t <- TargetDiagramV1(model = "model", substance = best_fit_substance ,location = best_fit_data$origin
                                     , date = best_fit_data$obs_date, sim_value = best_fit_data$best_fit_sim,
                                     obs_value = best_fit_data$obs_value,ref = NULL, color = best_fit_color)
         head(result1t)
         write.table(result1t,paste("TargetTableV1BF__",name,".csv",sep=""),sep = ";",quote = FALSE, row.names = FALSE)
         
         
         ## TargetDiagramV2BF
         jpeg(filename = paste("TargetDiagramV2BF_", name,".jpg",sep = ""), width = 600, height = 480, units = "px",type = "windows")
         print({TargetDiagramV2(model = "model", substance = best_fit_substance ,location = best_fit_data$origin
                                , date = best_fit_data$obs_date, sim_value = best_fit_data$best_fit_sim,
                                obs_value = best_fit_data$obs_value,ref = NULL, color = best_fit_color)})
         dev.off()
         
         result2t <- TargetDiagramV2(model = "model", substance = best_fit_substance ,location = best_fit_data$origin
                                     , date = best_fit_data$obs_date, sim_value = best_fit_data$best_fit_sim,
                                     obs_value = best_fit_data$obs_value,ref = NULL, color = best_fit_color)
         head(result2t)
         write.table(result2t,paste("TargetTableV2BF__",name,".csv",sep=""),sep = ";",quote = FALSE, row.names = FALSE)
         
         ## TargetDiagramV1M
         jpeg(filename = paste("TargetDiagramV1M_", name,".jpg",sep = ""), width = 600, height = 480, units = "px",type = "windows")
         print({TargetDiagramV1(model = "model", substance = average_substance ,location = average_data$origin
                                , date = average_data$obs_date, sim_value = average_data$average_sim,
                                obs_value = average_data$obs_value,ref = NULL, color = average_color)})
         dev.off()
         
         result3t <- TargetDiagramV1(model = "model", substance = average_substance ,location = average_data$origin
                                     , date = average_data$obs_date, sim_value = average_data$average_sim,
                                     obs_value = average_data$obs_value,ref = NULL, color = average_color)
         head(result3t)
         write.table(result3t,paste("TargetTableV1M__",name,".csv",sep=""),sep = ";",quote = FALSE, row.names = FALSE)
         
         ## TargetDiagramV2M
         jpeg(filename = paste("TargetDiagramV2M_", name,".jpg",sep = ""), width = 600, height = 480, units = "px",type = "windows")
         print({TargetDiagramV2(model = "model", substance = average_substance ,location = average_data$origin
                                , date = average_data$obs_date, sim_value = average_data$average_sim,
                                obs_value = average_data$obs_value,ref = NULL, color = average_color)})
         dev.off()
         
         result4t <- TargetDiagramV2(model = "model", substance = average_substance ,location = average_data$origin
                                     , date = average_data$obs_date, sim_value = average_data$average_sim,
                                     obs_value = average_data$obs_value,ref = NULL, color = average_color)
         head(result4t)
         write.table(result4t,paste("TargetTableV2M__",name,".csv",sep=""),sep = ";",quote = FALSE, row.names = FALSE)
         
         
         
         #TaylorDiagram
         best_fit_data <- na.omit(best_fit_data)
         if(length(best_fit_data[,1] > 1)){
           jpeg(filename = paste("TaylorDiagramBF_", name,".jpg",sep = ""), width = 600, height = 480, units = "px",type = "windows")
           print({TaylorDiagram(model = "model", substance = best_fit_substance ,location = best_fit_data$origin,
                                date = best_fit_data$obs_date, sim_value = best_fit_data$best_fit_sim,
                                obs_value = best_fit_data$obs_value, color = best_fit_color, cex = 0.8)})
           dev.off()
         }
         
         average_data <- na.omit(average_data)
         if(length(average_data[,1] > 1)){
           jpeg(filename = paste("TaylorDiagramM_", name,".jpg",sep = ""), width = 600, height = 480, units = "px",type = "windows")
           print({TaylorDiagram(model = "model", substance = average_substance ,location = average_data$origin,
                                date = average_data$obs_date, sim_value = average_data$average_sim,
                                obs_value = average_data$obs_value, color = average_color, cex = 0.8)})
           dev.off()
         }
         
         #Save observed data versus sim
         if(!(exists("data_save_obs"))){data_save_obs = data.frame(location = rep(as.character(list_locations[d,1]),length(observed_value_sub_new)),
                                                                   date = date_obs_sub_new,observed_value_sub_same = observed_value_sub_new)}else{
                                                                     data_save_obs = rbind(data_save_obs,data.frame(location = rep(as.character(list_locations[d,1]),length(observed_value_sub_new)),
                                                                                                                    date = date_obs_sub_new,observed_value_sub_same = observed_value_sub_new))
                                                                   }
         if(!(exists("data_save_sim"))){data_save_sim = data.frame(location = rep(as.character(list_locations[d,1]),length(simulated_value_sub_new)),
                                                                   date = date_sim_sub_new,simulated_value_sub_same = simulated_value_sub_new)}else{
                                                                     data_save_sim = rbind(data_save_sim,data.frame(location = rep(as.character(list_locations[d,1]),length(simulated_value_sub_new)),
                                                                                                                    date= date_sim_sub_new,simulated_value_sub_same = simulated_value_sub_new))
                                                                   }                                                          
         
         # Output Table
         
         DF_output = data.frame(NS = c("*",as.character(result1)), Model_bias = c("*", as.character(result2)), 
                                Costfunction = c("*",as.character(result5)), Skew = c(result4,result3), 
                                R_squared = c("*",as.character(result6)))
         DF_output = t(DF_output)
         colnames(DF_output) <- c("Obs",as.character(year_nr))
         write.csv(DF_output,paste("DataframeOutput__",name,".csv",sep=""))                                                                        
       }else{}
      }else{}                                      
    }
    setwd(old)
    
    # Test if data was stored for complete analysis
    if(!(exists("data_save_obs"))){next}else{}
    if(!(exists("data_save_sim"))){next}else{}
    
    # NashSutcliff
    result1 <- NashSutcliff(observed_value = data_save_obs$observed_value_sub_same ,simulated_value = data_save_sim$simulated_value_sub_same)
    head(result1)
    write.table(result1,paste("NashSutcliff_",name,".csv",sep=""),sep = ";",quote = FALSE, row.names = FALSE)
    
    # PercentageModelBias
    result2 <- PercentageModelBias(observed_value = data_save_obs$observed_value_sub_same ,simulated_value = data_save_sim$simulated_value_sub_same)
    head(result2)
    write.table(result2,paste("PercentageModelBias_",name,".csv",sep=""),sep = ";",quote = FALSE, row.names = FALSE)
    
    #Cost function
    result5 <- Costfunction(data_save_obs$observed_value_sub_same,data_save_sim$simulated_value_sub_same)
    head(result4)
    write.table(result4,paste("CostFunction__",name,".csv",sep=""),sep = ";",quote = FALSE, row.names = FALSE)
    
    # Skew referentie data
    result4 <- Skew(data_value = data_save_obs$observed_value_sub_same)
    head(result4)
    write.table(result4,paste("SkewObsdata_",name,".csv",sep=""),sep = ";",quote = FALSE, row.names = FALSE)
    
    #Skew model data
    result3 <- Skew(data_value = data_save_sim$simulated_value_sub_same)
    head(result3)
    write.table(result3,paste("SkewSimdata_",name,".csv",sep=""),sep = ";",quote = FALSE, row.names = FALSE)
    
    #R squared
    result6 <- Rsquared(data_save_obs$observed_value_sub_same,data_save_sim$simulated_value_sub_same)
    head(result6)
    write.table(result6,paste("Rsquared__",name,".csv",sep=""),sep = ";",quote = FALSE, row.names = FALSE)
    
    
    if(file_name == "Chlorophyl-A"){
      
      #Log tranform the data
      observed_value_log        = log(observed_value + 1)
      simulated_value_log       = log(simulated_value + 1)
      observed_value_save_log   = log(data_save_obs$observed_value_sub_same + 1)
      simulated_value_save_log  = log(data_save_sim$simulated_value_sub_same + 1)
      
      # CorrelationCoefficient
      jpeg(filename = paste("CorrelationCoefficient_", name,".jpg",sep = ""), width = 600, height = 480, units = "px",type = "windows")
      print({CorrelationCoefficient(observed_value = observed_value_sub_new_log ,simulated_value = simulated_value_sub_new_log)})
      dev.off()
      
      current_location_comp_obs = as.character(list_locations[,3])[match(origin,as.character(list_locations[,2]))]
      current_location_comp_sim = as.character(list_locations[,3])[match(origin_sim,as.character(list_locations[,1]))]
      
      best_fit_comp_data = BestFitData(comp_obs_origin = current_location_comp_obs, comp_obs_value = observed_value_log,
                                       comp_obs_date = date_obs, comp_sim_origin = current_location_comp_sim, 
                                       comp_sim_value = simulated_value_log, comp_sim_date = date_sim,
                                       range_day = search_window_bestfit_d)
      
      average_comp_data = AverageData(comp_obs_origin = current_location_comp_obs, comp_obs_value = observed_value_log,
                                      comp_obs_date = date_obs, comp_sim_origin = current_location_comp_sim, 
                                      comp_sim_value = simulated_value_log, comp_sim_date = date_sim,
                                      range_day = search_window_averaged_d)
      
    }else{  
      
      # CorrelationCoefficient
      jpeg(filename = paste("CorrelationCoefficient_", name,".jpg",sep = ""), width = 600, height = 480, units = "px",type = "windows")
      print({CorrelationCoefficient(observed_value = data_save_obs$observed_value_sub_same ,simulated_value = data_save_sim$simulated_value_sub_same)})
      dev.off()
      
      current_location_comp_obs = as.character(list_locations[,3])[match(origin,as.character(list_locations[,2]))]
      current_location_comp_sim = as.character(list_locations[,3])[match(origin_sim,as.character(list_locations[,1]))]
      
      best_fit_comp_data = BestFitData(comp_obs_origin = current_location_comp_obs, comp_obs_value = observed_value,
                                       comp_obs_date = date_obs, comp_sim_origin = current_location_comp_sim, 
                                       comp_sim_value = simulated_value, comp_sim_date = date_sim,
                                       range_day = search_window_bestfit_d)
      
      average_comp_data = AverageData(comp_obs_origin = current_location_comp_obs, comp_obs_value = observed_value,
                                      comp_obs_date = date_obs, comp_sim_origin = current_location_comp_sim, 
                                      comp_sim_value = simulated_value, comp_sim_date = date_sim,
                                      range_day = search_window_averaged_d)
    }
    
    if(!(class(best_fit_data) == "character" & class(average_data) == "character")){
      
      #Omit locations without measurement data
      best_fit_comp_data = best_fit_comp_data[complete.cases(best_fit_comp_data$best_fit_sim),]
      average_comp_data = average_comp_data[complete.cases(average_comp_data$average_sim),]
      
      #Give aditional information for plot
      best_fit_comp_substance = rep(file_name,length(best_fit_comp_data$origin))
      best_fit_comp_color = rainbow(length(unique(best_fit_comp_data$origin)))
      average_comp_substance = rep(file_name,length(average_comp_data$origin))
      average_comp_color = rainbow(length(unique(average_comp_data$origin)))          
      
      #TargetDiagram
      
      ## TargetDiagramV1BF
      jpeg(filename = paste("TargetDiagramV1BF_", name,".jpg",sep = ""), width = 600, height = 480, units = "px",type = "windows")
      print({TargetDiagramV1(model = "model", substance = best_fit_comp_substance ,location = best_fit_comp_data$origin,
                             date = best_fit_comp_data$obs_date, sim_value = best_fit_comp_data$best_fit_sim,
                             obs_value = best_fit_comp_data$obs_value,ref = NULL, color = best_fit_comp_color)})
      dev.off()                       
      
      result2_1t = TargetDiagramV1(model = "model", substance = best_fit_comp_substance ,location = best_fit_comp_data$origin,
                                   date = best_fit_comp_data$obs_date, sim_value = best_fit_comp_data$best_fit_sim,
                                   obs_value = best_fit_comp_data$obs_value,ref = NULL, color = best_fit_comp_color)
      head(result2_1t)
      write.table(result2_1t,paste("TargetTableV1BF__",name,".csv",sep=""),sep = ";",quote = FALSE, row.names = FALSE)
      
      
      ## TargetDiagramV2BF
      jpeg(filename = paste("TargetDiagramV2BF_", name,".jpg",sep = ""), width = 600, height = 480, units = "px",type = "windows")
      print({TargetDiagramV2(model = "model", substance = best_fit_comp_substance ,location = best_fit_comp_data$origin,
                             date = best_fit_comp_data$obs_date, sim_value = best_fit_comp_data$best_fit_sim,
                             obs_value = best_fit_comp_data$obs_value,ref = NULL, color = best_fit_comp_color)})
      dev.off()
      
      result2_2t = TargetDiagramV2(model = "model", substance = best_fit_comp_substance ,location = best_fit_comp_data$origin,
                                   date = best_fit_comp_data$obs_date, sim_value = best_fit_comp_data$best_fit_sim,
                                   obs_value = best_fit_comp_data$obs_value,ref = NULL, color = best_fit_comp_color)
      
      head(result2_2t)
      write.table(result2_2t,paste("TargetTableV2BF__",name,".csv",sep=""),sep = ";",quote = FALSE, row.names = FALSE)
      
      
      ## TargetDiagramV1M
      jpeg(filename = paste("TargetDiagramV1M_", name,".jpg",sep = ""), width = 600, height = 480, units = "px",type = "windows")
      print({TargetDiagramV1(model = "model", substance = average_comp_substance ,location = average_comp_data$origin,
                             date = average_comp_data$obs_date, sim_value = average_comp_data$average_sim,
                             obs_value = average_comp_data$obs_value,ref = NULL, color = average_comp_color)})
      dev.off()
      
      result2_3t = TargetDiagramV1(model = "model", substance = average_comp_substance ,location = average_comp_data$origin,
                                   date = average_comp_data$obs_date, sim_value = average_comp_data$average_sim,
                                   obs_value = average_comp_data$obs_value,ref = NULL, color = average_comp_color)
      
      head(result2_3t)
      write.table(result2_3t,paste("TargetTableV1M__",name,".csv",sep=""),sep = ";",quote = FALSE, row.names = FALSE)
      
      
      
      ## TargetDiagramV2M
      jpeg(filename = paste("TargetDiagramV2M_", name,".jpg",sep = ""), width = 600, height = 480, units = "px",type = "windows")
      print({TargetDiagramV2(model = "model", substance = average_comp_substance ,location = average_comp_data$origin,
                             date = average_comp_data$obs_date, sim_value = average_comp_data$average_sim,
                             obs_value = average_comp_data$obs_value,ref = NULL, color = average_comp_color)})
      dev.off()
      
      result2_4t = TargetDiagramV2(model = "model", substance = average_comp_substance ,location = average_comp_data$origin,
                                   date = average_comp_data$obs_date, sim_value = average_comp_data$average_sim,
                                   obs_value = average_comp_data$obs_value,ref = NULL, color = average_comp_color)
      
      head(result2_4t)
      write.table(result2_4t,paste("TargetTableV2M__",name,".csv",sep=""),sep = ";",quote = FALSE, row.names = FALSE)
      
      
      #TaylorDiagram
      best_fit_comp_data <- na.omit(best_fit_comp_data)
      if(length(best_fit_comp_data[,1]) > 1){
        jpeg(filename = paste("TaylorDiagramBF_", name,".jpg",sep = ""), width = 600, height = 480, units = "px",type = "windows")
        print({TaylorDiagram(model = "model", substance = best_fit_comp_substance ,location = best_fit_comp_data$origin,
                           date = best_fit_comp_data$obs_date, sim_value = best_fit_comp_data$best_fit_sim,
                           obs_value = best_fit_comp_data$obs_value, color = best_fit_comp_color, cex = 0.8)})
        dev.off()
      }
      
      average_comp_data <- na.omit(average_comp_data)
      if(length(average_comp_data[,1]) > 1){
        jpeg(filename = paste("TaylorDiagramM_", name,".jpg",sep = ""), width = 600, height = 480, units = "px",type = "windows")
        print({TaylorDiagram(model = "model", substance = average_comp_substance ,location = average_comp_data$origin,
                           date = average_comp_data$obs_date, sim_value = average_comp_data$average_sim,
                           obs_value = average_comp_data$obs_value, color = average_comp_color, cex = 0.8)})
        dev.off()
      }
    }
    
    # Output Table

    DF_output = data.frame(NS = c("*",as.character(result1)), Model_bias = c("*", as.character(result2)), 
                           Costfunction = c("*",as.character(result5)), Skew = c(result4,result3), 
                           R_squared = c("*",as.character(result6)))
    DF_output = t(DF_output)
    colnames(DF_output) <- c("Obs",as.character(year_nr))
    write.csv(DF_output,paste("DataframeOutput__",name,".csv",sep=""))
  }
}
warnings()
print("Done.")
