from BKL_plus.Functions.AddNewBklToOverview import *
from Libraries.Utils.Project import *
from Libraries.MorphAn.Models import *
from Libraries.Utils.View import *
from System.Drawing import Size as _Size
from DeltaShell.Plugins.MorphAn.Data import MorphAnWorkSpace as _MorphAnWorkSpace
from DeltaShell.Plugins.MorphAn.Models.CoastalDevelopment import CoastalDevelopmentModel as _CoastalDevelopmentModel

class BklPlusDialog(Dialog):
	areaNames = ProposedBklNames()
	
	def __init__(self):
		self.Size = _Size(250,200)
		self.Text = "Maak een selectie"
		self.FunctionToExecute = None
		
		workspace = None
		for item in RootFolder.Items:
			if (isinstance(item,_MorphAnWorkSpace)):
				workspace = item
				break
			
		if (workspace == None):
			PrintMessage("No workspace available")
			raise Exception("No workspace available")
			
		t = Label(
				Top = 10,
				Left = 10,
				Height = 15,
				Text = "Select model:")
		self.combobox_model = ComboBox(
				Top = 30,
				Left = 20,
				Width = 200,
				DropDownStyle = ComboBoxStyle.DropDownList)
		for model in workspace.Models:
			if isinstance(model,_CoastalDevelopmentModel):
				self.combobox_model.Items.Add(model)
				self.combobox_model.SelectedIndex = 0
			
		t2 = Label(
				Top = 60,
				Left = 10,
				Height = 15,
				Text = "Select area:")
		self.combobox_area = ComboBox(
				Top = 80,
				Left = 20,
				Width = 200,
				DropDownStyle = ComboBoxStyle.DropDownList)
		
		for idx,area in enumerate(self.areaNames):
			self.combobox_area.Items.Add(area)
			if (self.combobox_model.SelectedIndex > -1) and self.combobox_model.SelectedItem.Name == area:
				self.combobox_area.SelectedIndex = idx
		if (self.combobox_area.SelectedIndex < 0):
			self.combobox_area.SelectedIndex = 0
			
		buttonOK = Button(
				Text = "OK",
				Top = 110,
				Left= 60,
				Width=80)
				
		self.Controls.Add(t)
		self.Controls.Add(self.combobox_model)
		self.Controls.Add(t2)
		self.Controls.Add(self.combobox_area)
		self.Controls.Add(buttonOK)
		
		buttonOK.Click += lambda o,e: self.ButtonOkClicked(o,e)
		
	def ButtonOkClicked(self,o,eventargs):
		PrintMessage("Selected model: %s" % (self.combobox_model.SelectedItem),2);
		
		if self.FunctionToExecute != None:
			self.FunctionToExecute(areaName=self.combobox_area.SelectedItem,modelName=self.combobox_model.SelectedItem.Name)
			
		self.Close()
