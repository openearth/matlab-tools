#######################################################################
####                                                               ####
####          Script by willem.stolte@deltares.nl                  ####
####    Reads MWTL csv and saves file for presentation purpose     ####
####                                                               ####
####                copyright Deltares                             ####
####                                                               ####
#######################################################################

require(scales)
require(plyr)
require(reshape2)
require(ggplot2)

submap <- read.csv2("d:/Tools/Mapping tables/RWS2DELWAQ2names.csv", header = T, stringsAsFactors=FALSE)
locmap <- read.csv2("d:/Tools/Mapping tables/RWS2DELWAQ2locations.csv", header = T, stringsAsFactors=FALSE)

# rws_dat           <- read.csv2("d:\\GIS-DATA\\Nederland\\EemsDoll\\naarPostGis\\RWS\\MWTL_all.csv",dec = ".")
rws_dat           <- read.delim("DATA/collected-data.csv", header = T, sep = ";")
rws_datSvOD           <- read.delim("DATA/collected-dataSvOD.csv", header = T, sep = ";", na.strings = "N.A.")
rws_dat <- rbind(rws_dat, rws_datSvOD)
# rws_dat$waarde       <- as.numeric(rws_dat$waarde)
rws_dat$datetime   <- as.POSIXct(
  paste(rws_dat$datum, rws_dat$tijd),
  format = "%Y-%m-%d %H:%M")
rws_dat$variable   <- mapvalues(as.character(rws_dat$waarnemingssoort), from = submap$RWS_wns, to = submap$NL_name, warn_missing = F)
# rws_dat$location   <- mapvalues(as.character(rws_dat$locoms), from = locmap$locoms, to = locmap$Delwaq_ED, warn_missing = F)
# rws_dat$variable   <- mapvalues(as.character(rws_dat$variable), from = submap$Delwaq, to = submap$Delwaq_long_name, warn_missing = F)
rws_dat$month      <- format(rws_dat$datetime, format = "%m")
rws_dat$year <- as.numeric(format(rws_dat$datetime, "%Y"))
rws_dat$season <- ifelse(rws_dat$month %in% c("10", "11", "12", "01", "02"), "winter", "summer")
# rws_dat <- subset(rws_dat, rws_dat$kwccod < 50 )
save(rws_dat, file = "d:/Tools/R/ShinyMeetSchelde/data/MWTL_Schelde_bewerkt.Rdata")

#filter for high PO4 and NH4 measurements
rws_dat <- subset(rws_dat, rws_dat$waarde < 2 | rws_dat$variable != "opgelost fosfaat")
rws_dat <- subset(rws_dat, rws_dat$waarde < 4 | rws_dat$variable != "totaal opgelost fosfaat")
rws_dat <- subset(rws_dat, rws_dat$waarde < 3 | rws_dat$variable != "totaal fosfaat")
rws_dat <- subset(rws_dat, rws_dat$waarde < 2 | rws_dat$variable != "ammonium")
# rws_dat <- subset(rws_dat, rws_dat$waarde < 75 | rws_dat$variable != "chlorophyll-a")
# rws_dat <- subset(rws_dat, rws_dat$waarde < 3 | rws_dat$variable != "N pg")
# rws_dat <- subset(rws_dat, rws_dat$waarde < 30 | rws_dat$variable != "dissolved org C")
# rws_dat <- subset(rws_dat, rws_dat$waarde < 500 | rws_dat$variable != "suspended solids")
# rws_dat <- subset(rws_dat, rws_dat$waarde < 1000 )
# rws_dat <- subset(rws_dat, rws_dat$waarde >= 0 )
# rws_dat <- subset(rws_dat, rws_dat$kwccod == 0 )
# 
# save(rws_dat, file = "d:/Tools_Scripts/R/ShinyMeetVeersemeer/data/MWTL_Veersemeer_filtered.Rdata")
save(rws_dat, file = "d:/Tools/R/ShinyMeetSchelde/data/MWTL_Schelde_bewerkt_filtered.Rdata")

#filter for high PO4 and NH4 measurements
rws_dat <- subset(rws_dat, rws_dat$wrd < 0.6 | rws_dat$variable != "phosphate")
rws_dat <- subset(rws_dat, rws_dat$wrd < 1 | rws_dat$variable != "P nf")
rws_dat <- subset(rws_dat, rws_dat$wrd < 1 | rws_dat$variable != "TotP")
rws_dat <- subset(rws_dat, rws_dat$wrd < 0.6 | rws_dat$variable != "ammonium")
rws_dat <- subset(rws_dat, rws_dat$wrd < 75 | rws_dat$variable != "chlorophyll-a")
rws_dat <- subset(rws_dat, rws_dat$wrd < 3 | rws_dat$variable != "N pg")
rws_dat <- subset(rws_dat, rws_dat$wrd < 30 | rws_dat$variable != "dissolved org C")
rws_dat <- subset(rws_dat, rws_dat$wrd < 500 | rws_dat$variable != "suspended solids")
rws_dat <- subset(rws_dat, rws_dat$wrd < 1000 )
rws_dat <- subset(rws_dat, rws_dat$wrd >= 0 )
rws_dat <- subset(rws_dat, rws_dat$kwccod == 0 )

save(rws_dat, file = "d:/Tools/R/ShinyMeetSchelde/data/MWTL_Schelde_filtered_more.Rdata")

# p <- ggplot(aes(datetime, wrd), data = imares_dat)
# p + geom_line(aes(color = locoms)) +
#   geom_point(aes(datetime, wrd, color = locoms), data = rws_dat) +
#   facet_wrap(~ variable, scales = "free") 
