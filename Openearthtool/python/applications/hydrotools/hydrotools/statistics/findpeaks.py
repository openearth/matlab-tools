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
import warnings


def getPeaks_ts(Qts, freq=None, thresh=None, n_peaks=None,
                peak_dist=None, dist_freq='d'):
    """function to derive peaks from pandas Series object.
    Here, a peak is defined as any value surrounded by two lower values.
    The function returns a pandas.Series object with peak dates and values

    Set a frequency <freq> to derive block maxima, <freq> can be any
        pandas.TimeGrouper frequency string.
    Set a threshold <thresh> to derive only peaks over threshold
    Set a number of peaks <n_peaks> to derive the n largest peaks
    Set a distance <peak_dist><dist_freq> to ensure independent peaks based on
        a minimum distance between peaks

    Examples:
    to derive annual maxima (AM) peaks with the hydrological year starting in Oct:
        getPeaks_ts(Qts, freq='A-Sept')
    to derive peaks over threshold (POT; value=X) with a min. 30day distance
    between independent peaks:
        getPeaks_ts(Qts, thresh=X, peak_dist=30, dist_freq='d')
    to derive the 10 largest peaks with a min. 60s distance between independent
    peaks:
        getPeaks_ts(Qts, n_peaks=10, peak_dist=60, dist_freq='s')
    """
    assert type(Qts) == pd.Series, "invalid dtype for Qts, should be pandas.Series object"
    # nans are replaced by -np-inf to find peak values before/after nans
    d1 = Qts.fillna(-np.inf).diff().apply(np.sign) # sign of first derivative
    d2 = d1.where(d1 != 0).dropna().diff().shift(-1) # "where(d1 != 0).dropna()"" to remove flats.
    Qpeak = Qts.where(d2==-2).dropna() # peaks only
    if peak_dist is not None:
        # calculate threshold based on moving maxima to remove smaller peaks within peak dist of largest local peak
        thresh2 = Qpeak.resample(dist_freq).asfreq().fillna(-np.inf).rolling(peak_dist*2, center=True, min_periods=1).max()
        thresh = pd.concat([thresh2, pd.Series(index=Qpeak.index, data=thresh)], axis=1).loc[Qpeak.index].min(axis=1)
    if thresh is not None: # apply threshold
        Qpeak = Qpeak.where(Qpeak >= thresh).dropna()
    if n_peaks is not None:
        Qpeak = Qpeak.nlargest(n_peaks)
    if freq is not None: # calculate freq (block) maxima
        dates, values = [], []
        for name, group in list(Qpeak.groupby(pd.TimeGrouper(freq=freq))):
            if group.size > 0: # empty years may occur.
                dates.append(group.argmax())
                values.append(group.max())
            Qpeak = pd.Series(data=values, index=dates, name=Qts.name)
    return Qpeak

def getPeaks(Q, freq=None, thresh=None, n_peaks=None, peak_dist=None, dist_freq='d'):
    """function to derive peaks from pandas object, see getPeaks_ts for more info"""
    assert type(Q) in [pd.Series, pd.DataFrame], "invalid dtype for Q, should be pandas object"
    peakf = lambda x: getPeaks_ts(x, freq=freq, thresh=thresh, n_peaks=n_peaks,
                                  peak_dist=peak_dist, dist_freq=dist_freq)
    if type(Q) == pd.Series:
        Qpeaks = peakf(Q)
    else:
        assert len(np.unique(Q.columns)) == len(Q.columns), "column names should be unique"
        Qpeaks = pd.concat([peakf(Q.loc[:, col]) for col in Q.columns], axis=1)
    return Qpeaks

####DEPRECATED#########################

def peaks_over_threshold(timeseries, threshold, peak_dist=1, dist_freq='d'):
    """
    shouldn't use this function anymore! Now use getPeaks.
    """
    warnings.warn(
        "shouldn't use this function anymore! Now use getPeaks.",
        DeprecationWarning
    )
    return getPeaks(timeseries, freq=None, thresh=threshold, n_peaks=None,
                    peak_dist=peak_dist, dist_freq=dist_freq)


