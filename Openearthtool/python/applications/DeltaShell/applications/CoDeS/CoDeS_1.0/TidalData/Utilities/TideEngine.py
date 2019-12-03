#   Copyright notice
#   --------------------------------------------------------------------
#   Copyright (C) 2017 Deltares
#
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
from Libraries.NetCdfFunctions import *
import csv
import getpass
import numpy as _np
from datetime import datetime as _dt
import time as _t

def load_ascii(fname,hdr,delimiterChar,dateTimeFormat):
	"""
	Function to load ascii timeseries (as specified by product owners), see example *.txt (dummy_input.txt)
	
	INPUT:  - fname (full file name)
			- hdr (symbol for header, ex. '*')
			- delimiterChar (ex. '\t')
			- dateTimeFormat (ex. '%Y/%m/%d %H:%M:%S')
			
	OUTPUT: - data [list]
	"""
	

	#load the input file
	file = open(fname, "r")
	num_hdr = 0 #counter for later header skipping
	
	#determine number of header lines
	for line in file:
		num_hdr += 1
		if line.find(hdr) == -1: #determine if header token is in line string
			break
	
	#depends if the header info (num points/columns) is useful
	"""dummy = line #unsure what this dummy value is for...
	temp = file.readline() #read first line after header
	temp = temp.split(' ') #split based on space
	num_lines = float(temp[0]); #extract first value as number of lines
	num_vars = float(temp[1]); #extract second value as number of columns"""
	
	#extract all data from timeseries
	data = []
	liner = 0
	with open(fname) as csvfile:
		lines = csv.reader(csvfile,delimiter = delimiterChar)
		for line in lines:
			liner += 1
			if liner > num_hdr+1:
				dateLine = _dt.strptime(line[0],dateTimeFormat)
				valueLine = float(line[1])
				if len(line) > 2:
					for ii in range(2, len(line)):
						valueLine.append(float(line[ii]))
				data.append([dateLine, valueLine])
	file.close()
	return data


def extract_TOPEX(fullfilename, lat_in, lon_in):
	"""
	Function to load TOPEX constituent data (normally pointing to downloaded *.nc file 'h_tpxo7.2.nc')
	
	INPUT:  - lat_in (latitude in deg)
			- lon_in (longitude in deg)
		   
	OUTPUT: - data_out [dict] (consituent name with amplitude + phase)
	"""
	
	#read the TOPEX *.nc file
	#fname = "..\plugins\DeltaShell.Plugins.Toolbox\Scripts\Scripts\TidalData\DATA\h_tpxo7.2.nc" # BJ: Adjusted to new map structure
	#JB: made filename as input-argument
	file = NetCdfFile.OpenExisting(fullfilename)
	
	#read the 2 dimensional arrays
	constituents = file.Read(file.GetVariableByName("con"))
	phaseData = file.Read(file.GetVariableByName("hp"))
	amplitudeData = file.Read(file.GetVariableByName("ha"))
	latData = file.Read(file.GetVariableByName("lat_z"))
	lonData = file.Read(file.GetVariableByName("lon_z"))
	
	# get dimensions
	nx = file.GetDimensionLength(file.GetDimension("nx"))
	ny = file.GetDimensionLength(file.GetDimension("ny"))
	nc = file.GetDimensionLength(file.GetDimension("nc"))
	
	diff = []
	for ii in range(ny):
		diff.append(latData[0,ii] - lat_in)
	loc_lat = _np.argmin(_np.abs(diff))
	
	diff = []
	for ii in range(nx):
		diff.append(lonData[ii,0] - lon_in)
	loc_lon = _np.argmin(_np.abs(diff))
	
	con = []
	amp = []
	phase = []
	for ii in range(nc):
		amp.append(amplitudeData[ii,loc_lon,loc_lat])
		phase.append(phaseData[ii,loc_lon,loc_lat])
		temp = ''.join(constituents[ii])
		con.append(str.strip(temp))
	
	data_out = {}
	for ii in range(nc):
	    data_out[con[ii]] = [amp[ii],phase[ii]]
	return data_out

def export_stats(fname,stats,cons):
	"""
	Function to export tidal statistics
	
	INPUT:  - fname (full file name)
			- stats (calculated from tide_stats.py)
		   
	OUTPUT: *.txt file with date/user/statistics printed
	"""
	
	#open file for writing
	f = open(fname, 'w')
	
	#write header to file
	f.write('Tidal Analysis Output Statistics\n')
	f.write('================================\n')
	f.write('Run by: %s\n' %getpass.getuser())
	f.write('Run on: %s\n' %_dt.now())
	f.write('================================\n\n')
	
	#write all data to file
	f.write('Parameter, Value [m]\n')
	for key in stats.keys():
		f.write('%s, %.2f\n' %(key,stats[key]))
		
	#write constituents to file
	f.write('\n========================\n\n')
	
	#write all data to file
	f.write('Name, Amplitude [m], Phase [deg]\n')
	if cons == 0:
		f.write('\n**************************\n')
		f.write('*No Information Available*\n')
		f.write('**************************\n')
	else:
		for key in cons.keys():
			f.write('%s, %.4f, %.4f\n' %(key,cons[key][0],cons[key][1]))

	#close file
	f.close()
	
