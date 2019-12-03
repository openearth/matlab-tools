Model_Reference_analysis
Version 1.0

Author: M.P. Weeber (marc dot weeber at deltares dot nl)
Collaboration: Valesca Harezlak, Willem Stolte

#######################################
FOR HELP IN DELTARES:

	Development:
		Marc Weeber
		Willem Stolte

	Experienced users:
		Willem Stolte
		Tineke Troost
		Anne de Kluijver

#######################################



Contents:
1. Introduction
2. Function
3. Manual


1. Introduction

This module "Model_Reference_analysis" has been created in the framework of the project "KPP Betrouwbaarheid modellen", 
a project funded by the Dutch Ministry of Infrastructure and the Environment (RWS). 
The aim of this project is to make the preformance of different models more visible 
so this can be used as basis to select a specific model for a specific job.

With this module we focussed on waterquality modelling, more specific the model DELWAQ. The boundaries of this module is 
DELWAQ put to use within the Dutch national borders. 

However, currently this module could also be applied for any DELWAQ model applied in another country
as long as the reference data is in NetCDF and the format of the NetCDF has a simular setup as applied by RWS in Waterbase.
With minor changes this model could also be applied to other data formats of reference data. 


2. Function

The module "Module_Reference_analysis" is setup to validate modelresults of the waterquality module DELWAQ applied in the Dutch national bouders.
To validate the modelresults the module will make use of modelled data created by DELWAQ (.his files) and reference data aquired from RWS WATERBASE (NetCDF).

The scripts which are used to run the module are written in the free software scripting language R. This scripting language was chosen to make this module 
widely distributable. R is mainly used for statistical computing and graphics. For more information on R and to download R visit : http://www.r-project.org/ .
For working with R we advice using the IDE R-studio : https://www.rstudio.com/ .

