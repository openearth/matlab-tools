#   Copyright notice
#   --------------------------------------------------------------------
#   Copyright (C) 2017 Deltares
#
#       Gijs van den Oord
#
#       gijs.vandenoord@deltares.nl
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
from DeltaShell.Plugins.FMSuite.HarborTool import OnlineVisualizationWindow as _OnlineVisualizationWindow
from DeltaShell.Plugins.FMSuite.FlowFM import WaterFlowFMModel
from DeltaShell.Plugins.NetworkEditor.Gui import NetworkEditorMapLayerProvider
from DeltaShell.Plugins.SharpMapGis.Gui import SharpMapLayerProvider
from DeltaShell.Plugins.FMSuite.FlowFM.Gui import FlowFMMapLayerProvider
from System import TimeSpan

def CreateFMModel(mduPath):
    model = WaterFlowFMModel(mduPath)
    model.UseLocalApi = True 
    model.StopTime = model.StartTime + TimeSpan(1, 0, 0, 0)
    return model

def ShowFlowFieldWindow(scenario):
    path = r"D:\oord\src\nghs-1.1\test\DeltaShell.Plugins.FMSuite.FlowFM.Tests\test-data\harlingen\har.mdu"
    model = CreateFMModel(path)
    model.Area.ThinDams.Clear()
#    for civilStructure in scenario.CivilStructures)
#       thinDam = ThinDam()
#       thinDam.Name = civilStructure.Name
#       thinDam.Geometry = civilStructure.StructureGeometry
    
    hydroAreaMapLayerProvider = NetworkEditorMapLayerProvider()
    coverageMapLayerProvider = SharpMapLayerProvider()
    modelMapLayerProvider = FlowFMMapLayerProvider()
    
    form = _OnlineVisualizationWindow(model, hydroAreaMapLayerProvider, modelMapLayerProvider, coverageMapLayerProvider)
    form.ShowDialog()
