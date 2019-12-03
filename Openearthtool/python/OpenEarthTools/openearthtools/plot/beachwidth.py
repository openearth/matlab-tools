# -*- coding: utf-8 -*-
"""
Created on Wed Dec 02 09:54:23 2015

$Id: beachwidth.py 12705 2016-04-25 11:08:13Z heijer $
$Date: 2016-04-25 04:08:13 -0700 (Mon, 25 Apr 2016) $
$Author: heijer $
$Revision: 12705 $
$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/python/OpenEarthTools/openearthtools/plot/beachwidth.py $


@author: heijer
"""

import logging
logging.basicConfig(level=logging.DEBUG, format='%(levelname)s: %(filename)s line %(lineno)d: %(message)s')

from netCDF4 import Dataset, num2date
import os
import re
import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import matplotlib as mpl
from scipy import stats
import qrcode
import types
from jarkus.transects import Transects
import beachwidth_trends

checkouts_dir = os.path.abspath(os.path.join(os.path.dirname(__file__), '..', '..', '..', '..', '..'))
assessment_transectsfile = os.path.join(checkouts_dir, 'openearthrawdata/rijkswaterstaat/jarkus/scripts/python/toetsraaien.txt')

DFreg = 'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/DuneFoot/DF.nc'
DFnew = os.path.join(os.path.dirname(__file__), 'DF.nc')
WL = 'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/MHW_MLW/MHW_MLW.nc'
NOUR = 'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/suppleties/nourishments.nc'
jarkus_url = 'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/jarkus/profiles/transect.nc'

transect_limits = {'egmond': {'min': 7003500, 'max': 7004300},
                   'walcheren': {'min': 16000580, 'max': 16001832},
                   # 'walcheren-noord': {'min': 16000540, 'max': 16001469},
                   # 'walcheren-noordmid': {'min': 16001673, 'max': 16001927},
                   # 'walcheren-zuid': {'min': 16002195, 'max': 16003458},
                   # 'schiermonnikoog': {'min': 2000100, 'max': 2000400},
                   # 'ameland-oost': {'min': 3000680, 'max': 3001680},
                   # 'ameland-west': {'min': 3004800, 'max': 3004966},
                   # 'goeree': {'min': 12000625, 'max': 12001900},
                   # 'noord-bevenland': {'min': 15000120, 'max': 15000360},
                   # 'noord-holland-noord': {'min': 7000210, 'max': 7001062},
                   # 'noord-holland-callantsoog': {'min': 7001078, 'max': 7001360},
                   # 'noord-holland-camperduin': {'min': 7002629, 'max': 7002847},
                   # 'noord-holland-wijk_aan_zee': {'min': 7005100, 'max': 7005475},
                   # 'schouwen-noord': {'min': 13000084, 'max': 13000604},
                   # 'schouwen-zuid': {'min': 13001505, 'max': 13001719},
                   # 'terschelling': {'min': 4000800, 'max': 4001220},
                   # 'texel': {'min': 6000900, 'max': 6002300},
                   # 'texel-noord': {'min': 6002740, 'max': 6003081},
                   # 'vlieland': {'min': 5004880, 'max': 5005460},
                   # 'voorne': {'min': 11000880, 'max': 11001600},
                   # 'zeeuws_vlaanderen': {'min': 17000011, 'max': 17001487},
                   # 'rijnland-noord': {'min': 8005650, 'max': 8006425},
                   # 'rijnland-mid': {'min': 8007500, 'max': 8007525},
                   # 'rijnland-noordwijk': {'min': 8008075, 'max': 8008300},
                   # 'rijnland-katwijk': {'min': 8008600, 'max': 8008800},
                   # 'rijnland-zuid': {'min': 8009200, 'max': 8009275},
                   # 'delfland-den_haag': {'min': 9009770, 'max': 9010507},
                   # 'delfland-monster': {'min': 9011034, 'max': 9011263},
                   # 'delfland-hoek_van_holland': {'min': 9011750, 'max': 9011850},
                   }
                   
