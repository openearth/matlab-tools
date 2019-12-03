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
from GisSharpBlog.NetTopologySuite import Geometries as _GeometryLibrary

class CivilStructure:
    """Class which contains all (geographical) data, methods, etc, about a civil structure which is relevant for one or more CoDeS tools"""
    
    def __init__(self,name):
        self.Name = name
        self.StructureGeometry = None
    
    def GetVerticesXValues():
        return None
    
    def GetVerticesYValues():
        return None
    