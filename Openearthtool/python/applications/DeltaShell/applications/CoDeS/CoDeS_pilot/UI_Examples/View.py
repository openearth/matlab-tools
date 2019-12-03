#   Copyright notice
#   --------------------------------------------------------------------
#   Copyright (C) 2016 Deltares
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