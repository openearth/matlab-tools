from Libraries.StandardFunctions import *
from Libraries.MapFunctions import *

# Create a shapefile and a satellite image layer
shapeFileLayer = CreateShapeFileLayer("d:\\LG_Delfland.shp")
satelliteImageLayer = CreateSatelliteImageLayer()

# Show labels for shapefile layer using attibute "GM_CODE"
ShowLayerLabels(shapeFileLayer, "test")

# Set the style of the layer
shapeFileLayer.Opacity = 0.5
shapeFileLayer.Style.Fill.Color = Color.LightSkyBlue
shapeFileLayer.Style.Outline.Color = Color.Red
shapeFileLayer.Style.Outline.Width = 2

# Create map and add layers
map = Map()
map.Layers.AddRange([shapeFileLayer, satelliteImageLayer])
map.CoordinateSystem = CreateCoordinateSystem(3857) # EPSG code => WGS 84 / Pseudo-Mercator

ZoomToLayer(shapeFileLayer)

OpenView(map)

# create custom features based on shapefile features
newFeatures = []
for feature in GetShapeFileFeatures("d:\\LG_Delfland.shp"):
    feature = Feature(Geometry = feature.Geometry.Centroid)
    newFeatures.append(feature)

# create custom layer for features
customLayer = CreateLayerForFeatures("MyFeatures", newFeatures, shapeFileLayer.CoordinateSystem)
customLayer.Style.Fill.Color = Color.IndianRed
customLayer.Style.ShapeSize = 12
customLayer.Opacity = 0.9
    
map.Layers.Insert(0,customLayer)

