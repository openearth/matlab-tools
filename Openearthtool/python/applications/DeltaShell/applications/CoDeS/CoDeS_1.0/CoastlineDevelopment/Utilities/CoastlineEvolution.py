#   Copyright notice
#   --------------------------------------------------------------------
#   Copyright (C) 2017 Witteveen+Bos
#
#       Aline Kaji
#
#       aline.kaji@witteveenbos.com
#
#       Van Twickelostraat 2
#       7411 SC Deventer
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
import os
import clr
clr.AddReference("System.Windows.Forms")

import System.Drawing as _drawing
import System.Windows.Forms as _swf

import numpy as np
import time
from Scripts.GeneralData.Utilities.Interpolation import Interp as _interp
from Scripts.CoastlineDevelopment.Entities.CoastlineInput import *
from Scripts.CoastlineDevelopment.Entities.CoastlineOutput import *
import Scripts.LinearWaveTheory as lwt

from Scripts.CoastlineDevelopment.Utilities.bsplines import cspline1d as _cspline1d
from Scripts.CoastlineDevelopment.Utilities.bsplines import cspline1d_eval as _cspline1d_eval

#InputValues = InputData()
#OutputValues = OutputData()

def resample_coastline(x0,y0,npoints):
	""" Resamples coastline based on the required number of segments """

	# Check if coastline has more than 2 points
	s0 = np.cumsum(np.sqrt((x0[1:]-x0[0:-1])**2 + (y0[1:]-y0[0:-1])**2))
	s0 = np.append([0],s0)
	
	# Calculate new space vector
	s = np.linspace(0,s0[-1],npoints+1)
	
	# Calculate dx
	dx = s[1]-s[0]
	
	# Get new coordinates for grid corners (where transport is calculated)
	xcor = _interp(s,s0,x0)
	ycor = _interp(s,s0,y0)
	
	# Get coordinates of cell centers (where moving shoreline is computed)
	xcen = np.mean(np.vstack([xcor[0:-1],xcor[1:]]),axis=0)
	ycen = np.mean(np.vstack([ycor[0:-1],ycor[1:]]),axis=0) 
	
	return xcor, ycor, xcen, ycen, dx
	
def coastline_orientation(xcen, ycen):
	""" Get coastline orientation per segment (at grid corners)"""
	
	x_diff = xcen[1:] - xcen[0:-1]
	y_diff = ycen[1:] - ycen[0:-1]
	
	# Add orientation at the boundaries (which cannot be calculated using the above)
	x_diff = np.hstack((x_diff[0],x_diff,x_diff[-1])) 
	y_diff = np.hstack((y_diff[0],y_diff,y_diff[-1]))
	
	# Calculate coastline angle
	coastline_angle = np.arctan2(x_diff,y_diff)/np.pi*180
	
	# Correct for negative angles
	coastline_angle[coastline_angle < 0] = coastline_angle[coastline_angle < 0] + 360

	# Calculate shore normal
	shoreNormal = coastline_angle - 90
	shoreNormal[shoreNormal < 0] = shoreNormal[shoreNormal < 0] + 360
	
	return coastline_angle, shoreNormal

def coastline_orientation_centers(xcor, ycor):
	""" Get coastline orientation per segment in radians (at grid centers)"""
	
	x_diff = xcor[1:] - xcor[0:-1]
	y_diff = ycor[1:] - ycor[0:-1]
	
	# Calculate coastline angle
	coastline_angle = np.arctan2(x_diff,y_diff)/np.pi*180
	
	#wavesFile.write("Coastline Angle Rad: "+ str(coastline_angle) + "\n")
	
	# Correct for negative angles
	coastline_angle[coastline_angle < 0] = coastline_angle[coastline_angle < 0] + 360

	# Calculate shore normal
	shoreNormal = coastline_angle - 90
	shoreNormal[shoreNormal < 0] = shoreNormal[shoreNormal < 0] + 360
	shoreNormalRad = shoreNormal*np.pi/180;
	
	#wavesFile.write("shoreNormal: "+ str(shoreNormal) + "\n")
	
	return shoreNormalRad
	
