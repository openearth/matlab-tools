#   Copyright notice
#   --------------------------------------------------------------------
#   Copyright (C) 2017 RoyalHaskoningDHV
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
import numpy as np
import math as math
from Libraries.StandardFunctions import *
from Libraries.ChartFunctions import *
import scipy as scipy

def get_varangle(cota):
	tana=float(1)/cota # Tan alfa slope
	alfa=np.arctan(tana).Value
	return tana,alfa

def steepness(Hs,Tm,g):
	"""Calculates wave steepness based on Hs and Tm or Tp"""
	stp=(2 * math.pi*Hs)/(g*Tm**2)
	return stp

def calcMeanWavePeriod(Tp):
	"""Assumption that constant ratio is Tm=Tp/1.1.
	Hard coded!!"""
	Tm=Tp/1.1
	return Tm

def calcRelativedensity(rhos,rhow):
	delta=float(rhos)/rhow-1
	return delta

def calcNumberofWaves(stormdur,Tm):
	"""Calculate number of waves based on mean wave period and stormduration in hours"""
	N=float(stormdur)/Tm*3600
	return N

def irribarren(stp,tana):
	"""Calculates the irribarren number (ratio wave steepness and slope angle)"""
	
	irri=tana/(stp)**0.5 #Irribarren
	return irri

def vanderMeer_stability_rock(Hs,delta,irri,S,N,P,cpl,cs,cota):
	"""Van der Meer stability formulas for rock, checks whether waves are plunging or breaking
	Output is required Dn50 and critical irribarren number
	INPUT:
		Hs: Significant wave height (m)
		delta: Relative density (-)
		irri: Irribarren number
		S: Damage number (-)
		N: Number of waves (-)
		P: Notional permeability (-)
		cpl: constant
		cs: constant
		cota: Cotangens slope angle
	OUTPUT:
		Dn50: Required median stone size
		irricrit: Critical irribarren number
		isPlunging[Boolean] = Whether waves are plunging (true) of surging (false)"""
		
	[tana,alfa]=get_varangle(cota)
	
	irricrit=((cpl/cs)*P**0.31*tana**0.5)**(1/(P+0.5)) #Critical irribarren
	
	if irri<irricrit or cota>=4:
		Dn50=Hs/(delta*cpl*P**0.18*(S/N**0.5)**0.2*irri**-0.5)
		isPlunging = True
		#print "Plunging"
	
	else:
		Dn50=Hs/(delta*cs*P**-0.13*(S/N**0.5)**0.2*cota**0.5*irri**P)
		isPlunging = False
		#print "Surging"
	
	return Dn50,irricrit,isPlunging

def get_M50(Dn50,rhos):
	"""Get equivalent median Mass of stone (qubic)
	See Rock Manual"""
	
	M50=rhos*Dn50**3
	return M50
	
def get_D50(M50,rhos):
	"""Get cubic equivalent median stone diameter from median mass"""
	
	D50=(M50/rhos)**(1.0/3)
	return D50

def get_grading(Dn50):
	"""Get grading (min and max) of stones based on NEN table of Rock Manual(Table 3.5)
	Be aware that table is hard coded!!"""
	
	gradtable=np.array([[5,10,40,60,300,1000,3000,6000],[40,60,200,300,1000,3000,6000,10000]])
	gradtablemn=np.array([0.2,0.24,0.36,0.42,0.65,0.92,1.21,1.46])
	if Dn50>np.max(gradtablemn):
		idgrad=np.size(gradtablemn)-1
		isTooLarge = True
	else:
		idgrad=np.argmax(Dn50<=gradtablemn).Value
		isTooLarge = False
	
	gradmin=gradtable[0,idgrad].Value
	gradmax=gradtable[1,idgrad].Value
	Dn50_grad=gradtablemn[idgrad].Value
	return gradmin,gradmax,Dn50_grad,isTooLarge

