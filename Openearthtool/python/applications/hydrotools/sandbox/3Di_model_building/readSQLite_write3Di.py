# -*- coding: utf-8 -*-
"""
Created on Fri Apr 10 17:26:44 2015

This script could be used to build a stand alone version of you 3Di model, based on the SQLITE database.
TO DO:
- Add more cross-section types to cross-section definition
- Add connected channel type
- Add boundary conditions
- Cleanup script (e.g. make defintions)
- Add other model features, like weirs, pumps etc.

@author: Mark Hegnauer (mark.hegnauer@deltares.nl)
"""

import sqlite3
import matplotlib.pyplot as plt
import numpy as np
from osgeo import ogr
from osgeo import osr
from osgeo import gdal
import re
from shapely.geometry import Point,LineString
import random

class ChannelData(object):
    """Placeholder class for Channel data. To be used in templates."""
    def __init__(self, id=None, branchid=None, type=None, nr_calc_points=10, length=None,
                 start_point=None, end_point=None, the_geom=None, ):
        self.id = id
        self.branchid        = branchid
        self.the_geom        = the_geom
        self.type            = type
        self.length          = length
        self.start_point     = start_point
        self.end_point       = end_point
        if type == '0':
            # embedded channel has no intermediate nodes
            self.nr_calc_points = 0
        else:
            # type = '1'; isolated channel
            self.nr_calc_points = nr_calc_points

class NodeData(object):
    """Placeholder class for Node data. To be used in templates."""
    def __init__(self, id=None, branchid=None, type=None, start_point=None, end_point=None, the_geom=None, banklevel=None):
        self.id = id
        self.branchid        = branchid
        self.the_geom        = the_geom
        self.type            = type
        self.start_point     = start_point
        self.end_point       = end_point
        self.start_point_type= start_point_type
        self.end_point_type  = end_point_type
        self.banklevel       = banklevel

class CrossectionData(object):
    """Placeholder class for Crosssection data. To be used in templates."""
    def __init__(self, id=None, channel_id=None, the_geom=None, definition_id=None, bottom_level=None,
                 friction_type=None, friction_value=None, chainage=None, ):
        self.id = id
        self.channel_id      = channel_id
        self.the_geom        = the_geom
        self.definition_id   = definition_id
        self.bottom_level    = bottom_level
        self.friction_type   = friction_type
        self.friction_value  = friction_value
        self.chainage        = chainage

class CrossectionDefinition(object):
    """Placeholder class for Crosssection data. To be used in templates."""
    def __init__(self, id=None, shape=None, width=None, diameter=None, levels=None, y=None, z=None,
                 closed=None, height=None, ):
        self.id        = id
        self.shape     = type
        self.width     = width
        self.diameter  = diameter
        self.levels    = levels
        self.y         = y
        self.z         = z
        self.closed    = closed
        self.height    = height

def create_channel_inp_id_map(channels):
    """
    Some structures need to know on which channel they are on. This
    function returns a mapping of the channel ids as they are written in the
    network.inp.

    """
    counter = 1
    mapping = {}
    for channel in channels:
        channel_idx      = channel[-2]
        mapping[channel_idx] = counter
        counter += 1
    return mapping

def create_crosssection_inp_id_map(crosssections):
    """
    Some structures need to know on which channel they are on. This
    function returns a mapping of the channel ids as they are written in the
    network.inp.

    """
    counter = 1
    mapping = {}
    for crosssection in crosssections:
        crosssection_idx      = crosssection[-2]
        mapping[crosssection_idx] = counter
        counter += 1
    return mapping

## HERE SET YOUR OWN WORKING DIRECTORY ##
path_to_files  = r'd:\tools\HYDTools\sandbox\3Di_model_building'

"""DEFINITION OF FILES"""
plifile              = path_to_files + '/one_d/network_ayuthaya_default.pli'
inpfile              = path_to_files + '/one_d/network_ayuthaya_default.inp'
crossection_inp_file = path_to_files + '/one_d/crosssections_ayuthaya_default.inp'
crossection_def_file = path_to_files + '/one_d/definitions_ayuthaya_default.inp'
plifile_le           = path_to_files + '/polygons/levees_ayuthaya_default.pli'
plifile_gr           = path_to_files + '/polygons/grid_refinement_ayuthaya_default.pli'
dem_file             = path_to_files + '/subgrid/dummy.tif'

"""PATH TO SQLITE"""
db = path_to_files+ '/dummy.sqlite'

