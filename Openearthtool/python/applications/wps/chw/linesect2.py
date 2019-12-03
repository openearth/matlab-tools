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
describe statement = http://localhost/cgi-bin/pywps.cgi?&service=wps&version=1.0.0&request=DescribeProcess&identifier=linesect2
execute statment = http://localhost/cgi-bin/pywps.cgi?&service=wps&version=1.0.0&request=Execute&identifier=linesect2&datainputs=[wktline=LINESTRING(-6.2827 36.5944, -6.2679 36.6038);crs=4326]
"""

# standard modules
import types
import json
# non standard modules
from StringIO import StringIO
import logging
from pywps.Process import WPSProcess
import getopendata

class Process(WPSProcess):
    def __init__(self):
        WPSProcess.__init__(self,
            identifier = "linesect2", # must be same, as filename
            title="Lineintersection",
            version = "0.1",
            storeSupported = "true",
            statusSupported = "true",
            abstract="""Returns json dump of values of grid intersection with line for various global datasets. These are:
- Global lithology map (GLiM)
- Global elevetion map (SRTM4.1, 90 m)
- Globcover (MERIS data)
- Global mangrove map (GIRI2011)
- Global map with coralreefs
- DIVA points surge
- DIVA points cyclones
- DIVA points wave exposure
- Tidal climate
                        """)
        self.wktline = self.addLiteralInput(identifier = "wktline",
                                            title = "WKT Line",
                                            type=types.StringType,
                                            default = 'LINESTRING(-6.2827 36.5944, -6.2679 36.6038)')

                                            #default="LINESTRING(-6.29574 36.49846, -6.22576 36.52938)")
        self.crs= self.addLiteralInput(identifier="crs",
                                           title="EPSG code",
                                           type=types.IntType,
                                          default=4326)
#        self.json = self.addComplexOutput(identifier  = "values",
#                                             title       = "List of values to create topography available for given transect",
#                                             formats     = [{"mimeType":"text/plain"}])
##                                             
        self.json_veg = self.addComplexOutput(identifier  = "values vegetation",
                                             title       = "Globcover classes for given transect",
                                             formats     = [{"mimeType":"text/plain"}])
        self.json_elev = self.addComplexOutput(identifier  = "values elevation",
                                             title       = "Topography for given transect",
                                             formats     = [{"mimeType":"text/plain"}])
        self.json_geol = self.addComplexOutput(identifier  = "values geology",
                                             title       = "Lithology classes for given transect",
                                             formats     = [{"mimeType":"text/plain"}])
        self.json_surge = self.addComplexOutput(identifier  = "values surge",
                                             title       = "Surge around transect (based on value for diva  point)",
                                             formats     = [{"mimeType":"text/plain"}])
        self.json_coralreef = self.addComplexOutput(identifier  = "values coralreef",
                                             title       = "Transect crosses coralreef",
                                             formats     = [{"mimeType":"text/plain"}])
        self.json_wave =self.addComplexOutput(identifier  = "values wave",
                                             title       = "Wave type around transect (based on value for diva point)",
                                             formats     = [{"mimeType":"text/plain"}])
        self.json_mangrove =self.addComplexOutput(identifier  = "values mangrove",
                                             title       = "Transect crosses mangrove",
                                             formats     = [{"mimeType":"text/plain"}])
        self.json_cyclone =self.addComplexOutput(identifier  = "values cyclone",
                                             title       = "Cyclone climate around transect (based on point)",
                                             formats     = [{"mimeType":"text/plain"}])
        self.json_tidal= self.addComplexOutput(identifier  = "values tidal",
                                             title       = "Tidal data around transect (based on point)",
                                             formats     = [{"mimeType":"text/plain"}])
#        self.figureconfig = self.addComplexOutput(identifier  = "values2",
#                                             title       = "List of values available for several layers on given transect",
#                                             formats     = [{"mimeType":"text/plain"}])
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
#        io = getopendata.main(awktline,acrs,'chw')
#        logging.info(io.getvalue())
#        self.json.setValue(io)
#        io.close()
        io_veg,io_elev,io_geol,io_surge,io_coralreef,io_wave,io_mangrove,io_cyclone,io_tidal = getopendata.main(awktline,acrs)
        self.json_veg.setValue(io_veg)
        self.json_elev.setValue(io_elev)
        self.json_geol.setValue(io_geol)
        self.json_surge.setValue(io_surge)
        self.json_coralreef.setValue(io_coralreef)
        self.json_wave.setValue(io_wave)
        self.json_mangrove.setValue(io_mangrove)
        self.json_cyclone.setValue(io_cyclone)
        self.json_tidal.setValue(io_tidal)
        io_veg.close()
        io_elev.close()
        io_geol.close()
        io_surge.close()
        io_coralreef.close()
        io_wave.close()
        io_mangrove.close()
        io_cyclone.close()
        io_tidal.close()
        return