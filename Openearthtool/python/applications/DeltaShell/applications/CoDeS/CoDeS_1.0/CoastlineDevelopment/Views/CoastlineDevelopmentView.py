#   Copyright notice
#   --------------------------------------------------------------------
#   Copyright (C) 2017 Witteveen+Bos
#
#       Aline Kaji
#
#       aline.kaji@witteveenbos.com
#
#       Van Twickelostraat 2
#       7411 SC Deventer
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
import os
import clr
clr.AddReference("System.Windows.Forms")

import System.Drawing as _drawing
import System.Windows.Forms as _swf

import numpy as np
from SharpMap.Api.Enums import VerticalAlignmentEnum
#from System.Security.Policy import Url

#from Scripts.UI_Examples.View import *
#from datetime import datetime

#import Scripts.TidalData as td
from Libraries import MapFunctions as _MapFunctions

#import System.Windows.Forms.BorderStyle as BorderStyle
from SharpMap.Editors.Interactors import Feature2DEditor as _Feature2DEditor
from SharpMap.UI.Tools import NewLineTool as _NewLineTool
from NetTopologySuite.Extensions.Features import Feature as _Feature
from NetTopologySuite.Extensions.Features import DictionaryFeatureAttributeCollection as _DictionaryFeatureAttributeCollection

from Libraries.StandardFunctions import *
from SharpMap.Extensions.Layers import OpenStreetMapLayer as OSML
from SharpMap.Api.Enums import VerticalAlignmentEnum
from SharpMap.Styles import VectorStyle as _VectorStyle
from SharpMap.Rendering.Thematics import CategorialTheme as _CategorialTheme
from SharpMap.Rendering.Thematics import CategorialThemeItem as _CategorialThemeItem
from SharpMap.Rendering.Thematics import ColorBlend as _ColorBlend
from DelftTools.Utils import Url

import GisSharpBlog.NetTopologySuite.Geometries.Envelope as Env

from Scripts.GeneralData.Views.View import *
from Scripts.GeneralData.Views.BaseView import *
from Scripts.GeneralData.Entities import Scenario as _scenario
from Scripts.CoastlineDevelopment.Utilities import CoordUtilities as _CoordUtilities
from Scripts.CoastlineDevelopment.Utilities import CoastlineEvolution as _CoastlineEvolution
from Scripts.GeneralData.Utilities import Conversions as _Conversions


from Scripts.CoastlineDevelopment.Entities import CoastlineInput as _CoastlineInput
from Scripts.CoastlineDevelopment.Entities import CoastlineOutput as _CoastlineOutput
from Scripts.CoastlineDevelopment.Entities import CoastlineDevelopmentData as _CoastlineDevelopmentData

from Scripts.GeneralData.Entities import SlopeBathymetry as _SlopeBathymetry

import Scripts.GeneralData.Utilities.CoDesMapTools as _CoDesMapTools
#from Scripts.CoastlineDevelopment.Views.PlottingFunctions import PlotCoastlineEvolution as _PlotCoastlineEvolution

#from Scripts.CoastlineDevelopment.Views.OutputCoastlineEvolution import *