tr = Transects(url=jarkus_url)
trid = tr.get_data('id')
tr.close()
for kvno in range(2, 18):
    logging.debug(kvno)
    indx = np.logical_and(trid >= kvno*1e6, trid < (kvno+1)*1e6)

    transect_limits['kustvak_%02i'%kvno] = {'min': trid[indx].min(), 'max': trid[indx].max()}

period_bounds = (1990, )

def add_qrcode2fig(fig, size=.18):
    keywords = ['$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/python/OpenEarthTools/openearthtools/plot/beachwidth.py $', '$Revision: 12705 $', ]
    for i,keyword in enumerate(keywords):
        keywords[i] = keyword.replace('$', '').replace('Revision: ', '').replace('HeadURL: ', '').strip()
    img = qrcode.make('%s?p=%s' % (keywords[0], keywords[1]))
    figaspect = fig.get_figheight() / fig.get_figwidth()
    hsize = size
    vsize = size / figaspect
    logging.info('figure size: %g, %g' % (hsize, vsize))
    ax = fig.add_axes([1-hsize, 1-vsize, hsize, vsize], frameon=False)
    ax.set_xticks([])
    ax.set_yticks([])
    ax.imshow(img)

def get_alongshore_idx(trid, location):
    assessids = np.loadtxt(assessment_transectsfile)
    assessmask = np.invert(np.in1d(trid, assessids))
    if type(location) is types.StringType:
        aidx = np.logical_and(trid >= transect_limits[location]['min'], trid <= transect_limits[location]['max'])
        mask = assessmask[aidx]
        return aidx, mask
    elif type(location) is types.IntType:
        aidx = (trid-trid%1e6) == 1e6*location
        mask = assessmask[aidx]
        return aidx, mask
    elif location is None:
        return np.ones(trid.shape, dtype=bool), assessmask
    else:
        logging.warning('location %s not recognised' % location)
        return None, None

def get_dunefoot(ncfile, location, dfname='dune_foot_threeNAP_cross', minyear=1965, quiet=False):
    with Dataset(ncfile) as ds:
        if not quiet:
            logging.debug('%s %s' % (ncfile, location))
        t = ds.variables['time']
        time = num2date(t[:], t.units)
        tidx = np.array([tt.year for tt in time]) >= minyear
        trid = ds.variables['id'][:]
        aidx, mask = get_alongshore_idx(trid, location)
        if not np.all(mask):
            # print np.any(tidx), np.any(aidx)
            dunefoot = ds.variables[dfname][tidx,aidx]
        else:
            logging.warning('no valid transects found for %s' % location)

    if not np.all(mask):
        return trid[aidx], dunefoot, time[tidx], mask
    else:
        return None, None, None, None

def get_waterlevel(ncfile, location, wlname=('mean_high_water', 'mean_low_water')):
    with Dataset(ncfile) as ds:
        trid = ds.variables['id'][:]
        aidx, mask = get_alongshore_idx(trid, location)
        waterlevel = [ds.variables[wl][aidx] for wl in wlname]
    return trid[aidx], waterlevel

def get_waterline(ncfile, location, wlname=('mean_high_water_cross', 'mean_low_water_cross')):
    with Dataset(ncfile) as ds:
        trid = ds.variables['id'][:]
        aidx, mask = get_alongshore_idx(trid, location)
        waterline = [ds.variables[wl][:,aidx] for wl in wlname]
        t = ds.variables['time']
        time = num2date(t[:], t.units)
    return trid[aidx], waterline, time

def get_nourishments(ncfile, location):
    with Dataset(ncfile) as ds:
        trid = ds.variables['id'][:]
        aidx, mask = get_alongshore_idx(trid, location)
        nour = ds.variables['volume'][aidx,]
        # t = ds.variables['n_time']
        # time = t[:] # the time variable in the netcdf is in years (and not in days since 1970 as the units suggest)
        time = np.asarray([y.year for y in num2date(ds.variables['time'][:], units=ds.variables['time'].units)])
    return trid[aidx], nour.data, time

