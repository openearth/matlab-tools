__author__ = "Arnejan van Loenen"
import pydap.client as pdc
import pydap.cas.urs as pdcu
import configparser
import numpy as np
from pathlib import Path
import logging
from lxml import etree
from httplib2 import Http
from urllib.parse import urljoin, urlsplit

import datetime
import configparser
import os
import zipfile
import logging
import logging.handlers

ns1 = "http://www.unidata.ucar.edu/namespaces/thredds/InvCatalog/v1.0"
ns2 = "http://www.w3.org/1999/xlink"

class Dataset_Object:
    def __init__(self, top, bottom, left, right):
        """Initialize the grid object by providing it with the extent

        Keyword arguments:
        top, bottom, left, right -- integer coordinates in WGS85
        """
        try: 
            self.top=top
            self.bottom=bottom
            self.left=left
            self.right=right
			#calculate the grid extent as expressed in rows/columns of the total grid. Only valid for resolution 0.1
            self.grdleft=int((left+180)*10)
            self.grdright=int((right+180)*10)
            self.grdtop=int((top+90)*10)
            self.grdbottom=int((bottom+90)*10)
        except Exception as e:
            print('something went wront in init: ' + str(e))
            
    def GetDataset(self,url, username, password):
        """retrieve the dataset from the server

        Keyword arguments:
        url -- the url of the dataset
        username -- the username of the account to be used	
        password -- the password of the user account
        """
        try:
            session = pdcu.setup_session(username, password, check_url=url)
            dataset = pdc.open_url(url, session=session)
            var = dataset['precipitationCal']
			#this is where the data is actually downloaded
            self.grid=var[0,self.grdleft:self.grdright,self.grdbottom:self.grdtop]
            #collect file attributes
            self.NODATA_value=var.attributes['CodeMissingValue']
            self.fileattrs={}
			#store file attributes as list
            for item in dataset.attributes['HDF5_GLOBAL']['FileHeader'].split('\n'):
                if "=" in item:
                    self.fileattrs[item.split("=")[0]]=item.split("=")[1][:-1]
        except Exception as e: 
            print('something went wrong in func GetDataSet: ' + str(e))
    
    def WriteToAsc(self, toFolder, prefix):
        """write the grid is Arcinfo ASCII format

        Keyword arguments:
        toFolder: where the files should be stored 
        prefix -- prefix for the export file	
        """
        try:
            folderpath=Path(toFolder)
            file_name=self.fileattrs['FileName']
            outfile= prefix + '_'+ file_name.split('.')[4].split('-')[0]+file_name.split('.')[4].split('-')[1][1:]
			
            #make sure there is a temporary folder
            if not os.path.isdir('temp/'):
                os.makedirs('temp/')
			
            #start writing the ascii file
            with open('temp/'+ outfile +'.asc', "w") as f:
                    f.write('ncols ' + str(self.grdright-self.grdleft)+ "\n")
                    f.write('nrows ' + str(self.grdtop-self.grdbottom)+ "\n")
                    f.write('xllcorner ' + str(self.left)+ "\n")
                    f.write('yllcorner ' + str(self.bottom)+ "\n")
                    f.write('cellsize ' + str(0.1)+ "\n")
                    f.write('NODATA_value ' + str(self.NODATA_value)+ "\n")

                    x = np.array(self.grid[0][:])
                    #transport the grid, because somehow it is rotated...
                    grid_ts=x.transpose()

                    #write the lines of the ascii file
                    for line in reversed(grid_ts):
                        a_str = ' '.join(str(round(x,2)) for x in line)
                        f.write(a_str + "\n")
            
            #compress the ascii file
            with zipfile.ZipFile(f'{folderpath}{os.sep}'+ outfile+'.zip', 'w', zipfile.ZIP_DEFLATED) as file:
                file.write('temp/'+ outfile +'.asc', prefix + '_'+ file_name.split('.')[4].split('-')[0]+file_name.split('.')[4].split('-')[1][1:]+'.asc')
                os.remove('temp/'+ outfile+'.asc')
            
        except Exception as e: 
            print('something went wront while trying to write dataset: ' + str(e))
			
			


