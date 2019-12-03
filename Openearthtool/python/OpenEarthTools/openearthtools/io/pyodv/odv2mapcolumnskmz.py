## columns plot in KML

__version__ = "$Revision:  $"

#  Copyright notice
#   --------------------------------------------------------------------
#   Copyright (C) 2014 Deltares for EMODnet Chemistry
#       Giorgio Santinelli / Gerben J. de Boer
#
#       Giorgio.Santinelli@deltares.nl / gerben.deboer@deltares.nl
#
#   This library is free software: you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
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
#
# This tool is part of <a href="http://www.OpenEarth.eu">OpenEarthTools</a>.
# OpenEarthTools is an online collaboration to share and manage data and
# programming tools in an open source, version controlled environment.
# Sign up to recieve regular updates of this function, and to contribute
# your own tools.

# $Id:  $
# $Date:  $
# $Author:  $
# $Revision:  $
# $HeadURL:  $
# $Keywords: $

# for WPS: see http://matplotlib.org/faq/environment_variables_faq.html#envvar-MPLCONFIGDIR
# add to ..\apache\...\pywps.cgi: os.environ['MPLCONFIGDIR']='C:/Python27/Lib/site-packages/matplotlib/mpl-data' 
import os, numpy
# http://matplotlib.org/faq/howto_faq.html#howto-webapp
import matplotlib
matplotlib.use('Agg') # use non-interactive plot window on server
import matplotlib.pyplot as plt
import simplekml # not pythonXY: win32>> pip install simplekml
from shapely.geometry import Point, Polygon # shapely for polygons base definition
import odvdatetime

## local settings
iconfile        = os.path.join(os.path.split(__file__)[0], 'static', 'shaded_dot.png')
colobartemplate = os.path.join(os.path.split(__file__)[0], 'static', 'KML_colorbar_template_vertical.png')
fontsize = 11
Balloon  = False
maxHeight = 1e5 # max height of the columns

def kmltime(s):    
    """parses ISO8601 string 2006-01-04T12:00:00:000 to kml ISO8601 string"""
    
    t = odvdatetime.iso2datetime(s)
    
    return t.strftime('%Y-%m-%dT%H:%M:%S')
    
def cmap2png(cmapstr, clims, log10, clabel, alphavalue, stream):
    """
    create png with colorbar
    """
    # set colormap
    if log10:
        norm = matplotlib.colors.Normalize(vmin=numpy.log10(clims[0]), vmax=numpy.log10(clims[1]), clip=False)
    else:
        norm = matplotlib.colors.Normalize(vmin=clims[0], vmax=clims[1], clip=False)
    # read background image
    im = plt.imread(colobartemplate)
    # derive figsize based on aspect ratio of background image
    figsize = tuple(numpy.asarray(im.shape[-2::-1]) / float(im.shape[0]) * 6)
    # create figure
    fig = plt.figure(figsize=figsize)

    # plot background image
    axbg = fig.add_axes([0., 0., 1., 1.],
                        frameon=False,
                        xticks=[],
                        yticks=[])
    axbg.imshow(im)
    # plot colorbar
    ax = fig.add_axes([0.4, 0.2, 0.2, 0.72])
    if log10:
        cticks = numpy.linspace(clims[0], clims[1],8)
        cb = matplotlib.colorbar.ColorbarBase(ax, 
                                       ticks=numpy.log10(cticks),
                                       norm=norm,
                                       cmap=cmapstr,
                                       alpha=alphavalue,
                                       orientation='vertical')
        cticklabels = []
        for c in cticks:
           cticklabels.append( '%.2g' % c)
        cb.set_ticklabels(cticklabels)
    else:
        cb = matplotlib.colorbar.ColorbarBase(ax, 
                                       norm=norm,
                                       cmap=cmapstr,
                                       alpha=alphavalue,
                                       orientation='vertical')
    cb.set_label(clabel, color='w', labelpad=-60, fontsize=fontsize)
    # format ticklabels
    cbytick_obj = plt.getp(cb.ax.axes, 'yticklabels')
    plt.setp(cbytick_obj, color='w', fontsize=fontsize)
    # stream result
    fig.savefig(stream, format='png', transparent=True, facecolor='none')
        
    return stream

