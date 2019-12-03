from DeltaShell.Plugins.MorphAn.Domain import *
from DeltaShell.Plugins.XBeach1D.Model import *
from DeltaShell.Plugins.XBeach.Common.Models import *
from DeltaShell.Plugins.XBeach.Common.Models.WaveInput import *
from DeltaShell.Plugins.XBeach.Common.Gui.Forms import *
from DelftTools.Utils.Collections.Generic import *
from System import *
import System
from Libraries.MorphAn.Models import *
from Libraries.Utils.Functions import *
from Libraries.MorphAn.Models import *
from Libraries.XBeach.XBeach import *
from DeltaShell.Plugins.XBeach.Common.Models import XBeach1DModelBase as _XBeach1DModelBase
from DeltaShell.Plugins.MorphAn.Domain import Transect as _Transect
from System import Double as _Double
from DelftTools.Functions.Filters import VariableValueFilter as _VariableValueFilter
from System import DateTime as _DateTime

def CreateXBeachModel(x,z,waterLevel=5.0,Hs=9,Tp=16,D50=0.000250):
	"""
	Calculates an erosion profile according to the DUROS+ model
	@param x: Array of X coordinats describing the initial profile
	@param z: Array of Z coordinats describing the initial profile
	@param waterLevel: The maximum storm surge level that is taken into account (optional, default = 5.0)
	@param Hs: The significant wave height during the peak of the storm that is used to calculate the erosion profile (optional, default = 9)
	@param Tp: The wave peak period during the peak of the storm that is used to calculate the erosion profile (optional, default = 16)
	@param D50: The median grain size (in meters) used to calculate an erosion profile (optional, default = 0.000250)
	"""
	
	#Create and configure model
	model = XBeach1DModel()
	
	# Add initial profile
	model.MeasuredTransect = Transect(x,z)
	
	# Add wave conditions
	spectralCondition = XBeachWaveInputSpectral()
	spectralCondition.SignificantWaveHeight = Hs
	spectralCondition.WavePeriod = Tp
	eventedList = EventedList[XBeachWaveInputSpectral]()
	eventedList.Add(spectralCondition)
	model.WaveInput = XBeachWaveInputList(eventedList)
	
	# Specify D50 and D90
	XBeach1DModelBaseExtensions.GetParameter[Double](model,"D50").Value = D50
	XBeach1DModelBaseExtensions.GetParameter[Double](model,"D90").Value = D50*1.5
	
	# Specify Tide
	model.Tide.UseConstantWaterLevel = False
	model.Tide.Clear()
	model.Tide[0.0] = waterLevel
	model.Tide[1*3600.0] = waterLevel

	return model

def RunXBeachModel(model) :
	"""
	Runs an XBeach model
	"""
	if (model != None and hasattr(model,'ExplicitWorkingDirectory')) :
		Application.ActivityRunner.Enqueue(model)


def GetFinalProfile(modelName):
	"""model = GetModel(modelName)
	if (not isinstance(model,_XBeach1DModelBase) or model.XBeachOutputNetCdfStore == None or not model.XBeachOutputNetCdfStore.IsValidStore):
		print "No output was found"
		return _Transect()
	
	outputVariable = None
	for variable in model.GlobalOutputVariables:
		if (variable.Name == outputName):
			outputVariable = variable
			
	if (outputVariable == None):
		print "No output was found"
		return _Transect()
		
	timeArgument = GetArgumentByName(outputVariable,"Time")
	lastTime = timeArgument.Values.MaxValue
	xValues = list(GetArgumentByName(outputVariable,"globalx").Values)
	zValues = list(GetComponentByName(outputVariable,outputName).GetValues(_VariableValueFilter[_DateTime](timeArgument, lastTime)))
	
	return _Transect(xValues,zValues)
	"""
	return GetXBeachModelProfile(modelName)
	
def GetXBeachModelProfile(modelName,time = None):
	return GetXBeachModelOutput(modelName,time,"zb")

def GetXBeachModelOutput(modelName,time = None, outputName = None):
		
	model = GetModel(modelName)
	if (not isinstance(model,_XBeach1DModelBase) or model.XBeachOutputNetCdfStore == None or not model.XBeachOutputNetCdfStore.IsValidStore):
		print "No output was found"
		return _Transect()
	
	if (outputName == None):
		outputName = "zb"
	
	outputVariable = None
	for variable in model.GlobalOutputVariables:
		if (variable.Name == outputName):
			outputVariable = variable
			
	if (outputVariable == None):
		print "No output was found"
		return _Transect()
		
	timeArgument = GetArgumentByName(outputVariable,"Time")
	
	if (time == None):
		time = timeArgument.Values.MaxValue
	if (not isinstance(time,_DateTime)):
		#assume it is a double that specifies elapsed time in seconds
		targetTime = model.StartTime.AddSeconds(time)
		temptime = None
		for currentTime in timeArgument.Values:
			if (currentTime > targetTime):
				break
			temptime = currentTime
		if (temptime == None):
			time = timeArgument.Values.MinValue
		else:
			time = temptime
	
	xValues = list(GetArgumentByName(outputVariable,"globalx").Values)
	zValues = list(GetComponentByName(outputVariable,outputName).GetValues(_VariableValueFilter[_DateTime](timeArgument, time)))
	
	return _Transect(xValues,zValues)