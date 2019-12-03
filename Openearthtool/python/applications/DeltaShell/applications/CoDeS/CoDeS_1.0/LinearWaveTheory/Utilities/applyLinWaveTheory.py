#   Copyright notice
#   --------------------------------------------------------------------
#   Copyright (C) 2017 Witteveen+Bos
#
#       Jochem Boersma
#
#       jochem.boersma@witteveenbos.com
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
## Module for LinearWaveTheory
## Developed for CoDeS
## Author: J.H.Boersma / Witteveen+Bos
## Date: March 20th, 2015


## =====Import necessary modules================================
import numpy as np
import math

## =============================================================
def calcWaveHeightProfile(waveHeight, wavePeriod, relDir, profile, gamma):
    """
    Function to calculate waveheight along a given profile, based on a single offshore wave condition, including breaking waves
    in fact a combination of a for-loop, calcWaveConditions() and cutBreakingWaves(), but only of a single wave condition
    
    INPUT:  - waveHeight (offshore) [m] (scalar)
            - wavePeriod (offshore) [s] (scalar)
            - relDir (offshore) [deg]   (scalar)
            REMARK: zero means straight to the coast.
            REMARK: diverging waves will return NaNs for waveHeight and wavePeriod
            - waterDepths from offshore to nearshore [m minus reference] [vector]
            REMARK: the higher the number, the deeper the water
            REMARK: at least two entries are needed for calculation
            - gamma [-] (scalar) 
            
    OUTPUT: - waveHeightProfile [m]
            - waveBreak [TF]
    """
    
    #Check input variables and values:
    if (np.size(waveHeight) != 1) | (np.size(wavePeriod) != 1) | (np.size(relDir) != 1):
        raise Exception('ERROR: Hs, Tp and relDir should be scalar.')
    if (np.size(profile) < 2):
        raise Exception('ERROR: Profile should have at least two entries.')
    if np.any(profile <= 0):
        raise Exception('ERROR: The profile contains a negative value, only positive depth allowed.')
    
    
    #Initialize intermediate scalars (but always floats)
    waveHeightnear = float(waveHeight)
    wavePeriodnear = float(wavePeriod)
    relDirnear = float(relDir)
    gamma = float(gamma)
    
    #Initialize return variables (scalar/vector)
    waveHeightProfile = np.zeros_like(profile) * 1.
    waveHeightProfile[0] = waveHeight * 1.
    waveBreakProfile = np.zeros_like(profile).astype('bool')
    waveBreakProfile[0] = willBreak(waveHeight, profile[0], gamma)
    
    
    #For-loop from 1 (since 0 is initialy used for offshore). It implicates that if it has
    #one entry, it should return immediately with the same values as input values.
    for i in range(1, np.size(profile)):
        #For each dist, calc the waveheigth, based on previous profile-measurement
        (waveHeightnear, wavePeriodnear, relDirnear) = \
            calcWaveConditions(waveHeightnear, wavePeriodnear, relDirnear, profile[i-1], profile[i])
        
        #Store breaking boolean into bool-vector
        waveBreakProfile[i] = willBreak(waveHeight, profile[i], gamma)
        
        #After calculation: it should be checked if the wave will break, if so: cut height.
        #Store this height
        waveHeightProfile[i] = cutBreakingWaves(waveHeightnear, profile[i], gamma)
    #end for-loop
    
    
    
    return waveHeightProfile, waveBreakProfile





