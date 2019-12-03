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

def get_UI_Input(ip):
	
	# create a custom input dialog (initially empty except for OK and Cancel button)
	dialog = CustomInputDialog()
	
	
	layout = dialog.Controls[0]
	dialog.Text="Breakwater design input variables  "
	# add an input of type doubles, with labels 
	
	HsInput = dialog.AddInput[Double]('Hs (m)',ip.Hs)
	HsInput.ValidationMethod = Func[object, object, String] ( lambda o,value : 'Wave height must be positive  ' if value <= 0 else '' )
	HsInput.SubCategory="Wave conditions"
	
	TpInput = dialog.AddInput[Double]('Tp (s)',ip.Tp)
	TpInput.ValidationMethod = Func[object, object, String] ( lambda o,value : 'Wave period must be positive  ' if value <= 0 else '' )
	TpInput.SubCategory="Wave conditions"
	
	AngInput = dialog.AddInput[Double]('Angle of incidence (deg)',ip.angleinc)
	AngInput.ValidationMethod = Func[object, object, String] ( lambda o,value : 'Angle cannot be more than 90 degrees  ' if value > 90 or value < -90 else '' )
	AngInput.ToolTip = "Angle of incidence to normal in degrees (sign does not matter)  "
	AngInput.SubCategory="Wave conditions"
	
	
	SWLInput = dialog.AddInput[Double]('SWL (m+MSL)',ip.SWL)
	SWLInput.ToolTip = "Storm Water Level w.r.t. MSL   "
	SWLInput.SubCategory="Wave conditions"
	
	SlopeInput = dialog.AddInput[Double]('Slope 1:...',ip.cota)
	SlopeInput.ValidationMethod = Func[object, object, String] ( lambda o,value : 'Slope must be in between 0 and 10' if value<= 0 or value > 10 else '' )
	SlopeInput.SubCategory="Required dimensions"
	
	DepthInput = dialog.AddInput[Double]('Local depth (m)',ip.z)
	DepthInput.ToolTip = "Depth is always positive  "
	DepthInput.SubCategory="Required dimensions"
	
	LengthInput = dialog.AddInput[Double]('Length of breakwater (m)',ip.length)
	LengthInput.ToolTip = "Length of breakwater  "
	LengthInput.SubCategory="Required dimensions"
	
	
	CrestheightInput=dialog.AddInput[Double]('Crestheight (m+MSL)',ip.crestheight)
	CrestheightInput.SubCategory="Required dimensions"
	
	CrestwidthInput=dialog.AddInput[Double]('Crestwidth (m)',ip.crestwidth)
	CrestwidthInput.SubCategory="Required dimensions"
	
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
	
	RockDensityInput = dialog.AddInput[Double]('Rock density (kg/m3)',ip.rhos)
	WaterDensityInput = dialog.AddInput[Double]('Water density (kg/m3)',ip.rhow)
	PermInput = dialog.AddInput[Double]('Notional permeability (P)',ip.P)
	PermInput.ValidationMethod = Func[object, object, String] ( lambda o,value : 'P must be in between 0.1 and 0.6' if value< 0.1 or value > 0.6 else '' )
	
	DamageInput = dialog.AddInput[Double]('Damage number (S)',ip.S)
	DamageInput.ToolTip = "For design purposes S=2,3 is often used  "
	DamageInput.ValidationMethod = Func[object, object, String] ( lambda o,value : 'S must be larger dan 1' if value< 1 else '' )
	
	StormdurInput=dialog.AddInput[Double]('Storm duration (h)',ip.stormdur)
	StormdurInput.ValidationMethod = Func[object, object, String] ( lambda o,value : 'Stormduration must be positive' if value < 0 else '' )
	
	autocrestInput=dialog.AddInput[Boolean]('Auto Crestheight',True)
	autocrestInput.ToolTip="Automatically calculates required crestheight based on required overtopping criterium (overwrites user defined height)  "
	
	
	Critical_type=List[String]()
	#armour_types.AddRange({'Rock','Cube (1 layer)','Cube (2 layers)','Tetrapod','Dolos','Accropode','Core-loc','Xbloc'})
	Critical_type.Add('Pedestrians (unaware)')
	Critical_type.Add('Pedestrians (aware)')
	Critical_type.Add('Pedestrians (trained staff)')
	Critical_type.Add('Vehicles (high speed)')
	Critical_type.Add('Vehicles (low speed)')
	Critical_type.Add('Marinas (small boats)')
	Critical_type.Add('Marinas (large yachts)')
	Critical_type.Add('Buildings (no damage)')
	Critical_type.Add('Buildings (moderate damage)')
	Critical_type.Add('Embankment (no damage) ')
	Critical_type.Add('Embankment (crest not protected)')
	Critical_type.Add('Embankment (back slope not protected)')
	
	
	#Critical_type.Add('Buildings (structural damage)')
	
	OvertopcritInput = dialog.AddChoice('Situation',Critical_type)
	OvertopcritInput.ToolTip = "Situation for determination critical overtopping discharge"
	
	BermfactorInput = dialog.AddInput('Berm reduction factor (-)',ip.gammab) 
	BermfactorInput.ValidationMethod = Func[object, object, String] ( lambda o,value : 'Reduction factor must be lower than 1 and positive' if value > 1 or value < 0 else '' )
	
	RoughnessfactorInput = dialog.AddInput('Roughness reduction factor (-)',ip.gammaf)
	RoughnessfactorInput.ValidationMethod = Func[object, object, String] ( lambda o,value : 'Reduction factor must be lower than 1 and positive' if value > 1 or value < 0 else '' )
	
	
		# show dialog and wait for the user to click OK
	
	if dialog.ShowDialog() == DialogResult.OK:
	
		# retrieve values as filled in by user (using label name)
		ip.Hs = dialog['Hs (m)']
		ip.Tp = dialog['Tp (s)']
		ip.angleinc = dialog['Angle of incidence (deg)']
		ip.SWL = dialog['SWL (m+MSL)']
		ip.cota = dialog['Slope 1:...']
		ip.z = dialog['Local depth (m)']
		ip.Armour_Type=dialog['Armour type']
		ip.rhos=dialog['Rock density (kg/m3)']
		ip.rhow=dialog['Water density (kg/m3)']
		ip.P=dialog['Notional permeability (P)']
		ip.S=dialog['Damage number (S)']
		ip.stormdur=dialog['Storm duration (h)']
		ip.autocrest=dialog['Auto Crestheight']
		ip.crestheight=dialog['Crestheight (m+MSL)']
		ip.crestwidth=dialog['Crestwidth (m)']
		ip.situation=dialog['Situation']
		ip.gammab=dialog['Berm reduction factor (-)']
		ip.gammaf=dialog['Roughness reduction factor (-)']
		ip.length = dialog['Length of breakwater (m)']
		
		return ip,Critical_type,armour_types


