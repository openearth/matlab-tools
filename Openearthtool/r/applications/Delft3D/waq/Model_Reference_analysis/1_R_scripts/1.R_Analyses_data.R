#################################################
#Model_Referance : Analyse Data
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

#Add configuration
observation_as_date = as.logical(settings_dataframe[grep("observation_as_date",settings_dataframe[,1]),2])


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
    
    # Read and progress measurement NetcDF's, CSV files and Combines
    save_dataframe_new <- PrepareMeas(File_variable_list[s,],list_variables_comp,
                                      list_locations_comp,file.path(workdirectory,"/3_Reference_data"))
    unit_for_plot = unique(save_dataframe_new$unit)
    file_name = File_variable_list[s,3]
    
    
    #############
    ####Create folder structure
    
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
    subDir  = "Data analyses"
    dir.create(file.path(mainDir , subDir), showWarnings = FALSE)
    setwd(file.path(mainDir, subDir))
    
    ####Write all results to the following folder
    mainDir = getwd()
    subDir  = file_name
    dir.create(file.path(mainDir , subDir), showWarnings = FALSE)
    setwd(file.path(mainDir, subDir))
    
    ################
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
    date = do.call(c,collect_time_obs[1])
    format_strptime_obs = unlist(collect_time_obs[2])
    
    ###ERROR prevention###
    #Some how the date can switch to hours with do.call
    #This is solved here
    if(format_strptime_obs == "date"){
      date = trunc(date,"days")
    }    
    
    ###############################################################
    #Restriction to data from 1980 (data before is less reliable)
    observed_value = observed_value[date >= strptime("1980-01-01", format = "%y%y-%m-%d")]
    data_set       = data_set[date >= strptime("1980-01-01", format = "%y%y-%m-%d"),]
    date           = date[date >= strptime("1980-01-01", format = "%y%y-%m-%d")]
    ################################################################
    
    group = "Observed"
    origin = data_set$location_name
    aggregate_list = data_set[,c("platform_id","platform_name","lon","lat","wgs_84","epsg","x","y","z")]
    
    if(length(observed_value) == 0){next}else{}
    
    ##################
    #Analyse per location               
    for(d in 1:length(unique(origin))){
      
      ####################
      #Create location folder
      
      ##Clean up
      if(exists("mainDir")){rm(list = c("mainDir"))}else{}
      if(exists("subDir")){rm(list = c("subDir"))}else{}
      
      old <- paste(workdirectory,"/4_Results/",files_his[i],"/Data analyses/",file_name,sep = "")
      
      ##Create folder
      mainDir = old
      subDir  = as.character(list_locations[d,3])
      dir.create(file.path(mainDir , subDir), showWarnings = FALSE)
      setwd(file.path(mainDir, subDir))
      
      
      #######################
      #Prepare data per location
      
      ##Select data
      observed_value_sub =  data_set$value[as.character(data_set$location_name) == as.character(list_locations[d,2])]
      date_sub           =  date[as.character(data_set$location_name) == as.character(list_locations[d,2])]
      
      ##Check selection
      if(is.na(as.character(list_locations[d,2]))){
        stop(print(paste("List locations not filled for ",
                         unique(origin)[d]," from measurements of ",file_name,"!", sep = "")))
      }
      
      if(length(observed_value_sub) > 0 ){
        
        #######################
        #Preform analysis per location
        
        ##Boxplots
        png(filename = paste("BPBetYears_", name,".png",sep = ""), width = 600, height = 480, units = "px",type = "windows")
        BoxPlotBetweenYears(observed_value_sub,date_sub, main = file_name, ylab = unit_for_plot, xlab = "years")
        dev.off()
        
        breaks <- strptime(c("2005-12-30","2007-12-30","2009-12-30"), format = "%y%y-%m-%d")
        png(filename = paste("BPBetPer_", name,".png",sep = ""), width = 600, height = 480, units = "px",type = "windows")
        BoxPlotBetweenPeriods(observed_value_sub,date_sub,breaks, main = file_name, ylab = unit_for_plot, xlab = "breaks")
        dev.off()
        
        png(filename = paste("BPBetSumHalfYear_", name,".png",sep = ""), width = 600, height = 480, units = "px",type = "windows")
        BoxPlotBetweenSummerHalfYear(observed_value_sub,date_sub, main = file_name, ylab = unit_for_plot, xlab = "summerhalf years") 
        dev.off()
        
        png(filename = paste("BPBetMonths_", name,".png",sep = ""), width = 600, height = 480, units = "px",type = "windows")    
        BoxPlotBetweenMonths(observed_value_sub,date_sub, main = file_name, ylab = unit_for_plot, xlab = "months" )
        dev.off()
        
        #Preform the Shapiro-Wilk test
        if(length(observed_value_sub) > 5000){
          test_values_observed_sub = sample(observed_value_sub,5000, replace = FALSE)
        }else{
          test_values_observed_sub = observed_value_sub
        }
        result2 <-shapiro.test(test_values_observed_sub)
        capture.output(result2,file="Shapiro-Wilk_test_observed.txt") 
        
      }else{}
      
    }
    
    ################
    #Analyse per substance
    
    setwd(old)
    
    #######################
    #Preform analysis per substance
    
    ##Boxplots
    png(filename = paste("BoxPlotBetweenYears_", name,".png",sep = ""), width = 600, height = 480, units = "px",type = "windows")
    BoxPlotBetweenYears(observed_value,date, main = file_name, ylab = unit_for_plot, xlab = "years")
    dev.off()
    
    breaks <- strptime(c("2005-12-30","2007-12-30","2009-12-30"), format = "%y%y-%m-%d")
    png(filename = paste("BoxPlotBetweenPeriods_", name,".png",sep = ""), width = 600, height = 480, units = "px",type = "windows")
    BoxPlotBetweenPeriods(observed_value,date,breaks, main = file_name, ylab = unit_for_plot, xlab = "breaks")
    dev.off()
    
    png(filename = paste("BoxPlotBetweenSummerHalfYear_", name,".png",sep = ""), width = 600, height = 480, units = "px",type = "windows")
    BoxPlotBetweenSummerHalfYear(observed_value,date, main = file_name, ylab = unit_for_plot, xlab = "summerhalf years") # Onder chlorophyl niet mogelijk
    dev.off()
    
    png(filename = paste("BoxPlotBetweenBetweenMonths_", name,".png",sep = ""), width = 600, height = 480, units = "px",type = "windows")    
    BoxPlotBetweenMonths(observed_value,date, main = file_name, ylab = unit_for_plot, xlab = "months")
    dev.off()
    
    ##Log transformed analysis for chlorofyl
    if(file_name == "Chlorophyl-A"){
      observed_value <- log(observed_value + 1)
    }
    
    # Confidence interval
    result1 <- aggregate(observed_value, by = aggregate_list, FUN = ConvidenceInterval)
    write.table(result1,paste("Confidence_interval_",name,".csv",sep=""),sep = ";",quote = FALSE, row.names = FALSE)
    
    # Multiple comparison
    png(filename = paste("MultipleComparison_", name,".png",sep = ""), width = 1450, height = 480, units = "px",type = "windows")     
    print({MultipleComparison(observed_value,group = group, origin = origin, main = file_name, ylab = unit_for_plot)})
    dev.off()
    
    #Preform the Shapiro-Wilk test
    if(length(observed_value) > 5000){
      test_values_observed = sample(observed_value,5000, replace = FALSE)
    }else{
      test_values_observed = observed_value
    }
    result2 <-shapiro.test(test_values_observed)
    capture.output(result2,file="Shapiro-Wilk_test_observed.txt") 
  }                
}
print("Done.")
warnings()
