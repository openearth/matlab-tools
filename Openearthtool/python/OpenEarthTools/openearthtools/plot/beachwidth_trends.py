# -*- coding: utf-8 -*-
"""
Created on Thu Dec 10 14:01:18 2015

$Id: beachwidth_trends.py 12705 2016-04-25 11:08:13Z heijer $
$Date: 2016-04-25 04:08:13 -0700 (Mon, 25 Apr 2016) $
$Author: heijer $
$Revision: 12705 $
$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/python/OpenEarthTools/openearthtools/plot/beachwidth_trends.py $

@author: heijer
"""

import logging
logging.basicConfig(level=logging.DEBUG, format='%(levelname)s: %(filename)s line %(lineno)d: %(message)s')

import sys
import os
checkouts_dir = os.path.abspath(os.path.join(os.path.dirname(__file__), '..', '..', '..', '..', '..'))
sys.path.append(os.path.join(checkouts_dir, 'openearthrawdata/rijkswaterstaat/suppleties/scripts/python'))
import nourishments
from types import IntType
import matplotlib.pyplot as plt
import numpy as np
import beachwidth
import qrcode
import simplekml
from jarkus.transects import Transects
from mako.template import Template
import csv



tmpl = Template("""
<![CDATA[
<table border="1"> <tr>
<td>kustvak</td><td> ${areacode} </td></tr>
<td>transect</td><td> ${transectid} </td></tr>
<td>beachwidth ${bwyear}</td><td> ${bwval} m</td></tr>
<td>beachwidth trend ${tr1years}</td><td> ${tr1val} m/y</td></tr>
<td>beachwidth trend ${tr2years}</td><td> ${tr2val} m/y</td></tr>
</table>
<img  src="${figname}" align="left" width="500" />
<h3><a href = "http://www.rijkswaterstaat.nl">Rijkswaterstaat</a> JarKus data.</h3>
<h3>Provided by:</h3>
<a href = "http://www.openearth.eu"> <img  src="http://kml.deltares.nl/kml/logos/OpenEarth-logo-blurred-white-background.png" align="left" width="150" /> </a>
]]>
""")


url = nourishments.url
kustvak = nourishments.kustvak
kustvak = 3#[3,5,6,7,8,9,11,12,13,15,16,17]
path = os.path.dirname(__file__)

def add_qrcode2fig(fig, size=.18):
    keywords = ['$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/python/OpenEarthTools/openearthtools/plot/beachwidth_trends.py $', '$Revision: 12705 $', ]
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
    
def makenourishment_stackplot(ids, volm_cs, n_year, kustvak=kustvak, path=os.path.dirname(__file__), aoi=None, divyears=(1990,2001,2013), ax=None):
    ax = nourishments.makestackplot(ids, volm_cs, n_year, kustvak=kustvak, path=os.path.dirname(__file__), aoi=None, divyears=divyears, ax=ax)
    return ax

def makebeachwidthtrendplot(ax, years, cnt1, cnt2, trids, legend_kw=dict()):
    slps1, slps2 = [], []
    for idx,trid in enumerate(trids):
        _, _, slp1, bnds1 = beachwidth.linreg(years, cnt1[:, idx])
        _, _, slp2, bnds2 = beachwidth.linreg(years, cnt2[:, idx])
        slps1.append(slp1)
        slps2.append(slp2)
    labels = ['%i-%i' %(bnds1[i], bnd) for i,bnd in enumerate(bnds1[1:])]
    for label, slp1, slp2 in zip(labels, zip(*slps1), zip(*slps2)):
#        maketrendplot(axes[1], trid_df%1e6, slp, label=per)
        ax.plot(trids %1e6, np.array(slp2)-np.array(slp1), label=label)
    ax.set_ylabel('trend [m/y]')
    handles, labels = ax.get_legend_handles_labels()
    ax.legend(handles[::-1], labels[::-1], **legend_kw)
    ax.axhline(0, linestyle=':', color='k')
    ax.xaxis.grid(True)
    
