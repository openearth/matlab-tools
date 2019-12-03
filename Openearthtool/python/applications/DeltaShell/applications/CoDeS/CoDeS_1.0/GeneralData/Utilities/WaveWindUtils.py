#   Copyright notice
#   --------------------------------------------------------------------
#   Copyright (C) 2017 Deltares
#
#       Hidde Elzinga
#
#       hidde.elzinga@deltares.nl
#
#       P.O. Box 177
#       2600 MH Delft
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
import clr
clr.AddReference("System.Windows.Forms")
from System.Windows.Forms import Form
import System.Windows.Forms as _swf
import numpy as _np
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
    v1.7: - Eventual conditions are median of found conditions in "bin" 
    	  - Return of system floats and not numpy.float arrays
    """
    
    #Check input: all input should be of same length
    if (_np.alen(waveHeight) != _np.alen(wavePeriod)) | (_np.alen(waveHeight) != _np.alen(direction)):
        raise Exception('waveHeight, wavePeriod and direction should be of same length')
    
    
    #NaN handling: if a NaN occures in a vector, then this;
    #and the corresponding entries of the other vectors should be removed
    ixNaN = (_np.isnan(waveHeight) | _np.isnan(wavePeriod) | _np.isnan(direction))
    waveHeight = waveHeight[~ixNaN] 
    wavePeriod = wavePeriod[~ixNaN]
    direction = direction[~ixNaN]
    
    
    
    #If no input is given (or all NaNs), no output should be returned
    if (_np.alen(waveHeight) == 0):
        print('Empty or NaN-vectors given, returning empty wave')
        return []
    
    
    
    
    #Converting directions towards range [0,360)
    direction = direction % 360
    
    
    #Initialize bin sizes. #bin size is fixed, but can be made variable if necessary
    interval_Height = _np.array(0.25)     #interval wave Height [m]
    interval_period = _np.array(1.)      #interval wave period [seconds]
    interval_direction = _np.array(15.)  #interval direction [degrees]
    
    
    #Over all three dimensions, make bins. Total number of classes is the PRODUCT of the number of bins
    Hmin = _np.multiply(_np.floor(_np.divide((_np.amin(waveHeight)),interval_Height)), interval_Height)      #floor to minimum waveHeight value
    Tmin = _np.multiply(_np.floor(_np.divide((_np.amin(wavePeriod)),interval_period)), interval_period)      #floor to minimum wavePeriod value
    Dmin = _np.multiply(_np.floor(_np.divide((_np.amin(direction)),interval_direction)), interval_direction) #floor to minimum direction value
    
    
    #Create the bins from min to max (+ 1 interval) with interval 'interval_xxx'
    waveHeight_bins = _np.arange(Hmin,_np.amax(waveHeight) + interval_Height, interval_Height, float) 
    wavePeriod_bins = _np.arange(Tmin,_np.amax(wavePeriod) + interval_period, interval_period, float)
    direction_bins = _np.arange(Dmin,_np.amax(direction) + interval_direction, interval_direction, float)
    #print(direction_bins)
    
    #Initiate counter for names in classes
    t = 0
    
    #Values in wave_classes will be: 1-3 are lower boundaries of bins (Height, period, direction). Value 4 is occurrence (ratio)
    #Occurrence = number higher or equal to lower class boundary and smaller than upper class boundary
    wave_classes = [] #DECIDE TO KEEP IT AS A LIST!
    #Pass all wave-classes, and check whole series/array, to determine the occurence
    for i1 in range(0,len(waveHeight_bins)):
        #Those values inside the WAVEHeight bin should be count in occurence
        lowEdgeH = _np.round(waveHeight_bins[i1], 2)
        uppEdgeH = _np.round(waveHeight_bins[i1] + interval_Height, 2)
        inHeight_bin = _np.logical_and((lowEdgeH <= waveHeight), (waveHeight < uppEdgeH))
        
        #If no elements are in the current height bin, continue to next bin. 
        if not _np.any(inHeight_bin):
            continue
        
        for i2 in range(0,len(wavePeriod_bins)):
            #Those values inside the WAVEPERIOD bin should be count in occurence
            lowEdgeP = _np.round(wavePeriod_bins[i2], 0)
            uppEdgeP = _np.round(wavePeriod_bins[i2] + interval_period, 0)
            
            inPeriod_bin = _np.logical_and((lowEdgeP <= wavePeriod), (wavePeriod < uppEdgeP))
            
            #If no elements are in the current height bin, continue to next bin. 
            if not _np.any(inPeriod_bin):
                continue
                
            for i3 in range(0,len(direction_bins)):
                #Those values inside the DIRECTION bin should be count in occurence
                lowEdgeD = _np.round(direction_bins[i3], 0)
                uppEdgeD = _np.round(direction_bins[i3] + interval_direction, 0)
                
                inDir_bin = _np.logical_and((lowEdgeD <= direction), (direction < uppEdgeD))
                
                #Number of samples of the whole series which are in the current class.
                inClass = _np.all([inHeight_bin, inPeriod_bin, inDir_bin], axis=0)
                
                #If no elements are in the current 3-D bin, then do not add but go to next bin.
                if not _np.any(inClass):
                    continue
                
                #Otherwise: count number of occurences and calculate ratio
                NinClass = float(_np.sum(inClass))
                ratioinClass = NinClass / len(waveHeight)
                
                #Append the name (with number), three lower bin values and occurence
                t = t + 1
                
                # conditions (median of all in bin)
                Hcond = _np.median(waveHeight[inClass]).Value
                Tcond = _np.median(wavePeriod[inClass]).Value
                Dcond = _np.median(direction[inClass]).Value
                
                #KEEP IN LIST -> REMOVE CLASS TITLE, ONLY SAVE Hs, Tp, Dir, Occ
                wave_classes.append([Hcond, Tcond, Dcond, ratioinClass])
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
    H_s   = _np.zeros_like(wave_classes)
    T_p   = _np.zeros_like(wave_classes)
    dir   = _np.zeros_like(wave_classes)
    occ   = _np.zeros_like(wave_classes)
    names = _np.zeros_like(wave_classes)
    
    #Pick values from the wave class and put it in the correct value-vector
    for i1 in range(len(wave_classes)):
        values = _np.array(wave_classes[i1].values())
        H_s[i1] = values[0,0]
        T_p[i1] = values[0,1]
        dir[i1] = values[0,2]
        occ[i1] = values[0,3]
        names[i1] = str(wave_classes[i1].keys())
    #end for-loop
    
    return H_s, T_p, dir, occ, names
"""


