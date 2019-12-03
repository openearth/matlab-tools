import urllib
from Libraries.NetCdfFunctions import *

# Download a netCdf file from the opendap server
remote_path = "http://opendap.deltares.nl/static/deltares/delftdashboard/toolboxes/TideStations/iho.nc"
urllib.urlretrieve (remote_path, "D:\\iho.nc")

file = NetCdfFile.OpenExisting("D:\\iho.nc")

# show all variables
for var in file.GetVariables():
    print file.GetVariableName(var)

# show all dimensions
for dim in file.GetAllDimensions():
    print file.GetDimensionName(dim)

# get variables
stations = file.GetVariableByName("stations")
components = file.GetVariableByName("components")

# get dimensions lengths
nrOfStations = file.GetDimensionLength(file.GetDimension("stations"))
nrOfComponents = file.GetDimensionLength(file.GetDimension("components"))
componentNameLength = file.GetDimensionLength(file.GetDimension("component_string_length"))
stationNameLength = file.GetDimensionLength(file.GetDimension("name_string_length"))

# read the data from the netCdf file
stationNames = Transpose2DCharArrayToStringList(file.Read(stations),stationNameLength, nrOfStations)
componentNames = Transpose2DCharArrayToStringList(file.Read(components),componentNameLength, nrOfComponents)

# show dimentions used for a variable
for dim in file.GetDimensions(file.GetVariableByName("amplitude")):
    print file.GetDimensionName(dim)

# read the 2 dimentional arrays
latData = file.Read(file.GetVariableByName("lat"))
lonData = file.Read(file.GetVariableByName("lon"))
phaseData = file.Read(file.GetVariableByName("amplitude"))
amplitudeData = file.Read(file.GetVariableByName("amplitude"))

# print coordinatesystem
print file.GetAttributeValue(file.GetVariableByName("crs"),"coord_ref_sys_name")

file.Close()

class Station:
    # Station definition (name, geometry and componentInformation (amplitudes and phases))
    def __init__(self, name, point, amplitudeArray, phaseArray):
        self.name = name.strip()
        self.geometry = point
        self.amplitudeArray = amplitudeArray
        self.phaseArray = phaseArray

stationList = []
for i in range(nrOfStations):
    phaseComponents = GetArrayFromSecondDimention(phaseData, i, nrOfComponents)
    amplitudeComponents = GetArrayFromSecondDimention(amplitudeData, i, nrOfComponents)

    geometry = Point(lonData[i],latData[i])

    # create station
    station = Station(stationNames[i], geometry, amplitudeComponents, phaseComponents)
    stationList.append(station)
    
print "Number of stations found : " + str(len(stationList))