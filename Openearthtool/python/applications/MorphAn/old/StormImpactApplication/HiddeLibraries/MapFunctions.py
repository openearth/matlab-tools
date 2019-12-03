#SCRIPT VAN HIDDE

from System.Drawing import Color

from System.IO import Path as _Path
from System import Array as _Array
from SharpMap import Map
from SharpMap.Layers import VectorLayer as _VectorLayer
from SharpMap.Data.Providers import ShapeFile as _ShapeFile
from SharpMap.Data.Providers import FeatureCollection as _FeatureCollection
from SharpMap.Extensions.Layers import BingLayer as _BingLayer
from SharpMap.CoordinateSystems.Transformations import GeometryTransform as _GeometryTransform
from NetTopologySuite.Extensions.Features import Feature
from GeoAPI.Geometries import ICoordinate as _ICoordinate
from GisSharpBlog.NetTopologySuite.Geometries import LineString as _LineString
from GisSharpBlog.NetTopologySuite.Geometries import Point as _Point
from GisSharpBlog.NetTopologySuite.Geometries import Coordinate as _Coordinate
from DelftTools.Shell.Gui import MapLayerProviderHelper as _MapLayerProviderHelper


def CreateShapeFileLayer(shapeFilePath):
    """Create a layer for the provided shapefile(path)"""
    layer = _VectorLayer()
    layer.DataSource = _ShapeFile(shapeFilePath)
    layer.Name = _Path.GetFileNameWithoutExtension(shapeFilePath)
    return layer

def CreateSatelliteImageLayer():
    """Create a layer for satellite images"""
    layer = _BingLayer()
    layer.MapType = "Aerial"
    layer.Name = "Satellite images"
    return layer
    
def CreateCoordinateSystem(EPSGCode):
    """Creates a coordinate system for the provided EPSG code"""
    return Map.CoordinateSystemFactory.CreateFromEPSG(EPSGCode)

def ZoomToLayer(layer):
    """Zooms to the extend of the provided layer"""
    layer.Map.ZoomToFit(layer.Envelope)

def ShowLayerLabels(layer, attributeName):
    """Enables the labels for the provided layer (showing the values of the provided attibute)"""
    layer.LabelLayer.Visible = True
    layer.LabelLayer.LabelColumn = attributeName

def CreateLayerForFeatures(name, features, coordinateSystem = None):
    """Creates a map layer for the provided features"""
    layer = _VectorLayer(name)
    collection = _FeatureCollection(features,Feature().GetType())
    collection.CoordinateSystem = coordinateSystem
    layer.DataSource = collection
    return layer

def GetShapeFileCoordinateSystem(shapeFilePath):
    """Gets the features defined in the shapefile(path)"""
    shapefile = _ShapeFile(shapeFilePath)
    return shapefile.CoordinateSystem

def GetShapeFileFeatures(shapeFilePath):
    """Gets the features defined in the shapefile(path)"""
    shapefile = _ShapeFile(shapeFilePath)
    return shapefile.Features

def CreateLineGeometry(coordinateList):
    """Creates a deltashell line geometry using the provided list of coordinates [[x,y], [x,y], [x,y]... etc]"""
    list = []
    for item in coordinateList:
        list.append(_Coordinate(item[0], item[1]))
     
    return _LineString(_Array[_ICoordinate](list))

def CreatePointGeometry(xpos, ypos):
    """Creates a deltashell point geometry using the provided x and y position"""
    return _Point(_Coordinate(xpos,ypos))

def TransformGeometry(geometry, sourceEPSGCode, targetEPSGCode):
    """Transforms the geometry from source coordinate system to target coordinate system"""
    sourceCS = CreateCoordinateSystem(sourceEPSGCode)
    targetCS = CreateCoordinateSystem(targetEPSGCode)
    return TransformGeometryByCoordinateSystems(geometry, sourceCS, targetCS)    

def TransformGeometryByCoordinateSystems(geometry, sourceCS, targetCS):
    """Transforms the geometry from source coordinate system to target coordinate system"""
    transformation = Map.CoordinateSystemFactory.CreateTransformation(sourceCS, targetCS)
    return _GeometryTransform.TransformGeometry(geometry, transformation.MathTransform)

def CreateLayerForObject(object):
    """Creates a layer for the provided object"""
    layerProviders = []
    for plugin in Gui.Plugins:
        if (plugin.MapLayerProvider != None):
            layerProviders.append(plugin.MapLayerProvider)

    return _MapLayerProviderHelper.CreateLayersRecursive(object,None,layerProviders)