#   Copyright notice
#   --------------------------------------------------------------------
#   Copyright (C) 2016 RoyalHaskoningDHV
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


#region input variables 
Hs=3 # Significant wave height -> Assumed that Hm0 equals H(1/3) equals Hs
Tp=8 # Peak wave period
Tm=Tp/1.1 #CHECK!?

cota=2 # Slope angle 1:cota
def get_varangle(cota):
	tana=float(1)/cota # Tan alfa slope
	alfa=np.arctan(tana).Value
	return tana,alfa

[tana,alfa]=get_varangle(cota)

z=10.0 #Local depth

g=9.81 # Gravitational constant
cpl=6.2 # Constant; hard coded?
cs=1.0 # Constant; hard coded?
rhow=1000 # Density water kg/m3
rhos=2650 # Density rock kg/m3
delta=float(rhos)/rhow-1 # Relative density

P=0.4 # Permeability factor
S=2 # Damage factor
stormdur=6 #hours
N=float(stormdur)/Tm*3600 # Number of waves

crestwidth=10 # m
crestheight=0 # m w.r.t MSL
SWL=2 #w.r.t MSL

angleinc=0 # angle of waves to normal

qthres=10.0 # l/s/m Marinas small boats (Rock manual)

gammab=1 # Berm reduction factor (overtopping)
gammaf=1 # Roughness reduction factor (overtopping)

kt=1 # Compression factor for layer thickness

#endregion





def steepness(Hs,Tm):
	"""Calculates wave steepness based on Hs and Tm or Tp"""
	stp=(2 * math.pi*Hs)/(g*Tm**2)
	return stp

stp=steepness(Hs,Tm)

#region Irribarren
def irribarren(stp,tana):
	"""Calculates the irribarren number (ratio wave steepness and slope angle)"""
	
	irri=tana/(stp)**0.5 #Irribarren
	return irri
#endregion

irri=irribarren(stp,tana)

#region van der Meer 
def vanderMeer_stability_rock(Hs,delta,irri,S,N,P,cpl,cs,cota):
	"""Van der Meer stability formulas for rock, checks whether waves are plunging or breaking
	Output is required Dn50 and critical irribarren number"""
	
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
#endregion

[Dn50,irricrit,isPlunging]=vanderMeer_stability_rock(Hs,delta,irri,S,N,P,cpl,cs,cota)

def get_M50(Dn50,rhos):
	"""Get equivalent median Mass of stone (qubic)
	See Rock Manual"""
	
	M50=rhos*Dn50**3
	return M50
	
def get_D50(M50,rhos):
	"""Get cubic equivalent median stone diameter from median mass"""
	
	D50=(M50/rhos)**(1.0/3)
	return D50

#region Grading tables
def get_grading(Dn50):
	"""Get grading (min and max) of stones based on NEN table of Rock Manual(Table 3.5)
	Be aware that table is hard coded!!"""
	
	gradtable=np.array([[5,10,40,60,300,1000,3000,6000],[40,60,200,300,1000,3000,6000,10000]])
	gradtablemn=np.array([0.2,0.24,0.36,0.42,0.65,0.92,1.21,1.46])
	idgrad=np.argmax(Dn50<=gradtablemn).Value
	
	gradmin=gradtable[0,idgrad].Value
	gradmax=gradtable[1,idgrad].Value
	Dn50_grad=gradtablemn[idgrad].Value
	return gradmin,gradmax,Dn50_grad

[gradmin,gradmax,Dn50_grad]=get_grading(Dn50)

print "Armour: Grading "+str(gradmin)+" - "+str(gradmax)+" kg"
#endregion

#region Overtopping TAW
def calcGammabeta(angleinc):
	"""Calculates the correction factor for oblique waves according to TAW (Rock manual)
	Input is angle of incidence to shore normal, so zero means perpendicular to coast"""
	
	if np.abs(angleinc).Value>90:
		raise Exception('ERROR: Angle of incidence cannot be larger than 90 degreest')
		
	gammabeta=np.max([0.8,1-0.0022*np.abs(angleinc).Value]) # Correction factor for oblique waves
	return gammabeta