def calcGammabeta(angleinc):
	"""Calculates the correction factor for oblique waves according to TAW (Rock manual)
	Input is angle of incidence to shore normal, so zero means perpendicular to coast"""
	
	angleinc = float(angleinc)
	if np.abs(angleinc).Value>90:
		raise Exception('ERROR: Angle of incidence cannot be larger than 90 degreest')
		
	gammabeta=np.max([0.8,1-0.0022*np.abs(angleinc).Value]) # Correction factor for oblique waves
	return gammabeta

def calcOvertopping_TAW(Hs,Rc,irri,gammab,gammaf,gammabeta,tana,g):
	"""Calculates overtopping discharge in l/s/m(!) according to TAW (Rock Manual)
	Input:
		Hs: Significant wave height
		Rc: Crestheight above SWL (freeboard)
		irri: Irribarren number
		gammab: Correction factor for berms
		gammaf: Correction factor for rough slopes
		gammabeta: Correction factor for oblique incident waves
		tana: Tangens of slope angle (-)
		g: gravitational constant
		
	Output:
		qovertopping: Overtopping discharge in l/s/m"""
		
	# Constants: Hard coded
	A=0.067 
	B=4.3
	C=0.2
	D=2.3
	
	#Overtopping formula according to TAW (Rock Manual)
	qovertopping=1000*(g*Hs**3)**0.5*(A/tana**0.5)*gammab*irri*np.exp(-B*(Rc/Hs)*(1/(irri*gammab*gammaf*gammabeta))).Value
	
	return qovertopping

def calcGamma_crest(crestwidth,Hs):
	"""Calculates correction for overtopping discharge as a cause of crest width
	Input: 
		crestwidth: Crestwidth (m)
		Hs: Significant wave height (m)
	Output:
		gamma_crest: Correction factor"""
	
	gamma_crest=np.min([1,3.06*np.exp(-1.5*(crestwidth/Hs)).Value]).Value # Correction factor for crest width
	
	return gamma_crest

def calcOvertopping_crest(qovertopping,gamma_crest):
	"""Calculates overtopping discharge in l/s/m including effect of crest width
	Input:
		qovertopping: Overtopping discharge without effect of crest width
		gamma_crest: Correction factor for crestwidth
	Output:
		qovertopping_crest: Overtopping behind crest (l/s/m)"""
	
	#Calculate overtopping including effect of crest width
	qovertopping_crest=gamma_crest*qovertopping
	
	return qovertopping_crest

def calcRequired_crestheight(qthres,Hs,irri,gammab,gammaf,gammabeta,gamma_crest,tana,g):
	"""Calculates required crest height based on critical overtopping (qthres), in fact it is modification of overtopping formula
	It includes effect of crest width!
	Input: 
		qthres: Threshold value for critical overtopping discharge (l/s/m)
		Hs: Significant wave height (m)
		irri: Irribarren number (-)
		gammab: Correction factor for berm
		gammaf: Correction factor for roughness
		gammabeta: Correction factor for oblique waves
		gamma_crest: Correction factor for crest width
		tana: Tangens angle of slope
		g: Gravitational constant
	Output
		Rc_required: Required crestheight above SWL (freeboard)"""
	
	# Constants: Hard coded
	A=0.067
	B=4.3
	qthres=float(qthres)/1000 # Convert dimensions to m3/s/m
	qthres=qthres/float(gamma_crest) # Include effect of crest width 

	Rc_required=(Hs*irri*gammab*gammaf*gammabeta)*(np.log(qthres/((g*Hs**3)**0.5)*(tana**0.5/(A*gammab*irri))).Value/-B)
	return Rc_required

def getFilter_rock(M50_grad,rhos):
	"""Get filter rock grading based on filter rule Rock manual (10 times smaller mass)"""
	
	M50_filter=M50_grad/10 # Filter mass 10 times smaller than armour layer (ROCK manual)
	Dn50_filter=get_D50(M50_filter,rhos)
	return M50_filter,Dn50_filter

