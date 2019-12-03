#======================================
#Extract OSMaps Critical Infrastructure
#======================================
#JFriedman
#June 23/2015
#======================================

#import all necessary packages
#=============================
import osmFuncs as OSM

#define the main SHELL
#=====================
name = 'Zandmotor'
lats = [52, 52.3]
lons = [4, 4.3]
EPSGcode = 28992
curr = r'p:\1205871-bouwen-ad-kust\SatelliteImages\ee-coast'
   
ALL = {'building':['apartments','hotel','house','retail'],
    'highway':['motorway','trunk','primary','secondary','tertiary','unclassified','residential'],
    'leisure':['marina'],
    'man_made':['breakwater','embankment','dyke','groyne','pier'],
    'natural':['wetland'],
    'tourism':['hotel']}
    
XY = {}
for KEY in ALL:
    for VAL in ALL[KEY]:
        try:
            temp = OSM.ExtractOSMFeatures(KEY,VAL,lons,lats,name,EPSGcode)
            namer = '-'.join([KEY, VAL])
            XY[namer] = temp #assign to dictionary to keep clean!
            print 'Currently Extracting Key = %s, Value = %s' %(KEY,VAL)
        except:
            print 'NO DATA AVAILABLE!'

import matplotlib.pyplot as plt
from matplotlib import cm as cmap
plt.ion()
      
#PLOT THE DATA
fig1 = plt.figure(figsize=(9,6), dpi=150, facecolor='w', edgecolor='k')
jj = 0
for key in XY:
    for ii in range(len(XY[key])):
        if ii == 0: 
            plt.plot(XY[key][ii][0],XY[key][ii][1],color=cmap.spectral(jj/(len(XY)+1.)),linewidth=0.75,label=key)
        else:
            plt.plot(XY[key][ii][0],XY[key][ii][1],color=cmap.spectral(jj/(len(XY)+1.)),linewidth=0.75)
    jj += 1

#add necessary bells and whistles
plt.axis('equal')
plt.xticks(fontsize=8); plt.yticks(fontsize=8)
plt.ylabel('Y-coord [m]',fontsize=10)
plt.xlabel('X-coord [m]',fontsize=10)
plt.title(name+' Output from OSMExtract.py',fontsize=12)
plt.legend(prop={'size':10},loc=0)

#def BuildKML(outdir,KEY,VAL,lon,lat,name):
#    kml = simplekml.Kml()
#    r,g,b,a = cmap.jet(random.randint(1,255))
#    for ii in range(len(lon)):
#        lin = kml.newlinestring(name = "Section %d" %ii, coords = [(x,y) for (x,y) in zip(lon[ii],lat[ii])])
#        lin.style.linestyle.color = simplekml.Color.rgb(r*255,g*255,b*255,a*255)
#        lin.style.linestyle.width = 3
#    temp = os.path.join(outdir,"_".join([name,KEY,VAL])+".kml")
#    kml.save(temp)