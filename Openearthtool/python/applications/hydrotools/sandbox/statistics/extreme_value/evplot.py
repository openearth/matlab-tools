# -*- coding: utf-8 -*-
"""
Created on Wed Jan 14 11:36:58 2015

@author: eilan_dk (dirk.eilander@deltares.nl)
v0.1 26/01/2016

"""

import pandas as pd
import numpy as np
import matplotlib.pyplot as plt 

#%% functies
def returnlevel(rv=[],sample=None,lambd=1,ax=None,title='Return Level plot ',xlab='return period [years]',
                ylab='return level',legend=None,xlim=None,ylim=None,styles=None,samplestyle=None):
    """
    function for standard return level plots for one or more lines
    returning a matplotlib figure   
    
    inputs    
    rv ---- EITHER a numpy array with first the return periods in the first col
            and according values in the second, third ... etc col
            OR a pandas series / dataframe with the return period as index
    sample- sample data to wich rv is fitted
    ax ---- matplotlib axis object, default None
    title - string with figure title
    xlab -- string with x label figure
    ylab -- string with y label figure
    legend- IF rv is numpy array: list with legend names
            ELIF rv is pandas / dataframe: overwrites column names
    xlim -- tuple/ list with lower and upper boundary x-axis
    ylim -- tuple/ list with lower and upper boundary y-axis
    style - list or dict: matplotlib line style per columno of rv

    output
    fig --- matplotlib figure
    """
    # construct dataframe from numpy array if rv is numpy array and assign 
    # laabel rv to columns
    if type(rv) is np.ndarray:
        if legend is not None:
            plotdat = pd.DataFrame(rv[1,:], index=rv[0,:], columns=legend)
        else:
            plotdat = pd.DataFrame(rv[1,:], index=rv[0,:])
    else:
        plotdat = rv
    
    if sample is not None:
        npeak=len(sample)
        ys=np.sort(sample)
        y = []
        for i in range(npeak):
            y.append(float(npeak+1)/((npeak+1-(i+1))*(lambd)))
        sampleplot = pd.DataFrame(index=y,data=ys)

    if xlim is None:
        xlim = [plotdat.index.min(), plotdat.index.max()]
    if ylim is None:
        ylim = [plotdat.min().min()*0.9, plotdat.max().max()*1.1]
    
    if samplestyle is None:
        samplestyle = '.k'
    # plot figure  
    if ax is None:
        fig, ax = plt.subplots(nrows=1, ncols=1)
    if sample is not None:
        sampleplot.plot(ax=ax, style=samplestyle, logx=True, xlim=xlim, 
             ylim=ylim, legend=False)
    plotdat.plot(ax=ax, style=styles, logx=True, xlim=xlim, 
                 ylim=ylim, legend=False)
    ax.set_title(title, fontsize=10)
    if legend is not None:
        ax.legend(legend,loc=2)
    plt.ylabel(ylab)
    plt.xlabel(xlab)
    
    if ax is None:
        return fig
    else:
        return ax
    
def returnlevel_ci(rv=[],sample=None,lambd=1,ax=None,title='Return Level plot ',
                   xlab='return period [years]', ylab='return level',
                   legend=['sample','return level','95% confidence interval'],
                   xlim=None,ylim=None,styles=['k-','k:','k:']):
    """
    function for standard return level plots for one line with 95% (dafualt) 
    confidence intervals. 
    
    uses standard returnlevel function with pre-defined style and legend
    
    see returnlevel for the input and output parameters

    """
    f = returnlevel(rv,sample=sample,lambd=lambd,ax=ax,title=title,xlab=xlab,ylab=ylab,
                     legend=legend,xlim=xlim,ylim=ylim,styles=styles)

    return f
    
    
