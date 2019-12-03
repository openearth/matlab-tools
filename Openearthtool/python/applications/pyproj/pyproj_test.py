#PYPROJ_TEST  test for special treat in pyproj needed for Dutch coordinate system 29882

# $Id: pyproj_test.py 4658 2011-06-13 15:41:23Z boer_g $
# $Date: 2011-06-13 08:41:23 -0700 (Mon, 13 Jun 2011) $
# $Author: boer_g $
# $Revision: 4658 $
# $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/python/applications/pyproj/pyproj_test.py $
# $Keywords: $

# http://www.osgeo.org/ [part of PythonXY]
import osgeo.gdal
import osgeo.osr
import osgeo.ogr

# http://code.google.com/p/pyproj/ [not part of PythonXY]
import pyproj

OPT= {}
OPT['method'] = 1 # default: wrong
OPT['method'] = 2 # default: wrong
OPT['method'] = 3 # special treatment OPT['proj4']: correct
OPT['proj4']  = '+proj=sterea +lat_0=52.15616055555555 +lon_0=5.38763888888889 +k=0.999908 +x_0=155000 +y_0=463000 +ellps=bessel +units=m +towgs84=565.4174,50.3319,465.5542,-0.398957388243134,0.343987817378283,-1.87740163998045,4.0725 +no_defs'

## Van een kadaster Kernnetpunt
#  https://rdinfo.kadaster.nl/?inhoud=/rd/info.html%23publicatie&navig=/rd/nav_serverside.html%3Fscript%3D1
#  https://rdinfo.kadaster.nl/pics/publijst2.gif

D = {};
D['Puntnummer']        = '019111'
D['Actualiteitsdatum'] = 1999-06
D['Nr']                = 17
D['X']                 = 155897.26
D['Y']                 = 603783.39
D['H']                 = 3.7
D['NB']                = 53.+25./60+13.2124/3600
D['OL']                = 05.+24./60+02.5391/3600
D['h']                 = 44.83

# method 1: use pyproj epsg2proj4 tables
if OPT['method']==1:
 srs1 = pyproj.Proj(init='epsg:28992') # Dutch RD 
 print dir(srs1)
 print dir(srs1.srs)
 # >> THIS DOES NOT WORK DUE TO AN ERROR IN PROJ4 AND THE EPSG DATABASE (http://trac.osgeo.org/geotiff/ticket/22)
 # 53.4203367778 53.4214721299 -0.00113535209316
 # 5.40070530556 5.40113650762 -0.000431202062367
 # 155897.26 155868.618607 28.641393063 ERROR
 # 603783.39 603657.037483 126.352516692 ERROR
 # 155897.26 155897.26 -2.91038304567e-11
 # 603783.39 603783.39 2.67755240202e-09

# method 2: use osgeo epsg2proj4 tables (slightly different results)
if OPT['method']==2:
 srs_1 = osgeo.osr.SpatialReference()
 srs_1.ImportFromEPSG(28992)
 srs_1.ExportToProj4() # so do not use this to generate a proj4 string
 srs1 = pyproj.Proj(srs_1.ExportToProj4())
 # >> THIS DOES NOT WORK DUE TO THE SAME ISSUE 
 # 53.4203367778 53.4214721299 -0.00113535209316
 # 5.40070530556 5.40113650762 -0.000431202062365
 # 155897.26 155868.618607 28.6413930629
 # 603783.39 603657.037483 126.352516692
 # 155897.26 155897.26 -2.91038304567e-11
 # 603783.39 603783.39 2.67755240202e-09

#                  '+proj=sterea +lat_0=52.15616055555555 +lon_0=5.387638888888889 +k=0.9999079 +x_0=155000 +y_0=463000 +ellps=bessel +units=m +no_defs '
                 
# method 3: use nu tables: explicitly specy the ellipsoid
if OPT['method']==3:
 srs1 = pyproj.Proj(OPT['proj4'])
 # >> THIS FINALLY WORKS: explicitly specying the ellipsoid, a special case
 # 53.4203367778 53.4203352699 1.50790405229e-06
 # 5.40070530556 5.40070388119 1.42436669925e-06
 # 155897.26 155897.354786 -0.0947859991284
 # 603783.39 603783.558368 -0.168367567821
 # 155897.26 155897.260118 -0.00011813515448
 # 603783.39 603783.390523 -0.000523292343132

srs_2 = osgeo.osr.SpatialReference()
srs_2.ImportFromEPSG(4326)
print srs_2.ExportToProj4() # so do not use this to generate a proj4 string
srs2 = pyproj.Proj(init='epsg:4326') # wgs84

lon,lat  = pyproj.transform(srs1, srs2, D['X'] ,D['Y'] )
X  ,Y    = pyproj.transform(srs2, srs1, D['OL'],D['NB'])
X2 ,Y2   = pyproj.transform(srs2, srs1, lon    ,lat    ) # and back

# WGS84 and ETRS89 are not identical. WGS84 is < 1 m accurate
# The difference in 2004 is say 35 centimeter, see http://www.rdnap.nl/stelsels/stelsels.html
# So for testing less < 0.5 m error is OK.

print abs(X -D['X']) < 0.5 and abs(Y -D['Y']) < 0.5
print abs(X2-D['X']) < 0.5 and abs(Y2-D['Y']) < 0.5

# check projection onesided
print D['NB'], lat, D['NB'] - lat
print D['OL'], lon, D['OL'] - lon

# check projection onesided: ERROR for pyproj.Proj(init='epsg:28992')
print D['X'], X, D['X'] - X
print D['Y'], Y, D['Y'] - Y

# check projection twosided: internal consistency: OK
print D['X'], X2, D['X'] - X2
print D['Y'], Y2, D['Y'] - Y2

