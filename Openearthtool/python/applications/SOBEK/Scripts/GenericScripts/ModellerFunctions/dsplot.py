"""
This module contains convenience functions for modellers. They are build on the
standard library of scripts of SOBEK (Scripts/Libraries). 

This module is released without guarantee that functions work with future (or past)
SOBEK versions. 

SOBEK 3.4.0


Contact: koen.berends@deltares.nl

The MIT License (MIT)
Copyright (c) 2016 Deltares

Permission is hereby granted, free of charge, to any person obtaining a copy of 
this software and associated documentation files (the "Software"), to deal in 
the Software without restriction, including without limitation the rights to use, 
copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the 
Software, and to permit persons to whom the Software is furnished to do so, subject 
to the following conditions:

The above copyright notice and this permission notice shall be included in all 
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR 
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, 
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE 
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER 
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING 
FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER 
DEALINGS IN THE SOFTWARE.
"""

# -------------------------
#region // Imports 
# -------------------------
# DeltaShell .NET imports
from NetTopologySuite.Extensions.Coverages import NetworkLocation as _NetworkLocation
from NetTopologySuite.Extensions.Coverages import FeatureCoverage as _FeatureCoverage
from NetTopologySuite.Extensions.Coverages import NetworkCoverage as _NetworkCoverage

from System.Drawing import FontStyle, Font, GraphicsUnit, Text, Color
from System.Drawing.Drawing2D import DashStyle
import DeltaShell.Plugins.DelftModels as _DM

import DeltaShell.Plugins.NetworkEditor.Gui.Forms.CrossSectionView.ProfileMutators.ZWProfileMutator as zw
import DeltaShell.Plugins.NetworkEditor.Gui.Forms.CaseAnalysis.NetworkCoverageOperations as NCO
from DelftTools.Controls.Swf.Charting.Series import ChartSeriesFactory as _ChartSeriesFactory
from DelftTools.Hydro.Structures import Weir

# SOBEK specific functions 
try:
	from DeltaShell.Sobek.Readers.Readers import HisFileReader
except ImportError:
	print "SOBEK not detected. SOBEK related functions will not be available"

# FM specific functions (Warning will be raised with versions pre SOBEK 3.4)
try:
	import DeltaShell.Plugins.FMSuite as _FM
except:
	print "Flow FM not detected. Flow FM related functions will not be available"

# Python standard library import
from datetime import datetime, timedelta
import os
import numpy as np

# DeltaShell Python library import
from Libraries import ChartFunctions
from Libraries import Conversions 
from Libraries import StandardFunctions as SF
from Libraries import SobekWaterFlowFunctions as SWFF
#endregion

# -------------------------
#region // Module meta information

__author__ = "Koen Berends"
__copyright__ = "Copyright 2016, University of Twente & Deltares"
__credits__ = ["Koen Berends"]
__license__ = "no license (restricted)"
__version__ = "$Revision$"
__maintainer__ = "Koen Berends"
__email__ = "koen.berends@deltares.nl"
__status__ = "Prototype"
#endregion
# -------------------------

# -------------------------
#region // Plotting functions
def plot(PlotElements, title = ' '):
    """
    INPUT
    PlotElements    : list of plottable object(s). Make these objects with 
                      the 'drawline' function. 
                      
    OUTPUT
    chart           : chart handle
    
    EXAMPLE
    # Create a line object
    line = drawline([0,1,2], [0,1,2])
    
    # Create a chart
    h = plot([line])

    # Change chart layout
    h.Title = "Effect of lowering of the floodplain"
    
    # Show chart
    OpenView(h)
    """
    
    try:
        assert type(PlotElements) == list
    except AssertionError:
        print 'expected list, got %s' %(type(PlotElements))
        raise AssertionError

    chart = ChartFunctions.CreateChart(PlotElements)
    chart.Title = title
    chart.TitleVisible = True
    chart.Legend.Visible = True
    chart.BackGroundColor = Color.Silver
    OpenView(chart)
    return chart

def drawpatch(x, y, color = (255, 0, 0), width = 5):
    try:
        assert type(x) == list
        assert type(y) == list
    except AssertionError:
        print 'expected lists, got %s and %s' %(type(x), type(y))
        raise AssertionError
    
    if type(x[0]) == datetime:
        x = ConvertToDotNetDateTime(x)
    xylist = [[ix, y[i]] for i, ix in enumerate(x)]
    patchSeries = ChartFunctions.AddValuesToSeries(xylist, _ChartSeriesFactory.CreatePolygonSeries())
    patchSeries.Color = Color.FromArgb(color[0], color[1], color[2])
    return patchSeries

def drawline(x, y, color = (100, 100, 255), width = 5, title = 'line1'):
    """
    Draws a line object
    
    INPUT
    x :list
    y : list
    
    optional inpit
    color : tuple of colors (base 256)
    width : int, linewidth
    
    OUTPUT
    line object
    """

    if type(x[0]) == datetime:
        x = [Conversions.ConvertToDotNetDateTime(i) for i in x]
    xylist = [[ix, y[i]] for i, ix in enumerate(x)]
    lineSeries = ChartFunctions.CreateLineSeries(xylist)
    lineSeries.Color = Color.FromArgb(color[0], color[1], color[2])
    lineSeries.Width = width
    lineSeries.Title = title
    lineSeries.PointerVisible = False
    return lineSeries
    
def OpenView(data):
    """
    Opens a view for the provided data
    
    Note: this function is also in the 'StandardFunctions' library
    """
    if (not Gui.DocumentViewsResolver.CanOpenViewFor(data)):
        print "No view for " + str(data)
    else:
        Gui.CommandHandler.OpenView(data)
        return Gui.DocumentViews.ActiveView

#endregion
# -------------------------
