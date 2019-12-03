import os



def getdefaultbathyTheme():
	from StormImpactApplication.HiddeLibraries.MapFunctions import *
	from SharpMap.Rendering.Thematics import ColorBlend
	from SharpMap.Rendering.Thematics.ThemeFactory import CreateGradientTheme
	
	sizeMin = -15
	sizeMax = 15
	colors = (Color.Indigo, Color.DarkBlue, Color.Blue, Color.Cyan, Color.Green, Color.YellowGreen, Color.Yellow, Color.Orange, Color.OrangeRed, Color.Red, Color.DarkRed)
	positions = (0.0, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1.0)
	gradient = ColorBlend(colors, positions)
	bathyTheme = CreateGradientTheme('bathymetry', None, gradient, sizeMin, sizeMax, 1, 1, False, False, 8)
	
	return bathyTheme


#region GetKBnrfromMap, writes KBnr/url to file for download
from SharpMap.UI.Tools import MapTool

class GetKBnr(MapTool): #naar voorbeeld van Hidde
	def __init__(self):
		self.Layer = None

	def OnKeyDown(self, e):
		import System
		import clr
		clr.AddReference("System.Core")
		clr.AddReference("System.Windows.Forms")
		clr.ImportExtensions(System.Linq)
		from System.Windows.Forms import Keys
		if (e.KeyData == Keys.Enter):
			KBurllist = self.MapControl.SelectedFeatures.Select(lambda f: f.Attributes['KBurl']).ToArray()
			KBnrlist = self.MapControl.SelectedFeatures.Select(lambda f: f.Attributes['KBnr']).ToArray()
			for nr in KBnrlist:
				PrintMessage("%s selected" %nr)
			write_varstringlisttotxt("JarkusKBnrlist.txt", KBnrlist)
		
	#def OnMouseUp(self, worldPosition, e):
	#	PrintMessage("clicked")
	#	#PrintMessage(self.MapControl.SelectedFeatures.Count)
	#	#PrintMessage(self.MapControl.SelectedFeatures[0].Geometry.Boundary[0].X)
	#	#PrintMessage(self.MapControl.SelectedFeatures[0].Geometry.Boundary[2].X)
	#	#PrintMessage(self.MapControl.SelectedFeatures[0].Geometry.Boundary[1].Y)
	#	#PrintMessage(self.MapControl.SelectedFeatures[0].Geometry.Boundary[3].Y)

#endregion

#region GetTwoMapCoordinatesTool, draws points and line in map
from SharpMap.UI.Tools import MapTool
from StormImpactApplication.HiddeLibraries.MapFunctions import *
from StormImpactApplication.HiddeLibraries.StandardFunctions import *
from GisSharpBlog.NetTopologySuite.Geometries import Coordinate as _Coordinate
from Libraries.Utils.Project import PrintMessage

class GetTwoMapCoordinatesTool(MapTool): #naar voorbeeld van Hidde

	def __init__(self):
		self.FirstCoordinate = None
		self.SecondCoordinate = None
		self.Layer = None
	
	def OnMouseDown(self, worldPosition, e):
		self.Layer.DataSource.Add(Feature(Geometry = CreatePointGeometry(worldPosition.X, worldPosition.Y)))
		self.Layer.RenderRequired = True
		
		if (self.FirstCoordinate != None and self.SecondCoordinate != None):
			self.FirstCoordinate = None
			self.SecondCoordinate = None

			return
		if (self.FirstCoordinate == None):
			self.FirstCoordinate = worldPosition
			return 
			
		if(self.SecondCoordinate == None):
			self.SecondCoordinate = worldPosition
			PrintMessage("XB_coordland = [%f, %f]" %(self.FirstCoordinate.X, self.FirstCoordinate.Y))
			PrintMessage("XB_coordsea = [%f, %f]" %(self.SecondCoordinate.X, self.SecondCoordinate.Y))
			PrintMessage("Run XBRTplot2DbathyWrXB to make a grid with these coordinates")
			self.Layer.DataSource.Add(Feature(Geometry = CreateLineGeometry([[self.FirstCoordinate.X, self.FirstCoordinate.Y],[self.SecondCoordinate.X, self.SecondCoordinate.Y]])))
			self.Layer.RenderRequired = True
			
			XB_coordland = [self.FirstCoordinate.X, self.FirstCoordinate.Y]
			XB_coordsea = [self.SecondCoordinate.X, self.SecondCoordinate.Y]
			write_varlisttotxt('XB_coordland.txt', XB_coordland)
			write_varlisttotxt('XB_coordsea.txt', XB_coordsea)
			
			self.FirstCoordinate = None
			self.SecondCoordinate = None
			return
