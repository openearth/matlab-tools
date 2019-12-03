Model_Reference_analysis
Version 1.0

Author: M.P. Weeber (marc dot weeber at deltares dot nl)
Collaboration: Tineke Troost, Valesca Harezlak, Willem Stolte

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

"1. R scripts"
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
 The statisitical functions included in this R script per substance are:
        - Boxplot between months (all available data)
        - Boxplot between years  (all available data)
        - Boxplot between summerhalfyears (default = 1 May till 1 September)
        - Boxplot between periods (default breaks = "2005-12-30","2007-12-30","2009-12-30")
        - Confidence interval (all available data)
        - Multiple comparison (all available data)
 (IMPORTANT: set the workdirectory in the script to the location of the module, for example: "D:/Model_Reference_analysis_v1.1/")

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
 The statisitical functions included in this R script per substance are:
        - ANOVA between simulated and observed decade (over -5 years -> simulated <- +5 years )
        - ANOVA between simulated and observed limited (over year simulated between simulated and observed)
        - Convidence interval of simulated
        - Convidence interval of observed
        - Multiple comparison decade (over -5 years -> simulated <- +5 years between simulated and observed)
        - Multiple comparison limited (over year simulated between simulated and observed)
 (IMPORTANT: set the workdirectory in the script to the location of the module, for example: "D:/Model_Reference_analysis_v1.1/")

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
 The statisitical functions included in this R script per substance are:
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
 (IMPORTANT: set the workdirectory in the script to the location of the module, for example: "D:/Model_Reference_analysis_v1.1/")

"2. Modelled_data"
The folder "2. Modelled_data" contains the modelresults in a HIS-file and two mapping CSV's containing the following:

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


        "list_of_locations_linked.csv"
        The mapping table "list_of_locations_linked.csv" contains the mapping between the locations as mentioned in the HIS-file and
        the locations as mentioned in the NetCDF-file. This CSV file can be opened and editted with MSExcel and LibreOffice Clac.
        In the column "variable_his" the location name as metioned in the HIS-file should be placed (extra spaces after the name, for example "DenOever").
        In the column "variable_nc" the location name as mentioned in the NetCDF-file should be placed (for example "DENOVR").
        In the column "full_name" is free to place the name that you want to give to the location (NOTE: simular names will cause that the output is overwritten)
        ,in this case for example "Den Oever".
        By placing both names on the same row you will map the HIS-file location to the NetCDF location for comparison between the simulated and observed values.
        By leaving a "variable_nc" empty the "variable_his"is not processed.

"3. Reference_data"

The folder "3. Reference_data" contains the observed data, in this case the NetCDF files achieved from "WATERBASE". In the folder "3. Reference_data" the folder structure from "WATERBASE"
is maintained, for example "concentration_of_chlorophyll_in_water", "NH4" and "NO3NO2". In these folders the NetCDF files are placed, for example "id282-ADLWG.nc". The extention ".nc" is required.
For the location name mapping "ADLWG" is required and for the variable mapping "concentration_of_chlorofyll_in_water" is required. Chlorofyl is a special case, the name is changed from "conentration_of_chlorofyll_in_water"
to "Chlorofyl-A".

"4. Results"

The folder "4. Results" contains the results after running the R-script. The head folder will be named after the imported HIS-file (NOTE: when you process several HIS-files with the same year the data will be overwritten).
In the subfolder the division is made in "Data analysis", "Model analysis" and "Validation analysis", corresponding with the resluts produced by the R-scripts.



3. Manual

        1. For working with this module it is to maintain the whole folder structure starting from "Model_Reference_analysis_v%nr%". This is required for the R-scripts to work properly.

        2. You are required to place your own DELWAQ modelresults in the folder "2. Modelled_data" and name it with the modelled year (for example "2006.his")

        3. Before starting your analysis download the required NetCDF files from WATERBASE (http://live.waterbase.nl/waterbase_wns.cfm?taal=nl) and place these in the folder "3. Reference_data".
           If you require more NetCDF files than you wish to download manually, Gerben de Boer and Valesca Harezlak have access to scripts which will download all NetCDF files.

        4.  fill in the required location and parameter mapping between the modelresults and the NetCDF-files located in the CSV's "list_of_locations_linked" and "list_of_variables_linked" in the folder "2. Modelled_data"

        5.  set the correct workdirectory in the required R scripts (1,2 and 3) in the folder "1. R scripts".

        6. Execute the function InstallLib() in one of the R scripts (1,2 and 3) after the row containing "source" (this function can be removed after execution.

        7. run the scripts (1,2 and 3) in R or Rstudio and check the results in the folder "4. Results".
