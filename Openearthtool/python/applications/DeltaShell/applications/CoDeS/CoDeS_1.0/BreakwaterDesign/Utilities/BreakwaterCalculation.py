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
import Scripts.BreakwaterDesign.Entities.BreakwaterOutput as _BreakwaterOutput
from Scripts.LinearWaveTheory.Utilities import applyLinWaveTheory as lw
from Scripts.BreakwaterDesign.Utilities.EngineFunctionsBreakwater import *
import numpy as np


def CalculateBreakwater(ip):
	
	op = _BreakwaterOutput()
	
	op.cross_ind = ip.cross_ind
	
	# Check if 2D, and fill in local depth
	if ip.is2D:
		# Check if all depths are positive
		if np.all(ip.profile['z'] < 0):
			ip.IsNegative = True
		# If not all depths are negative then replace z value for first value of profile
		if not ip.IsNegative:
			op.z = np.max(ip.profile['z']).Value
	else:
		op.z = ip.z
		op.cross_ind = 0
	
	
	# Check for Offshore or Nearshore values
	if ip.isOffshore:
		[HsN, TpN, thetaN]=lw.transWaveConditions(float(ip.Hs0), float(ip.Tp0), float(ip.theta0), [float(ip.z0),float(ip.z)], float(ip.gammabreak))
		op.Hs = float(HsN)
		op.Tp = float(TpN)
		op.theta = float(thetaN)
	else:
		op.Hs = float(ip.Hs0)
		op.Tp = float(ip.Tp0)
		op.theta = float(ip.theta0)
	
	
	#region Pre calculation of additional input variables
	[tana,alfa]=get_varangle(ip.cota) 			# Variations of slope angle
	op.Tm=calcMeanWavePeriod(op.Tp) 				# Mean wave period
	op.stp=steepness(op.Hs,op.Tm,ip.g) 				# Wave steepness  
	op.irri=irribarren(op.stp,tana) 					# Irribarren number
	op.delta=calcRelativedensity(ip.rhos,ip.rhow) 	# Relative density
	op.N=calcNumberofWaves(ip.stormdur,op.Tm) 		# Number of waves
	#ip.qthres = get_Qthres(ip,Critical_type) 	# Get qthreshold
	
	#endregion
	
	# Calculate Dn50 for Rock
	[op.Dn50['armour'],op.irricrit,op.isPlunging]=vanderMeer_stability_rock(op.Hs,op.delta,op.irri,ip.S,op.N,ip.P,ip.cpl,ip.cs,ip.cota)
	
	# Get grading from table
	[op.grad['min_armour'],op.grad['max_armour'],op.Dn50['armour_grad'],op.isTooLarge['armour']]=get_grading(op.Dn50['armour'])
	
	# Correction for oblique waves
	op.gammabeta=calcGammabeta(ip.angleinc)
	
	# Calculate overtopping
	op.gamma_crest=calcGamma_crest(ip.crestwidth,op.Hs) # Correction for crestwidth
	op.crestheight = ip.crestheight
	
	if ip.autocrest: # If user want to auto determine required crest height
		op.Rc_required=calcRequired_crestheight(ip.qthres,op.Hs,op.irri,ip.gammab,ip.gammaf,op.gammabeta,op.gamma_crest,tana,ip.g)
		op.crestheight_required=np.max([op.Rc_required,0.10])+ip.SWL
		#print "Required crest elevation = %.2f m with allowable overtopping of %.1f l/s/m" % (crestheight_required,ip.qthres)
		if op.crestheight_required>op.crestheight:
			op.crestheight=np.ceil(op.crestheight_required*4).Value/4
		
			
		
		#print "Crestheight adjusted to required crest height ( %.1f m)" % ip.crestheight
	
	op.Rc=float(op.crestheight)-float(ip.SWL) # Crestheight above SWL
	
	op.qovertopping=calcOvertopping_TAW(op.Hs,op.Rc,op.irri,ip.gammab,ip.gammaf,op.gammabeta,tana,ip.g)
	op.qovertopping_crest=calcOvertopping_crest(op.qovertopping,op.gamma_crest)
	
	# Get M50 armour
	op.M50['armour']=get_M50(op.Dn50['armour'],ip.rhos)
	# get grading M50
	op.M50['armour_grad']=get_M50(op.Dn50['armour_grad'],ip.rhos)
	
	# Get filter	
	[op.M50['filter'],op.Dn50['filter']]=getFilter_rock(op.M50['armour_grad'],ip.rhos)
	
	[op.grad['min_filter'],op.grad['max_filter'],op.Dn50['filter_grad'],op.isTooLarge['filter']]=get_grading(op.Dn50['filter'])
	
	op.layer['armour']=getLayerthickness_rock(op.Dn50['armour_grad'],ip.kt)
	op.layer['filter']=getLayerthickness_rock(op.Dn50['filter_grad'],ip.kt)
	
	# Calculate Dimensions:
	
	if ip.is2D:
		
		if not ip.IsNegative:
			op.profile = ip.profile
			# Delete all values with negative depth
			op.profile['dist_pl'] = op.profile['dist'] # 'orginal' profile for plotting
			op.profile['dist'] = op.profile['dist'][(op.profile['z']+op.crestheight)>(op.layer['armour']+op.layer['filter'])]
			op.profile['dist_pl2'] = op.profile['dist'] # 'wet' profile with original distance axis, for plotting
			op.profile['dist'] = op.profile['dist']-np.min(op.profile['dist']) # 'wet' profile starting from waterline
			op.profile['z_pl'] = op.profile['z']
			op.profile['z'] = op.profile['z'][(op.profile['z']+op.crestheight)>(op.layer['armour']+op.layer['filter'])]
			
			
			# Get profile spacing and mean at 'centre' points
			op.profile = get_profile_mean(op.profile)
			
			for ii in range(len(op.profile['mean_z'])):
				op.alignment[ii] = {}
				op.alignment[ii]['dims']=get_Breakwater_dimensions(op.crestheight,ip.crestwidth,ip.cota,op.profile['mean_z'][ii],op.layer['armour'],op.layer['filter'])
				op.alignment[ii]['area']=get_Breakwater_areas(op.alignment[ii]['dims'])
				op.alignment[ii]['depth']=op.profile['mean_z'][ii]
				op.alignment[ii]['ds'] = op.profile['ds'][ii]
				op.alignment[ii]['volume'] = get_Breakwater_volumes(op.alignment[ii]['area'],op.profile['ds'][ii])
				
			for k,v in op.alignment[0]['volume'].items():
				op.volumes[k] = np.zeros(len(op.profile['mean_z']))
				op.costs[k] = np.zeros(len(op.profile['mean_z']))
				op.costs_perm[k] = np.zeros(len(op.profile['mean_z']))
			
			for ii in range(len(op.profile['mean_z'])):
				for k,v in op.alignment[ii]['volume'].items():
					op.volumes[k][ii] = v
				
				op.costs['armour'][ii] = op.volumes['armour'][ii] * ip.unitCostArmour
				op.costs['filter'][ii] = op.volumes['filter'][ii] * ip.unitCostFilter
				op.costs['core'][ii] = op.volumes['core'][ii] * ip.unitCostCore
				op.costs['outer'][ii] = op.costs['armour'][ii] + op.costs['filter'][ii] + op.costs['core'][ii]
				
				op.costs_perm['armour'][ii] = op.alignment[ii]['area']['armour'] * ip.unitCostArmour
				op.costs_perm['filter'][ii] = op.alignment[ii]['area']['filter'] * ip.unitCostFilter
				op.costs_perm['core'][ii] = op.alignment[ii]['area']['core'] * ip.unitCostCore
				op.costs_perm['outer'][ii] =  op.costs_perm['armour'][ii] + op.costs_perm['filter'][ii] + op.costs_perm['core'][ii]
			
			for k,v in op.volumes.items():
				op.totalvolumes[k] = np.sum(v)
			
			for k,v in op.costs.items():
				op.totalcosts[k] = np.sum(v)
	else: 
		op.cross_ind = 0
		op.alignment[0] = {}
		op.alignment[0]['dims']=get_Breakwater_dimensions(op.crestheight,ip.crestwidth,ip.cota,ip.z,op.layer['armour'],op.layer['filter'])
		op.alignment[0]['area']=get_Breakwater_areas(op.alignment[0]['dims'])
		op.alignment[0]['depth']=ip.z
		op.alignment[0]['ds'] = 1.0
		op.alignment[0]['volume'] = get_Breakwater_volumes(op.alignment[0]['area'],op.alignment[0]['ds'])
		
		for k,v in op.alignment[0]['volume'].items():
			op.volumes[k] = v
			op.costs[k] = float(0)
			op.costs_perm[k] = float(0)
			
		op.costs['armour'] = op.volumes['armour'] * ip.unitCostArmour
		op.costs['filter'] = op.volumes['filter'] * ip.unitCostFilter
		op.costs['core'] = op.volumes['core'] * ip.unitCostCore
		op.costs['outer'] = op.costs['armour'] + op.costs['filter'] + op.costs['core']
		
		op.costs_perm['armour'] = op.alignment[0]['area']['armour'] * ip.unitCostArmour
		op.costs_perm['filter'] = op.alignment[0]['area']['filter'] * ip.unitCostFilter
		op.costs_perm['core'] = op.alignment[0]['area']['core'] * ip.unitCostCore
		op.costs_perm['outer'] =  op.costs_perm['armour'] + op.costs_perm['filter'] + op.costs_perm['core']
		
		
		for k,v in op.volumes.items():
			op.totalvolumes[k] = v
		
		for k,v in op.costs.items():
			op.totalcosts[k] = v
		
	return op