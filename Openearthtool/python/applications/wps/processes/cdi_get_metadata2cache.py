"update (create/overwrite) cache for speeding-up cdi_get_metadata."
import os
import pyodv as p

dataDir = config.getConfigValue("server","dataPath") # default.cfg in pywps_processes

cachename = os.path.join(dataDir, 'cdi_get_metadata.json')

p.odvroot2cache(dataDir,cachename)