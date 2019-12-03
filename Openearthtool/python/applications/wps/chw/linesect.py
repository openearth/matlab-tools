# -*- coding: utf-8 -*-
"""
Created on Wed Nov 18 13:59:52 2015

@author: fews
"""

# -*- coding: utf-8 -*-
"""
First Created on Thu Feb  5 13:25:03 2015
Linestring profile of wcs served  raster
@author: Maarten Pronk

TODO    Gdal reading from memory instead of reading file from temp.

Repository information:
Date of last commit:    $Date: 2015-10-22 15:49:16 +0200 (do, 22 okt 2015) $
Revision of last commi: $Revision: 1025 $
Author of last commit:  $Author: m.j.pronk@student.tudelft.nl $
URL of source:          $HeadURL: https://repos.deltares.nl/repos/FAST/datamanagement/tools/linesect.py $
CodeID:                 $ID$    

capabilities statement = http://localhost/cgi-bin/pywps.cgi?&service=wps&version=1.0.0&request=GetCapabilities
describe statement = http://localhost/cgi-bin/pywps.cgi?&service=wps&version=1.0.0&request=DescribeProcess&identifier=linesect
execute statment = http://localhost/cgi-bin/pywps.cgi?&service=wps&version=1.0.0&request=Execute&identifier=linesect&datainputs=[wktline=LINESTRING(-6.2827 36.5944, -6.2679 36.6038);crs=4326]
"""

# standard modules
import types
import json
# non standard modules
from StringIO import StringIO
import logging
from pywps.Process import WPSProcess
import getdata

class Process(WPSProcess):
    def __init__(self):
        WPSProcess.__init__(self,
            identifier = "linesect", # must be same, as filename
            title="Lineintersection",
            version = "0.1",
            storeSupported = "true",
            statusSupported = "true",
            abstract="Returns json dump of values of grid intersection with line.")
        self.wktline = self.addLiteralInput(identifier = "wktline",
                                            title = "WKT Line",
                                            type=types.StringType,
                                            default = 'LINESTRING(-6.2827 36.5944, -6.2679 36.6038)')

                                            #default="LINESTRING(-6.29574 36.49846, -6.22576 36.52938)")
        self.crs= self.addLiteralInput(identifier="crs",
                                           title="EPSG code",
                                           type=types.IntType,
                                          default=4326)

        self.json = self.addComplexOutput(identifier  = "values",
                                             title       = "List of values to create topography available for given transect",
                                             formats     = [{"mimeType":"text/plain"}])

        self.figureconfig = self.addComplexOutput(identifier  = "values2",
                                             title       = "List of values available for several layers on given transect",
                                             formats     = [{"mimeType":"text/plain"}])
#        self.json = self.addComplexOutput(identifier="json",
#                                          title="XYZ JSON",
#                                          formats=[{'mimeType':'text/plain',
#                                                      "encoding": "utf-8",}])
#        self.figureconfig = self.addComplexOutput(identifier="figureconfig ",
#                                        title="JSON x-axis title, unit and y1..yn axis title and unit",
#                                        formats=[{'mimeType':'text/plain',
#                                                  "encoding": "utf-8",}])
                                          
        #self.metadata = self.addLiteralOutput(identifier='metadata',
        #                                      title = 'Describes metadata address for layer used for elevation data')
    def execute(self):
        logging.info(''.join(['wktline ',self.wktline.getValue()]))
        logging.info(''.join(['crs     ','epsg: {}'.format(self.crs.getValue())]))
        awktline = self.wktline.getValue()
        acrs = self.crs.getValue()
        io,io2 = getdata.main(awktline,acrs,'chw')
#        io.close()
#        io2.close()
#        io.close()
#        return
        logging.info(io.getvalue())
        logging.info(io2.getvalue())
#        io_bool = False
#        if not io_bool:
#        self.json.setValue(io)
#            io.close()            
            #conf = figconfig()
            #self.figureconfig.setValue(conf)
            #self.metadata.setValue('http://www.iets')   moet metadata gaan bevatten
#            return
#        else:
#            logging.info('getlayerurl failed')
            #self.failed()
            #self.figureconfig()
#            return
#        self.chwlist.setValue(io2)
        self.figureconfig.setValue(io2)
        self.json.setValue(io)
#        io2.close()
#        logging.info("Hello")
#        io = StringIO()
#        io.write('test')
        io.close()
        io2.close()
        return
            
def figconfig():
    import json
    from StringIO import StringIO 
    conf = (('title','Profile'),
            ('x','distance from start','meter'),
            ('y1','surface elevation','meter'))
    #f = open(r"d:\temp\json.ini", "w")
    #json.dump(conf,f)
    #f.close()
    f = StringIO()
    json.dump(conf,f)
    return f