"""Inquire on available cdi records on the server side either
i) in postgresql database generated from
ii) in a data folder organized as EDMO_code/<filename>.txt by odvdir.py.
JSON file caches are used to speed up response for large cdi collections.
https://publicwiki.deltares.nl/display/OET/pyWPSodv"""

# This tool is part of <a href="http://OpenEarth.nl">OpenEarthTools</a>.
# OpenEarthTools is an online collaboration to share and manage data and 
# programming tools in an open source, version controlled environment.
# Sign up to recieve regular updates of this function, and to contribute 
# your own tools.

# $Id: odvGetParameters.py 10693 2014-05-15 13:21:46Z boer_g $
# $Date: 2014-05-15 15:21:46 +0200 (Thu, 15 May 2014) $
# $Author: boer_g $
# $Revision: 10693 $
# $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/python/applications/wps/processes/odvGetParameters.py $
# $Keywords: $

# ----------------------------------------------
## server information
# on virtal test server, NGINX: /etc/nginx/sites-enabled
# points to:                    /etc/uwsgi/apps-enabled/wps.yml
# points to:                    /var/lib/wsgi/wps/pywps.cfg
# points to:                    /var/lib/wsgi/wps/processes
# ----------------------------------------------
## WPS wrapping
#  TO DO: solve issue that for letting pyWPS return a relative link inside xml reponse (WPS specs allow for it)
#  TO DO: check images Allessandra and SOER2010 by EEA, and tailor png return to look that (incl sea regions)
#  TO DO: implement color classes as input argument (next to clims)
#  TO DO: implement odvGetCDI subset on EDMO_code
#  TO DO: implement odvGetCDI subset on LOCAL_CDI_ID
#  TO DO: return geoJSON instead of JSON
# ----------------------------------------------

from pywps.Process import WPSProcess
from pywps import config
import os, sys, glob
import logging
import pandas
import pyodv as pyodv

tempPath = config.getConfigValue("server","tempPath") # default.cfg in pywps_processes
dataPath = config.getConfigValue("server","dataPath") # default.cfg in pywps_processes: folder of PG connection string

def orm_get_cdi(dbstring):
    """request all cdi"""

    ## Import the ORM
    from pyodv.odv2orm_model  import *
    from sqlalchemy     import create_engine
    from sqlalchemy.orm import sessionmaker
    import geoalchemy2.functions as ga_func

    ## Connect to the DB
    Engine = create_engine(dbstring, echo=False) # echo=True is very slow, and hackable
    lineage = Engine.url.drivername + '://' + Engine.url.username + ':********@'+Engine.url.host+':'+str(Engine.url.port)+'/'+Engine.url.database # dbstring
    
    ## Create a Session
    Session = sessionmaker(bind=Engine)
    session = Session()
    
    ## get data
    rows = session.query(Cdi.edmo_code,
                         Cdi.local_cdi_id,
                         Cdi.datetime,
            ga_func.ST_X(Cdi.geom),
            ga_func.ST_Y(Cdi.geom))
    
    session.close()
             
    n = rows.count()

    if n==0:
        print('NO CDIs FOUND')
        return O    
    
    EDMO_code    = []
    LOCAL_CDI_ID = []
    filename     = [] # without *.txt extension
    datetime     = []
    longitude    = []
    latitude     = []
    
    for i,row in enumerate(rows):
    
       EDMO_code.append   (row[0])
       LOCAL_CDI_ID.append(row[1])
       filename.append    (''    )
       datetime.append    (row[2])
       longitude.append   (row[3])
       latitude.append    (row[4])

    return pandas.DataFrame({'EDMO_code':EDMO_code,'LOCAL_CDI_ID':LOCAL_CDI_ID,'filename':filename,'datetime':datetime,'longitude':longitude,'latitude':latitude})

class odvProcess(WPSProcess):
    def __init__(self):
        WPSProcess.__init__(self,
                            identifier="cdi_get_metadata", # must be same, as filename
                            title="OceanDataView web processing service: cdi_get_metadata > cdi_get_parameters > [odv_plot_map, odv_plot_profile, odv_plot_timeseries]",
                            version="$Id: odvGetParameters.py 10693 2014-05-15 13:21:46Z boer_g $",
                            storeSupported=True,
                            statusSupported=True,
                            abstract="odvGetCDI returns a list of the datafiles of a remote server",
                            grassLocation=False)
                                             
#        self.EDMO_code = self.addLiteralInput(identifier = "EDMO_code",
#                                           title      = "EDMO_code of datacenter",
#                                           type       = type("000"),
#                                           default    = "486")
#        self.LOCAL_CDI_ID = self.addLiteralInput(identifier = "LOCAL_CDI_ID",
#                                           title      = "Unique local identifier of dataset in datacenter",
#                                           type       = type("123abc"),
#                                           default    = "18037204_PCh_Surf")

        self.datafiles = self.addComplexOutput(identifier = "datafiles",
                                             title      = "json stream of all datafiles on server as (EDMO_code,LOCAL_CDI_ID,filename,datetime,longitude,latitude) tuples",
                                             formats    = [{"mimeType":"text/json"}])


    def execute(self):
    
        logging.info("odvGetCDI: tempPath: " + tempPath)
        logging.info("odvGetCDI: dataPath: " + dataPath)
        
        storename = os.path.join(tempPath, 'cdi_get_metadata.json')
        
        # read file cache: for odv + PG
        if os.path.isfile(storename):
            F = pyodv.odvdir.cache2pandas(storename)
            logging.info("odvGetCDI: got # " + str(len(F["EDMO_code"])) + ' cdis from loading ' + storename)
            
        # test PG directly and save to file cache (find out if needed)
        elif dataPath[0:13]=='postgresql://':
            F = orm_get_cdi(dataPath)
            logging.info("odvGetCDI: got # " + str(len(F["EDMO_code"])) + ' cdis from querying ' + dataPath)
            pyodv.odvdir.pandas2cache(F,storename)
            logging.info("odvGetCDI: copied metadata cache to temp folder. ")
            
        # test odv cache, and otherwise loop all files
        else:
            cachename = os.path.join(dataPath, 'cdi_get_metadata.json')
            if os.path.isfile(cachename):
                logging.info("getting cache " + cachename)
                import shutil
                shutil.copyfile(cachename,storename)
                logging.info("odvGetCDI: copied metadata cache to temp folder. ")
                F = pyodv.odvdir.cache2pandas(storename)
                logging.info("odvGetCDI: got # " + str(len(F["EDMO_code"])) + ' cdis from loading ' + cachename)
            else:
                F = pyodv.odvdir.odvroot2pandas(dataPath)
                logging.info("odvGetCDI: got # " + str(len(F["EDMO_code"])) + ' cdis from scanning ' + dataPath)
                pyodv.odvdir.pandas2cache(F,storename)
        
        self.datafiles.setValue(storename) # if Output2 is WPS addComplexOutput(...,asReference=False), this file will actually be written, mapped to mime and inserted into xml
        logging.info("datafiles written")

        return
