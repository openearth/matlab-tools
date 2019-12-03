from SharpMap.Data.Providers import ShapeFile
from GisSharpBlog.NetTopologySuite.IO import ShapefileWriter
import os
from Libraries.Utils.Project import *
from System import Array
from GeoAPI.Extensions.Feature import IFeature
from NetTopologySuite.Extensions.Features import Feature
from System.Collections.Generic import List
from shutil import copyfile
#from Ringtoets.SplitLineStrings import *
from System import Double
from DeltaShell.Plugins.SharpMapGis.ImportExport import ShapeFileExporter
from DelftTools.Utils.Reflection import TypeUtils

from GisSharpBlog.NetTopologySuite.Geometries import Coordinate
from System.Collections.Generic import IEnumerable, List
from GisSharpBlog.NetTopologySuite.Geometries import LineString, Point
from DelftTools.Utils.Reflection import TypeUtils
from DeltaShell.Plugins.SharpMapGis.ImportExport import ShapeFileExporter
import os, random
from shutil import copyfile



#region base information
baseDir = r"n:\Projects\1230000\1230088\C. Report - advise\001 Ringtoets\Examples\Traject 12-2 piping\Voorbeeld\STPH\Vakindeling maken"
shapeTraject = baseDir + r"\traject_12-2.shp"
shapeSurfaceLines = baseDir + r"\Crosssection.shp"

outputLocation = baseDir

#endregion

#region read info
trajectShape = ShapeFile(shapeTraject, False)
surfaceLinesShape = ShapeFile(shapeSurfaceLines, False)

projectionFile = shapeTraject.replace(".shp",".prj")
if not(os.path.isfile(projectionFile)):
	projectionFile = None

if not os.path.exists(outputLocation):
    os.makedirs(outputLocation)

trajectLine = trajectShape.Features[0]
#endregion

#region Calculate vaklengths

lengths = List[Double]()
coordinates = List[Coordinate]()
isurfaceLine = 0
surfaceLine = surfaceLinesShape.Features[0]

for idxC, coordinate in enumerate(trajectLine.Geometry.Coordinates):
	coordinates.Add(coordinate)
	if (idxC == 0):
		continue
	line = LineString(coordinates.ToArray())
	if (line.Intersects(surfaceLine.Geometry)):
		crossing = line.Intersection(surfaceLine.Geometry)
		coordinates.Remove(coordinate)
		coordinates.Add(crossing.Coordinate)
		line = LineString(coordinates.ToArray())
		lengths.Add(line.Length)
		coordinates.Clear()
		coordinates.Add(crossing.Coordinate)
		coordinates.Add(coordinate)
		isurfaceLine = isurfaceLine + 1
		if (isurfaceLine == surfaceLinesShape.Features.Count):
			break
		surfaceLine = surfaceLinesShape.Features[isurfaceLine]

vakken = SplitLineString(trajectLine,lengths,0)
#endregion

#region Write vakindeling STPH
features = List[IFeature]()
for idx,vak in enumerate(vakken):
	f = Feature(Geometry = vak)
	f.Attributes = trajectLine.Attributes.Clone()
	f.Attributes["VakId"] = ("%s") % (surfaceLinesShape.Features[idx].Attributes['LOCATIONID'])
	f.Attributes["Vaknaam"] = ("%s") % (surfaceLinesShape.Features[idx].Attributes['LOCATIONID'])
	features.Add(f)

targetPathBase = outputLocation + r"\vakindeling STPH traject " + trajectLine.Attributes['TRAJECT_ID']
targetPath = targetPathBase + ".shp"

TypeUtils.CallPrivateStaticMethod(ShapeFileExporter,"WriteFeaturesToFile",targetPath,features,None)
if not(projectionFile == None):
	copyfile(projectionFile, targetPathBase + ".prj")
#endregion