def getLayerthickness_rock(Dn50,kt):
	"""Get layer thickness based on thumbrule Rockmanual"""
	layerthick=2*kt*Dn50
	return layerthick

def get_Breakwater_dimensions(crestheight,crestwidth,cota,z,layer_armour,layer_filter):
	"""Calculates breakwater dimensions based on calculated crestheight, 
	crestwidth, depth and thickness of layers
	INPUT:
		crestheight (m)
		crestwidth (m)
		cota = cotangens angle of slope
		z = depth in meters (positive down)
		layer_armour = layer thickness of armour layer (m)
		layer_filter = layer thickness of filter layer (m)
		
	OUTPUT:
		x and y dimensions of outer, armour and filter layer 
		as seperate arrays and xy arrays (for plotting)"""
	
	[tana,alfa]=get_varangle(cota)
	
	if (crestheight+z)<0:
		raise Exception('ERROR: Total depth negative!')
	
	#region Outer dimensions
	dims = {}
	dims['total_height'] = crestheight+z
	dims['xouter'] = np.cumsum(np.array([0,cota*float(dims['total_height']),crestwidth,cota*float(dims['total_height'])]))
	dims['youter'] = np.array([-z,crestheight,crestheight,-z])
	dims['xyouter'] = np.vstack((dims['xouter'],dims['youter'])).T
	#endregion

	#region Armour dimensions
	if (crestheight+z)<layer_armour:
		dims['xarmour_begin']=None
		dims['yarmour_top']=None
		dims['total_armourheight']=None
		dims['xarmour_2']=None
		dims['xarmour_end']=None
		dims['xarmour_3']=None
		dims['xarmour']=None
		dims['yarmour']=None
		dims['xyarmour']=None
	else:
		dims['xarmour_begin']=layer_armour/(np.sin(alfa).Value)
		dims['yarmour_top']=crestheight-layer_armour
		dims['total_armourheight']=dims['yarmour_top']+z
		dims['xarmour_2']=dims['xarmour_begin']+cota*dims['total_armourheight']
		dims['xarmour_end']=dims['xouter'][-1]-dims['xarmour_begin']
		dims['xarmour_3']=dims['xarmour_end']-(cota*dims['total_armourheight'])
		dims['xarmour']=np.array([dims['xarmour_begin'],dims['xarmour_2'],dims['xarmour_3'],dims['xarmour_end']])
		dims['yarmour']=np.array([-z,dims['yarmour_top'],dims['yarmour_top'],-z])
		dims['xyarmour']=np.vstack((dims['xarmour'],dims['yarmour'])).T
	#endregion

	#region Filter dimensions
	if (crestheight+z)<(layer_armour+layer_filter):
		dims['xfilter_begin']=None
		dims['yfilter_top']=None
		dims['total_filterheight']=None
		dims['xfilter_2']=None
		dims['xfilter_end']=None
		dims['xfilter_3']=None
		dims['xfilter']=None
		dims['yfilter']=None
		dims['xyfilter']=None
	else:
		dims['xfilter_begin']=dims['xarmour_begin']+layer_filter/(np.sin(alfa).Value)
		dims['yfilter_top']=dims['yarmour_top']-layer_filter
		dims['total_filterheight']=dims['yfilter_top']+z
		dims['xfilter_2']=dims['xfilter_begin']+(cota*dims['total_filterheight'])
		dims['xfilter_end']=dims['xouter'][-1]-dims['xfilter_begin']
		dims['xfilter_3']=dims['xfilter_end']-(cota*dims['total_filterheight'])
		dims['xfilter']=np.array([dims['xfilter_begin'],dims['xfilter_2'],dims['xfilter_3'],dims['xfilter_end']])
		dims['yfilter']=np.array([-z,dims['yfilter_top'],dims['yfilter_top'],-z])
		dims['xyfilter']=np.vstack((dims['xfilter'],dims['yfilter'])).T
	#endregion
	
	return dims

