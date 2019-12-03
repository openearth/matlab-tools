import clr
clr.AddReference("System.Windows.Forms")
clr.AddReference("System.Drawing")

from DelftTools.Controls import ICompositeView as _ICompositeView
from DelftTools.Controls import IView as _IView
from System.Drawing import Bitmap as _Bitmap
from System.Windows.Forms import UserControl as _UserControl
from DelftTools.Controls import ViewInfo as _ViewInfo
from System import Object as _Object
from DelftTools.Utils.Collections.Generic import EventedList as _EventedList
from System.Drawing import Size as _Size

"""Public classes that can be used when building a View"""
from System.Windows.Forms import (Form,
									Panel,
									RichTextBox,
									TextBox,
									ComboBox,
									Label,
									SplitContainer,
									NumericUpDown,
									DockStyle,
									ListBox, 
									GroupBox, 
									Button, 
									CheckBox, 
									DateTimePicker, 
									TabControl, 
									Orientation, 
									FixedPanel, 
									ComboBoxStyle)
from DeltaShell.Plugins.SharpMapGis.Gui.Forms import MapView
from DelftTools.Controls.Swf.Charting import ChartView
from DelftTools.Controls.Swf.Table import TableView
from System.Drawing import Color,Bitmap

class View (_UserControl,_ICompositeView):
	"""
	Wraps a windows forms UserControl in an object that implements IView. This allows displaying a user control as a view or toolwindow in Delta Shell
	"""
	def __init__(self):
		self.__image = None
		self.__data = "Dummy data"
		self.__viewInfo = _ViewInfo()
		self.__viewInfo.GetViewName = self.__getname
		self.__viewInfo.DataType = _Object().GetType()
		self.__viewInfo.ViewDataType = _Object().GetType()
		self.__viewInfo.ViewType = self.GetType()
		self.__viewInfo.AdditionalDataCheck = self.__additionaldatacheck
		self.__childviews = _EventedList[_IView]()

	def get_Data(self):
		return self.__data
	def set_Data(self,value):
		self.__data = value
		# When data is set to None, unsubscribing events should occur here
	
	def get_Image(self):
		return self.__image
	def set_Image(self,value):
		self.__image = value

	def EnsureVisible(self,item):
		pass

	def get_ViewInfo(self):
		return self.__viewInfo
	def set_ViewInfo(self,value):
		self.__viewInfo = value

	def get_Text(self):
		return _UserControl.Text.GetValue(self)
	def set_Text(self,value):
		_UserControl.Text.SetValue(self,value)
	
	def get_Visible(self):
		return _UserControl.Visible.GetValue(self)
	def set_Visible(self,value):
		_UserControl.Visible.SetValue(self,value)
		
	def Dispose(self,b = ""):
		# Don't know why the dummy argument is needed. On some occasions it is called with 2 arguments, sometimes with 1???
		_UserControl.Dispose(self,b)
	
	def __getname(self,v,o):
		return self.Text
	
	def __additionaldatacheck(self,o):
		return False
		
	def Show(self):
		Gui.DocumentViews.Add(self)
		Gui.DocumentViews.ActiveView = self
		
	def get_ChildViews(self):
		return self.__childviews
	
	def get_HandlesChildViews(self):
		return False
	
	def ActivateChildView(self,childView):
		pass
		
class Dialog (Form):
	def __init__(self):
		self.Text = "Dialog"
		self.Size = _Size(250,200)
		self.MaximizeBox = False
		self.MinimizeBox = False
		self.FormBorderStyle = _FormBorderStyle.FixedDialog
		self.StartPosition = _FormStartPosition.CenterScreen
		
	def SetSize(width,height):
		self.Size = _Size(widht,height)