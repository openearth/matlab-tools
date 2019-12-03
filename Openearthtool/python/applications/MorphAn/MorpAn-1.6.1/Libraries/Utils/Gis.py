from SharpMap import Map as _Map
from SharpMap.Layers import WmsLayer as _WmsLayer
from SharpMap.Extensions.Layers import OpenStreetMapLayer as _OpenStreetMapLayer
from SharpMap.Extensions.Layers import BingLayer as _BingLayer
from SharpMap.Layers import VectorLayer as _VectorLayer
from NetTopologySuite.Extensions.Features import Feature as _Feature
#from GisSharpBlog.NetTopologySuite.Geometries import LineString as _LineString
#from GisSharpBlog.NetTopologySuite.Geometries import Coordinate as _Coordinate
from SharpMap.Data.Providers import FeatureCollection as _FeatureCollection
from SharpMap.Layers import RegularGridCoverageLayer as _RegularGridCoverageLayer
from SharpMap.Data.Providers import FeatureCollection as _FeatureCollection
from SharpMap.Layers import SharpMapLayerFactory as _SharpMapLayerFactory
from SharpMap.Data.Providers import FeatureCollection as _FeatureCollection
from NetTopologySuite.Extensions.Coverages import RegularGridCoverage
import clr
clr.AddReference("BruTile")
from BruTile.Web import BingMapType as _BingMapType

def CreateMap():
	return _Map()

def GetCoordinateSystem(epsgCode):
	return _Map.CoordinateSystemFactory.CreateFromEPSG(epsgCode)
	
def AddBackgroundLayer(map,backgroundLayer):
	if (backgroundLayer == "OpenStreetMap"):
		layer = _OpenStreetMapLayer(Name="Open street map")
	elif (backgroundLayer == "BingAerial"):
		layer = _BingLayer(Name="Bing (Aerial)",MapType=_BingMapType.Aerial.ToString())
	elif (backgroundLayer == "BingHybrid"):
		layer = _BingLayer(Name="Bing (Hybrid)",MapType=_BingMapType.Hybrid.ToString())
	elif (backgroundLayer == "BingRoad"):
		layer = _BingLayer(Name="Bing (Roads)",MapType=_BingMapType.Roads.ToString())
	
	map.Layers.Add(layer)

def CreateRegularGridCoverageLayer(coverage):
	layer = _RegularGridCoverageLayer(Grid=coverage,Name=coverage.Name)
	layer.DataSource = _FeatureCollection()
	layer.DataSource.CoordinateSystem = coverage.CoordinateSystem
	return layer

def CreateLinesLayer(name,line):
	layer = _VectorLayer(name)
	layer.DataSource = _FeatureCollection([_Feature(Geometry=line)],_Feature)
	layer.DataSource.CoordinateSystem = GetCoordinateSystem(28992)
	return layer

def CreateLineString(x,y):
	points = []
	
	for idx,val in enumerate(x):
		points.append(_Coordinate(val,y[idx]))
	
	return _LineString(tuple(points))

def ShowMap(map):
	Gui.DocumentViewsResolver.OpenViewForData(map)