#endregion

#region GetXBeachExecutablePath (door pieter)
def GetXBeachExecutablePath():
	import clr
	
	for reference in clr.References:
		if (reference.GetName().Name == "DeltaShell.Plugins.XBeach.Common" ):
			return os.path.dirname(reference.Location)
#endregion

def GetDefaultScriptingPath():
	import clr
	
	for reference in clr.References:
		if (reference.GetName().Name == "DeltaShell.Plugins.Toolbox" ):
			return os.path.dirname(reference.Location)

#region areaname2areacode (door Kees den Heijer)
def areaname2areacode(areaname):
	import numpy as np
	"""
	returns areaname for a specified areacode as input.
	\nToDo: include in another class of the same package "jarkus_transects", eventually.
	"""
	# areas according to RWS definition
	areas = {"Schiermonnikoog":2,"Ameland":3,"Terschelling":4,"Vlieland":5,
	"Texel":6,"Noord-Holland":7,"Rijnland":8,"Delfland":9,
	"Maasvlakte":10,"Voorne":11,"Goeree":12,"Schouwen":13,
	"Noord-Beveland":15,"Walcheren":16,"Zeeuws-Vlaanderen":17}
	if type(areaname) == np.str:
		return areas.get(areaname)
	if type(areaname) == list:
	    return map(areas.get, areaname)
#endregion

#"""
#region CreateCurvilinearCoverageLayer (edited version of libraries.utils.gis.CreateRegularGridCoverageLayer)
def CreateCurvilinearCoverageLayer(coverage):
	from SharpMap.Data.Providers import FeatureCollection as _FeatureCollection
	from SharpMap.Layers import DiscreteGridPointCoverageLayer as _DiscreteGridPointCoverageLayer
	
	layer = _DiscreteGridPointCoverageLayer()#(Grid=coverage,Name=coverage.Name)
	#layer.Name = coverage.Name
	#layer.Grid = coverage
	layer.DataSource = _FeatureCollection()
	layer.DataSource.CoordinateSystem = coverage.CoordinateSystem
	return layer
#endregion
#"""

#region CreateRegularGridCoverage (door Pieter)
def CreateRegularGridCoverage(nx,ny,dx,dy,x0,y0,z_data,time_len,ntime):
	from NetTopologySuite.Extensions.Coverages import RegularGridCoverage
	#from DeltaShell.Plugins.SharpMapGis.Gui import RegularGridCoverageProperties as prop
	from DelftTools.Functions.Filters import VariableValueFilter
	from DelftTools.Functions.Generic import Variable
	from Libraries.Utils.Gis import * #nodig voor GetCoordinateSystem
	import System
	from System import DateTime
	
	grid = RegularGridCoverage(nx,ny,dx,dy,x0,y0)
	
	tstart = DateTime(1965,01,01)
	
	timeVariable = Variable[DateTime]("time");
	grid.Time = timeVariable;
	cornervals = [z_data[-1,1,1], z_data[-1,-1,1], z_data[-1,1,-1], z_data[-1,-1,-1]]
	grid.Components[0].NoDataValue = max(cornervals)
	#grid.Components[0].MaxValidValue = 15
	
	for i in range(time_len-ntime, time_len): #use amount of timesteps from z_data
		currentTime = tstart.AddYears(i)
		zValues = System.Array.CreateInstance(float, ny, nx) #X en Y zijn omgekeerd, want hoogte is eerste indexnr
		for x in range(0,nx):
			for y in range(0,ny):
				zValues[y,x] = z_data[i,y,x] #X en Y zijn omgekeerd, want hoogte is eerste indexnr
		grid.SetValues(zValues, VariableValueFilter[DateTime](timeVariable, currentTime));
	
	grid.CoordinateSystem = GetCoordinateSystem(28992)
	return grid
#endregion

#region GetjrkSetName with locationoffset (input "10025", output "Delfland")
def GetjrkSetName(locationOffset, year):
	string = "%d (%d)" %(locationOffset, year)
	jrkSetName = None
	for kustvak in RootFolder.Items[0].MorphAnData.JarkusMeasurementsList: #loopje langs kustvaknames, eg morphAnData.JarkusMeasurementsList[kustvakname]
		for raai in kustvak.Transects: #loopje langs raaien in bovenstaane, eg kustvak.Transects[raai] = morphAnData.JarkusMeasurementsList[kustvakname].Transects[raai]
			if raai.Name == string: #raai.Name = morphAnData.JarkusMeasurementsList[kustvakname].Transects[raai].Name
				jrkSetName = kustvak.Name
				print "found raai %s in %s" %(string, jrkSetName)
	if jrkSetName == None:
		raise Exception("Jarkus gegevens voor raai %d in jaar %d zijn niet beschikbaar in de workspace" %(locationOffset, year))

	return jrkSetName
