"""
This module contains convenience functions for modellers. They are build on the
standard library of scripts of SOBEK (Scripts/Libraries). 

This module is released without guarantee that functions work with future (or past)
SOBEK versions. 

SOBEK 3.4.0


Contact: koen.berends@deltares.nl

The MIT License (MIT)
Copyright (c) 2016 Deltares

Permission is hereby granted, free of charge, to any person obtaining a copy of 
this software and associated documentation files (the "Software"), to deal in 
the Software without restriction, including without limitation the rights to use, 
copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the 
Software, and to permit persons to whom the Software is furnished to do so, subject 
to the following conditions:

The above copyright notice and this permission notice shall be included in all 
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR 
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, 
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE 
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER 
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING 
FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER 
DEALINGS IN THE SOFTWARE.
"""

# -------------------------
#region // Imports 
# -------------------------
# DeltaShell .NET imports
from NetTopologySuite.Extensions.Coverages import NetworkLocation as _NetworkLocation
from NetTopologySuite.Extensions.Coverages import FeatureCoverage as _FeatureCoverage
from NetTopologySuite.Extensions.Coverages import NetworkCoverage as _NetworkCoverage

from System.Drawing import FontStyle, Font, GraphicsUnit, Text, Color
from System.Drawing.Drawing2D import DashStyle
import DeltaShell.Plugins.DelftModels as _DM

import DeltaShell.Plugins.NetworkEditor.Gui.Forms.CrossSectionView.ProfileMutators.ZWProfileMutator as zw
import DeltaShell.Plugins.NetworkEditor.Gui.Forms.CaseAnalysis.NetworkCoverageOperations as NCO
from DelftTools.Controls.Swf.Charting.Series import ChartSeriesFactory as _ChartSeriesFactory
from DelftTools.Hydro.Structures import Weir
from DeltaShell.Sobek.Readers.Readers import HisFileReader
import DelftModelApi.Net as DMA
# SOBEK specific functions 
try:
    from DeltaShell.Sobek.Readers.Readers import HisFileReader
except ImportError:
    print "SOBEK not detected. SOBEK related functions will not be available"

# FM specific functions (Warning will be raised with versions pre SOBEK 3.4)
try:
    import DeltaShell.Plugins.FMSuite as _FM
except:
    print "Flow FM not detected. Flow FM related functions will not be available"

# Python standard library import
from datetime import datetime, timedelta
import os
import numpy as np

# DeltaShell Python library import
from Libraries import ChartFunctions
from Libraries import Conversions 
from Libraries import StandardFunctions as SF
from Libraries import SobekWaterFlowFunctions as SWFF
#endregion

# -------------------------
#region // Module meta information

__author__ = "Koen Berends"
__copyright__ = "2016, Deltares"
__credits__ = ["Koen Berends"]
__license__ = "MIT"
__version__ = "$Revision$"
__maintainer__ = "Koen Berends"
__email__ = "koen.berends@deltares.nl"
__status__ = " "
#endregion
# -------------------------


# -------------------------
#region // Get functions
def GetFlow1DModel():
    """
    Returns the first Flow1D model it finds
   
    :return obj, Flow1DModel object
    """
    for model in CurrentProject.RootFolder.Models:
        if type(model) == _DM.HydroModel.HydroModel:
            for submodel in model.Models:
                if type(submodel) == _DM.WaterFlowModel.WaterFlowModel1D:
                    return submodel
        elif type(model) == _DM.WaterFlowModel.WaterFlowModel1D:
            return model

def GetFlowFMModel():
    """
    Returns the first Flow Flexible Mesh model it finds
   
    :return obj, FMModel object
    """
    for model in CurrentProject.RootFolder.Models:
        if type(model) == _DM.HydroModel.HydroModel:
            for submodel in model.Models:
                if type(submodel) == _FM.FlowFM.WaterFlowFMModel:
                    return submodel
        elif type(model) == _FM.FlowFM.WaterFlowFMModel:
            return model

def GetWaveModel():
    """
    Returns the first SWAN model it finds
   
    :return obj, WaveModel object
    """
    for model in CurrentProject.RootFolder.Models:
        if type(model) == _DM.HydroModel.HydroModel:
            for submodel in model.Models:
                if type(submodel) == _FM.Wave.WaveModel:
                    return submodel
        elif type(model) == _FM.Wave.WaveModel:
            return model
            
def GetIntegratedModel():
    """
    Returns the first integrated model it finds
   
    :return obj, HydroModel object
    """
    for model in CurrentProject.RootFolder.Models:
        if type(model) == _DM.HydroModel.HydroModel:
            return model
        else:
            print "There is no Integrated Model in this Project"

def GetRealtimeControlModel():
    """
    Returns the first RealTime Control model it finds
   
    :return obj, RealTimeControlModel object
    """
    for model in CurrentProject.RootFolder.Models:
        if type(model) == _DM.HydroModel.HydroModel:
            for submodel in model.Models:
                if type(submodel) == _DM.RealTimeControl.RealTimeControlModel:
                    return submodel
        elif type(model) == _DM.RealTimeControl.RealTimeControlModel:
            return model

