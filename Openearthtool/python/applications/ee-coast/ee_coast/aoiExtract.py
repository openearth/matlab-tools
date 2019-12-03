#==============================
#Extract Coastline Buffer (AOI)
#==============================
#JFriedman
#June 17/2015
#==============================

#import all necessary packages
#=============================
import os
import json
import osmFuncs as OSM
import ioFuncs as IO
import coastlineFuncs as CL

#define the main SHELL
#=====================
def SHELL(name = 'Zandmotor', lats = [52.03, 52.074], lons = [4.16, 4.222],
                     EPSGcode = 28992, buffer_dist = 1000,
                     curr = r'p:\1205871-bouwen-ad-kust\SatelliteImages\ee-coast'):
    
    curr = IO.PathBuilder(curr,'PROJECTS') #add projects folder to store data   
    
    print 'Currently Extracting Coastline...'
    XY = OSM.ExtractOSMFeatures('natural','coastline',lons,lats,name,EPSGcode)
    
#    #DEBUGGING!
#    import matplotlib.pyplot as plt
#    for val in XY:
#        plt.plot(val[0],val[1],'k')
#    plt.axis('equal')
#    plt.show()
        
    print 'Currently Removing Features Outside of Bounding Box...'  
    XY = CL.CoastInBounds(XY,EPSGcode,lons,lats)
    
#    #DEBUGGING!
#    for val in XY:
#        plt.plot([x[0] for x in val],[x[1] for x in val],'r')
#    plt.show()
    
    print 'Currently Getting the Correct Coastline Order...'
    ORDER,multiFlag = CL.GetCoastlineOrder(XY)
    
    print 'Currently Building and Cropping the Coastline...'
    COAST,multiFlag = CL.BuildCoastline(XY,ORDER,multiFlag)
    
#    #DEBUGGING!
#    if multiFlag:
#        for section in COAST:
#            plt.plot([x[0] for x in section],[x[1] for x in section],'b')    
#    else:
#        plt.plot([x[0] for x in COAST],[x[1] for x in COAST],'.b')
#    plt.show()
    
    print 'Currently Extracting the Area of Interest...'
    X,Y,LON,LAT = CL.ExtractAOI(name,COAST,multiFlag,buffer_dist,EPSGcode,curr)

    print 'Currently Exporting AOI to *.kml...'
    IO.BuildKML(name,LON,LAT,buffer_dist,curr)
    
    #save data to json for later use
    RAW = [LON,LAT]
    RAW = [[x,y] for x,y in zip(RAW[0][::-1],RAW[1][::-1])] #first flip direction (COUNTER CLOCKWISE!)
    
    print 'Currently Saving Coastline to *.json...'
    with open(os.path.join(curr,name, '%s_AOI.json' %name.replace(' ','_')), 'w') as f:
        json.dump(RAW, f)

    return RAW

##DEBUG!!!
#COAST = [] #initialize
#for ii in ORDER: #loop through order
#    x = [val for val in XY[ii][0]]
#    y = [val for val in XY[ii][1]]
#    COAST.extend((zip(x,y))) #zip coordinates together
#    
#if not LineString(COAST).is_simple: #if linestring is NOT simple (i.e. overlapping)
#    COAST = [] #initialize again
#    for ii in ORDER[::-1]: #order in REVERSE directIOn (land is on left!)
#        x = [val for val in XY[ii][0]]
#        y = [val for val in XY[ii][1]]
#        COAST.extend((zip(x,y))) #zip coordinates together
#            
#cx = [row[0] for row in COAST]
#cy = [row[1] for row in COAST]
#import matplotlib.pyplot as plt
#plt.plot(cx,cy)
#plt.axis('equal')
#
#ii = 0
#for vals in XY:
#    plt.plot(vals[0],vals[1],label=str(ii))
#    ii += 1
#plt.legend()