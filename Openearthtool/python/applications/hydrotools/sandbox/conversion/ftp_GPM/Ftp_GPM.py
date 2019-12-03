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

urlBase = 'jsimpson.pps.eosdis.nasa.gov'
dataDirBase = 'data/imerg/late/'
outputDir = sys.argv[1]
xmldiagfname = "ftp_GPM_diag.xml"
logfile = "ftp_GPM_adapt.log"
un=
pw=

# non-configurable part ------------------------------------------------------------------------------
logger = setlogger(logfile,"ftp_GPM_adapt")    
logger.info("Starting ftp")   
logger.info(urlBase)
ftp = FTP(urlBase,'','','',20)
exitCode=ftp.login(un,pw)  
logger.info(exitCode)
ftp.cwd(dataDirBase)
dirnames=[]
ftp.retrlines('NLST',dirnames.append)
dirnames.sort()
ftp.set_pasv(True)

import datetime
from fnmatch import fnmatch
a=datetime.datetime.strptime(sys.argv[2],'%Y%m%d')
numdays = 5
dateList = []
dateList2 = []
for x in range (0, numdays):
    dateList.append(a - datetime.timedelta(days = x))
    dateList2.append(dateList[x].strftime('%Y%m%d'))
#print dateList
print dateList2

filenames = []
for x in range(0,len(dirnames)):
	ftp.cwd(dirnames[x])
	ftp.retrlines('NLST', filenames.append) 
	nTry = 0
	while len(filenames)>0:
		filenamesFailed = []
	#	for filename in filenames:
	#          if (filename.startswith('3B') and filename.endswith('.RT-H5')):
		for filename in filenames:
		   if any(fnmatch(filename, '*'+pattern+'*') for pattern in dateList2):
	             print filename
	             exitCode=ftp.retrbinary('RETR '+filename, open(outputDir+'/'+filename, 'wb').write)
	             logger.info(filename+' '+exitCode)
	             filenamesFailed=[]
	             if exitCode!='226 Transfer complete.'>0:
					filenamesFailed.append(filename)
		filenames = filenamesFailed
	    # try to download every file 5 times in case of failure
		nTry = nTry+1
		if nTry==5: 
			break
	ftp.cwd('..')
	filenames = []


ftp.quit()
logger.info('script completed !!!')
logger.info('failed downloads = '+str(len(filenamesFailed)))
logger.info("Ending Ftp")
# convert logfile to xml
log2xml(logfile,xmldiagfname)
			


