from System.Collections.Generic import IEnumerable, List
from GisSharpBlog.NetTopologySuite.Geometries import LineString, Point
from GisSharpBlog.NetTopologySuite.Geometries import Coordinate

#region helper methods
def AddCoordinate(c1, c2,currentLength, desiredLength, coordinates, lengths, ilength, method):
	vakken = List[LineString]()
	
	dx = c2.X - c1.X
	dy = c2.Y - c1.Y
	dist = c1.Distance(c2)
	ratio = (desiredLength - currentLength) / dist
	newCoordinate = Coordinate(c1.X + ratio*dx, c1.Y + ratio*dy)
	coordinates.Add(newCoordinate)
	vakken.Add(LineString(coordinates.ToArray()))
	coordinates = List[Coordinate]()
	coordinates.Add(newCoordinate)
	dist = newCoordinate.Distance(c2)
	if method == 0:
		desiredLength = lengths[ilength]/2.0 + lengths[ilength+1]/2.0
	else:
		desiredLength = lengths[ilength]
		
	ilength = ilength +1 
	
	if (dist > desiredLength):
		newVakken, currentLength, desiredLength, coordinates, newCoordinate = AddCoordinate(newCoordinate,c2,0,desiredLength,coordinates,lengths, ilength, method)
		vakken.AddRange(newVakken)
	elif (currentLength == desiredLength):
		vakken.Add(LineString(coordinates.ToArray()))
		coordinates = List[Coordinate]()
		coordinates.Add(c2)
		currentLength = 0
		newCoordinate = c2
	else:
		coordinates.Add(c2)
		newCoordinate = c2
		currentLength = dist
	
	return vakken, currentLength, desiredLength, coordinates, newCoordinate

def SplitLineString(line, lengths, method):
	coordinates = List[Coordinate]()
	vakken = List[LineString]()
	
	if method == 0:
		desiredLength = lengths[0] + lengths[1]/2.0
	else:
		desiredLength = lengths[0]
	ilength = 1
	currentLength = 0.0
	lastCoordinate = line.Geometry.Coordinates[0]
	coordinates.Add(lastCoordinate)
	for c in line.Geometry.Coordinates[1:]:
		dist = lastCoordinate.Distance(c)
		if (dist + currentLength > desiredLength):
			newVakken, currentLength, desiredLength, coordinates, lastCoordinate = AddCoordinate(lastCoordinate,c,currentLength,desiredLength,coordinates,lengths,ilength, method)
			vakken.AddRange(newVakken)
		elif (dist + currentLength == desiredLength):
			coordinates.Add(c)
			vakken.Add(LineString(coordinates.ToArray()))
			coordinates = List[Coordinate]()
			lastCoordinate = c
			currentLength = 0
			coordinates.Add(lastCoordinate)
		else:
			coordinates.Add(c)
			currentLength = currentLength + dist 
			lastCoordinate = c

	if (not(coordinates.Contains(c))):
		coordinates.Add(c)

	vakken.Add(LineString(coordinates.ToArray()))
	return vakken

#endregion