def get_wave_classes(InputValues):
	
	WaveClimates = InputValues.Waves.WaveClimates
	
	H_s   = np.array([])
	T_p   = np.array([])
	dir   = np.array([])
	occ   = np.array([])
	names = np.array([])
	
	for waveClimate in WaveClimates:
		
		H_s = np.append(H_s,waveClimate.Hs)
		T_p = np.append(T_p,waveClimate.Tp)
		dir = np.append(dir,waveClimate.Dir)
		occ = np.append(occ,waveClimate.Occurences)
	
	H_s = H_s.reshape(H_s.shape[0],1)
	T_p = T_p.reshape(T_p.shape[0],1)
	dir = dir.reshape(dir.shape[0],1)
	occ = occ.reshape(occ.shape[0],1)
	
	# Normalize occurrences
	if np.sum(occ) < 0.999  or np.sum(occ) > 1.001:
		occ = occ/np.sum(occ)
		InputValues.normalize = True
		_swf.MessageBox.Show("Occurrence of wave conditions are normalized")
	
	return H_s,T_p,dir,occ

def translate_waves(H_s,T_p,dir,shoreNormal,translate_waves_data,gamma):

	relDir0 = np.empty([0,len(dir)])
	Hs_near = np.empty([0,len(dir)])
	Tp_near = np.empty([0,len(dir)])
	relDirnear = np.empty([0,len(dir)])
	
	for ang in shoreNormal:
		# Calculate relative angle of incidence
		reldir, _ = lwt.calcRelativeDirection(dir, ang)
		relDir0 = np.vstack(([relDir0,reldir]))
		
		Hs_new,Tp_new,relDirnew = lwt.transWaveConditions(H_s,T_p,reldir,np.array([translate_waves_data['offshore_depth'],translate_waves_data['nearshore_depth']]),gamma)
		Hs_near = np.vstack(([Hs_near,Hs_new]))
		Tp_near = np.vstack(([Tp_near,Tp_new]))
		relDirnear = np.vstack(([relDirnear,relDirnew]))
		
	return Hs_near, Tp_near, relDirnear

def add_structure_boundary(xcor,ycor,breakwaters):
	""" check location of the breakwater and include additional boundary conditions """
	
	ind = []
	
	# check dx
	s = np.cumsum(np.sqrt((xcor[1:]-xcor[0:-1])**2 + (ycor[1:]-ycor[0:-1])**2))
	dx = s[1]-s[0]
	
	for bw in breakwaters:
		
		# convert to numpy array
		bw = np.array(bw)
		
		xb0 = bw[0,0] # point at the coastline
		yb0 = bw[0,1]
		
		xb1 = bw[-1,0] # offshore point of the breakwater
		yb1 = bw[-1,1]
	
		# find grid point closest to breakwater location 
		C = np.sqrt((xb0 - xcor)**2 + (yb0 - ycor)**2)
		#if np.min(C) < dx:
		ind.append(np.argmin(C))
		
		# check length of breakwater to ignore points between two breakwaters that are too close together
		bw_len = np.sqrt((xb0 - xb1)**2 + (yb0 - yb1)**2)
	
	return ind
	
