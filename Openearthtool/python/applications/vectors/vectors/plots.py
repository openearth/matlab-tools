# -*- coding: utf-8 -*-

# Raw code for VECTORS Kustviewer project. The purpose of the code is to apply a user request
# (click on an icessquare) and generate timerseries of one of the values.

# preparation --> modules
import io
import datetime

import matplotlib
# use non gui backend (before importing rest of matplotlib)
matplotlib.use('Agg')

import pandas
import pandas.io.sql

import psycopg2

import matplotlib.pyplot as plt
import matplotlib.gridspec
import matplotlib.dates as mdates

from read_postgis import get_credentials, executesqlfetch
import logging
logger = logging.getLogger(__name__)

# following species are available
def setspecies():
    dctspecies = {'sound':['Sound',''],
          'sdepth':['Sample depth',''],
          'temperature':['Temperature','degrees C'],
          'salinity':['Salinity','PSU'],
          'doxy':['Dissolved Oxygen',''],
          'phos':['Phosphate concentration','umol/l'],
          'tphs':['',''],
          'slca':['Silica','umol/l'],
          'ntra':['Nitrate concentration','umol/l'],
          'ntri':['Nitrite concentration','umol/l'],
          'amon':['Ammonium concentration','umol/l'],
          'ntot':['Total nitrogen concentration','umol/l'],
          'hs':['',''],
          'phph':['pH',''],
          'alky':['Alkalinity','umol/l'],
          'chpl':['Chlorophyll concentration','mg/m^3']}
    return dctspecies

# Plot the results.
def plot_ts_nc(df, statsq, aspecies, dctspecies):
    fig, ax = plt.subplots()
    df[["yearmonth","concentration"]].groupby("yearmonth").mean().sort().plot(ax=ax)
    ax.set_title('Timeseries of %s (%s) for ICES Square %s' % (dctspecies[aspecies][0], dctspecies[aspecies][1], statsq))
    ax.legend(loc='upper left')
    ax.set_xlabel('date')
    # Create a file like object.
    f = io.BytesIO()
    fig.savefig(f, format='png')
    f.seek(0)
    return f

# create plot
def plotdf(df,statsq,aspecies,dctspecies):
    # Plot the results.
    fig, ax = plt.subplots(1)
    ax.errorbar(df['date'], df['avg'],yerr=df['stddev_samp'],fmt='r',label='stddev_samp')
    ax.plot(df['date'], df['avg'],color='b',label='avg '+aspecies)
    fig.autofmt_xdate()
    ax.set_title('Timeseries of %s (%s) for ICES Square %s' % (dctspecies[aspecies][0], dctspecies[aspecies][1], statsq))
    ax.fmt_xdata = mdates.DateFormatter('%Y-%M-%d')
    ax.legend(loc='upper left')
    ax.set_xlabel('date')
    ax.set_ylabel(aspecies+' in '+dctspecies[aspecies][1])
    ax.grid()
    # Create a file like object.
    f = io.BytesIO()
    fig.savefig(f, format='png')
    f.seek(0)
    return f

def plot_ts_nc_pgm(lstdfs, labels, dfpg, statsq, aspecies, dctspecies):
    fig, ax = plt.subplots(1)
    
    if len(lstdfs) > 1:
        for df in lstdfs:
            logger.info(df.head())
    else:
        logger.info(lstdfs[0].head())

    logger.info(dfpg.head())
    
    ax.set_title('Timeseries of %s (%s) for ICES Square %s' % (dctspecies[aspecies][0], dctspecies[aspecies][1], statsq))
    ax.set_xlabel('date')

    #ax.errorbar(dfpg['date'], dfpg['avg'],yerr=dfpg['stddev_samp'],fmt='r',label='stddev_samp')
    ax.plot(dfpg['date'], dfpg['avg'], 'bo',label='avg '+aspecies)
    styles = ['b','g','r','k']
       
    if len(lstdfs) > 1:
        for label,style, df in zip(labels,styles,lstdfs):
            df[["yearmonth","concentration"]].groupby("yearmonth").mean().sort().plot(style=style,label=label,ax=ax)
    else:            
        df[["yearmonth","concentration"]].groupby("yearmonth").mean().sort().plot(style=styles[0],label=labels[0],ax=ax)
    
    #ax.set_xlim(datetime.datetime(2003,1,1), datetime.datetime(2013,1,1))
    ax.autoscale(axis='y')
    labels.insert(0,'ICES Observations')
    ax.legend(labels)

    #ax.legend(loc='upper left')
    # Create a file like object.
    f = io.BytesIO()
    fig.savefig(f, format='png')
    f.seek(0)
    return f

def plot_ts_nc_pg(df,dfpg, statsq, aspecies, dctspecies):
    fig, ax = plt.subplots(1)
    logger.info(df.head())
    logger.info(dfpg.head())

    ax.set_title('Timeseries of %s (%s) for ICES Square %s' % (dctspecies[aspecies][0], dctspecies[aspecies][1], statsq))
    ax.set_xlabel('date')

    #ax.errorbar(dfpg['date'], dfpg['avg'],yerr=dfpg['stddev_samp'],fmt='r',label='stddev_samp')
    ax.plot(dfpg['date'], dfpg['avg'], 'bo',label='avg '+aspecies)
    df[["yearmonth","concentration"]].groupby("yearmonth").mean().sort().plot(ax=ax)

    #ax.set_xlim(datetime.datetime(2003,1,1), datetime.datetime(2013,1,1))
    ax.autoscale(axis='y')

    ax.legend(loc='upper left')
    # Create a file like object.
    f = io.BytesIO()
    fig.savefig(f, format='png')
    f.seek(0)
    return f

# Only do this if module is run as script.
if __name__ == '__main__':
    credentials = get_credentials()
    dctspecies = setspecies()

    aspecies = dctspecies.keys()[3]
    statsq = '32F3'

    df = query_ices(credentials,aspecies,statsq)

    plotdf(df,statsq,aspecies,dctspecies)