def linreg(years, cross, bounds=None):
    if bounds is None:
        bounds = np.hstack((np.array(period_bounds), np.array((years.min(), years.max()))))
        bounds.sort()
    yrs, crs, slp = [], [], []
    for i,st in enumerate(bounds[:-1]):
        idx = np.logical_and(years >= st, years <= bounds[i+1])
        x, y = years[idx], np.ma.masked_invalid(cross[idx])
        if np.all(y.mask):
            crs.append(y.data*np.nan)
            slp.append(np.nan)
        else:
            slope, intercept, r_value, p_value, std_err = stats.linregress(x[~y.mask], y[~y.mask])
            p = np.poly1d([slope, intercept])
            crs.append(np.polyval(p, x))
            slp.append(slope)
        yrs.append(x)
    return yrs, crs, slp, bounds

def mark_site(ax, bounds, method='rectangle', text=None):
    ylim = ax.get_ylim()
    if method == 'lines':
        for xl in bounds:
            ax.axvline(xl, color='r', linestyle='-')
    elif method in ('rectangle', 'patch'):
        height = np.diff(ylim)
        width = np.diff(bounds)
        xy = (bounds[0], ylim[0])
        print ylim, height, width, xy
        if method == 'rectangle':
            ax.add_patch(mpatches.Rectangle(xy, width, height, fill=False, linewidth=3, ec='r'))
        elif method == 'patch':
            ax.add_patch(mpatches.Rectangle(xy, width, height, fill=True, alpha=0.3, linewidth=0))


    if text is not None:
        print 'text', text
        ax.text(np.mean(bounds), np.mean(ylim), text, rotation=90, horizontalalignment='center', verticalalignment='center', zorder=10)



def plot_hist(year=None):
    for site in transect_limits.keys():
        trid_df, df, time_df, mask = get_dunefoot(DFreg, site)#, dfname='dune_foot_2ndDeriv_cross')
        trid_wl, wls, time_wl = get_waterline(WL, site)
        print (trid_df == trid_wl).all()
        trid_df = trid_df % 1e6
        trid_wl = trid_wl % 1e6
        wl_tidxs = np.in1d(time_wl, time_df)
        df_tidxs = np.in1d(time_df, time_wl)
        years = np.array([t.year for t in time_df[df_tidxs]])
        if year is None:
            yr = years.max()
        else:
            yr = year
        if yr not in years:
            print '%i not in data' % yr
            raise
        wl_tidx = [t.year for t in time_wl].index(yr)
        df_tidx = [t.year for t in time_df].index(yr)
        yr_tidx = years.tolist().index(yr)
        bw_dry = wls[0][wl_tidxs,] - df
        bw_wet = wls[1][wl_tidxs,] - df # please note: this is the intertidal area (as needed for proper plotting in the stackplot)
        
        fig, ax = plt.subplots()
        fig.suptitle('%s %i' % (site, yr))
        width = 10
        levels = range(0, int(np.nanmax(bw_wet)+20), 20)
        print levels
        dry, wet = [], []
        for i,lev in enumerate(levels[1:]):
            dry.append(np.count_nonzero(np.logical_and(bw_dry[yr_tidx,:]>=levels[i-1], bw_dry[yr_tidx,:]<lev)))
            wet.append(np.count_nonzero(np.logical_and(bw_wet[yr_tidx,:]>=levels[i-1], bw_wet[yr_tidx,:]<lev)))
        print dry, wet
        ax.bar(levels[:-1], dry, width, color='g')
        ax.bar(np.array(levels[:-1])+width, wet, width, color='b')
        fig.savefig('plot_hist_%s_%04i.png' % (site, yr))
        plt.close()
    

