# -*- coding: utf-8 -*-
"""
Created on Tue Mar 10 11:46:39 2015

@author: eilan_dk (dirk.eilander@deltares.nl)
v1.1 13/01/2016

"""

import numpy as np
import pandas as pd
import scipy.stats as ss
import matplotlib.pyplot as plt
import matplotlib.dates as dates
import sys


def SPI(P, nmonth=1, dist='gamma', parh=None, alt=True):
    """
    The standardized precipitation index (SPI) is probability based indicator 
    for abnormal wetness and dryness [1,2]. The SPI can be applied for different 
    time scales of precipitation (usually 1 - 24 months). For reliable results 
    a timeseries longer than 30 years is required.
    
    input
    P       pandas timeseries for precipitation with freq given
    nmonth  time resolution in months
            (default:  1)
    dist    distribution type 'gamma' (default) - only option so far
    alt     if alt==True the alpha and beta shape and scale parameters are calculated
            using equations provided in for instance publication of Giddings et al. 2005
            (default: True)
    parh    parameters [alpha, loc, beta] for gamma distribution
            if 'None', the parameters will be fitted to the data
            numpy array with shape (12L,3L)
            (default: None)
            when defined for each month or ( if known 'None' (default)

    output
    SPI - timeseries of SPI
    
    --------------------------------------------------------------------------    
    Calculation procedure:
    The first step in calculating the SPI is to determine a probability density 
    function that describes the long term time series of precipitation 
    observations. The series can be for any time scale (i.e., running series 
    of total precipitation for 1 month, 2 months, 6 months, 1 year, 3 years, 
    etc.) Once the probability density function is determined, the cumulative 
    probability of an observed precipitation amount is computed. The inverse 
    normal (Gaussian) function, with mean zero and variance one, is then 
    applied to the cumulative probability. The result is the SPI
        
    [1] McKee, T. B, N. J. Doeskin, and J. Kieist, 1993. The Relationship of
    Drought Frequency and Duration to Time Scales. Proc. 8th
    Conf. on Applied Climatology, January 17-22, 1993, American
    Meteorological Society, Boston, Massachusetts, pp. 179-184.
    [2] McKee, T. B, N. J. Doeskin, and J. Kieist, 1995. Drought Monitor.
    ing with Multiple Time Scales. Proc. 9th Conf. on Applied Climatology,
    January 15-20, 1995, American
    
    TODO
    --> add Pearson Type III distribution
    """
    X = input2pdSeries(P)

    if nmonth > 1:
        Pout = pd.rolling_mean(X.copy(), window=int(nmonth)) #, freq='M')
    else:
        Pout = X.copy()

    # group months
    nts = len(Pout)
    firstmonth = Pout.index.month[0]
    Pgrouped_months = Pout.groupby(Pout.index.month)
    spi_arr = np.empty(nts)
    parh_out = []

    for month, Pmonth in Pgrouped_months:
        startidx = (month - firstmonth)
        if startidx < 0:
            startidx += 12

        # fit probability distriibution to data
        if dist == 'gamma':
            if parh is None:
                alpha, loc, beta, q = calibrate_gamma(Pmonth.values, alt)
            elif type(parh) == np.ndarray:
                q, _ = calc_prob_zero(Pmonth.values)
                if parh.shape == (3L,):
                    alpha, loc, beta = parh
                elif parh.shape == (12L, 3L):
                    alpha, loc, beta = parh[month-1, :]
                elif parh.shape == (3L, 12L):
                    alpha, loc, beta = parh[:, month-1]
            else:
                print "incorrect parameter set, should be numpy array with shape==(12L,3L)"
                sys.exit(1)

            parh_out.append([alpha, loc, beta])
            rv = ss.gamma(alpha, loc=loc, scale=beta)
        else:
            print "distribution type unknown, only 'gamma'"

        cdf = q + (1 - q) * rv.cdf(Pmonth.values)  # calculate cumulative probability
        spi_vals = ss.norm.ppf(cdf)  # transform to normal gaussian to calculate SPI
        endidx = min(startidx + len(spi_vals) * 12, nts)
        spi_arr[startidx:endidx:12] = spi_vals

    SPI = pd.Series(spi_arr, index=Pout.index)
    SPI.name = 'SPI'

    return SPI, np.array(parh_out)