"1_R_scripts"
The folder "1. R scripts" contains 4 R-scripts with different functionalities:
 
 - R functions for Betrouwbaarheid modellen.R
 This file contains the different functions used in the other R-scripts. There is a function specific to reading his files, to reading NetCDF files and several
 functions for the statistics used. Next to this it includes the function InstallLib() which will install all the required libraries in R for using this module 
 (IMPORTANT: run this function the first time that you will use the module).   	

 - 1.R Analyses data.R
 This R script is used to analyse the reference data. The script will pick up the required HIS and NetCDF files and preform several statistical functions on the data.
 The statisitical functions included in this R script per location are:
 	- Boxplot between months (all available data)
 	- Boxplot between years  (all available data)
 	- Boxplot between summerhalfyears (default = 1 May till 1 September)
 	- Boxplot between periods (default breaks = "2005-12-30","2007-12-30","2009-12-30")
	- Shapiro-Wilk test for a normal distribution over the observed values
 The statisitical functions included in this R script per substance are:
  	- Boxplot between months (all available data)
  	- Boxplot between years  (all available data)
  	- Boxplot between summerhalfyears (default = 1 May till 1 September)
  	- Boxplot between periods (default breaks = "2005-12-30","2007-12-30","2009-12-30")
  	- Confidence interval (all available data)
  	- Multiple comparison (all available data)
	- Shapiro-Wilk test for a normal distribution over the observed values
 (IMPORTANT: the workdirectory is automatically set in the script, 
	therefor with every new run the workdirectory needs to be reset and you need to restart R or RStudio.
	With this functionality the scripts are easy to batch. When experience problems with running the script
	, first try to reload the script by restarting R or RStudio.)

 - 2.R Analyses Model data.R
 This R script is used to analyse the model data next to the reference data. The script will pick up the required HIS and NetCDF files and preform several statistical functions on the data.
 The statisitical functions included in this R script per location are:
 	- ANOVA between simulated and observed
 	- Convidence interval of simulated
 	- Convidence interval of observed
 	- Boxplot between months (over -5 years -> simulated <- +5 years ) with modelled and measured data of simulated year
 	- Boxplot between years (over -5 years -> simulated <- +5 years ) with modelled and measured data of simulated year
 	- Multiple comparison decade (over -5 years -> simulated <- +5 years between simulated and observed)
  	- Multiple comparison limited (over year simulated between simulated and observed)
	- Shapiro-Wilk test for a normal distribution over the observed values
	- Shapiro-Wilk test for a normal distribution over the simulated values
	- Used normal fit between data (observations that are matched to simulated values and the time window around the observation that is used,
		 the most central value is chosen).
 The statisitical functions included in this R script per substance are:
  	- ANOVA between simulated and observed decade (over -5 years -> simulated <- +5 years )
  	- ANOVA between simulated and observed limited (over year simulated between simulated and observed)
	- Convidence interval of simulated
	- Convidence interval of observed
	- Multiple comparison decade (over -5 years -> simulated <- +5 years between simulated and observed)
  	- Multiple comparison limited (over year simulated between simulated and observed)
	- Shapiro-Wilk test for a normal distribution over the observed values
	- Shapiro-Wilk test for a normal distribution over the simulated values
 (IMPORTANT: the workdirectory is automatically set in the script, 
	therefor with every new run the workdirectory needs to be reset and you need to restart R or RStudio.
	With this functionality the scripts are easy to batch. When experience problems with running the script
	, first try to reload the script by restarting R or RStudio.)

 - 3.R Analyses Validation data.R
 This R script is used to statistically analyse the coherance between the model data and the reference data. The script will pick up the required HIS and NetCDF files and preform several statistical functions on the data.
 The statisitical functions included in this R script per location are:
	- Bestfit of simulation vs observed (-5 days ->observed<- +5 days, where the observed values are taken within the period of simulation)
 	- Averged of simulation vs observed (-5 days ->observed<- +5 days, where the observed values are taken within the period of simulation)
	- Taylordiagram over median observed 
	- Taylordiagram over bestfit observed 
	- Targetdiagram over median observed (version1)
	- Targetdiagram over bestfit observed (version1)
	- Targetdiagram over median observed (version2)
	- Targetdiagram over bestfit observed (version2)
	- Correlation coefficient of simulated versus observed
	- Skew of simulated
	- Skew of observed
	- R-square result of simulated versus observed
	- Percentage Model Bias of simulated versus observed
	- NashSutcliff statistic of simulated versus observed
	- Cost function of simulated versus observed
	- Dataframe output of numeric results of statistics
	- Used normal fit between data (observations that are matched to simulated values and the time window around the observation that is used,
		 the most central value is chosen).
	- Used best fit between data (observations that are matched to simulated values and the time window around the observation that is used, 
		in this case the simulation value that best fits the observation value within the time window is chosen).
	- Used averaged between data (observations that are matched to simulated values and the time window around the observation that is used, 
		in this case the simulation values within the time window are averaged for comparison).
- Used normal fit between data (observations that are matched to simulated values and the time window around the observation that is used).
 The statisitical functions included in this R script per substance are:
  	- Bestfit of simulation vs observed (-5 days ->observed<- +5 days, where the observed values are taken within the period of simulation)
 	- Averged of simulation vs observed (-5 days ->observed<- +5 days, where the observed values are taken within the period of simulation)
	- Taylordiagram over median observed (derived from the "Used averaged table")
	- Taylordiagram over bestfit observed (derived from the "Used bestfit table")
	- Targetdiagram over median observed (version1, derived from the "Used averaged table")
	- Targetdiagram over bestfit observed (version1, derived from the "Used bestfit table")
	- Targetdiagram over median observed (version2, derived from the "Used averaged table")
	- Targetdiagram over bestfit observed (version2, derived from the "Used bestfit table")
	- Data used for Targetdiagram over median observed (version1, derived from the "Used averaged table")	
	- Data used for Targetdiagram over bestfit observed (version1, derived from the "Used bestfit table")
	- Data used for Targetdiagram over median observed (version2, derived from the "Used averaged table")
	- Data used for Targetdiagram over bestfit observed (version2, derived from the "Used bestfit table")	
	- Correlation coefficient of simulated versus observed
	- Skew of simulated
	- Skew of observed
	- R-square result of simulated versus observed
	- Percentage Model Bias of simulated versus observed
	- NashSutcliff statistic of simulated versus observed
	- Cost function of simulated versus observed
	- Dataframe output of numeric results of statistics
 (IMPORTANT: the workdirectory is automatically set in the script, 
	therefor with every new run the workdirectory needs to be reset and you need to restart R or RStudio.
	With this functionality the scripts are easy to batch. When experience problems with running the script
	, first try to reload the script by restarting R or RStudio.)


