#   Copyright notice
#   --------------------------------------------------------------------
#   Copyright (C) 2016 Deltares
#       Josh Friedman
#
#       josh.friedman@deltares.nl
#
#       P.O. Box 177
#       2600 MH Delft
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
#extracting tide stats
#JFriedman Jan.8/15
#------------------

#load libraries
import numpy as np
import time as t

# get the local max
def localMax(data):
	"""
	Function to find local maxima in the tidal tiemseries
	
	INPUT:  - data (list, output from load_ascii with the first col = dateStr)
		   
	OUTPUT: - max_wl (array, value of maxima)
			- max_ind (array, index of maxima)
	"""
	
	wl = np.array([col[1] for col in data])
	dx = np.diff(wl)
	log = np.logical_and(dx[:-1]>0,dx[1:]<=0)
	ind = np.where(log)
	max_ind = [x+1 for x in ind]
	max_wl = np.array(wl[max_ind])
	return max_wl, max_ind

# get the local min
def localMin(data):
	"""
	Function to find local minima in the tidal tiemseries
	
	INPUT:  - data (list, output from load_ascii with the first col = dateStr)
		   
	OUTPUT: - min_wl (array, value of minima)
			- min_ind (array, index of minima)
	"""
	
	wl = np.array([col[1] for col in data])
	dx = np.diff(wl)
	log = np.logical_and(dx[:-1]<0,dx[1:]>=0)
	ind = np.where(log)
	min_ind = [x+1 for x in ind]
	min_wl = np.array(wl[min_ind])
	return min_wl, min_ind

# get Mean Sea Level (MSL)
def getMSL(data):
	"""
	Function to find mean sea level from tidal timeseries
	
	INPUT:  - data (list, output from load_ascii with the first col = dateStr)
		   
	OUTPUT: - MSL (float, value of MSL)
	"""
	wl = np.array([col[1] for col in data])
	MSL = sum(wl)/len(wl)
	return MSL

# get High Water (HAT)
def getHAT(data):
	"""
	Function to find highest astronomical tide from tidal timeseries
	
	INPUT:  - data (list, output from load_ascii with the first col = dateStr)
		   
	OUTPUT: - HAT (float, value of HAT)
	"""
	
	val,_ = localMax(data)
	HAT = max(val)
	return HAT

# get Low Water (LAT)
def getLAT(data):
	"""
	Function to find lowest astronomical tide from tidal timeseries
	
	INPUT:  - data (list, output from load_ascii with the first col = dateStr)
		   
	OUTPUT: - LAT (float, value of LAT)
	"""
	
	val,_ = localMin(data)
	LAT = min(val)
	return LAT

# get Mean Low Water Spring (MLWS)
def getMLWS(data):
	"""
	Function to find mean low water spring from tidal timeseries
	
	INPUT:  - data (list, output from load_ascii with the first col = dateStr)
		   
	OUTPUT: - MLWS (float, value of MLWS)
	"""
	
	temp = [col[0] for col in data]
	dater = []
	for ii in range(0, len(temp)):
		dater.append(t.mktime(temp[ii].timetuple()))
	dt = 1./(np.mean(np.diff(dater))/86400)
	timeWindow = 14.76529; #days
	dt = int(dt*timeWindow) #number of "steps" in the file representing 14 days
	
	lmin,id = localMin(data)
	d_WL = lmin[id[0][:]<dt] - np.mean(lmin[id[0][:]<dt]) #detrend during 1st spring tide
	startID = np.argmin(np.abs(d_WL)) #find the closest minima to mean
	
	lw = [] #initialize
	for ii in range(startID,len(temp)-dt,dt):
		log = np.logical_and(id[0][:]>=ii,id[0][:]<=ii+dt)
		lwA_ind = np.argmin(lmin[log])
		lwA = min(lmin[log])
		lwB = lmin[log[lwA_ind]+1]
		lw.append((lwA+lwB)/2)
	MLWS = np.mean(lw)
	return MLWS
	
