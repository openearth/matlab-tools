# read ODV file and store values in a DataFrame, and plot it

# $Id: pyodv.py 15605 2019-07-29 09:38:08Z hendrik_gt $
# $Date: 2019-07-29 02:38:08 -0700 (Mon, 29 Jul 2019) $
# $Author: hendrik_gt $
# $Revision: 15605 $
# $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/python/OpenEarthTools/openearthtools/io/pyodv/pyodv.py $
# $Keywords: $

# DEPENDENCIES: On MS-Windows install PythonXY and
# pip install: simplekml, mako,
# update: pandas

__version__ = "$Revision: 15605 $"

#  Copyright notice
#   --------------------------------------------------------------------
#   Copyright (C) 2014 Deltares for EMODnet Chemistry
#       Gerben J. de Boer / Giorgio Santinelli
#
#       gerben.deboer@deltares.nl / Giorgio.Santinelli@deltares.nl
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

# $Id: pyodv.py 15605 2019-07-29 09:38:08Z hendrik_gt $
# $Date: 2019-07-29 02:38:08 -0700 (Mon, 29 Jul 2019) $
# $Author: hendrik_gt $
# $Revision: 15605 $
# $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/python/OpenEarthTools/openearthtools/io/pyodv/pyodv.py $
# $Keywords: $

import os, sys
import numpy as np
import pandas # at least 0.13.1 needed from http://www.lfd.uci.edu/~gohlke/pythonlibs/#pandas, not PythonXY default 0.11.0
import json
import logging
from mako.template import Template # win32>> pip install mako
from mako.lookup   import TemplateLookup
import numpy, datetime
import odvdatetime

## ODV: for example see matlab odvread
#  TO DO: solve issue that reading a pandas frame is slow. perhaps cache the read file as binary file, and read that any subsequent time
#  TO DO: parse odv P01 and P06 meta-data and add to df: make odv class instead of odv dataframe
#  TO DO: turn meta-data into 1-row dataframes instead if lists
#  TO DO: let pandas parse time, and make sure mpl.plot_date() still works on it. Handle special time columns.
#  TO DO: parse special time columns time_ISO8601, overruling the standard 4th column for time that is only meta-data time
#  TO DO: parse P01 to get altLabel for plot annotation
#  TO DO: handle files where column name in not exactly (case-sensitive) EDMO_code, e.g. EDMO_CODE

## KML: for example see OET kmlgrainsize_vtv.py
#  TO DO: make seperate generic kmlscatter a la kmlscatter.m: put CDATA generation loop outside via function handle
#  TO DO: add keyword option not to include pop-up html: faster kml
#  TO DO: add kml_logo
#  TO DO: profiles  : add kml_column.
#  TO DO: timeseries: add png into pop-up, or dot with concentric circles, and crosshair or location (just as in InterReg DiPoL http://www.tuhh.de/iue/dipol/wkp-dipols-web-based-knowledge-platform/openearthgoogleearth.html)
#  TO DO: trajectory: add kml_line