def localMax(data):
	"""
	Function to find local maxima in the tidal tiemseries
	
	INPUT:  - data (list, output from load_ascii with the first col = dateStr)
		   
	OUTPUT: - max_wl (array, value of maxima)
			- max_ind (array, index of maxima)
	"""
	
	wl = _np.array([col[1] for col in data])
	dx = _np.diff(wl)
	log = _np.logical_and(dx[:-1]>0,dx[1:]<=0)
	ind = _np.where(log)
	max_ind = [x+1 for x in ind]
	max_wl = _np.array(wl[max_ind])
	return max_wl, max_ind

# get the local min
def localMin(data):
	"""
	Function to find local minima in the tidal tiemseries
	
	INPUT:  - data (list, output from load_ascii with the first col = dateStr)
		   
	OUTPUT: - min_wl (array, value of minima)
			- min_ind (array, index of minima)
	"""
	
	wl = _np.array([col[1] for col in data])
	dx = _np.diff(wl)
	log = _np.logical_and(dx[:-1]<0,dx[1:]>=0)
	ind = _np.where(log)
	min_ind = [x+1 for x in ind]
	min_wl = _np.array(wl[min_ind])
	return min_wl, min_ind

# get Mean Sea Level (MSL)
def getMSL(data):
	"""
	Function to find mean sea level from tidal timeseries
	
	INPUT:  - data (list, output from load_ascii with the first col = dateStr)
		   
	OUTPUT: - MSL (float, value of MSL)
	"""
	wl = _np.array([col[1] for col in data])
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
		dater.append(_t.mktime(temp[ii].timetuple()))
	dt = 1./(_np.mean(_np.diff(dater))/86400)
	timeWindow = 14.76529; #days
	dt = int(dt*timeWindow) #number of "steps" in the file representing 14 days
	
	lmin,id = localMin(data)
	d_WL = lmin[id[0][:]<dt] - _np.mean(lmin[id[0][:]<dt]) #detrend during 1st spring tide
	startID = _np.argmin(_np.abs(d_WL)) #find the closest minima to mean
	
	lw = [] #initialize
	for ii in range(startID,len(temp)-dt,dt):
		log = _np.logical_and(id[0][:]>=ii,id[0][:]<=ii+dt)
		lwA_ind = _np.argmin(lmin[log])
		lwA = min(lmin[log])
		lwB = lmin[log[lwA_ind]+1]
		lw.append((lwA+lwB)/2)
	MLWS = _np.mean(lw)
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
		dater.append(_t.mktime(temp[ii].timetuple()))
	dt = 1./(_np.mean(_np.diff(dater))/86400)
	timeWindow = 14.76529; #days
	dt = int(dt*timeWindow) #number of "steps" in the file representing 14 days
	
	lmin,id = localMin(data)
	d_WL = lmin[id[0][:]<dt] - _np.mean(lmin[id[0][:]<dt]) #detrend during 1st spring tide
	startID = _np.argmin(_np.abs(d_WL)) #find the closest minima to mean
	
	lw = [] #initialize
	for ii in range(startID,len(temp)-dt,dt):
		log = _np.logical_and(id[0][:]>=ii,id[0][:]<=ii+dt)
		lwA_ind = _np.argmax(lmin[log])
		lwA = max(lmin[log])
		lwB = lmin[log[lwA_ind]+1]
		lw.append((lwA+lwB)/2)
	MLWN = _np.mean(lw)
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
		dater.append(_t.mktime(temp[ii].timetuple()))
	dt = 1./(_np.mean(_np.diff(dater))/86400)
	timeWindow = 14.76529; #days
	dt = int(dt*timeWindow) #number of "steps" in the file representing 14 days
	
	lmax,id = localMax(data)
	d_WL = lmax[id[0][:]<dt] - _np.mean(lmax[id[0][:]<dt]) #detrend during 1st spring tide
	startID = _np.argmin(_np.abs(d_WL)) #find the closest minima to mean
	
	hw = [] #initialize
	for ii in range(startID,len(temp)-dt,dt):
		log = _np.logical_and(id[0][:]>=ii,id[0][:]<=ii+dt)
		hwA_ind = _np.argmax(lmax[log])
		hwA = max(lmax[log])
		hwB = lmax[log[hwA_ind]+1]
		hw.append((hwA+hwB)/2)
	MHWS = _np.mean(hw)
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
		dater.append(_t.mktime(temp[ii].timetuple()))
	dt = 1./(_np.mean(_np.diff(dater))/86400)
	timeWindow = 14.76529; #days
	dt = int(dt*timeWindow) #number of "steps" in the file representing 14 days
	
	lmax,id = localMax(data)
	d_WL = lmax[id[0][:]<dt] - _np.mean(lmax[id[0][:]<dt]) #detrend during 1st spring tide
	startID = _np.argmin(_np.abs(d_WL)) #find the closest minima to mean
	
	hw = [] #initialize
	for ii in range(startID,len(temp)-dt,dt):
		log = _np.logical_and(id[0][:]>=ii,id[0][:]<=ii+dt)
		hwA_ind = _np.argmin(lmax[log])
		hwA = min(lmax[log])
		hwB = lmax[log[hwA_ind]+1]
		hw.append((hwA+hwB)/2)
	MHWN = _np.mean(hw)
	return MHWN