#   Copyright notice
#   --------------------------------------------------------------------
#   Copyright (C) 2016 Deltares
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
# import our dependencies
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
box.Width = 50
box.Height = 100
box.BringToFront()
box.Dock = DockStyle.Right
dialog.Controls.Add(box)
layout = dialog.Controls[0]

# add an input of type string, with label 'Sediment name'
strInput = dialog.AddInput[String]('Sediment name')

# add an input of type boolean, and directly specify a tooltip
dialog.AddInput[Boolean]('Is mud').ToolTip = "The name of the sediment"

# if we want to specify multiple options, first assign to a variable (here: d50input)
d50input = dialog.AddInput[Double]('D50')
# add a tooltip:
d50input.ToolTip = "Specify the D50 grain size for this sediment"
# assign validation logic, horrible syntax unfortunately (empty string = no error):
d50input.ValidationMethod = Func[object, object, String] ( lambda o,value : 'Value must be positive' if value < 0 else '' )

# add several other variables
dialog.AddInput[Boolean]('Is sand')
dialog.AddInput[Boolean]('Is silt')
dialog.AddInput[Boolean]('Is rock')

dialog.AddChoice('Sediment type', List[String]({'Sand','Silt','Rock'}))

def ShowDialog():
	# show dialog and wait for the user to click OK
	if dialog.ShowDialog() == DialogResult.OK:
	
		# retrieve values as filled in by user (using label name)
		grainSize = dialog['D50']
		sedimentName = dialog['Sediment name']
		sedimentType = dialog['Sediment type']
		
		# show in message box for confirmation
		MessageBox.Show('User supplied ' + str(grainSize) + ' as value for D50 grain size for sediment ' + sedimentName + ', with type ' + sedimentType)

from Shortcuts import *

AddShortcut("Show input", "Shortcuts",ShowDialog, None)