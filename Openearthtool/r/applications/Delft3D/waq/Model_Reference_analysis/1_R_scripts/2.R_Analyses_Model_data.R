#################################################
#Model_Referance : Analyse Model
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


###READ MAPPING

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


###READ HIS FILE

selection_hisfiles <- grep(".his",files_modelled)

#Check if HIS file is present
if(length(selection_hisfiles) == 0){
  stop(print("There is no his file present in the folder '2. Modelled data'!"))
}

files_his = files_modelled[selection_hisfiles]

# Prepare search windows
search_window_d = (search_window_sec / (24*60*60))

###START ANALYSIS LOOP
#Loop over HIS data
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
    subDir  = "Model analyses"
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
    date_obs       = date_obs[date_obs >= strptime("1980-01-01", format = "%y%y-%m-%d")]
    ######################################################################
    
    group = "Observed"
    origin = data_set$location_name
    
    aggregate_list = data_set[,c("platform_id","platform_name","lon","lat","wgs_84","epsg","x","y","z")]
    
    simulated_value = as.numeric(simulated_set$value)
    
    ##Get date and time of sim
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
    
    #####################################################################
    #Restriction to min and max of observation
    simulated_value     = simulated_value[date_sim >= min(date_obs) & date_sim <= max(date_obs)]
    simulated_set       = simulated_set[date_sim >= min(date_obs) & date_sim <= max(date_obs),]
    origin_sim          = origin_sim[date_sim >= min(date_obs) & date_sim <= max(date_obs)]
    aggregate_list_sim  = aggregate_list_sim[date_sim >= min(date_obs) & date_sim <= max(date_obs)]
    date_sim        = date_sim[date_sim >= min(date_obs) & date_sim <= max(date_obs)]
    ######################################################################
    
    ###################
    #Analyse per location
    for(d in 1:length(list_locations[,2])){
      
      ####################
      #Create location folder
      
      ##Clean up
      if(exists("mainDir")){rm(list = c("mainDir"))}else{}
      if(exists("subDir")){rm(list = c("subDir"))}else{}
      
      old <- paste(workdirectory,"/4_Results/",files_his[i],"/Model analyses/",file_name,sep = "")
      
      ##Create folder
      mainDir = old
      subDir  = as.character(list_locations[d,3])
      dir.create(file.path(mainDir , subDir), showWarnings = FALSE)
      setwd(file.path(mainDir, subDir))
      
      #######################
      #Prepare data per location
      
      observed_value_sub     =  observed_value[as.character(origin) == as.character(list_locations[d,2])]
      date_obs_sub           =  date_obs[as.character(origin) == as.character(list_locations[d,2])]
      
      simulated_value_sub    = simulated_value[as.character(origin_sim) == as.character(list_locations[d,1])]
      date_sim_sub           =  date_sim[as.character(origin_sim) == as.character(list_locations[d,1])]
      
      observed_value_sub_year     = observed_value_sub[date_obs_sub >= strptime(paste(year_nr,"-01-01",sep = ""), format = "%y%y-%m-%d") &
                                                         date_obs_sub < strptime(paste(year_nr+1,"-01-01",sep = ""), format = "%y%y-%m-%d")]
      date_obs_sub_year           = date_obs_sub[date_obs_sub >= strptime(paste(year_nr,"-01-01",sep = ""), format = "%y%y-%m-%d") &
                                                   date_obs_sub < strptime(paste(year_nr+1,"-01-01",sep = ""), format = "%y%y-%m-%d")]
      
      
      observed_value_sub_dec     = observed_value_sub[date_obs_sub > strptime(paste(year_nr-5,"-01-01",sep = ""), format = "%y%y-%m-%d") &
                                                        date_obs_sub < strptime(paste(year_nr+5,"-01-01",sep = ""), format = "%y%y-%m-%d")]
      date_obs_dec           = date_obs_sub[date_obs_sub > strptime(paste(year_nr-5,"-01-01",sep = ""), format = "%y%y-%m-%d") &
                                              date_obs_sub < strptime(paste(year_nr+5,"-01-01",sep = ""), format = "%y%y-%m-%d")]
      
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
      }
      
      #Save decade data
      if(!(exists("save_dec"))){save_dec = data.frame(location = rep(paste(as.character(list_locations[d,1])), length(observed_value_sub_dec)), date = date_obs_dec, observed_value_sub_dec)
      }else{ save_dec = rbind(save_dec, data.frame(location = rep(paste(as.character(list_locations[d,1])), length(observed_value_sub_dec)), date = date_obs_dec, observed_value_sub_dec) )
      }
      
      #Test if the location exists in the HIS file
      if(length(simulated_value_sub) == 0){
        stop(print(paste("The location ",as.character(list_locations[d,1])," does not exists for ",file_name,"in the .his file",sep = "")))
      }
      
      #######################
      #Preform analysis per location
      
      # Boxplots
      png(filename = paste("BPBetYears_", name,".png",sep = ""), width = 600, height = 480, units = "px",type = "windows")
      print({BoxPlotLinesBetweenYears(observed_value_sub_dec, simulated_value_sub,date_obs_dec, date_sim_sub, main = file_name, ylab = unit_for_plot, xlab = "years")})
      dev.off()
      
      png(filename = paste("BPBetMonths_", name,".png",sep = ""), width = 600, height = 480, units = "px",type = "windows")
      print({BoxPlotLinesBetweenMonths(observed_value_sub_dec, observed_value_sub_year, simulated_value_sub,date_obs_dec,date_obs_sub_year, date_sim_sub, main = file_name, ylab = unit_for_plot, xlab = "months")})
      dev.off()
      
      if(length(simulated_value_sub) > 0 & length(observed_value_sub_year) > 0){
        if(length(observed_value_sub_new) > 0){ 
          
          # Confidence interval
          result1 <- ConvidenceInterval(observed_value_sub_dec)
          head(result1)
          write.table(result1,paste("Confidence_interval_observed_",name,".csv",sep=""),sep = ";",quote = FALSE, row.names = FALSE)
          
          # Confidence interval
          result2 <- ConvidenceInterval(simulated_value_sub_new)
          head(result2)
          write.table(result2,paste("Confidence_interval_simulated_",name,".csv",sep=""),sep = ";",quote = FALSE, row.names = FALSE)
          
          if(file_name == "Chlorophyl-A"){
            
            #Check for Lower than zero chlorofyll-A levels
            if(min(c(simulated_value_sub,simulated_value_sub_new), na.rm = TRUE) < 0){ 
              warning(print(paste("Chlorofyll A levels lower than zero, zero assumed! Location = ",
                                  as.character(list_locations[d,1]),sep = "")))
              
              simulated_value_sub[simulated_value_sub < 0]
              simulated_value_sub_new[simulated_value_sub_new < 0]
            }else{}
            
            #Log tranform the data
            observed_value_sub_dec  <- log(observed_value_sub_dec + 1)
            observed_value_sub_new = log(observed_value_sub_new + 1)
            simulated_value_sub   = log(simulated_value_sub + 1)
            simulated_value_sub_new = log(simulated_value_sub_new + 1)
          }
          
          # ANOVA
          result3 <- ANOVA(value = c(observed_value_sub_new, simulated_value_sub_new),categorie = c(rep("Observed",length(observed_value_sub_new)), 
                                                                                                    rep("Simulated",length(simulated_value_sub_new))))
          sink(file= paste("ANOVASimOBs_",name,".txt",sep = ""))
          print(result3)
          sink(NULL)
          
          # Multiple comparison
          png(filename = paste("MC_dec_", name,".png",sep = ""), width = 480, height = 480, units = "px",type = "windows")     
          print({MultipleComparison(observed_value = c(observed_value_sub_dec,simulated_value_sub),
                                    group = rep(paste(as.character(list_locations[d,3]) ,"/", as.character(list_locations[d,1]),sep = " "),
                                                length(c(observed_value_sub_dec,simulated_value_sub))), 
                                    origin = c(rep("Observed",length(observed_value_sub_dec)), 
                                               rep("Simulated",length(simulated_value_sub))), main = file_name, ylab = unit_for_plot)})
          dev.off()
          
          # Multiple comparison
          png(filename = paste("MC_lim_", name,".png",sep = ""), width = 480, height = 480, units = "px",type = "windows")     
          print({MultipleComparison(observed_value = c(observed_value_sub_new,simulated_value_sub_new),
                                    group = rep(paste(as.character(list_locations[d,3]) ,"/", as.character(list_locations[d,1]),sep = " "),
                                                length(c(observed_value_sub_new,simulated_value_sub_new))), 
                                    origin = c(rep("Observed",length(observed_value_sub_new)), 
                                               rep("Simulated",length(simulated_value_sub_new))), main = file_name, ylab = unit_for_plot)})
          dev.off()
          
          #Shapiro-Wilk test
          result4a <- ShapiroWilkTest(observed_value_sub_new)
          capture.output(result4a,file="Shapiro-Wilk_test_observed_used.txt")
          
          #Shapiro-Wilk test
          result4b <- ShapiroWilkTest(simulated_value_sub_new)
          capture.output(result4b, file="Shapiro-Wilk_test_simulated_used.txt")
          
          
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
          
          
        }else{} 
      }
    }
    
    #######################
    #Analyse per substance	
    
    setwd(old)
    
    if(!(exists("save_dec"))){next}else{}
    
    observed_totvalue_dec     = save_dec$observed_value_sub_dec[save_dec$location %in% origin_sim]
    date_totobs_dec           = save_dec$date[save_dec$location %in% origin_sim]
    origin_dec                = as.character(save_dec$location[save_dec$location %in% origin_sim])
    simulated_value_lim       = simulated_value[origin_sim %in% unique(origin_dec)]
    origin_sim_lim            = origin_sim[origin_sim %in% unique(origin_dec)]
    
    # Confidence interval
    result1 <- aggregate(observed_totvalue_dec, by = data.frame(variable = origin_dec), 
                         FUN = ConvidenceInterval)
    head(result1)
    write.table(result1,paste("Confidence_interval_obs",name,".csv",sep=""),sep = ";",quote = FALSE, row.names = FALSE)
    
    # Confidence interval
    result2 <- aggregate(data_save_sim$simulated_value_sub_same, by = data.frame(variable = data_save_sim[,c("location")]), 
                         FUN = ConvidenceInterval)
    head(result2)
    write.table(result2,paste("Confidence_interval_sim",name,".csv",sep=""),sep = ";",quote = FALSE, row.names = FALSE)
    
    
    
    if(file_name == "Chlorophyl-A"){
      
      #Log tranform the data
      observed_value_dec_log  <- log(save_dec$observed_value_sub_dec[save_dec$location %in% origin_sim] + 1)
      simulated_value_log     <- log(simulated_value[origin_sim %in% unique(origin_dec)] + 1)
    }
    
    if(length(unique(origin_dec))>1){
      result3 <- ANOVA(value = observed_totvalue_dec,categorie = as.character(origin_dec))
      sink(file= paste("ANOVAOBs_dec_",name,".txt",sep = ""))
      print(result3)
      sink(NULL)
    }else{
      sink(file= paste("ANOVAOBs_dec_",name,".txt",sep = ""))
      print("Only one location present, no ANOVA possible")
      sink(NULL)
    }
    
    # Multiple comparison
    png(filename = paste("MC_dec_", name,".png",sep = ""), width = 2000, height = 1200, units = "px",type = "windows")     
    print({MultipleComparison(observed_value = c(observed_totvalue_dec,simulated_value_lim),
                              group = c(as.character(origin_dec),as.character(origin_sim_lim)), 
                              origin = c(rep("Observed",length(observed_totvalue_dec)), 
                                         rep("Simulated",length(simulated_value_lim))), main = file_name, ylab = unit_for_plot)})
    dev.off()
    
    if(length(unique(data_save_obs$location))>1){
      result3 <- ANOVA(value = data_save_obs$observed_value_sub_same,categorie = as.character(data_save_obs$location))
      sink(file= paste("ANOVAOBs_lim_",name,".txt",sep = ""))
      print(result3)
      sink(NULL)
    }else{
      sink(file= paste("ANOVAOBs_lim_",name,".txt",sep = ""))
      print("Only one location present, no ANOVA possible")
      sink(NULL)
    }
    
    
    # Multiple comparison
    png(filename = paste("MC_lim_", name,".png",sep = ""), width = 2000, height = 1200, units = "px",type = "windows")     
    print({MultipleComparison(observed_value = c(data_save_obs$observed_value_sub_same,data_save_sim$simulated_value_sub_same),
                              group = c(as.character(data_save_obs$location),as.character(data_save_sim$location)), 
                              origin = c(rep("Observed",length(data_save_obs$observed_value_sub_same)), 
                                         rep("Simulated",length(data_save_sim$simulated_value_sub_same))), main = file_name, ylab = unit_for_plot)})
    dev.off()
    
    
    #Shapiro-Wilk test
    result4a <- ShapiroWilkTest(data_save_obs$observed_value_sub_same)
    capture.output(result4a,file="Shapiro-Wilk_test_observed_used.txt")
    
    #Shapiro-Wilk test
    result4b <- ShapiroWilkTest(data_save_sim$simulated_value_sub_same)
    capture.output(result4b, file="Shapiro-Wilk_test_simulated_used.txt")
    
  }                
}
print("Done.")
warnings()
