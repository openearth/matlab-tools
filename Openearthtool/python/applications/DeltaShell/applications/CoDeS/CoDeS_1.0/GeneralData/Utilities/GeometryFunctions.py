#   Copyright notice
#   --------------------------------------------------------------------
#   Copyright (C) 2017 Deltares
#
#       Hidde Elzinga
#
#       hidde.elzinga@deltares.nl
#
#       P.O. Box 177
#       2600 MH Delft
#       The Netherlands
#
#   This library is free software: you can redistribute it and/or modify
#   it under the terms of the GNU Lesser General Public License as published by
#   the Free Software Foundation, either version 3 of the License, or
#   (at your option) any later version.
#
#   This library is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with this library.  If not, see <http://www.gnu.org/licenses/>.
#   --------------------------------------------------------------------
from GisSharpBlog.NetTopologySuite.Geometries import LineString as _LineString
from GisSharpBlog.NetTopologySuite.Geometries import Coordinate as _Coordinate
from GisSharpBlog.NetTopologySuite.Geometries import GeometryCollection as _GeometryCollection
from GeoAPI.Geometries import ICoordinate as _ICoordinate
from GeoAPI.Geometries import IGeometry as _IGeometry
from System import Array as _Array


def FindExtentOfGeometryList(ListOfGeometries,PercentZoomOut):
	geomArray = _Array[_IGeometry](ListOfGeometries)
	geomCollection = _GeometryCollection(geomArray)
		
	#	Find Convex Hull
	
	outerGeometry = geomCollection.ConvexHull()
	outerEnvelope = outerGeometry.EnvelopeInternal
	
	expansionMeters = float(outerEnvelope.Width)*(float(PercentZoomOut-100))*0.01	
	outerEnvelope.ExpandBy(expansionMeters)
	
	return outerEnvelope
	


"""Punt1 = _Coordinate(5,20)
Punt2 = _Coordinate(10,30)
Punt3 = _Coordinate(15,40)

Punt4 = _Coordinate(10,20)
Punt5 = _Coordinate(10,30)
Punt6 = _Coordinate(15,50)

puntenlijst = []
puntenlijst.append(Punt1)
puntenlijst.append(Punt2)
puntenlijst.append(Punt3)

puntenlijst2 = []
puntenlijst.append(Punt4)
puntenlijst.append(Punt5)
puntenlijst.append(Punt6)

CoordArray = _Array[_ICoordinate](puntenlijst)
CoordArray2 = _Array[_ICoordinate](puntenlijst)

CoastlineGeometry = _LineString(CoordArray)
CoastlineGeometry2 = _LineString(CoordArray2)

geomLijst = []
geomLijst.append(CoastlineGeometry)
geomLijst.append(CoastlineGeometry2)

expEnvelope = FindExtentOfGeometryList(geomLijst,250)


print expEnvelope.MinX"""