def get_Breakwater_areas(dims):
	"""Calculates the cross sectional area of breakwater, based on calculated breakwater dimensions"""
	area={}
	area['outer']=dims['xouter'][2]*dims['total_height']
	area['core']=(dims['xfilter'][2]-dims['xfilter'][0])*dims['total_filterheight']
	area['filterandcore'] = (dims['xarmour'][2]-dims['xarmour'][0])*dims['total_armourheight']
	area['armour'] = area['outer'] - area['filterandcore']
	area['filter'] = area['filterandcore'] - area['core']
	
	return area
	
def get_Breakwater_volumes(area,length):
	"""Calculates volumes based on cross sectional area of breakwater and the length of the (part) of breakwater"""
	volume={}
	for k,v in area.items():
		volume[k] = v*length
	
	return volume

def get_profile_mean(profile):
	"""Calculate spacing and mean profile depth at 'centre' points"""
	
	profile['ds'] = np.diff(profile['dist'])
	profile['mean_z'] = np.mean([profile['z'][0:-1],profile['z'][1:len(profile['z'])]],axis=0)
	profile['mean_dist'] = np.mean([profile['dist'][0:-1],profile['dist'][1:len(profile['dist'])]],axis=0)
	profile['mean_dist_pl2'] = np.mean([profile['dist_pl2'][0:-1],profile['dist_pl2'][1:len(profile['dist_pl2'])]],axis=0)
	
	return profile
	
def get_Qthres(ip,Critical_type):
	Type_Index = Critical_type.IndexOf(ip.situation)
	QthresValues = np.array([0.03,0.1,1,0.01,10,10,50,0.001,0.03,2,20,50])
	qthres = QthresValues[Type_Index].Value
	return qthres
	
def get_Qthres_Index(Type_Index):
	#Type_Index = Critical_type.IndexOf(ip.situation)
	QthresValues = np.array([0.03,0.1,1,0.01,10,10,50,0.001,0.03,2,20,50])
	qthres = QthresValues[Type_Index].Value
	return qthres

def get_situation_list(Critical_type):
	Critical_type.Items.Add('Pedestrians (unaware)')
	Critical_type.Items.Add('Pedestrians (aware)')
	Critical_type.Items.Add('Pedestrians (trained staff)')
	Critical_type.Items.Add('Vehicles (high speed)')
	Critical_type.Items.Add('Vehicles (low speed)')
	Critical_type.Items.Add('Marinas (small boats)')
	Critical_type.Items.Add('Marinas (large yachts)')
	Critical_type.Items.Add('Buildings (no damage)')
	Critical_type.Items.Add('Buildings (moderate damage)')
	Critical_type.Items.Add('Embankment (no damage) ')
	Critical_type.Items.Add('Embankment (crest not protected)')
	Critical_type.Items.Add('Embankment (back slope not protected)')
	return Critical_type

def get_armour_types(Armour_type):
	Armour_type.Items.Add('Rock')
	#armour_types.Items.Add('Cube (1 layer)')
	#armour_types.Items.Add('Cube (2 layers)')
	#armour_types.Items.Add('Tetrapod')
	#armour_types.Items.Add('Dolos')
	#armour_types.Items.Add('Accropode')
	#armour_types.Items.Add('Core-loc')
	#armour_types.Items.Add('Xbloc')
	return Armour_type

def get_bathygrid(ElevationPath):
	#ElevationPath = r"C:\Users\905252\Documents\CoDeS\plugins\DeltaShell.Plugins.Toolbox\Scripts\BathymetryData\Testdata\NorthSea\rws_testdata_grid_positive.asc"

	provider = GdalFeatureProvider()
	provider.Open(ElevationPath)	
	grid = provider.Grid
	return grid

def get_LineGeometry(LineLayer):
	"""Get line geometry from feature layer, by default take first feature"""
	LineFeatures = LineLayer.GetFeatures(LineLayer.Envelope)
	ResultFeature = None
	
	for LineFeature in LineFeatures:
		ResultFeature = LineFeature
		
		
	return ResultFeature.Geometry


	




