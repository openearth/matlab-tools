
library(shiny)
library(leaflet)
require(dplyr)
require(rgdal)
require(sf)
require(htmltools)
require(robis)
require(raster)
library(rjson)


emodnet_habitat_cl_origineel <- sf::read_sf("../windmills_downloaded_data/emodnet/emodnet_habitats_clipped.shp")
emodnet_habitat_cl <- st_transform(emodnet_habitat_cl_origineel, 4326)
emodnet_habitat_cl_sp <- emodnet_habitat_cl %>% dplyr::select(HAB_TYPE) %>%
  as( "Spatial")
bathymetry <- raster::raster("../windmills_downloaded_data/emodnet/bathymetry_emodnet.tif")
windparks_df <- read_sf("../windmills_downloaded_data/emodnet/emodnet_windfarms.shp")

obsData <- read.csv("obsdata.csv")
endangeredSp <- st_as_sf(obsData, coords = c("decimalLongitude", "decimalLatitude"))

kriged_wulk <- raster("data/kriged_wulk.tif")
primprod <- raster("../windmills_downloaded_data/cmems/netPP_cmems.nc")
crs(kriged_wulk) <- "+proj=longlat +datum=WGS84"

# fromJSON("../windmills_downloaded_data/emodnet/cables.json")
cables <- sf::read_sf("../windmills_downloaded_data/emodnet/cables.json")