def GetRainfallRunoffModel():
    """
    Returns the first Rainfall-Runoff  model it finds
   
    :return obj, RainfallRunoffModel object
    """
    for model in CurrentProject.RootFolder.Models:
        if type(model) == _DM.HydroModel.HydroModel:
            for submodel in model.Models:
                if type(submodel) == _DM.RainfallRunoff.RainfallRunoffModel:
                    return submodel
        elif type(model) == _DM.RainfallRunoff.RainfallRunoffModel:
            return model

def GetColors(verbose=False):
    """
    Returns object with all available system colors
    
    Equivalent to:
        
    >> from System.Drawing import Color
    
    Return the system Color object. 
            
    :param verbose: If true, print a list of available colors
        
    :return: obj. 'Color' object
    """
    if verbose:
        for color in vars(Color):
            if type(getattr(Color, color)) == Color:
                print color
                
    return Color

def GetFont(fontname, size=15, style='Regular'):
    """
    Returns font object for given fontname. 
    Possible options for styles:
        - 'Regular'
        - 'Bold'
        - 'Italic'
        - 'Underline'
        - 'Strikeout'
    :param fontname: str, e.g. 'Arial'
    :param size: int, size of font in points
    :param style: str, e.g. 'Regular' (case sensitive!)
    :return: obj, font object
    """
    
    ifc = Text.InstalledFontCollection()
    fontfamily = [font for font in ifc.Families if font.Name == fontname]
    if not(fontfamily):
        raise 'Unknown Font'
    
    try:
        fontstyle = getattr(FontStyle, style)
    except:
        fontstyle = FontStyle.Regular
        print 'Style %s not found, defaulting to Regular'
        
    FontOut = Font(fontfamily[0], size, fontstyle, GraphicsUnit.Point)
    return FontOut
    
def GetWeir(flow, name):
    """
    INPUT
    
    flow    : flow model. Retrieve with GetFlowModel()
    name    : name of the weir
        
    OUTPUT
    
    weir object
    """
    for weir in flow.Network.Structures:
        if type(weir) == Weir:
            if weir.Name == name:
                return weir
            
def GetOutputCoverage(flow, name):
    """
    INPUT
    
    flow    : flow model. Retrieve with GetFlow1DModel()
    name    : name of the coverage. Example: 'Water level'
        
    OUTPUT
    
    coverage object
    """
    
    return SF.GetItemByName(flow.OutputFunctions, name)

def GetObservationPoint(flow, name):
    """
    INPUT
    
    flow    : flow model. Retrieve with GetFlow1DModel()
    location: str, name of the observation point
        
    OUTPUT
    
    observation point object
    """
    op = None
    op = SF.GetItemByName(flow.Network.ObservationPoints, name)
    if not op:
        print 'No observation point by that name'
    return op
    
def GetObservationPoints(flow):
    """
    INPUT
    
    flow    : flow model. Retrieve with GetFlow1DModel()

        
    OUTPUT
    
    list with all observation point in flow model
    """
    obs = list()
    for i in flow.Network.ObservationPoints:
        obs.append(GetObservationPoint(flow, i.Name))
        
    return obs

def GetOutputForObservationPoint(flow, location):
    """
    INPUT
    
    flow    : flow model. Retrieve with GetFlow1DModel()
    location: str, name of the observation point
        
    OUTPUT
    
    dictionary:
        {coverage name: {time: nd array, value: nd array}}
    """
    # Get 
    # List possible outputs for observation points
    output = dict() 
    for cov in flow.OutputFunctions:
        if type(cov) == _FeatureCoverage:
            timeseries = SWFF.GetTimeSeriesFromWaterFlowModel(flow, GetObservationPoint(flow, location), cov.Name)
            time = [i[0] for i in timeseries]
            value = [i[1] for i in timeseries]
            output[cov.Name] = {'time': np.array(time), 'value': np.array(value)}
            

    return output
    
def GetBranch(flow, name):
    """
    INPUT
    
    flow    : flow model. Retrieve with GetFlowModel()
    name    : [str] name of the branch
        
    OUTPUT
    
    branch object
    """
    for branch in flow.Network.Branches:
        if branch.Name == name:
            return branch

def GetLocation(flow, branch, chainage):
    """
    INPUT
    
    flow    : flow model. Retrieve with GetFlowModel()
    branch  : [str] name of the branch
    chainage: [int or float] chainage of location
    
    OUTPUT
    
    location object
    """
    return _NetworkLocation(GetBranch(flow, branch), float(chainage))

def GetProjectPath():
    """
    INPUT
    
    flow    : flow model. Retrieve with GetFlowModel()

    OUTPUT
    
    [str] path to morph-gr.his
    """
    return os.path.join(Application.ProjectDataDirectory, '..')  

