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
import clr
clr.AddReference("System.Windows.Forms")
from System.Windows.Forms import NumericUpDown, TextBox, NumericUpDown, Label
import System.Drawing as s

#clr.AddReference("Log4Net")
#from log4net import LogManager
#_log = LogManager.GetLogger("Scenario persister")

def SetValue(object, propertyName, value):
	#_log.Debug("SetValue - " + str(object) + " - " + propertyName + " - " + str(value))
	script = "object." + propertyName + "=value"
	exec(script)

def GetValue(object, propertyName):
	script = "object." + propertyName
	return eval(script)
	
def SetValueAndNotifyObs(object,value,propertyName):
	script = "object." + propertyName + "=value"
	exec(script)
	for callback in object._observers:
		callback(object)

#========================
#define the label SPACING
#========================
sp_loc = 5 #start point/location for labels (from left edge)
label_width = 170 #width for labels + textboxes...
spacer_width = 5 #horizontal spacing between label + textboxes
vert_spacing = 30 #vertical spacing between labels (from previous)
vert_sp = 10 # start point/location for labels (from top edge)

def CreateInputLabelAndTextBox(containerControl, labelName, dataobject, propertyName, verticalOffset):
	label = Label()
	label.Text = labelName
	label.Location = s.Point(sp_loc,verticalOffset)
	label.Width = label_width
	containerControl.Controls.Add(label)
	
	textbox = TextBox()
	textbox.Text = GetValue(dataobject,propertyName)
	textbox.Location = s.Point(label_width+spacer_width,verticalOffset)
	textbox.Width = label_width
	textbox.TextChanged += lambda s,e : SetValue(dataobject,propertyName, textbox.Text)
	containerControl.Controls.Add(textbox)
	
	return label,textbox

def CreateInputLabelAndNumeric(containerControl, labelName, dataobject, propertyName, verticalOffset,min,max,decimal,increment):
	label = Label()
	label.Text = labelName
	label.Location = s.Point(sp_loc,verticalOffset)
	label.Width = label_width
	containerControl.Controls.Add(label)
	
	numbox = NumericUpDown()
	numbox.Maximum = max
	numbox.Minimum = min
	numbox.Value = GetValue(dataobject,propertyName)
	numbox.Location = s.Point(label_width+spacer_width,verticalOffset)
	numbox.Increment = increment
	numbox.DecimalPlaces = decimal
	numbox.Width = label_width

	numbox.ValueChanged += lambda s,e : SetValue(dataobject,propertyName, float(numbox.Value))
	containerControl.Controls.Add(numbox)
	
	return label,numbox