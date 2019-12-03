# -*- coding: utf-8 -*-
"""
Created on Mon Jun 23 16:54:29 2014

@author: heijer
"""

from netCDF4 import Dataset,num2date
import glob
import numpy as np
import simplekml
from mako.template import Template
import datetime
import re
import argparse
try:
    from thredds_crawler.crawl import Crawl
except:
    print 'thredds_crawler not installed'
import os

with open('templates/balloon_template.mako', 'r') as f:
    balloon_template = Template(f.read())

with open('templates/balloon_style.mako', 'r') as f:
    balloon_style = Template(f.read())

with open('templates/description_template.mako', 'r') as f:
    descr_template = Template(f.read())

def vaklodingen_coords2kb(x, y, prefix='KB'):
    # convert x,y to the lower left corner coordinates x0,y0
    x0 = x - np.mod(x, 500*20)
    y0 = y - np.mod(y, 625*20)
    
    # derive code in two directions
    xcode = x0/1e4 + 111
    ycode = np.round(11008 + ((y0+20) * -.01616))
    
    # create kaartblad name string
    kbname = '%s%03.0f_%04.0f' % (prefix, xcode, ycode)
    
    return kbname

def dates2list(dates):
    years, months, days = zip(*[(d.year, d.month, d.day) for d in dates])
    deq = np.unique(days).shape == (1,)
    meq = np.unique(months).shape == (1,)
    # .strftime function not used because it cannot deal with dates before 1900
    if deq and meq:
        showdate = datetime.date(2014, dates[-1].month, dates[-1].day)
        comment = 'all data is dated at %s'%showdate.strftime('%m %B')
        datelist = ['%s'%d.year for d in dates]
    elif deq:
        comment = 'all data is dated at day %i of the month'%days[0]
        datelist = ['%s-%s' % (d.year, d.month) for d in dates]
    else:
        comment = ''
        datelist = ['%s-%s-%s' % (d.year, d.month, d.day) for d in dates]
    return datelist,comment

def mask2coverage(mask):
    val = float(np.count_nonzero(~mask))/np.prod(mask.shape)*100
    if val < 1:
        s = '%.1g %%' % val
    else:
        s = '%.0f %%' % val
    return s
    
def readnc(fname):
    try:
        ds = Dataset(fname)
        x = ds.variables['x']
        y = ds.variables['y']
        lon = ds.variables['lon']
        lat = ds.variables['lat']
        t = ds.variables['time']
        z = ds.variables['z'][:]
        zmask = np.ma.masked_invalid(z).mask
        if len(t)==1:
            zcov = [mask2coverage(zmask)]
        else:
            zcov = map(mask2coverage, zmask)
        dates = num2date(t[:], units=t.units)
        kbname = vaklodingen_coords2kb(x[0], y[0], prefix='')
        xlim = (np.min(x), np.max(x))
        ylim = (np.min(y), np.max(y))
        if not kbname in fname:
            print kbname, 'doesn\'t match filename'
        bbox = [[lon[0,0],lat[0,0]],
                [lon[0,-1],lat[0,-1]],
                [lon[-1,-1],lat[-1,-1]],
                [lon[-1,0],lat[-1,0]],
                [lon[0,0],lat[0,0]]]
    finally:
        ds.close()
    return kbname, bbox, dates, zcov, xlim, ylim
    
def tile2kml(bbox, name, pol_folder=None, lab_folder=None, description='', style=''):
    """
    convert bounding box to kml polygon
    """
    points = [list(p)+[10] for p in bbox]
    # create polygon
    pol = pol_folder.newpolygon(name=name,
                         outerboundaryis=points)
    pol.description = description

    pol.altitudemode = 'relativeToGround'
    if pol_folder.stylemaps == []:
        pol.stylemap.normalstyle.linestyle.color = simplekml.Color.red
        pol.stylemap.normalstyle.polystyle.color = simplekml.Color.changealphaint(0, simplekml.Color.red)
        pol.stylemap.highlightstyle.linestyle.color = simplekml.Color.white
        pol.stylemap.highlightstyle.polystyle.color = simplekml.Color.changealphaint(100, simplekml.Color.blue)
        pol.stylemap.normalstyle.iconstyle.scale = 0
        pol.stylemap.highlightstyle.iconstyle.scale = 0
        pol.stylemap.highlightstyle.balloonstyle.text = style
    else:
        pol.stylemap = pol_folder.stylemaps[0]

    lon,lat,_ = zip(*points)
    lonpt = np.mean((np.min(lon),np.max(lon)))
    latpt = np.mean((np.min(lat),np.max(lat)))
    
    # create placemark at center of polygon for the tile number
    pt = lab_folder.newpoint(name = name, coords=[(lonpt,latpt)])
    #pt.style.balloonstyle.text = pol.style.balloonstyle.text
    pt.description = description
    pt.stylemap = pol_folder.stylemaps[0]
    # add region for placemark
    box = simplekml.LatLonBox(north=latpt+.05, south=latpt-.05, west=lonpt-.05, east=lonpt+.05)
    if int(name[2])%2 == 0:
        minlodpixels = 2**6
    else:
        minlodpixels = 2**7       
    lod = simplekml.Lod(minlodpixels=minlodpixels, maxlodpixels=-1)
    region = simplekml.Region(box, lod)
    pt.region = region

    #return kml

