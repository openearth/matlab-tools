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

import unittest
import datetime
import matplotlib.dates as dates
import sys, os
import cartopy
import pathlib
filepath = pathlib.Path(__file__)
filedir = filepath.parent
sys.path.insert(0, str(filedir) + "/../")
sys.path.insert(0, str(filedir) + "/../pyd3dfm")
from pyd3dfm import read_nc_map


class TestNcMapD3dfm(unittest.TestCase):

    def setUp(self):
        print('TestNcMapD3dfm.setUp')
        fn = "2D_UGRID_12h_map.nc"
        self.path = os.path.abspath(os.path.dirname(__file__)) + "/../test_data"
        file = self.path + '/' + fn
        self.netcdf_3d3 = read_nc_map.NcMapD3dfm(file)
        self.projection = cartopy.crs.UTM(zone='17N')

    def tearDown(self):
        del self.netcdf_3d3

    def test_get_globalAttr(self):
        print('TestNcHisD3dfm.test_get_globalAttr')
        text = self.netcdf_3d3.get_globalattr("institution")
        print('test_get_globalAttr: %s' % text)
        self.assertEqual(text, "Deltares", "Wrong institution")

    def test_get_dimension_names(self):
        print('TestNcHisD3dfm.test_get_dimension')
        dimnames = self.netcdf_3d3.get_dimension_names()
        self.assertEqual(dimnames[0], "nmesh2d_node", "Wrong dimension order")

    def test_get_variable_names(self):
        print('TestNcHisD3dfm.test_get_variable_names')
        varnames = self.netcdf_3d3.get_variable_names()
        self.assertEqual(varnames[27], "mesh2d_ucy", "Wrong variable order")

    def test_nc_dump(self):
        print('TestNcHisD3dfm.test_nc_dump')
        attrs, dimnames, varnames = self.netcdf_3d3.nc_dump()
        self.assertEqual(varnames[27], "mesh2d_ucy", "Wrong variable order") \
        or self.assertEqual(dimnames[0], "nmesh2d_node", "Wrong dimension order") \
        or self.assertEqual(attrs[0], "institution", "Wrong attribute")

    def test_plot_facevar(self):
        print('TestNcMapD3dfm.test_plot_face')
        variable_name = "sea_surface_height"
        dvar = self.netcdf_3d3.ugrid.find_uvars(variable_name)
        sc, vari = self.netcdf_3d3.plot_data_variable(fig=None, projection=self.projection, var=dvar, ts=11, marker='o',
                                                      msize=1, vmin=75, vmax=75.2, year=2013, month=8, day=7, km=True,
                                                      cbar=True, cborient='horizontal',
                                                      shpfilename=self.path + '/' + "lineboundary.shp", block=True)
        assert (vari.attributes['standard_name'] == variable_name)


    def test_plot_edgevar(self):
        print('TestNcMapD3dfm.test_plot_edge')
        variable_name = "sea_water_x_velocity"
        dvar = self.netcdf_3d3.ugrid.find_uvars(variable_name)
        sc, vari = self.netcdf_3d3.plot_data_variable(fig=None, projection=self.projection, var=dvar, ts=12, marker='o',
                                                      msize=1, vmin=0., vmax=0.1, year=2013, month=8, day=7, km=True,
                                                      shpfilename=self.path + '/' + "lineboundary.shp", block=True)
        assert (vari.attributes['standard_name'] == variable_name)

    def test_plot_nodevar(self):
        print('TestNcMapD3dfm.test_plot_node')
        variable_name = "altitude"
        dvar = self.netcdf_3d3.ugrid.find_uvars(variable_name)
        sc, vari = self.netcdf_3d3.plot_data_variable(fig=None, projection=self.projection, var=dvar, ts=12, marker='o',
                                                      msize=1, year=2013, month=8, day=7, km=True,
                                                      shpfilename=self.path + '/' + "lineboundary.shp", contours=True)
        assert (vari.attributes['standard_name'] == variable_name)

    def test_plot_polygon(self):
        print('TestNcMapD3dfm.test_plot_polygon')
        # Test a 'face' location with polygon drawing (marker=None)
        variable_name = "sea_surface_height"
        dvar = self.netcdf_3d3.ugrid.find_uvars(variable_name)
        sc, vari = self.netcdf_3d3.plot_data_variable(fig=None, projection=self.projection, var=dvar, ts=11,
                                                      marker=None, msize=1, vmin=75, vmax=75.2,
                                                      year=2013, month=8, day=7, km=False,
                                                      cbar=True, cborient='horizontal',
                                                      shpfilename=self.path + '/' + "lineboundary.shp", block=True)
        assert (vari.attributes['standard_name'] == variable_name)

    def test_animation(self):
        print('TestNcMapD3dfm.test_animation')
        variable_name = "sea_surface_height"
        dvar = self.netcdf_3d3.ugrid.find_uvars(variable_name)
        ret = self.netcdf_3d3.animate(projection=self.projection, var=dvar, marker='o', msize=1,
                                      vmin=75, vmax=75.2, year=2013, month=8, day=7, km=True,
                                      shpfilename=self.path + '/' + "lineboundary.shp", save=True, block=False)
        assert (ret == True)