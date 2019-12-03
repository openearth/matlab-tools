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
#i/o functions
#JFriedman Jan.28/15
#------------------

def load_ascii(fname,hdr,delimiterChar,dateTimeFormat):
	"""
	Function to load ascii timeseries (as specified by product owners), see example *.txt (dummy_input.txt)
	
	INPUT:  - fname (full file name)
			- hdr (symbol for header, ex. '*')
			- delimiterChar (ex. '\t')
			- dateTimeFormat (ex. '%Y/%m/%d %H:%M:%S')
		   
	OUTPUT: - data [list]
	"""
	
	#load necessary libraries
	import csv
	from datetime import datetime
	
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
				dateLine = datetime.strptime(line[0],dateTimeFormat)
				valueLine = float(line[1])
				if len(line) > 2:
					for ii in range(2, len(line)):
						valueLine.append(float(line[ii]))
				data.append([dateLine, valueLine])
	file.close()
	return data

def extract_TOPEX(lat_in,lon_in):
	"""
	Function to load TOPEX constituent data (downloaded *.nc file in \DATA\h_tpxo7.2.nc)
	
	INPUT:  - lat_in (latitude in deg)
			- lon_in (longitude in deg)
		   
	OUTPUT: - data_out [dict] (consituent name with amplitude + phase)
	"""
	
	#load necessary libraries
	from Libraries.NetCdfFunctions import *
	import numpy as np
	
	#read the TOPEX *.nc file
	fname = "..\plugins\DeltaShell.Plugins.Toolbox\Scripts\Scripts\TidalData\DATA\h_tpxo7.2.nc" # BJ: Adjusted to new map structure
	file = NetCdfFile.OpenExisting(fname)
	
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
	loc_lat = np.argmin(np.abs(diff))
	
	diff = []
	for ii in range(nx):
		diff.append(lonData[ii,0] - lon_in)
	loc_lon = np.argmin(np.abs(diff))
	
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
	
	#load necessary libraries
	from datetime import datetime
	import getpass
	
	#open file for writing
	f = open(fname, 'w')
	
	#write header to file
	f.write('Tidal Analysis Output Statistics\n')
	f.write('================================\n')
	f.write('Run by: %s\n' %getpass.getuser())
	f.write('Run on: %s\n' %datetime.now())
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