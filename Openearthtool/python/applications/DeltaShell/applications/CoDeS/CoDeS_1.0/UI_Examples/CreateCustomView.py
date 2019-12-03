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

from Scripts.UI_Examples.View import *

from Libraries.ChartFunctions import *
from Libraries.MapFunctions import *

from System.Windows.Forms import TableLayoutPanel, TableLayoutPanelGrowStyle, RowStyle,ColumnStyle, SizeType

# Create an empty view
view = View()
view.Text = "abc"

# Create chart
lineSeries = CreateLineSeries([[1,3],[2,5],[3,4],[4,1],[5,3],[6, 4]])
chart = CreateChart([lineSeries])

# Create a chartview
chartView = ChartView()
chartView.Chart = chart
chartView.Dock = DockStyle.Fill

# Create a mapview
mapview = MapView()
mapview.Dock = DockStyle.Fill
mapview.Map.Layers.Add(CreateSatelliteImageLayer())
mapview.Height = 100
# Create a label
label = Label()
label.Text = "Test"
label.Dock = DockStyle.Fill

# Create a splitter between chartview and label
splitContainer = SplitContainer()
splitContainer.Dock = DockStyle.Fill

splitContainer.Panel1.Controls.Add(chartView)
splitContainer.Panel2.Controls.Add(label)

# create table layout
tableLayout = TableLayoutPanel()
tableLayout.Dock = DockStyle.Fill

# define 1 column
tableLayout.ColumnCount = 1
tableLayout.ColumnStyles.Add(ColumnStyle(SizeType.Percent, 100))

# define 2 rows
tableLayout.RowCount = 2
tableLayout.RowStyles.Add(RowStyle(SizeType.Percent, 50))
tableLayout.RowStyles.Add(RowStyle(SizeType.Percent, 50))

# Add mapview (at column 0, row 0) and splitContainer (at column 0, row 1)
tableLayout.Controls.Add(mapview,0,0)
tableLayout.Controls.Add(splitContainer,0,1)

# Add controls to view
view.Controls.Add(tableLayout)        

# Show view
view.Show()