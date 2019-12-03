from DeltaShell.Plugins.MorphAn.Domain.Utils import *

def CalculateBeachSlope(transect,zHigh,zLow) :
	"""
	Calculates position of low- and high water, beach width and beach slope.
	@param transect: The input profile used to calculate beach width etc.
	@param waterLevel
	"""
	
	# Bereken kruispunten tussen profiel en hoog / laagwater
	highWaterIntersections = TransectExtensions.HorizontalIntersections(transect,zHigh)
	lowWaterIntersections = TransectExtensions.HorizontalIntersections(transect,zLow)
	
	# Indien geen kruispunten -> geen resultaat
	if (lowWaterIntersections.Count == 0 or highWaterIntersections.Count == 0) :
		return None, None, None, None
		
	# Zoek meest zeewaarts hoogwater kruispunt
	xHighWater = highWaterIntersections[0].X
	"""Take most seaward intersection"""
	for coordinate in highWaterIntersections :
		if coordinate.X > xHighWater : 
			xHighWater = coordinate.X
	
	# Zoek meest zeewaarts laagwater kruispunt
	xLowWaterLine = lowWaterIntersections[0].X
	"""Take most seaward intersection"""
	for coordinate in lowWaterIntersections :
		if coordinate.X > xLowWaterLine : 
			xLowWaterLine = coordinate.X
			
	# Bereken strandbreedte
	beachWidth = xLowWaterLine - xHighWater
	
	# Strandbreedte groter dan 800 meter? => Neem niet op in de resultaten
	if (beachWidth == 0 or beachWidth > 800) :
		return None, None, None, None
		
	# Bereken strandhelling
	beachSlope = (zHigh - zLow) / beachWidth
	
	return xHighWater, xLowWaterLine, beachWidth, beachSlope