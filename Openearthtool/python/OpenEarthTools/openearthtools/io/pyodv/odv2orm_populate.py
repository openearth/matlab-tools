"""
Populate RDBMS with odvfile collection
"""
#  Copyright notice
#   --------------------------------------------------------------------
#   Copyright (C) 2014 Deltares for EMODnet Chemistry
#       Gerben J. de Boer
#
#       gerben.deboer@deltares.nl
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

# $Id: odv2orm_initialize.py 10887 2014-06-24 09:38:44Z boer_g $
# $Date: 2014-06-24 11:38:44 +0200 (Tue, 24 Jun 2014) $
# $Author: boer_g $
# $Revision: 10887 $
# $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/python/OpenEarthTools/openearthtools/io/pyodv/odv2orm_initialize.py $
# $Keywords: $


""" for older versions of postgresql it is necessary to add sequences manually
create sequence cdi_id_seq
alter table cdi alter column id set default nextval('cdi_id_seq')

create sequence odvfile_id_seq
alter table odvfile alter column id DEFAULT nextval('odvfile_id_seq'::regclass)

"""

   
import hashlib
#http://stackoverflow.com/questions/3431825/generating-a-md5-checksum-of-a-file
from odv2orm_model import *
import odvdir, pyodv, glob
import datetime, odvdatetime, pandas, numpy,os
import re
from sqlalchemy import create_engine
   
    
## add unique edmo
def populateEDMO(F):
    print("Adding unique EDMO_code")
    for val in numpy.unique(F.data["EDMO_code"]):
        exist = session.query(Edmo).filter_by(code=val).first()
        # TODO combine this with a list of EDMO regions, for now this is the dummy institute
        if exist==None:
            element = Edmo(code=val,name='GreenWich Dummy Institute',
                           geom = 'srid=4326;POINT('+str(0)+' '+ str(51.48)+')') # GreenWich for testing purposes
            session.add(element)
        session.commit()

## add unique odv files
# returns the ID that belongs to this ODV File (is most safest way I think)
# TODO in stead of a file for each CDI the enriched ODV's host several cdi's per file
# TODO, first add a ODV file and connect to each cdi that particular id
def populateODVfile(filename):
    session.rollback()
    FileName         = os.path.basename(filename) # excl. path
    FileSize         = os.stat(filename).st_size
    FileLastModified = datetime.datetime.utcfromtimestamp(os.stat(filename).st_mtime)
    Sha256Hash       = hashfile(filename)
    # check unique constraints
    exist1           = session.query(Odvfile).filter_by(name=FileName).first()
    exist2           = session.query(Odvfile).filter_by(sha256hash=Sha256Hash).first()
    rid              = False
    if exist1==None and exist2==None:
        try:
            element = Odvfile(name=FileName,
                          sha256hash=Sha256Hash,
                          lastmodified=FileLastModified,
                          size=FileSize)
            session.add(element)
            session.commit()
            rid = element.id
        except:
            print('Error inserting (despite name and sha256hash being unique) %s%s' % (filename, exist1.id))
    else:
        if exist1 != None:
            rid = exist1.id
        else:
            rid = exist2.id
        msg = ''.join(['Message: ODVfile %s' % filename,'already present, id %s' % rid, ' returned'])
        print msg
    #get the id of this instance and return it
    return rid
       
## add unique cdi
#TODO make this faster, by using something like the listmethod described below
def populateCDI(F,fid):
    print("Adding unique LOCAL_CDI_ID")   # takes a long time for enriched ODV file
    for i in range(len(F.data["LOCAL_CDI_ID"])):
        edmo = is_int(F.data["EDMO_code"][i])
        localcdi = is_int(F.data["LOCAL_CDI_ID"][i])
        #cdi = str(Odv.data["EDMO_code"][i]) + ':' + str(Odv.data["LOCAL_CDI_ID"][i])
        cdi = ':'.join([edmo,localcdi])
        #cdi = str(F.data["EDMO_code"][i]) + ':' + str(F.data["LOCAL_CDI_ID"][i])
        lon = F.data['Longitude_[degrees_east]'][i]
        if lon > 180:
            lon = lon - 360
        exist = session.query(Cdi).filter_by(cdi=cdi).first()
        if exist==None:
            element = Cdi(cdi=cdi,
                          local_cdi_id=is_int(F.data["LOCAL_CDI_ID"][i]),
                          edmo_code=is_int(F.data["EDMO_code"][i]),
                          geom     = 'srid=4326;POINT('+str(lon)+' '+str(F.data['Latitude_[degrees_north]'][i])+')', 
                          datetime = odvdatetime.iso2datetime(F.data['yyyy-mm-ddThh:mm:ss.sss'][i]), 
                          datatype_id='u',
                          odvfile_id=str(fid))
            session.add(element)
        session.commit()