def plot_area(year=None, hlines=range(20,120,10)):
    """Plots for the different locations the spatial variation of the MHW, MLW and Dunefoot. Does this for location
    Walcheren and Egmond. The year can be selected """
    for site in transect_limits.keys():
        trid_df, df, time_df, mask = get_dunefoot(DFreg, site)#, dfname='dune_foot_2ndDeriv_cross')
        if trid_df is None:
            continue
        trid_wl, wls, time_wl = get_waterline(WL, site)
        print (trid_df == trid_wl).all()
        trid_df = trid_df % 1e6
        trid_wl = trid_wl % 1e6
        wl_tidxs = np.in1d(time_wl, time_df)
        df_tidxs = np.in1d(time_df, time_wl)
        years = np.array([t.year for t in time_df[df_tidxs]])
        if year is None:
            yr = years.max()
        else:
            yr = year
        if yr not in years:
            print '%i not in data' % yr
            raise
        wl_tidx = [t.year for t in time_wl].index(yr)
        df_tidx = [t.year for t in time_df].index(yr)
        yr_tidx = years.tolist().index(yr)
        bw_dry = wls[0][wl_tidxs,] - df
        bw_wet = wls[1][wl_tidxs,] - wls[0][wl_tidxs,] # please note: this is the intertidal area (as needed for proper plotting in the stackplot)
        fig, axes = plt.subplots(nrows=2, ncols=1, figsize=(10,10), sharex=True, subplot_kw=dict(xlim=[trid_df.min()-10, trid_df.max()+10]))
        fig.subplots_adjust(right=.75, bottom=.05, top=.9, left=.08)
        fig.suptitle('%s %i' % (site, yr))

        axes[0].set_title('contourlijnen')
        axes[0].set_ylabel('afstand tot RSP [m]')
        axes[0].scatter(trid_wl, wls[1][wl_tidx,], label='gem. laagwater', c='r')
        axes[0].scatter(trid_wl, wls[0][wl_tidx,], label='gem. hoogwater', c='g')
        axes[0].scatter(trid_df, df[df_tidx,], label='duinvoet', c='b')
        axes[0].legend(bbox_to_anchor=(1.01, 0), loc=3, borderaxespad=0.)
        ydiff = np.diff(axes[0].get_ylim())

        axes[1].set_title('strandbreedte')
        axes[1].set_xlabel('Raai # kustlangs')
        axes[1].set_ylabel('strandbreedte [m]')
        axes[1].stackplot(trid_wl, bw_dry[yr_tidx,:], bw_wet[yr_tidx,:], colors=('g', 'b'))
        axes[1].set_ylim(0, ydiff)
        for hl in hlines:
            hlh = axes[1].axhline(hl, ls=':', zorder=10, color='k')
        dry_p = mpatches.Patch(color='g', label='droog')
        wet_p = mpatches.Patch(color='b', label='nat')
        axes[1].legend((wet_p, dry_p, hlh), ('nat', 'droog', 'grenswaarden'), bbox_to_anchor=(1.01, 0), loc=3, borderaxespad=0.)

        add_qrcode2fig(fig, size=.2)
        fig.savefig('plot_%s_%04i.png' % (site, yr))
        plt.close()
    
