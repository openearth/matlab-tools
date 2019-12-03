# -*- coding: utf-8 -*-
"""
Created on Thu Dec 11 20:41:00 2014

@author: winsemi

$Id: basemap_setup.py 11457 2014-11-27 11:27:46Z winsemi $
$Date: 2014-11-27 12:27:46 +0100 (Thu, 27 Nov 2014) $
$Author: winsemi $
$Revision: 11457 $
$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/python/applications/hydrotools/hydrotools/gis/basemap_setup.py $
$Keywords: $

"""
import numpy as np  # package for array work
import matplotlib.pyplot as plt  # main plotting package
from mpl_toolkits.basemap import Basemap  # special package for plotting in geographical context
from matplotlib.collections import LineCollection  # collecting patches
import matplotlib.font_manager as font  # managing fonts within plots
from matplotlib import cm  # bunch of colormaps
from matplotlib import patches
from osgeo import ogr  # reading/writing geographical data
from hydrotools.gis import classify
# import classify  # home-made function to nicely color classify data

def get_rings(geom, ring_x, ring_y):
    pointsX = []; pointsY = [];
    nrpoints = geom.GetPointCount()
    if nrpoints > 0:
        for p in range(nrpoints):
            lon, lat, z = geom.GetPoint(p)
            pointsX.append(lon)
            pointsY.append(lat)
        # add the list of points to ring_x and ring_y
        ring_x.append(pointsX)
        ring_y.append(pointsY)
    else:
        # no points found, search deeper for rings
        numGeomInGeom = geom.GetGeometryCount()
        for n in range(numGeomInGeom):
            ring = geom.GetGeometryRef(n)
            ring_x, ring_y = get_rings(ring, ring_x, ring_y)
    return ring_x, ring_y

def basemap_patch(ax, m, shapefile, field_name, classes=np.arange(-10, 10),
                  cmap=cm.jet, extend=None, hatch=None, field_name_test=None,
                  test_criterion=0, test='>'):
    """
    Input:
        ax:                         plot axis in which to plot (typically made 
                                    with plt.subplot)
        m:                          Basemap handle (typically made with 
                                    basemap_setup)
        shapefile:                  path to shapefile with polygons
        field_name:                 field name in shapefile to use for 
                                    plotting. MUST contain numbers 
                                    (integer/float)
        classes=np.arange(-10,10):  classes to use for plotting. use the same 
                                    classes to make a colorbar
        cmap=cm.jet:                colormap used
        extend=None:                determines whether there are values below 
                                    the lowest or above highest value in 
                                    classes. Can be None, 'min', 'max', or 
                                    'both'
        hatch=None:                 determines whether a polygon should be 
                                    plotted with a hatch sign (e.g. '/'). This 
                                    is tested based upon field values and 
                                    typically used when a polygon value is 
                                    deemed unreliable or statistically 
                                    insignificant.
        field_name_test=None:       name of field in shapefile that is used to 
                                    test if a polygon should be hatched or not
        test_criterion=0:           Value to use for testing
        test='>':                   direction used for testing (can be '==', 
                                    '<', '>', '<=', '>='). If the test is True
                                    then the area is hatched.
        
    """
    driver = ogr.GetDriverByName('ESRI Shapefile')  # select the driver, in this case shapefile
    shp = driver.Open(shapefile, 1)  # file is now opened for reading!
    lyr = shp.GetLayer()  # get the geographical layer from the shapefile
    for i in range(lyr.GetFeatureCount()):
        feat = lyr.GetFeature(i)  # get the feature
        value = feat.GetField(field_name)  # get the value of the field
        if value is not None:
            field_color = classify.classify(value, classes, cmap, extend=extend)  # classify according to the defined classes
            if field_name_test is not None:
                test_value = feat.GetField(field_name_test)
                # test if test_value is <, <=, ==, >, >=
                hatch_sign = None
                exec('if test_value {:s} test_criterion: hatch_sign = hatch'.format(test))
            #print(message_template).format(float(i)/lyr.GetFeatureCount()*100)
            geom = feat.GetGeometryRef()  # get the geometry
            ring_x = []; ring_y = []
            # get all ringed geometries from feature and append to a linecollection
            ring_x, ring_y = get_rings(geom, ring_x, ring_y)
            for X, Y in zip(ring_x, ring_y):
                data = np.array(m(X, Y)).T
                lines = LineCollection([data,], antialiaseds=(1,))
                lines.set_facecolors(field_color)
                lines.set_edgecolors('k')
                lines.set_hatch(hatch_sign)
                lines.set_linewidth(0.1)
                # plot the line collection in the geographical axis
                ax.add_collection(lines)
# add a nice legend!

