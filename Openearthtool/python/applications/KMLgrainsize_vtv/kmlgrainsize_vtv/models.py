import numpy as np
import matplotlib.pyplot as plt
import matplotlib as mpl
import simplekml
from netCDF4 import Dataset
from mako.template import Template
import tempfile,os

"""
TODO:
    - make relative path to template
    - put proper units in icon names
    - solve "QPixmap: It is not safe to use pixmaps outside the GUI thread"
    - define a default colormap which is initially visible after opening the file
"""

url = 'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/grainsize_vtv/grainsize_vtv.nc'
colobartemplate = os.path.join(os.path.split(__file__)[0], 'static'   , 'KML_colorbar_template_vertical.png')
baloontemplate  = os.path.join(os.path.split(__file__)[0], 'templates', 'description_template.mako')
icon            = os.path.join(os.path.split(__file__)[0], 'static'   , 'shaded_dot.png')
fontsize = 11

with open(baloontemplate, 'r') as f:
    template = Template(f.read())

def mainkml(kmz=False):
    """
    creat main kml pointing to all available colormaps
    """
#    icon = os.path.join(os.path.split(__file__)[0], 'static', 'shaded_dot.png')
    cmaps = mpl.cm.datad.keys()
    cmaps.sort()
    kml = simplekml.Kml(name='VTV grain size')
    if kmz:
        icon = kml.addfile(icon)
    fol = kml.newfolder(name='Colormaps')
    fol.style.liststyle.listitemtype = simplekml.ListItemType.radiofolder
    for cmap in cmaps:
        if not cmap.endswith("_r"):
            subfol = fol.newfolder(name=cmap)
            subfol.style.liststyle.listitemtype = simplekml.ListItemType.radiofolder
            for suffix in ['', '_r']:
                netlink = subfol.newnetworklink(name=cmap+suffix)
                if kmz:
                    cbfile  = os.path.join(tempfile.gettempdir(), 'colorbar_%s.png'%(cmap+suffix))
                    kmlfile = os.path.join(tempfile.gettempdir(), 'grainsize_%s.kml'%(cmap+suffix))
                    kml.addfile(cbfile)
                    path = kml.addfile(kmlfile)
                    cmap2png(cmap+suffix, cbfile)
                    cmap2kml(cmap+suffix, kmz=False, icon=os.path.split(icon)[-1]).save(kmlfile)
                else:
                    path = 'grainsize_%s.kml'%(cmap+suffix)
                netlink.link.href = path
    return kml

def readdata(keys=None):
    """
    read data from netCDF file
    """
    try:
        ds = Dataset(url)
        if keys==None:
            keys = ds.variables.keys()
        data = dict.fromkeys(keys)
        for key in keys:
            data[key] = ds.variables[key][:]
    finally:
        ds.close()
    return data

def cmap2png(cmapstr, stream):
    """
    create png with colorbar
    """
    # read data
    data = readdata(['meanD50',])
    D50 = data['meanD50']*1e6
    # set colormap
    if hasattr(mpl.cm, cmapstr):
        cmap = eval('mpl.cm.%s'%cmapstr)
    norm = mpl.colors.Normalize(vmin=np.min(D50), vmax=np.max(D50), clip=False)
    # read background image
    im = plt.imread(colobartemplate)
    # derive figsize based on aspect ratio of background image
    figsize = tuple(np.asarray(im.shape[-2::-1]) / float(im.shape[0]) * 6)
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
    cb = mpl.colorbar.ColorbarBase(ax, cmap=cmap,
                                       norm=norm,
                                       orientation='vertical')
    cb.set_label('Mean D$_{50}$ grain size [$\mu$m]', color='w', labelpad=-60, fontsize=fontsize)
    # format ticklabels
    cbytick_obj = plt.getp(cb.ax.axes, 'yticklabels')
    plt.setp(cbytick_obj, color='w', fontsize=fontsize)
    # stream result
    fig.savefig(stream, format='png', transparent=True, facecolor='none')
        
    return stream

