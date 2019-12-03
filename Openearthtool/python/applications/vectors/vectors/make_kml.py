# -*- coding: utf-8 -*-
# <nbformat>3.0</nbformat>

# <codecell>
import io
import simplekml
import pandas
import pandas.io.sql


def points(df):
    kml = simplekml.Kml(open=1)
    fol = kml.newfolder(name="ICES Observations")
    #label part of the KML
    for i, row in df.iterrows():
        coords = [tuple(row[['st_x', 'st_y']])]
        fol.newpoint(description=str(row[['statsq']].item(0)), coords=coords)

    a = io.BytesIO()
    kml.savekmz(a,format=True)
    a.seek(0)
    return a

    #a = kml.kml()
    #fkmz = r'd:\temp\icesobservations.kmz'
    #kml.save(fkml)
    #kml.savekmz(fkmz)

def ices(df):


    kml = simplekml.Kml(open=1)
    pfol = kml.newfolder(name="ICES Rectangles")
    sharedstyle = simplekml.Style()
    sharedstyle.polystyle.color = '7d00ff00'  # Green
    sharedstyle.linestyle.color = '7d00ff00'  # Green
    #label part of the KML
    for i, row in df.iterrows():
        #netlink = pfol.newnetworklink(name=row['statsq'])
        #netlink.link.href = "/kml/PO4/{statsq}".format(statsq=row["statsq"])
        #netlink.link.viewrefreshmode = simplekml.ViewRefreshMode.onregion
        ws, en = row['box2d'].replace('BOX(','').replace(')','').split(',')
        w,s = ws.split()
        e,n = en.split()
        box = simplekml.LatLonBox(north=float(n),south=float(s),east=float(e),west=float(w))
        lod = simplekml.Lod(minlodpixels=100,maxlodpixels=2000,minfadeextent=10, maxfadeextent=20)
        region = simplekml.Region(box, lod)
        #netlink.region = region
        pol = pfol.newpolygon()
        pol.style = sharedstyle
        coords = row['st_askml'].replace('<Polygon><outerBoundaryIs><LinearRing><coordinates>','').replace('</coordinates></LinearRing></outerBoundaryIs></Polygon>','').split(' ')
        pol.outerboundaryis = ([(float(coords[j].split(',')[0]),float(coords[j].split(',')[1])) for j in range(len(coords))])
        pol.description='''<p><a href="species/PO4/{statsq}"><img src="species/PO4/{statsq}" width="600" height="400"></img></a></p>'''.format(statsq=row['statsq'])
        pol.region =region

    return kml.kml()

    #fkml = r'd:\temp\icessquares.kmz'
    #kml.savekmz(fkml)

def pts_ices(df2, statsq):
    kml = simplekml.Kml(open=1)
    pfol = kml.newfolder(name=statsq)
    sharedstyle = simplekml.Style()
    sharedstyle.labelstyle.color = 'ad30ff00'  # Green
    sharedstyle.linestyle.color = 'ad30ff00'  # Green
    sharedstyle.iconstyle.icon.href = 'http://maps.google.com/mapfiles/kml/shapes/placemark_circle.png'
    #label part of the KML
    for i, row in df2.iterrows():
        mp = pfol.newmultigeometry()
        mp.style = sharedstyle
        if row['collect'].startswith('POINT'):
            lon, lat = row['collect'].replace('POINT(','').replace(')','').split()
            mp.newpoint(coords=[(lon, lat)])
        elif row['collect'].startswith('MULTIPOINT'):
            mptext = row['collect'].replace('POINT(','').replace(')','')
            coords = [point.split() for point in mptext.split(',')]
            for coord in coords:
                mp.newpoint(coords=[coord])
        else:
            raise ValueError(row['collect'])

    return kml.kml()
    #fkml = r'd:\temp\{}.kmz'.format(statsq)
    #kml.savekmz(fkml)