"""READ PROJECTION INFORMATION FOR TRANSFORMATION (if needed)"""
dataset = gdal.Open(dem_file)
sp      = osr.SpatialReference()
sp.ImportFromWkt(dataset.GetProjectionRef())
sp_reference_int = int(sp.GetAttrValue("AUTHORITY", 1))

sep = ' '

"""SET PART(S) OF MODEL YOU WANT TO BUILD"""
make_channels          = 1 #SHOULD ALSO BE SET IF YOU WANT TO BUILD CROSS-SECTIONS, BECAUSE OF ID MAPPING
make_crosssections_inp = 1
make_crosssections_def = 1
make_gridrefinement    = 1
make_levees            = 1

plotting = False ## Takes much more time, but you can check some parts of the conversion better

"""MAKE DATABASE CONNECTIONS"""
conn       = sqlite3.connect(db)
print conn.execute("PRAGMA foreign_keys").fetchall()
cursor     = conn.cursor()

tables     = cursor.execute("select name from sqlite_master where type = 'table'").fetchall()
driver     = ogr.GetDriverByName("Sqlite")
dataSource = driver.Open(db, 0)
print "Available tables in SQLITE are:\n"
for i in range(0, len(dataSource)):
    print i, dataSource.GetLayer(i).GetName()


"""
###############################################################################
HERE THE ACTUAL BUILDING BEGINS, STARTING WITH CHANNELS (*.inp & *.pli)
###############################################################################
"""
if make_channels == 1:
    channels  = np.array(cursor.execute("SELECT * FROM CHANNEL").fetchall())
    ids       = create_channel_inp_id_map(channels)
    layer = dataSource.GetLayer(0)
    
    nodes = []; nodes_data = []; lenghts = []; idx = []; channelsarray = []
    oplifile = open(plifile,'w') 
    ## EVERY FEATURE IS A LINK IN CHANNEL
    
    ofile = open(inpfile,'w')
    for feature,channel in zip(layer,channels):
        geom        = feature.GetGeometryRef()
        source      = osr.SpatialReference()
        source.ImportFromEPSG(4326)
        
        target      = osr.SpatialReference()
        target.ImportFromEPSG(sp_reference_int)
        
        transform   = osr.CoordinateTransformation(source, target)
        geom.Transform(transform)
        geometry    = geom.ExportToWkt()[12:-1]
        geometry    = re.split(',',geometry)
        
        oplifile.write(str(feature['code']) + '\n')
        oplifile.write(str(np.shape(geometry)[0]) + ' 2' + '\n')
        for j in np.arange(0,np.shape(geometry)[0]):
            oplifile.write(str('%.10f' %(float(geometry[j].split(' ')[0]))) + " " + str('%.10f' %(float(geometry[j].split(' ')[1]))) + " \n")
        oplifile.write('\n')
        
        startpoint_x = str('%.10f' %float(geometry[0].split(' ')[0]))
        startpoint_y = str('%.10f' %float(geometry[0].split(' ')[1]))
        start_point  = startpoint_x + ' ' + startpoint_y
        
        endpoint_x  = str('%.10f' %float(geometry[-1].split(' ')[0]))
        endpoint_y  = str('%.10f' %float(geometry[-1].split(' ')[1]))
        end_point   = endpoint_x + ' ' + endpoint_y
    
        tot_length = geom.Length()
        
        nr_calc_points   = np.ceil(tot_length/channel[5])
        channel_type     = channel[2]
        channel_boundary = channel[3]
        
        if channel_type > 0 and channel_boundary > 0:
            if channel_boundary == 3:
                # both nodes are boundaries
                start_point_type = -1
                end_point_type   = -1
            elif channel_boundary == 2:
                # only node_2 is a boundary
                start_point_type = 1
                end_point_type   = -1
            else:
                assert channel_boundary == 1
                # only node_1 is a boundary
                start_point_type = -1
                end_point_type   = 1
        elif channel_type > 0 and channel_boundary == 0:
            start_point_type     = 1
            end_point_type       = 1       
        else:
            start_point_type     = 0
            end_point_type       = 0
        
        banklevel = feature['bank_level']
        
        Channel = ChannelData(id=ids[channel[8]], branchid=channel[8], type=channel_type, nr_calc_points=nr_calc_points,
                              length=tot_length, the_geom = geometry, start_point = start_point, end_point=end_point)
        
        Start_Node  = NodeData(id=ids[channel[8]], branchid=channel[8], type=start_point_type, start_point = start_point, banklevel=banklevel)                       
        End_Node    = NodeData(id=ids[channel[8]], branchid=channel[8], type=end_point_type, end_point = end_point, banklevel=banklevel)
        All_Nodes   = NodeData(id=ids[channel[8]], branchid=channel[8], type=channel_type, the_geom = geometry)
           
           
        nodes.append(Start_Node.start_point)
        nodes.append(End_Node.end_point)
        channelsarray.append([Channel.branchid,Channel.type,Channel.start_point,Channel.end_point,Channel.nr_calc_points,
                        Channel.length])
        nodes_data.append([Start_Node.start_point,Start_Node.type, Start_Node.banklevel])
        nodes_data.append([End_Node.end_point,End_Node.type, Start_Node.banklevel])
    
    unique_nodes     = np.unique(nodes,return_index=True)[0]
    unique_nodes_ind = np.unique(nodes,return_index=True)[1]

    i=0
    nodes_def = []
    for node, ind in zip(unique_nodes,unique_nodes_ind):
        i+=1
        if nodes_data[ind][2]:
            ofile.write("%s %s %s %s %s\n" %(str(i), str(nodes_data[ind][1]), str(node.split()[0]),str(node.split()[1]), str(nodes_data[ind][2])))
        else:
            ofile.write("%s %s %s %s\n" %(str(i), str(nodes_data[ind][1]), str(node.split()[0]),str(node.split()[1])))
        nodes_def.append(nodes_data[ind][0])
    
    j=0    
    ofile.write("-1\n")
    for channelsarr in channelsarray:
        j+=1
        startnodeID = nodes_def.index(channelsarr[2])
        endnodeID   = nodes_def.index(channelsarr[3])
        channelsarr.append(startnodeID + 1)
        channelsarr.append(endnodeID + 1)
        ofile.write("%s %s %s %s %s %s\n" %(str(j),str(channelsarr[1]),str(channelsarr[-2]),str(channelsarr[-1]),
                                      str(channelsarr[4]),str(channelsarr[5])))

    ofile.close()  
    oplifile.close()