class Odv(object):
    """Container object for information in ODV file: pandas data frame + meta-data for column names.
    For documentation see: https://publicwiki.deltares.nl/display/OET/pyodv
    """
        
    def __init__(self, **kwargs):
   
        self.data           = [] # pandas dataframe
        
        self.matrix         = ''
        self.data_type      = ''
        self.filename       = ''
        self.header         = [] # raw header lines
        self.time_column    = ''
        self.properties     = kwargs.get('properties', {})
        
        self.odv_column     = [] # "incl units, incl. spaces
        self.odv_name       = [] # odv_column = odv_name +  ' [' odv_units + ']'
        self.odv_units      = []
        self.sdn_code       = []
        self.sdn_name       = []
        self.sdn_units      = []
        self.sdn_units_code = []
        self.usecolindices  = []
        self.pandas_name    = [] # 3 flavours: [1:8] ODV column name, odd: P01, even: QV:P01 (P20 values)
    
    def __str__(self, **kwargs):
        """Serialize to ascii table
        """
        
        out = ''
        out += 'filename           | ' + str(self.filename) + '\n'
        out += 'matrix             | ' + self.matrix + '\n'
        out += 'data_type          | ' + self.data_type + '\n'

        #out += 'time begin:' + str(self.filename) + '\n'
        #out += 'time end:  ' + str(self.data[3]) + '\n'
        out += 'timeCoverage_min   | ' + str(min(self.data.as_matrix()[:,3])) + '\n' # works in char due to fixed format
        out += 'timeCoverage_max   | ' + str(max(self.data.as_matrix()[:,3])) + '\n'
        out += 'geospatial_lon_min | ' + str(min(self.data.as_matrix()[:,4])) + '\n'
        out += 'geospatial_lon_max | ' + str(max(self.data.as_matrix()[:,4])) + '\n'
        out += 'geospatial_lat_min | ' + str(min(self.data.as_matrix()[:,5])) + '\n'
        out += 'geospatial_lat_max | ' + str(max(self.data.as_matrix()[:,5])) + '\n'

        out += 'rows               | '       + str(len(self.data)) + '\n'
        out += 'cols               | '       + str(len(self.odv_name)) + ' with names: \n'
        out += '\n'
 # TO DO resolve P01        
        dout = "%3s | %26s | %18s | %14s \n" %  ('#','column name','SDN name','SDN units')
        out += dout
        dout = "%3s + %26s + %18s + %14s \n" %  ('---','--------------------------','------------------','------------->')
        out += dout
        for i,v in enumerate(self.odv_name):
            dout = "%0.3d | %26s | %18s | %14s \n" %  (i, str(self.pandas_name[i]),str(self.sdn_name[i]), str(self.sdn_units[i]))
            out += dout
        return out
        
    def meta2html(self, **kwargs):
        """Serialize to html
        """
        
        out = '<html>'
        out += '<body>'
        out += '<table width="100%" border="0" cellpadding="0" cellspacing="1">'
        out += '<tr><td>filename</td><td>'               + str(self.filename)                   + '</td></tr>'
        out += '<tr><td>matrix</td><td>'                 + str(self.matrix)                     + '</td></tr>'
        out += '<tr><td>data_type</td><td>'              + str(self.data_type)                  + '</td></tr>'
        out += '<tr><td>timeCoverage_min</td><td>'       + str(min(self.data.as_matrix()[:,3])) + '</td></tr>' # works in char due to fixed format
        out += '<tr><td>timeCoverage_max</td><td>'       + str(max(self.data.as_matrix()[:,3])) + '</td></tr>'
        out += '<tr><td>geospatial_lon_min</td><td>'     + str(min(self.data.as_matrix()[:,4])) + '</td></tr>'
        out += '<tr><td>geospatial_lon_max</td><td>'     + str(max(self.data.as_matrix()[:,4])) + '</td></tr>'
        out += '<tr><td>geospatial_lat_min</td><td>'     + str(min(self.data.as_matrix()[:,5])) + '</td></tr>'
        out += '<tr><td>geospatial_lat_max</td><td>'     + str(max(self.data.as_matrix()[:,5])) + '</td></tr>'
        out += '<tr><td>rows</td><td>'                   + str(len(self.data))                  + '</td></tr>'
        out += '<tr><td>cols</td><td>'                   + str(len(self.odv_name))              + ' with names: </td></tr>'
        
        dout = "<tr bgcolor='AAAAAA'><td>%3s </td><td> %18s </td><td> %14s </td><td> %30s </td></tr>" %  ('#','column name','SDN name','SDN units')
        out += dout
        for i,v in enumerate(self.odv_name):
           if i % 2 == 0:
               dout = "<tr                 ><td>%0.3d </td><td>%s</td><td>%s</td><td>%s</td></tr>" %  (i, str(self.pandas_name[i]),str(self.sdn_units[i]), str(self.odv_units[i]))
           else:
               dout = "<tr bgcolor='EEEEEE'><td>%0.3d </td><td>%s</td><td>%s</td><td>%s</td></tr>" %  (i, str(self.pandas_name[i]),str(self.sdn_units[i]), str(self.odv_units[i]))
           out += dout
        out += "</table>"
        out += '</body>'
        out += '</html>'
        return out
        
    def meta2json(self, **kwargs):
        """Serialize to json
        """
        
        out   = '{'
        
        out += '"column_name":{'
        for i,v in enumerate(self.pandas_name):
           dout = '"%d":"%s",' % (i, v)
           out += dout
        out = out[:-1] # remove final comma
        out += '},'
        
        out += '"sdn_name":{'
        for i,v in enumerate(self.sdn_name):
           dout = '"%d":"%s",' % (i, v)
           out += dout
        out = out[:-1] # remove final comma
        out += '},'
        
        out += '"sdn_units":{'
        for i,v in enumerate(self.sdn_units):
           dout = '"%d":"%s",' % (i, v)
           out += dout
        out = out[:-1] # remove final comma
        out += '},'        
        
        out += '}'
        
        return out

    def enrichedheader2columns(self):
        # parse semantic meta-data
        # changed with respect to previous header2columns by the introduction of enrichted ODV's
        # get local column names: last heaqder line
        odvcolumnnames = self.header[-1].split('\t')
        #print("h2c",odvcolumnnames)

        # loop column names (horizontal columsn in odv file ) 
        # and find accosiated semantic header line (vertical line in odv file)
        i = 0
        for col in odvcolumnnames:
            i = i + 1
            #print 'enrichedheader2columns',col
            self.odv_column.append(col) # incl units, excl. spaces
            self.odv_name.append(col.split(' [')[0])
            if len(col.split(' [')) ==2:
               self.odv_units.append(col.split(' [')[1].split(']')[0])
            else:
               self.odv_units.append('') # do not use None, as it does not print well in overviews
               
            self.sdn_code.append('')
            self.sdn_name.append('')
            self.sdn_units.append('')
            self.sdn_units_code.append('')
            self.pandas_name.append(col.replace(' ','_')) # keep column 1:8, and columns where SDN:LOCAL: does not match column name (wrong ODV file)
            
            for line in self.header:        
                if line.find('//<DataVariable>')>=0:
                   odv_name  = (line.split('label=')[1].split('value_type')[0]).strip().replace('"','') # gives odv_name without SDN:LOCAL !!!
                   try:
                       #if self.odv_name[-1] in odv_name:
                       if self.odv_name[-1] == odv_name.split(' [')[0]:                           
                          print('hc2t',self.odv_name[-1],odv_name)
                          self.sdn_name[-1]       = line.split('Codes:')[1].split('SDN:P06')[0].strip()
                          self.sdn_units[-1]      = line.split(self.sdn_name[-1])[1].split('</DataVariable>')[0].strip('"').strip('|').strip()
                          self.sdn_code[-1]       = self.sdn_name[-1].split(':')[3]
                          self.sdn_units_code[-1] = self.sdn_units[-1].split(':')[3]
                          self.usecolindices.append(i)
                          self.usecolindices.append(i+1)
                   except Exception:
                       if line.find('time_ISO8601') < 0:
                           print ('error occurred, last correct line')
                           print line

                if line.lower().find('//<datatype>')>=0:
                    self.data_type = line.lower().split('<datatype>')[1].split('</datatype>')[0]
                if line.lower().find('//<datafield>')>=0:
                    self.matrix = line.lower().split('<datafield>')[1].split('</datafield>')[0]

        # at last: turn sdn codes into pandas names  
        try:
            for i in range(11,len(self.pandas_name)-1,2):
                #print('h2c',i,self.sdn_code[i],self.pandas_name[i],self.odv_name[i])
                if len(self.sdn_code[i])==0:
                    self.pandas_name[i]    = 'column:' + str(i)
                    self.pandas_name[i+1]  = 'column:QV:' + str(i) # http://vocab.nerc.ac.uk/collection/L20/current/
                    if self.pandas_name[i+2]=='INFOS': self.pandas_name[i+2]  = 'INFOS:' + str(i)
                else:
                    self.pandas_name[i]    = self.sdn_code[i]
                    self.pandas_name[i+1]  = 'QV:' + self.sdn_code[i]
                    if self.pandas_name[i+2]=='INFOS': self.pandas_name[i+2]  = 'INFOS:' + str(i)
        except:
            print('after reading column ',i,' it went wrong')

    def header2columns(self):
        # parse semantic meta-data
    
        # get local column names: last heaqder line
        odvcolumnnames = self.header[-1].split('\t')

        # loop column names (horizontal columsn in odv file ) 
        # and find accosiated semantic header line (vertical line in odv file)
        for col in odvcolumnnames:
            self.odv_column.append(col) # incl units, excl. spaces
            self.odv_name.append(col.split(' [')[0])
            if len(col.split(' [')) ==2:
               self.odv_units.append(col.split(' [')[1].split(']')[0])
            else:
               self.odv_units.append('') # do not use None, as it does not print well in overviews
               
            self.sdn_code.append('')
            self.sdn_name.append('')
            self.sdn_units.append('')
            self.sdn_units_code.append('')
            self.pandas_name.append(col.replace(' ','_')) # keep column 1:8, and columns where SDN:LOCAL: does not match column name (wrong ODV file)
            
            for line in self.header:   