def crawl(catalog):
    """Grab all URLs from the THREDDS catalog."""
    resp, content = Http().request(catalog)
    #only loop through tree if the response is 200
    if resp.status == 200:
        xml = etree.fromstring(content)
        base = xml.find('.//{%s}service' % ns1)
        for dataset in xml.iterfind('.//{%s}access[@urlPath]' % ns1):
            url = '://'.join(urlsplit(catalog)[:2]) + base.attrib['base'] + dataset.attrib['urlPath']
            yield url
        for subdir in xml.iterfind('.//{%s}catalogRef' % ns1):
            url = urljoin(catalog, subdir.attrib['{%s}href' % ns2])
            for dataset in crawl(url):
                yield dataset

#------------------------------------------------------------------------------------------------------
#
# this is where the script actually starts
#
#------------------------------------------------------------------------------------------------------

#initialize logging component
logging.basicConfig(level=logging.INFO,format='%(asctime)s %(message)s')
handler = logging.handlers.RotatingFileHandler(filename='logging.txt', maxBytes=1000000, backupCount=1)

formatter = logging.Formatter('%(asctime)s %(message)s')  
handler.setFormatter(formatter)

#handler.setFormatter('%(asctime)s %(message)s')
handler.setLevel(logging.INFO)
logging.getLogger('').addHandler(handler)

logging.info('started')

current_time = datetime.datetime.now()

#read information from settings
config = configparser.ConfigParser()
config.sections()
config.read('settings.ini')

general=config['GENERAL']
nodatasets = int(general['nodatasets'])
username = general['user']    
password= general['password']

extent=config['EXTENT']
top= float(extent['top'])
bottom= float(extent['bottom'])
left= float(extent['left'])
right= float(extent['right'])

# loop through the configured datasets
for n in range(nodatasets):
    logging.info('starting with dataset '+str(n))
    dataset1=config['DATASET'+str(n)]
    currentfiles=[]
    listfile = 'filelist'+str(n)+'.txt'
	
    # first read filelist of previous run
    if os.path.exists(listfile):
        with open(listfile,"r") as f:
            currentfiles = [line.rstrip() for line in f]
    
    with open(listfile,"w") as f:
        #for every day in the searchperiod do	
        for iday in range(int(dataset1['days'])):
            search_date=current_time+datetime.timedelta(days=-iday)
            ndayofyear = str(search_date.strftime("%j"))
            nyear=str(search_date.strftime("%Y"))
            # collect the catalog for the specified day			
            dictlist = crawl(dataset1['url']+nyear+'/'+ndayofyear+'/catalog.xml')
            # for every URL in the returned catalog do:
            for ulr in dictlist:
                if not ulr[len(ulr)-4:len(ulr)] == '.xml':
                
                    # make a new list of the files already downloaded and still in search window
                    if ulr.strip() in currentfiles:
                        f.write(ulr.strip()+'\n')

                    # now loop through the new datasets
                    if ulr.strip() not in currentfiles:
                        try:
                            print('trying to retrieve '+ulr.strip())
                            logging.info('trying to retrieve '+ulr.strip())
                            # initialize new datagrid
                            a = Dataset_Object(top, bottom, left, right)
                            # retrieve the dataset from the server
                            a.GetDataset(ulr.strip(), username, password)
                            print('trying to write dataset')
                            logging.info('trying to write the dataset')
                            # now write the dataset as asci file
                            a.WriteToAsc(dataset1['tofolder'], dataset1['prefix'])
                            f.write(ulr.strip()+'\n')
                        except Exception as e:
                            print ('there was an error with '+ulr.strip() + "- " +str(e))
                            logging.error('there was an error with '+ulr.strip() + "- " +str(e))
                            continue
                            