else:
    print "No channels are made"

"""
###############################################################################
NOW GRID REFINEMENT
###############################################################################
"""
if make_gridrefinement == 1:
    layer_gr = dataSource.GetLayer(12)
    i=0
    oplifile_gr = open(plifile_gr,'w') 
    for feature_gr in layer_gr:
        geom_gr     = feature_gr.GetGeometryRef()
        source_gr   = osr.SpatialReference()
        source_gr.ImportFromEPSG(4326)
        
        target_gr   = osr.SpatialReference()
        target_gr.ImportFromEPSG(sp_reference_int)
        
        transform   = osr.CoordinateTransformation(source_gr, target_gr)
        geom_gr.Transform(transform)
#        geometry    = geom.ExportToWkt()[12:-1]
#        geometry    = re.split(',',geometry)
        i=+1
#        geom_gr     = feature_gr.GetGeometryRef()
        geometry_gr = geom_gr.ExportToWkt()[12:-2]
        geometry_gr = re.split(',',geometry_gr)
        oplifile_gr.write(str(feature_gr['display_name']) + '\n')
        oplifile_gr.write(str(np.shape(geometry_gr)[0]) + ' 3' + '\n')
        for j in np.arange(0,np.shape(geometry_gr)[0]):
            ### FOR NOW, ADD SMALL RANDOM VALUE TO X, BECAUSE OF KNOWN BUG (CRASH WHEN TWO SUCCEEDING X-VALUES ARE EQUAL) ###
#            oplifile_gr.write(str('%.10f' %(float(geometry_gr[j].split(' ')[0]))) + " " + str('%.10f' %(float(geometry_gr[j].split(' ')[1]))) + " " +str(feature_gr['refinement_level']) + "\n")
            oplifile_gr.write(str('%.10f' %(float(geometry_gr[j].split(' ')[0])+random.random()*0.0001)) + " " + str('%.10f' %(float(geometry_gr[j].split(' ')[1]))) + " " +str(feature_gr['refinement_level']) + "\n")
        oplifile_gr.write('\n')    
    oplifile_gr.close()
else:
    print "No gridrefinement is made"
    

"""
###############################################################################
LEVEES
###############################################################################
"""

point_x = []; point_y = []
segment=0; nodeid=0;

firstpart  = []
secondpart = []