#                print line
                if line.find('//<subject>')>=0:
                   odv_name  = line.split('<subject>')[1].split('</subject>')[0] # still has SDN:LOCAL in it
               
                   if self.odv_name[-1] in odv_name:
                      self.sdn_name[-1]  = line.split('<object>')[1].split('</object>')[0]
                      self.sdn_units[-1] = line.split('<units>')[1].split('</units>')[0]
                      self.sdn_code[-1]       = self.sdn_name[-1].split(':')[3]
                      self.sdn_units_code[-1] = self.sdn_units[-1].split(':')[3]

                if line.lower().find('//<datatype>')>=0:
                    self.data_type = line.lower().split('<datatype>')[1].split('</datatype>')[0]
                if line.lower().find('//<datafield>')>=0:
                    self.matrix = line.lower().split('<datafield>')[1].split('</datafield>')[0]
                
        # at last: turn sdn codes into pandas names        
        for i in range(11,len(self.pandas_name)-1,2):
            if len(self.sdn_code[i])==0:
                self.pandas_name[i]    = 'column:' + str(i)
                self.pandas_name[i+1]  = 'column:QV:' + str(i) # http://vocab.nerc.ac.uk/collection/L20/current/
            else:
                self.pandas_name[i]    = self.sdn_code[i]
                self.pandas_name[i+1]  = 'QV:' + self.sdn_code[i]
    ## LOAD file or folder of ODV
    
    @staticmethod
    def fromfile(fn,enriched=True):
        """load 1 ODV file entirely into Odv object: dataframe + metadata fields for columns"""
        
        O = Odv()
        O.filename = fn
        
        if not os.path.isfile(fn):
            return "File not found: " + fn
            sys.exit(-1)
        
        try:
            f = open(fn,'rb')
            while True:
                l=f.readline()
                O.header.append(l)
                if l.find('//')==-1:
                    print 'finished reading semantic header'
                    break
        except IOError:
            sys.exit(-1)
        finally:
            print enriched
            if not enriched:
                O.header2columns()
            else:
                O.enrichedheader2columns()
            return f,O
            # parsing dates fails in mpl.plot_date()
            #O.data = pandas.read_csv(f,sep='\t',names=O.pandas_name,index_col=False) #, parse_dates=[3], infer_datetime_format=True, date_parser=odvdatetime)
            
            #O.data = pandas.read_csv(f,sep='\t',names=O.pandas_name,index_col=False, na_values=numpy.nan) #, parse_dates=[3], infer_datetime_format=True, date_parser=odvdatetime)
    
            #f.close()
            
        # handle sparse meta-data columns: populate them with duplicates
        # Metadata column header labels are mandatory and must be included EXACTLY as written
        # 1 - Cruise
        # 2 - Station
        # 3 - Type
        # 4 - yyyy-mm-ddThh:mm:ss.sss
        # 5 - Longitude [degrees_east]
        # 6 - Latitude [degrees_north]
        # 7 - LOCAL_CDI_ID
        # 8 - EDMO_code
        # 9 - Bot. Depth [m]
        #10 - Instrument Info
        #11 - P01 Codes
        # As metadata values are constant throughout a row_group it is usual practice just to populate the first row.
        # All times in SeaDataNet data files are presented as universal time (UT) and all positions are presented such that tools may assume the WGS84 CRS.
            
        # fill all NaN (float and float64 !!!) with previous good values            
                     
            for col in range(11):
               for row in range(1,len(O.data)): # skip 1st
                  val = O.data[O.data.columns[col]].get_value(row)
                  print val
                  print val
                  if not(type(val)==str):
                     if numpy.isnan(O.data[O.data.columns[col]].get_value(row)):
                        val0 = O.data[O.data.columns[col]].get_value(row-1)
                        O.data[O.data.columns[col]].set_value(row,val0)
                        
                                
        # handle fact that meta-data time column is not same as measurement time column
        
            O.time_column = 'yyyy-mm-ddThh:mm:ss.sss'
            for i,l in enumerate(O.odv_name):
              if l=='time_ISO8601' or l=='Chronological_Julian_Date':
                O.time_column = O.pandas_name[i] # 'time_ISO8601_[yyyy-mm-ddThh:mm]'
                break
                
        # data shape: row_groups
                