def SPEI(P, PET, nmonth=1, dist='gamma', parh=None, alt=True):
    """
    The Standardized Precipitation Evapotranspiration Index (SPEI) [1] is an 
    extension of the widely used Standardized Precipitation Index (SPI). The 
    SPEI is designed to take into account both precipitation and potential 
    evapotranspiration (PET) in determining drought. Thus, unlike the SPI, the 
    SPEI captures the main impact of increased temperatures on water demand. 
    Like the SPI, the SPEI can be calculated on a range of timescales from 1-48 
    months. 
    
    input
    P       pandas timeseries for precipitation (with timeseries freq given)
    PET     pandas timeseries for potential evaporation (with timeseries freq 
            given) 
    nmonth  time scale in months (default = 1 )
    dist    distribution type 'gamma' (default) - more to be added
    parh    distribution parameters if known 'None' (default)
    
    output
    SPEI - timeseries of SPEI
    
    --------------------------------------------------------------------------    
        
    [1] Vicente-Serrano, S. M., S. Beguería, and J. I. López-Moreno. "A 
    multiscalar drought index sensitive to global warming: the standardized 
    precipitation evapotranspiration index." Journal of Climate 23.7 (2010): 
    1696-1718.
    
    """
    Pin = input2pdSeries(P)
    PETin = input2pdSeries(PET)

    D = Pin - PETin

    SPEI, parh = SPI(D, nmonth=nmonth, dist=dist, parh=parh, alt=alt)
    SPEI.name = 'SPEI'

    return SPEI, parh


def percentile_thresh(var, percentile=80, nmonth=1):
    """
    calculates threshold based on nmonth flow/stage percentile
    returns a time series with same index as input with threshold value at each step
    the timeseries is smoothed if the index timestep is < nmonth
    
    input
    var     pandas timeseries for storage / discharge
    nmonth  number of months over which to calculate threshold [1,2,3,4,6,12]
    
    """

    X = input2pdSeries(var)
    dt = round((X.index[-1] - X.index[0]).total_seconds() / 3600 / 24 / len(X))  # average dt in days

    # resample to nmonth periods
    Xres = X.copy().resample(str(int(nmonth)) + 'MS', how=np.nanmean, label='left')

    # calcualte flow duration curve percentile per period = threshold
    grouped = Xres.groupby(lambda x: x.month)
    thresh = grouped.aggregate(lambda x: np.percentile(x, 100 - percentile))

    # assing thresholdvalues to timeseries
    thresh_ts = pd.Series(index=X.index, name='thresh')
    for i, m0 in enumerate(thresh.index):
        if i < len(thresh) - 1:
            m1 = thresh.index[i + 1]
            thresh_ts[(thresh_ts.index.month >= m0) & (thresh_ts.index.month < m1)] = thresh.iloc[i]
        elif i == len(thresh) - 1:
            m1 = thresh.index[0]
            thresh_ts[(thresh_ts.index.month >= m0) | (thresh_ts.index.month < m1)] = thresh.iloc[i]

            # smooth threshold timeseries
    window = 30 / dt * nmonth  # number of timesteps in window
    if window > 1:
        thresh_ts = pd.rolling_mean(thresh_ts, window=30 / dt * nmonth, min_periods=1)

    return thresh_ts


def drought_deficit(var, thresh):
    """
    Calculates the drought deficit volume as the difference between threshold
    and observed value at each timestep
    
    input
    var     pandas timeseries for storage / discharge
    thresh  threshold value
    
    output
    DDV     pandas timeseries with drought deficit volume
    """
    X = input2pdSeries(var)

    # calc time series for drought deficit volume - no pooling
    short = thresh - X
    short[short <= 0] = 0
    DDV = pd.Series(index=X.index, data=short.values, name='Drought Deficit')

    ## cluster droughts
    clusters = cluster_values_above_thresh(DDV)

    ## calculate drought properties
    droughts = drought_properties(DDV, clusters)

    return DDV, droughts
	

def drought_deficit_pooling(var, thresh, min_spacing=1):
    """
    Calculates the drought deficit volume, i.e. volume below a threshold with 
    the sequential peak algorithm [1]. 
    
    max cumulative drought deficit volume (si), duration to max cumsum deficit (di) 
    date max cumsum deficit (ti),
    
    input
    var     pandas timeseries for storage / discharge
    thresh  threshold value
   
    output
    DDV     pandas timeseries with drought deficit volume
    drought pandas dataframe with max drought deficit volume (vi), drought 
            duration (di) and date of max drought deficit (ti)
            
    [1] Tallaksen, L. M., Madsen, H., & Clausen, B. (1997). On the definition 
    and modelling of streamflow drought duration and deficit volume. 
    Hydrological Sciences Journal, 42(1), 15-33.
    """

    X = input2pdSeries(var)
    thresh = input2pdSeries(thresh)

    # calc time series for drought deficit volume    
    short = thresh - X

    # apply pooling alogirth
    ddv = [0]
    for shorti in short:
        ddv.append(ddv[-1] + shorti)
        if ddv[-1] <= 0:
            ddv[-1] = 0
    DDV = pd.Series(index=X.index, data=ddv[1:], name='Drought Deficit')

    ## cluster droughts
    clusters = cluster_values_above_thresh(DDV, min_spacing=min_spacing)

    ## calculate drought properties
    droughts = drought_properties(DDV, clusters)

    return DDV, droughts


