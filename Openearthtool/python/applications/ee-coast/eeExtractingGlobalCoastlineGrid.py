#=========================
#Extract Global Coastline
#=========================
#JFriedman
#Sept 22/2015
#=========================

#define initial search size + level of detail for OSM
#====================================================
main_dir = r'.\output'
coast_file = r'.\input\coastlines_z5_buffered_3500m_lines.shp'
sizer = 2000 #search size [km]
buffer_dist = 2.5 #buffer around OSM coastline [km]
smallest_box = 35 #in km -> smallest search box

#import all necessary packages
#=============================
#get the current working path + system path working properly
import sys
import os
curr = r'.' #define working file path (SLOPPY - need to fix!)
os.chdir(curr) #change working directory
sys.path.append(curr) #add to system path

import shapefile
import math
import numpy as np
import matplotlib as mpl
import matplotlib.pyplot as plt
import matplotlib.cm as cm
import matplotlib.patheffects as PathEffects
plt.ioff() #non-interactive plots
from pyproj import Proj, transform
import simplekml
import json
from shapely.geometry import Polygon,MultiLineString
import time
import ee_coast.ioFuncs as IO
                
#extract coastline from appropriate shapefile
#============================================    
def getCoastline(fname):
    
    sf = shapefile.Reader(fname)
    shapes = sf.shapes()
    num = len(sf.records()) #number of polygons

    CL = []
    for ii in range(num):
        CL.append(shapes[ii].points)
    
    return CL

#function to determine the initial search boxes
#==============================================
def initialBoxes(sizer):
    
    #define max extents of Mercator projection
    min_x = -20037518.34
    max_x = 20037518.34
    min_y = -9000000
    max_y = 18461351

    #round up/down based on max/min + size of boxes
    sizer *= 1000.
    min_x = np.floor(min_x/sizer)*sizer
    max_x = np.ceil(max_x/sizer)*sizer
    min_y = np.floor(min_y/sizer)*sizer
    max_y = np.ceil(max_y/sizer)*sizer
    
    #global extents for searching
    glob_x = [min_x, max_x]
    glob_y = [min_y, max_y]
    
    #build LVL0 "search boxes" (solves memory issues)
    gx,gy = np.meshgrid(np.arange(glob_x[0],glob_x[1],sizer),np.arange(glob_y[0],glob_y[1],sizer))
    boxes = np.vstack((np.hstack(gx), np.hstack(gx)+sizer, np.hstack(gy), np.hstack(gy)+sizer))
    boxes = np.transpose(boxes) #defined as [x_start x_end y_start y_end]
    
    return boxes

    
#function for breaking boxes into smaller boxes (quadruple)
#==========================================================
def inceptionBox(search_box):
    
    s = abs(search_box[0][0] - search_box[0][1])
    new_search_box = []
    
    for box in search_box: #build 4 new boxes inside initial box
        new_search_box.append([box[0]    ,box[1]-s/2,box[2]    ,box[3]-s/2])
        new_search_box.append([box[0]+s/2,box[1]    ,box[2]    ,box[3]-s/2])
        new_search_box.append([box[0]    ,box[1]-s/2,box[2]+s/2,box[3]])
        new_search_box.append([box[0]+s/2,box[1]    ,box[2]+s/2,box[3]])
    
    return new_search_box
    
#extracting coordinates from shapely vector (LineString or MultiLineString)
#==========================================================================
def getCoords(temp):
    
    if temp.type is not 'LineString':
            out = []
            for liner in temp:
                out.append(list(liner.coords))
    else:
        out = [list(temp.coords)]
        
    return out
  
#intersect a single "initial" box with the entire coastline (MultiLineString) 
#============================================================================
def intersectBox(box,CL_line):
    
    bbox = Polygon([(box[0],box[2]),(box[1],box[2]),(box[1],box[3]),(box[0],box[3]),(box[0],box[2])])
    in_bbox = bbox.intersection(CL_line)
    
    if not in_bbox.is_empty:
        temp = getCoords(in_bbox)
    else:
        temp = []
        
    return temp
    
