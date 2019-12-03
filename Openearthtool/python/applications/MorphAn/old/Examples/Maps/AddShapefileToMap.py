import clr
clr.AddReference("System.Core")
import System
clr.ImportExtensions(System.Linq)
from SharpMap.Data.Providers import ShapeFile as ShapeFile
from SharpMap.Data.Providers import ShapeFileFeature
from GeoAPI.Geometries import IPolygon, IMultiPolygon
from GisSharpBlog.NetTopologySuite.Geometries import MultiPolygon
from NetTopologySuite.Extensions.Features import Feature
from SharpMap.Layers import VectorLayer
from SharpMap.Data.Providers import FeatureCollection
from NetTopologySuite.Extensions.Features import DictionaryFeatureAttributeCollection

#region preallocate
shapeLocation = r"d:\Projecten\MorphAn\Demo\Data\shapes\2011-buurtkaart\brt_2011_gn1.shp"

#endregion

def CreateFeatureFromPolygonFeature(polygon):
	feature = Feature()
	feature.Geometry = polygon.Geometry
	feature.Attributes = DictionaryFeatureAttributeCollection()
	
	attributeValuesArray = polygon.Attributes.Values.ToArray()
	for indx,key in enumerate(polygon.Attributes.Keys):
		feature.Attributes.Add(key,attributeValuesArray[indx])
	return feature

#region Read shapefile contents
shapeFile = ShapeFile(shapeLocation, False)
polygonFeatures = shapeFile.Features.OfType[ShapeFileFeature]().Where(lambda f: isinstance(f.Geometry,IPolygon)).ToArray()

#endregion

#region Translate content to features that can be shown on a map
features = None
if (polygonFeatures.Any()):
	features = polygonFeatures.Select(lambda p: CreateFeatureFromPolygonFeature(p)).ToList()

if (features == None):
	# return, no data in shapefile
	print "Oeps"

#endregion

#region put information in layer on map
dataSource = FeatureCollection(features,Feature)
layer = VectorLayer(DataSource = dataSource)

from DeltaShell.Plugins.SharpMapGis.Gui.Forms import MapView
map = MapView()
map.Map.Layers.Add(layer)
Gui.DocumentViews.Add(map)
Gui.DocumentViews.ActiveView = map

#endregion