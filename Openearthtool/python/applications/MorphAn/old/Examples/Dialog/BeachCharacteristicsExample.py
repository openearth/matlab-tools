#region import
from Examples.Dialog.BeachCharacteristicsCallback import *
from Libraries.Utils.Project import *
from Libraries.Utils.Shortcuts import *

import clr
clr.AddReference("System.Windows.Forms")
clr.AddReference("System.Drawing")

from System.Windows.Forms import Form as _Form
from System.Windows.Forms import TextBox as _TextBox 
from System.Windows.Forms import Label as _Label
from System.Windows.Forms import Button as _Button
from System.Windows.Forms import ComboBox as _ComboBox
from System.Windows.Forms import ComboBoxStyle as _ComboBoxStyle
from System.Windows.Forms import FormBorderStyle as _FormBorderStyle
from System.Windows.Forms import FormStartPosition as _FormStartPosition
from System.Windows.Forms import MessageBoxDefaultButton as _MessageBoxDefaultButton
from System.Windows.Forms import MessageBoxIcon as _MessageBoxIcon
from System.Windows.Forms import MessageBoxButtons as _MessageBoxButtons
from System.Windows.Forms import MessageBox as _MessageBox

from System.Drawing import Size as _Size
from DeltaShell.Plugins.MorphAn.Data import MorphAnWorkSpace as _MorphAnWorkSpace
from DeltaShell.Plugins.MorphAn.Data import MorphAnDataExtensions as _MorphAnDataExtensions

#endregion

#region Create dialog form with callback

#region Dialog Callback
def ButtonOkCLicked(o,e,dialog,lwBox,hwBox,setCombo,yearList):
	PrintMessage("Help")
	try:
		lw = float(lwBox.Text)
		hw = float(hwBox.Text)
	except:
		PrintMessage("Could not convert specified input to meaningfull numbers")
		dialog.Close()
		return
	
	year = yearList.SelectedItem
	jrkName = setCombo.SelectedItem
	PrintMessage("Laagwater = %0.2f" % (lw));
	PrintMessage("Hoogwater = %0.2f" % (hw));
	PrintMessage("JARKUS metingen = %s" % (jrkName));
	PrintMessage("Jaar = %d" % (year));
	
	dialog.Close()
	
	CalculateBeachChagacteristics(jrkName,lw,hw,year)
#endregion

#region _CreateDialog
def _CreateDialog():
	workspace = None
	for item in RootFolder.Items:
		if (isinstance(item,_MorphAnWorkSpace)):
			workspace = item
			break
			
	if (workspace == None):
		PrintMessage("No workspace available")
		return
	
	dialog = _Form(
				Text = "Analyse invoer",
				Size = _Size(250,200),
				MaximizeBox = False,
				MinimizeBox = False,
				FormBorderStyle = _FormBorderStyle.FixedDialog,
				StartPosition = _FormStartPosition.CenterScreen)
		
	l1 = _Label(Text = "Laagwater [m + NAP]",
				Top = 20,
				Height = 20,
				Width = 140,
				Left = 20)
		
	l2 = _Label(Text = "Hoogwater [m + NAP]",
				Top = 50,
				Height = 20,
				Width = 140,
				Left = 20)
		
	text_box_low_water = _TextBox(
				Text = "-1.2",
				Left = 160,
				Top = 20,
				Height = 20,
				Width = 60)
		
	text_box_high_water = _TextBox(
				Text = "3.2",
				Left = 160,
				Top = 50,
				Height = 20,
				Width = 60)
		
	combobox_jrk_set = _ComboBox(
				Top = 80,
				Left = 20,
				Width = 200,
				DropDownStyle = _ComboBoxStyle.DropDownList)
	
	locations = workspace.MorphAnData.TransectLocations
	allYears = []
	for jrk in workspace.MorphAnData.JarkusMeasurementsList:
		combobox_jrk_set.Items.Add(jrk.Name)
		for year in _MorphAnDataExtensions.YearsByLocations(workspace.MorphAnData,locations,jrk):
			allYears.append(year)
	combobox_jrk_set.SelectedIndex = 0
	
	combobox_years = _ComboBox(Top = 110,
				Left = 20,
				Width = 200,
				DropDownStyle = _ComboBoxStyle.DropDownList)
	
	for year in reversed(list(set(allYears))):
		combobox_years.Items.Add(year)
	if (combobox_years.Items.Count > 0):
		combobox_years.SelectedIndex = 0
	
	buttonOK = _Button(
				Text = "OK",
				Top = 140,
				Left= 60,
				Width=80)
			
	dialog.Controls.Add(combobox_jrk_set)
	dialog.Controls.Add(combobox_years)
	dialog.Controls.Add(text_box_low_water)
	dialog.Controls.Add(text_box_high_water)
	dialog.Controls.Add(l1)
	dialog.Controls.Add(l2)
	dialog.Controls.Add(buttonOK)
		
	buttonOK.Click += lambda o,e,lwBox=text_box_low_water, hwBox=text_box_high_water,setCombo=combobox_jrk_set,yearList=combobox_years,d=dialog  : ButtonOkCLicked(o,e,d,lwBox,hwBox,setCombo,yearList)

	return dialog
	
#endregion

#endregion

def ShowDialog():
	f = _CreateDialog()
	if (f != None):
		f.ShowDialog()
	else:
		_MessageBox.Show("Please add a workspace that contains JARKUS data to your project before running this command!","Important Note",
		_MessageBoxButtons.OK,
		_MessageBoxIcon.Exclamation,
		_MessageBoxDefaultButton.Button1);

basePath = r"c:\src\openearthtools\python\applications\MorphAn\Examples\ShortcutsExample"

RemoveShortcut("Beach characteristics","JARKUS")
AddShortcut("Beach characteristics","JARKUS",ShowDialog,basePath + r"\Letter-E-pink-icon.png")