def odv2mapcolumnskmz(kmzFilepath,ODV,cname,clims=[],log10=0,kmzcolumns=0,cmapstr="jet",alphavalue=1): # simplekml
    "save json ODV object to kml, where last json column is scatter dot"
    
    cname = cname.replace(' ','_') # same as pandas does for all spaces.
    ic = []
    for i,l in enumerate(ODV.odv_column):
        if ODV.pandas_name[i] in cname: # odv_column has units in it, and also _ for spaces
           ic = i
           break  
    
    df = ODV.data

    N    = df.shape[0] # series length
    M    = df.shape[1] # parameter column
    time = df[ODV.time_column]
    lon  = df[df.columns[4]]
    lat  = df[df.columns[5]]
    c    = df[df.columns[ic]] # NB flags column ic+1
    
    stnam = 'Station'
    rows  = df[stnam]
    kml   = simplekml.Kml(name=ODV.sdn_name[ic],description='<![CDATA[ <a href="http://www.seadatanet.org/Standards-Software/Software/ODV">ODV</a> visualization provided by <a href="http://www.openearth.nl"> OpenEarthTools</a> via <a href="http://pywps.wald.intevation.org/"> pyWPS</a>]]>')
    icon  = kml.addfile(iconfile)
    
    # color limits autoscale (use numpy to be nan-safe)
    if len(clims)==0:
        clims    = [0,0]
        clims[0] = numpy.min(ODV.data[cname])
        clims[1] = numpy.max(ODV.data[cname])       
    if clims[0]==numpy.finfo('single').max:
        clims[0] = numpy.min(ODV.data[cname])
    if clims[1]==numpy.finfo('single').min:
        clims[1] = numpy.max(ODV.data[cname])
        
    pfol = kml.newfolder(name="test")
    for irow in range(0, N):
        #value = c[irow] #df.get_value(irow,df.columns[ic]) # df.as_matrix()[irow,ic] # 
        value = c[irow]

            # normalize the values from 0-1 using either log either linear
        if log10:
           if value>=clims[1]:
              nvalue = 1
           elif value<=clims[0]:
              nvalue = 0
           else:
              nvalue = (numpy.log10(value-clims[0])) / (numpy.log10(clims[1]-clims[0]))
        else:
            nvalue = (value-clims[0])/(clims[1]-clims[0])

        # accept only a single clims!!! No log yet!
        elevation = maxHeight*nvalue
        
        if log10:
           norm = matplotlib.colors.Normalize(vmin=numpy.log10(clims[0]), vmax=numpy.log10(clims[1]), clip=False)
           cm = matplotlib.cm.ScalarMappable(norm=norm, cmap=cmapstr)
           cnorm = cm.to_rgba(numpy.log10(value))
        else:
           norm = matplotlib.colors.Normalize(vmin=clims[0], vmax=clims[1], clip=False)
           cm = matplotlib.cm.ScalarMappable(norm=norm, cmap=cmapstr)
           cnorm = cm.to_rgba(value)
        
        pol = pfol.newpolygon()
        pol.visibility = 1
        # 'trans Blue Poly'
        colorcol = simplekml.Color.rgb(cnorm[0]*255,cnorm[1]*255,cnorm[2]*255,alphavalue*255)
        pol.style.polystyle.color = colorcol
        pol.style.linestyle.color = colorcol
        pol.altitudemode = 'relativeToGround'
        pol.extrude = 1
        
        pnt= [(lon[irow],lat[irow])]
        point= Point(pnt)
        apoly= point.buffer(0.05) #0.1
        coords=numpy.asarray(apoly.exterior)
        asize = elevation
        pol.outerboundaryis = ([(float(coords[j][0]),float(coords[j][1]),asize) for j in range(0,len(coords),8)])
        
        
        #pol.timestamp = simplekml.TimeStamp(datetime.datetime(int(p[i][1]),int(p[i][2]),int(p[i][3])).isoformat()+'Z')
        # pnt = kml.newpoint(name=str(value))
        # pnt.coords = [(lon[irow], lat[irow])] # [(df["Longitude_[degrees_east]"][irow], df["Latitude_[degrees_north]"][irow])]
        
        
        #pol.timestamp.when = kmltime(time[irow]) # due to errors in some odv files we need to parse back to ISO8601
        pol.timestamp.when = time[irow]
        #cnorm = max(0,min(1,float(value - clims[0])/(clims[1] - clims[0])))*255.

       
        # stylemap
        # normalstyle
        
        # pnt.stylemap.normalstyle.iconstyle.color = simplekml.Color.rgb(cnorm[0]*255,cnorm[1]*255,cnorm[2]*255,alphavalue*255)
        # pnt.stylemap.normalstyle.iconstyle.icon.href = icon
        # pnt.stylemap.normalstyle.iconstyle.scale = .5
        # pnt.stylemap.normalstyle.labelstyle.scale = 0

        # highlightstyle
        
        # pnt.stylemap.highlightstyle.iconstyle.color = simplekml.Color.rgb(cnorm[0]*255,cnorm[1]*255,cnorm[2]*255,alphavalue*255)
        # pnt.stylemap.highlightstyle.iconstyle.icon.href = icon
        # pnt.stylemap.highlightstyle.iconstyle.scale = 1.5
        
        # balloonstyle
        if Balloon:
            pol.stylemap.highlightstyle.balloonstyle.text = "<![CDATA[<h3>" + stnam + " $[name]</h3> $[description]]]>"
            descr = "<![CDATA[ <table width='100%' border='0' cellpadding='0' cellspacing='1'>"
            for icol in range(0, 9):
                
                tmpval = ODV.data.as_matrix()[irow,icol] # df.get_value(irow,df.columns[icol])
                if icol%2:
                    descr += "<tr bgcolor='DDDDDD'><td>" + df.columns[icol] + "</td><td> " + str(tmpval) + "</td></tr>"
                else:
                    descr += "<tr><td>"                  + df.columns[icol] + "</td><td> " + str(tmpval) + "</td></tr>"

            descr += "<tr bgcolor='DDDDDD'><td>SDN P01 quantity</td><td> " + ODV.sdn_name[ic]  + "</td></tr>"
            descr +=                  "<tr><td>SDN P06 units</td><td> "    + ODV.sdn_units[ic] + "</td></tr>"
            
            pol.description = descr + "</table>]]>"
            descr = None
        
    cbfile  = os.path.split(kmzFilepath)[0] + '/' + os.path.splitext(os.path.split(kmzFilepath)[1])[0] + '_colorbar_%s.png'%(cmapstr)
    if log10:
        clabel = 'log10(' + ODV.sdn_name[ic] + '[' + ODV.sdn_units[ic] + '])'
    else:
        clabel = ODV.sdn_name[ic] + '[' + ODV.sdn_units[ic] + ']'
    cmap2png(cmapstr, clims, log10, clabel, alphavalue, cbfile)
    kml.addfile(cbfile)
    
    # add colorbar
    screen = kml.newscreenoverlay(name='Colorbar')
    screen.icon.href = 'files/' + os.path.split(cbfile)[1]
    screen.overlayxy = simplekml.OverlayXY(x=0,y=.5,xunits=simplekml.Units.fraction,
                                           yunits=simplekml.Units.fraction)
    screen.screenxy  = simplekml.ScreenXY (x=0,y=.5,xunits=simplekml.Units.fraction,
                                           yunits=simplekml.Units.fraction)
    
    #kml.save(kmzFilepath) # kml builder gives some xml recursion problems
    kml.savekmz(kmzFilepath, format=False)
    
    return kmzFilepath
