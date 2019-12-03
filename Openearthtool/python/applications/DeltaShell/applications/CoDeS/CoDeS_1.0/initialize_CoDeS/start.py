#   Copyright notice
#   --------------------------------------------------------------------
#   Copyright (C) 2017 RoyalHaskoningDHV
#
#       Bart-Jan van der Spek
#
#       Bart-Jan.van.der.Spek@rhdhv.com
#
#       Laan 1914, nr 35
#       3818 EX Amersfoort
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
test = False # set to True for testing

#change default scripting folder
#from DeltaShell.Plugins.Toolbox import ToolboxApplicationPlugin
#ToolboxApplicationPlugin.ChangeScriptingFolder(r"d:\friedman\Desktop\Current Work\CoDeS\DeltaShell\plugins\DeltaShell.Plugins.Toolbox")

#region import libraries
import clr
clr.AddReference("System.Windows.Forms")
clr.AddReference("Log4Net")
import numpy as np
from log4net import LogManager
import System.Windows.Forms as _swf

import Libraries.StandardFunctions as _StandardFunctions
import Scripts.UI_Examples.Shortcuts as _ShortcutsLibrary
from Scripts.GeneralData.Utilities.DeltaShellGuiUtils import *
from Scripts.GeneralData.Utilities.ScenarioPersister import ScenarioPersister as _ScenarioPersister
from Scripts.BreakwaterDesign.Utilities.BreakwaterPersister import BreakwaterPersister as _BreakwaterPersister
from Scripts.CoastlineDevelopment.Utilities import CoastlineDevelopmentPersister as _CoastlineDevelopmentPersister
from Scripts.WavePenetration.Utilities.WavePenetrationPersister import WavePenetrationPersister as _WavePenetrationPersister

from Scripts.GeneralData.Entities import Scenario as _Scenario
from Scripts.GeneralData.Views import GeneralDataView as _GeneralDataView
from Scripts.WavePenetration.Views import WavePenetrationView as _WavePenetrationView
#from Scripts.FlexibleMeshModel import FlowFieldView as _FlowFieldView
from Scripts.CoastlineDevelopment.Views import CoastlineDevelopmentView as _CoastlineDevelopmentView
import Scripts.BreakwaterDesign.Utilities.ShellBreakwaterTool as _BreakwaterShell

from DelftTools.Utils import Url

#endregion

def OpenGeneralDataView(scenario):
    if (not MakeViewActiveView("General data")):
        newDataView = _GeneralDataView.GeneralDataView(scenario)
        newDataView.Show()
        newDataView.SetScrollBars()

def OpenWavePenetrationView(scenario):
    if (not MakeViewActiveView("Wave penetration")):
        newWavePenetrationView = _WavePenetrationView(scenario)
        newWavePenetrationView.Show()

def OpenCoastlineDevelopmentView(scenario):
    if (not MakeViewActiveView("Coastline Development")):
        newCoastlineDevelopmentView = _CoastlineDevelopmentView(scenario)
        newCoastlineDevelopmentView.Show()

def ReplaceScenarioUsingFile():
    temp = persister.LoadWithDialog(persister.LoadScenario)
    NewScenario.GenericData = temp.GenericData
    NewScenario.ToolData = temp.ToolData
    del temp
    NewScenario.CreateDefaultMap()
    
    # Refresh views for new scenarios
    for view in Gui.DocumentViews:
        if (hasattr(view, "InitializeForScenario")):
            view.InitializeForScenario()

# Remove Start Page
RemoveViewByName("Start Page")

# open startup page
if (not test):
    _StandardFunctions.OpenView(Url("JIP CoDeS","https://publicwiki.deltares.nl/pages/viewpage.action?pageId=118652938"))

if (not test):
    #remove the side panels + toolbars
    RemoveToolWindowsExcept("MapLegendView")
    
    # remove unused tabs
    _ShortcutsLibrary.RemoveShortcutsTab("Developer")
    _ShortcutsLibrary.RemoveShortcutsTab("Tools")
    _ShortcutsLibrary.RemoveShortcutsTab("Home")
    _ShortcutsLibrary.RemoveShortcutsTab("Harbor Tool")

_log = LogManager.GetLogger("Start up")
persister = _ScenarioPersister()