def calc_prob_zero(unsortedsamples):
    # sort samples and discard NaN (makes a copy)
    samples = np.sort(unsortedsamples[~np.isnan(unsortedsamples)])
    # compute probability of zero rainfall
    n = len(samples)

    if n == 0:
        prob_zero = 0.0
    else:
        prob_zero = float(sum(samples == 0.0)) / n

    return prob_zero, samples


def calibrate_gamma(unsortedsamples, alt=False, plot=False):
    """
    This function fits a gamma distribution from a number of samples. It can be tested
    whether the process fits a Gamma distribution, because the function exports besides
    the fit parameters alpha and beta both the empirical plotting positions
    (x/(n+1)) and the plotting positions based on the fitted Gamma distribution.
    These can be used to construct goodness of fit or Q-Q plots
    Input:
        samples            : the samples from the process, to be described by
                             the Gamma distribution
    Output:
        alpha              : the shape parameter of the distribution
        loc                : the location (mean) parameter of the distribution
        beta               : the scale parameter of the distribution
        prob_zero          : the probability of zero-rainfall
        plot_pos_emp       : empirical plotting positions
        plot_pos_par       : parameterized plotting positions

    If the `alt` keyword argument is set true,
    the alpha and beta shape and scale parameters are calculated using equations provided in
    for instance publication of Giddings et al. 2005

    credits: Hessel Winsemius
    """
    prob_zero, samples = calc_prob_zero(unsortedsamples)

    s = samples[samples > 0]
    s_u = np.log(s.mean()) - np.log(s).mean()
    # following method described in Giddings et al. 2005 and the spi.pdf
    # only for monthly precipitation > 0
    alpha = (1/(4*s_u))*(1+np.sqrt(1+(4*s_u)/3))
    loc = 0
    beta = s.mean()/alpha
    # fit 2 par gamma (loc=0) using scipy fit function and initial estimate
    if not alt:
        a = ss.gamma.fit(samples[samples > 0], floc=0, a=alpha, scale=beta)
        alpha = a[0]
        beta = a[2]

    if plot:
        # empirical plot positions
        plot_pos_emp = (np.arange(0, n) + 0.5) / (n + 1)
        samples_continuous = np.linspace(s.min(), s.max(), num=10000)
        # compute parametrized plot positions
        plot_pos_par = ss.gamma.cdf(samples, alpha, loc=loc, scale=beta)
        plot_pos_cont = ss.gamma.cdf(samples_continuous, alpha, loc=loc, scale=beta)
        # correct for no rainfall probability
        plot_pos_par = prob_zero + (1 - prob_zero) * plot_pos_par
        plot_pos_par[samples == 0.0] = 0.0
        plot_pos_emp[samples == 0.0] = 0.0
        plot_pos_cont = prob_zero + (1 - prob_zero) * plot_pos_cont
        return alpha, loc, beta, prob_zero, samples_continuous, plot_pos_cont, plot_pos_emp, plot_pos_par

    return alpha, loc, beta, prob_zero


def plot_drought_deficit(var, thresh, DDV, ax=None, styles=['k', '--k', 'red', 'r']):
    # data bookkeeping (omslachtig!!)
    var = input2pdSeries(var)
    thresh = input2pdSeries(thresh)
    DDV = input2pdSeries(DDV)
    x = dates.date2num(var.index.date)
    locator = dates.YearLocator(5)
    y1 = var.values
    y2 = thresh.values
    y3 = DDV.values
    dy1 = np.max(y1) - np.min(y1)
    dy3 = np.max(y3)
    y1lim = [np.min(y1)-0.05*dy1,np.max(y1)+np.max([dy3,0.5*dy1])] #[5, 20]  # 
    y3lim = [(y1lim[1]-y1lim[0]), 0] # [15, 0]  # 
    if dy1>dy3:
        yrange = np.max(y1)-np.min(y1)
        if np.max(y1) > 0:
            y1lim = [np.min(y1)*0.95, np.max(y1)+(np.max(y1)-np.min(y1))*0.5]
        elif np.max(y1) <= 0:
            y1lim = [np.min(y1)*1.1, np.max(y1)*1/1.5]
            y3lim = [y1lim[1]-y1lim[0], 0]
        elif dy3>=dy1:
            y1lim = [np.min(y1)*0.95, np.min(y1)*0.95+dy3*1.2]
            y3lim = [dy3*1.2, 0]

    if ax is None:
        fig, ax = plt.subplots(nrows=1, ncols=1)
    ax.fill_between(x, y1, y2, where=y2 >= y1, facecolor=styles[2], alpha=0.8, interpolate=True)
    ax.plot_date(x, y1, fmt=styles[0], tz=None, xdate=True)
    ax.plot_date(x, y2, fmt=styles[1], tz=None, xdate=True)
    ax.set_ylim(y1lim)
    ax.set_xlim([x[0], x[-1]])
    ax.xaxis.set_major_locator(locator)
    #    ax.legend([var.name,thresh.name],loc=6)
    ax.legend([var.name, thresh.name], loc='lower left', bbox_to_anchor=(0, 1), ncol=2)

    ax1 = ax.twinx()
    ax1.plot_date(x, y3, fmt=styles[3], tz=None, xdate=True)
    ax1.set_ylim(y3lim)
    #    ax1.legend([DDV.name],loc=5)
    ax1.legend([DDV.name], loc='lower right', bbox_to_anchor=(1, 1))
    if ax is None:
        return fig
    else:
        return ax, ax1


