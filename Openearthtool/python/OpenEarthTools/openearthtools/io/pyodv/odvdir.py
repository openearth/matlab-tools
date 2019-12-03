# scan a folder with odv files to extract discovery metadata and save/load from.to cache

# root/<EDMO_code>/filename.txt
# where folder had to be <EDMO_code> and hence has to be renamed after downloading 
# from RSM where it is usually <sdn_user><EDMO_code><rest>
#
# filename is usually <prefix><LOCAL_CDI_ID><suffix>

# TODO parse and use meta-data csv added in later SDN releases

#import openearthtools.io.pyodv.pyodv as pyodv
import pyodv
import os, glob
import pandas, numpy
import logging

def odvroot2pandas(root):
   "odvroot2ids returns pandas dataframe with (EDMO_code,LOCAL_CDI_ID,filename,datetime,longitude,latitude) from data root"

   EDMO_code    = []
   LOCAL_CDI_ID = []
   filename     = []
   latitude     = []
   longitude    = []
   datetime     = []
  #datatype     = []
   
   folders = os.listdir(root)
   
   for folder in folders:
      files = glob.glob(os.path.join(root, folder, '*.txt'))
# TODO parse metadata csv
      for file in files:
          ODV = pyodv.Odv.fromfile(file) # handle case variations
          if "EDMO_code" in ODV.data.columns:
             edmo = str(int(ODV.data["EDMO_code"][0]))
          else:
             edmo = str(int(ODV.data["EDMO_CODE"][0]))
          
          if folder in edmo:
             print("OK    " +  file)
             
             if not(isinstance(ODV.data["LOCAL_CDI_ID"][0], basestring)): # transform LOCAL_CDI_ID to a string
                LOCAL_CDI_IDnum = ODV.data["LOCAL_CDI_ID"][0]
                LOCAL_CDI_IDstr = str(LOCAL_CDI_IDnum.astype(int))
                #logging.info(LOCAL_CDI_IDstr)
                LOCAL_CDI_ID.append(LOCAL_CDI_IDstr)
             else:
                LOCAL_CDI_ID.append(ODV.data["LOCAL_CDI_ID"][0])
             EDMO_code.append(edmo)
             basefilename = os.path.split(file)[1].split('.')[0]
             filename.append(basefilename)
             datetime.append( ODV.data[ODV.data.columns[3]][0])
             longitude.append(ODV.data[ODV.data.columns[4]][0])
             latitude.append( ODV.data[ODV.data.columns[5]][0])
# TODO add datatype
          else:
             print("ERROR    " +  file)
   
   return pandas.DataFrame({'EDMO_code':EDMO_code,'LOCAL_CDI_ID':LOCAL_CDI_ID,'filename':filename,'datetime':datetime,'longitude':longitude,'latitude':latitude})
   
def pandas2cache(F, cachename):
   "save pandas dataframe to json cache"

   F["datetime"] = [s.isoformat() for s in F["datetime"]] # ISO8601
   F.to_json(cachename)
   
def cache2pandas(cachename):
   "load json cache of odvroot2ids to pandas dataframe"

   F = pandas.read_json(cachename)

   # * Apparently pandas already parses ISO8601 code to datetime
   #   F["datetime"] = [dt.datetime.strptime(s,'%Y-%m-%dT%H:%M:%S') for s in F["datetime"]]
   # * However, pandas turns str EDMO_code into int
   
   F["EDMO_code"] = [str(v) for v in F["EDMO_code"]]

   return F

