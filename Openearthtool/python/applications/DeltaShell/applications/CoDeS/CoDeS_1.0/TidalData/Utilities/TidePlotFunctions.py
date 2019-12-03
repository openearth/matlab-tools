#   Copyright notice
#   --------------------------------------------------------------------
#   Copyright (C) 2017 Deltares
#
#       Josh Friedman
#
#       josh.friedman@deltares.nl
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
#plotting simple timeseries
#JFriedman Jan.8/15
#------------------

import Scripts.TidalData.Utilities.TideEngine as _TideEngine


#define some constants that won't change
titleSize = 12
labelSize = 10
axisSize = 8
legendSize = 10

def plot_tide(data,titler,xlabel,ylabel):
	"""
	Function to make simple plot of timeseries data
	
	INPUT:  - cnamer (name for chart, will show as panel name)
			- data (list, output from load_ascii with the first col = dateStr)
			- titler (obvious)
			- xlabel (obvious)
			- ylabel (obvious)
		   
	OUTPUT: - chart (handle, allows further plotting or viewing or exporting)
	"""
	
	#load libraries and whatnot
	from Libraries.StandardFunctions import *
	from Libraries.ChartFunctions import *
	from System.Drawing import Font as f
	import math as math
	
	# Configure the WL series
	lineSeries = CreateLineSeries(data)
	"""Color.FromArgb(255,0,0,0)"""
	lineSeries.Color = Color.Gray
	lineSeries.Width = 1.25 
	lineSeries.XAxisIsDateTime = 1
	lineSeries.PointerVisible = 0
	lineSeries.Title = "Tide"
	
	# Configure the chart
	chart = CreateChart([lineSeries])
	"""chart.Name = cnamer"""
	chart.TitleVisible = True
	chart.Title = titler
	chart.Font = f(chart.Font.FontFamily, titleSize)
	chart.BackGroundColor = Color.White
	chart.Legend.Visible = False
	
	# Configure the bottom axis
	chart.BottomAxis.Automatic = True
	chart.BottomAxis.LabelsFont = f(chart.BottomAxis.LabelsFont.FontFamily, axisSize)
	"""chart.BottomAxis.Minimum = 0
	chart.BottomAxis.Maximum = 1"""
	chart.BottomAxis.Title = xlabel
	chart.BottomAxis.TitleFont = f(chart.BottomAxis.TitleFont.FontFamily, labelSize)
	
	# Configure the left axis
	chart.LeftAxis.Automatic = False
	chart.LeftAxis.LabelsFont = f(chart.LeftAxis.LabelsFont.FontFamily, axisSize)
	chart.LeftAxis.Minimum = math.floor(_TideEngine.getLAT(data)/0.5)*0.5 
	chart.LeftAxis.Maximum =  math.ceil(_TideEngine.getHAT(data)/0.5)*0.5
	chart.LeftAxis.Title = ylabel
	chart.LeftAxis.TitleFont = f(chart.LeftAxis.TitleFont.FontFamily, labelSize)
	
	return chart
	
def add_series(chart,stat_data,lim_data):
	"""
	Function to add data to previously made timeseries plot
	
	INPUT:  - chart (pre-existing chart handle)
			- stat_data (list, output from tide_stats.py)
			- lim_data (original data for time extents)
		   
	OUTPUT: - chart (handle, allows further plotting or viewing or exporting)
	"""
	
	#load libraries
	import System.Drawing.Drawing2D.DashStyle as Dash
	from Libraries.ChartFunctions import *
	from System.Drawing import Font as f
	
	
	#loop through all tide stats
	func_dict = {7:_TideEngine.getLAT, 6:_TideEngine.getMLWS, 5:_TideEngine.getMLWN, 4:_TideEngine.getMSL, 3:_TideEngine.getMHWN, 2:_TideEngine.getMHWS, 1:_TideEngine.getHAT}
	namer_dict = {7:"LAT", 6:"MLWS", 5:"MLWN", 4:"MSL", 3:"MHWN", 2:"MHWS", 1:"HAT"}
	color_dict = {7:Color.Red, 6:Color.Blue, 5:Color.Green, 4:Color.Black, 3:Color.Green, 2:Color.Blue, 1:Color.Red}
	
	for ii in func_dict:
		val = func_dict[ii](stat_data)
		
		#build lineseries for tide stats
		temp = []
		temp.append([lim_data[0][0], val])
		temp.append([lim_data[-1][0], val])
		
		TEMP = CreateLineSeries(temp)
		TEMP.Color = color_dict[ii]
		TEMP.Width = 2
		TEMP.DashStyle = Dash.Dash
		TEMP.PointerVisible = False
		TEMP.XAxisIsDateTime = 1
		TEMP.Title = "%s = %.2f m" %(namer_dict[ii],val)
		chart.Series.Add(TEMP)
	
	chart.Legend.Visible = True
	chart.Legend.Alignment = LegendAlignment.Bottom
	chart.Legend.Font = f(chart.Legend.Font.FontFamily, legendSize)
	return chart