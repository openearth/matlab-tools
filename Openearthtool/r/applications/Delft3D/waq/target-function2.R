##=========================================================================##
##                                                                         ##
##                 Start function "make.target.table" version 2            ##
##                                 -----------------                       ##
##  Function to make a table suitable for target diagram plots containing  ##
##             uRMSD and nBIAS for selected categories of data             ##
##                                                                         ##
##       Input:   formula: variables ~ .  (variables to be grouped by)     ##
##                 df.stat (dataframe containing data                      ##
##                 val_obs (column with observed values)                   ##
##                 val_mod (column with modelled values)                   ##
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

make.target.table2 <- function (formulax, df.stat, val_obs, val_mod) {

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

  ## calculate normalized root mean square difference (uRMSD)
  ## and normalized bias (nBIAS)
    df.target <- ddply(df.summary, formulax, summarise,
                      uRMSD = (sqrt(mean(SD))*sign(sd(modelled)-sd(observed)))/sd(observed),
                      nBIAS = (mean(modelled) - mean(observed))/sd(observed)
                        )
  
  return(df.target)
}

####################### end function #########################################