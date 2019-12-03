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
from Libraries.MapFunctions import *
from Libraries.StandardFunctions import *
from Libraries.ChartFunctions import *

from SharpMap.UI.Tools import MapTool
from GisSharpBlog.NetTopologySuite.Geometries import Coordinate

import clr
clr.AddReference("System.Windows.Forms")

from System.Windows.Forms import MouseButtons
from System.Drawing import Bitmap, Rectangle, Pen, Graphics, Point

class ShowImageAtClickLocationMapTool(MapTool):
    def __init__(self):
        self.WorldPosition = Coordinate(0,0)
        self.Image = None
        
    def OnMouseDown(self, worldPosition, e):
        if (not(e.Button == MouseButtons.Left)):
            return
            
        
        self.WorldPosition = worldPosition
        self.MapControl.Refresh()
        
    def OnPaint(self, paintEventArgs):
        if (self.Image == None):
            return
            
        map = self.MapControl.Map
        loc = map.WorldToImage(self.WorldPosition)

        paintEventArgs.Graphics.DrawImage(self.Image, Point(loc.X - (self.Image.Width/2) ,loc.Y - (self.Image.Height/2) ))

tool = ShowImageAtClickLocationMapTool()

map = Map()
satLayer = CreateSatelliteImageLayer()

map.Layers.Add(satLayer)
map.ZoomToExtents()

mapview = OpenView(map)
mapview.MapControl.Tools.Add(tool)

bitmap = Bitmap(100,100)
pen = Pen(Color.Blue)
pen.Width = 3
rectangle = Rectangle(1,1,97,97)

graphics = Graphics.FromImage(bitmap)
graphics.DrawEllipse(pen ,rectangle)

tool.Image = bitmap
tool.IsActive = True