#            if len(np.unique(O.data[O.data.columns[4]]))==1 and len(np.unique(O.data[O.data.columns[5]]))==1:
#               if len(np.unique(O.data[O.time_column]))==1:
#                     O.data_type = 'profile'    # 1 (lat,lon), 1 time
#               else:
#                     O.data_type = 'timeseries' # 1 (lat,lon), N time
#            else:
#               if len(np.unique(O.data[O.time_column]))==1:
#                     O.data_type = 'shape'      # N (lat,lon), 1 time (not part of SeaDataNet library)
#               else:
#                     O.data_type = 'trajectory' # N (lat,lon), N time
                     
            return O
            
        return 

    def to_json(df, jsonfilename, *args):
        """serialize df to json ODV object into file on disk. You loose all meta-data.
         The paramName may contain spaces."""
         
        df.data.to_json(jsonfilename, orient='split')
        ## TO DO: use the buffer
        return jsonfilename


def showhlp():
    msg = """
    This routine imports ODV data and converts it something else: png, json or kml. 
    Tthe data is internally stored in an obect: Pandas DataFrame + meta data on columns.
    
    Version:
    - v0.1 1st phase --> reading ODV files and storing them in a Pandas Dataframe
    - v0.2 2nd phase --> reading ODV files and parsing semantic header
    
    Usage:
    - python pyODV.py odvfilename
    
    fn = r'../Yerseke/result_MON.WS.02260.193148.181-230211.txt'
    """
    #print msg
    return msg
    