def calculate_coastline_position(InputValues,S,xcen,ycen,xcor,ycor,ind,dt):
	
	S2 = S['net volume transport [m3/yr.]']*dt
	
	# Apply structures
	if ind:
		S2[ind] = 0
	
	# Apply boundary conditions [left boundary]
	if InputValues.leftbnd == 0: # Q = 0 (No sediment transport gradient)
		S2[0] = S2[1]
	elif InputValues.leftbnd == 1: # S = 0 (No sediment transport)
		S2[0] = 0
	elif InputValues.leftbnd == 2: #
		S2[0] = 0
		 
	# Apply boundary conditions [right boundary]
	if InputValues.rightbnd == 0: # Q = 0 (No sediment transport gradient)
		S2[-1] = S2[-2]
	elif InputValues.rightbnd == 1: # S = 0 (No sediment transport)
		S2[-1] = 0
	elif InputValues.rightbnd == 2: #
		S2[-1] = 0
		
	# Calculate sediment transport gradient
	Q = S2[0:-1] - S2[1:]
	
	# Calculate coastline changes
	ds = np.sqrt((xcor[1:]-xcor[0:-1])**2 + (ycor[1:]-ycor[0:-1])**2) # alongshore cell size
	#wavesFile.write("Ds: " + str(ds) + "\n")
	
	retreat = Q/(InputValues.active_height*ds)
	
	# Calculate the new point along shore normal
	shoreNormalRad = coastline_orientation_centers(xcor, ycor)
	#wavesFile.write("Retreat: " + str(retreat) + "\n")


	ux = - retreat * np.sin(shoreNormalRad)
	uy = - retreat * np.cos(shoreNormalRad)
	
	#wavesFile.write("ux: " + str(ux) + "\n")
	#wavesFile.write("uy: " + str(uy) + "\n")
	
	# Update xcen and ycen
	xcen = xcen + ux
	ycen = ycen + uy
	
	# Update xcor and ycor
	xcor0 = xcor
	ycor0 = ycor
	
	xnew = np.arange(0.5,len(xcen)-0.5,1)
	
	cjx = _cspline1d(np.array(xcen),0.1)
	xcor = _cspline1d_eval(cjx,xnew)
	cjy = _cspline1d(np.array(ycen),0.1)
	ycor = _cspline1d_eval(cjy,xnew)
	
	# Add retreat of boundaries
	xbnd1 = xcor0[0] + ux[0]
	ybnd1 = ycor0[0] + uy[0]
	
	xcor = np.append(xbnd1,xcor)
	ycor = np.append(ybnd1,ycor)
	
	xbnd2 = xcor0[-1] + ux[-1]
	ybnd2 = ycor0[-1] + uy[-1]
	
	xcor = np.append(xcor,xbnd2)
	ycor = np.append(ycor,ybnd2)
	
	#xlist = xcor.tolist()
	#xCenList = xcen.tolist()
	
	#for xvalue in xlist:
	#	wavesFile.write("Xcorner: " + str(xvalue) + "\n")
	
	#for xvalue in xCenList:
	#	wavesFile.write("Xcenter: " + str(xvalue) + "\n")
	
 
	return xcen, ycen, xcor, ycor

