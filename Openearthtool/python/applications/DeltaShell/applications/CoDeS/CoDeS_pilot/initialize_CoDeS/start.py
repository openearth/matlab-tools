#   Copyright notice
#   --------------------------------------------------------------------
#   Copyright (C) 2016 Deltares
#       Wiebe de Boer
#
#       wiebe.deboer@deltares.nl
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
#===============================
#change default scripting folder
#===============================
#from DeltaShell.Plugins.Toolbox import ToolboxApplicationPlugin
#ToolboxApplicationPlugin.ChangeScriptingFolder(r"d:\friedman\Desktop\Current Work\CoDeS\DeltaShell\plugins\DeltaShell.Plugins.Toolbox")

#========================
#load necessary libraries
#========================
from Scripts.TidalData.SHELL import *
from Scripts.CoastlineDevelopment.UI_functions import *
from Scripts.BreakwaterDesign.SHELL_BW import *
from Scripts.UI_Examples.Shortcuts import *
from DelftTools.Utils import Url

#================================
#change the start page -> logo?!?
#================================

#H = Gui.DocumentViews[0]
#H.Url = Url("temp","http://www.classyfireplace.com/")

from DelftTools.Utils import Url
from Libraries.StandardFunctions import *
OpenView(Url("Start-page CoDeS","https://publicwiki.deltares.nl/pages/viewpage.action?pageId=118652938"))

#=================================
#remove the side panels + toolbars
#=================================

viewList = [v for v in Gui.ToolWindowViews]
for v in viewList:
	Gui.ToolWindowViews.Remove(v)

#==========================
#add shortcut for each tool
#==========================

for i in Application.Plugins:
	if i.Name == "Toolbox":
		toobox_dir = i.Toolbox.ScriptingRootDirectory

#tide
AddShortcut("     Tidal Analysis     ","Tools",build_gui,toobox_dir + r"\Scripts\TidalData\tide.jpg")

#coastal development
AddShortcut("   Coastal Development  ","Tools",start_CD_GUI,toobox_dir + r"\Scripts\CoastlineDevelopment\transport.png")

#breakwater design
AddShortcut("     Breakwater Design     ","Tools",Start_BreakwaterTool,toobox_dir + r"\Scripts\BreakwaterDesign\breakwater_icon.png")

#=================================================
#change the ribbon to "CoDeS" + hide other ribbons
#=================================================
ribbon = None
for child in Gui.MainWindow.Content.Children :
	if (hasattr(child,'Name') and child.Name == "Ribbon"):
		ribbon = child

for tab in ribbon.Tabs:
	if (tab.Header == "Shortcuts"):
		tab_h = tab
	else:
		tab.Visibility = tab.Visibility.Collapsed
		
tab_h.Header = "CoDeS"
tab_h.IsSelected = True