## =============================================================
class frmDateTimeExample(Form):
	#Class for storing the table with all information about date time format
	
	def __init__(self):
		Form.__init__(self)
		self.Width = 845
		self.Height = 470
		self.Text="Date-time format"
		#frmDateTime.FormBorderStyle = FormBorderStyle.FixedDialog
		
		rtbDateFormat = _swf.RichTextBox()
		rtbDateFormat.Top = 10
		rtbDateFormat.Left = 10
		rtbDateFormat.Width = 807
		rtbDateFormat.Height = 340
		
		defaultHeader = r"{\rtf1\ansi\ansicpg1252\deff0\deflang1033{\fonttbl{\f0\fnil\fcharset0 Calibri;}}"
		colorsUsed = r"{\colortbl ;\red0\green0\blue255;\red0\green255\blue0;}"
		text = (defaultHeader + colorsUsed +
			r"\trowd\trautofit1" + 
			r"\cellx1000 \cellx8000 \cellx12000" +
			r"\intbl  Format\cell  Explanation\cell  Example\cell" +
			r"\row"+
			r"\intbl  %a\cell  Weekday as abbreviated name.\cell  Sun, Mon, ..., Sat\cell" +
			r"\row" +
			r"\intbl  %A\cell  Weekday as full name.\cell  Sunday, Monday, ..., Saturday\cell" +
			r"\row" +
			r"\intbl  %w\cell  Weekday as a decimal number, where 0 is Sunday and 6 is Saturday.\cell  0, 1, ..., 6\cell" +
			r"\row" +
			r"\intbl  %d\cell  Day of the month as a zero-padded decimal number.\cell  01, 02, ..., 31\cell" +
			r"\row" +
			r"\intbl  %b\cell  Month as abbreviated name.\cell  Jan, Feb, ..., Dec\cell" +
			r"\row" +
			r"\intbl  %B\cell  Month as full name.\cell  January, February, ..., December\cell" +
			r"\row" +
			r"\intbl  %m\cell  Month as a zero-padded decimal number.\cell  01, 02, ..., 12\cell" +
			r"\row" +
			r"\intbl  %y\cell  Year without century as a zero-padded decimal number.\cell  00, 01, ..., 99\cell" +
			r"\row" +
			r"\intbl  %Y\cell  Year with century as a decimal number.\cell  1970, 1988, 2001, 2013\cell" +
			r"\row" +
			r"\intbl  %H\cell  Hour (24-hour clock) as a zero-padded decimal number.\cell  00, 01, ..., 23\cell" +
			r"\row" +
			r"\intbl  %I\cell  Hour (12-hour clock) as a zero-padded decimal number.\cell  01, 02, ..., 12\cell" +
			r"\row" +
			r"\intbl  %p\cell  Equivalent of either AM or PM.\cell  AM, PM\cell" +
			r"\row" +
			r"\intbl  %M\cell  Minute as a zero-padded decimal number.\cell  00, 01, ..., 59\cell" +
			r"\row" +
			r"\intbl  %S\cell  Second as a zero-padded decimal number.\cell  00, 01, ..., 59\cell" +
			r"\row" +
			r"}")
		
		rtbDateFormat.Rtf = text
		
		btnOK = _swf.Button()
		btnOK.Text = "Close"
		btnOK.Top = 380
		btnOK.Left = 730
		btnOK.Click += self.btnOK_Click
		
		self.Controls.Add(rtbDateFormat)
		self.Controls.Add(btnOK)
	
	
	def btnOK_Click(self, sender, e):
		#After clicking OK:
		self.Close()



