# coding: utf-8
import os, sys, math, logging, time
from datetime import datetime
from gdal import ogr
from collections import OrderedDict
from reader_sobek3.Sobek3Model import Sobek3Model
from writer_dflowfm.FMModel import FMModel

class Sobek32FMConverter:
    ID_STRLENGTH   = 40
    LONG_STRLENGTH = 80

    def __init__(self):
        return

    def convert_to_fm_model(self, sobek3_model = Sobek3Model(), generate_2d_grid = False):
        logger = logging.getLogger('converter')
        logger.info('Converting')
        fm_model              = FMModel()
        fm_model.runid        = sobek3_model.runid
        fm_model.file_names   = sobek3_model.file_names
        fm_model.networkdata  = self.generate_networkdata(sobek3_model)
        fm_model.boundarydata = self.generate_boundarydata(sobek3_model)
        fm_model.keyvalue     = self.generate_keyvalue(sobek3_model)
        if generate_2d_grid:
            fm_model.griddata      = self.generate_2dmesh_data(fm_model.networkdata["geom_x"], fm_model.networkdata["geom_y"])
            fm_model.crosssections = self.generate_crossections(fm_model.profiles, fm_model.network)
        return fm_model

    # generate network and 1d mesh
    def generate_networkdata(self, sobek3_model):
        logger = logging.getLogger('converter')
        networkdata = {}
        networkdata["node_ids"] = []
        networkdata["node_names"] = []
        networkdata["node_longnames"] = []
        networkdata["node_x"] = []
        networkdata["node_y"] = []
        networkdata["node_indexes"] = []
        networkdata["geom_x"] = []
        networkdata["geom_y"] = []
        networkdata["geom_node_count"] = []
        networkdata["edge_node"] = []
        networkdata["point_ids"] = []
        networkdata["point_longnames"] = []
        networkdata["point_branch_id"] = []
        networkdata["point_branch_offset"] = []
        networkdata["point_xs"] = []
        networkdata["point_ys"] = []
        networkdata["edge_point"] = []
        networkdata["branch_ids"] = []
        networkdata["branch_names"] = []
        networkdata["branch_longnames"] = []
        networkdata["branch_length"] = []
        networkdata["branch_order"] = []
        networkdata["branch_ngeometrypoints"] = []
        networkdata["branch_indexes"] = []
        networkdata["edge_branch_id"] = []
        networkdata["edge_branch_offset"] = []

        # Temporary dictionary to store the id number of the nodes and branches
        node_indexes    = OrderedDict()
        fromToNodes     = OrderedDict()

        #parse nodes
        for i in range(1, sobek3_model.nnodes + 1):
            section   = "Node" + str(i)
            networkdata["node_ids"].append(self.str2chars(sobek3_model.network_config[section]["id"], self.ID_STRLENGTH))
            node_indexes[sobek3_model.network_config[section]["id"]] = i
            if "name" in sobek3_model.network_config[section]:
                name = sobek3_model.network_config[section]["name"]
                networkdata["node_longnames"].append(self.str2chars(name, self.LONG_STRLENGTH))
            else:
                name = sobek3_model.network_config[section]["id"]
                networkdata["node_longnames"].append(self.str2chars("longname_" + name, self.LONG_STRLENGTH))
            networkdata["node_names"].append(self.str2chars(name, self.ID_STRLENGTH))
            networkdata["node_x"].append(sobek3_model.network_config[section]["x"])
            networkdata["node_y"].append(sobek3_model.network_config[section]["y"])
            networkdata["node_indexes"].append(i)

        #parse branches
        for i in range(1, sobek3_model.nbranches + 1):
            section   = "Branch" + str(i)
            branch_id = sobek3_model.network_config[section]["id"]
            n_points   = int(sobek3_model.network_config[section]["gridPointsCount"])
            node_offset_previous = 0

            # points = value[0]
            branch_name = section

            if int(n_points) < 2:
                continue
            
            gp_offsets = list(sobek3_model.network_config[section]["gridPointOffsets"].split(' '))
            gp_ids     = list(sobek3_model.network_config[section]["gridPointIds"].split(';'))
            length     = float(gp_offsets[-1]) - float(gp_offsets[0])
            geometry   = sobek3_model.network_config[section]["geometry"]
            if geometry.find('LINESTRING') == -1:
                assert True, "Keyword 'LINESTRING' not found in geometry"
            else:
                start_index = geometry.find('(')
                end_index   = geometry.find(')')
                geometry = geometry[geometry.find('(') + 1 : geometry.find(')')]
                gp_xy = list(geometry.split(','))
                networkdata["geom_node_count"].append(len(gp_xy))
                for xy in gp_xy:
                    x_and_y = list(xy.strip().split(' '))
                    if len(x_and_y) != 2:
                        assert True, "Expecting an X and Y value in geometry_LINESTRING"
                    networkdata["geom_x"].append(float(x_and_y[0]))
                    networkdata["geom_y"].append(float(x_and_y[1]))

            if gp_ids[0] not in networkdata["node_ids"]:
                assert True, "Start point of branch not in node list"
            if gp_ids[-1] not in networkdata["node_ids"]:
                assert True, "End point of branch not in node list"

            #save branches
            networkdata["branch_ids"].append(branch_id)
            networkdata["branch_names"].append(self.str2chars(branch_id,self.ID_STRLENGTH))
            networkdata["branch_longnames"].append(self.str2chars("long_"+ branch_id,self.LONG_STRLENGTH))
            networkdata["branch_order"].append(sobek3_model.network_config[section]["order"])
            networkdata["branch_ngeometrypoints"].append(n_points)
            networkdata["branch_length"].append(length)
            networkdata["edge_node"].append([node_indexes[sobek3_model.network_config[section]["fromNode"]], node_indexes[sobek3_model.network_config[section]["toNode"]]])
            networkdata["branch_indexes"].append(i)

            idindex_previous = 0 # index to point before the current mesh edge
            idindex          = 0 # index to point after  the current mesh edge
            fromNode         = sobek3_model.network_config[section]["fromNode"]
            toNode           = sobek3_model.network_config[section]["toNode"]
            for j in range(0, n_points):
                # update idindex_previous, reset idindex
                idindex_previous = idindex
                idindex          = 0
                # idchar (character representation of point_id) is used to check whether this point already exists
                idchar = self.str2chars(gp_ids[j], self.ID_STRLENGTH)

                if idchar in networkdata["point_ids"]:
                    # This point already exists:
                    # Create a new, unique id and write a warning
                    iadd = 0
                    while idchar in networkdata["point_ids"]:
                        iadd += 1
                        newname = gp_ids[j] +'(' + str(iadd) + ')'
                        idchar  = self.str2chars(newname, self.ID_STRLENGTH)
                    logger.warning('Grid point id "' + gp_ids[j] + '" is not unique. Renaming duplicate occurrence to "' + newname + '".')
                    gp_ids[j] = newname
                    # Leave idindex zero (new point)

                # j=0: if fromNode already exists, refer to it, else add it to the fromToNodes-list
                if j==0:
                    if fromNode in fromToNodes:
                        idindex = networkdata["point_ids"].index(fromToNodes[fromNode]) + 1
                    else:
                        fromToNodes[fromNode] = idchar

                # j=j_max: if toNode already exists, refer to it, else add it to the fromToNodes-list
                if j==n_points-1:
                    if toNode in fromToNodes:
                        idindex = networkdata["point_ids"].index(fromToNodes[toNode]) + 1
                    else:
                        fromToNodes[toNode] = idchar

                if idindex == 0:
                    # This point is new
                    networkdata["point_ids"].append(idchar)
                    idindex = networkdata["point_ids"].index(idchar) + 1
                    networkdata["point_longnames"].append(self.str2chars("long_" + gp_ids[j], self.LONG_STRLENGTH))
                    networkdata["point_branch_id"].append(i)
                    networkdata["point_branch_offset"].append(gp_offsets[j])
                if j > 0:
                    networkdata["edge_point"].append([idindex_previous, idindex])
                    networkdata["edge_branch_id"].append(i)
                    networkdata["edge_branch_offset"].append((node_offset_previous + float(gp_offsets[j]))/2.0)
                    node_offset_previous = float(gp_offsets[j])

        return networkdata




    # generate boundary data
    def generate_boundarydata(self, sobek3_model):
        boundarydata = {}
        boundarydata["node_ids"] = []
        boundarydata["types"]    = []

        bnd_type_converter = {
            1: "waterlevelbnd",
            2: "dischargebnd"
            }
        #parse boundaries
        for i in range(1, sobek3_model.nbounds + 1):
            section   = "Boundary" + str(i)
            boundarydata["node_ids"].append(sobek3_model.bndloc_config[section]["nodeId"])
            type =int(sobek3_model.bndloc_config[section]["type"])
            boundarydata["types"].append(bnd_type_converter.get(type))
        return boundarydata




    # generate keyvalue pairs
    def generate_keyvalue(self, sobek3_model):
        keyvalue = {}

        startTime       = sobek3_model.md1d_config["Time1"]["StartTime"] # 2017-08-29 00:00:00 # yyyy-MM-dd HH:mm:ss
        starttime_      = time.strptime(startTime, '%Y-%m-%d %H:%M:%S')
        start_date_time = datetime(*starttime_[0:6])
        stopTime        = sobek3_model.md1d_config["Time1"]["StopTime"] # 2017-08-29 00:00:00 # yyyy-MM-dd HH:mm:ss
        stoptime_       = time.strptime(stopTime, '%Y-%m-%d %H:%M:%S')
        stop_date_time  = datetime(*stoptime_[0:6])

        # Refdate
        keyvalue["RefDate"] = startTime[0:4] + startTime[5:7] + startTime[8:10]

        # DtUser
        # D-Flow FM defines the timestep itself. Set DtUser as big as possible
        # "TimeStep" from SOBEK3 is too small
        if "HISOutputTimeStep" in sobek3_model.md1d_config["Time1"]:
            keyvalue["DtUser"] = sobek3_model.md1d_config["Time1"]["HISOutputTimeStep"]
        else:
            # Assume that the depriciated keyword OutTimeStepStructures is used
            keyvalue["DtUser"] = sobek3_model.md1d_config["Time1"]["OutTimeStepStructures"]

        # TStop
        keyvalue["TStop"] = str((stop_date_time - start_date_time).total_seconds())

        # HisInterval
        if "HISOutputTimeStep" in sobek3_model.md1d_config["Time1"]:
            keyvalue["HisInterval"] = sobek3_model.md1d_config["Time1"]["HISOutputTimeStep"]
        else:
            # Assume that the depriciated keyword OutTimeStepStructures is used
            keyvalue["HisInterval"] = sobek3_model.md1d_config["Time1"]["OutTimeStepStructures"]

        # MapInterval
        if "MapOutputTimeStep" in sobek3_model.md1d_config["Time1"]:
            keyvalue["MapInterval"] = sobek3_model.md1d_config["Time1"]["MapOutputTimeStep"]
        else:
            # Assume that the depriciated keyword OutTimeStepGridPoints is used
            keyvalue["MapInterval"] = sobek3_model.md1d_config["Time1"]["OutTimeStepGridPoints"]

        # GlobalValues
        if "UseInitialWaterDepth" in sobek3_model.md1d_config["GlobalValues1"]:
            keyvalue["UseInitialWaterDepth"] = sobek3_model.md1d_config["GlobalValues1"]["UseInitialWaterDepth"]
        else:
            keyvalue["UseInitialWaterDepth"] = 0
        if "InitialWaterLevel" in sobek3_model.md1d_config["GlobalValues1"]:
            keyvalue["InitialWaterLevel"] = sobek3_model.md1d_config["GlobalValues1"]["InitialWaterLevel"]
        if "InitialWaterDepth" in sobek3_model.md1d_config["GlobalValues1"]:
            keyvalue["InitialWaterDepth"] = sobek3_model.md1d_config["GlobalValues1"]["InitialWaterDepth"]
        if "InitialDischarge" in sobek3_model.md1d_config["GlobalValues1"]:
            keyvalue["InitialDischarge"] = sobek3_model.md1d_config["GlobalValues1"]["InitialDischarge"]

        return keyvalue



    def generate_2dmesh_data(self, geom_x, geom_y):

        #just generate a west and east cell of the area for running the model
        min_x    = min(geom_x)
        max_x    = max(geom_x)
        delta_x  = (max_x - min_x) * 0.5
        middle_x = min_x + delta_x
        min_y    = min(geom_y)
        max_y    = max(geom_y)
        delta_y  = max_y - min_y

        # generate extend as one cell
        grid = {}

        grid["node_x"] = []
        grid["node_y"] = []
        grid["edge_node"] = []
        grid["edge_x"] = []
        grid["edge_y"] = []
        grid["face_node"] = []
        grid["face_x"] = []
        grid["face_y"] = []
        grid["edge_faces"] = []

        grid["node_x"].extend([min_x, min_x, middle_x, middle_x, max_x, max_x])
        grid["node_y"].extend([min_y, max_y, min_y, min_y, min_y, max_y])
        grid["edge_node"].extend([[1, 2],[2, 4],[4, 3],[3, 1],[3,5],[5,6],[6,4]])
        grid["edge_x"].extend([min_x, min_x + (0.5 * delta_x), max_x, min_x + (0.5 * delta_x),min_x + (1.5 * delta_x),max_x,min_x + (1.5 * delta_x)])
        grid["edge_y"].extend([min_y + (0.5 * delta_y), max_y, min_y + (0.5 * delta_y), min_y,min_y, min_y + (0.5 * delta_y), max_y])
        grid["face_node"].append([3, 5, 6, 7])
        grid["face_x"].append(min_x + (0.5 * delta_x))
        grid["face_x"].append(min_x + (1.5 * delta_x))
        grid["face_y"].append(min_y + (0.5 * delta_y))
        grid["face_y"].append(min_y + (0.5 * delta_y))

        return grid

    def generate_crossections(self, profiles, branches):
        crosssections = []
        line = ogr.Geometry(ogr.wkbLineString)
        z_values = []
        name = None
        i_cs = 0

        for keyvalue in profiles.items():
            value = keyvalue[1]
            if name is None:
                name = value[8]

            if name != value[8]:

                #get cs
                if line.GetPointCount() <= 1:
                    print(str(name) + " has not enough points to construct a cross-section")
                else:
                    cs = self.get_yz_cs(name,line,z_values, branches)
                    if cs is not None:
                        crosssections.append(cs)
                        i_cs += 1

                        #if i_cs > 100: return crosssections


                #new cs
                line = ogr.Geometry(ogr.wkbLineString)
                z_values = []
                name = value[8]


            point = value[0][0]
            x, y, z = point
            line.AddPoint(x,y)
            z_values.append(z)

        if name is not None:
            if line.GetPointCount() <= 1:
                print(str(name) + " has not enough points to construct a cross-section")
            else:
                cs = self.get_yz_cs(name, line, z_values, branches)
                if cs is not None:
                    crosssections.append(cs)

        return crosssections

    def get_yz_cs(self, name, cs_line, z_values, branches):

        for keyvalue in branches.items():
            branch_id = keyvalue[0]
            points    = keyvalue[1][0]
            branch    = ogr.Geometry(ogr.wkbLineString)
            for xy in points:
                branch.AddPoint(xy[0], xy[1])

            if branch.GetPointCount() <= 1:
                continue

            if branch.Intersects(cs_line):
                point     = branch.Intersection(cs_line)
                offset    = self.get_offset(branch, point)
                yz_values = self.get_yz_values(cs_line, z_values)
                return [name, branch_id, offset, yz_values]

        print('No intersection of crossection = ' + str(name))
        return None

    def get_point_id(self, point):
        x,y = point
        return str("%.0f" % float(x)) + "_" + str("%.0f" % float(y))

    def str2chars(self,str,size):
        chars = list(str)
        if len(chars) > size:
            chars = chars[:size]
        elif len(chars) < size:
            chars.extend(list(' '* (size - len(chars))))
        return chars

    def get_offset(self, line, geom):
        offset = 0.0

        for i in range(1, line.GetPointCount()):
            p_from = ogr.Geometry(ogr.wkbPoint)
            p      = line.GetPoint(i-1)
            p_from.AddPoint(p[0],p[1])
            p_to = ogr.Geometry(ogr.wkbPoint)
            p    = line.GetPoint(i)
            p_to.AddPoint(p[0],p[1])
            distance = p_from.Distance(p_to)
            segment  = ogr.Geometry(ogr.wkbLineString)
            segment.AddPoint(p_from.GetX(),p_from.GetY())
            segment.AddPoint(p_to.GetX(),p_to.GetY())

            if(segment.Distance(geom) < 0.001):
                offset += p_from.Distance(geom)
                return offset

            offset += distance

        return -1.0

    def get_yz_values(self, line,z_values):
        points = []
        y = 0.0
        points.append([y,z_values[0]])
        for i in range(1, line.GetPointCount()):
            p_from = ogr.Geometry(ogr.wkbPoint)
            p      = line.GetPoint(i-1)
            p_from.AddPoint(p[0],p[1])
            p_to = ogr.Geometry(ogr.wkbPoint)
            p    = line.GetPoint(i)
            p_to.AddPoint(p[0],p[1])
            distance = p_from.Distance(p_to)
            y       += distance
            points.append([y, z_values[i]])
        return points