def find_n_peaks(timeseries, n_peaks, threshold=None, peak_dist=1, dist_freq='d'):
    """
    shouldn't use this function anymore! Now use getPeaks.
    """
    warnings.warn(
        "shouldn't use this function anymore! Now use getPeaks.",
        DeprecationWarning
    )
    return getPeaks(timeseries, freq=None, thresh=threshold, n_peaks=n_peaks,
                    peak_dist=peak_dist, dist_freq=dist_freq)


def block_max(timeseries, freq, threshold=None, peak_dist=1, realpeak=False, dist_freq='d'):
    """
    shouldn't use this function anymore! Now use getPeaks.
    realpeak input is ignored!
    """
    warnings.warn(
        "shouldn't use this function anymore! Now use getPeaks.",
        DeprecationWarning
    )
    return getPeaks(timeseries, freq=freq, thresh=threshold, n_peaks=n_peaks,
                    peak_dist=peak_dist, dist_freq=dist_freq)


def annual_max(timeseries, first_month='jan', threshold=None, peak_dist=1, dist_freq='d'):
    """
    shouldn't use this function anymore! Now use getPeaks.
    """
    warnings.warn(
        "shouldn't use this function anymore! Now use getPeaks.",
        DeprecationWarning
    )
    # define calender and frequency
    if type(first_month) == int:
        months = ['jan', 'feb', 'mar', 'apr', 'may', 'jun','jul', 'aug', 'sep', 'oct', 'nov', 'dec']
        first_month = months[first_month-1]
        print(first_month)
        freq = 'AS-' + first_month
    return getPeaks(timeseries, freq=freq, thresh=threshold, n_peaks=n_peaks,
                    peak_dist=peak_dist, dist_freq=dist_freq)


##### needs to be replaced.
def cluster_max(timeseries,threshold,peak_dist=1):
    """
    This function finds peaks (local maxima) in an input signal, e.g. a hydro-
    graph. A peak is a data sample that is larger than its two neighboring
    samples AND the largest sample within a cluster. A cluster is defined as
    the data samples between the point where the signal becomes larger than the
    threshold and the point where it becomes smaller again.

    Inputs
    timeseries:  pandas Series or DataFrame from which a peak should be detected
    threshold:   minimum value of peaks (optional, default=None)
    peak_dist:   min distance between to peaks, defines time window (optional, default=1)

    Output
    CM:          pandas Series with date and value of peaks
    """
    # make sure timeseries is a pandas datafreme object
    x = preprocess_ts(timeseries, peak_dist)
    # x = pd.DataFrame(timeseries)
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
        # true if max in window
        x['max_wndw'] = x['peak_value'].fillna(np.nanmin(x['peak_value'].values)).rolling(
            window=2*peak_dist+1, center=True, min_periods=0).max() == x['peak_value']
        # update peak values based on max in window
        x['peak_value'] = x[name][x['max_wndw']]

    CM = x[col][x['peak_value'].notnull()]

    return CM

    def preprocess_ts(timeseries, peak_dist=1):
        if type(timeseries) == pd.core.series.Series:
            x0 = pd.DataFrame(timeseries)
        elif type(timeseries) == pd.core.frame.DataFrame:
            assert timeseries.shape[1] <= 1, "Invalid shape of pandas DataFrame, single column only"
            x0 = timeseries.copy()
        else:
            raise ValueError("Invalid input. Use pandas Series, single-columns DataFrame")

        global_fill = np.nanmin(x0[x0.notnull().values])-1
        x0.iloc[-1] = np.nanmax([global_fill, x0.iloc[-1]]) # make sure last value is not nan

        # first fill by propagating values until dist = peak_dist
        # then fill with global minimum
        x = x0.fillna(method='ffill', limit=peak_dist).fillna(global_fill)
        return x
