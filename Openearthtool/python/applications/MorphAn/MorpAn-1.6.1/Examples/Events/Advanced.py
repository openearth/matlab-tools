#region imports
from Libraries.Utils.Charting import *
from Libraries.MorphAn.Models import *
from DelftTools.Utils import *
from Libraries.Utils.Project import PrintMessage
from DeltaShell.Plugins.MorphAn.Models.CoastalDevelopment.MomentaryCoastLine import MomentaryCoastLineLocation as _MomentaryCoastLineLocation
from DeltaShell.Plugins.MorphAn.Forms.Controls import MorphAnTable as _MorphAnTable
#endregion

"""
This script demostrates the capability of reacting on changes in a view via scripting. It registers a changed selection in a MomentaryCoastLineLocationsView 
(that shows the results of momentary coastline model) and plots / updates some extra line in the plot. In addition it prints the location of the selected MKL result.
To run this example:
	1. Add a workspace with coastal development model, jrk data and boundary conditions
	2. Set the location filter and model selection such that the model calculates valid momentary coastlines
	3. Run the Coastal development model
	4. Go to the output of the underlying momentary coastline model in the treeview
	5. Open a view for these results
	6. Run this script
	7. Change selection in the view and look at the changes in the view and messages
"""

#region MklViewSelectionChanged
def MklViewSelectionChanged(o,e,view,table) : 
	global previousWidth
	
	#region Retrieve selected objects
	"""These can be used in this callback function"""
	mkl = table.GetCurrentFocusedRowObject[_MomentaryCoastLineLocation]()
	objects = [o for o in table.GetSelectedObjects[_MomentaryCoastLineLocation]()]
	if (len(objects) == 0):
		return
		
	#endregion
	
	#region Retrieve extra testline
	chartView = view.ChildViews[0]
	line = None
	for series in chartView.Chart.Series:
		if (series.Tag == "TestLineTag"):
			line = series
			break
	
	if (line == None):
		line = AddLineToFigure(view,mkl)
	#endregion

	#region Report change
	"""
	1. Print current selected location and year
	2. Change line width and color to show we have hit this part of the callback
		It is for example possible to plot measured data or other interesting characteristics instead of these meaningless changes
	"""
	
	PrintMessage("Current selection = %s" % (mkl.Location),0)

	if (line.Width >= previousWidth and line.Width < 6) or line.Width == 1 :
		previousWidth = line.Width
		line.Width = line.Width + 1
	else:
		previousWidth = line.Width
		line.Width = line.Width -1


	if (line.Color == Color.Red):
		line.Color = Color.Green
	else:
		line.Color = Color.Red
	#endregion
#endregion
	
#region AddLineToFigure
def AddLineToFigure(view,mkl):
	chartView = view.ChildViews[0]
	line = AddToChartAsLine(chartView.Chart,[-200, 300],[-5, 12],"Test")
	line.Tag = "TestLineTag"
	return line
#endregion

#region NoViewMessage
def NoViewMessage():
	PrintMessage("This function needs a filled output view with Momentary coastline positions (MKL)",0)
	PrintMessage("Please add a coastal development model, run it and open the output of the momentary coastline model")

#endregion

def InitiateAndRegisterEvent(modelName = "Coastal development model"):
	
	global previousWidth
		
	#region Find model, view and data
	model = GetModel(modelName)
	if (model == None):
		NoViewMessage()
		return
	
	data = model.MomentaryCoastLineModel.MomentaryCoastLineLocations
	view = None
	for v in Gui.DocumentViews.AllViews:
		if (v.Data == data):
			view = v
			break
	
	if (view == None):
		NoViewMessage()
		return
		
	morphAnTable = None
	for control in view.Controls:
		if (hasattr(control,"Panel2")):
			for panelcontrol in control.Panel2.Controls:
				if (isinstance(panelcontrol,_MorphAnTable)):
					morphAnTable = panelcontrol
					break
		if (morphAnTable != None):
			break
	#endregion
	
	#region Add new line and initiate width
	mkl = morphAnTable.GetCurrentFocusedRowObject[_MomentaryCoastLineLocation]()
	AddLineToFigure(view,mkl)
	previousWidth = 1
	#endregion
	
	#region Register callback
	MklViewSelectionChangedCallback = lambda o, eventargs, mklView=view, table=morphAnTable: MklViewSelectionChanged(o,eventargs,mklView, table)
	
	morphAnTable.SelectionChanged += MklViewSelectionChangedCallback
	#morphAnTable.SelectionChanged -= MklViewSelectionChangedCallback
	#endregion

InitiateAndRegisterEvent()