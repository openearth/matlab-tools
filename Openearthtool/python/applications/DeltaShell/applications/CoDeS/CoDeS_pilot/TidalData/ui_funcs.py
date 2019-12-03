#   Copyright notice
#   --------------------------------------------------------------------
#   Copyright (C) 2016 Deltares
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
#i/o functions
#JFriedman Jan.28/15
#------------------

import clr
clr.AddReference("System.Windows.Forms")
from System import *
from System.Collections.Generic import *
from DelftTools.Controls.Swf import CustomInputDialog
from System.Windows.Forms import DialogResult
from System.Windows.Forms import MessageBox

# create a custom input dialog (initially empty except for OK and Cancel button)
dialog = CustomInputDialog()

from System.Windows.Forms import PictureBox,DockStyle
from System.Drawing import Bitmap

box = PictureBox()
box.Width = 5
box.Height = 200
box.BringToFront()
box.Dock = DockStyle.Right
dialog.Controls.Add(box)
layout = dialog.Controls[0]

# add an input of type string, with label 'Sediment name'
loc_input = dialog.AddInput[String]('Project Name','Test Site')
dir_input = dialog.AddInput[String]('Working Directory')

# add several other variables
dialog.AddChoice('Data Source', List[String]({'WPS','Timeseries'}))

# if we want to specify multiple options, first assign to a variable
lat_input = dialog.AddInput[float]('Latitude [deg]')
lat_input.ToolTip = "Specify the Latitude" # add a tooltip:
lon_input = dialog.AddInput[float]('Longitude [deg]')
lon_input.ToolTip = "Specify the Longitude" # add a tooltip:

# assign validation logic, horrible syntax unfortunately (empty string = no error):
lat_input.ValidationMethod = Func[object, object, String] ( lambda o,value : 'Value must be on Earth!' if (value < -90 or value > 90) else '' )
lon_input.ValidationMethod = Func[object, object, String] ( lambda o,value : 'Value must be on Earth!' if (value < -180 or value > 180) else '' )

# time extents
stime_input = dialog.AddInput[String]('Start Time','2010/01/01')
"""stime_input = dialog.AddInput[DateTime]('Start Time')"""
stime_input.ToolTip = "WPS only" # add a tooltip:
etime_input = dialog.AddInput[String]('End Time','2010/03/01')
"""etime_input = dialog.AddInput[DateTime]('End Time')"""
etime_input.ToolTip = "WPS only" # add a tooltip:

def ShowDialog():
	# show dialog and wait for the user to click OK
	if dialog.ShowDialog() == DialogResult.OK:
	
		# retrieve values as filled in by user (using label name)
		location = dialog['Project Name']
		work_dir = dialog['Working Directory']
		lat = dialog['Latitude [deg]']
		lon = dialog['Longitude [deg]']
		choice = dialog['Data Source']
		stime = dialog['Start Time']
		etime = dialog['End Time']
		
		if work_dir == "":
			work_dir = "..\\plugins\\DeltaShell.Plugins.Toolbox\\Scripts\\TidalData\\WORKING_DIR\\"
		
	return location, work_dir, lat, lon, choice, stime, etime

"""ShowDialog()"""