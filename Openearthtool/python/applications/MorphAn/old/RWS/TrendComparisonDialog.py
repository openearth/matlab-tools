#region import
from Libraries.Utils.Project import *
from RWS.TrendComparisonView import *

import clr
clr.AddReference("System.Windows.Forms")
clr.AddReference("System.Drawing")
clr.AddReference("System.Core")

from System.Windows.Forms import Form as _Form
from System.Windows.Forms import Label as _Labelfrom

from System.Windows.Forms import Button as _Button
from System.Windows.Forms import CheckedListBox as _CheckedListBox
from System.Windows.Forms import FormBorderStyle as _FormBorderStyle
from System.Windows.Forms import FormStartPosition as _FormStartPosition
from System.Windows.Forms import MessageBoxDefaultButton as _MessageBoxDefaultButton
from System.Windows.Forms import MessageBoxIcon as _MessageBoxIcon
from System.Windows.Forms import MessageBoxButtons as _MessageBoxButtons
from System.Windows.Forms import MessageBox as _MessageBox

from System.Drawing import Size as _Size
from DeltaShell.Plugins.MorphAn.Data import MorphAnWorkSpace as _MorphAnWorkSpace
from DeltaShell.Plugins.MorphAn.Data import MorphAnDataExtensions as _MorphAnDataExtensions
from RWS.CombinedTimeDependentView import *
from System.Collections.Generic import List
from System import String
from System.Linq import *

#endregion

#region Create dialog form with callback

#region Dialog Callback
def ButtonOkCLicked(o,e,dialog,chLstBox):
	PrintMessage("Help")
	try:
		modelNames = chLstBox.CheckedItems
	except:
		PrintMessage("Could not convert specified input to meaningfull numbers")
		dialog.Close()
		return
	
	dialog.Close()
	
	resultslist = dict()
	for indx, modelName in enumerate(modelNames):
		model = GetModel(modelName)
		if hasattr(model,'VolumeTrendModel'):
			results = model.VolumeTrendModel.Trends
			for result in results.ResultList:
				if (not(resultslist.has_key(result.Location))):
					resultslist[result.Location] = [None for x in range(len(modelNames))]
				resultslist[result.Location][indx] = result
		if hasattr(model,'ExpectedCoastLineModel'):
			results = model.ExpectedCoastLineModel.ExpectedCoastLineLocations
			for result in results.ResultList:
				if (not(resultslist.has_key(result.Location))):
					resultslist[result.Location] = [None for x in range(len(modelNames))]
				resultslist[result.Location][indx] = result
	
	ShowTrendComparisonView(resultslist,modelNames)
#endregion

#region _CreateDialog
def _CreateTrendComparisonDialog():
	

	dialog = _Form(
				Text = "Selecteed modellen",
				Size = _Size(250,200),
				MaximizeBox = False,
				MinimizeBox = False,
				FormBorderStyle = _FormBorderStyle.FixedDialog,
				StartPosition = _FormStartPosition.CenterScreen)
		
	l1 = _CheckedListBox(Top = 20,
				Height = 120,
				Width = 210,
				Left = 20,
				CheckOnClick = True)
	allModels = Application.GetAllModelsInProject()
	idx = 0
	for model in allModels:
		if (hasattr(model,'ExpectedCoastLineModel') or hasattr(model,'VolumeTrendModel')):
			l1.Items.Add(model.Name)
			l1.SetItemChecked(idx,True)
			idx = idx + 1
			
	buttonOK = _Button(
				Text = "OK",
				Top = 140,
				Left= 85,
				Width=80)
			
	dialog.Controls.Add(l1)
	dialog.Controls.Add(buttonOK)
		
	buttonOK.Click += lambda o,e : ButtonOkCLicked(o,e,dialog,l1)

	return dialog
	
#endregion

#endregion

def ShowTrendComparisonDialog():
	f = _CreateTrendComparisonDialog()
	if (f != None):
		f.ShowDialog()
	else:
		_MessageBox.Show("Please add a workspace that contains JARKUS data to your project before running this command!","Important Note",
		_MessageBoxButtons.OK,
		_MessageBoxIcon.Exclamation,
		_MessageBoxDefaultButton.Button1);

