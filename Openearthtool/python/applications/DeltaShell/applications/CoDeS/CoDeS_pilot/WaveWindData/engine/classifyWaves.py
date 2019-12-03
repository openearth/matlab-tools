#   Copyright notice
#   --------------------------------------------------------------------
#   Copyright (C) 2016 Witteveen+Bos
#       Jaap de Rue
#
#       jaap.de.rue@witteveenbos.com
#
#       Van Twickelostraat 2
#       7411 SC Deventer
#       The Netherlands
#
#   This library is free software: you can redistribute it and/or modify
#   it under the terms of the GNU Lesser General Public License as published by
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
import numpy as np
import math

## =============================================================
def classifyWaves(waveHeight, wavePeriod, direction):
    """
    Function to classify wave-specifications, based on wave Height, wave period and direction.
    
    INPUT:     - array of waveHeight [m]
            - array of wavePeriod [s]
            - array of directions [deg relative to northing]

    OUTPUT: - dictionary of wave_classes (including an occurence in ratios)
    
    v1.5: - statements outside for-loop (speed-up)
          - cast of occurence to float (instead of int)
          - skip adding empty wave_classes (speed-up)
          
    v1.6: - DEBUGGED: rounding bin-edges with np.round
          - direction is converted to a number in range [0,360)
          - NaN-handling
          - speedup: skipping for-loops
          - raise exeption (instead of display) if not the same length
          - no input should return empty output
    """
    
    #Check input: all input should be of same length
    if (np.alen(waveHeight) != np.alen(wavePeriod)) | (np.alen(waveHeight) != np.alen(direction)):
        raise Exception('waveHeight, wavePeriod and direction should be of same length')
    
    
    #NaN handling: if a NaN occures in a vector, then this;
    #and the corresponding entries of the other vectors should be removed
    ixNaN = (np.isnan(waveHeight) | np.isnan(wavePeriod) | np.isnan(direction))
    waveHeight = waveHeight[~ixNaN] 
    wavePeriod = wavePeriod[~ixNaN]
    direction = direction[~ixNaN]
    
    
    
    #If no input is given (or all NaNs), no output should be returned
    if (np.alen(waveHeight) == 0):
        print('Empty or NaN-vectors given, returning empty wave')
        return []
    
    
    
    
    #Converting directions towards range [0,360)
    direction = direction % 360
    
    
    #Initialize bin sizes. #bin size is fixed, but can be made variable if necessary
    interval_Height = np.array(0.1)     #interval wave Height [m]
    interval_period = np.array(1.)      #interval wave period [seconds]
    interval_direction = np.array(10.)  #interval direction [degrees]
    
    
    #Over all three dimensions, make bins. Total number of classes is the PRODUCT of the number of bins
    Hmin = np.multiply(np.floor(np.divide((np.amin(waveHeight)),interval_Height)), interval_Height)      #floor to minimum waveHeight value
    Tmin = np.multiply(np.floor(np.divide((np.amin(wavePeriod)),interval_period)), interval_period)      #floor to minimum wavePeriod value
    Dmin = np.multiply(np.floor(np.divide((np.amin(direction)),interval_direction)), interval_direction) #floor to minimum direction value
    
    
    #Create the bins from min to max (+ 1 interval) with interval 'interval_xxx'
    waveHeight_bins = np.arange(Hmin,np.amax(waveHeight) + interval_Height, interval_Height, float) 
    wavePeriod_bins = np.arange(Tmin,np.amax(wavePeriod) + interval_period, interval_period, float)
    direction_bins = np.arange(Dmin,np.amax(direction) + interval_direction, interval_direction, float)
    #print(direction_bins)
    
    #Initiate counter for names in classes
    t = 0
    
    #Values in wave_classes will be: 1-3 are lower boundaries of bins (Height, period, direction). Value 4 is occurrence (ratio)
    #Occurrence = number higher or equal to lower class boundary and smaller than upper class boundary
    wave_classes = [] #DECIDE TO KEEP IT AS A LIST!
    #Pass all wave-classes, and check whole series/array, to determine the occurence
    for i1 in range(0,len(waveHeight_bins)):
        #Those values inside the WAVEHeight bin should be count in occurence
        lowEdgeH = np.round(waveHeight_bins[i1], 1)
        uppEdgeH = np.round(waveHeight_bins[i1] + interval_Height, 1)
        inHeight_bin = np.logical_and((lowEdgeH <= waveHeight), (waveHeight < uppEdgeH))
        
        #If no elements are in the current height bin, continue to next bin. 
        if not np.any(inHeight_bin):
            continue
        
        for i2 in range(0,len(wavePeriod_bins)):
            #Those values inside the WAVEPERIOD bin should be count in occurence
            lowEdgeP = np.round(wavePeriod_bins[i2], 0)
            uppEdgeP = np.round(wavePeriod_bins[i2] + interval_period, 0)
            
            inPeriod_bin = np.logical_and((lowEdgeP <= wavePeriod), (wavePeriod < uppEdgeP))
            
            #If no elements are in the current height bin, continue to next bin. 
            if not np.any(inPeriod_bin):
                continue
                
            for i3 in range(0,len(direction_bins)):
                #Those values inside the DIRECTION bin should be count in occurence
                lowEdgeD = np.round(direction_bins[i3], 0)
                uppEdgeD = np.round(direction_bins[i3] + interval_direction, 0)
                
                inDir_bin = np.logical_and((lowEdgeD <= direction), (direction < uppEdgeD))
                
                #Number of samples of the whole series which are in the current class.
                inClass = np.all([inHeight_bin, inPeriod_bin, inDir_bin], axis=0)
                
                #If no elements are in the current 3-D bin, then do not add but go to next bin.
                if not np.any(inClass):
                    continue
                
                #Otherwise: count number of occurences and calculate ratio
                NinClass = float(np.sum(inClass))
                ratioinClass = NinClass / len(waveHeight)
                
                #Append the name (with number), three lower bin values and occurence
                t = t + 1
                #KEEP IN LIST -> REMOVE CLASS TITLE, ONLY SAVE Hs, Tp, Dir, Occ
                wave_classes.append([waveHeight_bins[i1], wavePeriod_bins[i2], direction_bins[i3], ratioinClass])
    #end triple for-loop
    
    return wave_classes


"""
## =============================================================
def get_wave_classes(wave_classes):
    
    Function to un-classify wave-classes. Inverse function of CLASSIFYWAVES.
    N.B. It returns the lower-bin-values of the classes.
    
    INPUT:  - dictionary of wave classes
    
    OUTPUT: - array of waveHeight [m]
            - array of wavePeriod [s]
            - array of directions [deg relative to northing]
            - array of occurences [ratios]
            - array of strings with names of wave_classes
    
    v1.1: - initialize zero-vectors (speed-up)
          - skip adding empty wave_classes (speed-up)
    
    
    # initialize zero-vectors (no appending, increase speed)
    H_s   = np.zeros_like(wave_classes)
    T_p   = np.zeros_like(wave_classes)
    dir   = np.zeros_like(wave_classes)
    occ   = np.zeros_like(wave_classes)
    names = np.zeros_like(wave_classes)
    
    #Pick values from the wave class and put it in the correct value-vector
    for i1 in range(len(wave_classes)):
        values = np.array(wave_classes[i1].values())
        H_s[i1] = values[0,0]
        T_p[i1] = values[0,1]
        dir[i1] = values[0,2]
        occ[i1] = values[0,3]
        names[i1] = str(wave_classes[i1].keys())
    #end for-loop
    
    return H_s, T_p, dir, occ, names
"""