## =============================================================
def transWaveConditions(waveHeight, wavePeriod, relDir, profile, gamma):
    """
    Function to calculate nearshore wavecondtions, based on offshore wave conditions, including breaking waves
    in fact a combination of a for-loop, calcWaveConditions() and cutBreakingWaves()
    
    INPUT:  - waveHeight (offshore) [m]
            - wavePeriod (offshore) [s]
            - relDir (offshore) [deg]
            REMARK: zero means straight to the coast.
            REMARK: diverging waves will return NaNs for waveHeight and wavePeriod
            - profile from offshore to nearshore [m minus reference]
            REMARK: the higher the number, the deeper the water
            REMARK: at least two entries are needed for calculation
            - gamma [-] (scalar) 
            
    OUTPUT: - waveHeight (nearshore) [m]
            - wavePeriod (nearshore) [s]
            - relDir (nearshore) [deg]
    """
    
    #Check input variables and values:
    if (np.size(waveHeight) != np.size(wavePeriod)) | (np.size(waveHeight) != np.size(relDir)):
        raise Exception('ERROR: Hs, Tp and relDir are not the same size.')
    if (np.size(profile) < 2):
        raise Exception('ERROR: Profile should have at least two entries.')
    if np.any(profile <= 0):
        raise Exception('ERROR: The profile contains a negative value, only positive depth allowed.')
    
    
    #Initialize return vectors/scalars (but always floats)
    waveHeightnear = waveHeight * 1.
    wavePeriodnear = wavePeriod * 1.
    relDirnear = relDir * 1.
    gamma = float(gamma)
    
    #For-loop from 1 (since 0 is initialy used for offshore). It implicates that if it has
    #one entry, it should return immediately with the same values as input values.
    for i in range(1, np.size(profile)):
        #For each dist, calc the waveheigth, based on previous profile-measurement
        (waveHeightnear, wavePeriodnear, relDirnear) = \
            calcWaveConditions(waveHeightnear, wavePeriodnear, relDirnear, profile[i-1], profile[i])
        
        #After calculation: it should be checked if the wave will break, if so: cut height.
        waveHeightnear = cutBreakingWaves(waveHeightnear, profile[i], gamma)
    #end for-loop
    
    return waveHeightnear, wavePeriodnear, relDirnear


## =============================================================
def calcWaveConditions(waveHeight, wavePeriod, relDir, depthOffshore, depthNearshore):
    """
    Function to calculate nearshore wavecondtions, based on offshore wave conditions.
    Based on: Waves in Oceanic and Coastal Waters (2007);
              Det Norske Vertitas (2010);
              Linear Wave Theory part A (2000).
    
    INPUT:  - waveHeight (offshore) [m]
            - wavePeriod (offshore) [s]
            - relDir (offshore) [deg]
            REMARK: zero means straight to the coast.
            REMARK: diverging waves will return NaNs for waveHeight and wavePeriod
            - waterDepth offshore [m minus reference]
            - waterDepth nearshore [m minus reference]
            REMARK: the higher the number, the deeper the water
           
    OUTPUT: - waveHeight (nearshore) [m]
            - wavePeriod (nearshore) [s]
            - relDir (nearshore) [deg]
    """
    
    #Check input variables and values:
    if (np.size(waveHeight) != np.size(wavePeriod)) | (np.size(waveHeight) != np.size(relDir)):
        raise Exception('ERROR: Hs, Tp and relDir are not the same size.')
    if (depthOffshore <= 0) | (depthNearshore <= 0):
        raise Exception('ERROR: Depth is negative, only positive depth allowed.')
    #No failure, it should return NaNs for those (see end of function)
    #if np.any(~((-90 < relDir) & (relDir < 90))):
    #    raise Exception('ERROR: Some waves are diverging from the coast. Use cut-function first.')
    
    
    #From here: all inputs should be 1-D-numpy-nd-arrays. 
    #Plain-scalars should be converted to NDarrays (with [])
    if np.ndim(waveHeight) == 0:
        waveHeight = np.array([waveHeight])
    if np.ndim(wavePeriod) == 0:
        wavePeriod = np.array([wavePeriod])
    if np.ndim(relDir) == 0:
        relDir = np.array([relDir])
    
    
    
    #Calculate the wavelength of both locations, bases on the waveperiod (remains constant)
    Ldeep = calcWaveLength(wavePeriod, depthOffshore)
    Lnear = calcWaveLength(wavePeriod, depthNearshore)
    
    #Calculate the waveVelocity of both locations
    Cdeep = calcWaveVelocity(Ldeep, depthOffshore)
    Cnear = calcWaveVelocity(Lnear, depthNearshore)
    
    
    #REMARK: values of angle should be between -90 and 90 deg, otherwise the waves will not enter the coast
    #REMARK2: all trigoniometry functions are working with radians.
    SinThetadeep = np.sin(relDir * (math.pi/180.))
    #Calculate the wave-angle of the point near the coast
    SinThetanear = (SinThetadeep / Cdeep) * Cnear
    relDirnear = np.arcsin(SinThetanear) * (180./math.pi)
    
    #Refraction coefficient: ref [?]
    Kr = (np.cos(relDir * (math.pi/180.)) / np.cos(relDirnear * (math.pi/180.)) ) ** 0.5
    
    
    #Calculate group wave velocities
    Cgroupdeep = calcGroupVelocity(Ldeep, depthOffshore)
    Cgroupnear = calcGroupVelocity(Lnear, depthNearshore)
    
    #Shoaling coefficient:
    Ks = (Cgroupdeep / Cgroupnear) ** 0.5
    
    #Final output arguments:
    #Wave-climate of the near shore climate,
    waveHeightnear = Kr * Ks * waveHeight
    wavePeriodnear = wavePeriod * 1.
    
    
    
    #Setting/overwritting all wave climates which has diverging waves:
    # * waveHeightnear becomes NaN
    # * wavePeriodnear becomes NaN
    # * relDirnear becomes orignal relDir
    ixD = ~((-90 < relDir) & (relDir < 90))
    waveHeightnear[ixD] = float('NaN')
    wavePeriodnear[ixD] = float('NaN')
    relDirnear[ixD] = relDir[ixD]
    
    return waveHeightnear, wavePeriodnear, relDirnear



