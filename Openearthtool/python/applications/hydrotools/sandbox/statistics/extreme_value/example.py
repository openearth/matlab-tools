# -*- coding: utf-8 -*-
"""
Created on Fri Nov 07 18:21:17 2014

@author: eilan_dk
"""

import pandas as pd
import matplotlib.pyplot as plt
import os
import numpy as np

# import local functions
import findpeaks as fp
import evfit  # requires lmoments library!
import evplot

# sample
if __name__ == "__main__":
    DIR = os.path.dirname(os.path.realpath(__file__))
    fname = r'sample_data\hydrograph_DIM.xls'
    outDIR = r'output\plots'
    dist = 'gumb'

    # variables
    threshold = 120
    peak_dist = 30
    first_month = 'OCT'

    # fit ev
    R = np.array([2, 5, 10, 50, 100, 500, 1000])
    lambd = 1  # peaks per year (1 in case of Annual Max)
    Qarray = 1 - 1. / (lambd * R)  # plot position

    # read data
    sample = pd.read_excel(os.path.join(DIR, fname), index_col=0)
    n_peaks = round(len(sample) / 365, 0)  # number of peaks equal to number of years

    for name in sample.columns:
        # get peaks
        # POT = fp.find_n_peaks(sample, n_peaks=n_peaks, threshold=None, peak_dist=peak_dist)
        # POT1 = fp.peaks_over_threshold(sample, threshold=None, peak_dist=peak_dist)
        AM = fp.annual_max(sample[name], first_month=first_month, threshold=None, peak_dist=peak_dist)

        # find gumbel params with l-moments fit and get frozen rv object
        # requires lmoments library!
        rv = evfit.lmfit_gumbel(AM.values)
        # calc quantiles for given range R
        Qrv = rv.ppf(Qarray)
        # calc 95 % confidence intervals with bootstrap
        lb, ub = evfit.CI_bootstrap(AM.values, R, rv, pc=95, nb=1000)
        rv_df = pd.DataFrame(index=R, data=np.vstack((Qrv, lb, ub)).T, columns=['rv', 'lb', 'ub'])

        # plot hydrograph
        legend = []
        fig = plt.figure()
        ax = fig.add_subplot(111)
        sample.plot(ax=ax, style='-b', legend=False)
        legend.append('Discharge')
        AM.plot(ax=ax, style='or')
        legend.append('An. Max.')
        # POT1.plot(ax=ax,style='og',markersize=6, legend=False); legend.append('POT \w n_peaks method')
        # POT.plot(ax=ax,style='or',markersize=3, legend=False); legend.append('POT with threshold method')
        ax.legend(legend, fontsize=10)
        fname_fig = os.path.join(DIR, outDIR, 'hydrograph_' + name + '.png')
        plt.savefig(fname_fig, bbox_inches='tight', transparent=True, dpi=220)

        # gumbel plot
        fig1 = plt.figure(figsize=(7, 5))
        ax1 = fig1.add_subplot(111)
        evplot.returnlevel_ci(rv=rv_df, sample=AM.values, ax=ax1, ylab='daily discharge [m$^3$/s]',
                              legend=None, xlim=[2, 500], ylim=[0, np.max(rv_df['ub'].values)],
                              styles=['k-', 'k--', 'k--'])
        plt.xticks(R[:-1], R[:-1])
        ax1.legend(['An. maxima peak discharge', 'return level  (%s)' % rv.dist.name, '95% confidence interval'],
                   loc=2)
        ax1.grid(which='minor')
        plt.title('Freq. Analysis at ' + name)
        fname_fig = os.path.join(DIR, outDIR, 'rv_' + name + '_' + dist + '.png')
        plt.savefig(fname_fig, bbox_inches='tight', transparent=True, dpi=220)
