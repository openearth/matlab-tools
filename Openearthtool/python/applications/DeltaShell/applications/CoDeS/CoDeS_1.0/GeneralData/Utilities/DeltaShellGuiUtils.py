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
from Libraries.StandardFunctions import GetItemByName as _GetItemByName

def GetToolboxDir():
    for i in Application.Plugins:
        if i.Name == "Toolbox":
            return i.Toolbox.ScriptingRootDirectory

def SelectTab(tabName):
    ribbon = None
    for child in Gui.MainWindow.Content.Children:
       if (hasattr(child,'Name') and child.Name == "Ribbon"):
        ribbon = child

    for t in ribbon.Tabs:
        if t.Header == tabName:
            tab = t
        
    ribbon.SelectedTabItem = tab
    
def RemoveViewByName(viewName):
    view = _GetViewByText(viewName)
    if (view != None):
        Gui.DocumentViews.Remove(view)

def RemoveToolWindowsExcept(viewNames):
    viewList = [v for v in Gui.ToolWindowViews]
    for v in viewList:
        if v.Text not in viewNames :
            Gui.ToolWindowViews.Remove(v)
            
def MakeViewActiveView(viewName):
    view = _GetViewByText(viewName)
    if (view != None):
        Gui.DocumentViews.ActiveView = view
        return True
    return False

def _GetViewByText(viewText):
    for view in Gui.DocumentViews:
        if view.Text == viewText:
            return view