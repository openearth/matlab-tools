#   Copyright notice
#   --------------------------------------------------------------------
#   Copyright (C) 2017 RoyalHaskoningDHV
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
#Breakwater Tool SHELL (run me!)
#========================
#BJT van der spek Mar. 11, 2015
#========================

#========================
#load necessary libraries
#========================

#region load libraries
import os
import clr
clr.AddReference("System.Windows.Forms")
from System.Windows.Forms import DateTimePickerFormat
from System.Windows.Forms import MessageBox
from System.Windows.Forms import HorizontalAlignment
from System.Windows.Forms import TabPage
from System.Windows.Forms import DataGridView
from System.Windows.Forms import FolderBrowserDialog
from System.Windows.Forms import DialogResult
from System.Windows.Forms import RadioButton
from System.Windows.Forms import Panel
from System.Windows.Forms import CheckBox
from System.Windows.Forms import ComboBox
from System.Windows.Forms import NumericUpDown
from System.Windows.Forms import TrackBar
from System.Windows.Forms import BorderStyle,TableLayoutPanel, TableLayoutPanelGrowStyle, RowStyle,ColumnStyle, SizeType
from System.Windows.Forms import Button, DockStyle, AnchorStyles, Padding
import GisSharpBlog.NetTopologySuite.Geometries.Envelope as Env
from SharpMap.Extensions.Layers import OpenStreetMapLayer as OSML
from NetTopologySuite.Extensions.Features import Feature
import numpy as np
from Scripts.UI_Examples.View import *
from datetime import datetime
import System.Drawing as s
#import Scripts.TidalData as td
import Scripts.BreakwaterDesign as bw
import Scripts.LinearWaveTheory as lw
#from Scripts.BreakwaterDesign.UI_functions_BW import *
from Scripts.BathymetryData import GridFunctions
from Scripts.BathymetryData.Bathy_UI_functions import SetGradientTheme
from SharpMap.Extensions.Layers import GdalRegularGridRasterLayer as _RegularGridRasterLayer
from Libraries.StandardFunctions import *
from Libraries.MapFunctions import *
from Libraries.ChartFunctions import *
from Scripts.GeneralData.Views.BaseView import *
from Scripts.BreakwaterDesign.Views.InputView import *
from Scripts.BreakwaterDesign.Views.OutputView import *
from Scripts.BreakwaterDesign.Entities.Input import *
from Scripts.BreakwaterDesign.Entities.Output import *
import Scripts.BreakwaterDesign.ENGINEv2 as _ENGINE 
#endregion

#=============================
#define input + clone function
#=============================

#========================
#define the label SPACING
#========================
sp_loc = 5 #start point/location for labels (from left edge)
label_width = 170 #width for labels + textboxes...
spacer_width = 5 #horizontal spacing between label + textboxes
vert_spacing = 30 #vertical spacing between labels (from previous)
vert_sp = 10 # start point/location for labels (from top edge)

class InputView(BaseView):
	
	def __init__(self, inputData):
		BaseView.__init__(self)
		self.InputData = inputData
		self.Text = "Breakwater Input"
		
		group_MAP = Panel()
		#group_MAP.Text = "Breakwater alignment"
		group_MAP.Font = s.Font(group_MAP.Font.FontFamily, 10)
		group_MAP.Dock = DockStyle.Fill
		group_MAP.Controls.Add(inputData.mapview)
		
		group_INTABS = Panel()
		#group_INTABS.Text = "Input"
		group_INTABS.Font = s.Font(group_INTABS.Font.FontFamily, 10)
		group_INTABS.Dock = DockStyle.Fill
		group_INTABS.Width = 2*label_width+4*spacer_width
		inputTabs = make_InputTabs(self.InputData,group_MAP,False)
		group_INTABS.Controls.Add(inputTabs)
		
		B1 = Button()
		B1.Dock = DockStyle.Bottom
		B1.Text = "Calculate"
		B1.Height = label_width/5
		B1.Width = label_width*0.5
		B1.Click += lambda s,e : START(s,e,self.InputData)
		
		group_INTABS.Controls.Add(B1)
		#
		self.ChildViews.Add(inputData.mapview)
		self.rightPanel.Controls.Add(group_MAP)
		self.leftPanel.Controls.Add(group_INTABS)