"""if the above results in 1 point then store the elements in a list and try session.add_all(list):
   otherwise perform a bulk operation with pandas and psycopg2
   
http://docs.sqlalchemy.org/en/latest/core/tutorial.html#executing-multiple-statements   
stmt = users.insert().\
...         values(name=bindparam('_name') + " .. name")
>>> conn.execute(stmt, [               
...        {'id':4, '_name':'name1'},
...        {'id':5, '_name':'name2'},
...        {'id':6, '_name':'name3'},
...     ])   
   
"""

#bulk = []
#for i in range(len(F.data["LOCAL_CDI_ID"])):
#    cdi = str(F.data["EDMO_code"][i]) + ':' + F.data["LOCAL_CDI_ID"][i]
#    lon = F.data['Longitude_[degrees_east]'][i]
#    if lon > 180:
#        lon = lon - 360
#    #exist = session.query(Cdi).filter_by(cdi=cdi).first()
#    #if exist==None:
#    bulk.append({'cdi'         :cdi,
#                  'local_cdi_id':F.data["LOCAL_CDI_ID"][i],
#                  'edmo_code'   :F.data["EDMO_code"][i],
#                  'geom'        :'srid=4326;POINT('+str(lon)+' '+str(F.data['Latitude_[degrees_north]'][i])+')', 
#                  'datetime'    :odvdatetime.iso2datetime(F.data['yyyy-mm-ddThh:mm:ss.sss'][i]), 
#                  'datatype_id' :'u',
#                  'odvfile_id'  :str(fid)})
                                    
        
## add data
        
#TODO due to the fact that there are also new files (enriched) there should be a new method
# to ensure that it will work        

#Odv = pyodv.Odv.fromfile(filename)

# TODO handle non-float columns, e.g. ISO time
# TODO handle cases where pandas yield a column with width=2???
# TODO handle exist to replace old data
# TODO handle cdi datatype


'''ok todo:
    - alter table observations, change p01 to identifier
    - alter table observations add column type !! so p01 or p35
    - create populate observations function to import timeseries
    - in both the functions to import data into observation table there should be
    a procedure implemented to get information on the type (p01 or p35)
'''

def is_int(s):
    try:
        if int(s):
            return str(int(s))
        if float(s):
            return str(int(s))
    except ValueError:
        return s

def populateODVprofiles(Odv,fid,enriched=False):
    print("Adding data")
    session.rollback()
    if enriched:
        skipcols = 62
    else:
        skipcols = 8
    
    for i in range(len(Odv.data["LOCAL_CDI_ID"])):
        edmo = is_int(Odv.data["EDMO_code"][i])
        localcdi = is_int(Odv.data["LOCAL_CDI_ID"][i])
        #cdi = str(Odv.data["EDMO_code"][i]) + ':' + str(Odv.data["LOCAL_CDI_ID"][i])
        cdi = ':'.join([edmo,localcdi])
        row = i
        #filename = os.path.join(dataDir,F.data["EDMO_code"][i]
        #,F.data["filename"][i] + '.txt') # incl. path
        
        #FileName = os.path.basename(filename) # excl. path
        #odvfile  = session.query(Odvfile).filter_by(name=FileName)
        FileName = session.query(Odvfile).filter_by(id=fid).first().name
        print('PROGRESS files: ' + str(i)+ '/' + str(len(Odv.data["EDMO_code"])) + ': '+ FileName)
            
        if FileName == None:
            print('WARNING: odvfile not in database: %s' % FileName)            
        else:        
            times  = Odv.data[Odv.time_column].as_matrix() # not do not use c olcumn 3 here, those are meta-data times
            lons   = Odv.data['Longitude_[degrees_east]'].as_matrix()
            lats   = Odv.data['Latitude_[degrees_north]'].as_matrix()
            depths = Odv.data[Odv.data.columns[76]].as_matrix()
            Odv.z_column = Odv.data.columns[skipcols]
            if Odv.z_column in Odv.data.columns: # cannot check for len() for None
                z        = Odv.data[Odv.z_column].as_matrix()
                z_column = Odv.z_column
            else:
                z        = [numpy.nan] * len(Odv.data)
                z_column = ''
               
            ncol = (len(Odv.data.columns)-skipcols)/2
            for col in range(skipcols,len(Odv.data.columns),2): # skip 8 meta-data columns, leapfrog odd flag columns
            #for col in range(skipcols,64,2):
                print('progress columns: ' + str(int((col-skipcols)/2)) + '/'+ str(int(ncol)) + ': ' + Odv.sdn_code[col])
                exist = session.query(P01).filter_by(identifier=Odv.sdn_code[col]).first()
                if exist==None:    
                    print('WARNING: column skipped code="' + Odv.sdn_code[col] + '": not in P01')
                else:
                    values = Odv.data[Odv.data.columns[col  ]].as_matrix()
                    flags  = Odv.data[Odv.data.columns[col+1]].as_matrix()
                    
                    if len(values) !=0:  # sometimes pandes make a column with width=2???
                        if Odv.sdn_code[col]=='DTUT8601':
                            # TODO handle non-float values in addition to time
                            print('WARNING: column skipped code="DTUT8601": not a float')
                        else:
                            #for row in range(len(Odv.data)): because this is one large file, i in stead of again i (row) should do the trick
                            
                            #TODO ref naar cdi                            
                            #TODO how necessary is it to have 2 times depth                            
                            if str(flags[row]) != 'nan':
                                flgid=str(int(flags[row]))           # candidate key
                            else:
                                flgid = 'A'
                            
                            adate = times[row]
                            try:
                                y,m,d,hh,mm,ss = re.split(' |-|T|:',str(odvdatetime.iso2datetime(adate)))
                            except Exception:
                                break
                            
                            adate = datetime.datetime(int(y),int(m),int(d),int(hh),int(mm), int(ss))
                            
                            lon = lons[row]
                            if lon > 180:
                                lon = lons[row]-360
                            element = Observation(
                            value         = float(values[row]), 
                            geom          = 'srid=4326;POINT('+str(lon)+' '+str(lats[row])+')', 
                            datetime      = str(times[row]),           # already datetime, SQL can't handle datetime64
                            #depth         = float(depths[row]),        # depth is total depth < z, ...
                            #z             = float(z[row]),             # whereas  z is vertical position of sample
                            z_id          = 'ADEPZZ01',                 # Odv.sdn_code[62], ADEPZZ01/PRESPS01/COREDIST/?
                            p01_id        = Odv.sdn_code[col],         # candidate key
                            p06_id        = Odv.sdn_units_code[col].strip('"'),   # candidate key
                            flag_id       = flgid,
                            cdi_id        = cdi,                       # candidate key
                            odvfile_id    = str(fid))       # technical key
                            session.add(element)
                    else:
                        print 'no values added'
                session.commit() # commit in chunks per column


