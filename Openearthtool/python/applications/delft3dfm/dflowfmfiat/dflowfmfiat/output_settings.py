import numpy as np
# Output settings for all produced tiff-files
################################################################################
lower_left = [ 0, 300000 ]    # lower-left corner
xres = 25.                    # resolution pixel size
yres = 25.
epsg = 28992
nptype = np.float64           # 8-byte floats
nodata = float(-9999.0)       # set the no-data value for the tiff
timeunit = 'hours'
################################################################################