def GetMorHisFilePath(flow):
    """
    INPUT
    
    flow    : flow model. Retrieve with GetFlowModel()

    OUTPUT
    
    [str] path to morph-gr.his
    """
    return os.path.join(Application.ProjectDataDirectory, flow.Name.replace(" ", "_")+"_output", 'work', 'morph-gr.his')
    
def GetRoute(flow, name):
    """
    INPUT
    
    flow    : flow model. Retrieve with GetFlowModel()
    name  : [str] name of the route
    
    OUTPUT
    
    route object
    """
    for route in flow.Network.Routes:
        if route.Name == name:
            return route

def GetMorphologyComponents(flow, verbose=False):
    """
    This functions reads the morph-gr.his file generated by SOBEK if
    morphology is enabled and returns the id and name of its outputs. 
    
    """
    hisFile = GetMorHisFilePath(flow)
    OUT = list()
    with HisFileReader(hisFile) as fileReader:
        header = fileReader.GetHisFileHeader
        if verbose: print("Components:")
        for i, comp in enumerate(header.Components):
            if verbose: print('%i: %s'%(i, comp))
            OUT.append(comp)

    return OUT

def GetMorphologyLocations(flow, verbose=False):
    """
    This functions reads the morph-gr.his file generated by SOBEK if
    morphology is enabled and returns the id and name of output locations. 
    
    """
    hisFile = GetMorHisFilePath(flow)
    OUT = list()
    with HisFileReader(hisFile) as fileReader:
        header = fileReader.GetHisFileHeader
        if verbose: print("Locations:")
        for i, loc in enumerate(header.Locations):
            if verbose: print('%i: %s'%(i, loc))
            OUT.append(loc)
        
    return OUT
    
def GetMorphologyTimeSteps(flow, verbose=False):
    """
    This functions reads the morph-gr.his file generated by SOBEK if
    morphology is enabled and returns the id and name of output locations. 
    
    """
    hisFile = GetMorHisFilePath(flow)
    OUT = list()
    with HisFileReader(hisFile) as fileReader:
        header = fileReader.GetHisFileHeader
        if verbose: print("TimeSteps:")
        for i, t in enumerate(header.TimeSteps):
            if verbose: print('%i: %s'%(i, t))
            OUT.append(t)
        
    return OUT

def GetMorphologyResults(flow, component=None, location=None, timestep=None, to_csv=None):
    """
    This functions reads the morph-gr.his file generated by SOBEK if
    morphology is enabled. 
    
    INPUT
    
    flow: flow model. Get with GetFlow1DModel
    component: str or int. 
    location: str or int
    timestep: str or int
    to_csv: str, filename. Writes output to CSV file in project path
    
    OUTPUT
    :return array: list of [loc, value] or [time, value]
    
    EXAMPLE
    >> flow = GetFlow1DModel()
    >> GetMorphologyResults(flow, component=0, time=0)
    
    """
    dataOUT = list()
    header = ''
    # Check input
    # ======================================
    if component==None: 
        GetMorphologyComponents(flow)
    elif type(component)==str:
        components = GetMorphologyComponents(flow)
        try:
            component_id = components.index(component)
        except ValueError:
            print "Unknown component, available components"
            GetMorphologyComponents(flow)
    else:
        component_id = int(component)
        
    if type(location)==str:
        locations = GetMorphologyLocations(flow)
        try:
            location_id = locations.index(location)
        except ValueError:
            print "Unknown location, available locations"
            GetMorphologyLocations(flow)
    elif not location == None:
        location_id = int(location)
         
    if type(timestep)==str:
        timesteps = GetMorphologyLocations(flow)
        try:
            timestep_id = timesteps.index(location)
        except ValueError:
            print "Unknown timestep, available timesteps:"
            GetMorphologyLocations(flow)
    elif not timestep == None:
        timestep_id = int(timestep)
        
    # Retrieve input
    # ======================================

    hisFile = GetMorHisFilePath(flow)
    with HisFileReader(hisFile) as fileReader:
        header = fileReader.GetHisFileHeader
        if not location == None:
            data = fileReader.ReadLocation(header.Locations[location_id], header.Components[component_id])
            dataOUT = [[i.TimeStep, i.Value] for i in data]
            header = 'Time, {}'.format(header.Components[component_id])
        elif not timestep == None:
            data = fileReader.ReadTimeStep(header.TimeSteps[timestep_id], header.Components[component_id])
            dataOUT = [[i.LocationName, i.Value] for i in data]
            header = 'Location, {}'.format(header.Components[component_id])
        else:
            pass
            
    if not to_csv == None:
        with open(os.path.join(GetProjectPath(), to_csv), 'w') as f:
            # header
            f.write('{}\n'.format(header))
            for row in dataOUT:
                f.write('{}, {} \n'.format(row[0], row[1]))
            
    return dataOUT
 
def GetModelAPI():
    # Global model API
    # Note: alternative to use flowmodel.ModelEngine? --> is NoneType?
    try:
        api = DMA.ModelApi()
    except:
        raise Exception('API failed to load. Try running your model first')
    return api
#endregion
# -------------------------