def crawl_files(mainurl):
    """
    return nc files, either opendap urls or local paths
    """
    if re.search('^http.*\.xml$', mainurl):
        skips = Crawl.SKIPS + ["catalog.nc"]
        c = Crawl(mainurl, skip=skips)
        ncfiles = []
        for d in c.datasets:
            dsurl = [ds['url'] for ds in d.services if ds['service'] == 'OPENDAP']
            ncfiles.append(dsurl[0])
    else:
        ncfiles = glob.glob(os.path.join(mainurl, '*.nc'))
        ncfiles = [ncf for ncf in ncfiles if not re.search('catalog\.nc$', ncf)]

    # read title from first file
    ds = Dataset(ncfiles[0])
    datasetname = ds.title
    ds.close()

    return ncfiles, datasetname

def makekml(mainurl, datasetname, rawdataurl, opendapbaseurl='', ftpbaseurl=''):
    ncfiles, dstitle = crawl_files(mainurl)
    if datasetname in (None, ''):
        datasetname = dstitle
    rawdataalias = datasetname.replace(' ', '')
    
    # create kml object
    file_description = descr_template.render(date=datetime.datetime.utcnow().strftime('%Y-%m-%d'),
                                            rawdataurl=rawdataurl,
                                            rawdataalias=rawdataalias,
                                            datasetname=datasetname)
    kml = simplekml.Kml(name="%s overview"%datasetname,
                        description=file_description)
    balloonstyle = balloon_style.render(datasetname=datasetname)
    # add two folders
    pol_folder = kml.newfolder(name='polygons')
    lab_folder = kml.newfolder(name='labels')
    llur = [np.nan, np.nan]
    llll = [np.nan, np.nan]
    xyur = [np.nan, np.nan]
    xyll = [np.nan, np.nan]
    for fname in ncfiles:
        # loop over all ncfiles and add the bounding boxes to the kml
        print fname
        if re.match('http', fname):
            ncurl = fname
            ftpurl = re.sub('dodsC', 'fileServer', ncurl)
            opendapurl = '%s.html' % ncurl
        else:
            ncurl = os.path.split(fname)[-1]
            ftpurl = ftpbaseurl+ncurl
            opendapurl = '%s.html' % (opendapbaseurl+ncurl)
            
        kbname, bbox, dates, zcov, xlim, ylim = readnc(fname)
        datelist,comment = dates2list(dates)
        # get the indices if ascending sorted
        sortidx = sorted(np.arange(len(datelist)), key=lambda k: datelist[k])
        datecov = [(datelist[idx],zcov[idx]) for idx in sortidx[::-1]]
        tile_description = balloon_template.render(epsg=28992,
                                              xmin=xlim[0],
                                              xmax=xlim[1],
                                              ymin=ylim[0],
                                              ymax=ylim[1],
                                              comment=comment,
                                              datecov=datecov,
                                              opendapurl=opendapurl,
                                              ftpurl=ftpurl)
        tile2kml(bbox, kbname,
                       pol_folder=pol_folder,
                       lab_folder=lab_folder, 
                       description=tile_description,
                       style=balloonstyle)
        bbox.append(llll)
        bbox.append(llur)
        llll = map(np.nanmin, zip(*bbox))
        llur = map(np.nanmax, zip(*bbox))
        xyur = map(np.nanmax, zip(xyur, (xlim[1], ylim[1])))
        xyll = map(np.nanmin, zip(xyll, (xlim[0], ylim[0])))
    
    dx,dy = map(np.diff, zip(xyll, xyur))
    
    # set lookat
    kml.document.lookat.tilt = 0
    kml.document.lookat.range = np.max([.95*dx, 1.4*dy])
    lon,lat = map(np.mean, zip(llll, llur))
    kml.document.lookat.latitude = lat
    kml.document.lookat.longitude = lon
    
    # save kml
    kml.save("%s_overview.kml" % rawdataalias.lower())

if __name__ == '__main__':
    mainurl = 'http://dtvirt5.deltares.nl:8080/thredds/dodsC/opendap/rijkswaterstaat/vaklodingen/catalog.xml'

    rawdataurl = 'https://svn.oss.deltares.nl/repos/openearthrawdata/trunk/rijkswaterstaat/dienstzeeland/'
    opendapurl = 'http://dtvirt5.deltares.nl:8080/thredds/dodsC/opendap/rijkswaterstaat/vaklodingen/'
    ftpurl = 'http://dtvirt5.deltares.nl:8080/thredds/fileServer/opendap/rijkswaterstaat/vaklodingen/'
    
    parser = argparse.ArgumentParser(description='Create overview kml with bathymetry tiles')
    parser.add_argument('-u', '--url', type=str, default=mainurl, help='url of catalog.xml (default: %s)' % mainurl)
    parser.add_argument('-n', '--name', type=str, help='dataset name (by default the global attribute "title" is used)')
    parser.add_argument('-r', '--rawurl', type=str, default=rawdataurl, help='url of raw data (default: %s)'%rawdataurl)
    parser.add_argument('-o', '--opendapurl', type=str, default=opendapurl, help='url of opendap data (default: %s)'%rawdataurl)
    parser.add_argument('-f', '--ftpurl', type=str, default=ftpurl, help='url of ftp data (default: %s)'%rawdataurl)
    args = parser.parse_args()
    makekml(args.url, args.name, args.rawurl, opendapbaseurl=args.opendapurl, ftpbaseurl=args.ftpurl)