if make_levees == 1:
    layer_le = dataSource.GetLayer(7)
    i=0
    oplifile_le = open(plifile_le,'w') 
    for feature_le in layer_le:
        geom_le          = feature_le.GetGeometryRef()
        geom_le.Transform(transform)
#        geometry_le      = geom_le.ExportToWkt()[12:-2]
#        geometry_le      = re.split(',',geometry_le)
        pointCoordinates = geom_le.GetPoints()
        for point in pointCoordinates:
            i+=1
            ID=i
            point_x = point[0]
            point_y = point[1]
            
            ### Add all nodes to the firstpart list to write later, after all features are read ###            
            firstpart.append("%.0f %.5f %.5f\n" %(ID, point_x, point_y)) 
        
        for segement in range(0,len(pointCoordinates)-1):
            segment+=1
            nodeid+=1
            
            ### Add all nodes to the secondpart list to write later, after all features are read ###
            secondpart.append("%.0f %.0f %.0f %.3f\n" %(segment, nodeid, nodeid+1, feature_le['crest_level'])) 
     
        ### Skip one extra nodeID, to sperate two features that might not be connected ###
        nodeid+=1   
    
    ### Here the actual writing of the file starts ###
    for line in firstpart:
        oplifile_le.write(line)
    oplifile_le.write("-1\n") 
    for line in secondpart:
        oplifile_le.write(line)
    oplifile_le.write("-1\n")    
    oplifile_le.close()
else:
    print "No levees is made"

"""
###############################################################################
CROSS SECTIONS
###############################################################################
"""
if make_crosssections_inp == 1:
    crosssections     = np.array(cursor.execute("SELECT * FROM CROSS_SECTION").fetchall())
    ids_crosssections = create_crosssection_inp_id_map(crosssections)
    
    layer_crosssections = dataSource.GetLayer(8)

    ofile_crosssections = open(crossection_inp_file,'w')
    crosssections_data = []; channel_id = 0
    for feature_ch, channel in zip(layer,channels):
        i=1
        for feature_cs,crosssection, id in zip(layer_crosssections,crosssections, ids_crosssections):
            if int(feature_ch.code) == feature_cs.channel_id:      
                geom_cs     = feature_cs.GetGeometryRef()
                geom_ch     = feature_ch.GetGeometryRef()
                source      = osr.SpatialReference()
                source.ImportFromEPSG(4326)
                
                target      = osr.SpatialReference()
                target.ImportFromEPSG(sp_reference_int)
                
                transform   = osr.CoordinateTransformation(source, target)
                geom_ch.Transform(transform)
                geom_cs.Transform(transform)
                geometry_ch    = geom_ch.ExportToWkt()[12:-2]
                geometry_ch    = re.split(',',geometry_ch)
                geometry_cs    = geom_cs.ExportToWkt()[7:-1]
                geometry_cs    = re.split(' ',geometry_cs)
                
                points=[]; points_for_plotting=[]
                for j in np.arange(0,np.shape(geometry_ch)[0]):
                        coords_x = (float(geometry_ch[j].split(' ')[0]))
                        coords_y = (float(geometry_ch[j].split(' ')[1]))
                        points.append(((coords_x,coords_y)))
                
                line     = LineString(points)
                point    = Point(float(geometry_cs[0]), float(geometry_cs[1]))
                chainage = line.project(point)
                #### FIGURE TO CHECK ###
                if plotting is True:
                    plt.figure()
                    x , y = line.xy
                    plt.plot(x,y)
                    x1, y1 = point.xy
                    plt.plot(x1, y1, 'ro')

                channel_id = crosssection[1]
                ID = str(channel_id) + '_' + str(i)
                i+=1
                channel_id = crosssection[1] 
            
                definition_id  = crosssection[2] 
                bottom_level   = crosssection[3]
                friction_type  = crosssection[4] 
                friction_value = crosssection[5] 
                
                channel_data = channelsarray[channel_id-1]
                crosssections_ = CrossectionData(id=ID, channel_id=channel_id, the_geom=geometry, definition_id=definition_id, 
                                                    bottom_level=bottom_level, friction_type=friction_type, chainage=chainage, 
                                                    friction_value=friction_value)
                crosssections_data.append(crosssections_)
    
    j=0 
    for crosssection in crosssections_data:
        j+=1
        ofile_crosssections.write("[CrossSection] \n")
        ofile_crosssections.write("id = %s \n" %(crosssection.id))
        ofile_crosssections.write("definition = %s \n" %(crosssection.definition_id))
        ofile_crosssections.write("branchid = %s \n" %(crosssection.channel_id))
        ofile_crosssections.write("chainage = %s \n" %(crosssection.chainage))
        ofile_crosssections.write("bottomlevel = %s \n" %(crosssection.bottom_level))
        ofile_crosssections.write("frictiontype = %s \n" %(crosssection.friction_type))
        ofile_crosssections.write("frictionvalue = %s \n" %(crosssection.friction_value))
        ofile_crosssections.write("\n")
                
    ofile_crosssections.close()