def plot_time(maxplots=None, sites=transect_limits.keys(), hlines=range(20,120,10)):
    for site in sites:
        trid_df, df, time_df, mask = get_dunefoot(DFreg, site)#, dfname='dune_foot_2ndDeriv_cross')
        trid_wl, wls, time_wl = get_waterline(WL, site)
        wl_tidxs = np.in1d(time_wl, time_df)
        df_tidxs = np.in1d(time_df, time_wl)
        years = np.array([t.year for t in time_df[df_tidxs]])
        bw_dry = wls[0][wl_tidxs,] - df
        bw_wet = wls[1][wl_tidxs,] - wls[0][wl_tidxs,] # please note: this is the intertidal area (as needed for proper plotting in the stackplot)
        trid_nr, nour, nour_yrs = get_nourishments(NOUR, site)
        cum_nour = np.cumsum(nour, axis=-1)
        print (trid_df == trid_wl).all() and (trid_wl == trid_nr).all()
        for idx,trid in enumerate(trid_df):
            if maxplots is not None and idx > maxplots:
                continue
            has_nour = np.sum(nour[idx,]) > 0
            if has_nour:
                nrows = 3
                figsize = (10,14)
            else:
                nrows = 2
                figsize = (10,11)
            fig, axes = plt.subplots(nrows=nrows, ncols=1, figsize=figsize, sharex=True, subplot_kw=dict(xlim=[years.min()-1, years.max()+1]))
            fig.suptitle('Raai %i (%s, kustvak %i)'% (trid%1e6, site, (trid-trid%1e6)/1e6))
            fig.subplots_adjust(right=.74, bottom=.05, left=.1, top=.93)
            legend_kw = dict(bbox_to_anchor=(1.02, 0), loc=3, borderaxespad=0.)
            axes[0].set_title('contourlijnen')
            axes[0].set_ylabel('afstand tot RSP [m]')
            axes[0].scatter(years, wls[1][wl_tidxs,idx], label='gem. laagwater', c='r')
            yrs_mlw, crs_mlw, _, _ = linreg(years, wls[1][wl_tidxs,idx])
            for x,y in zip(yrs_mlw, crs_mlw):
                axes[0].plot(x, y, '-r')
            axes[0].scatter(years, wls[0][wl_tidxs,idx], label='gem. hoogwater', c='g')
            yrs_mhw, crs_mhw, _, _ = linreg(years, wls[0][wl_tidxs,idx])
            for x,y in zip(yrs_mhw, crs_mhw):
                axes[0].plot(x, y, '-g')
            axes[0].scatter(years, df[:,idx], label='duinvoet', c='b')
            yrs_df, crs_df, _, _ = linreg(years, df[:,idx])
            for x,y in zip(yrs_df, crs_df):
                axes[0].plot(x, y, '-b')
            axes[0].legend(**legend_kw)
            ydiff = np.diff(axes[0].get_ylim())
            print ydiff
            
            axes[1].set_title('strandbreedte')
            axes[1].set_ylabel('strandbreedte [m]')
            axes[1].set_ylim(0, ydiff)
            axes[1].stackplot(years, bw_dry[:,idx], bw_wet[:,idx], colors=('g', 'b'))
            dry_p = mpatches.Patch(color='g', label='droog')
            wet_p = mpatches.Patch(color='b', label='nat')
            for hl in hlines:
                hlh = axes[1].axhline(hl, ls=':', zorder=10, color='k')
            axes[1].legend((wet_p, dry_p, hlh), ('nat', 'droog', 'grenswaarden'), bbox_to_anchor=(1.01, 0), loc=3, borderaxespad=0.)

#            axes[2].set_title('strand breedte (trend)')
#            axes[2].set_ylim(0, ydiff)
#            yrs = np.hstack(yrs_df)
#            bw_tr_dry = np.hstack(crs_mhw) - np.hstack(crs_df)
#            bw_tr_wet = np.hstack(crs_mlw) - np.hstack(crs_mhw)
#            axes[2].stackplot(yrs, bw_tr_dry, bw_tr_wet, colors=('g', 'b'))
#            axes[2].legend((wet_p, dry_p), ('nat', 'droog'), loc=2)
            
            if has_nour: #Checks if sand nourishments have taken place for specific location. If TRUE than it adds a 4th plot of the nourishments
                axes[2].set_title('suppleties')
                axes[2].set_ylabel('volume [m$^3$/m]')
                barwidth = .5
                if np.sum(nour[idx,:,0]) > 0:
                    axes[2].bar(nour_yrs, nour[idx,:,0], barwidth, color='y', label='strand')
                for i,(label,c) in enumerate(zip(('s', 'vooroever', 'duin', 'overige'), ('y', 'b', 'c', 'r'))):
                    if i > 0 and np.sum(nour[idx,:,i]) > 0:
                        axes[2].bar(nour_yrs, nour[idx,:,i], barwidth, color=c, label=label, bottom=cum_nour[idx,:,i-1])
                    nour_list = nour[idx,:,i]
                    year_nour_list = np.nonzero(nour_list)[0]
                    for year in nour_yrs[year_nour_list]:
                        axes[2].axvline(x=year+barwidth/2.,c="red", ls=':' ,linewidth=1, ymax=3.2,clip_on=False)
                axes[2].legend(**legend_kw)
            add_qrcode2fig(fig, size=.22)
            fig.savefig('plot_%08i.png' % trid)
            plt.close()

