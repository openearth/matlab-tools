from scrapy.contrib.loader import ItemLoader
import netCDF4
import numpy

class DapcrawlerItemLoader(ItemLoader):
    def add_dataset(self):
        """This method expects a response.url in the context"""
        response = self.context['response']
        ds = netCDF4.Dataset(response.url)
        # flat representation
        self.item['url'] = response.url
        self.item['header'] = nctodict(ds)
        ds.close()


def nctodict(ds):
    """convert a netcdf dataset to a dictionary"""
    d = {}
    # get the main attributes
    d['attributes'] = ds.ncattrs()
    # get the dimensions and store the lengths
    d['dimensions'] = dict(
        (name, len(dim))
        for (name, dim)
        in ds.dimensions.items()
        )
    # now make a dictionary with all variables and their attributes
    d['variables'] = dict(
        # create a new item per variable, containing the dictionary with attributes
        (var, {'attributes':
                 dict(
                     (attr, ds.variables[var].getncattr(attr))
                     for attr in ds.variables[var].ncattrs()
                     )
                         })
        for var
        in ds.variables
        )
    # Update axis attributes and actual_ranges
    
    # update the axis
    for varname, variable in d['variables'].items():
        attrs = variable['attributes']
        # if there's no standard name just continue
        if 'standard_name' not in attrs:
            continue
        # If there's already an axis, skip it.
        elif 'axis' in attrs:
            continue
        # Set the axis for the different possible dimensions
        # X
        if attrs['standard_name'] in ('projection_x_coordinate', 'longitude'):
            attrs['axis'] = 'X'
        # Y 
        elif attrs['standard_name'] in ('projection_y_coordinate', 'latitude'):
            attrs[varname]['axis'] = 'Y'
        # Time
        elif attrs['standard_name'] in ('time', ):
            attrs[varname]['axis'] = 'T'
        # Z
        else:
            name = attrs['standard_name']
            if 'altitude' in name or 'height' in name or 'sigma_coordinate' in name:
                attrs['axis'] = 'Z'
    # Now loop over the variables again
    for varname in d['variables']:
        attrs = variable['attributes']
        # get the dataset variable now
        variable = ds.variables[varname]
        actual_range = None
        if 'axis'  in attrs:
            if len(variable.dimensions) == 1:
                # get the first and the last value
                bounds = variable[0], variable[-1]
                # do a nan check
                actual_range = float(numpy.min(bounds)), float(numpy.max(bounds))
            elif len(variable.dimensions) == 2:
                # get the boundaries, TODO: make this more efficient
                top    = variable[ 0,: ]
                bottom = variable[-1,: ]
                left   = variable[ :, 0]
                right  = variable[ :,-1]
                bounds = numpy.r_[top, bottom, left, right]
                actual_range = float(numpy.min(bounds)), float(numpy.max(bounds))
            attrs['actual_range'] = actual_range

    
    return d
    