#intersect smaller "inception" boxes with the coastline in the initial box 
#==========================================================================    
def intersectInceptionBox(sboxes,CL_box):
    
    CL_in_sbox = []
    sboxes_with_CL = []

    for sbox in sboxes: #go through each individually
        temp = intersectBox(sbox,MultiLineString(CL_box))
        if temp:
            CL_in_sbox.append(intersectBox(sbox,MultiLineString(CL_box)))
            sboxes_with_CL.append(sbox)
            
    return sboxes_with_CL, CL_in_sbox
    
#simple pythagorus for getting distance between points
#======================================================
def distance(p0, p1):
    return math.sqrt((p0[0] - p1[0])**2 + (p0[1] - p1[1])**2) #pythagorus between two points

#convert to cartesian coordinates to determine possible zones
#============================================================
def ConvertCoordinates(EPSGin,EPSGout,x1,y1):
    
    inProj = Proj(init='epsg:%s' %EPSGin) #input projection
    outProj = Proj(init='epsg:%s' %EPSGout) #ouput projection
    xy = transform(inProj,outProj,x1,y1)
    
    return xy
    
#plot the boxes on the map -> gives spatial link between indices and map!
#========================================================================
def PlotBoxMap(init_boxes,data_boxes,outdir):    
    
    #define figure + colormap
    fig = plt.figure(figsize=(9,6), dpi=150, facecolor='w', edgecolor='k')#plot the entire coastline (use the non-buffered version)
    cols_empty = cm.Reds(np.linspace(0.15,0.85,len(init_boxes))) #build colormap
    cols_data = cm.Greens(np.linspace(0.15,0.85,len(init_boxes))) #build colormap
    
    #plot the entire coastline (use the non-buffered version)
    CL = getCoastline(r'.\input\coastlines_z5.shp')
    for cl in CL:
        plt.plot([x[0] for x in cl],[x[1] for x in cl],lw=0.75,c='k')
        
    #get bounds for plotting
    xlimmer = [init_boxes[0][0],init_boxes[-1][1]]
    ylimmer = [init_boxes[0][2],init_boxes[-1][3]]
    
    #plot the initial boxes with their index number inside
    jj = 0
    for box in init_boxes:
        
        plt.plot([box[0],box[1],box[1],box[0],box[0]],[box[2],box[2],box[3],box[3],box[2]],'-',c='0.7',lw=0.5)
        
        #if there is data in the box
        if any([jj == check for check in data_boxes]):
            plt.fill([box[0],box[1],box[1],box[0],box[0]],[box[2],box[2],box[3],box[3],box[2]],'-',color='#66FF66',alpha=0.5)
            plt.text((box[0]+box[1])/2, (box[2]+box[3])/2, '%03d' %jj, color=cols_data[jj],
                     size=6,fontweight='bold',ha="center", va="center",
                     path_effects=[PathEffects.withStroke(linewidth=2,foreground="w")])
        else:
            plt.text((box[0]+box[1])/2, (box[2]+box[3])/2, '%03d' %jj, color=cols_empty[jj],
                     size=6,fontweight='bold',ha="center", va="center",
                     path_effects=[PathEffects.withStroke(linewidth=2,foreground="w")])
        jj += 1
    
    #remove axis information
    plt.axis('equal')
    plt.axis(xlimmer+ylimmer)
    plt.axis('off')
    plt.tight_layout()
    
    #save figure to output directory
    fig.savefig(os.path.join(outdir,"BOX_Locations.png"),dpi=300,bbox_inches='tight')
    plt.close("all")