def get_areaname(areacode):
    with Dataset(jarkus_url) as ds:
        areanames = ds.variables['areacode'].flag_meanings
        areacodes = ds.variables['areacode'].flag_values
    areacodes = map(int, areacodes)
    areanames = re.split(',\s+', areanames)
    areas = dict(zip(areacodes, areanames))
    if type(areacode) == np.int:
        return areas.get(areacode)
    if type(areacode) == list:
        return map(areas.get, areacode)

def plot_beachwidth_contourf(hlines=range(20,130,10)):
    sites = transect_limits.keys()
    kvs = map(beachwidth_trends.site2kustvak, sites)
    for site,kv in zip(sites, kvs):
        trid_df, df, time_df, mask = get_dunefoot(DFreg, site)#, dfname='dune_foot_2ndDeriv_cross')
        if trid_df is None:
            continue
        trid_wl, wls, time_wl = get_waterline(WL, site)
        trid_df = trid_df % 1e6
        trid_wl = trid_wl % 1e6
        wl_tidxs = np.in1d(time_wl, time_df)
        df_tidxs = np.in1d(time_df, time_wl)
        years = np.array([t.year for t in time_df[df_tidxs]])
        bw_dry = wls[0][wl_tidxs,] - df
        bw_wet = wls[1][wl_tidxs,] - df # use here total wet beach, (dry+intertidal)
        fig,axes = plt.subplots(nrows=2, ncols=1, sharex=True, sharey=True,
                                subplot_kw=dict(xlim=(np.min(trid_wl), np.max(trid_wl)),ylim=(np.min(years), np.max(years)), ylabel='Tijd [jaren]'))
        fig.subplots_adjust(right=.8, top=.87, left=.1)
        if site == 'kustvak_%02i' % kv:
            areaname = get_areaname(kv)
            fig.suptitle('kustvak %i: %s' % (kv, areaname), fontsize=14)
        else:
            fig.suptitle(site, fontsize=14)
        axtitle = ('(a) Strandbreedte bij gemiddeld hoogwater (droog)', '(b) Strandbreedte bij gemiddeld laagwater (nat)')
        data = map(np.ma.masked_invalid, (bw_dry, bw_wet))
        a,t = np.meshgrid(trid_df, years)
        print mask.shape
        meshmask = np.expand_dims(mask, axis=0).repeat(t.shape[0], axis=0)
        print t.shape, meshmask.shape
        
        for i,(ax,d) in enumerate(zip(axes, data)):
            masked_data = np.ma.masked_where(meshmask, d)
            ax.set_title(axtitle[i])
            ph = ax.contourf(a, t, masked_data, levels=hlines, vmin=0, vmax=hlines[-1], extend='max',cmap=plt.cm.Blues)
        ax.set_xlabel('Raai # kustlangs')
#        cax, kw = mpl.colorbar.make_axes([ax for ax in axes.flat])
        cax = fig.add_axes([.85, .1, .05, .65])
        cb = plt.colorbar(ph, cax=cax)
        cb.set_label('Strandbreedte [m]')
        add_qrcode2fig(fig)
        if site == 'kustvak_%02i' % kv:
            subsites = [s for s,k in zip(sites, kvs) if k == kv and s is not site]
            for ss in subsites:
                bounds = (transect_limits[ss]['min'] % 1e6, transect_limits[ss]['max'] % 1e6)
                for ax in axes.flat:
                    if ax == axes[-1]:
                        text = ss
                    else:
                        text = None
                    mark_site(ax, bounds, method='rectangle', text=None)
            ylim = ax.get_ylim()
            dy = np.abs(np.diff(ylim)) * .02
            ax.set_ylim(ylim[0]-dy, ylim[-1]+dy)

        fig.savefig('plot_%s_beachwidth_%s.png' % (site, ph.__module__.split('.')[-1]))
        
        plt.close()
            