#def odvs2df() too complex: need to check every column to be identical

def odvpar2df(url, paramName, *args):
    """load 1 column(parameter) from one ODV file entirely into Odv object: dataframe + metadata fields for columns"""
    
    if not os.path.isfile(url):
        cwd=os.getcwd()
        return "the current path is " + cwd
    else:
        O  = Odv.fromfile(url)
        O1 = Odv()
        #curwd=os.getcwd()
        
        # stores the file on the tmp folder
        # build the main df, with columns 0 to 9
        O1.data = O.data[O.data.columns[0:11]]

        paramName = paramName.replace(' ','_') # same as pandas does for all spaces.
        logging.info("odvpar2df: paramName = " + paramName)

        ## TODO handle case when paramName is not present in columns

        O1.data[paramName] = pandas.Series(O.data[paramName])
        
        # subset meta-data too: use list.index()
        index = []        
        for i,l in enumerate(O.pandas_name):
            if O.pandas_name[i] in paramName:
               index = i
               break
           
        O1.data_type      = O.data_type
        O1.filename       = O.filename
        O1.header         = O.header
        O1.time_column    = O.time_column
        O1.properties     = O.properties
        
        O1.odv_column     = [O.odv_column[i]     for i in range(11) + [index]]
        O1.odv_name       = [O.odv_name[i]       for i in range(11) + [index]]
        O1.odv_units      = [O.odv_units[i]      for i in range(11) + [index]]
        O1.sdn_code       = [O.sdn_code[i]       for i in range(11) + [index]]
        O1.sdn_name       = [O.sdn_name[i]       for i in range(11) + [index]]
        O1.sdn_units      = [O.sdn_units[i]      for i in range(11) + [index]]
        O1.sdn_units_code = [O.sdn_units_code[i] for i in range(11) + [index]]
        O1.pandas_name    = [O.pandas_name[i]    for i in range(11) + [index]]
        
        
        return O1
        
