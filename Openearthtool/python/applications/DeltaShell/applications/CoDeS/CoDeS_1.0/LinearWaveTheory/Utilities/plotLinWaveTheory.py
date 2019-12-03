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
from Libraries.StandardFunctions import *
from Libraries.ChartFunctions import *
import numpy as np
import System.Drawing.Drawing2D.DashStyle as Dash

## =============================================================
def plotProfileWaveHeight(profile, waveHeight):
    """
    Function to plot the waveHeight, in combination with waterDepth
    In fact, this function is obsolete, and could be replaced by combining
     * plotProfile()
     * addWaveHeightPlot()
    and then additionaly (optional)
     * addBreakingPlot()    or
     * addBreakWaterDashes()
    
    INPUT:  - profile 
            a dictionary with four entries:
                * profile['dist'] distance (from offshore point) [m]
                * profile['z']    waterDepth [m minus reference]
                * profile['x']    x-coordinate (not used)
                * profile['y']    y-coordinate (not used)
            - waveHeight [m]
            REMARK: waterDepth has positive numbers, negative numbers are above sea level
            REMARK: profile and waveHeight should be of same size
           
    OUTPUT: - chart
    """
    
    #Check input 
    if (np.size(profile['dist']) != np.size(waveHeight)):
        raise Exception('ERROR: profile and waveHeight,are not the same size.')
    #No exception needed for negative water depths, since the profile could be made on land
    #if np.any(profile['z'] < 0):
    #    raise Exception('ERROR: profile-depth should be non-negative.')
    
    
    #Extract from dictionary, force float and reverse sign for depth 
    distance = np.array(profile['dist']) * 1.
    depth = np.array(profile['z']) * -1.
    
    #Generate stacked vectors for lineseries
    depthatDist = np.vstack((distance,depth)).T
    waveHeightatDist = np.vstack((distance,waveHeight)).T
    
    
    #Generating Series
    areaProfile = CreateAreaSeries(depthatDist)
    zeroLine = CreateLineSeries([[0,0],[len(distance)-1,0]])
    
    
    #Configure the line series for Depth
    areaProfile.LineColor = Color.Red
    areaProfile.LineWidth = 2
    areaProfile.Transparency = 40 # %
    areaProfile.PointerVisible = False
    areaProfile.PointerLineVisible = False
    areaProfile.Color = Color.Beige
    
    # Configure the dashed line (REF + 0 m)
    zeroLine.Color = Color.Black
    zeroLine.PointerLineVisible = False
    
    
    # Generate chart
    chart = CreateChart([areaProfile, zeroLine])
    
    # Configure the chart
    chart.TitleVisible = True
    chart.Title = "Depth Profile (red) and Wave Height (blue)"
    chart.BackGroundColor = Color.White
    
    # Configure the bottom axis
    #chart.BottomAxis.Automatic = False
    #chart.BottomAxis.Minimum = 1
    #chart.BottomAxis.Maximum = 6
    chart.BottomAxis.Title = "distance from offshore point"
    
    # Configure the left axis
    chart.LeftAxis.Title = "Depth [m] / WaveHeight [m]"
    chart.LeftAxis.Automatic = False
    chart.LeftAxis.Minimum = max(waveHeight) * -2.5
    chart.LeftAxis.Maximum = max(waveHeight) * 1.1
    
    
    
    #NaNs in vector will give fatal error, so catch this
    if (np.any(np.isnan(waveHeight))):
        print('NaNs occuring in waveHeight, only depth profile is plotted.')
        #Function will be quit prematurely
        return chart
    
    #If it has valid values, it will be added to the (already configured) plot
    lineWaveHeight = CreateLineSeries(waveHeightatDist)
    
    # Configure the line series for Wave heigth
    lineWaveHeight.Color = Color.Blue
    lineWaveHeight.Width = 2
    lineWaveHeight.PointerVisible = False
    chart.Series.Add(lineWaveHeight)
    
    return chart


