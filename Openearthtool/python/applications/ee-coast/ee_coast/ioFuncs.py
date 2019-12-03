#==============================
#Input/Output Functions
#==============================
#JFriedman
#June 17/2015
#==============================

#import all necessary packages
#=============================
import os
import json
import simplekml
import datetime
import getpass
from pykml import parser

#load the polygon KML file to define the AOI
#===========================================
def loadKML(outdir):
    
    #load file in directory (only *.kml) -> assume only 1!
    infile = [file for file in os.listdir(outdir) if ".kml" in file][0] #get first *.kml file 
    
    #parse KML
    root = parser.fromstring(open(os.path.join(outdir,infile),'r').read())
    
    #get coordinates -> assume a SINGLE COUNTER-CLOCKWISE polygon!  
    temp = str(root.Document.Placemark.Polygon.outerBoundaryIs.LinearRing.coordinates).replace('\t','').replace('\n','').split(',0 ')
    temp = [x.split(',') for x in temp]
    bounds = [[float(x[0]),float(x[1])] for x in temp[:-1]]
    
    return bounds

#build output folder based on name
#=================================
def PathBuilder(curr,name):
    
    outdir = os.path.join(curr,name)
    if not os.path.exists(outdir):
        os.makedirs(outdir)
    return outdir    
    
#build simple kml for exporting (later INPUT for satellite image work)
#=====================================================================
def BuildKML(name,LON,LAT,buffer_dist,curr):
    
    kml = simplekml.Kml()
    
    pol = kml.newpolygon(name= name+" Buffer Zone",
                     outerboundaryis=[(x0,y0) for (x0,y0) in zip(LON,LAT)])    
    pol.style.polystyle.fill = 0 #turn fill off -> easier to visualize
    pol.style.linestyle.color = simplekml.Color.red
    pol.style.linestyle.width = 5 #in pixels
    
    outdir = PathBuilder(curr,name)
    temp = os.path.join(outdir,"%s_AOI_Width=%dm.kml" %(name.replace(' ','_'),buffer_dist))
    kml.save(temp)
 
#function to determine how many values exist in a nested list
#============================================================
def flatten(seq,container=None):
    if container is None:
        container = []
    for s in seq:
        if hasattr(s,'__iter__'):
            flatten(s,container)
        else:
            container.append(s)
    return container
   
#write out the coastline results into *.ldb file (later analysis)
#===============================================================
def writeCoastline(name,xy,dateLims,tempdir):
    
    #loop through all reduced image dates (i.e. dateLims)
    for ii in range(len(dateLims)):
        fname = "%s_%s_to_%s.ldb" %(name,datetime.datetime.strftime(dateLims[ii][0],'%Y%m%d'),datetime.datetime.strftime(dateLims[ii][1],'%Y%m%d'))

        f = open(os.path.join(tempdir,fname), 'w')      
        f.write('*column 1 = x coordinate\n')
        f.write('*column 2 = y coordinate\n')
        f.write('   1\n')
        num_vals = len(flatten(xy[ii]))/2
        f.write('%d 2\n' %num_vals)
        
        for jj in range(len(xy[ii])):
            for kk in range(len(xy[ii][jj])):
                for ll in range(len(xy[ii][jj][kk])):
                    f.write('%f %f\n' %(xy[ii][jj][kk][ll]))
                if jj != len(xy[ii])-1:
                    f.write('-999 -999\n')
        f.close()

#save geoJSON data from coastlines for later processing
#======================================================
def dumpGeoJSON(name,xy,dateLims,tempdir):
    
    fname = "%s_%s_to_%s.geojson" %(name,datetime.datetime.strftime(dateLims[0][0],'%Y%m%d'),datetime.datetime.strftime(dateLims[0][1],'%Y%m%d'))    
    with open(os.path.join(tempdir,fname),'w') as f:
            json.dump(xy,f,indent=2)

#write out the morphology results
#================================
def writeMorphology(name,m,dateLims,tempdir):
    
    temp_date = [x[0] + (x[1] - x[0])/2 for x in dateLims] #get "fake" middle date of reduced images
    
    f = open(os.path.join(tempdir,"%s_Morphology.txt" %name), 'w')
    f.write('Earth Engine Satellite Morphology Output\n')
    f.write('================================\n')
    f.write('Run by: %s\n' %getpass.getuser())
    f.write('Run on: %s\n' %datetime.datetime.now())
    f.write('Project Location: %s\n' %name)
    f.write('================================\n')
    f.write('Start Date, End Date, Accretion [m2], Erosion [m2], Net [m2]\n')
    f.write('--------------------------------\n')
    for ii in range(len(m)):
        f.write('%s, %s, %.1f, %.1f, %.1f\n' %(datetime.datetime.strftime(temp_date[ii],'%Y/%m/%d'),
                                               datetime.datetime.strftime(temp_date[ii+1],'%Y/%m/%d'),m[ii][0],m[ii][1],m[ii][2]))
    f.write('================================\n')
    f.close()