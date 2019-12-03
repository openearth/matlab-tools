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
import scipy as scipy
from Libraries.StandardFunctions import *
from Libraries.ChartFunctions import *
from Libraries.MapFunctions import *

from SharpMap.Editors.Interactors import Feature2DEditor
from SharpMap.UI.Tools import NewLineTool
import Scripts.LinearWaveTheory as lw

from Scripts.BreakwaterDesign.Engine_functions import *
#from Scripts.BreakwaterDesign.Input_dialog import *
from System import *
from System.Windows.Forms import MessageBox,BorderStyle,TableLayoutPanel, TableLayoutPanelGrowStyle, RowStyle,ColumnStyle, SizeType
from Scripts.UI_Examples.View import *
import clr
clr.AddReference("System.Windows.Forms")


def ENGINE(ip):
	
	class outputparam_BW():
		def __init__(self):
			self.Tm = []
			self.stp = []
			self.irri = []
			self.delta = []
			self.N = []
			self.Dn50 = {}
			self.irricrit = []
			self.isPlunging = []
			self.grad = {}
			self.isTooLarge = {}
			self.gammabeta = []
			self.gamma_crest = []
			self.Rc_required = []
			self.crestheight_required = []
			self.Rc = []
			self.qovertopping = []
			self.qovertopping_crest = []
			self.M50 = {}
			self.layer = {}
			self.alignment = {}
			self.volumes = {}
			self.totalvolumes = {}
			self.y_layer = {}
			
	
	op = outputparam_BW()
	
	# Check if 2D, and fill in local depth
	if ip.is2D:
		# Check if all depths are positive
		if np.all(ip.profile['z'] < 0):
			ip.IsNegative = True
		# If not all depths are negative then replace z value for first value of profile
		if not ip.IsNegative:
			ip.z = np.max(ip.profile['z']).Value 
	
	
	# Check for Offshore or Nearshore values
	if ip.isOffshore:
		[HsN, TpN, thetaN]=lw.transWaveConditions(float(ip.Hs0), float(ip.Tp0), float(ip.theta0), [float(ip.z0),float(ip.z)], float(ip.gammabreak))
		ip.Hs = float(HsN)
		ip.Tp = float(TpN)
		ip.theta = float(thetaN)
	else:
		ip.Hs = float(ip.Hs0)
		ip.Tp = float(ip.Tp0)
		ip.theta = float(ip.theta0)
	
	
	#region Pre calculation of additional input variables
	[tana,alfa]=get_varangle(ip.cota) 			# Variations of slope angle
	op.Tm=calcMeanWavePeriod(ip.Tp) 				# Mean wave period
	op.stp=steepness(ip.Hs,op.Tm,ip.g) 				# Wave steepness  
	op.irri=irribarren(op.stp,tana) 					# Irribarren number
	op.delta=calcRelativedensity(ip.rhos,ip.rhow) 	# Relative density
	op.N=calcNumberofWaves(ip.stormdur,op.Tm) 		# Number of waves
	#ip.qthres = get_Qthres(ip,Critical_type) 	# Get qthreshold
	
	#endregion
	
	# Calculate Dn50 for Rock
	[op.Dn50['armour'],op.irricrit,op.isPlunging]=vanderMeer_stability_rock(ip.Hs,op.delta,op.irri,ip.S,op.N,ip.P,ip.cpl,ip.cs,ip.cota)
	
	# Get grading from table
	[op.grad['min_armour'],op.grad['max_armour'],op.Dn50['armour_grad'],op.isTooLarge['armour']]=get_grading(op.Dn50['armour'])
	
	# Correction for oblique waves
	op.gammabeta=calcGammabeta(ip.angleinc)
	
	# Calculate overtopping
	op.gamma_crest=calcGamma_crest(ip.crestwidth,ip.Hs) # Correction for crestwidth
	
	if ip.autocrest: # If user want to auto determine required crest height
		op.Rc_required=calcRequired_crestheight(ip.qthres,ip.Hs,op.irri,ip.gammab,ip.gammaf,op.gammabeta,op.gamma_crest,tana,ip.g)
		op.crestheight_required=np.max([op.Rc_required,0])+ip.SWL
		#print "Required crest elevation = %.2f m with allowable overtopping of %.1f l/s/m" % (crestheight_required,ip.qthres)
		if op.crestheight_required>ip.crestheight:
			ip.crestheight=np.ceil(op.crestheight_required*4).Value/4
		
		#print "Crestheight adjusted to required crest height ( %.1f m)" % ip.crestheight
	
	op.Rc=float(ip.crestheight)-float(ip.SWL) # Crestheight above SWL
	
	op.qovertopping=calcOvertopping_TAW(ip.Hs,op.Rc,op.irri,ip.gammab,ip.gammaf,op.gammabeta,tana,ip.g)
	op.qovertopping_crest=calcOvertopping_crest(op.qovertopping,op.gamma_crest)
	
	# Get M50 armour
	op.M50['armour']=get_M50(op.Dn50['armour'],ip.rhos)
	# get grading M50
	op.M50['armour_grad']=get_M50(op.Dn50['armour_grad'],ip.rhos)
	
	# Get filter	
	[op.M50['filter'],op.Dn50['filter']]=getFilter_rock(op.M50['armour_grad'],ip.rhos)
	
	[op.grad['min_filter'],op.grad['max_filter'],op.Dn50['filter_grad'],op.isTooLarge['filter']]=get_grading(op.Dn50['filter'])
	
	#print "Filter: Grading "+str(gradmin_filter)+" - "+str(gradmax_filter)+" kg"
	
	op.layer['armour']=getLayerthickness_rock(op.Dn50['armour_grad'],ip.kt)
	op.layer['filter']=getLayerthickness_rock(op.Dn50['filter_grad'],ip.kt)
	
	return ip,op


