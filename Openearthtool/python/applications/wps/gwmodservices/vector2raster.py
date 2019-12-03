# -*- coding: utf-8 -*-
# -*- coding: utf-8 -*-
#  Copyright notice
#   --------------------------------------------------------------------
#   Copyright (C) 2017 Deltares for Three clicks to a ground watermodel
#   Gerrit Hendriksen@deltares.nl
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

# $Id: orm_subsurface.py 13354 2017-05-16 12:45:29Z hendrik_gt $
# $Date: 2017-05-16 14:45:29 +0200 (Tue, 16 May 2017) $
# $Author: hendrik_gt $
# $Revision: 13354 $
# $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/python/applications/datamodel/subsurface/orm_subsurface.py $
# $Keywords: $

import os
import sys

import subprocess

#-of netCDF hieronder zou dan vervangen moeten worden door –of AAIGRID (van ArcInfo Ascii GRID)



def gdalrasterize(af,field,cs,xmin,xmax,ymin,ymax):
    anc = af.replace('.shp', '.tif')
    lyr = os.path.basename(af.replace('.shp',''))
    args = ['gdal_rasterize','-a','{f}'.format(f=field), '-of', 'GTIFF', 
            '-tr',str(cs),str(cs), '-te',str(xmin),str(ymin),str(xmax),str(ymax),
            '-l','{l}'.format(l=lyr), af, anc]
    try:
        subprocess.call(args)
        print ' '.join(['rasterisation of ',af,'started'])
        if os.path.isfile(anc):
            print(' '.join([anc,'created']))
            return anc
        else:
            print(' '.join([anc,'not created']))
            return None
        # return anc
    except BaseException as err:
        print err.args
        print 'Please check:'
        print '  if gdalrasterize is in path environment'
        print 'Status of:'
        print '  ',af,'exists =',os.path.isfile(af)
        print 'Complete list of arguments'
        print subprocess.list2cmdline(args)
        sys.exit()

        #os.system('gdal_rasterize' '-a shape_leng' '-tr 1.0 1.0' '-l' 'glim_v01_export D:/data/india3/glim_v01_export.shp' 'D:/data/iranrasterised2.tif')
        #'gdal_rasterize' '-a shape_leng' '-tr 1.0 1.0' '-l' 'glim_v01_export D:/data/india3/glim_v01_export.shp' 'D:/data/iranrasterised2.tif'

def showhelp():
    msg="""
    Created on December 13th of 2016
    necessary input     
    # 1. shapefile to be rasterized
    # 2. fieldname
    # 3. cellsize
    # 4,5,6,7. xmin,xmax,ymin,ymax
    
    example
    python vector2raster7december.py path\india.shp 0.5 75 23 76 24
    """
    print(msg)

if __name__ == '__main__':
    """handling arguments
    # 1. getting help
    # 1. shapefile to be rasterized
    # 2. fieldname
    # 3. cellsize
    # 4,5,6,7. xmin,xmax,ymin,ymax
    """
    print ' '
    print '# input information'

    if sys.argv[1] == '?':
        showhelp()
        sys.exit()

    if not os.path.isfile(sys.argv[1]):
        print sys.argv[1],'is not a file'
        sys.exit()
    else:
        af = sys.argv[1]
        
    field = sys.argv[2]
    cs = sys.argv[3]
    xmin,ymin,xmax,ymax = sys.argv[4],sys.argv[5],sys.argv[6],sys.argv[7]
    
    """ONLY FOR TESTING"""
    #af = r"C:\data\temp\india21\glhympsPolygon.shp"
    #field = 'porosity'
    #cs = 0.5
    #xmin,ymin,xmax,ymax = 75, 23, 76, 24
    """ONLY FOR TESTING"""
    print(af)
    print(field)
    print(str(cs))
    print(xmin,ymin,xmax,ymax)

#    af = r'D:\temp\ganga\test\india.shp'
#    field = 'porosity'
#    cs = 0.5
#    xmin,xmax,ymin,ymax =  75,23,76,24
    atif = gdalrasterize(af,field,cs,xmin,xmax,ymin,ymax)
    print atif
    
    
    