def maketrendplot(ax, years, cnt, trids, cnt1=None, legend_kw=dict()):
    slps = []
    for idx,trid in enumerate(trids):
        _, _, slp, bnds = beachwidth.linreg(years, cnt[:, idx])
        slps.append(slp)
    if cnt1 is not None:
        # derive trends for second contour separately and subtract it from the first contour afterwards
        slps1 = []
        for idx,trid in enumerate(trids):
            _, _, slp1, bnds1 = beachwidth.linreg(years, cnt1[:, idx])
            slps1.append(slp1)
        # subtract trends
        slps = (np.asarray(slps) - np.asarray(slps1)).tolist()

    labels = ['%i-%i' %(bnds[i], bnd) for i,bnd in enumerate(bnds[1:])]
    for label, slp in zip(labels, zip(*slps)):
        kv_trids = np.array(trids % 1e6)
        kv_slp = np.array(slp)
        if np.any(np.diff(kv_trids) > 200):
            # add extra nan value in large gaps, in order to prevent meaningless connections between transects that are far apart
            idx = np.nonzero(np.diff(trids % 1e6) > 200)[0] + 1
            vals = kv_trids[idx] + 100
            kv_trids = np.insert(kv_trids, idx, vals)
            kv_slp = np.insert(kv_slp, idx, np.nan)
        ax.plot(kv_trids, kv_slp, label=label)
    ax.set_ylabel('trend [m/y]')
    handles, labels = ax.get_legend_handles_labels()
    ax.legend(handles[::-1], labels[::-1], **legend_kw)
    ax.axhline(0, linestyle=':', color='k')
    ax.xaxis.grid(True)
    return slps, zip((trids, trids))

def site2kustvak(site):
    kv = (beachwidth.transect_limits[site]['min'] - (beachwidth.transect_limits[site]['min'] % 1e6)) / 1e6
    return int(kv)
    
