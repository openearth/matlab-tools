#==============================
#Coastline Functions
#==============================
#JFriedman
#June 17/2015
#==============================

#import all necessary packages
#=============================
import os
from matplotlib import pyplot as plt
plt.ioff() #turn off plots popping on screen
from shapely.geometry import LineString,Polygon
from . import ioFuncs as IO
from . import osmFuncs as OSM

#remove islands from analysis (too complicated)
#==============================================
def CleanCoastline(XY):
    XY2 = []
    ii = 0
    for val in XY:
        if not LineString(val).is_closed: #exclude ISLANDS from coastline
            #plt.plot([x[0] for x in val],[x[1] for x in val],linewidth=2,label=str(ii))
            ii += 1
            XY2.append(val)
        #plt.legend()
    return XY2

#remove data outside of bounding box
#===================================
def CoastInBounds(XY,EPSGcode,lons,lats):
    
    #convert bounding box coordinates
    xy = OSM.ConvertCoordinates(4326,EPSGcode,lons,lats)
    jiggle = 25 #to remove odd end points
    xb = [sum(x) for x in zip(xy[0],[jiggle,-jiggle])]
    yb = [sum(x) for x in zip(xy[1],[jiggle,-jiggle])]
    bbox = [xb[0],xb[1],xb[1],xb[0],xb[0]],[yb[0],yb[0],yb[1],yb[1],yb[0]]

    #combine bounding box coordinates -> create polygon
    bbox_poly = Polygon(zip(bbox[0],bbox[1]))
    
    #combine coastline coordinates -> create linestring
    OUT = []
    for line in XY:
        temp = [(x,y) for x,y in zip(line[0],line[1])]
        #plt.plot([x[0] for x in temp],[x[1] for x in temp],c='k',linewidth=4) #visualize the individual features
        temp = LineString(temp)
        temp_in_bbox = bbox_poly.intersection(temp)
        if not temp_in_bbox.is_empty:
            if temp_in_bbox.type is 'MultiLineString':
                temper = []
                for liner in temp_in_bbox:
                    temper.extend(list(liner.coords))
                    #plt.plot([x[0] for x in temper],[x[1] for x in temper],c='r',linewidth=2) #visualize features IN bounding box
                OUT.append(temper)
            else:
                temp_in_bbox = list(temp_in_bbox.coords)
                #plt.plot([x[0] for x in temp_in_bbox],[x[1] for x in temp_in_bbox],c='r',linewidth=2) #visualize features IN bounding box
                OUT.append(temp_in_bbox)
    
    #plt.axis('equal')
    #plt.plot(bbox[0],bbox[1],'--b')            
            
    OUT = CleanCoastline(OUT)
    return OUT  

#get proper sequence of coastlines (not in order from ExtractOSMFeatures)
#========================================================================
def GetCoastlineOrder(XY):
   
    multiCoastFlag = False #assume there is only a SINGLE coastline
    starting = 0 #starting index
    ORDER = [starting] #index ORDER
    available = range(len(XY)) #list of ALL possible segments
    available = filter(lambda x: x != starting,available) #remove STARTING point
    
    #use starting point -> find order based on closest next segment
    while len(ORDER) != len(XY): #continue until all connections are made
        d = [] #initialize
        for ii in available: #loop through "available" connections
            starter = LineString(XY[starting]) #start
            connector = LineString(XY[ii]) #connector
            d.append(starter.distance(connector)) #distance between line segments
          
        check = filter(lambda x: x == 0,d)
        if (len(check) == 2) and (len(d) != 1): #if the first index is in middle (rare but possible!)
            starting = available[1] #starting index
            ORDER = [starting] #index ORDER
            available = range(len(XY)) #list of ALL possible segments
            available = filter(lambda x: x != starting,available) #remove STARTING point
        elif check == []:
            multiCoastFlag = True
            multiNum = len(available)
            break
        else:  
            ending = available[d.index(min(d))] #find min distance
            ORDER.append(ending) #add to index ORDER
            available = filter(lambda x: x != ending,available) #remove ENDING point
            starting = ending #re-assign starting point as end point (continue!)
            
    if multiCoastFlag: #if discontinuity in coastline (e.g. islands, harbours, etc...)
        starting = available[1] #starting index
        multiORDER = [starting] #index ORDER
        available = range(len(XY)) #list of ALL possible segments
        available = filter(lambda x: x != starting,available) #remove STARTING point
        
        #use starting point -> find order based on closest next segment
        while len(multiORDER) != multiNum: #continue until all connections are made
            d = [] #initialize
            for ii in available: #loop through "available" connections
                starter = LineString(XY[starting]) #start
                connector = LineString(XY[ii]) #connector
                d.append(starter.distance(connector)) #distance between line segments
              
            check = filter(lambda x: x == 0,d)
            if (len(check) == 2) and (len(d) != 1): #if the first index is in middle (rare but possible!)
                starting = available[1] #starting index
                multiORDER = [starting] #index ORDER
                available = range(len(XY)) #list of ALL possible segments
                available = filter(lambda x: x != starting,available) #remove STARTING point
            else:  
                ending = available[d.index(min(d))] #find min distance
                multiORDER.append(ending) #add to index ORDER
                available = filter(lambda x: x != ending,available) #remove ENDING point
                starting = ending #re-assign starting point as end point (continue!)
    
        #assemble order of coastlines together
        TEMP = []
        TEMP.append(ORDER)   
        TEMP.append(multiORDER)  
        
    else:
        TEMP = ORDER
            
    return TEMP,multiCoastFlag

