#   Copyright notice
#   --------------------------------------------------------------------
#   Copyright (C) 2016 Witteveen+Bos
#       Jochem Boersma
#
#       jochem.boersma@witteveenbos.com
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
#from Scripts.UI_Examples.ClickTwiceMapTool import *
import os
import clr
clr.AddReference("System.Windows.Forms")
from System.Windows.Forms import DateTimePickerFormat, MessageBox, HorizontalAlignment, TabPage, Padding, MessageBox
from System.Windows.Forms import DataGridView, FolderBrowserDialog, DialogResult

from Scripts.UI_Examples.View import *
from Libraries.ChartFunctions import *
from Libraries.MapFunctions import *
#from Scripts.UI_Examples.Shortcuts import *


import Scripts.LinearWaveTheory as lwt
#import Scripts.BathymetryData as bmd
#import Scripts.BreakwaterDesign as bwd
import Scripts.TidalData as td
#import Scripts.CoastlineDevelopment as cd
#import Scripts.WaveWindData as wwd

from Scripts.LinearWaveTheory.testfunctie import *


#region load libraries
from datetime import datetime
import System.Drawing as s
import Scripts.TidalData as td
from Libraries.MapFunctions import *
#endregion






def initiateLinWaveTheory():

    # Create an empty view
    view = View()
    view.Text = "Linear Wave Theory"
    
    """
    # Create a mapview
    mapview = MapView()
    mapview.Dock = DockStyle.Top
    mapview.Map.Layers.Add(CreateSatelliteImageLayer())
    """
    
    """
    getProfileStartEnd = GetTwoMapCoordinatesTool()
    getProfileStartEnd.FunctionToExecute = None #lwt.plotprofile
    
    mapview.MapControl.SelectTool.IsActive = False
    mapview.MapControl.Tools.Add(getProfileStartEnd)
    getProfileStartEnd.IsActive = True
    
    # Create a chartview
    #plot1 = ChartView()
    #plot1.Chart = chart_all
    #plot1.Dock = DockStyle.Fill
    #
    
    
    # Create chart
    lineSeries = CreateLineSeries([[1,3],[2,5],[3,4],[4,1],[5,3],[6, 4]])
    plot1 = CreateChart([lineSeries])
    
    # Create a chartview
    chartView = ChartView()
    chartView.Chart = plot1
    chartView.Dock = DockStyle.Fill
    view.Controls.Add(chartView)
    
    # Create a label
    label = Label()
    label.Text = "Test"
    label.Dock = DockStyle.Fill
    
    # Create a splitter between chartview and label
    splitContainer = SplitContainer()
    splitContainer.Dock = DockStyle.Fill
    
    splitContainer.Panel1.Controls.Add(chartView)
    splitContainer.Panel2.Controls.Add(label)
    
    # Add controls to view
    view.Controls.Add(splitContainer)
    view.Controls.Add(mapview)        
    
    # Show view
    """
    
    
    
    def active(s,e):
        #Running script
        chart = testfunctie
        view.Controls.Add(chart)
        return chart
    
    # Add button to reactivate tool 
    buttonCalc = Button(Text = "Calc profile")
    buttonCalc.Dock = DockStyle.Top
    buttonCalc.Click += active
    
    view.Controls.Add(buttonCalc)
    
    
    view.Show()
    
    return


"""
#RemoveShortcut("Linear Wave Theory", "CoDeS")
AddShortcut("Linear Wave Theory", "CoDeS", initiateLinWaveTheory, None)
AddShortcut("Tidal data", "CoDeS", mainJosh.main_func, None)
"""


initiateLinWaveTheory()