#region Create vakindeling kunstwerken
features = List[IFeature]()
vakken = SplitLineString(trajectLine,[2190,20,100000],1)
names = ["kunstwerken vak 1","Stontelerkeersluis","kunstwerken vak 3"]
for idx,vak in enumerate(vakken):
	f = Feature(Geometry = vak)
	f.Attributes = trajectLine.Attributes.Clone()
	f.Attributes["VakId"] = names[idx]
	f.Attributes["Vaknaam"] = names[idx]
	features.Add(f)

targetPathBase = outputLocation + r"\vakindeling Kunstwerken traject " + trajectLine.Attributes['TRAJECT_ID']
targetPath = targetPathBase + ".shp"

TypeUtils.CallPrivateStaticMethod(ShapeFileExporter,"WriteFeaturesToFile",targetPath,features,None)
if not(projectionFile == None):
	copyfile(projectionFile, targetPathBase + ".prj")

#endregion

#region write kunstwerken shape
features = List[IFeature]()
kunstwerkenShape = ShapeFile(baseDir + r"\Kunstwerken.shp", False)
for kunstwerk in kunstwerkenShape.Features:
	if kunstwerk.Attributes["KWKIDENT"] == "KGM-A-371":
		break

x = (vakken[1].Coordinates[1].X + vakken[1].Coordinates[1].X)/2.0
y = (vakken[1].Coordinates[1].Y + vakken[1].Coordinates[1].Y)/2.0
kunstwerk.Geometry = Point(Coordinate(x,y))
features.Add(kunstwerk)

targetPathBase = outputLocation + r"\Kunstwerken traject " + trajectLine.Attributes['TRAJECT_ID']
targetPath = targetPathBase + ".shp"

TypeUtils.CallPrivateStaticMethod(ShapeFileExporter,"WriteFeaturesToFile",targetPath,features,None)
if not(projectionFile == None):
	copyfile(projectionFile, targetPathBase + ".prj")
print targetPath
#endregion

#region write GEKB/voorlanden shape
vaklength = trajectLine.Geometry.Length/5
lengths = [vaklength,vaklength,vaklength,vaklength,vaklength]
vakken = SplitLineString(trajectLine,lengths,1)

features = List[IFeature]()
names = ["profiel001","profiel002","profiel003","profiel004","profiel005"]
for idx,vak in enumerate(vakken):
	f = Feature(Geometry = vak)
	f.Attributes = trajectLine.Attributes.Clone()
	f.Attributes["VakId"] = names[idx]
	f.Attributes["Vaknaam"] = names[idx]
	features.Add(f)

targetPathBase = outputLocation + r"\vakindeling Grasbekledingen erosie kruin en binnentalud " + trajectLine.Attributes['TRAJECT_ID']
targetPath = targetPathBase + ".shp"

TypeUtils.CallPrivateStaticMethod(ShapeFileExporter,"WriteFeaturesToFile",targetPath,features,None)
if not(projectionFile == None):
	copyfile(projectionFile, targetPathBase + ".prj")

features = List[IFeature]()
for idx,vak in enumerate(vakken):
	id = vak.NumPoints/2
	c1 = vak.Coordinates[id]
	c2 = vak.Coordinates[id+1]
	f = Feature(Geometry = Point(Coordinate((c1.X + c2.X)/2.0,(c1.Y + c2.Y)/2.0)))
	f.Attributes = trajectLine.Attributes.Clone()
	f.Attributes.Clear()
	f.Attributes["ID"] = names[idx]
	f.Attributes["Naam"] = names[idx]
	f.Attributes["X0"] = random.uniform(-20,20)
	features.Add(f)

targetPathBase = outputLocation + r"\Voorlanden " + trajectLine.Attributes['TRAJECT_ID']
targetPath = targetPathBase + ".shp"

TypeUtils.CallPrivateStaticMethod(ShapeFileExporter,"WriteFeaturesToFile",targetPath,features,None)
if not(projectionFile == None):
	copyfile(projectionFile, targetPathBase + ".prj")

#endregion