def CERC(H_s,T_p,occ,ang,InputValues):
	""" Calculates sediment transport according to CERC formula
	
	Input:
	H_s		 - significant wave height nearshore(as numpy array) [m]
	T_p		 - peak wave period nearshore (as numpy array) [s]
	occ		 - occurrence of each wave condition
	ang		 - relative wave angle to coastline [deg]
	InputValues
	
	"""
	
	d50			= InputValues.d50
	beach_slope = InputValues.beach_slope
	rho_s		 = InputValues.rho_s
	rho_w		 = InputValues.rho_w
	porosity	 = InputValues.porosity		
	gamma		 = InputValues.gamma
	
	K	 = 0.77 # [-] Coefficient, Komar and Inman (1970) found 0.77, US Army corps of engineers uses 0.92 and Schoones and Theron (1993, 1996).
				 #	 suggested a value much lower (about half). The shore protection manual (USACE, 1984) recommends a value of 0.39.
	# Variable from input: gamma = 0.70 # [-] Breaker coefficient
	n_br  = 1.00 # [-] n-coefficient at breaker line (approx. 1)
	g	 = 9.81 # [m/s^2] gravitational acceleration
	c_br  = np.sqrt(g * (H_s / K )) # [m/s] wave celerity at the breaker line
	
	S =  (np.abs(ang) < 90) * ((K * (1.0/8.0) * rho_w * g * H_s**2.0 * n_br * c_br * np.abs(np.sin(2.0 * np.radians(np.abs(ang))))) / ((1.0-porosity) * (rho_s-rho_w) * g))
	S[np.isnan(S)] = 0
	
	CERC_data = {}
	
	CERC_data['volume transport per set [m3/s]']		 = S * ang/np.abs(ang)
	CERC_data['mass transport per set [kg/s]']		   = (1-porosity) * rho_s * CERC_data['volume transport per set [m3/s]']
	
	CERC_data['weighted volume transport [m3/s]']		= (CERC_data['volume transport per set [m3/s]'] * occ)
	CERC_data['weighted mass transport [kg/s]']		  = (CERC_data['mass transport per set [kg/s]'] * occ)
	
	CERC_data['gross positive mass transport [kg/s]']	= np.sum(np.clip(CERC_data['weighted mass transport [kg/s]'],0.0,np.inf),0.0)
	CERC_data['gross negative mass transport [kg/s]']	 = np.sum(np.clip(CERC_data['weighted mass transport [kg/s]'],-np.inf,0.0),0.0)
	CERC_data['net mass transport [kg/s]']			   = CERC_data['gross positive mass transport [kg/s]'] + CERC_data['gross negative mass transport [kg/s]']
	
	CERC_data['gross positive volume transport [m3/s]']  = np.sum(np.clip(CERC_data['weighted volume transport [m3/s]'],0.0,np.inf),0.0)
	CERC_data['gross negative volume transport [m3/s]']  = np.sum(np.clip(CERC_data['weighted volume transport [m3/s]'],-np.inf,0.0),0.0)
	CERC_data['net volume transport [m3/s]']			 = CERC_data['gross positive volume transport [m3/s]'] + CERC_data['gross negative volume transport [m3/s]']
	
	CERC_data['gross positive mass transport [kg/yr.]']   = CERC_data['gross positive mass transport [kg/s]']   * 60.0 * 60.0 * 24.0 * 365.0
	CERC_data['gross negative mass transport [kg/yr.]']   = CERC_data['gross negative mass transport [kg/s]']   * 60.0 * 60.0 * 24.0 * 365.0
	
	CERC_data['gross positive volume transport [m3/yr.]'] = CERC_data['gross positive volume transport [m3/s]'] * 60.0 * 60.0 * 24.0 * 365.0
	CERC_data['gross negative volume transport [m3/yr.]'] = CERC_data['gross negative volume transport [m3/s]'] * 60.0 * 60.0 * 24.0 * 365.0
	
	CERC_data['net mass transport [kg/yr.]']			 = CERC_data['net mass transport [kg/s]']   * 60.0 * 60.0 * 24.0 * 365.0
	CERC_data['net volume transport [m3/yr.]']		   = CERC_data['net volume transport [m3/s]'] * 60.0 * 60.0 * 24.0 * 365.0
		
	CERC_data['function name']						   = 'CERC'
	
	return CERC_data
	