def plot_dunefoot_comp():
    for site in transect_limits.keys():
        trid_df, df, time_df, mask = get_dunefoot(DFreg, site)
        trid_df2, df2, time_df2, mask = get_dunefoot(DFnew, site, dfname='dune_foot_2ndDeriv_cross')
        fig, ax = plt.subplots(nrows=1, ncols=1, subplot_kw=dict(aspect='equal'))
        fig.subplots_adjust(right=.8, top=.87, left=.1)
        ax.set_title(site)
        ax.scatter(df, df2)
        xlim = ax.get_xlim()
        ax.plot(xlim, xlim)
        ax.set_xlim(xlim)
        ax.set_ylim(xlim)
        ax.set_xlabel('NAP + 3m dunefoot')
        ax.set_ylabel('2nd deriv. dunefoot')
        add_qrcode2fig(fig)
        fig.savefig('plot_%s_dunefoot_comp.png' % site)
        plt.close()

def plot_beachwidth_comp():
    for site in transect_limits.keys():
        trid_df, df, time_df, mask = get_dunefoot(DFreg, site)
        trid_df2, df2, time_df2, mask = get_dunefoot(DFnew, site, dfname='dune_foot_2ndDeriv_cross')
        trid_wl, wls, time_wl = get_waterline(WL, site)
        trid_df = trid_df % 1e6
        trid_wl = trid_wl % 1e6
        wl_tidxs = np.in1d(time_wl, time_df)
        df_tidxs = np.in1d(time_df, time_wl)
        years = np.array([t.year for t in time_df[df_tidxs]])
        bw_dry = wls[0][wl_tidxs,] - df
        bw_wet = wls[1][wl_tidxs,] - df # use here total wet beach, (dry+intertidal)
        bw_dry2 = wls[0][wl_tidxs,] - df2
        bw_wet2 = wls[1][wl_tidxs,] - df2 # use here total wet beach, (dry+intertidal)
        bw_dry_diff = bw_dry2 - bw_dry
        bw_wet_diff = bw_wet2 - bw_wet
        fig,axes = plt.subplots(nrows=2, ncols=1, sharex=True, sharey=True,
                                subplot_kw=dict(xlim=(np.min(trid_wl), np.max(trid_wl)),ylim=(np.min(years), np.max(years)), ylabel='Tijd [jaren]'))
        fig.subplots_adjust(right=.8, top=.87, left=.1)
        fig.suptitle(site, fontsize=14)
        axtitle = ('(a) Verschil strandbreedte bij gemiddeld hoogwater (droog)', '(b) Verschil strandbreedte bij gemiddeld laagwater (nat)')
        data = map(np.ma.masked_invalid, (bw_dry_diff, bw_wet_diff))
        a,t = np.meshgrid(trid_df, years)
        
        for i,(ax,d) in enumerate(zip(axes, data)):
            ax.set_title(axtitle[i])
            ph = ax.contourf(a, t, d, levels=range(-50,60,20), vmin=-50, vmax=50, extend='both')
        ax.set_xlabel('Raai # kustlangs')
#        cax, kw = mpl.colorbar.make_axes([ax for ax in axes.flat])
        cax = fig.add_axes([.85, .1, .05, .65])
        cb = plt.colorbar(ph, cax=cax)
        cb.set_label('Strandbreedte [m]')
        add_qrcode2fig(fig)
        fig.savefig('plot_%s_beachwidth_diff_%s.png' % (site, ph.__module__.split('.')[-1]))
        
        plt.close()

def hist_dunefoot():
    for site in transect_limits.keys():
        trid_df2, df2, time_df2, mask = get_dunefoot(DFnew, site, dfname='dune_foot_2ndDeriv')
        df2 = np.ma.masked_invalid(df2)
        fig,ax = plt.subplots(nrows=1, ncols=1)
        ph = ax.hist(df2.flatten(), range=(0,5))
        fig.savefig('plot_%s_dunefoot_hist.png' % (site,))
        plt.close()