#plot the boxes on the map -> gives spatial link between indices and map!
#========================================================================
def PlotDetailedBoxMap(lbox,temp_sboxes,counter,outdir):  
    
    #define figure + colormap
    fig = plt.figure(figsize=(6,6), dpi=150, facecolor='w', edgecolor='k')
    ax = fig.add_axes([0.05,0.05,0.85,0.85])
    ax.yaxis.set_ticks([])
    ax.xaxis.set_ticks([])
    
    #set up colormap
    cmapper = plt.cm.get_cmap('Greens')
    num = len(temp_sboxes)
    cNorm  = mpl.colors.Normalize(vmin=0, vmax=num-1)
    scalarMap = mpl.cm.ScalarMappable(norm=cNorm, cmap=cmapper)    
        
    #plot the entire coastline (use the non-buffered version)
    CL = getCoastline(r'.\input\coastlines_z5.shp')
    for cl in CL:
        plt.plot([x[0] for x in cl],[x[1] for x in cl],lw=0.75,c='k')
    
    #plot the initial boxes with their index number inside
    jj = 0
    for box in temp_sboxes:
        colorVal = scalarMap.to_rgba(jj)
        plt.plot([box[0],box[1],box[1],box[0],box[0]],[box[2],box[2],box[3],box[3],box[2]],'-',c='0.7',lw=0.5)
        plt.fill([box[0],box[1],box[1],box[0],box[0]],[box[2],box[2],box[3],box[3],box[2]],'-',color=colorVal,alpha=0.5)

        jj += 1
    
    #remove axis information
    plt.axis(lbox)
    plt.title('BOX_%03d' %counter,fontsize=14)
         
    #add colormap for easy referencing
    cbaxes = fig.add_axes([0.925, 0.05, 0.02, 0.85]) 
    cbar = mpl.colorbar.ColorbarBase(cbaxes, cmap=cmapper, norm=cNorm, orientation='vertical')
    cbar.set_label('Analysis Box [#]',fontsize=8)
    
    #dynamically change ticklabels (make sure you can see them)
    if num < 20:
        ticker = range(num)
    elif num< 40:
        ticker = range(0,num,2)
    elif num < 100:
        ticker = range(0,num,5)
    elif num< 200:
        ticker = range(0,num,10)
    else:
        ticker = range(0,num,25)
        
    cbar.set_ticks(ticker)
    plt.tick_params(labelsize=8)
     
    #save figure to output directory
    fig.savefig(os.path.join(outdir,"BOX_%03d_Analysis_Boxes.png" %counter),dpi=300,bbox_inches='tight')
    plt.close("all")
 
#build simple kml for testing boxes in google earth (for scale)
#==============================================================
def BuildKML(box,cl_in_box,counter,outdir):
    
    #build coordinates of boxes
    x0,y0 = ConvertCoordinates(3857,4326,[x[0] for x in box],[x[2] for x in box])
    x1,y1 = ConvertCoordinates(3857,4326,[x[1] for x in box],[x[3] for x in box])        
    temp_box = zip(x0,x1,y0,y1)
    
    #set up colormap
    cmapper = plt.cm.get_cmap('Greens')
    num = len(temp_box)
    cNorm  = mpl.colors.Normalize(vmin=0, vmax=num-1)
    scalarMap = mpl.cm.ScalarMappable(norm=cNorm, cmap=cmapper)    

    #initialize kml instance
    kml = simplekml.Kml()
    
    #loop through all box coordinates -> make polygon
    jj = 0
    for b in temp_box:
        colorVal = scalarMap.to_rgba(jj)
        pol = kml.newpolygon(name= 'Box_%03d' %jj, outerboundaryis=[(b[0],b[2]),(b[1],b[2]),(b[1],b[3]),(b[0],b[3]),(b[0],b[2])])
        pol.style.polystyle.fill = 0 #turn fill off -> easier to visualize
        pol.style.linestyle.color = simplekml.Color.rgb(colorVal[0]*255,colorVal[1]*255,colorVal[2]*255)
        pol.style.linestyle.width = 3 #in pixels
        jj+=1
        
    #loop through all coastline sections -> make linestrings
    for cl in cl_in_box:
        for c in cl:
            xt,yt = ConvertCoordinates(3857,4326,[x[0] for x in c],[x[1] for x in c])
            lin = kml.newlinestring(name = 'Coastline', coords = zip(xt,yt))
            lin.style.linestyle.color = simplekml.Color.yellow
            lin.style.linestyle.width = 2.5
       
    temp = 'BOX_%03d_Analysis_Boxes.kml' %counter
    kml.save(os.path.join(outdir,temp))
 