else:
    print "No cross-sections are made"
"""
###############################################################################
CROSS SECTION DEFINITION
###############################################################################
"""
### First map the information needed to write the correct data in the file ####
shapeIdMap       = {1: "rectangle", 2: "circle", 3: "egg", 4: "yz", 5: "tabulated"}
frictionTypeMap  = { crosssection.definition_id : crosssection.friction_type for crosssection in crosssections_data }
frictionValueMap = { crosssection.definition_id : crosssection.friction_value for crosssection in crosssections_data }

ofile_crosssections_def = open(crossection_def_file,'w')
if make_crosssections_def == 1:
    crosssection_defs = np.array(cursor.execute("SELECT * FROM cross_section_definition").fetchall())
    for crosssection_def in crosssection_defs:
        crosssection_def_id        = crosssection_def[0]
        if crosssection_def_id in frictionTypeMap.keys():
            crosssection_def_shape     = crosssection_def[1]
    
#            crosssection_def_levels    = crosssection_def[4]
            crosssection_def_y         = crosssection_def[5]
            crosssection_def_z         = crosssection_def[6]
            crosssection_def_closed    = crosssection_def[7]
            if plotting==True:
                plt.plot(np.array(crosssection_def_y.split(',')),np.array(crosssection_def_z.split(',')))
                plt.savefig(path_to_files + '\\figs\\%s.png' %crosssection_def_id, dpi=100)
                plt.close('all')
            
            try:
                crosssection_def_fricType  = frictionTypeMap[crosssection_def_id]
                crosssection_def_fricValue = frictionValueMap[crosssection_def_id]    
            except:
                print "Use dummy values"
                crosssection_def_fricType  = 1
                crosssection_def_fricValue = 40               
    
            ofile_crosssections_def.write("[Definition]\n")
            ofile_crosssections_def.write("id = %s \n" %(crosssection_def_id))
            ofile_crosssections_def.write("type = %s \n" %(shapeIdMap[crosssection_def_shape]))
            if crosssection_def_shape == 1:
                crosssection_def_width     = float(crosssection_def[2])
                crosssection_def_height    = float(crosssection_def[8])
                ofile_crosssections_def.write("width = %s \n" %(crosssection_def_width))
                ofile_crosssections_def.write("height = %s \n" %(crosssection_def_height))
            elif crosssection_def_shape == 2:
                print "WRITE CIRCLE DETAILS NOT YET SUPPORTED"
                crosssection_def_diameter  = crosssection_def[3]
            elif crosssection_def_shape == 3: 
                print "WRITE EGG DETAILS NOT YET SUPPORTED"
            elif crosssection_def_shape == 4:
                ofile_crosssections_def.write("numlevels = %s \n" %(len(crosssection_def_y.split('%s' %(sep)))))
#                ofile_crosssections_def.write("y = %s \n" %(crosssection_def_y.replace(',',' ')))
#                ofile_crosssections_def.write("z = %s \n" %(crosssection_def_z.replace(',',' ')))
                ofile_crosssections_def.write("y = ")
                for i in range(0,len(crosssection_def_y.split('%s' %(sep)))):
                    ofile_crosssections_def.write("%.0f " %(float(crosssection_def_y.split('%s' %(sep))[i])))
                ofile_crosssections_def.write("\n")
                ofile_crosssections_def.write("z = ")
                for i in range(0,len(crosssection_def_z.split('%s' %(sep)))):
                    ofile_crosssections_def.write("%.2f " %(float(crosssection_def_z.split('%s' %(sep))[i])))
                ofile_crosssections_def.write("\n")
                
            ofile_crosssections_def.write("frictiontype = %s \n" %(crosssection_def_fricType))
            ofile_crosssections_def.write("frictionvalue = %s \n" %(crosssection_def_fricValue))
                
            ofile_crosssections_def.write("\n")
        else:
            print "Crosssection is not used in the model"

ofile_crosssections_def.close()