gammabeta=calcGammabeta(angleinc)

Rc=crestheight-SWL #Crestheight above SWL

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

qovertopping=calcOvertopping_TAW(Hs,Rc,irri,gammab,gammaf,gammabeta,tana,g)
	
def calcGamma_crest(crestwidth,Hs):
	"""Calculates correction for overtopping discharge as a cause of crest width
	Input: 
		crestwidth: Crestwidth (m)
		Hs: Significant wave height (m)
	Output:
		gamma_crest: Correction factor"""
	
	gamma_crest=np.min([1,3.06*np.exp(-1.5*(crestwidth/Hs)).Value]).Value # Correction factor for crest width
	
	return gamma_crest

gamma_crest=calcGamma_crest(crestwidth,Hs)
	
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

qovertopping_crest=calcOvertopping_crest(qovertopping,gamma_crest)

# Calculate minimum required crest height based on threshold q and crest width
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


Rc_required=calcRequired_crestheight(qthres,Hs,irri,gammab,gammaf,gammabeta,gamma_crest,tana,g)
crestheight_required=Rc_required+SWL

print "Required crest elevation = %.2f m with allowable overtopping of %.1f l/s/m" % (crestheight_required,qovertopping_thres)

if crestheight_required>crestheight:
	crestheight=np.ceil(crestheight_required*2).Value/2
	print "Crestheight adjusted to required crest height ( %.1f m)" % crestheight


#endregion

#region M50, filter and layer
M50=get_M50(Dn50,rhos)
M50_grad=get_M50(Dn50_grad,rhos)

def getFilter_rock(M50_grad,rhos):
	"""Get filter rock grading based on filter rule Rock manual (10 times smaller mass)"""
	
	M50_filter=M50_grad/10 # Filter mass 10 times smaller than armour layer (ROCK manual)
	Dn50_filter=get_D50(M50_filter,rhos)
	return M50_filter,Dn50_filter

[M50_filter,Dn50_filter]=getFilter_rock(M50_grad,rhos)

[gradmin_filter,gradmax_filter,Dn50_grad_filter]=get_grading(Dn50_filter)

print "Filter: Grading "+str(gradmin_filter)+" - "+str(gradmax_filter)+" kg"

def getLayerthickness_rock(Dn50,kt):
	"""Get layer thickness based on thumbrule Rockmanual"""
	layerthick=2*kt*Dn50
	return layerthick
	
layer_armour=getLayerthickness_rock(Dn50_grad,kt)
layer_filter=getLayerthickness_rock(Dn50_grad_filter,kt)
#endregion


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

	#region Outer dimensions
	total_height=crestheight+z

	xouter=np.cumsum(np.array([0,cota*float(total_height),crestwidth,cota*float(total_height)]))
	youter=np.array([-z,crestheight,crestheight,-z])

	xyouter=np.vstack((xouter,youter)).T
	#endregion

	#region Armour dimensions
	xarmour_begin=layer_armour/(np.sin(alfa).Value)
	yarmour_top=crestheight-layer_armour
	total_armourheight=yarmour_top+z
	xarmour_2=xarmour_begin+cota*total_armourheight
	xarmour_end=xouter[-1]-xarmour_begin
	xarmour_3=xarmour_end-(cota*total_armourheight)
	xarmour=np.array([xarmour_begin,xarmour_2,xarmour_3,xarmour_end])
	yarmour=np.array([-z,yarmour_top,yarmour_top,-z])

	xyarmour=np.vstack((xarmour,yarmour)).T
	#endregion

	#region Filter dimensions
	xfilter_begin=xarmour_begin+layer_filter/(np.sin(alfa).Value)
	yfilter_top=yarmour_top-layer_filter
	total_filterheight=yfilter_top+z
	xfilter_2=xfilter_begin+(cota*total_filterheight)
	xfilter_end=xouter[-1]-xfilter_begin
	xfilter_3=xfilter_end-(cota*total_filterheight)
	xfilter=np.array([xfilter_begin,xfilter_2,xfilter_3,xfilter_end])
	yfilter=np.array([-z,yfilter_top,yfilter_top,-z])

	xyfilter=np.vstack((xfilter,yfilter)).T
	#endregion
	
	return xouter,youter,xyouter,xarmour,yarmour,xyarmour,xfilter,yfilter,xyfilter,total_height,total_armourheight,total_filterheight

