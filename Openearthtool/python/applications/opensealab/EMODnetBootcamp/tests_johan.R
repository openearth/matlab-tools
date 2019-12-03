library(robis)
library(leaflet)
library(tidyverse)
library(sf)

library(gstat)
library(sp)
library(raster)

library(automap)

# wind park bb 7.55, 56.99, 12.09, 58.05
a = st_bbox(c(7.55, 56.99, 12.09, 58.05))
pol = st_sfc(st_polygon(list(cbind(c(7.55,7.55,12.09,12.09,7.55),c(56.99,58.05,58.05,58.05,56.99)))))
pol_ext = st_buffer(pol, dist = 1)
bb <- st_bbox(pol)
# data1 <- occurrence(scientificname = c(""), geometry = st_as_text(pol))

sortedlist <- sort(table(data1$scientificName), decreasing = T)
head(sortedlist, 50)

data11 <- occurrence(scientificname = c("Buccinum undatum"), geometry = st_as_text(pol_ext))

# data2 <- occurrence(scientificname = c("Cetartiodactyla"), geometry = st_as_text(pol_ext))
#leafletmap(data11)

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


g1 <- gstat(id="count",formula = individualCount ~ 1, 
      data = data)

v<- variogram(g1)

vm <- fit.variogram(v, vgm(10,"Sph"))
plot(v, model=vm)

grid2 <- as(grid, "SpatialPixels")

a = autoKrige(individualCount~1,
         data,
         grid)

plot(a)
spplot(a$krige_output)
