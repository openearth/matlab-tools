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
#========================
#load libraries
#========================

import clr
clr.AddReference("System.Windows.Forms")
clr.AddReference("System.Drawing")

from Scripts.GeneralData.Views.BaseView import *
from Scripts.GeneralData.Views.BathymetryView import BathymetryView as _BathymetryView
from Scripts.GeneralData.Views.WaveWindViewRefactor import WaveWindView as _WaveWindView
from Scripts.GeneralData.Views.StructureView import StructureView as _StructureView
from Scripts.GeneralData.Views.CoastlineView import CoastlineView as _CoastlineView
import Scripts.TidalData.Views.TideView as _TideView

from Scripts.GeneralData.Entities import Scenario as _Scenario
from Scripts.GeneralData.Entities import Bathymetry as _Bathymetry
import System.Drawing as _Draw
import System.Windows.Forms as _swf
from System.Windows.Forms import MessageBox

class GeneralDataView(View):
	
	def __init__(self, scenario):
		View.__init__(self)
		self.__scenario = scenario
		self.Text = "General data"
		self.Dock = _swf.DockStyle.Fill
				
		#	Make tabcontrol
		
		self.ChildViewsDict = dict()
		self.MapViewsDict = dict()
		self.MakeTabcontrol()
		
	
	def InitializeForScenario(self):
		for childView in self.ChildViewsDict.itervalues():
			#if (hasAttr(childView, "InitializeForScenario"):
			childView.InitializeForScenario()
	
	def MakeTabcontrol(self):
		self.tabControl = _swf.TabControl()
		
		self.tabControl.Dock = _swf.DockStyle.Fill

		
		#	Create tabpages		 
		
		tabPage1 = _swf.TabPage()
		tabPage1.Text = "Coastline"
		newCoastlineView = _CoastlineView(self.__scenario)		
		newCoastlineView.Dock = _swf.DockStyle.Fill
		self.ChildViewsDict[1] = newCoastlineView
		self.MapViewsDict[1] = newCoastlineView.mapView
		tabPage1.Controls.Add(newCoastlineView)
		
		tabPage2 = _swf.TabPage()
		tabPage2.Text = "Structure"
		newStructureView = _StructureView(self.__scenario)
		newStructureView.Dock = _swf.DockStyle.Fill
		self.ChildViewsDict[2] = newStructureView
		self.MapViewsDict[2] = newStructureView.mapView
		tabPage2.Controls.Add(newStructureView)
		
		tabPage3 = _swf.TabPage()
		tabPage3.Text = "Bathymetry"
		newBathyView = _BathymetryView(self.__scenario)
		self.ChildViews.Add(newBathyView)
		newBathyView.Dock = _swf.DockStyle.Fill
		self.ChildViewsDict[3] = newBathyView
		self.MapViewsDict[3] = newBathyView.mapPreview
		tabPage3.Controls.Add(newBathyView)
		
		tabPage4 = _swf.TabPage()
		tabPage4.Text = "Waves"
		newWaveView = _WaveWindView(self.__scenario)
		newWaveView.Dock = _swf.DockStyle.Fill
		self.ChildViewsDict[4] = newWaveView
		self.MapViewsDict[4] = newWaveView.map
		tabPage4.Controls.Add(newWaveView)
		
		tabPage5 = _swf.TabPage()
		tabPage5.Text = "Tide"
		newTideView = _TideView.TideView(self.__scenario)
		newTideView.Dock = _swf.DockStyle.Fill
		self.ChildViewsDict[5] = newTideView
		self.MapViewsDict[5] = newTideView.mapView
		tabPage5.Controls.Add(newTideView)
				
		self.tabControl.TabPages.Add(tabPage1)
		self.tabControl.TabPages.Add(tabPage2)
		self.tabControl.TabPages.Add(tabPage3)
		self.tabControl.TabPages.Add(tabPage4)
		self.tabControl.TabPages.Add(tabPage5)
		
		self.tabControl.SelectedIndexChanged +=  lambda s,e : self.tabControl_SelectedIndexChanged(s,e)
		
		self.Controls.Add(self.tabControl)

		#	Activate childview for first page (Coastline)
		
		self.ChildViews.Clear()
		self.ChildViews.Add(self.ChildViewsDict[1])
	
		
	#	Open new view
	
	def tabControl_SelectedIndexChanged(self,s,e):
		
		pageIndex = self.tabControl.SelectedIndex + 1
		
		self.ChildViews.Clear()
		
		control = _swf.Control()
		page = _swf.TabPage
		
		activeMapExtent = self.__scenario.GenericData.GetDataExtent()
		
		for key in self.MapViewsDict.keys():
			self.MapViewsDict[key].MapControl.SelectTool.Clear()
		
		#	Make the view on this page the 'active' childview

		if self.ChildViewsDict.has_key(pageIndex):			
			self.ChildViews.Add(self.ChildViewsDict[pageIndex])
		
		#if self.MapViewsDict.has_key(pageIndex):
		#	self.MapViewsDict[pageIndex].MapControl.SelectTool.Clear()
			#self.MapViewsDict[pageIndex].Map.ZoomToFit(activeMapExtent)
	
	def SetScrollBars(self):
		
		for baseView in self.ChildViewsDict.values():
			baseView.SetScrollBarsLeftPanel(0)

		
	def SetTextboxColor(self,TextBox):		
		if TextBox.Text == "":
			TextBox.BackColor = _Draw.Color.LightGray
		else:
			TextBox.BackColor = _Draw.Color.LightGreen
				
#from Scripts.GeneralData.Utilities.ScenarioPersister import *
#path = "D:\\temp\\newScenario.dat"
#scenarioPersister = ScenarioPersister()
#newScenario = scenarioPersister.LoadScenario(path) 

#newScenario = _Scenario()

#newView = GeneralDataView(newScenario)

#newView.Show()