# get Mean Low Water Neap (MLWN)
def getMLWN(data):
	"""
	Function to find mean low water neap from tidal timeseries
	
	INPUT:  - data (list, output from load_ascii with the first col = dateStr)
		   
	OUTPUT: - MLWN (float, value of MLWN)
	"""
	
	temp = [col[0] for col in data]
	dater = []
	for ii in range(0, len(temp)):
		dater.append(t.mktime(temp[ii].timetuple()))
	dt = 1./(np.mean(np.diff(dater))/86400)
	timeWindow = 14.76529; #days
	dt = int(dt*timeWindow) #number of "steps" in the file representing 14 days
	
	lmin,id = localMin(data)
	d_WL = lmin[id[0][:]<dt] - np.mean(lmin[id[0][:]<dt]) #detrend during 1st spring tide
	startID = np.argmin(np.abs(d_WL)) #find the closest minima to mean
	
	lw = [] #initialize
	for ii in range(startID,len(temp)-dt,dt):
		log = np.logical_and(id[0][:]>=ii,id[0][:]<=ii+dt)
		lwA_ind = np.argmax(lmin[log])
		lwA = max(lmin[log])
		lwB = lmin[log[lwA_ind]+1]
		lw.append((lwA+lwB)/2)
	MLWN = np.mean(lw)
	return MLWN

# get Mean High Water Spring (MHWS)
def getMHWS(data):
	"""
	Function to find mean high water spring from tidal timeseries
	
	INPUT:  - data (list, output from load_ascii with the first col = dateStr)
		   
	OUTPUT: - MHWS (float, value of MHWS)
	"""
	
	temp = [col[0] for col in data]
	dater = []
	for ii in range(0, len(temp)):
		dater.append(t.mktime(temp[ii].timetuple()))
	dt = 1./(np.mean(np.diff(dater))/86400)
	timeWindow = 14.76529; #days
	dt = int(dt*timeWindow) #number of "steps" in the file representing 14 days
	
	lmax,id = localMax(data)
	d_WL = lmax[id[0][:]<dt] - np.mean(lmax[id[0][:]<dt]) #detrend during 1st spring tide
	startID = np.argmin(np.abs(d_WL)) #find the closest minima to mean
	
	hw = [] #initialize
	for ii in range(startID,len(temp)-dt,dt):
		log = np.logical_and(id[0][:]>=ii,id[0][:]<=ii+dt)
		hwA_ind = np.argmax(lmax[log])
		hwA = max(lmax[log])
		hwB = lmax[log[hwA_ind]+1]
		hw.append((hwA+hwB)/2)
	MHWS = np.mean(hw)
	return MHWS
	
# get Mean High Water Neap (MHWN)
def getMHWN(data):
	"""
	Function to find mean high water neap from tidal timeseries
	
	INPUT:  - data (list, output from load_ascii with the first col = dateStr)
		   
	OUTPUT: - MHWN (float, value of MHWN)
	"""
	
	temp = [col[0] for col in data]
	dater = []
	for ii in range(0, len(temp)):
		dater.append(t.mktime(temp[ii].timetuple()))
	dt = 1./(np.mean(np.diff(dater))/86400)
	timeWindow = 14.76529; #days
	dt = int(dt*timeWindow) #number of "steps" in the file representing 14 days
	
	lmax,id = localMax(data)
	d_WL = lmax[id[0][:]<dt] - np.mean(lmax[id[0][:]<dt]) #detrend during 1st spring tide
	startID = np.argmin(np.abs(d_WL)) #find the closest minima to mean
	
	hw = [] #initialize
	for ii in range(startID,len(temp)-dt,dt):
		log = np.logical_and(id[0][:]>=ii,id[0][:]<=ii+dt)
		hwA_ind = np.argmin(lmax[log])
		hwA = min(lmax[log])
		hwB = lmax[log[hwA_ind]+1]
		hw.append((hwA+hwB)/2)
	MHWN = np.mean(hw)
	return MHWN