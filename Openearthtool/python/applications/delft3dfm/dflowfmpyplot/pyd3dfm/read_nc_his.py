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
import os
import sys

PACKAGE_PARENT = '.'
SCRIPT_DIR = os.path.dirname(os.path.realpath(os.path.join(os.getcwd(), os.path.expanduser(__file__))))
sys.path.append(os.path.normpath(os.path.join(SCRIPT_DIR, PACKAGE_PARENT)))

import read_nc_cdf
import matplotlib
import matplotlib.pyplot as plt
import matplotlib.dates as dates
import netCDF4
import re
from matplotlib.dates import MONDAY, SATURDAY
from cycler import cycler
import numpy as np

months = dates.MonthLocator()  # every month
yearsFmt = dates.DateFormatter('%Y')

# every monday
mondays = dates.WeekdayLocator(MONDAY)
hour = dates.HourLocator(byhour=None, interval=6, tz=None)


class NcHisD3dfm(read_nc_cdf.NcCdf):
    '''
    Class encapsulating the Delft3D-FM netCDF HIS file features and plotting
    '''

    dims = [
        'time',
        'name_len',
        'stations',
        'cross_section',
        'cross_section_name_len',
        'cross_section_pts'
    ]

    var_list_plotable = [
        'station_x_coordinate',
        'station_y_coordinate',
        'station_id',
        'station_name',
        'waterlevel',
        'Waterdepth',
        'x_velocity',
        'y_velocity',
        'windx',
        'windy',
        'cross_section_x_coordinate',
        'cross_section_y_coordinate',
        'cross_section_name',
        'cross_section_discharge',
        'cross_section_discharge_int',
        'cross_section_discharge_avg',
        'cross_section_area',
        'cross_section_area_avg',
        'cross_section_velocity',
        'cross_section_velocity_avg',
        'WaterBalance_total_volume',
        'WaterBalance_storage',
        'WaterBalance_volume_error',
        'WaterBalance_boundaries_in',
        'WaterBalance_boundaries_out',
        'WaterBalance_boundaries_total',
        'WaterBalance_exchange_with_1D_in',
        'WaterBalance_exchange_with_1D_out',
        'WaterBalance_exchange_with_1D_total',
        'WaterBalance_precipitation',
        'WaterBalance_source_sink',
        # 'time',   TIME is not a plottable variable
    ]

    var_list_waterbalance = [
        'WaterBalance_total_volume',
        'WaterBalance_storage',
        'WaterBalance_volume_error',
        'WaterBalance_boundaries_in',
        'WaterBalance_boundaries_out',
        'WaterBalance_boundaries_total',
        'WaterBalance_exchange_with_1D_in',
        'WaterBalance_exchange_with_1D_out',
        'WaterBalance_exchange_with_1D_total',
        'WaterBalance_precipitation',
        'WaterBalance_source_sink',
    ]

    var_list_plot_sections = [
        'cross_section_discharge',
        'cross_section_discharge_int',
        'cross_section_discharge_avg',
        'cross_section_area',
        'cross_section_area_avg',
        'cross_section_velocity',
        'cross_section_velocity_avg',
    ]

    var_list_plot_obs = [
        'waterlevel',
        'Waterdepth',
        'x_velocity',
        'y_velocity',
        'windx',
        'windy',
    ]

    var_list_stations = [
        'station_id',
        'station_name',
    ]

    var_list_obs_loc = [
        'station_x_coordinate',
        'station_y_coordinate',
    ]

    var_list_obs_var_names = [
        'station_name',
    ]

    var_list_sect_var_names = [
        'cross_section_name',
    ]

    #-----------------------------------------------------------------------------------------------------------------#
    def __init__(self, file):
        self.nc_fid = None
        self.nc_attrs = None 
        self.nc_dims = None
        self.nc_vars = None
        self.dt_time = None
        self.nm_time = None
        self.f = None
        self.fname = file

        try:
            print('open file: %s' % self.fname)
            self.f = netCDF4.Dataset(self.fname, 'r', 'NETCDF3_CLASSIC')
            # format='NETCDF4')
            # 'NETCD F4')
            # 'NETCDF3_CLASSIC')
        except IOError:
            print("Cannot open file:%s" % self.fname)
            raise

    #-----------------------------------------------------------------------------------------------------------------#
    def __del__(self):
        print('closed file: %s' % self.fname)
        self.f.close()
        
    #-----------------------------------------------------------------------------------------------------------------#
    def get_station_names(self):
        '''

        :return:
        '''
        ns = self.get_variable_value('station_name')
        return self.translate_names(ns)

    #-----------------------------------------------------------------------------------------------------------------#
    def get_section_names(self):
        '''

        :return:
        '''
        names = self.get_variable_value('cross_section_name')
        return self.translate_names(names)

    #-----------------------------------------------------------------------------------------------------------------#
    def plot_variables(self, plot_var_name, var_name_id, ids,
                       year=1, month=1, day=1,
                       ylabel=None, xlabel=None, title=None, loc=None,
                       colors=None, doy=True, block=False):
        '''

        :type plot_var_name: object
        :rtype: object
        :param plot_var_name:
        :param var_name_id: "station_name" , "cross_section_name", etc.
        :param ids: Array of variable instances ex: ["Station_Alpha"] or ["st1", "st2"]
        :param year:
        :param month:
        :param day:
        :param ylabel:
        :param xlabel:
        :param title:
        :param loc: 1 top right, 2 top left, 3 bottom left, 4 botom right
        :param doy:
        :param block:
        :return: True/False
        '''

        # safety checks
        if plot_var_name not in NcHisD3dfm.var_list_plotable:
            raise KeyError(plot_var_name)
        if var_name_id not in NcHisD3dfm.var_list_obs_var_names \
                and var_name_id not in NcHisD3dfm.var_list_sect_var_names:
            raise KeyError(var_name_id)

        fig = plt.figure()
        ax = fig.add_subplot(111)

        if colors is None:
            colors = ['b', 'r', 'g', 'c', 'm', 'y', 'k', 'brown', 'gold', 'gray', 'orange', 'pink']
            ax.set_prop_cycle(cycler('color', colors))
        else:
            color = colors

        if len(ids) > len(colors):
            raise KeyError("Only 12 plots are supported.")

        dt_time = self.get_time(year=year, month=month, day=day)
        var = self.get_variable_value(plot_var_name)
        varname = self.get_variable_value(var_name_id)[:]
         
        # Find the index for cross section, convert ndarray to bytes and remove exra bytes
        varname_str = [re.sub(r'[^ -~].*', '', v.tobytes().decode()) for v in varname]

        if doy:
            time = self.date2doy()
            self.nm_time = time
        else:
            time = self.dt_time[:]
            formatter = dates.DateFormatter('%Y-%m-%d %H:%M')
            ax.xaxis.set_major_formatter(formatter)
            # ax.xaxis.grid(True, 'major')
            # ax.xaxis.grid(True, 'minor')
            ax.grid(True)
            fig.autofmt_xdate()

        i = 1
        for id in ids:
            cs_idx = varname_str.index(id)
            ax.plot(time, var[:][:, cs_idx], label=id)
            i += 1

        if ylabel is not None:
            ax.set_ylabel(ylabel)
        else:
            ax.set_ylabel("%s [%s]" % (plot_var_name, self.f.variables[plot_var_name].units))

        if xlabel is not None:
            ax.set_xlabel(xlabel)
        else:
            if doy:
                ax.set_xlabel("Julian Day")
            else:
                ax.set_xlabel("Time [%s]" % (self.f.variables['time'].units))

        if title is not None:
            ax.set_title(title)
        else:
            if len(ids) == 1:
                ax.set_title("%s from\n%s" % (plot_var_name, ids[0]))
            else:
                ax.set_title("%s" % (plot_var_name))
                if loc is None:
                    loc = 1
                plt.legend(loc=loc)

        if block is False:
            plt.draw()
        else:
            plt.show()
        return True

    #-----------------------------------------------------------------------------------------------------------------#
    def plot_3Dvariables(self, plot_var_name, var_name_id, strid,
                        year=1, month=1, day=1,
                        ylabel=None, xlabel=None, title=None, loc=None,
                        colors=None, doy=True, block=False,
                        img=False, revert=False, interp=None, legloc=1):
        '''

        :type plot_var_name: object
        :rtype: object
        :param plot_var_name:
        :param var_name_id: "station_name" , "cross_section_name"
        :param id: variable instance ex: "Station_Alpha"
        :param year: default 1
        :param month: : default 1
        :param day: : default 1
        :param ylabel: None
        :param xlabel: None
        :param title: None
        :param loc: 1 top right, 2 top left, 3 bottom left, 4 botom right
        :param doy: True
        :param block: False, show is done outside, True show() is done in the method
        :param img:
        :paral legloc: None = nolegend, upper right 1, upper left 2, lower left 3, lower right 4, right	5,
                    center left 6, center right	7, lower center	8, upper center 9, center 10
        :return: True/False
        '''

        # safety checks
        if plot_var_name not in NcHisD3dfm.var_list_plotable:
            raise KeyError(plot_var_name)
        if var_name_id not in NcHisD3dfm.var_list_obs_var_names \
                and var_name_id not in NcHisD3dfm.var_list_sect_var_names:
            raise KeyError(var_name_id)

        fig = plt.figure()
        ax = fig.add_subplot(111)

        if colors is None:
            colors = ['b', 'r', 'g', 'c', 'm', 'y', 'k', 'brown', 'gold', 'gray', 'orange', 'pink']
            ax.set_prop_cycle(cycler('color', colors))
        else:
            color = colors


        dt_time = self.get_time(year=year, month=month, day=day)
        var = self.get_variable_value(plot_var_name)
        varname = self.get_variable_value(var_name_id)
        laydim = self.get_layers()
        if laydim.size > len(colors):
            raise KeyError("Only 12 plots are supported.")

        #ToDO: Explore what can we do with the coordinates of this variable? Perhaps remove hardcoding of zcoordinate_c
        #coords = self.get_coordinate_names(plot_var_name)

        layers = self.get_variable_value(plot_var_name)
        var = self.get_variable_value(plot_var_name)
        varname = self.get_variable_value(var_name_id)[:]

        # Find the index for cross section, convert ndarray to bytes and remove exra bytes
        varname_str = [re.sub(r'[^ -~].*', '', v.tobytes().decode()) for v in varname]

        # set the position for the zcoordinate
        # get a number id  for the string 'id'

        idx = varname_str.index(strid)
        dimpos = [None, idx, None]
        coordval, dims = self.get_variable_value_at_loc('zcoordinate_c', dimpos)

        if doy:
            time = self.date2doy()
            self.nm_time = time
        else:
            time = self.dt_time[:]
            formatter = dates.DateFormatter('%Y-%m-%d %H:%M')
            ax.xaxis.set_major_formatter(formatter)
            # ax.xaxis.grid(True, 'major')
            # ax.xaxis.grid(True, 'minor')
            ax.grid(True)
            fig.autofmt_xdate()

        #TODO: Here we have a choice between a simple plot and an image
        if img:
            if interp is not None:
                from scipy.interpolate import interp1d
                print("Interpolating on the vertical axis : n=%d" % interp)
                new_y = np.linspace(coordval[0], coordval[len(coordval)-1], interp * len(coordval))
                fint = interp1d(coordval[:], var[:][:, idx], kind='cubic')
                vel = fint(new_y).T
                if revert == True:
                    depth = new_y[::-1]  # or use np.flipud()
                else:
                    depth = new_y
            else:
                depth = coordval
                vel = var[:][:, idx].T
            X, Y = np.meshgrid(time, depth)
            im = ax.pcolormesh(X, Y, vel, shading = 'gouraud')  # , cmap = 'gray', norm = LogNorm())

            if ylabel is not None:
                ax.set_ylabel(ylabel)
            else:
                ax.set_ylabel("%s [%s]" % ('zcoordinate_c', self.f.variables['zcoordinate_c'].units))

            #deal with the colorbar
            fontsize=14
            cb = fig.colorbar(im)
            #cb.set_clim(0, maxtemp)
            labels = cb.ax.get_yticklabels()
            plt.setp(labels, rotation=0, fontsize=fontsize - 3)
            cb.set_label("%s [%s]" % (plot_var_name, self.f.variables[plot_var_name].units))
            text = cb.ax.yaxis.label
            font = matplotlib.font_manager.FontProperties(size=fontsize - 1)
            text.set_font_properties(font)

        else:
            lg = ax.plot(time, var[:][:, idx], label=id)
            if legloc is not None:
                coordval_str = ["%.02f" % c for c in coordval ]
                ax.legend(lg, coordval_str, loc=legloc, fontsize=12)

            if ylabel is not None:
                ax.set_ylabel(ylabel)
            else:
                ax.set_ylabel("%s [%s]" % (plot_var_name, self.f.variables[plot_var_name].units))

        if xlabel is not None:
            ax.set_xlabel(xlabel)
        else:
            if doy:
                ax.set_xlabel("Julian Day")
            else:
                ax.set_xlabel("Time [%s]" % (self.f.variables['time'].units))

        if title is not None:
            ax.set_title(title)
        else:
            ax.set_title("%s from\n%s" % (plot_var_name, strid))

        if block is False:
            plt.draw()
        else:
            plt.show()
        return True

    #-----------------------------------------------------------------------------------------------------------------#
    def plot_stations(self, plot_var_name, ids,
                      ylabel=None, xlabel=None, title=None,
                      km=False, marker='+', col='colx', block=False):
        '''

        :rtype: object
        :param plot_var_name: {str} one of 'station_id','station_name',
        :param ids: {str}: the name of the station to be ploted as +; pass one item array to plot only on station
        :param ylabel:
        :param xlabel:
        :param title:
        :param km: True, False
        :param marker: default '+'
        :param col: 'colx' or 'coly' color of the marker based on the positionof the station on x or y coordinates
        :param block: True to display the plot before leaving the method
        :return:True/False
        '''

        # safety checks
        if plot_var_name not in NcHisD3dfm.var_list_stations:
            raise KeyError(plot_var_name)

        fig = plt.figure()
        ax = fig.add_subplot(111)

        var = self.get_variable_value(plot_var_name)
        varname_str = [re.sub(r'[^ -~].*', '', v.tobytes().decode()) for v in var]

        varx = self.get_variable_value('station_x_coordinate')
        vary = self.get_variable_value('station_y_coordinate')

        cs_ids = [varname_str.index(id) for id in ids]

        # create a linear range for x and y coord
        ax.set_autoscale_on(False)
        if km and self.f.variables['station_x_coordinate'].units == 'm':
            varx = varx/1000.
            xunits = 'km'
        else:
            xunits = self.f.variables['station_x_coordinate'].units
        if km and self.f.variables['station_y_coordinate'].units == 'm':
            vary = vary/1000.
            yunits = 'km'
        else:
            yunits = self.f.variables['station_y_coordinate'].units

        epsx = (max(varx) - min(varx)) * 0.1
        epsy = (max(vary) - min(vary)) * 0.1
        ax.set_xlim(min(varx) - epsx, max(varx) + epsx)
        ax.set_ylim(min(vary) - epsy, max(vary) + epsy)
        ax.set_xmargin(1)
        ax.set_ymargin(1)

        # prevent offset type number display
        y_formatter = matplotlib.ticker.ScalarFormatter(useOffset=False)
        ax.yaxis.set_major_formatter(y_formatter)

        # create the array for x an y coordinates
        xcoord = []
        ycoord = []
        for cs_idx in cs_ids:
            xcoord.append(varx[cs_idx])
            ycoord.append(vary[cs_idx])

        # create colors for the marker
        if col == 'colx':
            colr = xcoord
        elif col == 'coly':
            colr = ycoord
        else:
            raise KeyError("Bad col entry:%s" % (col))

        ax.scatter(xcoord, ycoord, marker=marker, s=80, cmap='jet', c=colr)

        if ylabel is not None:
            ax.set_ylabel(ylabel)
        else:
            ax.set_ylabel("%s [%s]" % ('y coordinate', yunits))

        if xlabel is not None:
            ax.set_xlabel(xlabel)
        else:
            ax.set_xlabel("%s [%s]" % ('x coordinate', xunits))

        # select a title based on the number of stations
        if title is not None:
            ax.set_title(title)
        else:
            if plot_var_name == 'station_id':
                if len(ids) == 1:
                    ax.set_title("Observation station identifier %s" % (ids[0]))
                else:
                    ax.set_title("Observation station identifiers")
            if plot_var_name == 'station_name':
                if len(ids) == 1:
                    ax.set_title("Observation station name %s" % (ids[0]))
                else:
                    ax.set_title("Observation station names")
        if block is False:
            plt.draw()
        else:
            plt.show()
        return True

    #-----------------------------------------------------------------------------------------------------------------#
    def plot_waterbalance(self, plot_var_name, ylabel=None, xlabel=None, title=None, block=False):
        pass

# end class NcHisD3dfm

if __name__ == '__main__':
    fn = "run_2D_20130813_his.nc"
    path = "../test_data"
    file = path+'/'+fn
    
    netcdf_3d3 = NcHisD3dfm(file)
   
    [nc_attrs, nc_dims, nc_vars] = netcdf_3d3.nc_dump(verb=True)

    variable = "cross_section_discharge"
    varname = "cross_section_name"
    cross_section_name = "West-Gap-01"
    ax1 = netcdf_3d3.plot_variables(variable, varname, [cross_section_name],
                                    year=2013, month=8, day=7, doy=True, block=False)

    variable = "waterlevel"
    varname = "station_name"
    station_name = "TC1-09"
    ax2 = netcdf_3d3.plot_variables(variable, varname, [station_name], doy=True, block=False)

    print(netcdf_3d3.get_station_names())
    print(netcdf_3d3.get_section_names())
    plt.show()

    # dim = netcdf_3d3.get_dimension("time")
    # print(dim._name)
