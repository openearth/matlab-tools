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
#Working Example for Tide Tool
#=============================
#JFriedman Jan.29/15
#=============================
#contents:
#	1. get user input from dialog
#	2. loads data
#		timeseries (ascii or WPS)
#		constituents (TOPEX)
#	3. extracts stats
#		LAT, MLWS, MLWN, MSL, MHWN, MHWS, HAT
#	4. plots timeseries with stats
#		entire record + partial record
#	5. exports ascii file with stats
#==============================

#region load libraries
import clr
clr.AddReference("System.Windows.Forms")
from Libraries.ChartFunctions import *
from Libraries.StandardFunctions import *
from datetime import datetime
from System import *
from System.Windows.Forms import MessageBox
from Scripts.UI_Examples.View import *
import System.Drawing as s
import Scripts.TidalData as td
import numpy as np
import time as t
#endregion

#user input from dialog box
location, work_dir, lat, lon, input_method, startDateTime, endDateTime = td.ShowDialog()

print 'Starting Tidal Analysis...'

if input_method == "WPS":
	
	#required library
	from Libraries.Wps import *
	
	print 'Be Patient: Extracting TOPEX Constituents...'
	cons = td.extract_TOPEX(lat,lon)
	
	#required input
	"""startDateTime, endDateTime = datetime(2010,1,1),datetime(2010,6,1)
	lon,lat = 4, 52 """
	epsgCode = 4326
	
	print 'Be Patient: Downloading WPS Timeseries...'
	data = GetTidalPredictForCoordinate(lon, lat, epsgCode, startDateTime, endDateTime, Frequency.Hourly)
	
elif input_method == "Timeseries":
	
	#required input
	fname = 'WL_input.txt'
	hdr = '*'
	delimiterChar = '\t'
	dateTimeFormat = '%Y/%m/%d %H:%M:%S'
	cons = 0
	print 'Be Patient: Loading ascii Timeseries...'
	data = td.load_ascii(work_dir + fname,hdr,delimiterChar,dateTimeFormat)
	
#plot the entire timeseries
titler = 'Entire Tidal Record at %s' %location
ylabel = 'Water Level [m]'
xlabel = 'Date/Time'
chart_all = td.plot_tide(data,titler,xlabel,ylabel) #initialize the plot with the first dataset
chart_all = td.add_series(chart_all,data,data) #add the tide statistics on top of plot
chart_all.Legend.Visible = False

#plot only 30 days in the middle of the record
temp = [col[0] for col in data]
dater = []
for ii in range(0, len(temp)):
	dater.append(t.mktime(temp[ii].timetuple()))
dt = 1./(np.mean(np.diff(dater))/86400)
timeWindow = 30; #days
Ndt = int(dt*timeWindow) #number of "steps" in the file representing 14 days
starter = int(len(temp)/2)
sub = data[starter:starter+Ndt] #portion of data

titler = 'Partial Tidal Record at %s' %location
chart_partial = td.plot_tide(sub,titler,xlabel,ylabel) #initialize the plot with the first dataset
chart_partial = td.add_series(chart_partial,data,sub) #add the tide statistics on top of plot

#export the tidal statistics for next user
stats = dict([('LAT', td.getLAT(data)),('MLWS', td.getMLWS(data)),\
('MLWN', td.getMLWN(data)),('MSL', td.getMSL(data)),('MHWN', td.getMHWN(data)),\
('MHWS', td.getMHWS(data)),('HAT', td.getHAT(data))])

#export function for button click
def export_tide_data(sender, e):
	file_name = 'Tidal_Analysis_[%s].txt' %location.replace(' ','_')
	td.export_stats(work_dir+file_name,stats,cons)
	MessageBox.Show('Finished Exporting Tidal Statistics')
	
#print plots for button click
def print_plots(sender, e):
	img_name = 'Tidal_Record_Full_[%s].png' % location.replace(' ','_')
	chart_all.ExportAsImage(work_dir+img_name,1200,900) # Export the chart as an image
	img_name = 'Tidal_Record_Partial_[%s].png' % location.replace(' ','_')
	chart_partial.ExportAsImage(work_dir+img_name,1200,900) # Export the chart as an image
	MessageBox.Show('Finished Printing Figures')

#build view for plotting + stats
view = View()
view.Text = "Tidal Analysis"

# Create a chartview
plot1 = ChartView()
plot1.Chart = chart_all
plot1.Dock = DockStyle.Fill

# Create a chartview
plot2 = ChartView()
plot2.Chart = chart_partial
plot2.Dock = DockStyle.Fill

# Create a splitter between plots
splitPlot = SplitContainer()
splitPlot.Dock = DockStyle.Fill
splitPlot.Orientation = Orientation.Horizontal
splitPlot.Panel1.Controls.Add(plot1)
splitPlot.Panel2.Controls.Add(plot2)

# Create a label
stats_text = Label()
header = 'Tidal Constituents\n=================\nName,Amplitude, Phase\n=================\n'
temp = '\n'.join(['%s = %.4f (%.2f)\n' % (key, cons[key][0], cons[key][1]) for key in cons.keys()])
stats_text.Text = header + temp
stats_text.AutoSize = True
stats_text.Dock = DockStyle.Fill
stats_text.Font = s.Font(stats_text.Font.FontFamily, 9)

#add button for controlling export functionality
button1 = Button()
button1.Text = "Export Statistics"
button1.Height = 60
button1.Dock = DockStyle.Bottom
button1.Click += export_tide_data

#add button for controlling export functionality
button2 = Button()
button2.Text = "Print Figures"
button2.Height = 60
button2.Dock = DockStyle.Bottom
button2.Click += print_plots

# Create a splitter between plots

splitRight = SplitContainer()
splitRight.Dock = DockStyle.Right
splitRight.Width = 175
splitRight.Orientation = Orientation.Horizontal
splitRight.Panel1.Controls.Add(stats_text)
splitRight.Panel2.Controls.Add(button1)
splitRight.Panel2.Controls.Add(button2)

# Add controls to view
view.Controls.Add(splitPlot)
view.Controls.Add(splitRight)

# Show view
view.Show()

##########