def hashfile(fname, blocksize=65536):
    hasher = hashlib.sha256()  
    f = open(fname, 'rb')
    buf = f.read(blocksize)
    while len(buf) > 0:
        hasher.update(buf)
        buf = f.read(blocksize)
    return hasher.digest()


if __name__ == '__main__':
    """handling arguments
    """

    ## Connect to the DB
    f = open('C:\pywps_processes\pyodv\odvconnection.txt')
    engine = create_engine(f.read(), echo=False) # echo=True is very slow
    f.close()
    
    ## Declare a Mapping
    
    ## Create a Session
    from sqlalchemy.orm import sessionmaker
    Session = sessionmaker(bind=engine)
    
    session = Session()
    session.rollback()
    
    
    
    # TODO check if database already exists
    #Base.metadata.drop_all(engine)
    #Base.metadata.create_all(engine)
    
    #TODO after creation of new database, also initial filling of vocabs is necessary
    
    
    """ following code is obsolete, don't know the function of this caching, beside the fact that it generates erros
    dataDir = r'C:\pywps_processes\data'
    #dataDir = r'c:\pywps\pywps_processes\data_test'
    #dataDir = r'd:\checkouts\OpenEarthRawData\SeaDataNet'
    # cachename = dataDir + 'cache' obsolete, is overwritten by next statement
    cachename = os.path.join(dataDir, 'cache.json')
    
    ## make cdi (EDMO_code,LOCAL_CDI_ID) inventory, annd cache it
    print("Listing Odvfiles")
    if os.path.isfile(cachename):
        F = odvdir.cache2pandas(cachename)
    else:
        F = odvdir.odvroot2pandas(dataDir)
        odvdir.pandas2cache(F,cachename)"""
    
    root = r'C:\pywps_processes\data'
    folders = os.listdir(root)
    
    #file = r'C:\pywps_processes\data\buffer\data_from_ocean_depth_profiles.txt'
    
    for folder in folders:
        files = glob.glob(os.path.join(root, folder, '*.txt'))
        for file in files:
            try:
                print 'reading',file
                ODV = pyodv.Odv.fromfile(file)
                populateEDMO(ODV)
                fid = populateODVfile(file)
                fid = session.query(Odvfile).filter_by(name=os.path.basename(file)).first().id
                populateCDI(ODV,fid)
                populateODVprofiles(ODV,fid,True)
                print str(np.unique(ODV.data['EDMO_code'])),' added to the database'
            except IOError:
                sys.exit(-1)
            finally:
                print 'moet nog wat komen, of niet' 
        session.close()