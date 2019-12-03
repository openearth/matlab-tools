# -*- coding: utf-8 -*-
"""
Created on Fri Nov 07 15:23:28 2014

@author: Dirk Eilander

This function finds peaks in a time series, e.g. a hydrograph. A peak is a data 
sample that is larger than its two neighboring samples AND the largest sample 
within a moving time window.

Three methods are available: 
peaks over threshold, annual maxima, selection of n peaks

checkout the functions for more information

@version: 1 - 13/01/2015
--> proper error handling needs to be inplemented
--> the function works with pandas TimeSeries or DataFrame only, 
    possibly extend to more general numpy arrays

"""


import numpy as np
import pandas as pd


def peaks_over_threshold(timeseries,threshold,peak_dist=1):
    """
    This function finds peaks (local maxima) in an input signal, e.g. a hydro-
    graph, based on a threshold value. A peak is a data sample that is larger 
    than its two neighboring samples AND the largest sample within a moving 
    time window. 
    
    The peaks greater than the given threshold are selected.
    
    Inputs
    timeseries:  list, nummpy array, pandas Series or DataFrame with 1 column
                    from which a peak should be detected
    threshold:   minimum value of peaks 
    peak_dist:   min distance between to peaks, defines time window (optional, default=1)
    
    Output
    POT:         pandas Series with date and value of peaks
    """
    
    # make sure timeseries is a pandas datafreme object
    x = pd.DataFrame(timeseries)
    name = x.columns[0]
    
    # find peaks based on second order diff; correct for flats
    x['peak'] = False # create boolean to qualify peaks
    trend = np.sign(np.diff(x[name].values))
    idx = np.where(trend==0)[0] # find flats
    N = len(trend)
    for i in np.flipud(idx):
        if trend[np.min([i+1,N-1])] >= 0:
            trend[i] = 1
        else:
            trend[i] = -1 # flat peaks       
    idx = np.where(np.diff(trend)==-2)[0] + int(1) # find all peaks
    x['peak'].iloc[idx] = True
    
    # find data above threshold
    if threshold is not None:
        x['thrh'] = x[name] >= threshold
        x['peak_value'] = x[name][x['peak'] & x['thrh']]  
    else:
        x['peak_value'] = x[name][x['peak']]  
    
    # find max peak within window idx-dist <> idx+dist  
    if peak_dist > 1:
        x['peak_value'] = minDistBetweenPeaks(x['peak_value'],peak_dist)
           
    # create pandas series with peaks only
    POT = x[name][x['peak_value'].notnull()]
    return POT

def minDistBetweenPeaks(peakts,peak_dist):
    """
    find max peak within window idx-dist <> idx+dist 
    
    peakts is a timeseries filled with nan's exept for peaks
    
    """
    # find max peak within window idx-dist <> idx+dist      
    peak_dist = int(peak_dist)
    x = peakts.copy()
    # find peaks with neighboring peaks within peak_dist
    npeaks = pd.rolling_count(peakts,window=2*peak_dist+1,center=True)
    # start with largest peak and eliminate peaks within peak_dist 
    pks_sort = peakts[(npeaks>1)  & (peakts.notnull())].order(ascending=False)
    for date in pks_sort.index:
        if np.isnan(x.loc[date]) == False:
            idx= np.where(x.index==date)[0]
            x.iloc[np.max([0,idx-peak_dist]):idx] = np.nan
            x.iloc[idx+1:idx+peak_dist+1] = np.nan
    
    return x


def find_n_peaks(timeseries,n_peaks,threshold=None,peak_dist=1):
    """
    This function finds peaks (local maxima) in an input signal, e.g. a hydro-
    graph, based on a number of peaks. A peak is a data sample that is larger 
    than its two neighboring samples AND the largest sample within a moving 
    time window. 
    
    The n largest peaks are selected. In case less then n peaks are found, a
    warning message is returned.
    
    Inputs
    timeseries:  pandas Series or DataFrame from which a peak should be detected
    threshold:   minimum value of peaks (optional, default=None)
    peak_dist:   min distance between to peaks, defines time window (optional, default=1)
    
    Output
    NP:          pandas Series with date and value of peaks
    
    """
   
    # run standard function to find all peaks
    POT_all = peaks_over_threshold(timeseries,threshold=threshold,peak_dist=peak_dist)
    
    n_peaks = int(n_peaks)
    N = len(POT_all)
    
    # select n_peaks largest peaks
    if N > n_peaks:
        pks = np.sort(POT_all.values)
        thrh_new = pks[N-n_peaks]
        idx = np.where(POT_all.values>=thrh_new) 
        NP = POT_all.iloc[idx]
    elif N == n_peaks:
        NP = POT_all
    else:
        print 'with the given threshold and peak distance, only ' + str(N) + ' from the required ' + str(n_peaks) + ' peaks were found'
        
       
    return NP