## =============================================================
def willBreak(waveHeight, waterDepth, gamma):
    """
    Function to check whether the waves will break due shallow water.
    Based on: Linear Wave Theory part A (2000) p.15?
    
    INPUT:  - waveHeight [m] (scalar or vector)
            - waterDepth [m minus reference] (scalar)
              REMARK: the higher the number, the deeper the water
            - gamma [-]
           
    OUTPUT: - true OR false [boolean] (with same size as waveHeight)
    """
    
    #From here: all inputs should be 1-D-numpy-nd-arrays. 
    #Plain-scalars should be converted to NDarrays (with [])
    if np.ndim(waveHeight) == 0:
        waveHeight = np.array([waveHeight])
    
    #Check input values
    if (waterDepth <= 0):
        raise Exception('ERROR: Depth is negative, only positive depth allowed.')
    
    #To ensure floats (not ints)
    waveHeight = waveHeight.astype('float')
    waterDepth = float(waterDepth)
    gamma = float(gamma)
    
    breaking = (waveHeight / waterDepth > gamma)
    return breaking.astype('bool')


## =============================================================
def cutBreakingWaves(waveHeight, waterDepth, gamma):
    """
    Function to cut off waveHeight, when waterDepth is too small.
    based on function willBreak.
    
    INPUT:  - waveHeight [m] (scalar or vector)
            - waterDepth [m minus reference] (scalar)
                 n.b. the higher the number, the deeper the water
            - gamma [-] (scalar)
           
    OUTPUT: - cutted waveHeight [m] (with same size as waveHeight)
    """
    
    
    #From here: all inputs should be 1-D-numpy-nd-arrays. 
    #Plain-scalars should be converted to NDarrays (with [])
    if np.ndim(waveHeight) == 0:
        waveHeight = np.array([waveHeight])
        
    #Check input values
    if (waterDepth <= 0):
        raise Exception('ERROR: waterDepth is negative, only positive depth allowed.')
    
    #Enforce waveHeight, waterDepth and gamma being a float
    waveHeight = waveHeight * 1.
    waterDepth = float(waterDepth)
    gamma = float(gamma)
    
    #Initiate new vector containing maximal values for current depth and gamma
    waveMax = np.ones_like(waveHeight) * waterDepth * gamma
    cutWaveHeight = np.min([waveHeight, waveMax], 0)
    
    return cutWaveHeight