#endregion


#region GetJarkusTransect (door Pieter)
def GetJarkusTransect(jrkSetName,locationOffset,year):
	from Libraries.MorphAn.MorphAnData import GetJarkusMeasurementsSet
	set = GetJarkusMeasurementsSet(jrkSetName)
	transect = set.Transects[0]
	for transect in set.Transects:
		if transect.TransectLocation.Offset == locationOffset and transect.Time.Year == year:
			return list(transect.XCoordinates),list(transect.ZCoordinates)
	return None, None
#endregion

#region GetJarkusTransectLocation
def GetJarkusTransectLocation(jrkSetName,locationOffset):
	from Libraries.MorphAn.MorphAnData import GetJarkusMeasurementsSet
	set = GetJarkusMeasurementsSet(jrkSetName)
	transect = set.Transects[0]
	location = None
	for transect in set.Transects:
		if transect.TransectLocation.Offset == locationOffset:
			location = transect.TransectLocation
	if location == None:
		raise Exception("Er is geen raai %d in %s" %(locationOffset, jrkSetName))
	return location
#endregion


def writebeddep2D(nx, ny, z):
	with open('bed.dep','w') as beddep:
		for yloc in range(0,ny+1):
			list = []
			for xloc in range(0,nx+1):
				list.append(z[yloc, xloc]) #X en Y zijn omgekeerd, want hoogte is eerste indexnr 
			#print list
			string = ' '.join("%e" %i for i in list)
			beddep.write(string)
			beddep.write('\n')
	return

def writexgrd2D(x, nx, ny):
	with open('x.grd','w') as xgrd:
		for yloc in range(0,ny+1):
			xony = []
			for i in range(yloc*(nx+1),yloc*(nx+1)+nx+1):
				xony.append(x[i])
			string = ' '.join("%e" %i for i in xony) #x is 2D, maar dit kan met np.array
			xgrd.write(string)
			xgrd.write('\n')
	return
	
def writeygrd2D(y, nx, ny):
	with open('y.grd','w') as ygrd:
		for yloc in range(0,ny+1):
			yony = []
			for i in range(yloc*(nx+1),yloc*(nx+1)+nx+1):
				yony.append(y[i])
			string = ' '.join("%e" %i for i in yony) #y is 2D, maar dit kan met np.array
			ygrd.write(string)
			ygrd.write('\n')
	return


#region jrktoXB: reverse x list and start at 0 for XBeach if necessary, also reverse z list if necessary
def jrktoXB(x, z):
	import numpy as np
	if z[-1] < z[0]:
		x_XB = x[::-1]
		x_XB = np.array(x_XB) - max(x_XB)
		x_XB = abs(x_XB)
		
		z_XB = z[::-1]
		
	else:
		x_XB = x
		x_XB = np.array(x_XB) - min(x_XB)
		
		z_XB = z

	return x_XB, z_XB
	
#region write bed.dep to dir
def writebeddep(z_XB, ny):
	with open('bed.dep','w') as beddep:
		string = ' '.join("%e" %i for i in z_XB)
		for i in range(0,ny+1):
			beddep.write(string)
			beddep.write('\n')
	return None
#endregion

#region write x.grd to dir
def writexgrd(x_XB, ny):
	with open('x.grd','w') as xgrd:
		string = ' '.join("%e" %i for i in x_XB)
		for i in range(0,ny+1):
			xgrd.write(string)
			xgrd.write('\n')
	return None
#endregion

#region write y.grd to dir
def writeygrd(dy_grid, ny, nx):
	import numpy as np
	#make list of ny+1 y values
	y_XB = np.arange(0, dy_grid*ny+1, dy_grid)
	
	#write y.grd
	with open('y.grd','w') as ygrd:
		for i in range(0,ny+1):
			y = [y_XB[i]] * (nx+1)
			string = ' '.join("%e" %i for i in y)
			ygrd.write(string)
			ygrd.write('\n')
	
	return None
#endregion
	
def write_varstringlisttotxt(filename, varlist):
	with open(filename,'w') as f:
	    for string in range(len(varlist)): #useful for 2D grid
	    	f.write(varlist[string])
	    	f.write('\n')
	
def get_varstringlistfromtxt(filename):
	with open(filename) as f:
		varlist = []
		for line in f:
			url = line.replace("\n", "")
			varlist.append(url)
	return varlist

def write_varlisttotxt(filename, varlist):
	with open(filename,'w') as f:
	    string = ' '.join("%e" %i for i in varlist)
	    #for i in range(0,ny+1): #useful for 2D grid
	    f.write(string)
	
