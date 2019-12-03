##=========================================================================##
##                                                                         ##
##                 Start function "make.target.table"                      ##
##                                 -----------------                       ##
##  Function to make a table suitable for target diagram plots containing  ##
##             uRMSD and nBIAS for selected categories of data             ##
##                                                                         ##
##       Input:   formula: variables ~ .  (variables to be grouped by)     ##
##                 df.stat (dataframe containing data                      ##
##                 val_obs (observed values)                               ##
##                 val_mod (modelled values)                               ##
##      Output:    df.target (dataframe with uRMSD and nbias)              ##
##   Reference:    Jolliff(2009) J Mar Sys, 76(1-2), 64-82                 ##
##      Author:    willem.stolte@deltares.nl                               ##
##  webaddress:    https://svn.oss.deltares.nl/repos/openearthtools/       ##
##                 trunk/r/applications/Delft3D/waq/target-function.R      ##
##  testscript:    https://svn.oss.deltares.nl/repos/openearthtools/       ##
##                 trunk/r/applications/Delft3D/waq/target-diagram.R       ##
##   copyright:    Deltares                                                ##
##                                                                         ##
##=========================================================================##

make.target.table <- function (formulax, df.stat, val_obs, val_mod) {
  require(reshape2)
#lst<-reshape2:::parse_formula(formula = substance + location + season ~ . )
  lst<-reshape2:::parse_formula(formula = formulax )
  ii<-length(lst[[1]])
  groupingvariables<-c(as.character(lst[[1]]))
  ##  make list of means (obs and mod) and sd (obs) for all groups based on:
  ##   variables defined in input (e.g. substance, location and season)
  df.summary <- dcast(df.stat, formulax, mean, value.var=val_obs)
  df.summary <- cbind(df.summary,
                      dcast(df.stat, formulax, mean, value.var=val_mod)[ii+1])
  df.summary <- cbind(df.summary,
                      dcast(df.stat, formulax, sd, value.var=val_obs)[ii+1])
  colnames(df.summary)[(ii+1):(ii+3)] <- c("mean_obs", "mean_mod", "sd_obs") 
  ## Put back mean and sd values in "stat" table at right place
  ## Then calculate Square difference (SD) and normalized bias
  df.stat2<-merge(df.stat,df.summary,by=groupingvariables,all.x=T)
  
  df.stat2$SD<-((df.stat2[val_obs]-df.stat2$mean_obs)-
    (df.stat2[val_mod]-df.stat2$mean_mod))^2
  df.stat2$bias<-(df.stat2$mean_mod-df.stat2$mean_obs)/df.stat2$sd_obs

## calculate means of SD and bias for each group in separate table
  ## then calculate uR van MSD
  df.target <- dcast(df.stat2, formulax, mean, value.var="SD")
  df.target <- cbind(df.target,
                     dcast(df.stat2, formulax, mean, value.var="bias")[ii+1])
  df.target <- cbind(df.target,
                     dcast(df.stat2, formulax, sd, value.var=val_obs)[ii+1])
  df.target <- cbind(df.target,
                     dcast(df.stat2, formulax, sd, value.var=val_mod)[ii+1])
  colnames(df.target)[(ii+1):(ii+4)] <- c("MSD", "bias", "sd_obs", "sd_mod")
  df.target$uRMSD<-sqrt(df.target$MSD)*sign(df.target$sd_mod-df.target$sd_obs)
  return(df.target)
}

####################### end function #########################################
