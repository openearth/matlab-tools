"""
Created on Thu Nov 27 12:24:58 2014

@author: Hessel Winsemius

$Id: dem_wavelet.py 11457 2014-11-27 11:27:46Z winsemi $
$Date: 2014-11-27 12:27:46 +0100 (Thu, 27 Nov 2014) $
$Author: winsemi $
$Revision: 11457 $
$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/python/applications/hydrotools/hydrotools/gis/dem_wavelet.py $
$Keywords: $

This tool is part of the hydrotools toolbox in the openearthtools suite.

"""

import pywt
import numpy as np
import pdb
#file = 'Bangkok_cut.tif'
#filter_name='bior6.8'
# find misses and fill with a zero

# max. level of waveforms
#levels = int(np.floor(np.log2(zi2.shape[0])))

def dem_wavelet(dem, filter_name='bior6.8', filter_weight=10, xBlockSize=1000,
                yBlockSize=1000):
    """
    Wavelet filtering of a DEM. Rather than filtering in the normal domain
    with e.g. a low-pass filter, this filtering function filters in the
    spectral domain by removing high frequencies from the wavelet transformed
    elevation model. This was suggested by:

    Falorni, G.: Analysis and characterization of the vertical accuracy of 
    digital elevation models from the Shuttle Radar Topography Mission, 
    J. Geophys. Res., 110(F2), F02005, doi:10.1029/2003JF000113, 2005.
    
    Inputs:
        dem:            2D-array (numpy) with elevation values
        filter_name:    Name of wavelet to use. Default is bior6.8
        filter_weight:  Number of frequencies to remove, default is 10.
                        Higher means more filtering.
        xBlockSize:     block size of x-direction in which dem is treated
        yBlockSize:     block size in y-direction in which dem is treated
                        a higher block size means that more memory is used
                        A too high block size may result in memory problems
    Outputs:
        dem_new:        2D-array containing new elevation model, filtered 
                        with wavelet filter
    TODO: enable the use of references to arrays, stored in NetCDF files

    """
    # load full DEM in memory
    # x, y, dem, FillVal = readMap(file, 'GTiff')
    ii = np.isnan(dem)
    dem[ii] = 0.
    # if dem bigger than a certain area, chop the procedure in small pieces
    dem_new = np.zeros(dem.shape)
    rows = dem.shape[0]
    cols = dem.shape[1]
    
    for i in range(0,rows, yBlockSize):
        if i + yBlockSize < rows:
            numRows = yBlockSize
        else:
            numRows = rows - i
            if numRows % 2 == 1:
                # round to a even number
                numRows -= 1
        i2 = i + numRows
        for j in range(0, cols, xBlockSize):
            if j + xBlockSize < cols:
                numCols = xBlockSize
            else:
                numCols = cols - j
                if numCols % 2 == 1:
                    # round to a even number
                    numCols -= 1
            j2 = j + numCols
            print 'Filtering data-block y: %g -- %g; x: %g -- %g' % (i, i2, j, j2)
             # the wavelet level is taken from paper Falorni et al. (2005)
            coeffs = pywt.wavedec2(dem[i:i2, j:j2], filter_name, level=5) 
            filter_weight = np.float64(filter_weight)
            # now remove some thresholds
             # noiseSigma*sqrt(2*log2(image.size))
            NewWaveletCoeffs = map(lambda x: pywt.thresholding.soft(x, 
                                                        filter_weight),
                                                        coeffs)
            dem_new[i:i2, j:j2] = pywt.waverec2(NewWaveletCoeffs, filter_name)
    
    # now bring back missing values
    dem_new[ii] = np.nan
    return dem_new