def plot_SPI_timeseries(SPI1, SPI2=None, SPI3=None, ax=None, styles=['--k', 'k', ':k']):
    # data bookkeeping (omslachtig!!)
    SPI1 = input2pdSeries(SPI1)
    x = dates.date2num(SPI1.index.date)
    locator = dates.YearLocator(5)
    y1 = SPI1.values
    legend = [SPI1.name]

    if ax is None:
        fig, ax = plt.subplots(nrows=1, ncols=1)

    ax.axhspan(-1.97, -2.03, facecolor='r', alpha=1, edgecolor='none')
    ax.axhspan(-0.97, -1.03, facecolor='r', alpha=0.3, edgecolor='none')
    ax.axhspan(0.97, 1.03, facecolor='b', alpha=0.3, edgecolor='none')
    ax.axhspan(1.97, 2.03, facecolor='b', alpha=1.0, edgecolor='none')
    ax.plot_date(x, y1, fmt=styles[0], tz=None, xdate=True)
    if SPI2 is not None:
        SPI2 = input2pdSeries(SPI2)
        legend.append(SPI2.name)
        ax.plot_date(dates.date2num(SPI2.index.date), SPI2.values, fmt=styles[1], tz=None, xdate=True)
    if SPI3 is not None:
        SPI3 = input2pdSeries(SPI3)
        legend.append(SPI3.name)
        ax.plot_date(dates.date2num(SPI3.index.date), SPI3.values, fmt=styles[2], tz=None, xdate=True)

    ax.set_xlim([x[0], x[-1]])
    ax.set_ylim([-3, 3])
    ax.xaxis.set_major_locator(locator)

    ax.set_ylabel('Stand. Precipitation Index')
    ax.legend(legend, loc=9, ncol=len(legend))

    if ax is None:
        return fig, ax
    else:
        return ax

def drought_properties(DDV, clusters):
    df = pd.DataFrame(index=DDV.index, columns=['ddv'], data=DDV.values);
    df['cluster'] = clusters
    df['org'] = -DDV
    grouped = df.groupby(['cluster'])
    droughts = pd.DataFrame(columns=['si', 'di', 'ti', 'sum', 'tstart', 'tend'], index=grouped.first().index)
    for igroup, x in grouped:
        i = np.cumsum(x['cluster'] / x['cluster'])
        si = x['ddv'].max()
        droughts['si'].loc[igroup] = si  # max drought deficit volume
        droughts['di'].loc[igroup] = i[x['ddv'] == si].values[0]  # drought duration
        droughts['ti'].loc[igroup] = x.index[x['ddv'] == si].values[0]  # t max drought deficit
        droughts['tstart'].loc[igroup] = x.index[0]
        droughts['tend'].loc[igroup] = x.index[-1]
        droughts['sum'].loc[igroup] = x['ddv'].sum()
    return droughts


def cluster_values_above_thresh(ts, thresh=0, min_spacing=1):
    df = pd.DataFrame(index=ts.index, data=(ts.values - thresh), columns=['ts'])
    df['sign'] = np.sign(df['ts']);
    df['sign'].iloc[0] = 0
    df['sign'][np.isnan(df['sign'].values)] = 0
    if min_spacing > 1:
        df['spacing'] = np.append(df['sign'].values[0], (np.diff(df['sign']) < 0).cumsum())
        df['spacing'][df['sign'] > 0] = np.nan
        spacing = df.groupby(['spacing']).spacing.count()
        for iclust in spacing.index[spacing <= min_spacing]:
            df['sign'][df['spacing'] == iclust] = 1
    df['cluster'] = np.append(df['sign'].values[0], (np.diff(df['sign']) > 0).cumsum())
    df['cluster'][df['sign'] < 1] = np.nan
    return df['cluster']


def input2pdSeries(Xin):
    if type(Xin) == pd.core.frame.DataFrame:
        Xout = Xin.iloc[:, 0]  # if dataframe convert to timeseries by taking first column
    elif type(Xin) == np.ndarray:
        Xout = pd.Series(Xin)  # create pandas series from numpy array
    else:
        Xout = Xin
    return Xout