## =============================================================
def plotProfile(profile,crestheight,layer):
    """
    Function to plot the profile
    
    INPUT:  - profile 
            a dictionary with four entries:
                * profile['dist'] distance (from offshore point) [m]
                * profile['z']    waterDepth [m minus reference]
                * profile['x']    x-coordinate (not used)
                * profile['y']    y-coordinate (not used)
    
    OUTPUT: - chart
    """
    
    #Check input 
    #if np.any(profile['z'] < 0):
    #    raise Exception('ERROR: profile-depth should be non-negative.')
    
    #Extract from dictionary, force float and reverse sign for depth 
   
    distance = np.array(profile['dist_pl2']) * 1.
    distance_or = np.array(profile['dist_pl']) * 1.
    depth = np.array(profile['z']) * -1.
    depth_or = np.array(profile['z_pl']) * -1.
     
    meanDepth = np.array(profile['mean_z']) * -1.
    meanDistance = np.array(profile['mean_dist_pl2']) * 1.
    #Generate stacked vectors for lineseries
    
    depthatDist = np.vstack((distance,depth)).T
    depthatDist_or = np.vstack((distance_or,depth_or)).T
    
    #Generating Series
    areaProfile = CreateAreaSeries(depthatDist)
    areaProfile_or = CreateAreaSeries(depthatDist_or)
    #zeroLine = CreateLineSeries([[0,0],[len(distance)-1,0]])
    
    crestH = CreateLineSeries([[distance[0],crestheight],[distance[-1],crestheight]])
    crestH.Color = Color.Green
    crestH.PointerLineVisible = False
    crestH.Width = 2
    crestH.DashStyle = Dash.Dot
    
    aH = crestheight - layer['armour']
    armourH = CreateLineSeries([[distance[0],aH],[distance[-1],aH]])
    armourH.Color = Color.Green
    armourH.PointerLineVisible = False
    armourH.Width = 2
    armourH.DashStyle = Dash.Dot    
    
    fH = crestheight - layer['armour'] - layer['filter']
    filterH = CreateLineSeries([[distance[0],fH],[distance[-1],fH]])
    filterH.Color = Color.Green
    filterH.PointerLineVisible = False
    filterH.Width = 2
    filterH.DashStyle = Dash.Dot   
    
    #Configure the area series for Depth
    areaProfile.LineColor = Color.Red
    areaProfile.LineWidth = 2
    areaProfile.Transparency = 40 # %
    areaProfile.PointerVisible = False
    areaProfile.PointerLineVisible = False
    areaProfile.Color = Color.Beige
    
    #Configure the area series for orginal Depth
    areaProfile_or.LineColor = Color.Gray
    areaProfile_or.LineWidth = 2
    areaProfile_or.Transparency = 60 # %
    areaProfile_or.PointerVisible = False
    areaProfile_or.PointerLineVisible = False
    areaProfile_or.Color = Color.LightGray
    
    # Configure the dashed line (REF + 0 m)
    #zeroLine.Color = Color.Black
    #zeroLine.PointerLineVisible = False
    
    
    # Generate chart
    chart = CreateChart([areaProfile_or, areaProfile,crestH,armourH,filterH])
    
    # Configure the chart
    chart.TitleVisible = True
    chart.Title = "Depth Profile along breakwater (red), selected cross-section (blue dashed) and layer heights (green dashed)"
    chart.BackGroundColor = Color.White
    
    # Configure the bottom axis
    #chart.BottomAxis.Automatic = False
    #chart.BottomAxis.Minimum = 1
    #chart.BottomAxis.Maximum = 6
    chart.BottomAxis.Title = "distance from start point"
    
    # Configure the left axis
    chart.LeftAxis.Title = "Depth [m]"
    chart.LeftAxis.Automatic = False
    chart.LeftAxis.Minimum = min(depth) * 1.1
    chart.LeftAxis.Maximum = max([max([max(depth_or) * 1.1,2]),crestheight * 1.1])
    
    #Generate stacked vectors for point series
    depthatDistpt = np.vstack((meanDistance,meanDepth)).T
    
    
    #Generating Series
    pointsProfile = CreatePointSeries(depthatDistpt)
    
    #Configure the points at mean depth, and add to chart
    pointsProfile.Color = Color.DarkRed
    pointsProfile.Size = 2
    chart.Series.Add(pointsProfile)
    
    return chart