def Kamphuis(H_s,T_p,occ,ang,InputValues):
	""" Calculates sediment transport according to Kamphuis (1991) 
	see http://www.leovanrijn-sediment.com/papers/Longshoretransport2013.pdf
	
	Input:
	H_s		 - significant wave height nearshore(as numpy array) [m]
	T_p		 - peak wave period nearshore (as numpy array) [s]
	occ		 - occurrence of each wave condition
	ang		 - relative wave angle to coastline [deg]
	InputValues
	
	"""
	
	d50			= InputValues.d50
	beach_slope = InputValues.beach_slope
	rho_s		 = InputValues.rho_s
	rho_w		 = InputValues.rho_w
	porosity	 = InputValues.porosity		
	gamma		 = InputValues.gamma
	
	S =  2.33 * H_s**2.0 * T_p**1.5 * beach_slope**0.75 * d50**-0.25 * (np.abs(np.sin(2.0 * np.radians(ang)))**0.6)
	S[np.isnan(S)] = 0
	
	kamphuis_data = {}
	
	# Add transport direction
	S_Direction = S * ang/np.abs(ang)
	S_Direction[np.isnan(S_Direction)] = 0
	
	# see http://www.leovanrijn-sediment.com/papers/Longshoretransport2013.pdf
	kamphuis_data['mass transport per set [kg/s]']		   = S_Direction # transport rate of immersed mass per unit time [kg(immersed)/s]
	
	kamphuis_data['weighted mass transport [kg/s]']		  = (kamphuis_data['mass transport per set [kg/s]'] * occ)
	
	kamphuis_data['volume transport per set [m3/s]']		 = kamphuis_data['mass transport per set [kg/s]'] / ((rho_s - rho_w) * (1.0 - porosity))
	kamphuis_data['weighted volume transport [m3/s]']		= (kamphuis_data['volume transport per set [m3/s]'] * occ)
	
	kamphuis_data['gross positive mass transport [kg/s]']	= np.sum(np.clip(kamphuis_data['weighted mass transport [kg/s]'],0.0,np.inf),0.0)
	kamphuis_data['gross negative mass transport [kg/s]']	= np.sum(np.clip(kamphuis_data['weighted mass transport [kg/s]'],-np.inf,0.0),0.0)
	kamphuis_data['net mass transport [kg/s]']			   = kamphuis_data['gross positive mass transport [kg/s]'] + kamphuis_data['gross negative mass transport [kg/s]'] 
	
	kamphuis_data['gross positive volume transport [m3/s]']  = np.sum(np.clip(kamphuis_data['weighted volume transport [m3/s]'],0.0,np.inf),0.0)
	kamphuis_data['gross negative volume transport [m3/s]']  = np.sum(np.clip(kamphuis_data['weighted volume transport [m3/s]'],-np.inf,0.0),0.0)
	kamphuis_data['net volume transport [m3/s]']			 = kamphuis_data['gross positive volume transport [m3/s]']  + kamphuis_data['gross negative volume transport [m3/s]']
	
	kamphuis_data['gross positive mass transport [kg/yr.]']   = kamphuis_data['gross positive mass transport [kg/s]']   * 60.0 * 60.0 * 24.0 * 365.0
	kamphuis_data['gross negative mass transport [kg/yr.]']   = kamphuis_data['gross negative mass transport [kg/s]']   * 60.0 * 60.0 * 24.0 * 365.0
	
	kamphuis_data['gross positive volume transport [m3/yr.]'] = kamphuis_data['gross positive volume transport [m3/s]'] * 60.0 * 60.0 * 24.0 * 365.0
	kamphuis_data['gross negative volume transport [m3/yr.]'] = kamphuis_data['gross negative volume transport [m3/s]'] * 60.0 * 60.0 * 24.0 * 365.0
	
	kamphuis_data['net mass transport [kg/yr.]']			 = kamphuis_data['net mass transport [kg/s]']   * 60.0 * 60.0 * 24.0 * 365.0
	kamphuis_data['net volume transport [m3/yr.]']		   = kamphuis_data['net volume transport [m3/s]'] * 60.0 * 60.0 * 24.0 * 365.0
	
	kamphuis_data['function name']						   = 'Kamphuis'
	
	
	return kamphuis_data

def max_time_step(InputValues,H_s,T_p,dx):
	""" calculate required time step """
	
	alpha = 0.0000000005
	
	# Compute S-phi curve per wave condition
	ang = np.arange(0,46).reshape(1,46)
	
	dS = 0
	
	for i in range(0,len(H_s)):
		kamphuis_data = Kamphuis(H_s[i],T_p[i],1,ang,InputValues)
		S = kamphuis_data['net volume transport [m3/yr.]']
		S[np.isnan(S)] = 0
		
		# calculate maximum slope in s-phi curve
		dS0 = np.max(np.abs(S[1:-1]-S[0:-2]))
		
		if dS0 > dS:
			dS = dS0
	
	dtmax = alpha * dS * dx
	
	# find most appropriate time step
	dt = 0.1
	while dt > dtmax:
		dt = dt/2.0

	return dt

