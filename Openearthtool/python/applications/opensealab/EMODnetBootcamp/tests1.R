library(robis)
library(leaflet)
library(tidyverse)
library(rworldxtra)
library(sf)
library(gstat)
library(sp)
library(raster)

# wind park bb 7.55, 56.99, 12.09, 58.05
# a = st_bbox(c(7.55, 56.99, 12.09, 58.05))

pol = st_sfc(st_polygon(list(cbind(c(7.55,7.55,12.09,12.09,7.55),c(56.99,58.05,58.05,58.05,56.99)))))
pol_ext = st_buffer(pol, dist = 5)
bb <- st_bbox(pol)
pol_ext_sp <- pol_ext %>% as('Spatial')
crs(pol_ext_sp) <- ("+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0")
data1 <- occurrence(scientificname = c(""), geometry = st_as_text(pol))

sortedlist <- sort(table(data1$scientificName), decreasing = T)
top50species <- data.frame(species = head(sortedlist, 50))
save(top50species, file = "backgrounddata.rdata")

data11 <- occurrence(scientificname = c("Buccinum undatum"), geometry = st_as_text(pol_ext))

# data2 <- occurrence(scientificname = c("Cetartiodactyla"), geometry = st_as_text(pol_ext))
leafletmap(data11)

data <- data11 %>% 
  filter(scientificName == "Buccinum undatum") %>%
  dplyr::select(decimalLongitude, eventDate, decimalLatitude, individualCount) %>%
  filter(!is.na(individualCount))
data$eventDate <- as.POSIXct(data$eventDate, "%Y-%m-%d %H:%M:%S", tz = "GMT")
hist(as.numeric(format(data$eventDate, "%Y")))

# data <- data %>% filter(
#   as.numeric(format(data$eventDate, "%Y")) >= 2000,
#   as.numeric(format(data$eventDate, "%Y")) < 2017
#   )

coordinates(data) <- ~decimalLongitude + decimalLatitude
grid <- raster(data)
res(grid) <- 0.1


g1 <- gstat(formula = individualCount ~ 1, 
      data = data)

v<- variogram(g1)
plot(v)
vm <- fit.variogram(v, vgm(10,"Sph"))
plot(v, model=vm)

grid2 <- as(grid, "SpatialPixels")
gridded <- krige(formula = individualCount ~ 1, locations = data, model=vm, newdata=grid2)


endangeredSp <- read.csv("endangered.csv")
bb
endangeredSp2 <- endangeredSp %>% filter(coords.x2>bb[1] & coords.x2<bb[3] & coords.x1>bb[2] & coords.x1<bb[4])
endangeredSp2
write.csv(endangeredSp2, "endangered2.csv")
require(rgeos)
windparks <- readOGR("../windmills_downloaded_data/emodnet/emodnet_windfarms.shp")
# windparks <- spTransform(windparks, "+proj=longlat +datum=WGS84")
windparks2 <- gIntersection(windparks, pol_ext_sp)
coordinates(windparks2)
class(windparks2)
windparks2 <- SpatialPointsDataFrame(windparks2)
windparks2@data <- data.frame()
writeOGR(windparks2, layer = "emodnet_windfarms2", driver = "ESRI Shapefile", "../windmills_downloaded_data/emodnet/emodnet_windfarms2.shp")
windparks_df <- data.frame(windparks)


