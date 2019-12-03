'''
NAME
    NetCDF Python tools for Deltares Delft3d-FM files
PURPOSE
    To to read and process Deltares Delft3d-FM netCDF files: his.nc and map.nc
    Plotting using Matplotlib and Basemap.
    Using pyugrid to read grids from the map.nc files.
PROGRAMMER(S)
    Bogdan Hlevca
REVISION HISTORY
    20160913 -- Initial version created

REFERENCES
    netcdf4-python -- http://code.google.com/p/netcdf4-python/
    pyugrid        -- https://github.com/pyugrid/pyugrid/tree/master/pyugrid
'''
import read_nc_cdf
import pyugrid.read_netcdf as read_netcdf  #part of the pyugrid package
import numpy as np
import matplotlib.pyplot as plt
import matplotlib.dates as dates
import datetime as dt  # Python standard library datetime  module
import netCDF4
import pyugrid #Python library that can read unstructured grid netcdf based on UGRID specification



class D3dfmUGrid(pyugrid.UGrid):
    """
    A derived class from pyugrid to hold an unstructured grid (triangular mesh).

    The internal structure mirrors the netcdf data standard.

    It was developed to override the methods that expect latitude and logitude as coordinates while dflowfm does not
    make the conversion and uses UTM coordinates.
    """


    def __init__(self,
                 nodes=None,
                 node_lon=None,
                 node_lat=None,
                 faces=None,
                 edges=None,
                 boundaries=None,
                 face_face_connectivity=None,
                 face_edge_connectivity=None,
                 edge_coordinates=None,
                 face_coordinates=None,
                 boundary_coordinates=None,
                 data=None,
                 mesh_name="mesh",
                 ):
        """
        ugrid class -- holds, saves, etc. an unstructured grid

        :param nodes=None : the coordinates of the nodes
        :type nodes: (NX2) array of floats

        :param faces=None : the faces of the grid. Indexes for the nodes array.
        :type faces: (NX3) array of integers

        :param edges=None : the edges of the grid. Indexes for the nodes array.
        :type edges: (NX2) array of integers

        :param boundaries=None: specification of the boundaries are usually a
                                subset of edges where boundary condition
                                information, etc is stored.
                                (NX2) integer array of indexes for the nodes
                                array.
        :type boundaries: numpy array of integers

        :param face_face_connectivity=None: connectivity arrays.
        :param face_edge_connectivity=None: connectivity arrays.

        :param edge_coordinates=None: representative coordinate of the edges.
        :param face_coordinates=None: representative coordinate of the faces.
        :param boundary_coordinates=None: representative coordinate of the
                                          boundaries.

        :param edge_coordinates=None: representative coordinate of the edges
        :type edge_coordinates: (NX2) array of floats

        :param face_coordinates=None: representative coordinate of the faces
                                      (NX2) float array
        :type face_coordinates: (NX2) array of floats


        :param boundary_coordinates=None: representative coordinate of the
                                          boundaries
        :type boundary_coordinates: (NX2) array of floats


        :param data = None: associated variables
        :type data: dict of UVar objects

        :param mesh_name = "mesh": optional name for the mesh
        :type mesh_name: string

        Often this is too much data to pass in as literals -- so usually
        specialized constructors will be used instead (load from file, etc).
        """

        super(D3dfmUGrid, self).__init__(nodes,
                                         node_lon,
                                         node_lat,
                                         faces,
                                         edges,
                                         boundaries,
                                         face_face_connectivity,
                                         face_edge_connectivity,
                                         edge_coordinates,
                                         face_coordinates,
                                         boundary_coordinates,
                                         data,
                                         mesh_name,
                                         )

    @classmethod
    def from_ncfile(klass, nc_url, mesh_name=None, load_data=False):
        """
        create a UGrid object from a netcdf file name (or opendap url)

        :param nc_url: the filename or OpenDap url you want to load

        :param mesh_name=None: the name of the mesh you want. If None, then
                               you'll get the only mesh in the file. If there
                               is more than one mesh in the file, a ValueError
                               Will be raised
        :param load_data=False: flag to indicate whether you want to load the
                                associated data or not.  The mesh will be
                                loaded in any case.  If False, only the mesh
                                will be loaded.  If True, then all the data
                                associated with the mesh will be loaded.
                                This could be huge!
        :type load_data: boolean

        """
        grid = klass()
        D3dfmUGrid.load_grid_from_ncfilename(nc_url, grid,               #replaced read_netcdf with D3dfmUGrid
                                             mesh_name, load_data)
        return grid

    @staticmethod
    def load_grid_from_ncfilename(filename, grid, mesh_name=None, load_data=True):
        """
        loads UGrid object from a netcdf file, adding the data
        to the passed-in grid object.

        It will load the mesh specified, or look
        for the first one it finds if none is specified

        :param filename: filename or OpenDAP url of dataset.

        :param grid: the grid object to put the mesh and data into.
        :type grid: UGrid object.

        :param mesh_name=None: name of the mesh to load
        :type mesh_name: string

        :param load_data=False: flag to indicate whether you want to load the
                                associated data or not.  The mesh will be loaded
                                in any case.  If False, only the mesh will be
                                loaded.  If True, then all the data associated
                                with the mesh will be loaded.  This could be huge!
        :type load_data: boolean
        """

        with netCDF4.Dataset(filename, 'r') as nc:
            D3dfmUGrid.load_grid_from_nc_dataset(nc, grid, mesh_name, load_data)

    @staticmethod
    def load_grid_from_nc_dataset(nc, grid, mesh_name=None, load_data=True):
        """
        loads UGrid object from a netCDF4.DataSet object, adding the data
        to the passed-in grid object.

        It will load the mesh specified, or look
        for the first one it finds if none is specified

        :param nc: netcdf Dataset to be loaded up
        :type nc: netCDF4 Dataset object

        :param grid: the grid object to put the mesh and data into.
        :type grid: UGrid object.

        :param mesh_name=None: name of the mesh to load
        :type mesh_name: string

        :param load_data=False: flag to indicate whether you want to load the
                                associated data or not.  The mesh will be loaded
                                in any case.  If False, only the mesh will be
                                loaded.  If True, then all the data associated
                                with the mesh will be loaded.  This could be huge!
        :type load_data: boolean

        NOTE: passing the UGrid object in to avoid circular references,
        while keeping the netcdf reading code in its own file.
        """
        ncvars = nc.variables

        # Get the mesh_name.
        if mesh_name is None:
            # Find the mesh.
            meshes = read_netcdf.find_mesh_names(nc) # read_netcdf.find_mesh_names instead find_mesh_names
            if len(meshes) == 0:
                msg = "There are no standard-conforming meshes in {}".format
                raise ValueError(msg(nc.filepath))
            if len(meshes) > 1:
                msg = "There is more than one mesh in the file: {!r}".format
                raise ValueError(msg(meshes))
            mesh_name = meshes[0]
        else:
            if not read_netcdf.is_valid_mesh(nc, mesh_name):
                msg = "Mesh: {} is not in {}".format
                raise ValueError(msg(mesh_name, nc.filepath))

        grid.mesh_name = mesh_name
        mesh_var = ncvars[mesh_name]

        # Load the coordinate variables.
        for defs in read_netcdf.coord_defs:  # read_netcdf.coord_defs instead coord_defs
            try:
                coord_names = mesh_var.getncattr(defs['role']).strip().split()
                coord_vars = [nc.variables[name] for name in coord_names]
            except AttributeError:
                if defs['required']:
                    msg = "Mesh variable must include {} attribute.".format
                    raise ValueError(msg(defs['role']))
                continue
            except KeyError:
                msg = ("File must include {} variables for {} "
                       "named in mesh variable.").format
                raise ValueError(msg(coord_names, defs['role']))

            coord_vars = [nc.variables[name] for name in coord_names]
            num_node = len(coord_vars[0])
            nodes = np.empty((num_node, 2), dtype=np.float64)
            for var in coord_vars:
                try:
                    standard_name = var.standard_name
                except AttributeError:
                    # CF does not require a standard name, look in units, instead.
                    try:
                        units = var.units
                    except AttributeError:
                        msg = ("The {} variable doesn't contain units "
                               "attribute: required by CF").format
                        raise ValueError(msg(var))
                    # CF accepted units attributes for longitude.
                    if units in ('degrees_east', 'degree_east', 'degree_E',
                                 'degrees_E', 'degreeE', 'degreesE'):
                        standard_name = 'longitude'
                    # CF accepted units attributes for longitude.
                    elif units in ('degrees_north', 'degree_north', 'degree_N',
                                   'degrees_N', 'degreeN', 'degreesN'):
                        standard_name = 'latitude'
                    else:
                        msg = ("{} variable's units value ({}) doesn't look "
                               "like latitude or longitude").format
                        raise ValueError(msg(var, units))
                if standard_name == 'projection_y_coordinate':  #'latitude':
                    nodes[:, 1] = var[:]
                elif standard_name == 'projection_x_coordinate': #'longitude':
                    nodes[:, 0] = var[:]
                else:
                    raise ValueError('Node coordinates standard_name is neither '
                                     '"projection_x_coordinate" nor "projection_y_coordinate" ')
                                     #'"longitude" nor "latitude" ')
            setattr(grid, defs['grid_attr'], nodes)

        # Load assorted connectivity arrays.
        for defs in read_netcdf.grid_defs: # read_netcdf.grid_defs instead grid_defs
            try:
                try:
                    var = nc.variables[mesh_var.getncattr(defs['role'])]
                except AttributeError:  # This connectivity array isn't there.
                    continue
                array = var[:, :]
                # Fortran order, instead of C order, transpose the array
                # logic below will fail for 3 node or two edge grids.
                if array.shape[0] == defs['num_ind']:
                    array = array.T
                try:
                    start_index = int(var.start_index)
                except AttributeError:
                    start_index = 0
                if start_index >= 1:
                    array -= start_index
                    # Check for flag value.
                    try:
                        # FIXME: This won't work for more than one flag value.
                        flag_value = var.flag_values
                        array[array == flag_value - start_index] = flag_value
                    except AttributeError:
                        pass
                setattr(grid, defs['grid_attr'], array)
            except KeyError:
                pass  # OK not to have this...

        # Load the associated data:

        if load_data:
            # Look for data arrays -- they should have a "location" attribute.
            for name, var in nc.variables.items():
                # Data Arrays should have "location" and "mesh" attributes.
                try:
                    location = var.location
                    # The mesh attribute should match the mesh we're loading:
                    if var.mesh != mesh_name:
                        continue
                except AttributeError:
                    print("var:%s does not have 'location' attribute" % name)
                    continue

                # Get the attributes.
                # FIXME: Is there a way to get the attributes a Variable directly?
                attributes = {n: var.getncattr(n) for n in var.ncattrs()
                              if n not in ('location', 'coordinates', 'mesh')}

                # Trick with the name: FIXME: Is this a good idea?
                name = name.lstrip(mesh_name).lstrip('_')
                uvar = pyugrid.UVar(name, data=var[:].transpose(),            # added pyugridd.UVar instead UVar ; Need to transpose because UVar checks on the same var length as the mesh
                                    location=location, attributes=attributes)
                print("{'name':'%s', 'standard_name': '%s', 'long_name': '%s', 'location':'%s'}," %(name, var.standard_name, var.long_name, var.location))
                try:
                    grid.add_data(uvar)
                except ValueError:
                    print("Var name:%s Failed" % name)

    def find_uvars_byname(self, name, location=None):
        """
        Find all :py:class:`UVar`s that match the specified standard name

        :param str name: the name attribute.


        :keyword location: optional attribute location to narrow the returned
        :py:class : `UVar`s (one of 'node', 'edge', 'face', or 'boundary').

        :return: set of matching :py:class:`UVar`s

        """
        found=set()
        for ds in self._data.values():
            if ds.name == name:
                if location is not None and ds.location != location:
                    continue
                found.add(ds)
        return found
