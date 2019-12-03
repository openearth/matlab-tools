# core
import os

# local packages
from config import *
from utils_geoserver import *

## MAIN

# Read configuration
conf = CONF(os.path.join(os.path.dirname(os.path.realpath(__file__)), 'config.txt')).readConfig()
path = conf['DATA_DIR'] 
outd = conf['DATA_RESAMP_DIR'] 
wksp = conf['WORKSPACE_DATA']
res = [5]

io = utilsGeoserver(conf)
for root, dirs, files in os.walk(path, topdown=False):
    for t in files:        
        if t.endswith('.tif'):	# resample to 10m and 25m and upload to GeoServer
            for r in res:
	            o=io.resampleTiff(t, path, outd, r)
	            io.geoserverUploadGtif(os.path.abspath(o), wksp)
		