def coastline_engine(InputValues,OutputValues):
	
	if not InputValues.Coastline_utm:
		_swf.MessageBox.Show("No coastline found")
	
	# Clear output
	OutputValues.CoastX			   = []
	OutputValues.CoastY			   = []
	OutputValues.CoastLon			 = []
	OutputValues.CoastLat			 = []
	OutputValues.Coastline_utm		= []
	OutputValues.Coastline_utm_codes  = []
	OutputValues.Years	 			  = []
	OutputValues.Time				  = []
	
	# Get coastline input
	coastline = np.array(InputValues.Coastline_utm)
	x0 = coastline[:,0]
	y0 = coastline[:,1]
	#x0[2] = x0[2]-100
	#y0[2] = y0[2]-100
	
	# Get waves input
	Hs_near0,Tp_near0,dir_near0,occ0 = get_wave_classes(InputValues)
	
	
	#	Write waveclimates to files
	#wavesFile = open(r"c:/Temp_CODES/wavesFromImport.txt",'w')
	
	# Calculate initial coastline position and grid spacing
	npoints = InputValues.npoints
	xcor, ycor, xcen, ycen, dx = resample_coastline(x0,y0,npoints)

	# Calculate minimum time step:
	tmax = InputValues.time
	dt = max_time_step(InputValues,Hs_near0,Tp_near0,dx)
	
	
	if dt < 0.001:
		_swf.MessageBox.Show("Time step is too small, please decrease number of points")

	# Maximum number of calculations
	nit = np.int(tmax/dt)
	
	# Check years to output
	requiredYears = np.arange(0,InputValues.time+1,InputValues.time_step)
	
	YearsList = []
	for y in requiredYears:
		YearsList.append("%0.2f" %y)

	
	# Start calculation loop
	year = 0
	
   
	for t in range(0,nit+1):
		
		# Calculate coastline wave angle
		coastline_angle, shoreNormal = coastline_orientation(xcen, ycen)
		
		# Copy wave conditions
		Hs_near = np.repeat(Hs_near0,len(shoreNormal),1)
		Tp_near = np.repeat(Tp_near0,len(shoreNormal),1)
		occ = np.repeat(occ0,len(shoreNormal),1)
		dir_near = np.repeat(dir_near0,len(shoreNormal),1)
		
		#wavesFile.write("\n-------------- Checking wave conditions Time:" + str(t) + "\n")
		#LenWavesInitial = dir_near.shape[0]
		#wavesFile.write("LenWaves:  " + str(LenWavesInitial) + "\n")
		
		# Calculate relative angle		
		RelativeDirNear = np.array(dir_near-shoreNormal)
		#wavesFile.write("dirnear 1:  " + str(dir_near) + "\n")
		
		RelativeDirNear[np.where(RelativeDirNear < 0)] = 360 + RelativeDirNear[np.where(RelativeDirNear < 0)] # Remove negative angles
		#wavesFile.write("RelativeDirNear 2:  " + str(RelativeDirNear) + "\n")
		#wavesFile.write("Shape:  " + str(RelativeDirNear.shape) + "\n")
		
		# Remove waves coming from land
		RemoveAngles = np.any((RelativeDirNear > 90) & (RelativeDirNear < 270),1)
		RelativeDirNear[RemoveAngles,:] = 0
		
		# Check direction of transport
		RelativeDirNear[np.where(RelativeDirNear >= 270)] = RelativeDirNear[np.where(RelativeDirNear >= 270)] - 360
		
		# Remove high angle waves (to avoid coastline instability)
		hwa = 45
		RelativeDirNear[np.abs(RelativeDirNear) > hwa] = hwa * np.abs(RelativeDirNear[np.abs(RelativeDirNear) > hwa])/RelativeDirNear[np.abs(RelativeDirNear) > hwa]
		#wavesFile.write("RelativeDirNear 3:  " + str(RelativeDirNear) + "\n")
		
		#wavesFile.write("Occurrence:  " + str(occ) + "\n")
		 
		# Calculate sediment transport
		exec("S = " + InputValues.formula + "(Hs_near,Tp_near,occ,RelativeDirNear,InputValues)")
		#wavesFile.write("Sediment transport:  " + str(S['net volume transport [m3/yr.]']*dt) + "\n")
		
		# Include location of breakwaters
		if t == 0:
			ind = add_structure_boundary(xcor,ycor,InputValues.Breakwaters_utm)
			""" Not implemented!
			for i in ind:
				# include point before structure
				xi = np.linspace(xcen[i-1],xcen[i],10)
				yi = np.linspace(ycen[i-1],ycen[i],10)
				
				xcen = np.insert(xcen,[i-1],xi[-2])
				ycen = np.insert(ycen,[i-1],yi[-2])
				
				xcor = np.insert(xcor,[i-1],xcor[i])
				ycor = np.insert(ycor,[i-1],ycor[i])
				
				# include point after structure
				xi = np.linspace(xcen[i],xcen[i+1],10)
				yi = np.linspace(ycen[i],ycen[i+1],10)
				
				xcen = np.insert(xcen,[i],xi[1])
				ycen = np.insert(ycen,[i],yi[1])
				
				xcor = np.insert(xcor,[i],xcor[i])
				ycor = np.insert(ycor,[i],ycor[i])
		"""
		
		if t > 0:
			
			# Calculate new coastline position
			xcen,ycen,xcor,ycor = calculate_coastline_position(InputValues,S,xcen,ycen,xcor,ycor,ind,dt)
			
			# Calculate year
			year = year+dt
		
		# Fill output object
		YearNumber = float(YearsList[0])
				
		if float(year) > YearNumber - dt/2.0 and float(year) < YearNumber + dt/2.0:
			OutputValues.CoastX.append(xcor)
			OutputValues.CoastY.append(ycor)
			
			OutputValues.Years.append(YearsList[0])
			YearsList.pop(0)
			
			#	Write outputvalues to file
			coastline = []
			for n in range(0,len(xcor)):
				coastline.append([xcor[n],ycor[n]])

			OutputValues.Coastline_utm.append(coastline)			
			
			
	#wavesFile.write("Calculation ready")
	#wavesFile.close()
		