def cmap2icon(cmapstr, stream):
    """
    create png with colorbar
    """
    # read data
    data = readdata(['meanD50',])
    D50 = data['meanD50']*1e6
    # set colormap
    if hasattr(mpl.cm, cmapstr):
        cmap = eval('mpl.cm.%s'%cmapstr)
    norm = mpl.colors.Normalize(vmin=np.min(D50), vmax=np.max(D50), clip=False)
    # create colorbar
    fig = plt.figure(figsize=(2,.2))
    # plot colorbar
    ax = fig.add_axes([0., 0., 1., 1.])
    cb = mpl.colorbar.ColorbarBase(ax, cmap=cmap,
                                       norm=norm,
                                       ticks=[],
                                       orientation='horizonal')
    # stream result
    fig.savefig(stream, format='png', transparent=True, facecolor='none')
        
    return stream

def cmap2kml(cmapstr, kmz=False):
    """
    create kml based on colormap
    """
    data = readdata()
    lon,lat = data['lon'],data['lat']
    D50 = data['meanD50']*1e6
    
    if hasattr(mpl.cm, cmapstr):
        cmap = eval('mpl.cm.%s'%cmapstr)
    norm = mpl.colors.Normalize(vmin=np.min(D50), vmax=np.max(D50), clip=False)
    cm = mpl.cm.ScalarMappable(norm=norm, cmap=cmap)
    
    rgba = cm.to_rgba(D50)
    
    kml= simplekml.Kml(name='VTV grain size', description='<![CDATA[<a href="http://www.rijkswaterstaat.nl">Rijkswaterstaat</a> grain sizes provided by <a href="http://www.openearth.nl"> OpenEarthTools</a><br>see <a href="http://repository.tudelft.nl/view/hydro/uuid%3A15d29d22-862b-418e-903d-d90c01f04983/">VTV2006</a> and <a href="http://repository.tudelft.nl/view/hydro/uuid%3A0348afd3-d846-4be9-934f-abb5f2d4e0b2/">TAW1984</a> for more info]]>')
    
    # set initial camera position
    kml.document.camera.latitude = np.mean((np.max(lat), np.min(lat)))
    kml.document.camera.longitude = np.mean((np.max(lon), np.min(lon)))
    kml.document.camera.altitude = 355e3
    kml.document.camera.tilt = 0
    
    for idx,(lt,ln,d50,c) in enumerate(zip(lat,lon,D50,rgba)):
        pt = kml.newpoint(name="%i"%d50, coords=[(ln,lt)])
        # stylemap
        # normalstyle
        pt.stylemap.normalstyle.iconstyle.color = simplekml.Color.rgb(*tuple(c*255))
        pt.stylemap.normalstyle.iconstyle.icon.href = icon
        pt.stylemap.normalstyle.iconstyle.scale = .5
        pt.stylemap.normalstyle.labelstyle.scale = 0
        # highlightstyle
        pt.stylemap.highlightstyle.iconstyle.color = simplekml.Color.rgb(*tuple(c*255))
        pt.stylemap.highlightstyle.iconstyle.icon.href = icon
        pt.stylemap.highlightstyle.iconstyle.scale = 1.5
        # balloonstyle
        pt.stylemap.highlightstyle.balloonstyle.text = '<h3>Mean D<sub>50</sub> $[name] &mu;m</h3> $[description]'
        # description
        pt.description = description(idx=idx,data=data)
    
    # add colorbar
    screen = kml.newscreenoverlay(name='Colorbar')
    if kmz:
        # adjust the relative file reference in case will be saved as kmz
        screen.icon.href = 'files/colorbar_%s.png'%cmapstr
    else:
        screen.icon.href = 'colorbar_%s.png'%cmapstr
    screen.overlayxy = simplekml.OverlayXY(x=0,y=.5,xunits=simplekml.Units.fraction,
                                           yunits=simplekml.Units.fraction)
    screen.screenxy = simplekml.ScreenXY(x=0,y=.5,xunits=simplekml.Units.fraction,
                                         yunits=simplekml.Units.fraction)
    
    return kml

def description(idx=None, data=dict()):
    """
    create description string
    """
    areaname = "".join(data['areaname'][:,idx])
    descr = template.render(url=url,
                            idx=idx,
                            ftp=url.replace('dodsC', 'fileServer'),
                            data=data,
                            areaname=areaname)
    return descr