def block_max(timeseries,freq,threshold=None,peak_dist=1,realpeak=False):
    """
    This function finds peaks (local maxima) in an input signal, e.g. a hydro-
    graph. A peak a data sample that is largest sample within a moving time 
    window (block). 
    
    Similar to annual max.
    
    Inputs
    timeseries:  pandas Series or DataFrame from which a peak should be detected
    freq:        pandas Frequency string snotation, e.g.:
                    D   calendar day frequency
                    W   weekly frequency
                    M   month end frequency
                    Q   quarter end frequency
                    A   year end frequency
                    AS  year start frequency
                    H   hourly frequency
                    T   minutely frequency
                    S   secondly frequency
                    L   milliseconds
                    U   microseconds
    threshold:   minimum value of peaks (optional, default=None)
    peak_dist:   min distance between to peaks, defines time window (optional, default=1)
    realpeak:    TRUE: peak should be larger than both neighboring data samples
                 FAlse: peak is maximum sample, regardless neighboring samples
    
    Output
    BM:          pandas Series with date and value of peaks
    """
        
    if realpeak == True:
        # run standard function to find all 'real' peaks
        ts = peaks_over_threshold(timeseries,threshold=threshold,peak_dist=peak_dist)
    elif realpeak == False:
        # make sure timeseries is a pandas datafreme object
        ts = pd.DataFrame(timeseries) 

    # select block maxima
    BM = ts.resample(freq, how='max')
    BM = BM[BM.values>=0]
    npeak = len(BM)
    
    # find dates block maixma
    idx = np.zeros([npeak])
    for i,peak in enumerate(BM.values):
        if i+1 < npeak:
            idx1 = np.where(ts.index == BM.index[i+1])[0]
        else:
            idx1 = -1    
        idx0 = np.where(ts.index == BM.index[i])[0]
        idx[i] = int(idx0 + np.where(ts.iloc[idx0:idx1].values == peak)[0][-1])
        
    BM.index = ts.index[idx.astype(int)]
    
    return BM

def annual_max(timeseries,first_month='jan',threshold=None,peak_dist=1):
    """
    This function finds peaks (local maxima) in an input signal, e.g. a hydro-
    graph. A peak is a data sample that is larger than its two neighboring 
    samples AND the largest sample within a moving time window. 
    
    The largest annual peak is returned
    
    Inputs
    timeseries:  pandas Series or DataFrame from which a peak should be detected
    first_month: the first month of the calender under consideration in ref 
                 to the gregorian calender. Both integers and strings are ok
                 i.e.: 1,2,...,12 OR 'jan', 'feb', 'mar', 'apr', 'may', 'jun', 
                 'jul', 'aug', 'sep', 'oct', 'nov', 'dec'
                 (optional, default='jan')
    threshold:   minimum value of peaks (optional, default=None)
    peak_dist:   min distance between to peaks, defines time window (optional, default=1)
    
    Output
    AM:          pandas Series with date and value of peaks
    """
       
    # define calender and frequency
    if type(first_month) == int:
        months = ['jan', 'feb', 'mar', 'apr', 'may', 'jun','jul', 'aug', 'sep', 'oct', 'nov', 'dec']
        first_month = months[first_month-1]
        print first_month
    freq = 'AS-' + first_month

    # get AM using block_max
    AM = block_max(timeseries,freq,threshold,peak_dist,realpeak=True)
    
    return AM

def cluster_max(timeseries,threshold,peak_dist=1):
    """
    This function finds peaks (local maxima) in an input signal, e.g. a hydro-
    graph. A peak is a data sample that is larger than its two neighboring 
    samples AND the largest sample within a cluster. A cluster is defined as
    the data samples between the point where the signal becomes larger than the 
    threshold and the point where it becomes smaller again. 
    
    Inputs
    timeseries:  pandas Series or DataFrame from which a peak should be detected
    first_month: the first month of the calender under consideration in ref 
                 to the gregorian calender. Both integers and strings are ok
                 i.e.: 1,2,...,12 OR 'jan', 'feb', 'mar', 'apr', 'may', 'jun', 
                 'jul', 'aug', 'sep', 'oct', 'nov', 'dec'
                 (optional, default='jan')
    threshold:   minimum value of peaks (optional, default=None)
    peak_dist:   min distance between to peaks, defines time window (optional, default=1)
    
    Output
    CM:          pandas Series with date and value of peaks
    """
       
    # make sure timeseries is a pandas datafreme object
    x = pd.DataFrame(timeseries)
    col = x.columns[0]
    
    # find peaks based on diff of the sign of the series (sample - threshold)
    # when the sign changes from negative to positive a cluster starts
    # when the sign changes from positive to negative the cluster ends
    cross_thresh = np.diff(np.sign(x[col]-threshold)); 
    x['idx'] = np.sign(np.append(cross_thresh[0], cross_thresh))
    # check first and last cluster
    if x['idx'][x['idx']>0].values[-1] == 1: # close last cluster if unclosed
        x['idx'].iloc[-1] = -1 
    if x['idx'][x['idx']>0].values[0] == -1: # start first cluster if signal strarts with value larger then threshold
        x['idx'].iloc[0] = 1 
    
    # find max values of each clusters; if two identical max values are found the
    # the first is chosen as peak
    x['peak_value'] = np.nan
    for istart,iend in zip(np.where(x['idx']==1)[0], np.where(x['idx']==-1)[0]):
        peak = x[col].iloc[istart:iend].max()
        idx = int(np.where(x[col].iloc[istart:iend] == peak)[0][0] + istart)
        x['peak_value'].iloc[idx] = peak
            
    # find max peak within window idx-dist <> idx+dist  
    if peak_dist > 1:
        x['peak_value'] = minDistBetweenPeaks(x['peak_value'],peak_dist)    
        
    CM = x[col][x['peak_value'].notnull()]
 
    return CM

        
        
        