## =============================================================
def isDeepWater(waveLength, waterDepth):
    """
    Function to check whether the depth is deep enough to assume deep water.
    Based on: Linear Wave Theory part A (2000) p.15.
    
    INPUT:  - waveLength [m] (scalar of vector)
            - waterDepth [m minus reference] (scalar)
                 n.b. the higher the number, the deeper the water
           
    OUTPUT: - true OR false [boolean, same size as waveLength]
    """
    
    #From here: all inputs should be 1-D-numpy-nd-arrays. 
    #Plain-scalars should be converted to NDarrays (with [])
    if np.ndim(waveLength) == 0:
        waveLength = np.array([waveLength])
    
    
    #Enforce waveLength and waterDepth being a float
    waveLength = waveLength * 1.
    waterDepth = float(waterDepth)
    
    #Return result directly (nd-array containing booleans):
    return (waterDepth / waveLength > 0.5)
    

## =============================================================
def calcGroupVelocity(waveLength, waterDepth):
    """
    Function to calculate group wave velocity, based on wave length and waterdepth.
    Based on: Waves in Oceanic and Coastal Waters (2007) section 7.3.1 - Shoaling, p.199.
    
    INPUT:  - waveLength [m] (scalar or vector)
            - waterDepth [m minus reference] (scalar)
                 n.b. the higher the number, the deeper the water
           
    OUTPUT: - groupVelocity [m/s]
    """
    
    #From here: all inputs should be 1-D-numpy-nd-arrays. 
    #Plain-scalars should be converted to NDarrays (with [])
    if np.ndim(waveLength) == 0:
        waveLength = np.array([waveLength])
    
    #Enforce waveLength and waterDepth being a float    
    waveLength = waveLength * 1.    
    waterDepth = float(waterDepth)
    
    
    waveVelocity = calcWaveVelocity(waveLength, waterDepth)
    waveNumber = 2*math.pi / waveLength
    
    #Equations (7.3.3), p.199):
    n = 0.5 * (1 + (2 * waveNumber * waterDepth) / np.sinh(2 * waveNumber * waterDepth))
    groupVelocity = n * waveVelocity
    
    return groupVelocity


## =============================================================
def calcWaveVelocity(waveLength, waterDepth):
    """
    Function to calculate wave velocity, based on wave length.
    Based on: Det Norske Vertitas (2010) section 3.2.2 - Linear Wave Theory, p.25.
    
    INPUT:  - waveLength [m] (scalar or vector)
            - waterDepth [m minus reference] (scalar)
                 n.b. the higher the number, the deeper the water
           
    OUTPUT: - waveVelocity [m/s]
    """
    
    #From here: all inputs should be 1-D-numpy-nd-arrays. 
    #Plain-scalars should be converted to NDarrays (with [])
    if np.ndim(waveLength) == 0:
        waveLength = np.array([waveLength])
    
    #Enforce waveLength and waterDepth being a float    
    waveLength = waveLength * 1.
    waterDepth = float(waterDepth)

    
    #Additional entities
    pi = math.pi
    grav = 9.81
    
    #Calculating the wave length (p.26)
    waveVelocity = ( (grav*waveLength / 2*pi) * np.tanh(2*pi * waterDepth / waveLength) )**0.5
    
    ##TODO: increasing speed? NO.
    ##When deep water or shallow water, the relation is much more simple.
    ##This could be interesting when function is slow.
    
    return waveVelocity