def get_AllDims(ip,op):
	
	if ip.is2D:
		
		if not ip.IsNegative:
			# Delete all values with negative depth
			ip.profile['dist_pl'] = ip.profile['dist'] # 'orginal' profile for plotting
			ip.profile['dist'] = ip.profile['dist'][(ip.profile['z']+ip.crestheight)>(op.layer['armour']+op.layer['filter'])]
			ip.profile['dist_pl2'] = ip.profile['dist'] # 'wet' profile with original distance axis, for plotting
			ip.profile['dist'] = ip.profile['dist']-np.min(ip.profile['dist']) # 'wet' profile starting from waterline
			ip.profile['z_pl'] = ip.profile['z']
			ip.profile['z'] = ip.profile['z'][(ip.profile['z']+ip.crestheight)>(op.layer['armour']+op.layer['filter'])]
			
			# Get profile spacing and mean at 'centre' points
			ip.profile = get_profile_mean(ip.profile)
			
			for ii in range(len(ip.profile['mean_z'])):
				op.alignment[ii] = {}
				op.alignment[ii]['dims']=get_Breakwater_dimensions(ip.crestheight,ip.crestwidth,ip.cota,ip.profile['mean_z'][ii],op.layer['armour'],op.layer['filter'])
				op.alignment[ii]['area']=get_Breakwater_areas(op.alignment[ii]['dims'])
				op.alignment[ii]['depth']=ip.profile['mean_z'][ii]
				op.alignment[ii]['ds'] = ip.profile['ds'][ii]
				op.alignment[ii]['volume'] = get_Breakwater_volumes(op.alignment[ii]['area'],ip.profile['ds'][ii])
				
				for k,v in op.alignment[ii]['volume'].items():
					op.volumes[k] = np.zeros(len(ip.profile['mean_z']))
				for k,v in op.alignment[ii]['volume'].items():
					op.volumes[k][ii] = v
					
			
			for k,v in op.volumes.items():
				op.totalvolumes[k] = np.sum(v)
			
	else: 
		ip.cross_ind = 0
		op.alignment[0] = {}
		op.alignment[0]['dims']=get_Breakwater_dimensions(ip.crestheight,ip.crestwidth,ip.cota,ip.z,op.layer['armour'],op.layer['filter'])
		op.alignment[0]['area']=get_Breakwater_areas(op.alignment[0]['dims'])
		op.alignment[0]['depth']=ip.z
		op.alignment[0]['ds'] = 1.0
		op.alignment[0]['volume'] = get_Breakwater_volumes(op.alignment[0]['area'],op.alignment[0]['ds'])
		
		for k,v in op.alignment[0]['volume'].items():
			op.volumes[k] = v
		for k,v in op.volumes.items():
			op.totalvolumes[k] = v
		
	return ip,op
#endregion




	
	


