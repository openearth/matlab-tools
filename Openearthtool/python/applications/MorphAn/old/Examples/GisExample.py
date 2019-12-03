from Libraries.Utils.Gis import *
from System import DateTime

def GetArray(nx,ny,maxValue):
	import System
	zValues = System.Array.CreateInstance(float, nx, ny)
	for x in range(0,nx):
		for y in range(0,ny):
			zValues[x,y] = (float(nx-x)/float(nx)) * maxValue
	return zValues

def CreateRegularGridCoverage(nx,ny,dx,dy,x0,y0,maxValue):
	from NetTopologySuite.Extensions.Coverages import RegularGridCoverage
	from DelftTools.Functions.Filters import VariableValueFilter
	from DelftTools.Functions.Generic import Variable
	import System
	
	grid = RegularGridCoverage(nx,ny,dx,dy,x0,y0)
	now = DateTime.Now
	
	timeVariable = Variable[DateTime]("time");
	grid.Time = timeVariable;
	
	i = 0
	while i < 50:
		currentTime = now.AddDays(i)
		maxValueTime = (maxValue - i % 10 * maxValue)
		zValues = GetArray(nx,ny,maxValueTime)
		grid.SetValues(zValues, VariableValueFilter[DateTime](timeVariable, currentTime));
		i = i+1
	
	grid.CoordinateSystem = GetCoordinateSystem(28992)
	return grid
	
map = CreateMap()
map.CoordinateSystem = GetCoordinateSystem(28992)# WGS 84: 3857

grid = CreateRegularGridCoverage(100,100,150,150,50050,652000,15)
layer = CreateRegularGridCoverageLayer(grid)
map.Layers.Add(layer)

line = CreateLineString([50000,50100],[650000,655000])
lineLayer = CreateLinesLayer("Dit is een collectie lijnen",line)
map.Layers.Add(lineLayer)

# TODO: This requires some coordinate transformation in the coveragelayer, which is not taken care of properly.
# AddBackgroundLayer(map,"OpenStreetMap")
# AddBackgroundLayer(map,"BingAerial")
# AddBackgroundLayer(map,"BingHybrid")
# AddBackgroundLayer(map,"BingRoad")

map.ZoomToFit(layer.Envelope,True)

ShowMap(map)