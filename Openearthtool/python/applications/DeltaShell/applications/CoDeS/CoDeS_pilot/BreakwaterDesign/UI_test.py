#   Copyright notice
#   --------------------------------------------------------------------
#   Copyright (C) 2016 RoyalHaskoningDHV
#       Bart-Jan van der Spek
#
#       Bart-Jan.van.der.Spek@rhdhv.com
#
#       Laan 1914, nr 35
#       3818 EX Amersfoort
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
from System import *
from System.Collections.Generic import *
from DelftTools.Controls.Swf import CustomInputDialog
from System.Windows.Forms import DialogResult
from System.Windows.Forms import MessageBox
from System.Windows.Forms import PictureBox,DockStyle
from System.Drawing import Bitmap

# create a custom input dialog (initially empty except for OK and Cancel button)
dialog = CustomInputDialog()

layout = dialog.Controls[0]
dialog.Text="Breakwater design input variables  "

# add an input of type doubles, with labels 
HsInput = dialog.AddInput[Double]('Hs (m)',1)
HsInput.ValidationMethod = Func[object, object, String] ( lambda o,value : 'Wave height must be positive  ' if value <= 0 else '' )
HsInput.SubCategory="Wave conditions"

TpInput = dialog.AddInput[Double]('Tp (s)',6)
TpInput.ValidationMethod = Func[object, object, String] ( lambda o,value : 'Wave period must be positive  ' if value <= 0 else '' )
TpInput.SubCategory="Wave conditions"

AngInput = dialog.AddInput[Double]('Angle of incidence (deg)',0)
AngInput.ValidationMethod = Func[object, object, String] ( lambda o,value : 'Angle cannot be more than 90 degrees  ' if value > 90 or value < -90 else '' )
AngInput.ToolTip = "Angle of incidence to normal in degrees (sign does not matter)  "


SWLInput = dialog.AddInput[Double]('SWL (m+MSL)')
SWLInput.ToolTip = "Storm Water Level w.r.t. MSL   "

SlopeInput = dialog.AddInput[Double]('Slope 1:...',3)
SlopeInput.ValidationMethod = Func[object, object, String] ( lambda o,value : 'Slope must be in between 0 and 10' if value<= 0 or value > 10 else '' )

DepthInput = dialog.AddInput[Double]('Depth (m)',10.0)
DepthInput.ToolTip = "Depth is always positive  "

armour_types=List[String]()
#armour_types.AddRange({'Rock','Cube (1 layer)','Cube (2 layers)','Tetrapod','Dolos','Accropode','Core-loc','Xbloc'})
armour_types.Add('Rock')
armour_types.Add('Cube (1 layer)')
armour_types.Add('Cube (2 layers)')
armour_types.Add('Tetrapod')
armour_types.Add('Dolos')
armour_types.Add('Accropode')
armour_types.Add('Core-loc')
armour_types.Add('Xbloc')
#{'Rock','Cube (1 layer)','Cube (2 layers)','Tetrapod','Dolos','Accropode','Core-loc','Xbloc'}

ArmourtypeInput = dialog.AddChoice('Armour type',armour_types)

RockDensityInput = dialog.AddInput[Double]('Rock density (kg/m3)',2650)
WaterDensityInput = dialog.AddInput[Double]('Water density (kg/m3)',1000)
PermInput = dialog.AddInput[Double]('Notional permeability (P)',0.4)
PermInput.ValidationMethod = Func[object, object, String] ( lambda o,value : 'P must be in between 0.1 and 0.6' if value< 0.1 or value > 0.6 else '' )

DamageInput = dialog.AddInput[Double]('Damage number (S)',2)
DamageInput.ToolTip = "For design purposes S=2,3 is often used  "
DamageInput.ValidationMethod = Func[object, object, String] ( lambda o,value : 'S must be larger dan 1' if value< 1 else '' )

StormdurInput=dialog.AddInput[Double]('Storm duration (h)',6)
StormdurInput.ValidationMethod = Func[object, object, String] ( lambda o,value : 'Stormduration must be positive' if value < 0 else '' )

autocrestInput=dialog.AddInput[Boolean]('Auto Crestheight')
autocrestInput.ToolTip="Automatically calculates required crestheight based on required overtopping criterium (overwrites user defined height)  "

CrestheightInput=dialog.AddInput[Double]('Crestheight (m+MSL)')
CrestwidthInput=dialog.AddInput[Double]('Crestwidth (m)',5)

Critical_type=List[String]()
#armour_types.AddRange({'Rock','Cube (1 layer)','Cube (2 layers)','Tetrapod','Dolos','Accropode','Core-loc','Xbloc'})
Critical_type.Add('Pedestrians (unaware)')
Critical_type.Add('Pedestrians (aware)')
Critical_type.Add('Pedestrians (trained staff)')
Critical_type.Add('Vehicles (low speed)')
Critical_type.Add('Vehicles (high speed)')
Critical_type.Add('Marinas (small boats)')
Critical_type.Add('Marinas (large yachts)')
Critical_type.Add('Buildings (no damage)')
Critical_type.Add('Buildings (moderate damage)')
Critical_type.Add('Buildings (structural damage)')

OvertopcritInput = dialog.AddChoice('Situation',Critical_type)
OvertopcritInput.ToolTip = "Situation for determination critical overtopping discharge"

BermfactorInput = dialog.AddInput('Berm reduction factor (-)',1) 
BermfactorInput.ValidationMethod = Func[object, object, String] ( lambda o,value : 'Reduction factor must be lower than 1 and positive' if value > 1 or value < 0 else '' )

RoughnessfactorInput = dialog.AddInput('Roughness reduction factor (-)',1)
RoughnessfactorInput.ValidationMethod = Func[object, object, String] ( lambda o,value : 'Reduction factor must be lower than 1 and positive' if value > 1 or value < 0 else '' )


def ShowDialog():
	# show dialog and wait for the user to click OK
	
	if dialog.ShowDialog() == DialogResult.OK:
	
		# retrieve values as filled in by user (using label name)
		Hs = dialog['Hs (m)']
		Tp = dialog['Tp (s)']
		angleinc = dialog['Angle of incidence (deg)']
		SWL = dialog['SWL (m+MSL)']
		cota = dialog['Slope 1:...']
		z = dialog['Depth (m)']
		Armour_Type=dialog['Armour type']
		rhos=dialog['Rock density (kg/m3)']
		rhow=dialog['Water density (kg/m3)']
		P=dialog['Notional permeability (P)']
		S=dialog['Damage number (S)']
		stormdur=dialog['Storm duration (h)']
		autocrest=dialog['Auto Crestheight']
		crestheight=dialog['Crestheight (m+MSL)']
		crestwidth=dialog['Crestwidth (m)']
		situation=dialog['Situation']
		gammab=dialog['Berm reduction factor (-)']
		gammaf=dialog['Roughness reduction factor (-)']
		
		
			
		
		# show in message box for confirmation
		#MessageBox.Show('User supplied ' + str(grainSize) + ' as value for D50 grain size for sediment ' + sedimentName + ', with type ' + sedimentType)

from Scripts.UI_Examples.Shortcuts import *



AddShortcut("Breakwater", "CoDeS",ShowDialog, None)