def odvspar2df(urls, paramName, *args):
    """load 1 column(parameter) from one ODV file/folder entirely into Odv object: dataframe + metadata fields for columns"""

    if urls[0] == '?':
        wpsMsg=showhlp()
        return wpsMsg
    else:
        if os.path.isfile(urls): # it's an odv file
            O1 = odvpar2df(urls, paramName, *args)
            return O1
        elif os.path.isdir(urls): # # it's a directory containing odv files
            files = os.listdir(urls)
            tmp = [] # list
            for file in files:
                if file.endswith('.txt'): # just pick the files that end with '.txt'
                    tmp.append(file)
            odvs = tmp
            # create the dataframe with all files
            for odv in odvs:
                O1=odvpar2df(urls + '/' + odv, paramName, *args)
                if not 'Oall' in locals():
                    Oall = O1
                else:
                    Oall.data = Oall.data.append(O1.data)
            # set the index to the dataframe
            Oall.data = Oall.data.set_index([range(Oall.data.shape[0])])
            return Oall
        else:
            return "The url is neither a file, nor a dir"        

## make JSON view

def odvpar2json(url, paramName, tempDir, *args):
    """serialize df to json ODV object into file on disk. You loose all meta-data.
     The paramName may contain spaces."""

    O1 = odvpar2df (url, paramName)
    jsonFilepath = tempDir + '/' + os.path.splitext(os.path.basename(url))[0] + "_" + paramName + ".json"
    df2json(O1 , jsonFilepath)
    return jsonFilepath

def odvspar2json(urls, paramName, tempDir, *args):
    "load 1 parameter from ODV file/folder to json ODV object into file on disk"

    if urls[0] == '?':
        wpsMsg=showhlp()
        return wpsMsg
    else:
        if os.path.isfile(urls): # it's an odv file
            dfSinglefile = odvpar2json(urls, paramName, tempDir, *args)
            return dfSinglefile
        elif os.path.isdir(urls): # # it's a directory containing odv files
            Oall = odvspar2df(urls, paramName, tempDir, *args)
            # create the json file with the information merged
            tempFilename    = tempDir + '/' + "all" + "_" + paramName + ".json"
            jsonAllFilepath = tempDir + '/' + "all" + "_" + paramName + ".json"
            Oall.data.data.to_json(jsonAllFilepath, orient='split') 
            return jsonAllFilepath
        else:
            return "The url is neither a file, nor a dir"

## make scatter view wrappers

def odvspar2kmlscatter(urls, paramName, tempDir, clims = [], *args):
    """save 1 parameter from ODV file/folder to kml scatter plot"""
    
    DFA       = odvspar2df(urls, paramName)
    
    paramName = paramName.replace(' ','_') # same as pandas does for all spaces.
    kmzFilepath = tempDir + '/' + os.path.splitext(os.path.basename(urls))[0] + '_' + paramName + '.kmz' # spaces already gone in paramName
    kml = jsonpar2kmlscatter(kmzFilepath,DFA,paramName,clims)
    return kml

def odvspar2pngscatter(urls, paramName, tempDir, clims = [], *args):
    """save 1 parameter from ODV file/folder to png scatter plot"""
    
    DFA       = odvspar2df(urls, paramName)
    
    paramName = paramName.replace(' ','_') # same as pandas does for all spaces.
    pngFilepath = tempDir + '/' + os.path.splitext(os.path.basename(urls))[0] + '_' + paramName + '.png' # spaces already gone in paramName
    kml = odv2map(pngFilepath,DFA,paramName,clims)
    return kml
