# -*- coding: utf-8 -*-
#   --------------------------------------------------------------------
#   Copyright (C) 2018 Deltares
#       Joan Sala
#       joan.salacalero@deltares.nl
#       Nena Vandebroek
#       nena.vandebroek@deltares.nl
#
#   This library is free software: you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
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
#
# This tool is part of <a href="http://www.OpenEarth.eu">OpenEarthTools</a>.
# OpenEarthTools is an online collaboration to share and manage data and
# programming tools in an open source, version controlled environment.
# Sign up to recieve regular updates of this function, and to contribute
# your own tools.

# core 
import os
import configparser

# modules
import time
import statistics
import numpy as np
import datetime

# Read default configuration from file
def readConfig():
	# Default config file (relative path)
	cfile=os.path.join(os.path.dirname(os.path.realpath(__file__)), 'pt_config.txt')
	cf = configparser.RawConfigParser()
	cf.read(cfile)
	reports_dir = cf.get('Reports', 'reports_dir')
	reports_url = cf.get('Reports', 'reports_url')
	plots_dir = cf.get('Bokeh', 'plots_dir')
	plots_url = cf.get('Bokeh', 'plots_url')
	piwebservice_url = cf.get('PIService', 'host') # default is 'local'
	return reports_dir, reports_url, plots_dir, plots_url, piwebservice_url

# Do we need to generate a CSV, default is false
def getGenerateCsv(conf):
	try:
		return conf['generateCsv'] == 'True'
	except:
		return False

# Get plot size [defaults included]
def getPlotSize(conf):
	try:
		return int(conf['plotXsize']), int(conf['plotYsize'])
	except:
		return 770, 370 # defaults

# Get plot settings [analyze tab]
def getPlotSettings(conf):
	# Empty defaults
	title = ''
	xAxis = ''
	yAxis1 = ''
	yAxis2 = ''

	try:
		title = conf['title']
	except:
		pass
	try:
		xAxis = conf['xAxis']
	except:
		pass
	try:
		yAxis1 = conf['yAxis1']
	except:
		pass
	try:
		yAxis2 = conf['yAxis2']
	except:
		pass						

	return title, xAxis, yAxis1, yAxis2

# Get a unique temporary file
def getTempFile(tempdir, typen='plot', extension='.html'):
    fname = typen + '_' + str(time.time()).replace('.','')
    return os.path.join(tempdir, fname+extension)

# Get basic statistics in html format
def getStatistics(time, vals):
	y = [item for sublist in vals for item in sublist]
	statsJSON = {
		'mean': round(statistics.mean(y),2),
		'stdev': round(statistics.stdev(y),2),
		'variance': round(statistics.variance(y),2),
		'sum': round(sum(y),2)
	}
	return statsJSON

# The following function returns the indices from doing an intersection analysis. This is used in the scatterplot function to find matching timesteps in two datasets to compare in the plot. 
def intersection_indices(a, b):
	a1=np.argsort(a)
	b1=np.argsort(b)

	# use searchsorted:
	sort_left_a=a[a1].searchsorted(b[b1], side='left')
	sort_right_a=a[a1].searchsorted(b[b1], side='right')
	sort_left_b=b[b1].searchsorted(a[a1], side='left')
	sort_right_b=b[b1].searchsorted(a[a1], side='right')

	# which values of b are also in a?
	inds_b=(sort_right_a-sort_left_a > 0).nonzero()[0]
	# which values of a are also in b?
	inds_a=(sort_right_b-sort_left_b > 0).nonzero()[0]

	# return the indices of a and b which return the matching values of a and b
	return a1[inds_a], b1[inds_b]

# Datetime conversions
def datetime_to_float(d):
	epoch = datetime.datetime.fromtimestamp(86400)
	total_seconds =  (d - epoch).total_seconds()
	# total_seconds will be in decimals (millisecond precision)
	return total_seconds

def float_to_datetime(fl):
    return datetime.datetime.fromtimestamp(fl)    