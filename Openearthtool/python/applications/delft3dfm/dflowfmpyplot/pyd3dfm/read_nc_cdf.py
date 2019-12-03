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

import numpy as np
import matplotlib.pyplot as plt
import matplotlib as mpl
import matplotlib.dates as dates
import datetime as dt  # Python standard library datetime  module
import netCDF4
import re
from matplotlib.dates import MONDAY, SATURDAY

months = dates.MonthLocator()  # every month
yearsFmt = dates.DateFormatter('%Y')

# every monday
mondays = dates.WeekdayLocator(MONDAY)
hour = dates.HourLocator(byhour=None, interval=6, tz=None)


class NcCdf(object):
    # -----------------------------------------------------------------------------------------------------------------#
    def __init__(self, file):
        self.nc_fid = None
        self.nc_attrs = None 
        self.nc_dims = None
        self.nc_vars = None
        self.dt_time = None
        self.nm_time = None
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

    # -----------------------------------------------------------------------------------------------------------------#
    def __del__(self):
        print('closed file: %s' % self.fname)
        self.f.close()

    # -----------------------------------------------------------------------------------------------------------------#
    def get_globalattr(self, par):
        '''

        :param par:
        :return:
        '''
        #  get global atts
        if par == "title":
            return self.f.title
        if par == "institution":
            return self.f.institution
        if par == "source":
            return self.f.source
        if par == "history":
            return self.f.history
        if par == "references":
            return self.f.references
        if par == "email":
            return self.f.email
        if par == "comment":
            return self.f.comment
        if par == "version":
            return self.f.version
        if par == "Conventions":
            return self.f.Conventions
        if par == "terms_for_use":
            return self.f.terms_for_use
        if par == "disclaimer":
            return self.f.disclaimer
        if par == "all":
            return {"title": self.f.title,
                    "institution": self.f.institution,
                    "source": self.f.source,
                    "history": self.f.history,
                    "references": self.f.references,
                    "email": self.f.email,
                    "comment": self.f.comment,
                    "version": self.f.version,
                    "Conventions": self.f.Conventions,
                    "terms_of_use": self.f.terms_for_use,
                    "disclaimer": self.f.disclaimer
                    }

    # -----------------------------------------------------------------------------------------------------------------#
    def get_dimension(self, dimension):
        '''

        :param dimension:
        :return:
        '''
        dim = self.f.dimensions[dimension]
        return dim

    # -----------------------------------------------------------------------------------------------------------------#
    def get_variable_value(self, varname):
        '''

        :param varname:
        :return:
        '''
        if isinstance(varname, str):
            vname = varname
        else:
            vname = re.sub(r'[^ -~].*', '', varname.tobytes().decode())
        var = self.f.variables[vname] #[:]
        return var

    #------------------------------------------------------------------------------------------------------------------#
    def get_variable_value_at_loc(self, varname, dimpos=None):
        '''
        method that drills in the cube dimension to extract the values of variable with varname

        :param varname:
        :param dimpos: array of values for each dimension in the order of definition in the variable
        :return:
        '''

        if isinstance(varname, str):
            vname = varname
        else:
            vname = re.sub(r'[^ -~].*', '', varname.tobytes().decode())
        var = self.f.variables[vname]
        dims = var.dimensions

        if dimpos is not None and isinstance(dimpos, list):
            varpos = np.empty(len(dimpos), dtype=np.ndarray)
            i = 0
            for p in dimpos:
                if p is None:
                    if i == 0:
                        varpos[i] = var[:][0]
                    else:
                        varpos[i] = varpos[i-1][:]
                else:
                    varpos[i] = var[i-1][p]
                i += 1
        else:
            print("Error: dimension values not specified.")
            return None
        return varpos[len(dimpos)-1], dims

    #------------------------------------------------------------------------------------------------------------------#
    def print_ncattr(self, key):
        """
        Prints the NetCDF file attributes for a given key

        Parameters
        ----------
        key : unicode
            a valid netCDF4.Dataset.variables key
        """
        try:
            print("\t\ttype:", repr(self.f.variables[key].dtype))
            for ncattr in self.f.variables[key].ncattrs():
                print('\t\t%s:' % ncattr,
                      repr(self.f.variables[key].getncattr(ncattr)))
        except KeyError:
            print("\t\tWARNING: %s does not contain variable attributes" % key)

    #------------------------------------------------------------------------------------------------------------------#
    def get_attr_names(self, verb=True):
        '''

        :param verb:
        :return:
        '''

        # NetCDF global attributes
        nc_attrs = self.f.ncattrs()
        if verb:
            print("NetCDF Global Attributes:")
            for nc_attr in nc_attrs:
                print('\t%s:' % nc_attr, repr(self.f.getncattr(nc_attr)))

        return nc_attrs

    #------------------------------------------------------------------------------------------------------------------#
    def get_variable_names(self, verb=True):
        '''

        :param verb:
        :return:
        '''
        nc_vars = [var for var in self.f.variables]  # list of nc variables
        if verb:
            print("NetCDF variable information:")
            for var in nc_vars:
                if self.nc_dims is None:
                    self.nc_dims = self.get_dimension_names(verb=False)
                if var not in self.nc_dims:
                    print('\tName:', var)
                    print("\t\tdimensions:", self.f.variables[var].dimensions)
                    print("\t\tsize:", self.f.variables[var].size)
                    self.print_ncattr(var)
        return nc_vars

    #------------------------------------------------------------------------------------------------------------------#
    def get_coordinate_names(self, varname):
        '''

        :param varname:
        :return:
        '''
        coordinates = None
        try:
            for ncattr in self.f.variables[varname].ncattrs():
                if ncattr == 'coordinates':
                    coordinates = self.f.variables[varname].getncattr(ncattr)
                    coordarr = np.array(coordinates.split(' '))
                    break
        except KeyError:
            print("\t\tWARNING: %s does not contain variable attributes" % varname)
        return coordarr

    #------------------------------------------------------------------------------------------------------------------#
    def get_dimension_names(self, verb=True):
        '''

        :param verb:
        :return:
        '''
        nc_dims = [dim for dim in self.f.dimensions]  # list of nc dimensions
        if verb:
            print("NetCDF dimension information:")
            for dim in nc_dims:
                print("\tName:", dim)
                print("\t\tsize:", len(self.f.dimensions[dim]))
                self.print_ncattr(dim)
        return nc_dims

    # -----------------------------------------------------------------------------------------------------------------#
    def nc_dump(self, verb=True):
        '''
        nc_dump outputs dimensions, variables and their attribute information.
        The information is similar to that of NCAR's ncdump utility.
        ncdump requires a valid instance of Dataset.

        :param verb: Boolean - whether or not nc_attrs, nc_dims, and nc_vars are printed
        :return: nc_attrs : list - A Python list of the NetCDF file global attributes
                 nc_dims : list -  A Python list of the NetCDF file dimensions
                 nc_vars : list -  A Python list of the NetCDF file variables
        '''

        # Attributes information
        self.nc_attrs = self.get_attr_names(verb)

        # Dimension shape information.
        self.nc_dims = self.get_dimension_names(verb)

        # Variable information.
        self.nc_vars = self.get_variable_names(verb)
        return self.nc_attrs, self.nc_dims, self.nc_vars

    # -----------------------------------------------------------------------------------------------------------------#
    def get_time(self, year=1, month=1, day=1):
        '''

        :param year: - int start date year
        :param month: - int start date month
        :param day: - int start date day
        :return: dt_time - datetime format
        '''

        time = self.f.variables['time'][:]
        self.dt_time = [dt.datetime(year, month, day) + dt.timedelta(seconds=t) for t in time]

        return self.dt_time

    # -----------------------------------------------------------------------------------------------------------------#
    def get_layers(self):
        layers = self.f.dimensions['laydim']
        return layers

    # -----------------------------------------------------------------------------------------------------------------#
    @staticmethod
    def timestamp2doy(dt):
        '''
        Converts from timestamp [seconds] to day of the year
        '''
        dofy = np.zeros(len(dt))
        for j in range(0, len(dt)):
            d = dates.num2date(dt[j])
            dofy[j] = d.timetuple().tm_yday \
                      + d.timetuple().tm_hour / 24. \
                      + d.timetuple().tm_min / (24. * 60) \
                      + d.timetuple().tm_sec / (24. * 3600)
    
        return dofy

    # -----------------------------------------------------------------------------------------------------------------#
    def date2doy(self):
        '''
        Converts from date time in seconds to day of the year
        '''
        dofy = np.zeros(len(self.dt_time))
        j = 0
        for d in self.dt_time:
            dofy[j] = d.timetuple().tm_yday \
                      + d.timetuple().tm_hour / 24. \
                      + d.timetuple().tm_min / (24. * 60) \
                      + d.timetuple().tm_sec / (24. * 3600)
            j += 1

        return dofy

    # -----------------------------------------------------------------------------------------------------------------#
    def translate_names(self, strarr):
        varname_str = [re.sub(r'[^ -~].*', '', v.tobytes().decode()) for v in strarr]
        return varname_str

    # -----------------------------------------------------------------------------------------------------------------#
    def plt_show(self):
        plt.show()

    # -----------------------------------------------------------------------------------------------------------------#
    def color_norm(self, cmap=None, vmin=None, vmax=None, nbands=20, customstart=None):
        '''

        :param cmap:
        :param vmin:
        :param vmax:
        :param nbands:
        :param customstart:
        :return:
        '''

        if vmax == None or vmin == None:
            print("KeyError: vmax or vmin are None")
            raise KeyError("Error: vmax or vmin are None")

        # define the colormap
        if cmap is None:
            raise KeyError("cmap cannot be None")

        if isinstance(cmap,str):
            cmap = plt.get_cmap(cmap)

        if customstart is not None:
            # extract all colors from the .jet map
            cmaplist = [cmap(i) for i in range(cmap.N)]
            # force the first color entry to be grey if this is desired
            cmaplist[0] = (.5, .5, .5, 1.0)
            # create the new map
            cmap = cmap.from_list('Custom cmap', cmaplist, cmap.N)

        # define the bins and normalize
        bounds = np.linspace(vmin, vmax, nbands)
        norm = mpl.colors.BoundaryNorm(boundaries=bounds, ncolors=cmap.N)

        return norm, bounds

# end class NcCdf