## =============================================================
def calcWaveLength(wavePeriod, waterDepth):
    """
    Function to calculate wavelength, based on wave period and water depth.
    Approximation based on: Det Norske Vertitas (2010) section 3.2.2 - Linear Wave Theory, p.25
    
    INPUT:     - wavePeriod [s] (scalar or vector)
               - waterDepth [m minus reference] (scalar)
                 n.b. the higher the number, the deeper the water
           
    OUTPUT:    - waveLength [m]
    """
    
    #From here: input should be 1-D-numpy-nd-arrays. 
    #Plain-scalars should be converted to NDarrays (with [])
    if np.ndim(wavePeriod) == 0:
        wavePeriod = np.array([wavePeriod])
    
    #Enforce wavePeriod and waterDepth being a float    
    wavePeriod = wavePeriod * 1.
    waterDepth = float(waterDepth)
    
    
    #Additional entities
    pi = math.pi
    grav = 9.81
    
    
    #Additional constants (p.26)
    a1 = 0.666
    a2 = 0.445
    a3 = -0.105
    a4 = 0.272
    
    #Defining omega with bar and approximation of f (to approximate inverse tanh, p.26)
    omega = (4 * (pi**2) * waterDepth) / (grav * wavePeriod**2)
    F = 1 + a1*omega + a2*(omega**2) + a3*(omega**3) + a4*(omega**4)
    
    #Calculating the wave length
    waveLength = wavePeriod * (grav * waterDepth)**0.5 * (F/(1 + omega*F))**0.5
    
    ##TODO: increasing speed.
    ##When deep water or shallow water, the relation is much more simple.
    ##This could be interesting when function is slow.

    """
    #Calculation of wave-length (deep water)
    L = (9.81*Tp) / 2*math.pi
    
    #Recursive function to determine wave-length
    L = (9.81*Tp) / 2*math.pi * np.tanh(2*math.pi * nearshZ / L)
    
    #Calculation of wave-length (shallow water)
    L = Tp * (9.81*) ** (0.5)
    """
    return waveLength
    
    
    
    
## =============================================================
def calcRelativeDirection(dirWave, shoreNormal):
    """
    Function to determine wave directions with respect to the shore normal.
    Based on: Linear Wave Theory part A (2000) p.15.
    
    INPUT:  - dirWave [degree] (scalar or vector)
            waves are coming from this nautic direction, 
            i.e. 225 means a wave coming from the south-west
            - shoreNormal [degree] (scalar)
            points towards the sea, relative to north, clockwise
           
    OUTPUT: - relDir [degrees]
            vector containing the relative directions (size equal to dirWave)
            REMARK: 0 degrees means: waves are going straight towards the coast
            Negative degrees coming from the left, positive from the right
            - ixD [boolean] (same size as relDir and dirWave
            indicator of directions which of the waves are approaching the coast
    """
    
    #From here: all inputs should be 1-D-numpy-nd-arrays. 
    #Plain-scalars should be converted to NDarrays (with [])
    if np.ndim(dirWave) == 0:
        dirWave = np.array([dirWave])
    
    #Ensure float for dirWave and shoreNormal, between 0 and 360
    dirWave = dirWave * 1.
    shoreNormal = float(shoreNormal % 360)
    
    #The angle between shore and wave.
    # (in degrees, modulo 360, but between -180 and 180)
    # ref: Waves in Oceanic and Coastal Waters p.205, fig 7.7
    relDir = (dirWave - shoreNormal + 180.) % 360. - 180.
    
    #If DirWave == ShoreNormal, then the wave will go 'gerade aus'.
    #If DirWave < ShoreNormal - 90 or 
    #	DirWave > ShoreNormal + 90
    #then the wave will never reach the coast.
    
    #Non diverging instances are selected.
    ixD = (-90 < relDir) & (relDir < 90)
    
    return relDir, ixD

#End of Module