class CoastlineDevelopmentView(BaseView):
	def __init__(self,scenario):
		
		BaseView.__init__(self)
		
		self.__scenario = scenario
		
		#	Set default inputValues
		self.InputValues = _CoastlineInput.InputData()		
		
		#	Check if the scenario contains Coastline data
		
		if self.__scenario.ToolData.has_key("coastlinedevelopment"):			
			self.InputValues = self.__scenario.ToolData["coastlinedevelopment"].InputData		
		
		self.OutputValues = _CoastlineOutput.OutputData()		
		self.DemoVersion = True	
		self.GroupLayer = self.__scenario.GroupLayerCoastlineDevelopment

		#	Layers for output of calculation
		self.coastlineLayer = None
		self.transportLayer = None
		self.sp_loc = 5 #start point/location for labels (from left edge)
		self.label_width  = 140 #width for labels + textboxes...
		self.spacer_width = 20 #horizontal spacing between label + textboxes
		
		self.vert_spacing = 40 #vertical spacing between labels (from previous)
		self.window_width = 2.6*self.label_width #2*self.label_width+2*self.spacer_width
		
		self.CalculationMethod = 'Calculate alongshore transport'
		self.isFrozen = False
		
		#	Compose user controls
				
		self.Text = "Coastline Development"
		
		#	Set Grouplayer for display of outputs
		self.GroupLayer = self.__scenario.GroupLayerCoastlineDevelopment 		
		
		#	Create mapcontrols and add them to right panel of BaseView
		self.createMapControl()		
		
		#	Create inputtabs and add them to left panel of BaseView
		
		self.createInputControl()								
		self.ShowWaveInformation()				
		
		#	Show information about slope
		self.ShowSlopeBathymetry()
		
		#	Make sure the proper controls are shown (for alongshore transport or coastline evolution)
		self.SetCalculationType()

		
		#	Set anchoring		
		
		self.SetScrollBarsLeftPanel(20)
		self.SetAnchoring()
				
		
		
	def createInputControl(self):
		
		self.inputTabs = _swf.TabControl()
		self.inputTabs.Dock = _swf.DockStyle.Fill
		
		#	Create and populate the tabpage with general settings
		
		self.tabPageGeneral = _swf.TabPage()
		self.tabPageGeneral.Text = "General"
		#self.tabPageGeneral.Font = _drawing.Font(self.tabPageGeneral.Font.FontFamily, 10)
		self.tabPageGeneral.Dock = _swf.DockStyle.Fill
		
		self.CreateControlsGeneral()		
		
		#	Create and dopulate the tabpage with parameters
				
		self.tabPageParameters = _swf.TabPage()
		self.tabPageParameters.Text = "Parameters"
		#self.tabPageParameters.Font = _drawing.Font(self.tabPageGeneral.Font.FontFamily, 10)
		self.tabPageParameters.Dock = _swf.DockStyle.Fill
		
		self.CreateControlsParameters()	
		
		#	Create controls visible on both pages
		
		self.GenerateFixedControls()
		
		#	Add pages to TabControl
		
		self.inputTabs.TabPages.Add(self.tabPageGeneral)
		self.inputTabs.TabPages.Add(self.tabPageParameters)		
		
		#	Show Tabcontrol on the left panel of the BaseView
		self.leftPanel.Controls.Add(self.inputTabs)
		
		
		
	
	#region Inputvalues	
	
	"""This function is called when the input data has changed, therefore the InputValues need to be stored in the ToolData dictionary"""  
	def CheckToolDataLink(self):		
		if self.__scenario.ToolData.has_key("coastlinedevelopment") == False:
			#	Create new Tooldata object		
			coastlineData = _CoastlineDevelopmentData(self.InputValues)			
			self.__scenario.ToolData["coastlinedevelopment"] = coastlineData
			
	
	def set_gamma(self):
		self.InputValues.gamma = float(self.nud_gamma.Value)
		self.CheckToolDataLink()
	
	def set_doc(self):
		self.InputValues.doc = float(self.nud_doc.Value)
		self.CheckToolDataLink()
			
	def set_d50(self):
		self.InputValues.d50 = float(self.nud_d50.Value / 1000000)
		self.CheckToolDataLink()
	
	def set_slope(self):
		#	Check if a numeric value has been filled in
		
		if self.txtBathymetry.Text <> "": 
			slopeValue = _Conversions.StrToFloat(self.txtBathymetry.Text)
			
			if slopeValue != None:
				self.InputValues.beach_slope = float(1)/float(slopeValue)			
				self.lblMessage.Text = ""
				self.lblMessage.ForeColor = _drawing.Color.Black
			else:
				self.lblMessage.Text = "Please fill in a valid value for the slope"
				self.lblMessage.ForeColor = _drawing.Color.Red
		self.CheckToolDataLink()
	
	def set_rho_s(self):
		self.InputValues.rho_s = float(self.nud_rho_s.Value)
		self.CheckToolDataLink()
			
	def set_rho_w(self):
		self.InputValues.rho_w = float(self.nud_rho_w.Value)
		self.CheckToolDataLink()
	
	def set_por(self):
		self.InputValues.porosity = float(self.nud_por.Value)	
		self.CheckToolDataLink()
		
	
	''' function for setting input formula (Kamphuis or Cerc)'''
	def set_formula(self):
		
		if self.L7.Text == 'van Rijn (not implemented yet)':
			#	Choose Kamphuis by default
			self.InputValues.formula = 'Kamphuis'
		else:
			self.InputValues.formula = self.L7.Text
		
		self.CheckToolDataLink()
	
	def set_active_height(self):
		self.InputValues.active_height = float(self.nud_active_height.Value)	
		self.CheckToolDataLink()
	
	def set_npoints(self):
			self.InputValues.npoints = int(self.nud_npoints.Value)
	
	def set_time(self):
		self.InputValues.time = int(self.nud_time.Value)
		self.CheckToolDataLink()
			
	def set_time_step(self):
		self.InputValues.time_step = float(self.nud_t_step.Value)	
		self.CheckToolDataLink()
	
	def SetCalculationType(self):		
		self.cbCalculationMethod_copy.Text = self.cbCalculationMethod.Text		
		
		#	Enable or disable controls
		if self.cbCalculationMethod.Text == 'Calculate alongshore transport':
			self.btnDraw.Enabled = True		
			
			#	Parameters not necessary for alongshore transport
			self.SwitchControlsCoastlineEvolution(False)
			self.L5.Text = "Calculation alongshore transport"
			self.L5_copy.Text = "Calculation alongshore transport"
			
			# Add to input values
			self.InputValues.CalculationType = 1

		else:
			#	Necessary controls for coastline evolution
			self.btnDraw.Enabled = False
			self.SwitchControlsCoastlineEvolution(True)
			
			self.L5.Text = "Calculation coastline evolution"
			self.L5_copy.Text = "Calculation coastline evolution"
			self.InputValues.CalculationType = 2
		self.CheckToolDataLink()
	#endregion
	
	def ShowCalculationType(self,control):
		if self.InputValues.CalculationType == 1:			
			control.Text = "Calculate alongshore transport"
		if self.InputValues.CalculationType == 2:
			control.Text = "Calculate coastline evolution"
	

	def GenerateFixedControls(self):
		
		#	 Combobox for choice of calculation type
		
		self.labelMethod = _swf.Label()
		self.labelMethod.Text = "Choose type of calculation:"
		self.labelMethod.Location = _drawing.Point(0.1*self.label_width,0.2*self.vert_spacing)
		self.labelMethod.Width = 2*self.label_width
		self.labelMethod.TextAlign = _drawing.ContentAlignment.MiddleLeft
		self.tabPageGeneral.Controls.Add(self.labelMethod)	
		
		self.labelMethod_copy = _swf.Label()
		self.labelMethod_copy.Text = "Choose type of calculation:"
		self.labelMethod_copy.Location = _drawing.Point(0.1*self.label_width,0.2*self.vert_spacing)
		self.labelMethod_copy.Width = 2*self.label_width
		self.labelMethod_copy.TextAlign = _drawing.ContentAlignment.MiddleLeft
		self.tabPageParameters.Controls.Add(self.labelMethod_copy)					
		
		self.cbCalculationMethod = _swf.ComboBox()
		self.cbCalculationMethod_copy = _swf.ComboBox()
		
		self.cbCalculationMethod.Items.Add("Calculate alongshore transport")
		self.cbCalculationMethod.Items.Add("Calculate coastline evolution")								
		self.cbCalculationMethod.Location = _drawing.Point(0.1*self.label_width,1*self.vert_spacing)
		self.cbCalculationMethod.Width = 2*self.label_width				
		self.ShowCalculationType(self.cbCalculationMethod)
		self.cbCalculationMethod.TextChanged += lambda s,e : self.SetCalculationType()
		self.tabPageGeneral.Controls.Add(self.cbCalculationMethod)
		
		self.cbCalculationMethod_copy.Items.Add("Calculate alongshore transport")
		self.cbCalculationMethod_copy.Items.Add("Calculate coastline evolution")				
		self.cbCalculationMethod_copy.Location = _drawing.Point(0.1*self.label_width,1*self.vert_spacing)
		self.cbCalculationMethod_copy.Width = 2*self.label_width
		self.cbCalculationMethod_copy.Enabled = False
		self.ShowCalculationType(self.cbCalculationMethod_copy)
		self.tabPageParameters.Controls.Add(self.cbCalculationMethod_copy)		
		
		
				
		# 	Compute button
		self.L5 = _swf.Button()
		self.L5.Enabled = True
		#self.L5.BackColor = Color.LightGray
		self.L5.Text = "Compute alongshore transports"
		self.L5.Location = _drawing.Point(0.1*self.label_width,12.8*self.vert_spacing)
		self.L5.Width = 2*self.label_width
		self.L5.Click += lambda s,e : self.StartCalculation()
		self.tabPageGeneral.Controls.Add(self.L5)
		
		self.L5_copy = _swf.Button()
		self.L5_copy.Enabled = True
		#self.L5_copy.BackColor = Color.LightGray
		self.L5_copy.Text = "Compute alongshore transports"
		self.L5_copy.Location = _drawing.Point(0.1*self.label_width,12.8*self.vert_spacing)
		self.L5_copy.Width = 2*self.label_width
		self.L5_copy.Click += lambda s,e : self.StartCalculation()
		self.tabPageParameters.Controls.Add(self.L5_copy)
		
		self.progCalculation = _swf.ProgressBar()
		self.progCalculation.Maximum = 100
		self.progCalculation.Value = 0
		self.progCalculation.Location = _drawing.Point(0.1*self.label_width,13.7*self.vert_spacing)
		self.progCalculation.Width = 2*self.label_width
		self.progCalculation.Height = 0.3*self.vert_spacing
		self.progCalculation.Visible = False
	
		self.tabPageGeneral.Controls.Add(self.progCalculation)
		
		
	
	'''Show wave information which is stored in GenericData'''
	def ShowWaveInformation(self):
		
		#	Add wave information to the datagridWaves				
		if self.__scenario.GenericData.Waves <> None:
			for WaveClimate in self.__scenario.GenericData.Waves.WaveClimates:				
				self.datagridWaves.Rows.Add(WaveClimate.Hs,WaveClimate.Tp,WaveClimate.Dir,WaveClimate.Occurences)
				
			#	Label showing type of waves and depth at wave location
			
			if self.__scenario.GenericData.Waves.IsOffshore:
				self.L3.Text = "Waves are offshore at depth of " + str(self.__scenario.GenericData.Waves.Z) + " m"
			else:
				self.L3.Text = "Waves are nearshore"
	
	'''Check if a slope bathymetry is defined in GenericData. If yes, show the slope ratio'''	
	def ShowSlopeBathymetry(self):	 
		#	Check bathymetry type
		
		bathy = self.__scenario.GenericData.Bathymetry
		
		if bathy <> None:			
			if bathy.BathymetryType == "Slope":
				self.txtBathymetry.Text = str(bathy.SlopeValue)
				self.txtBathymetry.Enabled = False
				return
		
		#	No slope in General data, show the slopeValue which is stored in InputData
		
		slopeNumber = float(1)/float(self.InputValues.beach_slope)		
		self.txtBathymetry.Text = str(slopeNumber)

	def CreateControlsGeneral(self):
		
		#	 Combobox for choice of calculation formula
				
		self.labelFormula = _swf.Label()
		self.labelFormula.Text = "Choose formula:"
		self.labelFormula.Location = _drawing.Point(0.1*self.label_width,1.8*self.vert_spacing)
		self.labelFormula.Width = 2*self.label_width
		self.labelFormula.TextAlign = _drawing.ContentAlignment.MiddleLeft
		self.tabPageGeneral.Controls.Add(self.labelFormula)	
				
		self.L7 = _swf.ComboBox()
		self.L7.Items.Add('Kamphuis')
		self.L7.Items.Add('CERC')
		#self.L7.Items.Add('van Rijn (not implemented yet)')		
		self.L7.Text = self.InputValues.formula
		self.L7.Location = _drawing.Point(0.1*self.label_width,2.6*self.vert_spacing)
		self.L7.Width = 2*self.label_width
		self.L7.TextChanged += lambda s,e : self.set_formula()
		self.tabPageGeneral.Controls.Add(self.L7)
		
		# 	Controls for wave conditions
		
		self.L2 = _swf.Label()
		
		self.L2.Text = "Wave climate (from general data):"
		self.L2.Location = _drawing.Point(0.1*self.label_width,3.4*self.vert_spacing)
		self.L2.Width = 2*self.label_width
		#self.L2.Click += lambda s,e : self.get_wave_data_from_gui()		
		self.tabPageGeneral.Controls.Add(self.L2)
		
		
		#	Datagridview for waves				
		self.datagridWaves = _swf.DataGridView()
		self.datagridWaves.ReadOnly = True
		self.datagridWaves.AllowUserToAddRows = False
		self.datagridWaves.Left = 0.1 * self.label_width
		self.datagridWaves.Top = 4.2*self.vert_spacing
		self.datagridWaves.Width = self.leftPanel.Width - 0.1*self.label_width
		self.datagridWaves.Height = 4.2 * self.vert_spacing	

		#	Add columns to datagridview		
		self.datagridWaves.ColumnCount = 4
		self.datagridWaves.Columns[0].Name = "Height"
		self.datagridWaves.Columns[0].Width = 80
		self.datagridWaves.Columns[1].Name = "Period"
		self.datagridWaves.Columns[1].Width = 80
		self.datagridWaves.Columns[2].Name = "Direction"
		self.datagridWaves.Columns[2].Width = 80
		self.datagridWaves.Columns[3].Name = "Occurence"
		self.datagridWaves.Columns[3].Width = 80
		self.tabPageGeneral.Controls.Add(self.datagridWaves)		
		
		#	Label showing if waves are offshore or nearshore	
		self.L3 = _swf.Label()		
		self.L3.Font = _drawing.Font(self.L3.Font,_drawing.FontStyle.Italic)
		self.L3.Enabled=False
		self.L3.Text = "Waves are offshore"
		self.L3.Left = 0.1*self.label_width
		self.L3.Top = 8.4*self.vert_spacing		
		self.L3.Width = 2.6*self.label_width
		self.tabPageGeneral.Controls.Add(self.L3)		
		
		#	Bathymetry information
		self.labelBathymetry = _swf.Label()
		self.labelBathymetry.Location = _drawing.Point(0.1*self.label_width,9.2*self.vert_spacing)
		self.labelBathymetry.Width = self.label_width
		self.labelBathymetry.Text = "Beach slope: "
		
		self.labelBathymetry2 = _swf.Label()
		self.labelBathymetry2.Location = _drawing.Point(0.1*self.label_width,10*self.vert_spacing)
		self.labelBathymetry2.Width = 0.15*self.label_width
		self.labelBathymetry2.Text = "1:"
		
		self.txtBathymetry = _swf.TextBox()		
		self.txtBathymetry.Location = _drawing.Point(0.25*self.label_width,10*self.vert_spacing)
		self.txtBathymetry.Width = 0.3*self.label_width		
		self.txtBathymetry.TextChanged += lambda s,e : self.set_slope()
		
		self.tabPageGeneral.Controls.Add(self.labelBathymetry)
		self.tabPageGeneral.Controls.Add(self.labelBathymetry2)
		self.tabPageGeneral.Controls.Add(self.txtBathymetry)
		
		
		#	Button for activation of linetool
				
		self.btnDraw = _swf.Button()
		#self.btnDraw.BackColor = Color.LightGray
		self.btnDraw.Text = "Draw a cross-shore transect"
		self.btnDraw.Location = _drawing.Point(0.1*self.label_width,10.8*self.vert_spacing)
		self.btnDraw.Width = 2*self.label_width
		self.btnDraw.Click += lambda s,e : self.add_CS_profile()
		self.tabPageGeneral.Controls.Add(self.btnDraw)
		
			
	def CreateControlsParameters(self):
		
		#self.tabPageParameters.Font = _drawing.Font(self.tabPageParameters.Font.FontFamily, 10)
		self.tabPageParameters.Dock = _swf.DockStyle.Fill
		
		#	List of parameters
		lbl_heading = _swf.Label()
		lbl_heading.Text = "Choose parameter values:"
		lbl_heading.Location = _drawing.Point(0.1*self.label_width,1.8*self.vert_spacing)
		lbl_heading.Width = 1.6*self.label_width
		lbl_heading.TextAlign = _drawing.ContentAlignment.MiddleLeft
		self.tabPageParameters.Controls.Add(lbl_heading)	
			
			
		# 1.1 Gamma input
		text_gamma = _swf.Label()
		text_gamma.Text = "Breaker index:"
		text_gamma.Location = _drawing.Point(self.window_width/2 - 1.05*self.label_width,2.5*self.vert_spacing)
		text_gamma.Width = 0.8*self.label_width
		text_gamma.TextAlign = _drawing.ContentAlignment.MiddleRight
		self.tabPageParameters.Controls.Add(text_gamma)	
		

		self.nud_gamma = _swf.NumericUpDown()
		self.nud_gamma.DecimalPlaces = 2
		self.nud_gamma.TextAlign = _swf.HorizontalAlignment.Right
		self.nud_gamma.Increment = 0.01 #for increment with dir keys
		self.nud_gamma.Maximum = 0.99 #max bounds
		self.nud_gamma.Minimum = 0.01 #min bounds
		self.nud_gamma.Location = _drawing.Point(self.window_width/2 - 0.25*self.label_width+self.spacer_width/2,2.5*self.vert_spacing)
		self.nud_gamma.Width = 0.5*self.label_width
		self.nud_gamma.Value = self.InputValues.gamma #default number
		self.nud_gamma.ValueChanged += lambda s,e : self.set_gamma()
		self.tabPageParameters.Controls.Add(self.nud_gamma)
		
		text_gamma_unit = _swf.Label()
		text_gamma_unit.Text = "[-]"
		text_gamma_unit.Location = _drawing.Point(self.window_width/2 + 0.25*self.label_width+2*self.spacer_width/2,2.5*self.vert_spacing)
		text_gamma_unit.Width = 0.5*self.label_width
		text_gamma_unit.TextAlign = _drawing.ContentAlignment.MiddleLeft
		self.tabPageParameters.Controls.Add(text_gamma_unit)
		
		# 1.2 DOC input
		
		text_doc = _swf.Label()
		text_doc.Text = "Depth of closure:"
		text_doc.Location = _drawing.Point(self.window_width/2 - 1.05*self.label_width,3.2*self.vert_spacing)
		text_doc.Width = 0.8*self.label_width
		text_doc.TextAlign = _drawing.ContentAlignment.MiddleRight
		self.tabPageParameters.Controls.Add(text_doc)
		
		self.nud_doc = NumericUpDown()
		self.nud_doc.DecimalPlaces = 2
		self.nud_doc.TextAlign = _swf.HorizontalAlignment.Right
		self.nud_doc.Increment = 0.1 #for increment with dir keys
		self.nud_doc.Maximum = 10 #max bounds
		self.nud_doc.Minimum = 0.5 #min bounds
		self.nud_doc.Location = _drawing.Point(self.window_width/2 - 0.25*self.label_width+self.spacer_width/2,3.2*self.vert_spacing)
		self.nud_doc.Width = 0.5*self.label_width
		self.nud_doc.Value = self.InputValues.doc #default number
		self.nud_doc.ValueChanged += lambda s,e : self.set_doc()
		self.tabPageParameters.Controls.Add(self.nud_doc)
		
		text_doc_unit = _swf.Label()
		text_doc_unit.Text = "[mtr.]"
		text_doc_unit.Location = _drawing.Point(self.window_width/2 + 0.25*self.label_width+2*self.spacer_width/2,3.2*self.vert_spacing)
		text_doc_unit.Width = 0.5*self.label_width
		text_doc_unit.TextAlign = _drawing.ContentAlignment.MiddleLeft
		self.tabPageParameters.Controls.Add(text_doc_unit)
		
		# 1.3 d50 input:
		
		text_d50 = _swf.Label()
		text_d50.Text = "d50:"
		text_d50.Location = _drawing.Point(self.window_width/2 - 1.05*self.label_width,3.9*self.vert_spacing)
		text_d50.Width = 0.8*self.label_width
		text_d50.TextAlign = _drawing.ContentAlignment.MiddleRight
		self.tabPageParameters.Controls.Add(text_d50)
		
		self.nud_d50 = _swf.NumericUpDown()
		self.nud_d50.DecimalPlaces = 1
		self.nud_d50.TextAlign = _swf.HorizontalAlignment.Right
		self.nud_d50.Increment = 10 #for increment with dir keys
		self.nud_d50.Maximum = 10000 #max bounds
		self.nud_d50.Minimum = 1 #min bounds
		self.nud_d50.Location = _drawing.Point(self.window_width/2 - 0.25*self.label_width+self.spacer_width/2,3.9*self.vert_spacing)
		self.nud_d50.Width = 0.5*self.label_width
		self.nud_d50.Value = self.InputValues.d50 * 1000000 #default number
		self.nud_d50.ValueChanged += lambda s,e : self.set_d50()
		self.tabPageParameters.Controls.Add(self.nud_d50)
		
		text_d50_unit = _swf.Label()
		text_d50_unit.Text = "[micrometer]"
		text_d50_unit.Location = _drawing.Point(self.window_width/2 + 0.25*self.label_width+2*self.spacer_width/2,3.9*self.vert_spacing)
		text_d50_unit.Width = 0.70*self.label_width
		text_d50_unit.TextAlign = _drawing.ContentAlignment.MiddleLeft
		self.tabPageParameters.Controls.Add(text_d50_unit)
		
		"""# 1.4 Beach slope input:
		
		text_slope = _swf.Label()
		text_slope.Text = "Beach slope:"
		text_slope.Location = _drawing.Point(self.window_width/2 - 1.05*self.label_width,4.6*self.vert_spacing)
		text_slope.Width = 0.8*self.label_width
		text_slope.TextAlign = _drawing.ContentAlignment.MiddleRight
		self.tabPageParameters.Controls.Add(text_slope)
		
		
		self.nud_slope = _swf.NumericUpDown()
		self.nud_slope.DecimalPlaces = 3
		self.nud_slope.TextAlign = _swf.HorizontalAlignment.Right
		self.nud_slope.Increment = 0.001 #for increment with dir keys
		self.nud_slope.Maximum = 1 #max bounds
		self.nud_slope.Minimum = 0.000001 #min bounds
		self.nud_slope.Location = _drawing.Point(self.window_width/2 - 0.25*self.label_width+self.spacer_width/2,4.6*self.vert_spacing)
		self.nud_slope.Width = 0.5*self.label_width
		self.nud_slope.Value = self.InputValues.beach_slope #default number
		self.nud_slope.ValueChanged += lambda s,e : self.set_slope()
		self.tabPageParameters.Controls.Add(self.nud_slope)
		
		text_slope_unit = Label()
		text_slope_unit.Text = "[-]"
		text_slope_unit.Location = _drawing.Point(self.window_width/2 + 0.25*self.label_width+2*self.spacer_width/2,4.6*self.vert_spacing)
		text_slope_unit.Width = 0.5*self.label_width
		text_slope_unit.TextAlign = _drawing.ContentAlignment.MiddleLeft
		self.tabPageParameters.Controls.Add(text_slope_unit)"""
		
		# 1.5 Rho_s input
		
		text_rho_s = _swf.Label()
		text_rho_s.Text = "Rho_s:"
		text_rho_s.Location = _drawing.Point(self.window_width/2 - 1.05*self.label_width,4.6*self.vert_spacing)
		text_rho_s.Width = 0.8*self.label_width
		text_rho_s.TextAlign = _drawing.ContentAlignment.MiddleRight
		self.tabPageParameters.Controls.Add(text_rho_s)		
		
		self.nud_rho_s = _swf.NumericUpDown()
		self.nud_rho_s.DecimalPlaces = 0
		self.nud_rho_s.TextAlign = _swf.HorizontalAlignment.Right
		self.nud_rho_s.Increment = 5 #for increment with dir keys
		self.nud_rho_s.Maximum = 3000 #max bounds
		self.nud_rho_s.Minimum = 1000 #min bounds
		self.nud_rho_s.Location = _drawing.Point(self.window_width/2 - 0.25*self.label_width+self.spacer_width/2,4.6*self.vert_spacing)
		self.nud_rho_s.Width = 0.5*self.label_width
		self.nud_rho_s.Value = self.InputValues.rho_s #default number
		self.nud_rho_s.ValueChanged += lambda s,e : self.set_rho_s()
		self.tabPageParameters.Controls.Add(self.nud_rho_s)
		
		text_rho_s_unit = _swf.Label()
		text_rho_s_unit.Text = "[kg/m3]"
		text_rho_s_unit.Location = _drawing.Point(self.window_width/2 + 0.25*self.label_width+2*self.spacer_width/2,4.6*self.vert_spacing)
		text_rho_s_unit.Width = 0.5*self.label_width
		text_rho_s_unit.TextAlign = _drawing.ContentAlignment.MiddleLeft
		self.tabPageParameters.Controls.Add(text_rho_s_unit)
		
		# 1.6 Rho_w input
		
		text_rho_w = Label()
		text_rho_w.Text = "Rho_w:"
		text_rho_w.Location = _drawing.Point(self.window_width/2 - 1.05*self.label_width,5.3*self.vert_spacing)
		text_rho_w.Width = 0.8*self.label_width
		text_rho_w.TextAlign = _drawing.ContentAlignment.MiddleRight
		self.tabPageParameters.Controls.Add(text_rho_w)
		
		
		self.nud_rho_w = _swf.NumericUpDown()
		self.nud_rho_w.DecimalPlaces = 0
		self.nud_rho_w.TextAlign = _swf.HorizontalAlignment.Right
		self.nud_rho_w.Increment = 5 #for increment with dir keys
		self.nud_rho_w.Maximum = 1250 #max bounds
		self.nud_rho_w.Minimum = 995 #min bounds
		self.nud_rho_w.Location = _drawing.Point(self.window_width/2 - 0.25*self.label_width+self.spacer_width/2,5.3*self.vert_spacing)
		self.nud_rho_w.Width = 0.5*self.label_width
		self.nud_rho_w.Value = self.InputValues.rho_w #default number
		self.nud_rho_w.ValueChanged += lambda s,e : self.set_rho_w()
		self.tabPageParameters.Controls.Add(self.nud_rho_w)
		
		text_rho_w_unit = _swf.Label()
		text_rho_w_unit.Text = "[kg/m3]"
		text_rho_w_unit.Location = _drawing.Point(self.window_width/2 + 0.25*self.label_width+2*self.spacer_width/2,5.3*self.vert_spacing)
		text_rho_w_unit.Width = 0.5*self.label_width
		text_rho_w_unit.TextAlign = _drawing.ContentAlignment.MiddleLeft
		self.tabPageParameters.Controls.Add(text_rho_w_unit)
		
		# 1.7 porosity input
		
		text_por = _swf.Label()
		text_por.Text = "Porosity:"
		text_por.Location = _drawing.Point(self.window_width/2 - 1.05*self.label_width,6*self.vert_spacing)
		text_por.Width = 0.8*self.label_width
		text_por.TextAlign = _drawing.ContentAlignment.MiddleRight
		self.tabPageParameters.Controls.Add(text_por)		
		
		self.nud_por = _swf.NumericUpDown()
		self.nud_por.DecimalPlaces = 2
		self.nud_por.TextAlign = _swf.HorizontalAlignment.Right
		self.nud_por.Increment = 0.01 #for increment with dir keys
		self.nud_por.Maximum = 0.99 #max bounds
		self.nud_por.Minimum = 0.01 #min bounds
		self.nud_por.Location = _drawing.Point(self.window_width/2 - 0.25*self.label_width+self.spacer_width/2,6*self.vert_spacing)
		self.nud_por.Width = 0.5*self.label_width
		self.nud_por.Value = self.InputValues.porosity #default number
		self.nud_por.ValueChanged += lambda s,e : self.set_por()
		self.tabPageParameters.Controls.Add(self.nud_por)
		
		text_por_unit = _swf.Label()
		text_por_unit.Text = "[-]"
		text_por_unit.Location = _drawing.Point(self.window_width/2 + 0.25*self.label_width+2*self.spacer_width/2,6*self.vert_spacing)
		text_por_unit.Width = 0.5*self.label_width
		text_por_unit.TextAlign = _drawing.ContentAlignment.MiddleLeft
		self.tabPageParameters.Controls.Add(text_por_unit)
		
		
		
		# 1. Active height

		self.text_active_height = _swf.Label()
		self.text_active_height.Text = "Active height:"
		self.text_active_height.Location = _drawing.Point(self.window_width/2 - 1.05*self.label_width,6.7*self.vert_spacing)
		self.text_active_height.Width = 0.8*self.label_width
		self.text_active_height.TextAlign = _drawing.ContentAlignment.MiddleRight		
		self.tabPageParameters.Controls.Add(self.text_active_height)
		
		
		self.nud_active_height = _swf.NumericUpDown()
		self.nud_active_height.DecimalPlaces = 1
		self.nud_active_height.TextAlign = _swf.HorizontalAlignment.Right
		self.nud_active_height.Increment = 0.1 #for increment with dir keys
		self.nud_active_height.Maximum = 100 #max bounds
		self.nud_active_height.Minimum = 1 #min bounds
		self.nud_active_height.Location = _drawing.Point(self.window_width/2 - 0.25*self.label_width+self.spacer_width/2,6.7*self.vert_spacing)
		self.nud_active_height.Width = 0.5*self.label_width
		self.nud_active_height.Value = self.InputValues.active_height #default number
		self.nud_active_height.ValueChanged += lambda s,e : self.set_active_height()
		self.tabPageParameters.Controls.Add(self.nud_active_height)
		
		self.txt_active_height_unit = _swf.Label()
		self.txt_active_height_unit.Text = "[m]"
		self.txt_active_height_unit.Location = _drawing.Point(self.window_width/2 + 0.25*self.label_width+2*self.spacer_width/2,6.7*self.vert_spacing)
		self.txt_active_height_unit.Width = 0.5*self.label_width
		self.txt_active_height_unit.TextAlign = _drawing.ContentAlignment.MiddleLeft
		self.tabPageParameters.Controls.Add(self.txt_active_height_unit)
		
		# 2. Number of coastline points 
		
		self.text_npoints = _swf.Label()
		self.text_npoints.Text = "N points:"
		self.text_npoints.Location = _drawing.Point(self.window_width/2 - 1.05*self.label_width,7.4*self.vert_spacing)
		self.text_npoints.Width = 0.8*self.label_width
		self.text_npoints.TextAlign = _drawing.ContentAlignment.MiddleRight
		self.tabPageParameters.Controls.Add(self.text_npoints)
		
		self.nud_npoints = _swf.NumericUpDown()
		self.nud_npoints.DecimalPlaces = 0
		self.nud_npoints.TextAlign = _swf.HorizontalAlignment.Right
		self.nud_npoints.Increment = 1 #for increment with dir keys
		self.nud_npoints.Maximum = 1000 #max bounds
		self.nud_npoints.Minimum = 1 #min bounds
		self.nud_npoints.Location = _drawing.Point(self.window_width/2 - 0.25*self.label_width+self.spacer_width/2,7.4*self.vert_spacing)
		self.nud_npoints.Width = 0.5*self.label_width
		self.nud_npoints.Value = self.InputValues.npoints #default number
		self.nud_npoints.ValueChanged += lambda s,e : self.set_npoints()
		self.tabPageParameters.Controls.Add(self.nud_npoints)
		
		self.txt_npoints_unit = _swf.Label()
		self.txt_npoints_unit.Text = "[-]"
		self.txt_npoints_unit.Location = _drawing.Point(self.window_width/2 + 0.25*self.label_width+2*self.spacer_width/2,7.4*self.vert_spacing)
		self.txt_npoints_unit.Width = 0.5*self.label_width
		self.txt_npoints_unit.TextAlign = _drawing.ContentAlignment.MiddleLeft
		self.tabPageParameters.Controls.Add(self.txt_npoints_unit)
		
		# 3. Time to compute:
		
		self.text_time = _swf.Label()
		self.text_time.Text = "Total time:"
		self.text_time.Location = _drawing.Point(self.window_width/2 - 1.05*self.label_width,8.1*self.vert_spacing)
		self.text_time.Width = 0.8*self.label_width
		self.text_time.TextAlign = _drawing.ContentAlignment.MiddleRight
		self.tabPageParameters.Controls.Add(self.text_time)
		
		self.nud_time = _swf.NumericUpDown()
		self.nud_time.DecimalPlaces = 0
		self.nud_time.TextAlign = _swf.HorizontalAlignment.Right
		self.nud_time.Increment = 1 #for increment with dir keys
		self.nud_time.Maximum = 10000 #max bounds
		self.nud_time.Minimum = 1 #min bounds
		self.nud_time.Location = _drawing.Point(self.window_width/2 - 0.25*self.label_width+self.spacer_width/2,8.1*self.vert_spacing)
		self.nud_time.Width = 0.5*self.label_width
		self.nud_time.Value = self.InputValues.time #default number
		self.nud_time.ValueChanged += lambda s,e : self.set_time()
		self.tabPageParameters.Controls.Add(self.nud_time)
		
		self.text_time_unit = _swf.Label()
		self.text_time_unit.Text = "[years]"
		self.text_time_unit.Location = _drawing.Point(self.window_width/2 + 0.25*self.label_width+2*self.spacer_width/2,8.1*self.vert_spacing)
		self.text_time_unit.Width = 0.70*self.label_width
		self.text_time_unit.TextAlign = _drawing.ContentAlignment.MiddleLeft
		self.tabPageParameters.Controls.Add(self.text_time_unit)
		
		# 4. Time step:
		
		self.text_time_step = _swf.Label()
		self.text_time_step.Text = "Time step:"
		self.text_time_step.Location = _drawing.Point(self.window_width/2 - 1.05*self.label_width,8.8*self.vert_spacing)
		self.text_time_step.Width = 0.8*self.label_width
		self.text_time_step.TextAlign = _drawing.ContentAlignment.MiddleRight
		self.tabPageParameters.Controls.Add(self.text_time_step)
				
		self.nud_t_step = _swf.NumericUpDown()
		self.nud_t_step.DecimalPlaces = 1
		self.nud_t_step.TextAlign = _swf.HorizontalAlignment.Right
		self.nud_t_step.Increment = 0.1 #for increment with dir keys
		self.nud_t_step.Maximum = 100 #max bounds
		self.nud_t_step.Minimum = 0.1 #min bounds
		self.nud_t_step.Location = _drawing.Point(self.window_width/2 - 0.25*self.label_width+self.spacer_width/2,8.8*self.vert_spacing)
		self.nud_t_step.Width = 0.5*self.label_width
		self.nud_t_step.Value = self.InputValues.time_step #default number
		self.nud_t_step.ValueChanged += lambda s,e : self.set_time_step()
		self.tabPageParameters.Controls.Add(self.nud_t_step)
		
		self.text_time_step_unit = _swf.Label()
		self.text_time_step_unit.Text = "[years]"
		self.text_time_step_unit.Location = _drawing.Point(self.window_width/2 + 0.25*self.label_width+2*self.spacer_width/2,8.8*self.vert_spacing)
		self.text_time_step_unit.Width = 0.5*self.label_width
		self.text_time_step_unit.TextAlign = _drawing.ContentAlignment.MiddleLeft
		self.tabPageParameters.Controls.Add(self.text_time_step_unit)
		
		# Select Boundary conditions (Left)
		self.B4a = _swf.Label()
		self.B4a.Text = "Left boundary:"
		self.B4a.Location = _drawing.Point(self.window_width/2 - self.label_width,9.5*self.vert_spacing)
		self.B4a.Width = self.label_width
		self.tabPageParameters.Controls.Add(self.B4a)
			
		self.B4a_label = _swf.ComboBox()
		self.B4a_label.Items.Add('dS = 0')
		self.B4a_label.Items.Add('S = 0')
		self.B4a_label.Items.Add('S = x (not implemented)')
		self.B4a_label.SelectedIndex = 0
		self.B4a_label.Location = _drawing.Point(self.window_width/2 - self.label_width,10.2*self.vert_spacing)
		self.B4a_label.Width = 0.9*self.label_width
		self.B4a_label.TextChanged += lambda s,e: self.change_leftbnd()
		self.B4a_label.SelectedIndex = self.InputValues.leftbnd 
		self.tabPageParameters.Controls.Add(self.B4a_label)
		
		# Select Boundary conditions (Right)
		self.B4b_label = Label()
		self.B4b_label.Text = "Right boundary:"
		self.B4b_label.Location = _drawing.Point(self.window_width/2,9.5*self.vert_spacing)
		self.B4b_label.Width = 0.9*self.label_width
		
		self.tabPageParameters.Controls.Add(self.B4b_label)
		
		self.B4b = _swf.ComboBox()
		self.B4b.Items.Add('dS = 0')
		self.B4b.Items.Add('S = 0')
		self.B4b.Items.Add('S = x (not implemented)')
		self.B4b.SelectedIndex = 0
		self.B4b.Location = _drawing.Point(self.window_width/2,10.2*self.vert_spacing)
		self.B4b.Width = 0.9*self.label_width
		self.B4b.TextChanged += lambda s,e: self.change_RightBND()
		self.B4b.SelectedIndex = self.InputValues.rightbnd
		self.tabPageParameters.Controls.Add(self.B4b)
		
	
	def SwitchControlsCoastlineEvolution(self,visible):
		self.text_active_height.Visible = visible
		self.nud_active_height.Visible = visible
		self.txt_active_height_unit.Visible = visible
		self.text_npoints.Visible = visible
		self.nud_npoints.Visible = visible
		self.txt_npoints_unit.Visible = visible
		self.text_time.Visible = visible
		self.nud_time.Visible = visible
		self.text_time_unit.Visible = visible
		self.text_time_step.Visible = visible
		self.nud_t_step.Visible = visible
		self.text_time_step_unit.Visible = visible
		self.B4a.Visible = visible
		self.B4a_label.Visible = visible
		self.B4b_label.Visible = visible
		self.B4b.Visible = visible
	
	
	
	
	def change_RightBND(self):
		if self.B4b.SelectedIndex==2:
			self.B4b.SelectedIndex=0
		self.InputValues.rightbnd = self.B4b.SelectedIndex#s.Items[s.SelectedIndex]
		self.CheckToolDataLink()
				
	def change_leftbnd(self):
		if self.B4a_label.SelectedIndex==2:
			self.B4a_label.SelectedIndex=0
		self.InputValues.leftbnd = self.B4a_label.SelectedIndex#s.Items[s.SelectedIndex]
		self.CheckToolDataLink()
			
		
		
	def createMapControl(self):
		self.mapView = MapView() #empty map view
		self.mapView.Dock = DockStyle.Fill #fill the space
		
		#	Add map from Scenario
		
		self.mapView.Map = self.__scenario.GeneralMap
		
		#	Check if Grouplayer is already present
		
		if not self.mapView.Map.Layers.Contains(self.GroupLayer):
			self.mapView.Map.Layers.Add(self.GroupLayer)
		
		# Add the general map (from scenario) to the mapview
		
		self.rightPanel.Controls.Add(self.mapView)
		self.ChildViews.Add(self.mapView)	

		
		# Add message box cross-shore profile
		self.ClickProfile = _swf.Label()
		self.ClickProfile.Text = "Please click the first point at the coastline and the second point offshore You can end with a double click (only the first 2 points are used)"
		self.ClickProfile.Visible = False
		self.ClickProfile.BackColor = Color.White
		self.ClickProfile.BorderStyle = _swf.BorderStyle.FixedSingle
		self.ClickProfile.Location = _drawing.Point(10,25)
		self.ClickProfile.Width = 450
		self.ClickProfile.Height = 30
		self.ClickProfile.TextAlign = _drawing.ContentAlignment.MiddleCenter
				
		self.rightPanel.Controls.Add(self.ClickProfile)
	
	
		#	Check if Grouplayer contains layer 'Cross-shore profiles'
		
		removeLayer = None
		for tempLayer in self.GroupLayer.Layers:
			if tempLayer.Name == "Cross-shore profiles":
				removeLayer = tempLayer				
		
		if removeLayer <> None:
			self.GroupLayer.Layers.Remove(removeLayer)
		
	
		# Add layer for cross-shore profile
		self.LayerCrossShoreProfiles = _MapFunctions.CreateLayerForFeatures("Cross-shore profiles", [], None)
		_MapFunctions.ShowLayerLabels(self.LayerCrossShoreProfiles, "title")
		self.LayerCrossShoreProfiles.Style.Line.Color = Color.Black
		self.LayerCrossShoreProfiles.Style.Line.Width = 5
		self.LayerCrossShoreProfiles.Style.Line = self.LayerCrossShoreProfiles.Style.Line 
		#self.LayerCrossShoreProfiles.Style.Line.DashStyle = _drawing.DashStyle.Dot
		self.LayerCrossShoreProfiles.FeatureEditor = _Feature2DEditor(None)
		self.LayerCrossShoreProfiles.DataSource.CoordinateSystem = _MapFunctions.Map.CoordinateSystemFactory.CreateFromEPSG(3857)
		
		
		self.GroupLayer.Layers.Add(self.LayerCrossShoreProfiles)
		self.__scenario.GeneralMap.BringToFront(self.LayerCrossShoreProfiles)
		
		_CoDesMapTools.ShowLegend(self.mapView)
		
		self.LayerCrossShoreProfiles.RenderOrder = 0
		self.LayerCrossShoreProfiles.ShowInLegend = True
	
	
		self.newLineTool = _NewLineTool(None, "New polygon tool", CloseLine = False)	
		# Define layer filter for self.newLineTool (layer to add the new features to)
		self.newLineTool.DrawLineDistanceHints = True
		# Add tool
		self.mapView.MapControl.Tools.Add(self.newLineTool)
				
			
	def add_CS_profile(self):
		
		# Create a layer for the polygons if not existing yet:
		self.ClickProfile.Visible = True
		self.mapView.MapControl.Focus()
		
		# Create new line tool for line (CloseLine = False)
		self.mapView.MapControl.ActivateTool(self.newLineTool)
		
		self.newLineTool.LayerFilter = lambda l : l == self.LayerCrossShoreProfiles
		
		self.ClickProfile.BringToFront()
		
	def add_Coastline(self):
	
		# Create a layer for the polylines if not existing yet:
		self.ClickCoastline.Visible = True
		self.ClickCoastline.BringToFront()
		self.mapView.MapControl.Focus()
		
		# Create new line tool for line (CloseLine = False)
		self.mapView.MapControl.ActivateTool(self.newLineTool)
		
		self.newLineTool.LayerFilter = lambda l : l == self.LAY_CE
	
	
	
	def StartCalculation(self):
				
		#	Add Waves object to InputValues
		
		if self.__scenario.GenericData.Waves <> None:
			self.InputValues.Waves = self.__scenario.GenericData.Waves
		else:
			self.lblMessage.ForeColor = _drawing.Color.Red
			self.lblMessage.Text = "Please add Waves information"
			return		
		
		# Erase previous output
		self.OutputValues.CoastX  = []
		self.OutputValues.CoastY               = []
		self.OutputValues.CoastLon             = []
		self.OutputValues.CoastLat             = []
		self.OutputValues.Coastline_utm        = []
		self.OutputValues.Coastline_utm_codes  = []
		self.OutputValues.Years	 			  = []
		self.OutputValues.Time				  = []
		
		# Remove message
		self.ClickProfile.Visible = False

		self.GenerateGeometriesUTM()
		#_swf.MessageBox.Show("Geometries converted to UTM")
		
		#	Before calculation, save input data to Tooldata

		self.__scenario.ToolData['coastlinedevelopment'] = _CoastlineDevelopmentData(self.InputValues)
		
		
		
		if self.InputValues.CalculationType == 2:
			""" Start Coastline Evolution Engine """
			
			_swf.MessageBox.Show("Calculation might take a few minutes")
			#dr = _swf.MessageBox.Show("Are you happy now?", 
            #          "Mood Test", _swf.MessageBoxButtons.YesNo)
			
			self.lblMessage.ForeColor = _drawing.Color.Black
			self.lblMessage.Text = "Calculating..."
			self.Refresh()
			
			#	Show progressbar
			self.progCalculation.Visible = True
			_CoastlineEvolution.coastline_engine(self.InputValues,self.OutputValues)
			self.lblMessage.ForeColor = _drawing.Color.Green
			self.lblMessage.Text = "Done"
			self.Refresh()
			
			self.progCalculation.Visible = False
			
			_swf.MessageBox.Show("Calculation done")
			
			self.PlotCoastlineEvolution()
		else:
			""" Start Longshore Transport Engine """	
			
			if not self.InputValues.Profiles_utm:
				self.lblMessage.Text = "No cross-shore transects found"
				self.lblMessage.ForeColor = _drawing.Color.Red				
				return
			
			self.lblMessage.ForeColor = _drawing.Color.Black
			self.lblMessage.Text = "Calculating..."
			self.Refresh()
			
			_CoastlineEvolution.longshore_transport_engine(self.InputValues,self.OutputValues)
			
			self.lblMessage.ForeColor = _drawing.Color.Green
			self.lblMessage.Text = "Done"
			self.Refresh()
			
			self.PlotTransports()
		
	"""def start_to_compute_CE():
		# Remove previous output layers
		RemLay = map.Map.GetLayerByName("Coastline Development")
		self.mapView.Map.Layers.Remove(RemLay)
		
		# Add layer for output
		LayOutput = CreateLayerForFeatures("Coastline Development", [], CreateCoordinateSystem(3857))
		self.mapView.Map.Layers.Add(LayOutput)
		
		# Calculate and plot intermediate results
		#coastline_engine()
		
		# Plot final results
		self.plot_coastline_evolution()"""
	
	def update_map_plot(self):
		# Delete the old basepoints:
		inds_to_rem = []
		for ind in range(0,len(self.mapView.Map.Layers)):
			if self.mapView.Map.Layers[ind].Name == "Basepoints":
				inds_to_rem.append(ind)
		inds_to_rem.reverse()
		if len(inds_to_rem)>0:
			for ind in inds_to_rem:
				self.mapView.Map.Layers.Remove(self.mapView.Map.Layers[ind])
		
		for feature in self.LayerCrossShoreProfiles.DataSource.Features:
			start_point = feature.Geometry.Coordinates.Get(0)
			end_point   = feature.Geometry.Coordinates.Get(1)
			
			basepoint_features = []
			basepoint_features.append(_Feature(Geometry = _MapFunctions.CreatePointGeometry(start_point.X,start_point.Y)))
			basepoint_features[-1].Attributes = _DictionaryFeatureAttributeCollection()
			basepoint_features[-1].Attributes['title'] = str(int(np.mod(90 + (-(180.0/np.pi) * np.arctan2((end_point.Y - start_point.Y),(end_point.X - start_point.X))),360.0)))  + " deg. N"
			
			LAY_BASE = _MapFunctions.CreateLayerForFeatures("Basepoints", basepoint_features, _MapFunctions.CreateCoordinateSystem(3857))
			self.mapView.Map.Layers.Insert(0,LAY_BASE)
			_MapFunctions.ShowLayerLabels(LAY_BASE, "title")
			if (np.mod(90 + (-(180.0/np.pi) * np.arctan2((end_point.Y - start_point.Y),(end_point.X - start_point.X))),360.0) < 90.0) or (np.mod(90 + (-(180.0/np.pi) * np.arctan2((end_point.Y - start_point.Y),(end_point.X - start_point.X))),360.0) > 270.0):
				LAY_BASE.LabelLayer.Style.VerticalAlignment = VerticalAlignmentEnum.Bottom
			else:
				LAY_BASE.LabelLayer.Style.VerticalAlignment = VerticalAlignmentEnum.Top
	
	def update_CE_map_plot(self):
		# Delete the old basepoints:
		inds_to_rem = []
		for ind in range(0,len(map.Map.Layers)):
			if map.Map.Layers[ind].Name == "Basepoints":
				inds_to_rem.append(ind)
		inds_to_rem.reverse()
		if len(inds_to_rem)>0:
			for ind in inds_to_rem:
				map.Map.Layers.Remove(map.Map.Layers[ind])
		
		"""for feature in self.LAY_CE.DataSource.Features:
			start_point = feature.Geometry.Coordinates.Get(0)
			end_point   = feature.Geometry.Coordinates.Get(1)
			
			basepoint_features = []
			basepoint_features.append(Feature(Geometry = CreatePointGeometry(start_point.X,start_point.Y)))
			basepoint_features[-1].Attributes = DictionaryFeatureAttributeCollection()
			basepoint_features[-1].Attributes['title'] = str(int(np.mod(90 + (-(180.0/np.pi) * np.arctan2((end_point.Y - start_point.Y),(end_point.X - start_point.X))),360.0)))  + " deg. N"
			
			LAY_BASE = CreateLayerForFeatures("Basepoints", basepoint_features, CreateCoordinateSystem(3857))
			map.Map.Layers.Insert(0,LAY_BASE)
			ShowLayerLabels(LAY_BASE, "title")
			if (np.mod(90 + (-(180.0/np.pi) * np.arctan2((end_point.Y - start_point.Y),(end_point.X - start_point.X))),360.0) < 90.0) or (np.mod(90 + (-(180.0/np.pi) * np.arctan2((end_point.Y - start_point.Y),(end_point.X - start_point.X))),360.0) > 270.0):
				LAY_BASE.LabelLayer.Style.VerticalAlignment = VerticalAlignmentEnum.Bottom
			else:
				LAY_BASE.LabelLayer.Style.VerticalAlignment = VerticalAlignmentEnum.Top"""
	
	'''Create geographic input for the engine'''
	def GenerateGeometriesUTM(self):
		self.newLineTool.IsActive = False		
		
		#	Initialize empty lists of coordinate pairs
		self.InputValues.Profiles_utm = []
		self.InputValues.Profiles_utm_codes = []
		self.InputValues.Coastline_utm = []
		self.InputValues.Coastline_utm_codes = []
		self.InputValues.Breakwaters_utm = []
		
		sourceEPSG = self.__scenario.GenericData.SR_EPSGCode		
		
		# 	Transform cross-shore profile to UTM
		
		utm_error = False
		for feature in self.LayerCrossShoreProfiles.DataSource.Features:
			if feature.Geometry.NumPoints >= 2:
				start_point = feature.Geometry.Coordinates.Get(0)
				end_point   = feature.Geometry.Coordinates.Get(1)
				x1_utm,y1_utm,CS_code_compute_1 = _CoordUtilities.ConvertPointGeometryToUTM(start_point,sourceEPSG)
				x2_utm,y2_utm,CS_code_compute_2 = _CoordUtilities.ConvertPointGeometryToUTM(end_point,sourceEPSG)
				
				if CS_code_compute_1 != CS_code_compute_2:
					if ((((end_point.X - start_point.X)**2) + ((end_point.Y - start_point.Y)**2))**(1.0/2.0)) < 50000:
						# We can agree on this, though just make sure the points are now both in the same CS_code_compute_1:
						x1_utm,y1_utm,CS_code_compute_temp1  = _CoordUtilities.ConvertPointGeometryToUTM(start_point,sourceEPSG,CS_code_compute_1)
						x2_utm,y2_utm,CS_code_compute_temp2	= _CoordUtilities.ConvertPointGeometryToUTM(end_point,sourceEPSG,CS_code_compute_2)
					else:
						utm_error = True
						self.lblMessage.Text = "Please define a smaller profile"
						return
				
				self.InputValues.Profiles_utm.append([[x1_utm,y1_utm],[x2_utm,y2_utm]])
				#self.InputValues.Profiles_utm.append()
				self.InputValues.Profiles_utm_codes.append(CS_code_compute_1)
				
				if feature.Geometry.NumPoints >= 3:
					feature.Geometry = _MapFunctions.CreateLineGeometry([[start_point.X,start_point.Y],[end_point.X,end_point.Y]])
		
		# 	Transform coastline features to UTM
		
		if self.__scenario.GenericData.Coastline <> None:
			
			if self.__scenario.GenericData.Coastline.CoastlineGeometry <> None:
				#	Convert first point to define UTM zone	
				
				firstPoint = self.__scenario.GenericData.Coastline.CoastlineGeometry.Coordinates.Get(0)
				x_utm_first,y_utm_first,CS_code_first = _CoordUtilities.ConvertPointGeometryToUTM(firstPoint,sourceEPSG)
				
				
				#	Loop through all vertices of the coastline				
				for coordinate in self.__scenario.GenericData.Coastline.CoastlineGeometry.Coordinates:					
					x_utm,y_utm,CS_code_compute_1 = _CoordUtilities.ConvertPointGeometryToUTM(coordinate,sourceEPSG,CS_code_first)
					self.InputValues.Coastline_utm.append([x_utm,y_utm])				
					self.InputValues.Coastline_utm_codes.append(CS_code_first)
			else:
				self.lblMessage.Text = "Please define a coastline first"
				self.lblMessage.ForeColor = _drawing.Color.Red
				return	
		else:
			self.lblMessage.Text = "Please define a coastline first"			
			self.lblMessage.ForeColor = _drawing.Color.Red
			return
		
		
		# 	Transform breakwater features to UTM
				
		if len(self.__scenario.GenericData.CivilStructures.keys()) > 0:
			
			firstName = self.__scenario.GenericData.CivilStructures.keys()[0]
			firstStructure = self.__scenario.GenericData.CivilStructures[firstName]
			firstGeometry = firstStructure.StructureGeometry
			firstPoint = firstGeometry.Coordinates.Get(0)
					
			x_utm_first,y_utm_first,CS_code_first = _CoordUtilities.ConvertPointGeometryToUTM(firstPoint,sourceEPSG)			
			
			for breakwaterName in self.__scenario.GenericData.CivilStructures.keys():
				civilStructure = self.__scenario.GenericData.CivilStructures[breakwaterName]
				lineGeometry = civilStructure.StructureGeometry
				coordinateList = []
				
				for coordinate in lineGeometry.Coordinates:				
					x_utm,y_utm,CS_code_compute_1 = _CoordUtilities.ConvertPointGeometryToUTM(coordinate,sourceEPSG,CS_code_first)
					coordinateList.append([x_utm,y_utm])
					
				#	Add list of coordinates to list of breakwaters
				self.InputValues.Breakwaters_utm.append(coordinateList)				
		
		
	def PlotCoastlineEvolution(self):
		
		#_swf.MessageBox.Show("Start plotting")
		
		
		 
		
		newFeatures = []
		theme = _CategorialTheme("Years",_VectorStyle())
		Item = []
		
		# Add initial coastline
		feature1 = _Feature()
		feature1.Geometry = _MapFunctions.CreateLineGeometry(self.OutputValues.Coastline_utm[0])
		
		# Convert geometry to map coordinates
		feature1.Geometry = _MapFunctions.TransformGeometry(feature1.Geometry,self.InputValues.Coastline_utm_codes[0],3857)
		
		feature1.Attributes = _DictionaryFeatureAttributeCollection()
		feature1.Attributes.Add("Years","Initial Coastline")
		
		style = _VectorStyle()
		style.Line.Color = _drawing.Color.Black
		style.Line.Width = 3
		style.Line = style.Line # needed to refresh symbol of vectorstyle
		
		# create a themeitem for "abc" features
		abcItem = _CategorialThemeItem()
		abcItem.Category = "Initial Coastline"
		abcItem.Value = "Initial Coastline"
		abcItem.Style = style
		
		Item.append(abcItem)
		
		newFeatures.append(feature1)
		
		#wavesFile = open(r"c:\Temp_CODES\wavesPlotting.txt",'w')
		
		for ind in range(1,len(self.OutputValues.Years)):
			
			#wavesFile.write("Creating feature for timestep " + str(ind))
			#wavesFile.flush()
			
			feature1 = _Feature()
			feature1.Geometry = _MapFunctions.CreateLineGeometry(self.OutputValues.Coastline_utm[ind])
			feature1.Geometry = _MapFunctions.TransformGeometry(feature1.Geometry,self.InputValues.Coastline_utm_codes[0],3857)
			
			feature1.Attributes = _DictionaryFeatureAttributeCollection()
			feature1.Attributes.Add("Years", str(self.OutputValues.Years[ind]))
		
			style = _VectorStyle()
			style.Line.Color = _ColorBlend.Rainbow7.GetColor(1./len(self.OutputValues.Years)*(ind))
			style.Line.Width = 3
			style.Line = style.Line # needed to refresh symbol of vectorstyle
			
			# create a themeitem for "abc" features
			abcItem = _CategorialThemeItem()
			abcItem.Category = str(self.OutputValues.Years[ind])
			abcItem.Value = str(self.OutputValues.Years[ind])
			abcItem.Style = style
			
			Item.append(abcItem)
			
			newFeatures.append(feature1)
		
		#	Check of layer is present in Grouplayer
		
		#wavesFile.write("Checking layers")
		
		removeLayer = None
		for tempLayer in self.GroupLayer.Layers:
			if tempLayer.Name == "Coastline Position":
				removeLayer = tempLayer				
		
		if removeLayer <> None:
			self.GroupLayer.Layers.Remove(removeLayer)
		#_swf.MessageBox.Show('Layer check done!')		
		
		#if self.coastlineLayer <> None:
		#	self.GroupLayer.Layers.Remove(self.coastlineLayer)
		
		self.coastlineLayer = _MapFunctions.CreateLayerForFeatures("Coastline Position", newFeatures, _MapFunctions.CreateCoordinateSystem(3857))
		self.GroupLayer.Layers.Insert(0,self.coastlineLayer)
		
		# create theme for styling (coloring) features based on Name attribute 
		theme.ThemeItems.AddRange(Item)
		
		# assign theme to custom layer
		self.coastlineLayer.Theme = theme
		
		# Add to baseview map	
		self.coastlineLayer.RenderOrder = 0
		self.coastlineLayer.ShowInLegend = True
		
		#wavesFile.write("Plotting finished")
		#wavesFile.close()
		
				
	def PlotTransports(self):
	
		#GroupLayer.Layers.Clear()
		
		transport_features = []
		
		# Plot transports per transect
		#_swf.MessageBox.Show("%0.2f %0.2f %0.2f"%[self.OutputValues.SedTransPos[0])
		#neg_pos_net = [self.OutputValues.SedTransPos[ind], self.OutputValues.SedTransNeg[ind], self.OutputValues.SedTransNet[ind]]
		
		for ind in range(0,len(self.InputValues.Profiles_utm)):
			#_swf.MessageBox.Show("Plot transect n %f"%ind)
			
			# Get location of cross-shore transects
			transects = np.array(self.InputValues.Profiles_utm[ind])
			#_swf.MessageBox.Show("Get Loc %f"%ind)
			
			# Get positive transport direction
			pos_dir = self.OutputValues.TransectOrientation[ind] - 90
			#_swf.MessageBox.Show("Dir %0.2f"%pos_dir)
			
			# Calculate transect length
			feature_length = np.sqrt((transects[0,0] - transects[1,0])**2 + (transects[0,1] - transects[1,1])**2)
			
			# Calculate location of transport arrow base
			baseX = transects[0,0] - np.sin(np.pi*(self.OutputValues.TransectOrientation[ind]-180)/180) * feature_length * np.array([0.25,0.50,0.75])
			baseY = transects[0,1] - np.cos(np.pi*(self.OutputValues.TransectOrientation[ind]-180)/180) * feature_length * np.array([0.25,0.50,0.75])
			
			# Get transports
			neg_pos_net = [self.OutputValues.SedTransPos[ind], self.OutputValues.SedTransNeg[ind], self.OutputValues.SedTransNet[ind]]
			#_swf.MessageBox.Show("Get Trans %f"%ind)
			
			# Normalize transport arrows
			rel_max_dist_to_L  = feature_length*0.3
			
			# Calculate location of transport arrow head
			endX = baseX + np.sin(np.pi * pos_dir/180) * rel_max_dist_to_L * (neg_pos_net/(np.max(np.abs(neg_pos_net)) + (10**(-20))))
			endY = baseY + np.cos(np.pi * pos_dir/180) * rel_max_dist_to_L * (neg_pos_net/(np.max(np.abs(neg_pos_net)) + (10**(-20))))
			
			# Create features
			for i in range(0,3):
				feature1 = _Feature()
				feature1.Geometry = _MapFunctions.CreateLineGeometry([[baseX[i],baseY[i]],[endX[i],endY[i]]])
				feature1.Geometry = _MapFunctions.TransformGeometry(feature1.Geometry,self.InputValues.Profiles_utm_codes[0],3857)
				feature1.Attributes = _DictionaryFeatureAttributeCollection()
				feature1.Attributes['title'] = str(int(np.abs(neg_pos_net[i]))) + " m3/yr."
				#_swf.MessageBox.Show("Get Feature %f"%i)
				
				transport_features.append(feature1)
		
		removeLayer = None
		for tempLayer in self.GroupLayer.Layers:
			if tempLayer.Name == "Transport arrows and values":
				removeLayer = tempLayer				
		
		if removeLayer <> None:
			self.GroupLayer.Layers.Remove(removeLayer)
			
		self.transportLayer = _MapFunctions.CreateLayerForFeatures("Transport arrows and values", transport_features, _MapFunctions.CreateCoordinateSystem(3857))	
		style_var = self.transportLayer.Style
		self.transportLayer.Style.Line.Color    = _drawing.Color.LightSeaGreen
		self.transportLayer.Style.Line.Width    = 10
		self.transportLayer.Style.Line.EndCap   = _drawing.Drawing2D.LineCap.ArrowAnchor
		 
		_MapFunctions.ShowLayerLabels(self.transportLayer, "title")
		self.GroupLayer.Layers.Insert(0,self.transportLayer)
		
		self.__scenario.GeneralMap.BringToFront(self.transportLayer)
		
		
		#_MapFunctions.ZoomToLayer(transport_features_layer)
	
	def SetAnchoring(self):				
		self.progCalculation.Anchor = _swf.AnchorStyles.Left | _swf.AnchorStyles.Right | _swf.AnchorStyles.Top
		self.datagridWaves.Anchor = _swf.AnchorStyles.Left | _swf.AnchorStyles.Top | _swf.AnchorStyles.Right
		
	