"2_Modelled_data"
The folder "2_Modelled_data" contains the modelresults in a HIS-file and two mapping CSV's containing the following:

	HIS file
	The HIS file contains the water quality model results from DELWAQ. Until now we have tested this module only with results of one year and starting in 1st of January.
	The script will look up all the his files present in the "2. Modelled_data"folder and create output per his file. The script for now requires that the modelled year is the name
	of the HIS file , for example "2006.his". This has as effect that you cannot generated output of several HIS-files with the same modelled year in one script run.
	(IMPORTANT: Name the HIS-file for the modelled year, for example "2006.his")
	
	"list_of_variables_linked.csv"
	The mapping table "list_of_variables_linked.csv" contains the mapping between the variables as mentioned in the HIS-file and
	the variables as mentioned in the NetCDF-file. This CSV file can be opened and editted with MSExcel and LibreOffice Clac. 
	In the column "variable_his" the variable name as metioned in the HIS-file should be placed (extra spaces after the name, as given in the HIS file are not required, for example "NH4").
	In the column "variable_nc" the variable name as mentioned in the NetCDF-file should be placed (for example "NH4").
	By placing both names on the same row you will map the HIS-file varaible to the NetCDF variable for comparison between the simulated and observed values.
	By leaving a "variable_nc" empty the "variable_his"is not processed. With placing "---"in front of a "variable_nc" name the variable_his" is not taken up in the analyses.

		Some examples of more complex opperations:

	 				|variable_his|variable_nc|variable_csv|factor_on_measurement|combine_simulated| combine_measurement|remarks   |
	  "Add to simulated values	|O2_1	     |           |            |                     | O2_total        |                    |          |
	   together and analyse as      |O2_2        |           |            |                     | O2_total        |                    |          |
	   one, against the "           |O2_total    |           | O2_meas    |                     |                 |                    |          |
	   measurements in the csv file
	   "O2_meas.csv"
                                        |variable_his|variable_nc|variable_csv|factor_on_measurement|combine_simulated| combine_measurement|remarks   |
	  "Add to measurement values	|            | N         |            |                     | N_complete      |                    |          |
	   together, one csv and one	|            |           | N_missed   |                     | N_complete      |                    |          |
	   NetCDF, convert from         |N_modelled  | N_complete|            | 0.0001              |                 |                    |          |
	   KG/L to mg/l (* 0.0001) and
	   compare with NetCDF" 


	"list_of_locations_linked.csv"
	The mapping table "list_of_locations_linked.csv" contains the mapping between the locations as mentioned in the HIS-file and
	the locations as mentioned in the NetCDF-file. This CSV file can be opened and editted with MSExcel and LibreOffice Clac. 
	In the column "variable_his" the location name as metioned in the HIS-file should be placed (extra spaces after the name, for example "DenOever").
	In the column "variable_nc" the location name as mentioned in the NetCDF-file should be placed (for example "DENOVR").
	In the column "full_name" is free to place the name that you want to give to the location (NOTE: simular names will cause that the output is overwritten)
	,in this case for example "Den Oever".
	By placing both names on the same row you will map the HIS-file location to the NetCDF location for comparison between the simulated and observed values.
	By leaving a "variable_nc" empty the "variable_his"is not processed. 

	"settings.inp"
	This file is used to chose the prevered settings for your run.
	Always use three spaces between the "=" sign and input entered, like this:
		delimiter   =   ,

	Possible settings are:
	- Delimiter (the delimiter that is used reading the Mapping tables .csv)
		*input: delimiter -> , ; \t
	- observation_as_date (converts timestamps of observation values to dates,
		 but only when one observation per date is available)
		*input: boolean -> TRUE, FALSE
	- observation_forced_as_date (converts timestamps of observation values to dates
		 and averages when more than one observation per date is available)
		*input: boolean -> TRUE, FALSE
	- search_window_sec (the search window used on both sides of the observation value to create the 
		"Used normal fit" table)
		*input: numeric (seconds) -> 30, 60 , 1800
	- search_window_bestfit_sec (the search window used on both sides of the observation value to create the 
		"Used best fit" table)
		*input: numeric (seconds) -> 30, 60 , 1800
	- search_window_averaged_sec (the search window used on both sides of the observation value to create the 
		"Used averaged" table)
		*input: numeric (seconds) -> 30, 60 , 1800
	- ignore_tests (ignore the test if locations contain more than 3 observations that can be matched to simulations,
		can be usefull for large analysis, but requires that you asses the results later on)
		*input: boolean -> TRUE, FALSE