def plottrends(kustvak, ylim_fixed=None, bwidx=5):
    relvol, year, tf, vol, stretch, areacode, ids, volm_cs, n_year, volume = nourishments.getdata(url=url)
    logging.info(kustvak)
    if type(kustvak) == IntType:
        kustvak = [kustvak]

    subplot_titles = ['cumulative nourishments', 'trends mean low water', 'trends mean high water', 'trends dune foot']
    if bwidx == 4:
        subplot_titles.append('trends dry beachwidth')
    else:
        subplot_titles.append('trends difference MHW and DF')
    sites = beachwidth.transect_limits.keys()
    kvs = map(site2kustvak, sites)
    for site,kv in zip(sites, kvs):
        # kv = (beachwidth.transect_limits[site]['min'] - (beachwidth.transect_limits[site]['min'] % 1e6)) / 1e6
        xlim = (beachwidth.transect_limits[site]['min'] %1e6, beachwidth.transect_limits[site]['max'] %1e6)
        logging.info('kustvak %i %s' % (int(kv), site))
        idx_n = np.floor(ids/1e6) == kv
        fig, axes = plt.subplots(nrows=len(subplot_titles), ncols=1, figsize=(10,14), sharex=True, subplot_kw=dict(xlim=xlim))
        fig.subplots_adjust(right=.78, bottom=.05, left=.1, top=.9)
        fig.suptitle(site, fontsize=14)
        for ax, title in zip(axes, subplot_titles):
            ax.set_title(title)
        divyears = beachwidth.period_bounds
        ax = makenourishment_stackplot(ids[idx_n], volm_cs[idx_n,], n_year, kustvak=kv, path=os.path.dirname(__file__), aoi=None, divyears=divyears, ax=axes[0])
        ax.set_xlabel('')


        
        # trends        
        trid_df, df, time_df, mask_df = beachwidth.get_dunefoot(beachwidth.DFreg, site)#, dfname='dune_foot_2ndDeriv_cross')
        trid_wl, wls, time_wl = beachwidth.get_waterline(beachwidth.WL, site)
        if time_df is None:
            logging.debug('time_df is None for %s; Skipping...' % site)
            continue
        if time_wl is None:
            logging.debug('time_wl is None for %s; Skipping...' % site)
            continue
        wl_tidxs = np.in1d(time_wl, time_df)
        df_tidxs = np.in1d(time_df, time_wl)
        years = np.array([t.year for t in time_df[df_tidxs]])
        legend_kw = dict(bbox_to_anchor=(1.02, 0), loc=3, borderaxespad=0.)
        maketrendplot(axes[1], years, wls[1][wl_tidxs, :], trid_df, legend_kw=legend_kw)
        maketrendplot(axes[2], years, wls[0][wl_tidxs, :], trid_df, legend_kw=legend_kw)
        maketrendplot(axes[3], years, df, trid_df, legend_kw=legend_kw)
        if bwidx == 4:
            # plot beachwidth trend as last subplot
            slpsbw, tridsbw = maketrendplot(axes[-1], years, wls[0][wl_tidxs, :]-df, trid_df, legend_kw=legend_kw)
        else:
            # plot the difference between the MHW and DF trend as last subplot
            slpsdiff, tridsdiff = maketrendplot(axes[-1], years, wls[0][wl_tidxs, :], trid_df, cnt1=df, legend_kw=legend_kw)


        if site == 'kustvak_%02i' % kv:
            subsites = [s for s,k in zip(sites, kvs) if k == kv and s is not site]
            logging.info(subsites)
            for ss in subsites:
                sxlim = (beachwidth.transect_limits[ss]['min'] %1e6, beachwidth.transect_limits[ss]['max'] %1e6)
                for ax in axes.flat:
                    beachwidth.mark_site(ax, sxlim, method='lines', text=None)
                #     for xl in sxlim:
                #         ax.axvline(xl, color='k', linestyle='-')
                # axes[0].text(np.mean(sxlim), 0, ss, rotation=90, horizontalalignment='center', verticalalignment='bottom')

            # fig2, ax2 = plt.subplots(nrows=1, ncols=1, subplot_kw=dict(aspect='equal'))
            # bwt = np.array(slpsbw).flatten()
            # dft = np.array(slpsdiff).flatten()
            # # iidx = np.abs(bwt - dft) > 10.
            # # inspect_trids = np.unique(np.array(tridsbw).flatten()[iidx])
            # # with open('inspect.txt', 'a') as fw:
            # #     for item in inspect_trids:
            # #         fw.write('%i\n' % item)
            # ax2.scatter(bwt, dft, alpha=.4)
            # areaname = beachwidth.get_areaname(kv)
            # ax2.set_title('kustvak %i: %s' % (kv, areaname))
            # ax2.set_xlabel('Beachwidth trend [m/y]')
            # ax2.set_ylabel('Difference MHW and DF contour trend [m/y]')
            #
            # figfilename = os.path.join(path, '%s_scatter_%02i_%s.png' % (os.path.splitext(os.path.split(__file__)[-1])[0], kv, site))
            # fig2.savefig(figfilename)


        if ylim_fixed is None:
            ylim = 0
            for i in range(1,5):
                # print i, np.abs(axes[i].get_ylim())
                ylim = np.max((ylim, np.abs(axes[i].get_ylim()).max()))
        else:
            ylim = ylim_fixed
        for ax in axes[1:]:
            ax.set_ylim(-ylim, ylim)
        axes[-1].set_xlabel('transect # alongshore')

        figfilename = os.path.join(path, '%s_stackplot2_%02i_%s'%(os.path.splitext(os.path.split(__file__)[-1])[0], kv, site))
        dpi = 300
        fnames = []
        add_qrcode2fig(fig, size=.2)
        for ext in ('.pdf', '.png'):
            fig.savefig(figfilename + ext, dpi=dpi)
            fnames.append(figfilename + ext)
        plt.close(fig)

        fig, axes = plt.subplots(nrows=2, ncols=1, figsize=(10,8), sharex=True, subplot_kw=dict(xlim=xlim))
        fig.subplots_adjust(right=.78, bottom=.07, left=.08, top=.9)
        fig.suptitle(site, fontsize=14)
        axes[0].set_title('(a) trend droge strandbreedte (GHW)')
        makebeachwidthtrendplot(axes[0], years, df, wls[1][wl_tidxs, :], trid_df, legend_kw=legend_kw)
        axes[1].set_title('(b) trend natte strandbreedte (GLW)')
        makebeachwidthtrendplot(axes[1], years, df, wls[0][wl_tidxs, :], trid_df, legend_kw=legend_kw)
        axes[-1].set_xlabel('transect # alongshore')
        ylim = 0
        for ax in axes:
            # print np.abs(ax.get_ylim())
            ylim = np.max((ylim, np.abs(ax.get_ylim()).max()))
        for ax in axes:
            ax.set_ylim(-ylim, ylim)
        figfilename = os.path.join(path, '%s_%02i'%(os.path.splitext(os.path.split(__file__)[-1])[0], kv))
        dpi = 300
        fnames = []
        add_qrcode2fig(fig, size=.2)
        for ext in ('.pdf', '.png'):
            fig.savefig(figfilename + ext, dpi=dpi)
            fnames.append(figfilename + ext)
        plt.close(fig)

