import csv as _csv
import math
from System import Enum

from StormImpactApplication.HiddeLibraries.Conversions import ConvertToDotNetDateTime as _ConvertToDotNetDateTime
from StormImpactApplication.HiddeLibraries.Conversions import ConvertToDotNetTimeSpan as _ConvertToDotNetTimeSpan
from DelftTools.Shell.Core.Workflow import ActivityRunner as _ActivityRunner

from DelftTools.Controls.Swf import ExportImageHelper as _ExportImageHelper

class ImageType:
    """Supported image types for the ExportImage functions"""
    PNG = "png"
    JPG = "jpg"
    BMP = "bmp"
    GIF = "gif"
    EMF = "emf"
    TIFF = "tiff"

def ParseToEnum(name, enumType):
    return Enum.Parse(enumType, name)

def GetItemByName(list, name):
    """ Returns the first item in the list
        that has the provided name"""
    for item in list :
        if item.Name == name : 
            return item
            
def GetModelByName(modelName):
    """Searches for a model with the provided name"""
    return GetItemByName(Application.ModelService.GetAllModels(RootFolder), modelName)

def RunModel(model, showDialog = False):
    """Runs the provided model
    (Initialize, Execute, Finish, Cleanup)"""
    if (showDialog):
        Application.RunActivity(model)
    else :
        _ActivityRunner.RunActivity(model)

def OpenView(data):
    """Opens a view for the provided data"""
    if (not Gui.DocumentViewsResolver.CanOpenViewFor(data)):
        print "No view for " + str(data)
    else:
        Gui.CommandHandler.OpenView(data)
        return Gui.DocumentViews.ActiveView

def ExportListToCsvFile(fileName, list, header =[], delimiterChar = ","):
    """Creates a csv file for the provided list"""
    with open(fileName, 'wb') as csvfile:
        writer = _csv.writer(csvfile, delimiter = delimiterChar)
        if len(header) != 0:
            writer.writerow(header)
        for item in list:
            writer.writerow(item)

def AddToProject(item):
    """Adds the item to the project"""
    RootFolder.Add(item)
    
def SetModelTimes(model, startTime, stopTime, timeStep):
    """Sets the start time, stop time and timestep of the provided model"""
    model.StartTime = _ConvertToDotNetDateTime(startTime)
    model.StopTime = _ConvertToDotNetDateTime(stopTime)
    model.TimeStep = _ConvertToDotNetTimeSpan(timeStep)

def SetViewTimeSelection(view, dateTime):
    """Sets the current time displayed in the view to the provided datetime"""
    view.SetCurrentTimeSelection(_ConvertToDotNetDateTime(dateTime), _ConvertToDotNetDateTime(dateTime))

def ExportImageUsingDialog(image):
    """Exports the provided image using the image export dialog.
    This enables the user to change the resolution of the image"""
    _ExportImageHelper.ExportWithDialog(image)

def ExportImage(image, path, imageType, factor = 1.0):
    """Exports the provided image to the provided path as an image of the specified type.
    The factor is a zoom factor that determines the resolution of the image"""
    _ExportImageHelper.Export(image, path, imageType, factor)
    
def MakeFunction(definition, parameters):
    """Creates a function given the function definition as a string, and the independent variable(s), also as a string
    The function can be one or more values (a vector), and the independen variables can also be one or more parameters
    Examples:
    MakeFunction("x **2 + 3 *x - 1", "x") -> f(x) = x^2 + 3x - 1, a one valued function of one variable (x)
    MakeFunction("[u, 3 * math.sin(u)]", "u") -> [x(u), y(u)] = [3, 3sin(u)], a 2D vector function of one variable (u)
    MakeFunction(" C0 * (1 + math.exp(-t) )", "C0, t") -> C(x,t) = C0 * (1 + exp(-t)), a one valued function of two variables (C0,t)
    MakeFunction("[u * math.sin( v + w), u * math.sin(v-w), u * math.cos(v)]", "u, v, w") ->  [f(u,v,w), g(u,v,w), h(u,v,w)] =     [u sin(v + w), u sin(v-w), u cos(v)], a 3D vector of three variables""" 
    funcstr='''\
def f({p}):
    return {e}
    '''.format(e = definition, p = parameters)
    exec(funcstr)
    return f

def ParametricSeries(func, paramName, paramValueStart, paramValueEnd, paramValueStep):
    """Creates a series func(t) when the parameter t goes from paramValueStart to paramValueEnd in steps of size paramValueStep
    Example:
    parametricSeries("[1000 * u, 1500* math.sin(2*u)]", "u", 0, math.pi, math.pi/200)
    """
    seriesList = []
    f = MakeFunction(func, paramName)
    param = paramValueStart
    while param <= paramValueEnd:
        seriesList.append(f(param))
        param += paramValueStep
    return seriesList