# add tool persisters
BreakwaterPersister = _BreakwaterPersister()
coastlineDevelopmentPersister = _CoastlineDevelopmentPersister()
WavePenetrationPersister = _WavePenetrationPersister()

persister.ToolDataPersisters.append(BreakwaterPersister)
persister.ToolDataPersisters.append(coastlineDevelopmentPersister)
persister.ToolDataPersisters.append(WavePenetrationPersister)

# Create new Scenario object for storage of all data
NewScenario = _Scenario()

# Create CoDes ribbon
tabName = "CoDeS"
groupName = "Tools"
toolbox_dir = GetToolboxDir()

_ShortcutsLibrary.RemoveShortcutsTab(tabName)

# add tool shortcuts
_ShortcutsLibrary.CreateShortcutButton(" General Data ","", tabName,lambda: OpenGeneralDataView(NewScenario) ,toolbox_dir + r"\Scripts\initialize_CoDeS\icons\database3_small.png")
_ShortcutsLibrary.CreateShortcutButton("   Coastline Development  ", groupName, tabName,lambda: OpenCoastlineDevelopmentView(NewScenario),toolbox_dir + r"\Scripts\CoastlineDevelopment\transport_small.png")
_ShortcutsLibrary.CreateShortcutButton("     Breakwater Design     ",groupName, tabName, lambda: _BreakwaterShell.OpenBreakwaterView(NewScenario),toolbox_dir + r"\Scripts\initialize_CoDeS\icons\BWIcon3.png")
_ShortcutsLibrary.CreateShortcutButton("    Wave Penetration     ",groupName, tabName,lambda: OpenWavePenetrationView(NewScenario) ,toolbox_dir + r"\Scripts\initialize_CoDeS\icons\wavepen3.png")
_ShortcutsLibrary.CreateShortcutButton("     Flow Field     ",groupName, tabName,None ,toolbox_dir + r"\Scripts\initialize_CoDeS\icons\FlowIcon_small.png")
#_ShortcutsLibrary.CreateShortcutButton("     Flow Field     ", groupName, tabName, lambda: _FlowFieldView.ShowFlowFieldWindow(NewScenario), toolbox_dir + r"\Scripts\GeneralData\Views\SpatialData.png")

# add save/load shortcuts
_ShortcutsLibrary.CreateShortcutButton("Save", "Save/load", tabName, lambda: persister.SaveWithDialog(persister.SaveScenario, NewScenario), toolbox_dir + r"\Scripts\initialize_CoDeS\icons\disk-black.png")
_ShortcutsLibrary.CreateShortcutButton("Load", "Save/load", tabName, lambda: ReplaceScenarioUsingFile(), toolbox_dir + r"\Scripts\initialize_CoDeS\icons\folder-horizontal-open.png")

# add website shortcuts
#nota bene: increasing the number of spaces will give critical error in DeltaShell.
_ShortcutsLibrary.CreateShortcutButton("Royal HaskoningDHV","Developers", tabName,lambda: _StandardFunctions.OpenView(Url("Royal HaskoningDHV","http://www.royalhaskoningdhv.com/")) ,toolbox_dir + r"\Scripts\initialize_CoDeS\icons\royal (small).png")
_ShortcutsLibrary.CreateShortcutButton(" Witteveen+Bos ","Developers", tabName,lambda: _StandardFunctions.OpenView(Url("Witteveen+Bos","http://www.witteveenbos.com/")), toolbox_dir + r"\Scripts\initialize_CoDeS\icons\logoWB.png")
_ShortcutsLibrary.CreateShortcutButton("   Deltares   ", "Developers", tabName, lambda: _StandardFunctions.OpenView(Url("Deltares", "http://www.deltares.com/")), toolbox_dir + r"\Scripts\initialize_CoDeS\icons\Deltares_ico.png")

# Select CoDeS Ribbon
SelectTab(tabName)

# Make grouplayer non-visible for old view when changing in between Tools
def ActiveViewChangedEV(s,eventarg):
    if hasattr(eventarg.OldView,"GroupLayer"):
        eventarg.OldView.GroupLayer.Visible = False
    if hasattr(eventarg.View,"GroupLayer"):
        eventarg.View.GroupLayer.Visible = True

Gui.DocumentViews.ActiveViewChanged += lambda s,eventarg: ActiveViewChangedEV(s,eventarg)