#build coastline based on order + ensure it is within bounding box
#==================================================================
def BuildCoastline(XY,ORDER,multiFlag):
    
    if not multiFlag: #if single coastline (status quo)
        COAST = [] #initialize
        for ii in ORDER: #loop through order
            COAST.extend(XY[ii]) #put coordinates together
                        
        if not LineString(COAST).is_simple or LineString(COAST).is_closed: #if linestring is NOT simple (i.e. overlapping)
            COAST = [] #initialize again
            for ii in ORDER[::-1]: #order in REVERSE direction (land is on left!)
                COAST.extend(XY[ii]) #put coordinates together
                
    else: #if multiple coastlines exist
        COAST = [] #initialize
        for section in ORDER:
            temp = []
            for ii in section: #loop through order
                temp.extend(XY[ii]) #put coordinates together
                
            if not LineString(temp).is_simple: #if linestring is NOT simple (i.e. overlapping)
                temp = [] #initialize again
                for ii in section[::-1]: #order in REVERSE direction (land is on left!)
                    temp.extend(XY[ii]) #put coordinates together 
            COAST.append(temp)
         
    return COAST,multiFlag
        
#determine offset from coastline
#===============================
def OffsetCoastline(geo,multiFlag):
    
    coords = []
    if geo.geom_type != 'LineString':
        temp = filter(lambda x: not x.is_ring,geo)
        for t in temp:
            coords.append(list(t.coords))
        if len(temp) > 2:
            ORDER = GetCoastlineOrder(coords) #get order of linestrings (in case of gaps)
        else:
            ORDER = [0,1]
        XY,_ = BuildCoastline(coords,ORDER,False) #build linestring based on order!
    else:    
        XY = list(geo.coords)
    
    #put back into proper format for later analysis
    x = [val[0] for val in XY]
    y = [val[1] for val in XY]
    return x,y

