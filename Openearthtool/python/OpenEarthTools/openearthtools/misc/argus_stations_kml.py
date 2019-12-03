# -*- coding: utf-8 -*-
"""
Created on Sat Oct 11 17:26:13 2014

$Id: argus_stations_kml.py 11206 2014-10-11 20:20:02Z heijer $
$Date: 2014-10-11 13:20:02 -0700 (Sat, 11 Oct 2014) $
$Author: heijer $
$Revision: 11206 $
$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/python/OpenEarthTools/openearthtools/misc/argus_stations_kml.py $

@author: heijer
"""

import urllib2
import simplejson
from osgeo.osr import SpatialReference, CoordinateTransformation
import simplekml
from mako.template import Template

class Api():
    def __init__(self):
        self.baseurl = 'http://argus-public.deltares.nl/db/table/'
        self.siteinfo = self.get_siteinfo()
    def loadurl(self, path=''):
        response = urllib2.urlopen(self.baseurl + path)
        return simplejson.loads(response.read())
    def get_siteinfo(self):
        return self.loadurl(path='site')
    def get_sitecoords(self, info):
        if info['lon'] != 0 and info['lat'] != 0:
            return info['lon'],info['lat']
        elif info['coordinateOrigin'] != None:
            x,y,z = info['coordinateOrigin'][0]
            epsg = info['coordinateEPSG']
            lon,lat = self.convertcoords(x,y,epsg=epsg)
            return lon,lat
        else:
            print 'coordinates unknown for station %s'%info['name']
    def convertcoords(self, x, y, epsg=28992):
        """
        convert x,y (in RD new) to lon,lat (in WGS84)
        """
        #Define the Rijksdriehoek projection system (EPSG 28992)
        crs0 = SpatialReference()
        crs0.ImportFromEPSG(epsg)
        if epsg == 28992:
            crs0.SetTOWGS84(565.237,50.0087,465.658,-0.406857,0.350733,-1.87035,4.0812)
        epsg4326 = SpatialReference()
        epsg4326.ImportFromEPSG(4326)
        crs02latlon = CoordinateTransformation(crs0, epsg4326)
        lonlatz = crs02latlon.TransformPoint(x,y,0)
        lon,lat,_ = lonlatz
        return lon,lat

    def makekml(self):
        kml = simplekml.Kml(name="ARGUS stations")
        camera = simplekml.Camera(latitude=52, longitude=4, altitude=4e5, roll=0, tilt=0,
                          altitudemode=simplekml.AltitudeMode.relativetoground)
        kml.document.camera = camera
        for station in self.siteinfo:
            coords = self.get_sitecoords(station)
            if coords == None:
                continue
            template = Template("""<![CDATA[
<table style="width:100%">
% for key in keys:
<tr>
  <td>${key}</td>
  <td>${data[key]}</td> 
</tr>
% endfor
</table>
]]>""")
            keys = ['name', 'owner', 'siteID']
            description = template.render(data=station, keys=keys)
            kml.newpoint(name=station['name'],
                      description=description,
                      coords=[coords])
        kml.save(__file__.replace('_kml.py', '.kml'))
        

if __name__ == '__main__':
    Argus = Api()
    Argus.makekml()