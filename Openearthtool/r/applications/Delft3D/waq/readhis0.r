# Readhis
setwd('d:/Tools&Scripts/R_tools/Delwaq-R/')

# Inlcude script for reading binairy .his file, returns an array of data including headers.
source('readhis.rpj')

conc <- readhis('delwaq.his')
dimnames(conc)
# NH4 op locatie "start"
NH4.Start <- as.vector(conc[,1,2])
plot(NH4.Start)


