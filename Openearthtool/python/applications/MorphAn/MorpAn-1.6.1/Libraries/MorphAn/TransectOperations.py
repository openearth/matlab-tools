#region imports
from DeltaShell.Plugins.MorphAn.Domain.Utils import TransectExtensions as _TransectExtensions
from DeltaShell.Plugins.MorphAn.TRDA.Utils import TransectHelper as _TransectHelper
#endregion

def CumulativeVolume(transect,lowerBoundary):
	return _TransectExtensions.CumulativeVolume(transect,transect.XMinimal,transect.XMaximal,lowerBoundary)

def CrossShore2Coordinate(x,location):
	"""
	Returns X and Y in RD for any given cross-shore position on a transect
	@param x: Cross-shore position in RSP
	@param location: Location that describes the base point and orientation of the cross-shore profile
	"""
	
	rdCoordinates = _TransectHelper.CrossShore2Coordinate(x,location)
	return rdCoordinates.Item1, rdCoordinates.Item2
	
def CalculateZLevel(transect,xPosition) :
	"""
	Calculates the height of a profile (Z level) at the specified X position
	@param xPosition: The X position (in meters) where the heigth of the profile should be calculated
	"""
	
	return _TransectExtensions.InterpolateZ(transect,xPosition)

def CreateTrimmedProfile(transect,xmin,xmax):
	"""
	Isolates a part of the profile
	@param xmin: minimum X coordinate of the resulting profile
	@param xmax: maximum X coordinate of the resulting profile
	"""
	
	return _TransectExtensions.CreateTrimmedProfile(transect,xmin,xmax)

def CalculateBeachSlope(transect, zLow, zHigh) :
	"""
	Calculates the slope of a beach between zLow and zHigh
	@param zLow: The lower level used to calculate a slope in meter relative to NAP
	@param zHigh: The upper level used to calculate a slope in meter relative to NAP
	"""

	beachWidth = CalculateBeachWidth(transect, zLow, zHigh)
	
	if (beachWidth == None or beachWidth == 0) :
		return None
	
	return (zHigh - zLow) / beachWidth

def CalculateBeachWidth(transect, zLow, zHigh) :
	"""
	Calculates the width of a beach between two z levels
	@param zLow: The lower level used to calculate beach width
	@param zHigh: The upper level used to calculate beach width
	"""
	
	lowIntersections = _TransectExtensions.HorizontalIntersections(transect,zHigh)
	highIntersections = _TransectExtensions.HorizontalIntersections(transect,zLow)
	
	if (lowIntersections.Count == 0 or highIntersections.Count == 0) :
		return None
		
	xHigh = highIntersections[0].X
	# Take most seaward intersection
	for coordinate in highIntersections :
		if coordinate.X > xHigh : 
			xHigh = coordinate.X
	
	xLow = lowIntersections[0].X
	# Take most seaward intersection
	for coordinate in lowIntersections :
		if coordinate.X > xLow : 
			xLow = coordinate.X
	
	# Calculate beach width
	return xLow - xHigh

def GetXIntersectionMaximum(transect,zLevel):
	"""
	Returns the most seaward intersection of a profile measurement (transect) with a horizontal line at level z
	@param transect: The profile measurement
	@param zLevel: The horizontal level for which to calculate intersections with
	"""
	
	intersections = _TransectExtensions.HorizontalIntersections(transect,zLevel)
	
	if (intersections.Count == 0):
		return None
	
	current = intersections[0].X
	for intersection in intersections:
		if (intersection.X > current):
			current = intersection.X

	return current

def CreateExtendedProfile(transect1,transect2):
	return _TransectExtensions.CreateExtendedProfile(transect1,transect2)