## =============================================================
def addBreakWaterDashes(chart, profile):
    """
    Function to add dashes which represents the cross-sections of the breakwater
    
    INPUT:  - chart (where the plot must be placed)
            - profile 
            a dictionary with four entries:
                * profile['dist']       distance (from offshore point) [m]
                * profile['z']          waterDepth [m minus reference]
                * profile['x']          x-coordinate (not used)
                * profile['y']          y-coordinate (not used)
           (new)* profile['mean_dist']  mean distance between two points [m]
           (new)* profile['mean_z']     mean waterDepth between two points [m minus reference]
   
            
    OUTPUT: - chart
    """
    
    #Check input 
    if np.any(profile['mean_z'] < 0):
        raise Exception('ERROR: means of profile-depth should be non-negative.')
    
    #Extract from dictionary, ensure floats and reverse sign for depth 
    depth = np.array(profile['dist']) * -1.
    meanDepth = np.array(profile['mean_z']) * -1.
    meanDistance = np.array(profile['mean_dist']) * 1.
    
    
    #Generate stacked vectors for point series
    depthatDist = np.vstack((meanDistance,meanDepth)).T
    
    
    #Generating Series
    pointsProfile = CreatePointSeries(depthatDist)
    
    #Configure the points at mean depth, and add to chart
    pointsProfile.Color = Color.DarkRed
    pointsProfile.Size = 3
    chart.Series.Add(pointsProfile)
    
    
    #Draw vertical dashed lines at mean-points
    for i in range(len(meanDistance)):
        #Each intermediate value gets a line from low value to high-value 
        dashBWLine = CreateLineSeries([[meanDistance[i], meanDepth[i]],[meanDistance[i], 2.]])
        
        #Configure, and add to chart
        dashBWLine.Color = Color.Black
        dashBWLine.PointerLineVisible = False
        dashBWLine.Width = 2
        dashBWLine.DashStyle = Dash.Dot
        chart.Series.Add(dashBWLine)
        
    
    
    #Update chart title
    chart.Title = "Depth Profile along breakwater (red) and Selected cross-section (blue dashed)"
    
    return chart
    
    
## =============================================================
def addBreakwaterDashes_ind(plot, profile, cross_ind):
    """
    Function to add dashes which represents the cross-sections of the breakwater for the 'selected' cross section in blue
    
    INPUT:  - plot with chart (where the plot must be placed)
            - profile 
            a dictionary with six entries:
                * profile['dist']       distance (from offshore point) [m]
                * profile['z']          waterDepth [m minus reference]
                * profile['x']          x-coordinate (not used)
                * profile['y']          y-coordinate (not used)
           (new)* profile['mean_dist_pl2']  mean distance between two points (wet profile) [m]
           (new)* profile['mean_z']     mean waterDepth between two points [m minus reference]
             - 'cross_ind'
            
    OUTPUT: - chart
    """
    
    depth = np.array(profile['z_pl']) * -1.
    meanDepth = np.array(profile['mean_z']) * -1.
    meanDistance = np.array(profile['mean_dist_pl2']) * 1.
    
    for ind in range(0,len(plot.Chart.Series)):
    	if plot.Chart.Series[ind].Tag == "Indexed":
			ind_to_rem = ind
	if 'ind_to_rem' in locals():
		plot.Chart.Series.Remove(plot.Chart.Series[ind_to_rem])

    dashBWLine1 = CreateLineSeries([[meanDistance[cross_ind], meanDepth[cross_ind]],[meanDistance[cross_ind], max([max(depth)*1.1,2])]])
    dashBWLine1.Color = Color.Blue
    dashBWLine1.PointerLineVisible = False
    dashBWLine1.Width = 3
    dashBWLine1.DashStyle = Dash.Dot
    dashBWLine1.Tag = "Indexed"
    

        
    plot.Chart.Series.Add(dashBWLine1)
    
    


