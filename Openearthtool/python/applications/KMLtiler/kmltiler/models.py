import numpy as np
import matplotlib.pyplot as plt
import io
import simplekml

def code2png(code):
    """
    create png with random colored patch and the tile code in its center
    """
    fig = plt.figure(figsize=(2, 2), dpi=128)
    
    fontsize = 170 / len(code) 
    
    ax = fig.add_axes([0.,0.,1.,1.])
    ax.text(0.5, 0.5, code,
        fontsize=fontsize,
        horizontalalignment='center',
        verticalalignment='center')
    ax.get_xaxis().set_visible(False)
    ax.get_yaxis().set_visible(False)
    
    ax.patch.set_facecolor(tuple(np.random.random(3)))
    ax.patch.set_alpha(0.5)
    
    stream = io.BytesIO()
    fig.savefig(stream, format='png', facecolor='none', dpi=128)
    stream.seek(0)
        
    return stream

def code2kml(code):
    """
    creat kml based on tile code
    """
    latmax, latmin, lonmin, lonmax = code2bounds(code)
    kml = simplekml.Kml()
    box = simplekml.LatLonBox(north=latmax, south=latmin, west=lonmin, east=lonmax)
    lod = simplekml.Lod(minlodpixels=256, maxlodpixels=1024, minfadeextent=128, maxfadeextent=512)
    region = simplekml.Region(box, lod)
    ground = kml.newgroundoverlay(name=code)
    ground.latlonbox.north = latmax
    ground.latlonbox.south = latmin
    ground.latlonbox.east =  lonmax
    ground.latlonbox.west =  lonmin
    ground.draworder = 5
    ground.region = region
    ground.icon.href = "%s.png"%(code)
    
    for subcode in map(lambda c: "%i"%c, np.arange(4)):
        latmax, latmin, lonmin, lonmax = code2bounds(code+subcode)
        link = kml.newnetworklink(name=code+subcode)
        box = simplekml.LatLonBox(north=latmax, south=latmin, west=lonmin, east=lonmax)
        lod = simplekml.Lod(minlodpixels=256, maxlodpixels=-1)
        region = simplekml.Region(box, lod)
        link.region = region
        link.link.href = "%s.kml"%(code+subcode)
        link.link.viewrefreshmode = simplekml.ViewRefreshMode.onregion
        
    return kml

def code2bounds(code):
    """
    convert tile code to bounds
    """
    zoomlevel = len(code)
    tilesizes = 360. / 2.**np.asarray(np.arange(zoomlevel))
    # west
    lonmin    = -180 + np.sum([tilesizes[x] for x in np.arange(zoomlevel) if code[x] in '13'])
    # east
    lonmax    = lonmin + tilesizes[-1]
    # south
    latmin    = -540 + np.sum([tilesizes[x] for x in np.arange(zoomlevel) if code[x] in '01'])
    # north
    latmax    = latmin + tilesizes[-1]
    
    return latmax, latmin, lonmin, lonmax