"3_Reference_data"

The folder "3. Reference_data" contains the observed data, in this case the NetCDF files achieved from "WATERBASE" or csv files set up in a similar format. In the folder "3_Reference_data/NetCDF" the folder structure from "WATERBASE"
is maintained, for example "concentration_of_chlorophyll_in_water", "NH4" and "NO3NO2". In these folders the NetCDF files are placed, for example "id282-ADLWG.nc". The extention ".nc" is required.
For the location name mapping "ADLWG" is required and for the variable mapping "concentration_of_chlorofyll_in_water" is required. Chlorofyl is a special case, the name is changed from "concentration_of_chlorofyll_in_water"
to "Chlorofyl-A".

"4_Results"

The folder "4. Results" contains the results after running the R-script. The head folder will be named after the imported HIS-file (NOTE: when you process several HIS-files with the same year the data will be overwritten).
In the subfolder the division is made in "Data analysis", "Model analysis" and "Validation analysis", corresponding with the resluts produced by the R-scripts.



3. Manual

	1. For working with this module it is to maintain the whole folder structure starting from "Model_Reference_analysis". This is required for the R-scripts to work properly.

	2. You are required to place your own DELWAQ modelresults in the folder "2_Modelled_data" and name it with the modelled year (for example "2006.his")

	3. Before starting your analysis download the required NetCDF files from WATERBASE (http://live.waterbase.nl/waterbase_wns.cfm?taal=nl) and place these in the folder "3_Reference_data/NetCDF".
   	   If you require more NetCDF files than you wish to download manually, Gerben de Boer and Valesca Harezlak have access to scripts which will download all NetCDF files.
	   You can also place CSV files in the correct format (see examples) in the folder "3_Reference_data/CSV".
	   (IMPORTANT: Make sure that the same time notation (GMT+1) is used for your simulation input as for your observation input) 

	4. Fill in the required settings in "settings.inp" in the folder "2_Modelled_data".

	5. Fill in the required location and parameter mapping between the modelresults and the NetCDF-files located in the CSV's "list_of_locations_linked" and "list_of_variables_linked" in the folder "2_Modelled_data"

	5. Start up script 1 "1_R_Analyses_data" in the folder "1_R_scripts".

	6. Type the function InstallLib() in one of the R scripts (1,2 and 3) after the row containing "source" (this function can be removed after execution).
	   (IMPORTANT: This function only needs to be used the first time you use the scripts to import the required libraries. 
	   When libraries are still missing when having executed this function, please repeat the procedure form point 5)

	7. Run the scripts (1,2 and 3) in R or Rstudio and check the results in the folder "4. Results".
	   (IMPORTANT: close and restart R or RStudio by clicking on the desired script to reset the correct working directory.
	   The scripts can also be executed in batch by starting "run_all_scripts.bat").  





DEVELOPMENTS:

	IMPORTANT: Please do not alter any of the examples!!!!	

	New developments can be tested in the workbench:
	p:\1207726-betrouwbaarheid\Model_Referance_analysis_testbank\
	(Only accesable within Deltares)

	This workbench provides a number of applications for the scripts.
	For testing Python 3.3 is required. Start the test by batch from "runAllTests.bat"
	New scripts should be placed in "_new_scripts" and are automatically applied to the applications.

	Validations should currently still be done manually.

	
	 