## =============================================================
def addWaveHeightPlot(chart, profile, waveHeight):
    """
    Function to add the waveheight to the profile plot
    
    INPUT:  - chart (where the plot must be placed)
            - profile 
            a dictionary with four entries:
                * profile['dist'] distance (from offshore point) [m]
                * profile['z']    waterDepth [m minus reference]
                * profile['x']    x-coordinate (not used)
                * profile['y']    y-coordinate (not used)
            - waveHeight [m]
            REMARK: waterDepth has positive numbers
            REMARK: profile and waveHeight should be of same size
           
    OUTPUT: - chart
    """
    
    
    #Check input 
    if (np.size(profile['dist']) != np.size(waveHeight)):
        raise Exception('ERROR: profile and waveHeight,are not the same size.')
    
    
    #NaNs in vector will give fatal error, so catch this
    if (np.any(np.isnan(waveHeight))):
        print('NaNs occuring in waveHeight, plot not added.')
        #Function will be quit prematurely
        return chart
    
    
    #Extract from dictionary, and reverse sign for depth 
    distance = np.array(profile['dist'])
    
    #Generate stacked vectors for lineseries
    waveHeightatDist = np.vstack((distance,waveHeight)).T

    
    
    #If it has valid values, it will be added to the (already configured) plot
    lineWaveHeight = CreateLineSeries(waveHeightatDist)
    
    # Configure the line series for Wave height
    lineWaveHeight.Color = Color.Blue
    lineWaveHeight.Width = 2
    lineWaveHeight.PointerVisible = False
    chart.Series.Add(lineWaveHeight)
    
    
    # Adjust the chart title
    chart.TitleVisible = True
    chart.Title = "Depth Profile (red) and Wave Height (blue)"
    chart.BackGroundColor = Color.White
    
    # Adjust the left axis
    chart.LeftAxis.Title = "Depth [m] / WaveHeight [m]"
    chart.LeftAxis.Automatic = False
    chart.LeftAxis.Minimum = max(waveHeight) * -2.5
    chart.LeftAxis.Maximum = max(waveHeight) * 1.1
    
    return chart



## =============================================================
def addBreakingPlot(chart, profile, waveHeight, waveBreak):
    """
    Function to add the markers where wave breaking will occur
    
    INPUT:  - chart (where the plot must be placed)
            - profile (like function plotProfileWaveHeight())
            - waveBreak [boolean]
            - waveHeight [m]
            REMARK: waveBreak and waveHeight should be of same size
           
    OUTPUT: - chart
    """
    
    #Check input 
    if (np.size(waveBreak) != np.size(waveHeight)) | (np.size(profile['dist']) != np.size(waveHeight)):
        raise Exception('ERROR: waveBreak, waveHeight and profile are not the same size.')
    
    #Force types and extract distance from profile dictionary
    distance = np.array(profile['dist']).astype('float')
    waveHeight = np.array(waveHeight).astype('float')
    waveBreak = waveBreak.astype('bool')
    
    #Places where the waves not break are excluded from the plotting selection
    distance = distance[waveBreak]
    waveHeight = waveHeight[waveBreak]
    waveBreak = waveBreak[waveBreak]
    
    
    #The values of waveHeight are only the values in case that waves break
    #these points should be marked.
    breakatDist = np.vstack((distance,waveHeight)).T
    
    
    #Generating a point-series, and add it to the existing chart.
    breakWaves = CreatePointSeries(breakatDist)
    breakWaves.Color = Color.LightBlue
    breakWaves.Size = 4.5
    chart.Series.Add(breakWaves)
    
    #Updating the chart title
    chart.Title = "Depth Profile (red) and Wave Height (blue) with Breaking Waves (blue dots)"
    
    return chart

#End of Module