#determine the coordinates of the AOI
#====================================
def ExtractAOI(name,COAST,multiFlag,buffer_dist,EPSGcode,curr):

    if not multiFlag: #if single coastline (status quo)
        #get coastline coordinates
        cx = [row[0] for row in COAST]
        cy = [row[1] for row in COAST]
        
        #offset coastline by buffer distance
        COAST = LineString(COAST)
        land = COAST.parallel_offset(buffer_dist,'left')
        water = COAST.parallel_offset(buffer_dist,'right')
        
        #get BOTH offset coordinates
        lx,ly = OffsetCoastline(land,multiFlag)
        wx,wy = OffsetCoastline(water,multiFlag)
        
        #combine BOTH offset coordinates -> AOI!
        X = wx+lx+[wx[0]]
        Y = wy+ly+[wy[0]]
        LON,LAT = OSM.ConvertCoordinates(EPSGcode,4326,X,Y)
        
        #build figure to verify the approach
        fig1 = plt.figure(figsize=(9,6), dpi=150, facecolor='w', edgecolor='k')
        plt.plot(cx,cy,'-k',linewidth=1,label='coastline from OpenStreetMaps')
        plt.plot(lx,ly,'-r',linewidth=1,label='land "offset"')
        plt.plot(wx,wy,'-b',linewidth=1,label='water "offset"')
        plt.plot(X,Y,'--',color='0.7',linewidth=0.75,label='bounding box') #bounding box
        
        #add necessary bells and whistles
        plt.axis('equal')
        plt.xticks(fontsize=8); plt.yticks(fontsize=8)
        plt.ylabel('Y-coord [m]',fontsize=10)
        plt.xlabel('X-coord [m]',fontsize=10)
        plt.title(name + ' Area of Interest (AOI) from ExtractAOI.py',fontsize=12)
        plt.legend(prop={'size':10},loc=0)
        
        #export figure
        outdir = IO.PathBuilder(curr,name)
        temp = os.path.join(outdir,"%s_AOI_Width=%dm.png" %(name.replace(' ','_'),buffer_dist))
        fig1.savefig(temp,dpi=300,bbox_inches='tight')
        plt.close("all")
        
    else:   #if multiple coastlines exist
        
        wx,wy,lx,ly = [],[],[],[]        
        for section in COAST:

            #offset coastline by buffer distance
            section = LineString(section)
            land = section.parallel_offset(buffer_dist,'left')
            water = section.parallel_offset(buffer_dist,'right')
            
            #get BOTH offset coordinates
            if not land.is_empty:
                tx,ty = OffsetCoastline(land,multiFlag)
                lx.append(tx)
                ly.append(ty)
            if not water.is_empty:            
                tx,ty = OffsetCoastline(water,multiFlag)
                wx.append(tx)
                wy.append(ty)
         
        #analyze the water coordinates
        if len(wx) != 0: #only if data EXISTS
            start = Polygon(zip(wx[0],wy[0]))
            for ii in range(1,len(wx)):
                wcombo = start.union(Polygon(zip(wx[ii],wy[ii])))
                start = wcombo #iterate on top of itself
            wx =  [row[0] for row in list(wcombo.exterior.coords)]
            wy =  [row[1] for row in list(wcombo.exterior.coords)]
            
        #analyze the land coordinates
        if len(lx) != 0: #only if data EXISTS
            start = Polygon(zip(lx[0],ly[0]))
            for ii in range(1,len(lx)):
                lcombo = start.union(Polygon(zip(lx[ii],ly[ii])))
                start = lcombo #iterate on top of itself
            lx =  [row[0] for row in list(lcombo.exterior.coords)]
            ly =  [row[1] for row in list(lcombo.exterior.coords)]
         
                  
        #combine BOTH offset coordinates -> AOI!
        X = wx+lx+[wx[0]]
        Y = wy+ly+[wy[0]]
        LON,LAT = OSM.ConvertCoordinates(EPSGcode,4326,X,Y)
        
        #build figure to verify the approach
        fig1 = plt.figure(figsize=(9,6), dpi=150, facecolor='w', edgecolor='k') #make single figure
        ii = 0
        for section in COAST:
            if ii == 0:
                plt.plot([x[0] for x in section],[x[1] for x in section],'-k',linewidth=1,label='coastline from OpenStreetMaps')
            else:
                plt.plot([x[0] for x in section],[x[1] for x in section],'-k',linewidth=1)
            ii += 1
        plt.plot(lx,ly,'-r',linewidth=1,label='land "offset"')
        plt.plot(wx,wy,'-b',linewidth=1,label='water "offset"')
        plt.plot(X,Y,'--',color='0.7',linewidth=0.75,label='bounding box') #bounding box
            
        #add necessary bells and whistles
        plt.axis('equal')
        plt.xticks(fontsize=8); plt.yticks(fontsize=8)
        plt.ylabel('Y-coord [m]',fontsize=10)
        plt.xlabel('X-coord [m]',fontsize=10)
        plt.title(name + ' Area of Interest (AOI) from ExtractAOI.py',fontsize=12)
        plt.legend(prop={'size':10},loc=0)
        
        #export figure
        outdir = IO.PathBuilder(curr,name)
        temp = os.path.join(outdir,"%s_AOI_Width=%dm.png" %(name.replace(' ','_'),buffer_dist))
        fig1.savefig(temp,dpi=300,bbox_inches='tight')
        plt.close("all")        
        
    return X,Y,LON,LAT