#save final search boxes for later analysis
#==========================================
def saveData(data,namer,outdir):
    
    with open(os.path.join(outdir,namer), 'w') as f:
            json.dump(data, f, indent=2)

#determine number of inception iterations to perform
#===================================================
def getIterations(sizer,smallest_box):
    
    result = sizer
    iternum = -1
    
    while result > smallest_box: #make sure smallest tiles are less than Xkm in width/height
        result *= 0.5
        iternum += 1
    return iternum

#process initial box to buffered polygons
#========================================
def ProcessBufferedCoastlines(box,CL_line,iternum,buffer_dist,outdir,counter,tot_counter):       

    #determine the coastline inside of box
    CL_box = intersectBox(box,CL_line) 
    
    if CL_box:
        CL_box = [x for x in CL_box if len(x) > 1] #remove possible single points at edge of box
        ii = 0
    
        while ii <= iternum:
            print 'Initial box %d of %d -> in a dream %s' %(counter,tot_counter,'within a dream '*ii) #for updating user
            
            if ii == 0:
                sboxes = inceptionBox([box]) #smaller boxes inside main box
            else:
                sboxes = inceptionBox(sboxes) #smaller boxes inside main box
            
            if ii == iternum: #end of inception boxes -> save results! 
            
                # build output folder structure
                tempdir = IO.PathBuilder(main_dir,'BOX_%03d' %counter)
            
                temp_sboxes,temp_CL = intersectInceptionBox(sboxes,CL_box)
    
                #build KML for easy visualization of approach
                BuildKML(temp_sboxes,temp_CL,counter,tempdir)
                PlotDetailedBoxMap(box,temp_sboxes,counter,tempdir)        
                
                #save each search box into its own folder
                xx = 0
                for search in temp_sboxes:
                    tdir = IO.PathBuilder(tempdir,'BOX_%03d_%03d' %(counter,xx))
                    tx,ty = ConvertCoordinates(3857,4326,search[:2],search[2:])
                    bbox = tx+ty #put x+y together in list
                    bbox = [[bbox[0],bbox[2]],[bbox[1],bbox[2]],[bbox[1],bbox[3]],[bbox[0],bbox[3]]] #get bounding box
                    saveData(bbox,'BOX_%03d_%03d.json' %(counter,xx),tdir)
                    xx+=1
         
                #let user know the "inception" boxes are complete ("kick" out of the dream)
                print '======'*ii    
                print 'Kick! '*ii
                print '======'*ii          
         
            else:
                sboxes,_ = intersectInceptionBox(sboxes,CL_box) #use newer "smaller" boxes as initial search for next loop!
        
            ii += 1  
            
    counter += 1
    
    return counter
    
#pre-process the coastline to linestring -> determine initial boxes
CL = getCoastline(coast_file)
CL_line = MultiLineString(CL) #turn the coastline coordinates into vector multilinestring (shapely!)
init_boxes = initialBoxes(sizer) #determine initial boxes over the entire world

#set up counter + iteration number for inception boxes
counter = 0
iternum = getIterations(sizer,smallest_box)
tot_counter = len(init_boxes)

#process buffered polygons around each individual box
start_time = time.time() #for timing the code
for box in init_boxes: #loop through boxes
    counter = ProcessBufferedCoastlines(box,CL_line,iternum,buffer_dist,main_dir,counter,tot_counter)

#make overview plot of the extracted boxes
data_boxes = [int(d.split('_')[1]) for d in os.listdir(main_dir) if os.path.isdir(os.path.join(main_dir, d))] 
PlotBoxMap(init_boxes,data_boxes,main_dir) #build plot of all initial boxes + CL (for reference)    
    
print "--- %.1f seconds ---" %(time.time() - start_time)