[xouter,youter,xyouter,xarmour,yarmour,xyarmour,xfilter,yfilter,xyfilter,total_height,total_armourheight,total_filterheight]=get_Breakwater_dimensions(crestheight,crestwidth,cota,z,layer_armour,layer_filter)

#region Volumes of layers
def get_Breakwater_areas(xouter,xfilter,xarmour,total_height,total_armourheight,total_filterheight):
	"""Calculates the cross sectional area of breakwater, based on calculated breakwater dimensions"""
	area_outer=xouter[2]*total_height
	area_core=(xfilter[2]-xfilter[0])*total_filterheight
	area_filterandcore=(xarmour[2]-xarmour[0])*total_armourheight

	area_armour=area_outer-area_filterandcore
	area_filter=area_filterandcore-area_core

	#print "Volume armour = %.0f m3/m" % area_armour
	#print "Volume filter = %.0f m3/m" % area_filter
	#print "Volume core = %.0f m3/m" % area_core
	return area_outer,area_armour,area_filter,area_core

[area_outer,area_armour,area_filter,area_core]=get_Breakwater_areas(xouter,xfilter,xarmour,total_height,total_armourheight,total_filterheight)


#endregion

#region Plotting
lineouter=CreateLineSeries(xyouter)
lineouter.Color = Color.Black
lineouter.Width = 3
lineouter.PointerVisible = False
lineouter.Transparency = 0
lineouter.Title="Crestheight: %.1f m+MSL Crestwidth: %.1f m " % (crestheight,crestwidth)


linearmour=CreateLineSeries(xyarmour)
linearmour.Color = Color.Black
linearmour.Width = 2
linearmour.PointerVisible = False
linearmour.Transparency = 0
linearmour.Title="Armour: Grading "+str(gradmin)+" - "+str(gradmax)+" kg"


linefilter=CreateLineSeries(xyfilter)
linefilter.Color = Color.Black
linefilter.Width = 1
linefilter.PointerVisible = False
linefilter.Transparency = 0
linefilter.Title = "Filter: Grading "+str(gradmin_filter)+" - "+str(gradmax_filter)+" kg"

xyMSL=np.vstack((xouter,[0,0,0,0])).T
lineMSL=CreateLineSeries(xyMSL)
lineMSL.Color = Color.Blue
lineMSL.Width = 1.5
lineMSL.PointerVisible = False
lineMSL.Transparency = 0
lineMSL.Title="MSL"

xySWL=np.vstack((xouter,[SWL,SWL,SWL,SWL])).T
lineSWL=CreateLineSeries(xySWL)
lineSWL.Color = Color.BlueViolet
lineSWL.Width = 1.5
lineSWL.PointerVisible = False
lineSWL.Transparency = 0
lineSWL.Title="SWL"

chart = CreateChart([lineouter,linearmour,linefilter,lineMSL,lineSWL])
chart.LeftAxis.Automatic = False
chart.LeftAxis.Minimum = -z
chart.LeftAxis.Maximum = crestheight+2
chart.LeftAxis.Title = "level w.r.t. MSL (m)"
chart.BottomAxis.Title = "Distance (m)"
chart.BackGroundColor = Color.White
chart.Legend.Visible=True
chart.Legend.Alignment=LegendAlignment.Right
chart.Title="Breakwater layout Hs = %.1f m, Tp = %.1f s \n Slope = 1:%d, Dn50 = %.2f m, M50 = %.0f kg" % (Hs,Tp,cota,Dn50_grad,M50_grad)
chart.TitleVisible=True
chart.Name="Breakwater design"

"""for view in Gui.DocumentViews:
	if (view.Text == chart.Name):
		viewToRemove = view
		break
print "Remove" + viewToRemove.Text
Gui.DocumentViews.Remove(viewToRemove)
"""
OpenView(chart)
#endregion

