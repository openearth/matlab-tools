from SharpMap.Data.Providers import ShapeFile
from System.Collections.Generic import List
from GeoAPI.Extensions.Feature import IFeature
from DelftTools.Utils.Reflection import TypeUtils
from DeltaShell.Plugins.SharpMapGis.ImportExport import ShapeFileExporter
from GisSharpBlog.NetTopologySuite.Geometries import LineString, Coordinate
from NetTopologySuite.Extensions.Features import Feature
import math

#region Initialize info
baseDir = r"D:\Test\Vakindeling"
shapeTraject = baseDir + r"\19-1.shp"
targetTrajectPath = baseDir + r"\19-1 aangepast.shp"
vakindelingShape = baseDir + r"\dr19-piping.shp"
targetVakkenPath = baseDir + r"\dr19-piping aangepast.shp"
#endregion

#region adjust traject
trajectShape = ShapeFile(shapeTraject, False)

trajectLength = trajectShape.Features[0].Geometry.Length

traject = trajectShape.Features[0]
adjustedCoordinates = List[Coordinate]()
first = True
for coordinate in traject.Geometry.Coordinates:
	if (first):
		firstCoordinate = coordinate
		newFirstCoordinate = Coordinate(coordinate.X,coordinate.Y+3)
		adjustedCoordinates.Add(newFirstCoordinate)
		first = False
		continue
	adjustedCoordinates.Add(Coordinate(coordinate.X,coordinate.Y))
	
adjustedTrajectGeometry = LineString(adjustedCoordinates.ToArray())
features = List[IFeature]()
features.Add(Feature(Geometry = adjustedTrajectGeometry))
TypeUtils.CallPrivateStaticMethod(ShapeFileExporter,"WriteFeaturesToFile",targetTrajectPath,features,None)
#endregion

#region Adjust 
vakShape = ShapeFile(vakindelingShape, False)

features = List[IFeature]()
first = True
for vak in vakShape.Features:
	coordinates = List[Coordinate]()
	for coordinate in vak.Geometry.Coordinates:
		if (math.fabs(coordinate.X - firstCoordinate.X) < 0.1 and math.fabs(coordinate.Z - firstCoordinate.Z < 0.1) and first):
			coordinates.Add(newFirstCoordinate)
			first = False
			print "joepie"
		else:
			coordinates.Add(coordinate)
	feature = Feature(Geometry = LineString(coordinates.ToArray()))
	feature.Attributes = vak.Attributes.Clone()
	feature.Attributes['Lengte'] = feature.Geometry.Length
	features.Add(feature)
TypeUtils.CallPrivateStaticMethod(ShapeFileExporter,"WriteFeaturesToFile",targetVakkenPath,features,None)

#endregion