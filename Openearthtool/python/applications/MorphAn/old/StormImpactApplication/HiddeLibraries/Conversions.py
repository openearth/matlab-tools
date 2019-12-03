from datetime import datetime as _datetime, time
from System import DateTime as _DateTime
from System import TimeSpan as _TimeSpan
from System import Array as _Array

from DelftTools.Functions import TimeSeries as _TimeSeries
from DelftTools.Functions.Generic import Variable as _Variable

def ConvertToDotNetTimeSpan(pythonTime):
    """Converts a python time object to 
    a .Net System.TimeSpan object"""
    if(isinstance(pythonTime, time)):
        return _TimeSpan(pythonTime.hour, pythonTime.minute, pythonTime.second)

def ConvertToDotNetDateTime(pythonDateTime):
    """Converts a python datetime object to 
    a .Net System.DateTime object"""
    if(isinstance(pythonDateTime, _datetime)):
        return _DateTime(pythonDateTime.year, pythonDateTime.month, pythonDateTime.day,pythonDateTime.hour,pythonDateTime.minute,pythonDateTime.second)

def ConvertToPythonDateTime(dotNetDateTime):
    """Converts a .Net System.DateTime object to 
    a python datetime object"""
    if(isinstance(dotNetDateTime, _DateTime)):
        return _datetime(dotNetDateTime.Year, dotNetDateTime.Month, dotNetDateTime.Day,dotNetDateTime.Hour,dotNetDateTime.Minute,dotNetDateTime.Second)

def FillTimeSeries(timeSeries, list):
    """Fills a DeltaShell timeseries object with the values of
    the provided list of datetime, value"""
    for item in list:
        timeSeries[ConvertToDotNetDateTime(item[0])] = item[1]               
    return timeSeries

def CreateTimeSeries(list):
    """Creates a DeltaShell timeseries object from
    the provided list of datetime, value"""
    timeSeries = _TimeSeries()
    timeSeries.Components.Add(_Variable[float]("Value"))
    FillTimeSeries(timeSeries, list)    
    return timeSeries

def CreateDateTimeList(timeSeries):
    """Creates a list of datetime, value object from
    the provided DeltaShell timeseries"""
    list = []
    for timeValue in timeSeries.Arguments[0].Values:
        list.append([ConvertToPythonDateTime(timeValue), timeSeries[timeValue]])
    return list

def CreateTwoDimDotNetArray(type, list):
    """convert [[]] list to 2d .Net array"""
    lengthFirstDim = len(list)
    lengthSecondDim = len(list[0])
    
    array = _Array.CreateInstance(type, lengthFirstDim, lengthSecondDim)
    for indexFirstDim in range(lengthFirstDim):
        for indexSecondDim in range(lengthSecondDim):
            array[indexFirstDim,indexSecondDim] = list[indexFirstDim][indexSecondDim]
    return array