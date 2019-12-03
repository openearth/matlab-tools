import numpy as np
from Libraries.MorphAn.Models import GetModel
from Libraries.Utils.Charting import *
from DeltaShell.Plugins.MorphAn.Gui.Forms.Controls import MorphAnTable as _MorphAnTable
from Libraries.Utils.Project import PrintMessage
from DeltaShell.Plugins.MorphAn.Gui.Forms.DuneSafetyModelViews.BoundaryProfileModelViews import BoundaryProfileWrapper as _BoundaryProfile

"""
Script voor het toevoegen van de legger lijn aan het resultaat van het grensprofielmodel op basis van een asci file.
## De text file bevat twee kolommen met de metering (kolom 1) en de locatie van de legger lijn (kolom 2).
## Locatie zonder leggerlijn hebben een waarden van -999
## De locatie van de leggerlijn is de afstand tot het RSP van de raai.
"""

## input
path = 'd:\\Terschelling.txt'

##  import legger line
data = np.loadtxt(path, delimiter='\t')

## functies
def ChangeFig(o,e) : 

	## get view
	for v in Gui.DocumentViews.AllViews:
		if v.Name=='BoundaryProfileView':
			view = v
			break
	if (view == None):
		NoViewMessage()
	else:
		## get chartview
		chartView = view.ChildViews[0]
		
		## get focused
		BF = morphAnTable.GetCurrentFocusedRowObject[_BoundaryProfile]()
		loc = BF.Location.Offset
		ind = np.where(data[:,0]==loc)
	
		check = data[ind,1]
		if check[0,0]!=-999:
			## add line
			line1 = AddToChartAsLine(chartView.Chart,[data[ind,1],data[ind,1]],[0, 10],'Legger lijn')
			line1.Color = Color.Blue
			line1.Width = 3
			line1.PointerVisible = True
			line1.PointerSize = 5
			line1.PointerColor = Color.Blue
			line1.PointerLineVisible = True
			line1.PointerLineColor = Color.DarkBlue
		else:
			PrintMessage("Deze locatie heeft geen locatie voor de legger lijn")	


def NoViewMessage():
	PrintMessage("Er is geen Grensprofiel window geopend!")


## get view
view = None
for v in Gui.DocumentViews.AllViews:
	if v.Name=='BoundaryProfileView':
		view = v
		break

## check view
if (view == None):
	NoViewMessage()
else:
	morphAnTable = None
	for control in view.Controls:
		if (hasattr(control,"Panel2")):
			for panelcontrol in control.Panel2.Controls:
				if (isinstance(panelcontrol,_MorphAnTable)):
					morphAnTable = panelcontrol
					break
		if (morphAnTable != None):
			break

	## testing
	#BF = morphAnTable.GetCurrentFocusedRowObject[_BoundaryProfile]()
	#testLoc = BF.Location.Offset
	#ind = np.where(data[:,0]==testLoc)
	#print(data[ind,1])
	#print(testLoc)
	
	## set callback
	callback = lambda o, eventargs: ChangeFig(o,eventargs)
	morphAnTable.SelectionChanged += callback
	#morphAnTable.SelectionChanged -= callback