# ------------------ Longshore Transport ------------------------------

def transect_orientation(InputValues,OutputValues):
	
	""" Calculate orientation of cross-shore transects """
	
	profile_angle = []
	
	for profile in InputValues.Profiles_utm:
		profile = np.array(profile)
		
		xdiff = profile[1,0] - profile[0,0]
		ydiff = profile[1,1] - profile[0,1]
		
		# Calculate angle
		ang = np.arctan2(xdiff,ydiff)/np.pi*180
		
		if ang < 0:
			ang = ang + 360
		
		profile_angle.append(ang)
	
	# Add to output
	OutputValues.TransectOrientation = profile_angle
	
	return profile_angle
	
def longshore_transport_engine(InputValues,OutputValues):
	
	""" Engine to calculate longshore transport through transects """ 
	
	#TransportFile = open(r"c:/Temp_CODES/longshore_transport_engine.txt",'w')
	
	# Clear output object
	OutputValues.SedTransPos = []
	OutputValues.SedTransNeg = []
	OutputValues.SedTransNet = []
	
	# Get waves input
	Hs_near0,Tp_near0,dir_near0,occ0 = get_wave_classes(InputValues)

	# Get transect orientation
	profile_angle = transect_orientation(InputValues,OutputValues)
	
	# Copy wave conditions
	Hs_near = np.repeat(Hs_near0,len(profile_angle),1)
	Tp_near = np.repeat(Tp_near0,len(profile_angle),1)
	occ = np.repeat(occ0,len(profile_angle),1)
	dir_near = np.repeat(dir_near0,len(profile_angle),1)
		
	# Calculate relative angle		
	RelativeDirNear = np.array(dir_near-profile_angle)
	
	RelativeDirNear[np.where(RelativeDirNear < 0)] = 360 + RelativeDirNear[np.where(RelativeDirNear < 0)] # Remove negative angles
	
	# Check direction of transport
	RelativeDirNear[np.where((RelativeDirNear > 90) & (RelativeDirNear < 270))] = 0 # waves coming from land
	RelativeDirNear[np.where(RelativeDirNear >= 270)] = RelativeDirNear[np.where(RelativeDirNear >= 270)] - 360
		
 	#TransportFile.write("Longshore transport direction:  " + str(RelativeDirNear) + "\n")

	# Calculate sediment transport
	exec("S = " + InputValues.formula + "(Hs_near,Tp_near,occ,RelativeDirNear,InputValues)")
	
 	#TransportFile.write("Sediment transport:  " + str(S['net volume transport [m3/yr.]']) + "\n")
	
	# Write to output object
	for i in range(0,len(profile_angle)):
		OutputValues.SedTransPos.append(S["gross positive volume transport [m3/yr.]"][i])
		OutputValues.SedTransNeg.append(S["gross negative volume transport [m3/yr.]"][i])
		OutputValues.SedTransNet.append(S["net volume transport [m3/yr.]"][i])
		
	#TransportFile.close()
	