class OutputView(BaseView):
	
	def __init__(self, inputdata, outputdata,BWlineClone,MapEnvelope):
		BaseView.__init__(self)
		self.InputData = inputdata
		self.OutputData = outputdata
		self.Text = "Breakwater Output"
		
		group_OUT = Panel()
		group_OUT.Dock = DockStyle.Fill
		#group_OUT.Text = "Output"
		
		tabs_FROZEN = make_InputTabs(self.InputData,None,False)
		
		group_FROZEN = Panel()
		#group_FROZEN.Text = "Selected Input"
		group_FROZEN.Dock = DockStyle.Left
		group_FROZEN.Width = 2.5*label_width+4*spacer_width
		group_FROZEN.Controls.Add(tabs_FROZEN)
		
		[outputTabs,MapOut1] = make_OutputTabs(self.InputData,self.OutputData,BWlineClone,MapEnvelope)
				
		group_OUT.Controls.Add(outputTabs)
		
		
		self.rightPanel.Controls.Add(group_OUT)
		self.leftPanel.Controls.Add(group_FROZEN)
		if self.InputData.is2D:
			self.ChildViews.Add(MapOut1)
	
def START(sender,e,inputData):
	
	# Check if Breakwater is clicked
	if inputData.BWlayer.LastRenderedFeaturesCount<1 and inputData.is2D:
		MessageBox.Show("Please click breakwater in map","No breakwater defined!")
		return
	
	# Check if crestheight is above SWL
	
	if not inputData.autocrest and inputData.crestheight <= inputData.SWL:
		MessageBox.Show("Please increase the crest height","Crestheight is lower than SWL")
		return
		
	if inputData.is2D:
				
		# Check if grid exists
		ValidPath = os.path.exists(inputData.RasterPath)
		
		if ValidPath == False:			
			MessageBox.Show("Please select a valid path to a bathymetry grid","No bathymetry found!")
			return
		
		# Get bathy grid from path
		grid = bw.get_bathygrid(inputData.RasterPath)		
		
		# Check if the depth values need to be multiplied by -1 to make them positive
		
		Multiplication = 1
		
		if inputData.MakePositive == True:			
			Multiplication = -1	
						
		
		# Get lineGeometry
		LineGeometry = bw.get_LineGeometry(inputData.BWlayer)
		
		# Get profile
		Profile = GridFunctions.GetProfileFromGrid(LineGeometry,grid,3857)
		BWlineClone = LineGeometry.Clone()
		inputData.profile['dist'] = np.array(Profile["dist_UTM"])
		inputData.profile['z'] = np.array(Profile["Z"]) * Multiplication
		inputData.profile['x'] = np.array(Profile["UTM_X"])
		inputData.profile['y'] = np.array(Profile["UTM_Y"])
	else:
		BWlineClone = []
		LineGeometry = []
	
	inputData.counterTAB = inputData.counterTAB + 1
	
	inputClone = inputData.Clone()
	MapEnvelope = inputData.mapview.Map.Envelope.Clone()
	
	if inputClone.is2D:
		# Check if all depths are positive
		if np.all(inputClone.profile['z'] < 0):
			inputClone.IsNegative = True

	if inputClone.IsNegative:
		MessageBox.Show("No bathymetry data found or you defined your breakwater on land. \nPlease redefine breakwater","No data or land data")
		return
	
	#dat = BuildOutput(inputData)
	#inputData = dat.InputData
	#outputData = dat.OutputData
	outputData = _ENGINE.ENGINE(inputClone)

	
	outputView = OutputView(inputClone,outputData,BWlineClone,MapEnvelope)
	
	outputView.Text = "Breakwater Output (%0.2d)" %inputClone.counterTAB
	outputView.Show()

"""def Start_BreakwaterTool():
	inputData = BuildInput()
	inputData = bw.get_BW_Alignment(inputData)
	inputView = InputView(inputData)
	inputView.Show()


Start_BreakwaterTool()
"""


x = 5