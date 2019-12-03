"""
This is the __init__ file for hydrotools.gis
Add imports to your new functions as follows:

# import functions in new_file.py in a new namespace as follows 
(preferred for a whole bunch of functions forming a separate subpackage):
import new_file
# now you can call a function new_fun in new_file.py as follows:
hydrotools.gis.new_file.new_fun

# import functions under the current namespace as follows (preferred for separate functions):
from new_file import *
# now you can call a function new_fun in new_file.py as follows:
hydrotools.gis.new_fun

$Id: __init__.py 13153 2017-01-30 11:27:44Z eilan_dk $
$Date: 2017-01-30 03:27:44 -0800 (Mon, 30 Jan 2017) $
$Author: eilan_dk $
$Revision: 13153 $
$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/python/applications/hydrotools/hydrotools/gis/__init__.py $
$Keywords: $

"""
from gdal_readmap import *
from gdal_writemap import *
from gdal_sample_points import gdal_sample_points
from dem_fill_dig import *
from basemap_setup import *
from dem_wavelet import *
from basemap_patch import *
from classify import *
from gdal_grid import *
from gdal_warp import *
from fiona_read_point import *
from ogr_burn import *
from pcraster_funcs import *