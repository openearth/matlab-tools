import unittest
import datetime
import matplotlib.dates as dates
import sys, os
import pathlib
filepath = pathlib.Path(__file__)
filedir = filepath.parent
sys.path.insert(0, str(filedir) + "/../")

from pyd3dfm import read_nc_his


class TestNcHisD3dfm(unittest.TestCase):

    def setUp(self):
        print('TestNcHisD3dfm.setUp')
        fn = "run_2D_20130813_his.nc"
        filepath = pathlib.Path(__file__)
        filedir = filepath.parent
        path = str(filedir) + "/../test_data"
        #path = os.path.abspath(os.path.dirname(__file__)) + "/../test_data"
        file = path + '/' + fn
        self.netcdf_3d3 = read_nc_his.NcHisD3dfm(file)

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
        self.assertEqual(dimnames[0], "time", "Wrong dimension order")

    def test_get_variable_names(self):
        print('TestNcHisD3dfm.test_get_variable_names')
        varnames = self.netcdf_3d3.get_variable_names()
        self.assertEqual(varnames[27], "waterlevel", "Wrong variable order")

    def test_nc_dump(self):
        print('TestNcHisD3dfm.test_nc_dump')
        attrs, dimnames, varnames = self.netcdf_3d3.nc_dump()
        self.assertEqual(varnames[27], "waterlevel", "Wrong variable order") \
        or self.assertEqual(dimnames[0], "time", "Wrong dimension order") \
        or self.assertEqual(attrs[0], "institution", "Wrong attribute")


    def test_get_time(self):
        print('TestNcHisD3dfm.test_get_time')
        time = self.netcdf_3d3.get_time()
        format = "%a %b %d %H:%M:%S %Y"
        self.assertEqual(time[1].strftime(format), "Sat Jan 13 00:06:00 1", "Wrong time")


    def test_timestamp2doy(self):
        print('TestNcHisD3dfm.test_timestamp2doy')
        time = self.netcdf_3d3.get_time()
        num = dates.date2num(time[1])
        doy = read_nc_his.NcHisD3dfm.timestamp2doy([num])
        self.assertEqual(doy[0], 13.004166666666666, "Wrong time doy")


    def test_date2doy(self):
        print('TestNcHisD3dfm.test_date2doy')
        time = self.netcdf_3d3.get_time()
        doy = self.netcdf_3d3.date2doy()
        self.assertEqual(doy[1], 13.004166666666666, "Wrong date doy")


    def test_plot_variables(self):
        print('TestNcHisD3dfm.test_plot_variable')
        [nc_attrs, nc_dims, nc_vars] = self.netcdf_3d3.nc_dump(verb=True)

        # variable = "cross_section_discharge"
        # varname = "cross_section_name"
        # cross_section_name = "West-Gap-01"
        # ax1 = self.netcdf_3d3.plot_variable(variable, varname, cross_section_name,
        #                                     year=2013, month=8, day=7,
        #                                     doy=True, block=False)
        #
        # variable = "waterlevel"
        # varname = "station_name"
        # station_name = "TC1-09"
        # ax2 = self.netcdf_3d3.plot_variable(variable, varname, station_name,
        #                                     year=2013, month=8, day=7,
        #                                     doy=True, block=False)

        success = 0
        errors = 0
        var_names = self.netcdf_3d3.get_variable_names(verb=False)

        # test observation points first
        for vn in self.netcdf_3d3.var_list_plot_obs:
            for vv in self.netcdf_3d3.var_list_obs_var_names:
                var_values = self.netcdf_3d3.get_station_names()
                for id in var_values:
                    try:
                        success += self.netcdf_3d3.plot_variables(vn, vv, [id],
                                                                 year=2013, month=8, day=7,
                                                                 doy=True, block=False)
                    except Exception:
                        print("Error %s : %s : %s" % (vn, vv, id))
                        errors += 1


        # test observation cross sections second
        for vn in self.netcdf_3d3.var_list_plot_sections:
            for vv in self.netcdf_3d3.var_list_sect_var_names:
                var_values = self.netcdf_3d3.get_section_names()
                for id in var_values:
                    try:
                        success += self.netcdf_3d3.plot_variables(vn, vv, [id],
                                                                 year=2013, month=8, day=7,
                                                                 doy=True, block=False)
                    except Exception:
                        print("Error %s : %s : %s" % (vn, vv, id))
                        errors += 1


        # self.netcdf_3d3.plt_show() - just for debugging
        assert (success >= 1 and errors == 0)

    def test_plot_2_variables(self):
        print('TestNcHisD3dfm.test_plot_variable')

        success = 0
        [nc_attrs, nc_dims, nc_vars] = self.netcdf_3d3.nc_dump(verb=True)


        variable = "waterlevel"
        varname = "station_name"
        station_name1 = "Emb-C-01"
        station_name2 = "TC1-09"

        success += self.netcdf_3d3.plot_variables(variable, varname, [station_name1,station_name2],
                                            year=2013, month=8, day=7,
                                            doy=True, block=False)
        # self.netcdf_3d3.plt_show() - just for debugging
        assert (success == 1)

    def test_plot_stations(self):
        print('TestNcHisD3dfm.test_plot_stations')
        [nc_attrs, nc_dims, nc_vars] = self.netcdf_3d3.nc_dump(verb=True)

        station_name = "TC1-09"
        success = 0
        var_names = self.netcdf_3d3.get_variable_names(verb=False)

        #plot only one
        for vn in var_names:
            if vn in self.netcdf_3d3.var_list_stations:
                success += self.netcdf_3d3.plot_stations(vn, [station_name], block=False)

        #plot all stations

        for vn in var_names:
            if vn in self.netcdf_3d3.var_list_stations:
                sn = self.netcdf_3d3.get_station_names()
                try:
                    success += self.netcdf_3d3.plot_stations(vn, sn, km=True, col='coly', block=False)
                except Exception:
                    print("Error %s : print all stations" % (vn))

        #self.netcdf_3d3.plt_show() - just for debugging
        assert (success >= 1)