def make_beachwidth_table():
    bw0, bw1 = {}, {}
    for site in range(2,18):
        trid_df, df, time_df, mask = get_dunefoot(DFreg, site)
        if trid_df is None:
            continue
        trid_df2, df2, time_df2, mask = get_dunefoot(DFnew, site, dfname='dune_foot_2ndDeriv_cross')
        trid_wl, wls, time_wl = get_waterline(WL, site)
        trid_df = trid_df % 1e6
        trid_wl = trid_wl % 1e6
        wl_tidxs = np.in1d(time_wl, time_df)
        df_tidxs = np.in1d(time_df, time_wl)
        years = np.array([t.year for t in time_df[df_tidxs]])
        bw_dry = wls[0][wl_tidxs,] - df
        if np.all(np.isnan(bw_dry)):
            continue
        bw_wet = wls[1][wl_tidxs,] - df # use here total wet beach, (dry+intertidal)
        bw_dry2 = wls[0][wl_tidxs,] - df2
        bw_wet2 = wls[1][wl_tidxs,] - df2 # use here total wet beach, (dry+intertidal)
        yearidx0 = years < 1990
        yearidx1 = years >= 1990
        bw0[site] = []
        bw1[site] = []
        for bwm in (bw_dry, bw_dry2, bw_wet, bw_wet2):
            bw0[site].append(np.mean(np.ma.masked_invalid(bwm[yearidx0, ])))
            bw1[site].append(np.mean(np.ma.masked_invalid(bwm[yearidx1, ])))
    sites = bw0.keys()
    sites.sort()
    def bw2ranges(bw):
        bw = np.asarray(bw)
        return np.min(bw[:2]), np.max(bw[:2]), np.min(bw[2:]), np.max(bw[2:])
    # print 'kustvak, dry +3, dry 2nd der., wet +3, wet 2nd der.'
    print 'kustvak', 'pre 1990 dry/wet', 'post 1990 dry/wet'
    for site in sites:
        # print '%2i' % site, '%5.0f %5.0f %5.0f %5.0f' % tuple(bw0[site]), '%2i' % site, '%5.0f %5.0f %5.0f %5.0f' % tuple(bw1[site])
        print '%2i' % site, '%5.0f-%.0f  %5.0f-%.0f' % bw2ranges(bw0[site]), '%5.0f-%.0f  %5.0f-%.0f' % bw2ranges(bw1[site])

def beach_slope():
    trid_df, df, time_df, mask = get_dunefoot(DFreg, None)
    trid_wl, wls, time_wl = get_waterline(WL, None)
    trid, wl = get_waterlevel(WL, None)
    print df.shape
    print wls[0].shape, wls[1].shape
    print wl[0].shape, wl[1].shape

    wl_tidxs = np.in1d(time_wl, time_df)
    df_tidxs = np.in1d(time_df, time_wl)
    years = np.array([t.year for t in time_df[df_tidxs]])
    bw_dry = wls[0][wl_tidxs,] - df
    bw_wet = wls[1][wl_tidxs,] - df # use here total wet beach, (dry+intertidal)

    dry_slp = bw_dry[-1,] / (3 - wl[0])
    wet_slp = bw_wet[-1,] / (3 - wl[1])
    dry_bl = np.logical_and(dry_slp>45, dry_slp<55)
    wet_bl = np.logical_and(wet_slp>45, wet_slp<55)
    print trid_df[dry_bl]
    print trid_df[wet_bl]
    print trid_df[np.logical_and(dry_bl, wet_bl)]




if __name__ == '__main__':
    # beach_slope()
   plot_time()
#    plot_area()
#    plot_dunefoot_comp()
#    plot_beachwidth_contourf()
#     plot_beachwidth_comp()
#    make_beachwidth_table()
#    hist_dunefoot()
#    for site in transect_limits.keys():
#        trid, wl = get_waterlevel(WL, site)
#        print wl