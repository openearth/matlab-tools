# coding: utf-8
import __main__
import os, sys, math, logging
from netCDF4 import Dataset
from collections import OrderedDict
from datetime import *


class UgridWriter:
    """Writer for FM files"""
    strLengthIds = 40
    strLengthLongNames = 80

    def __init__(self):
        return

    def write(self, output_dir, networkdata, griddata, runid, converter_version):  # write ugrid file
        logger = logging.getLogger('UgridWriter')
        logger.info('Writing Ugrid file')
        ncfile = self.create_netcdf(output_dir, runid, converter_version)

        self.init_1dnetwork(ncfile,networkdata)
        #self.init_2dmesh(ncfile, griddata)

        self.set_1dnetwork(ncfile,networkdata)
        self.set_1dmesh(ncfile,networkdata)

        #self.set_2dmesh(ncfile, griddata)

        ncfile.close()

        return True

    def create_netcdf(self, output_dir, name, converter_version):

        output_file = os.path.join(output_dir, name + "_net.nc")
        # File format:
        outformat = "NETCDF3_CLASSIC" #"NETCDF4"
        # File where we going to write
        ncfile = Dataset(output_file, 'w', format=outformat)

        # global attributes
        mainscript = os.path.basename(__main__.__file__)
        ncfile.Conventions = "CF-1.8 UGRID-1.0 Deltares-0.10"
        ncfile.history = "Created on {0} by {1}".format(datetime.now(), mainscript)
        ncfile.institution = "Deltares"
        ncfile.references = "http://www.deltares.nl"
        ncfile.source = "Python script converting a Sobek3 model into a D-Flow FM model, version " + str(converter_version).strip()

        # EPSG
        epsgcode = 0
        projected_coordinate_system = ncfile.createVariable("projected_coordinate_system", "i4", ())
        if epsgcode==28992:
            projected_coordinate_system.projection_name = 'Amersfoort / RD New'
            projected_coordinate_system.long_name = 'Grid mapping Amersfoort / RD New'
            projected_coordinate_system.epsg = epsgcode
            projected_coordinate_system.grid_mapping_name = 'oblique_stereographic'
            projected_coordinate_system.latitude_of_projection_origin = float(52.15616)
            projected_coordinate_system.longitude_of_prime_meridian = float(5.387639)
            projected_coordinate_system.semi_major_axis = float(6377397.155)
            projected_coordinate_system.semi_minor_axis = float(6356752.314245)
            projected_coordinate_system.inverse_flattening = float(299.1528128)
            projected_coordinate_system.scale_factor_at_projection_origin = float(0.9999079)
            projected_coordinate_system.false_easting = float(155000)
            projected_coordinate_system.false_northing = float(463000)
            projected_coordinate_system.EPSG_code = 'EPSG:' + str(epsgcode)
            projected_coordinate_system.proj4_params = '+proj=sterea +lat_0=52.15616055555555 +lon_0=5.38763888888889 +k=0.999908 +x_0=155000 +y_0=463000 +ellps=bessel +units=m +towgs84=565.4174,50.3319,465.5542,-0.398957388243134,0.343987817378283,-1.87740163998045,4.0725 +no_defs'
            projected_coordinate_system.value = 'value is equal to EPSG code'
            projected_coordinate_system[:] = epsgcode
        else:
            projected_coordinate_system.projection_name = 'Unknown projected'
            projected_coordinate_system.long_name = 'Unknown projected'
            projected_coordinate_system.epsg = epsgcode
            projected_coordinate_system.grid_mapping_name = 'Unknown projected'
            projected_coordinate_system.latitude_of_projection_origin = float(0.0)
            projected_coordinate_system.longitude_of_prime_meridian = float(0.0)
            projected_coordinate_system.semi_major_axis = float(6378137.0)
            projected_coordinate_system.semi_minor_axis = float(6356752.314245)
            projected_coordinate_system.inverse_flattening = float(298.257223563)
            projected_coordinate_system.scale_factor_at_projection_origin = float(0.0)
            projected_coordinate_system.false_easting = float(0.0)
            projected_coordinate_system.false_northing = float(0.0)
            projected_coordinate_system.EPSG_code = 'EPSG:' + str(epsgcode)
            projected_coordinate_system.proj4_params = ''
            projected_coordinate_system.value = 'value is equal to EPSG code'
            projected_coordinate_system[:] = epsgcode

        return ncfile

    def init_1dnetwork(self, ncfile, data):

        # dimensions of the network

        ncfile.createDimension("network1d_nNodes", len(data["node_ids"]))
        ncfile.createDimension("network1d_nGeometryNodes", len(data["geom_x"]))
        ncfile.createDimension("network1d_nEdges", len(data["edge_node"]))
        ncfile.createDimension("strLengthIds", self.strLengthIds)
        ncfile.createDimension("strLengthLongNames", self.strLengthLongNames)
        ncfile.createDimension("mesh1d_nEdges", len(data["edge_point"]))
        ncfile.createDimension("mesh1d_nNodes", len(data["point_branch_id"]))
        ncfile.createDimension("Two", 2)

    def init_2dmesh(self, ncfile, data_2dmesh):

        # dimensions 2d mesh
        edges_2d = len(data_2dmesh["edge_x"])
        faces_2d = len(data_2dmesh["face_node"])
        nodes_2d = len(data_2dmesh["node_x"])

        ncfile.createDimension("mesh2d_nMax_face_nodes", 4)
        ncfile.createDimension("mesh2d_nEdges", edges_2d)
        ncfile.createDimension("mesh2d_nFaces", faces_2d)
        ncfile.createDimension("mesh2d_nNodes", nodes_2d)

    def set_1dnetwork(self, ncfile, data):

        # geometry
        ntw = ncfile.createVariable("network1d", "i4", ())
        ntw.cf_role = 'mesh_topology'
        ntw.edge_dimension = 'network1d_nEdges'
        ntw.edge_geometry = 'network1d_geometry'
        ntw.edge_node_connectivity = 'network1d_edge_nodes'
        ntw.long_name = "Topology data of 1D network"
        ntw.node_coordinates = 'network1d_node_x network1d_node_y'
        ntw.node_dimension = 'network1d_nNodes'
        ntw.topology_dimension = 1
        ntw.node_id = "network1d_node_id"
        ntw.node_long_name = "network1d_node_long_name"
        ntw.branch_id = "network1d_branch_id"
        ntw.branch_long_name = "network1d_branch_long_name"
        ntw.edge_length = "network1d_edge_length"
        ntw.branch_order = "network1d_branch_order"

        ntw_node_id = ncfile.createVariable("network1d_node_id", "c", (ntw.node_dimension, "strLengthIds"))
        ntw_node_id.long_name = "ID of network nodes"
        ntw_node_id[:] = data["node_ids"]

        ntw_node_longname = ncfile.createVariable("network1d_node_long_name", "c", (ntw.node_dimension, "strLengthLongNames"))
        ntw_node_longname.long_name = "Long name of network nodes"
        ntw_node_longname[:] = data["node_longnames"]

        ntw_node_x = ncfile.createVariable("network1d_node_x", "f8", ntw.node_dimension)
        ntw_node_x.standard_name = 'projection_x_coordinate'
        ntw_node_x.long_name = "x-coordinate of network nodes"
        ntw_node_x.units = 'm'
        ntw_node_x[:] = data["node_x"]

        ntw_node_y = ncfile.createVariable("network1d_node_y", "f8", ntw.node_dimension)
        ntw_node_y.standard_name = 'projection_y_coordinate'
        ntw_node_y.long_name = "y-coordinate of network nodes"
        ntw_node_y.units = 'm'
        ntw_node_y[:] = data["node_y"]

        ntw_branch_id_name = ncfile.createVariable("network1d_branch_id", "c", (ntw.edge_dimension, "strLengthIds"))
        ntw_branch_id_name.long_name = "ID of branch geometries"
        ntw_branch_id_name[:] = data["branch_names"]

        ntw_branch_id_longname = ncfile.createVariable("network1d_branch_long_name", "c", (ntw.edge_dimension, "strLengthLongNames"))
        ntw_branch_id_longname.long_name = "Long name of branch geometries"
        ntw_branch_id_longname[:] = data["branch_longnames"]

        ntw_branch_length = ncfile.createVariable("network1d_edge_length", "f8", ntw.edge_dimension)
        ntw_branch_length.long_name = "Real length of branch geometries"
        ntw_branch_length.units = 'm'
        ntw_branch_length[:] = data["branch_length"]

        ntw_branch_order = ncfile.createVariable("network1d_branch_order", "i4", ntw.edge_dimension)
        ntw_branch_order.long_name = "Order of branches for interpolation"
        ntw_branch_order.mesh = "network1d"
        ntw_branch_order.location = "edge"
        ntw_branch_order[:] = data["branch_order"]

        ntw_edge_node = ncfile.createVariable("network1d_edge_nodes", "i4", (ntw.edge_dimension, "Two"))
        ntw_edge_node.cf_role = 'edge_node_connectivity'
        ntw_edge_node.long_name = 'Start and end nodes of network edges'
        ntw_edge_node.start_index = 1
        ntw_edge_node[:] = data["edge_node"]

        ntw_geom = ncfile.createVariable("network1d_geometry", "i4", ())
        ntw_geom.geometry_type = 'line'
        ntw_geom.long_name = "1D Geometry"
        ntw_geom.node_count = 'network1d_geom_node_count'
        ntw_geom.node_coordinates = 'network1d_geom_x network1d_geom_y'

        ntw_geom_node_count = ncfile.createVariable("network1d_geom_node_count", "i4", ntw.edge_dimension)
        ntw_geom_node_count.long_name = "Number of geometry nodes per branch"
        ntw_geom_node_count[:] = data["geom_node_count"]

        ntw_geom_x = ncfile.createVariable("network1d_geom_x", "f8", "network1d_nGeometryNodes")
        ntw_geom_x.standard_name = 'projection_x_coordinate'
        ntw_geom_x.units = 'm'
        ntw_geom_x.long_name = 'x-coordinate of branch geometry nodes'

        ntw_geom_y = ncfile.createVariable("network1d_geom_y", "f8", "network1d_nGeometryNodes")
        ntw_geom_y.standard_name = 'projection_y_coordinate'
        ntw_geom_y.units = 'm'
        ntw_geom_y.long_name = 'y-coordinate of branch geometry nodes'

        ntw_geom_x[:] = data["geom_x"]
        ntw_geom_y[:] = data["geom_y"]

        return True


    def set_1dmesh(self, ncfile, data):

        mesh1d = ncfile.createVariable("mesh1d", "i4", ())
        mesh1d.cf_role = 'mesh_topology'
        mesh1d.coordinate_space = 'network1d'
        mesh1d.edge_dimension = 'mesh1d_nEdges'
        mesh1d.edge_node_connectivity = 'mesh1d_edge_nodes'
        mesh1d.long_name = "Topology data of 1D mesh"
        mesh1d.node_coordinates = 'mesh1d_node_branch mesh1d_node_offset'
        mesh1d.edge_coordinates = 'mesh1d_edge_branch mesh1d_edge_offset'
        mesh1d.node_dimension = 'mesh1d_nNodes'
        mesh1d.node_id = "mesh1d_node_id"
        mesh1d.node_long_name = "mesh1d_node_long_name"
        mesh1d.topology_dimension = 1

        mesh1d_node_id = ncfile.createVariable("mesh1d_node_id", "c", (mesh1d.node_dimension, "strLengthIds"))
        mesh1d_node_id.long_name = "ID of mesh nodes"
        mesh1d_node_id[:] = data["point_ids"]

        mesh1d_node_longname = ncfile.createVariable("mesh1d_node_long_name", "c", (mesh1d.node_dimension, "strLengthLongNames"))
        mesh1d_node_longname.long_name = "Long name of mesh nodes"
        mesh1d_node_longname[:] = data["point_longnames"]

        mesh1d_edge_node = ncfile.createVariable("mesh1d_edge_nodes", "i4", (mesh1d.edge_dimension, "Two"))
        mesh1d_edge_node.cf_role = 'edge_node_connectivity'
        mesh1d_edge_node.long_name = 'Start and end nodes of mesh edges'
        mesh1d_edge_node.start_index = 1
        mesh1d_edge_node[:] = data["edge_point"]

        mesh1d_point_branch = ncfile.createVariable("mesh1d_node_branch", "i4", mesh1d.node_dimension)
        mesh1d_point_branch.long_name = "Index of branch on which mesh nodes are located"
        mesh1d_point_branch.start_index = 1
        mesh1d_point_branch[:] = data["point_branch_id"]

        mesh1d_point_offset = ncfile.createVariable("mesh1d_node_offset", "f8", mesh1d.node_dimension)
        mesh1d_point_offset.long_name = "Offset along branch of mesh nodes"
        mesh1d_point_offset.units = 'm'
        mesh1d_point_offset[:] = data["point_branch_offset"]

        mesh1d_edge_branch = ncfile.createVariable("mesh1d_edge_branch", "i4", mesh1d.edge_dimension)
        mesh1d_edge_branch.long_name = "Index of branch on which mesh edges are located"
        mesh1d_edge_branch.start_index = 1
        mesh1d_edge_branch[:] = data["edge_branch_id"]

        mesh1d_edge_offset = ncfile.createVariable("mesh1d_edge_offset", "f8", mesh1d.edge_dimension)
        mesh1d_edge_offset.long_name = "Offset along branch of mesh edges"
        mesh1d_edge_offset.units = 'm'
        mesh1d_edge_offset[:] = data["edge_branch_offset"]

        # Ugly Code Ahead:
        # The last variable added sometimes contains NaNs. This happened with "mesh1d_point_branch_offset".
        # When changing the order of the variables, it's still the last variable showing the problem.
        # As a workaround, an additional dummy variable is added.
        # I expect this is solved by executing "ncfile.close()"
        #dummyvar = ncfile.createVariable("dummy", "c", "Two")

        return True

    # set 2d mesh data to netcdf file
    def set_2dmesh(self, ncfile, data_2dmesh):

        mesh2d = ncfile.createVariable("mesh2d", "i4", ())
        mesh2d.long_name = "Topology data of 2D network"
        mesh2d.topology_dimension = 2
        mesh2d.cf_role = 'mesh_topology'
        mesh2d.node_coordinates = 'mesh2d_node_x mesh2d_node_y'
        mesh2d.node_dimension = 'mesh2d_nNodes'
        mesh2d.edge_coordinates = 'mesh2d_edge_x mesh2d_edge_y'
        mesh2d.edge_dimension = 'mesh2d_nEdges'
        mesh2d.edge_node_connectivity = 'mesh2d_edge_nodes'
        mesh2d.face_node_connectivity = 'mesh2d_face_nodes'
        mesh2d.max_face_nodes_dimension = 'mesh2d_nMax_face_nodes'
        mesh2d.face_dimension = "mesh2d_nFaces"
        #mesh2d.edge_face_connectivity = "mesh2d_edge_faces"
        mesh2d.face_coordinates = "mesh2d_face_x mesh2d_face_y"

        mesh2d_x = ncfile.createVariable("mesh2d_node_x", "f8", mesh2d.node_dimension)
        mesh2d_y = ncfile.createVariable("mesh2d_node_y", "f8", mesh2d.node_dimension)
        mesh2d_x.standard_name = 'projection_x_coordinate'
        mesh2d_x.units = 'm'
        mesh2d_y.standard_name = 'projection_y_coordinate'
        mesh2d_y.units = 'm'
        mesh2d_x[:] = data_2dmesh["node_x"]
        mesh2d_y[:] = data_2dmesh["node_y"]

        mesh2d_xu = ncfile.createVariable("mesh2d_edge_x", "f8",  mesh2d.edge_dimension)
        mesh2d_yu = ncfile.createVariable("mesh2d_edge_y", "f8",  mesh2d.edge_dimension)
        mesh2d_xu.standard_name = 'projection_x_coordinate'
        mesh2d_xu.units = 'm'
        mesh2d_yu.standard_name = 'projection_y_coordinate'
        mesh2d_yu.units = 'm'
        mesh2d_xu[:] = data_2dmesh["edge_x"]
        mesh2d_yu[:] = data_2dmesh["edge_y"]

        mesh2d_en = ncfile.createVariable("mesh2d_edge_nodes", "i4", ( mesh2d.edge_dimension, "Two"))
        mesh2d_en.cf_role = 'edge_node_connectivity'
        mesh2d_en.long_name = 'Start and end nodes of mesh edges'
        mesh2d_en.start_index = 1
        mesh2d_en[:] = data_2dmesh["edge_node"]

        mesh2d_fn = ncfile.createVariable("mesh2d_face_nodes", "i4", (mesh2d.face_dimension, mesh2d.max_face_nodes_dimension), fill_value=0)
        mesh2d_fn.cf_role = 'face_node_connectivity'
        mesh2d_fn.long_name = 'Vertex nodes of mesh faces'
        mesh2d_fn.start_index = 1
        mesh2d_fn[:] = data_2dmesh["face_node"]

        #mesh2d_edge_faces = ncfile.createVariable("mesh2d_edge_faces", "i4", (mesh2d.edge_dimension, "Two"), fill_value=-1)
        #mesh2d_edge_faces.cf_role = "edge_face_connectivity"
        #mesh2d_edge_faces.long_name = "Neighboring faces of mesh edges"
        #mesh2d_edge_faces.start_index = 1
        #mesh2d_edge_faces[:] = data_2dmesh["edge_faces"]

        mesh2d_face_x = ncfile.createVariable("mesh2d_face_x", "f8", mesh2d.face_dimension)
        mesh2d_face_x.units = "m"
        mesh2d_face_x.standard_name = "projection_x_coordinate"
        mesh2d_face_x.long_name = "Characteristic x-coordinate of mesh faces"
        mesh2d_face_x.mesh = "mesh2d"
        mesh2d_face_x.location = "face"
        #mesh2d_face_x.bounds = "mesh2d_face_x_bnd"
        mesh2d_face_x[:] = data_2dmesh["face_x"]

        mesh2d_face_y = ncfile.createVariable("mesh2d_face_y", "f8", mesh2d.face_dimension)
        mesh2d_face_y.units = "m"
        mesh2d_face_y.standard_name = "projection_y_coordinate"
        mesh2d_face_y.long_name = "Characteristic y-coordinate of mesh faces"
        mesh2d_face_y.mesh = "mesh2d"
        mesh2d_face_y.location = "face"
        #mesh2d_face_y.bounds = "mesh2d_face_y_bnd"
        mesh2d_face_y[:] = data_2dmesh["face_y"]

        #cm = ncfile.createVariable("composite_mesh", "u4", ())
        #cm.cf_role = 'mesh_topology_parent'
        #cm.meshes= 'mesh1D mesh2D'
        #cm.mesh_contact = 'link1d2d'

        #link1d2d = ncfile.createVariable("link1d2d", "u4", ("nlinks_1d2d", "Two"))
        #link1d2d.cf_role = 'mesh_topology_contact'
        #link1d2d.contact= 'mesh1D:node mesh2D:face'
        #link1d2d.start_index = 1
        #link1d2d[:,:] = None


    # generate a street grid based on the manholes and street grid
    def generate_1d2dlinks(self):
        return True

    def str2chars(self,str,size):
        chars = list(str)
        if len(chars) > size:
            chars = chars[:size]
        elif len(chars) < size:
            chars.extend(list(' '* (size - len(chars))))
        return chars


