# -*- coding: utf-8 -*-
"""
Created on Sun Feb 15 09:54:27 2015
@author: Albrecht Weerts (based on scripts by Dirk Schwanenberg and Jaap Schellekens)
"""
import logging
import logging.handlers
import sys
import os
from ftplib import FTP

def setlogger(logfilename,loggername,thelevel=logging.INFO):
    """
    Set-up the logging system and return a logger object. Exit if this fails
    """
    try:    
        #create logger
        logger = logging.getLogger(loggername)
        if not isinstance(thelevel, int):
            logger.setLevel(logging.DEBUG)
        else:
            logger.setLevel(thelevel)
        ch = logging.FileHandler(logfilename,mode='w')
        console = logging.StreamHandler()
        console.setLevel(logging.DEBUG)
        ch.setLevel(logging.DEBUG)
        #create formatter
        formatter = logging.Formatter("%(asctime)s - %(name)s - %(levelname)s - %(message)s")
        #add formatter to ch
        ch.setFormatter(formatter)
        console.setFormatter(formatter)
        #add ch to logger
        logger.addHandler(ch)
        logger.addHandler(console)
        logger.debug("File logging to " + logfilename)
        return logger
    except IOError:
        print "ERROR: Failed to initialize logger with logfile: " + logfilename
        sys.exit(2)


def log2xml(logfile,xmldiag):
    """
    Converts a wflow log file to a Delft-Fews XML diag file
    """
    trans = {'WARNING': '2', 'ERROR': '1', 'INFO': '3','DEBUG': '4'}
    if os.path.exists(logfile):
        ifile = open(logfile,"r")
        ofile = open(xmldiag,"w")
        all = ifile.readlines()
        ofile.write("<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n")
        ofile.write("<Diag xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" \n")
        ofile.write("xmlns=\"http://www.wldelft.nl/fews/PI\" xsi:schemaLocation=\"http://www.wldelft.nl/fews/PI \n")
        ofile.write("http://fews.wldelft.nl/schemas/version1.0/pi-schemas/pi_diag.xsd\" version=\"1.2\">\n")
        for aline in all:
            lineparts = aline.strip().split(" - ")
            ofile.write("<line level=\"" + trans[lineparts[2]] + "\" description=\"" + lineparts[3] + " [" + lineparts[0] + "]\"/>\n")
        ofile.write("</Diag>\n")


#def main():            
#"""
#Main entry for using the module as a command line program (e.g. from the Delft-FEWS GA)
#"""
#from datetime import timedelta, tzinfo, datetime
#from string import replace

# configurable part ----------------------------------------------------------------------------------

urlBase = 'hokusai.eorc.jaxa.jp'
dataDirBase = 'realtime/daily0.1/00Z-23Z'
currentDir=os.getcwd()
outputDir = sys.argv[1]
xmldiagfname = "ftp_GSMAP_diag.xml"
logfile = "ftp_GSMAP_adapt.log"
un=
pw=

# non-configurable part ------------------------------------------------------------------------------
logger = setlogger(logfile,"ftp_GSMAP_adapt")    
logger.info("Starting ftp")   
logger.info(urlBase)
ftp = FTP(urlBase,'','','',20)
exitCode=ftp.login(un,pw)  
logger.info(exitCode)
ftp.cwd(dataDirBase)
dirnames=[]
ftp.retrlines('NLST',dirnames.append)
dirnames.sort()
print dirnames
ftp.set_pasv(True)

import datetime
from fnmatch import fnmatch
a=datetime.datetime.strptime(sys.argv[2],'%Y%m%d')
numdays = 10
dateList = []
dateList2 = []
for x in range (0, numdays):
    dateList.append(a - datetime.timedelta(days = x))
    dateList2.append(dateList[x].strftime('%Y%m%d'))
#print dateList
print dateList2

filenames = []
for x in range(0,len(dirnames)):
	try:
		ftp.cwd(dirnames[x])
		ftp.retrlines('NLST', filenames.append) 
		nTry = 0
		while len(filenames)>0:
			filenamesFailed = []
			for filename in filenames:
		           print filename
			   if any(fnmatch(filename, '*'+pattern+'*') for pattern in dateList2):
		             print filename
		             exitCode=ftp.retrbinary('RETR '+filename, open(outputDir+'/'+filename, 'wb').write)
		             logger.info(filename+' '+exitCode)
		             filenamesFailed=[]
		             if exitCode!='226 Transfer complete.'>0:
						filenamesFailed.append(filename)
			filenames = filenamesFailed
		    # try to download every file 2 times in case of failure
			nTry = nTry+1
			if nTry==2: 
				break
		ftp.cwd('..')
		filenames = []
	except Exception: 
	  pass

ftp.quit()
			

import numpy as np
import os
#import re
import gzip
import netCDF4
from netCDF4 import num2date, date2num
from datetime import datetime, timedelta
import matplotlib.pyplot as plt


# Calculate lon/lat grid points from info on website
lons=np.arange(0.05, 360, 0.1)
#lons=np.where(lons>180, lons-360, lons)
lats = np.arange(59.95, -59.95-0.1, -0.1)
data_lon_size=3600
data_lat_size=1200

data_dir = outputDir
os.chdir(data_dir)
files=[s for s in os.listdir('.')]

ncfile = netCDF4.Dataset('GSMaP_'+sys.argv[2]+'.nc', 'w') 
    # create a dimensions
time=ncfile.createDimension('time',0)  
lat=ncfile.createDimension('lat',data_lat_size)        
lon=ncfile.createDimension('lon',data_lon_size)
lat=ncfile.createVariable('lat','double',('lat',))
lat.standard_name='latitude'
lat.units='degrees _north' 
lat.axis="Y"
lon=ncfile.createVariable('lon','double',('lon',))
lon.standard_name='longitude'
lon.units='degrees _east' 
lon.axis="X"  
times = ncfile.createVariable('time', 'double', ('time',))
times.standard_name='time'
times.long_name='time'
times.units = 'days since 1970-01-01 00:00:00.0 +0000'
times.calendar = 'gregorian'
precip=ncfile.createVariable('precipitation_amount','double',('time','lat','lon'), zlib=True)
precip.standard_name='precipitation_amount'
precip.units='mm'
lat[:]=lats
lon[:]=lons
for nt, filename in enumerate(files):
    f = gzip.open(filename,'rb')
    datex = datetime(int(filename[-34:-30]),int(filename[-30:-28]),int(filename[-28:-26]))  
    datex=datex+timedelta(days=1)
    times[nt] = date2num(datex,units=times.units,calendar=times.calendar)
    dt = np.dtype('<f4') # Little-endian 4byte (32bit) float
    a=np.frombuffer(f.read(), dtype=dt).reshape(data_lat_size,data_lon_size)
    precip[nt, :, :]=a    
    f.close()
    ncfile.sync()

ncfile.close()

import glob
filelist = glob.glob('*.gz')
print filelist
for f in filelist:
    os.remove(f)

logger.info('ncfile closed')
logger.info('script completed !!!')
logger.info('failed downloads = '+str(len(filenamesFailed)))
logger.info("Ending Ftp")
# convert logfile to xml
os.chdir(currentDir)
print os.getcwd()
log2xml(logfile,xmldiagfname)
logger.info("Ending XML file")