def get_varlistfromtxt_ony0(filename):
	with open(filename) as f:
		varstring = f.readlines()[0].strip().split() #x_XB werd gedefined in MorphAnJarkus, maar zo is het onafhankelijk daarvan
	varlist = [float(item) for item in varstring]
	return varlist

def get_varlistfromtxt_onysel(filename, y_sel):
	with open(filename) as f:
		varstring = f.readlines()[y_sel].strip().split() #x_XB werd gedefined in MorphAnJarkus, maar zo is het onafhankelijk daarvan
	varlist = [float(item) for item in varstring]
	return varlist

def write_vartotxt(filename, var):
	with open(filename,'w') as f:
		f.write('%f' %var)
		
def get_varfromtxt(filename):
	with open(filename) as f:
		var = float(f.readlines()[0].strip())
	return var


def getAnalysisTimefromtxt(filename):
	with open(filename) as file:
		for i, line in enumerate(file):
			if i == 6:
				return int(line.split()[4])

def get_nxnyfromparamstxt(filename):
	with open(filename) as file:
		for i, line in enumerate(file):
			if i == 16:
				nx = int(line.split()[2])
			if i == 17:
				ny = int(line.split()[2])
	return nx, ny
			
def get_nxnyfromxgrd(filename):
	with open(filename) as file:
		ny = len(file.readlines())-1
	with open(filename) as file:
		nx = len(file.readlines()[0].split())-1
	return nx, ny



#region writeparamstxt
def writeparamstxt(nx, ny, snells, thetamin, thetamax, dtheta, tsmat_real_tstop, XBO_tint, tstart, xbo_globalvars, xbo_meanvars):
	
	XBvars = {
	"nx":nx,
	"ny":ny,
	"snells": snells,
	"thetamin": thetamin,
	"thetamax": thetamax,
	"dtheta": dtheta,
	"tstop": tsmat_real_tstop,
	"tint": XBO_tint,
	"tstart": tstart,
	"nglobalvar": len(filter(None, xbo_globalvars)),
	"gvar1": xbo_globalvars[0],
	"gvar2": xbo_globalvars[1],
	"gvar3": xbo_globalvars[2],
	"gvar4": xbo_globalvars[3],
	"gvar5": xbo_globalvars[4],
	"nmeanvar": len(filter(None, xbo_meanvars)),
	"mvar1": xbo_meanvars[0],
	"mvar2": xbo_meanvars[1],
	"mvar3": xbo_meanvars[2],
	"mvar4": xbo_meanvars[3],
	"mvar5": xbo_meanvars[4]}
	
	# paramstemplate
	paramstemplate = """%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% XBeach parameter settings input file                                     %%%
%%%                                                                          %%%
%%% created with: python scripting in DeltaShell                             %%%
%%% function: writeparamstxt                                                 %%%
%%%                                                                          %%%
%%% params in this file are different from the default XBeach params         %%%
%%% the other (default) XBeach params are in XBlog.txt after startrun        %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%% Grid parameters %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

gridform   = xbeach
xfile      = x.grd
yfile      = y.grd
vardx      = 1
nx         = {nx}
ny         = {ny}
depfile    = bed.dep
posdwn     = -1
thetamin   = {thetamin}
thetamax   = {thetamax}
snells     = {snells}
dtheta     = {dtheta}

%%% WTI PARAMETERS (Deltares2015_XBeachDefaults) %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fw         = 0.000
bedfriccoef = 0.001
bedfriction = cf
gammax     = 2.364
beta       = 0.138
wetslp     = 0.260
alpha      = 1.262
facSk      = 0.375
facAs      = 0.123
gamma      = 0.541

%%% Model time %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

tstop      = {tstop}
CFL        = 0.900

%%% Morphology parameters %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

morfac     = 10

%%% Tide boundary conditions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

tideloc    = 2
zs0file    = tide.txt

%%% Wave boundary condition parameters %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

random     = 0
instat     = jons_table
bcfile     = waves.lst
thetanaut  = 1

%%% Output variables %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

tint         = {tint}
tstart       = {tstart}
outputformat = netcdf

nglobalvar = {nglobalvar}
{gvar1}
{gvar2}
{gvar3}
{gvar4}
{gvar5}

nmeanvar = {nmeanvar}
{mvar1}
{mvar2}
{mvar3}
{mvar4}
{mvar5}"""
	
	#Write params.txt to dir and confirm
	with open('params.txt','w') as paramstxt:
	    paramstxt.write(paramstemplate.format(**XBvars))
	
	return None
#endregion