def make_kml(threshold={'trend': -1, 'beachwidth': 80}):
    """
    make kml of with information on trend differences
    """

    sites = beachwidth.transect_limits.keys()
    kvs = map(site2kustvak, sites)

    # read JarKus netcdf
    tr = Transects()
    rsp_lat = tr.get_data('rsp_lat')
    rsp_lon = tr.get_data('rsp_lon')
    rsp_id = tr.get_data('id')
    tr.close()

    loc = {}
    kml = simplekml.Kml()    
    folG = kml.newfolder()
    folO = kml.newfolder()
    folR = kml.newfolder()
    listred = []
    for site,kv in zip(sites, kvs):
        if site.startswith('kustvak_'):
            continue
        # plot figure of individual transect
        # beachwidth.plot_time(sites=[site])
        # trends
        trid_df, df, time_df, mask = beachwidth.get_dunefoot(beachwidth.DFreg, site, quiet=True)#, dfname='dune_foot_2ndDeriv_cross')
        trid_wl, wls, time_wl = beachwidth.get_waterline(beachwidth.WL, site)
        wl_tidxs = np.in1d(time_wl, time_df)
        df_tidxs = np.in1d(time_df, time_wl)
        years = np.array([t.year for t in time_df[df_tidxs]])
        bw = wls[0][wl_tidxs, :]-df
        logging.info(site)
        for idx,trid in enumerate(trid_df):
            yrs, crs, slp, bnds = beachwidth.linreg(years, bw[:, idx])
            # print trid, slp, bnds
            """conditions:
            slp[-1] < slp[-2] : trend after 1990 smaller than trend before 1990
            slp[-1] < threshold['trend'] : trend smaller than threshold
            crs[-1][-1] < threshold['beachwidth'] : beachwidth in 2015 (according to trend) smaller than threshold"""
            #np.count_nonzero(vals)
            bvals = np.array([slp[-1] < slp[-2], slp[-1] < threshold['trend'], crs[-1][-1] < threshold['beachwidth']])
            vals = np.array([slp[-2] ,slp[-1],crs[-1][-1]])
            # print trid, vals, np.count_nonzero(vals)
            rsp_idx = rsp_id == trid
            loc[trid] = {'lat': rsp_lat[rsp_idx], 'lon': rsp_lon[rsp_idx], 'val':vals,'bval':bvals,'count': np.count_nonzero(bvals)} # count number of True values

            key = trid
            
            if loc[key]['val'][2] > 80:# i.e. the current beachwidth is not smaller than 80m
                if (loc[key]['val'][2])+(loc[key]['val'][1]*5) > 80: # and the beachwidth remains within 80m after 5 years based on current trend 
                    pnt = folG.newpoint(name='%i' % key, coords=[(loc[key]['lon'][0],loc[key]['lat'][0])])  
                    pnt.style.iconstyle.icon.href = 'http://maps.google.com/mapfiles/kml/shapes/shaded_dot.png'
                    pnt.style.iconstyle.color = simplekml.Color.green 
                else:
                    pnt = folR.newpoint(name='%i' % key, coords=[(loc[key]['lon'][0],loc[key]['lat'][0])])  
                    pnt.style.iconstyle.icon.href = 'http://maps.google.com/mapfiles/kml/shapes/shaded_dot.png'
                    pnt.style.iconstyle.color = simplekml.Color.red 
                    listred.append(key)
            elif loc[key]['val'][1] > -1:
                    pnt = folG.newpoint(name='%i' % key, coords=[(loc[key]['lon'][0],loc[key]['lat'][0])])  
                    pnt.style.iconstyle.icon.href = 'http://maps.google.com/mapfiles/kml/shapes/shaded_dot.png'
                    pnt.style.iconstyle.color = simplekml.Color.green 
            elif loc[key]['val'][1] < -1:
                    pnt = folR.newpoint(name='%i' % key, coords=[(loc[key]['lon'][0],loc[key]['lat'][0])])  
                    pnt.style.iconstyle.icon.href = 'http://maps.google.com/mapfiles/kml/shapes/shaded_dot.png'
                    pnt.style.iconstyle.color = simplekml.Color.red 
                    listred.append(key)

            if np.isnan(loc[key]['val']).any():
                    pnt = folO.newpoint(name='%i' % key, coords=[(loc[key]['lon'][0],loc[key]['lat'][0])])  
                    pnt.style.iconstyle.icon.href = 'http://maps.google.com/mapfiles/kml/shapes/shaded_dot.png'
                    pnt.style.iconstyle.color = simplekml.Color.orange

                    
            #else:
                #pnt.style.iconstyle.color = simplekml.Color.orange
            pnt.description = tmpl.render(areacode=kv,
                                          transectid=trid,
                                          bwyear=yrs[-1][-1],
                                          bwval='%.0f' % crs[-1][-1],
                                          tr1years='%i - %i' % (bnds[-3], bnds[-2]),
                                          tr1val='%.1f' % slp[-2],
                                          tr2years='%i - %i' % (bnds[-2], bnds[-1]),
                                          tr2val='%.1f' % slp[-1],
                                          figname='plot_%08i.png' % trid,
                                          )
    folG.name = "Green (%i)" % len(folG.features)
    folO.name = "Orange (%i)" % len(folO.features)
    folR.name = "Red (%i)" % len(folR.features)
    kml.save("trends.kml")
        
    with open('redlist.csv', 'wb') as myfile:
        wr = csv.writer(myfile)
        for item in listred:        
            wr.writerow([item])


if __name__ == '__main__':
    # print kustvak
    plottrends(kustvak, ylim_fixed=25)
    #make_kml()
