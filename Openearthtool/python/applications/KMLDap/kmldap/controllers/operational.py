import logging
import mimetypes
mimetypes.init()
mimetypes.add_type('application/pdf', 'pdf')
mimetypes.add_type('image/png', 'png')
mimetypes.add_type('image/svg+xml', 'svg')
mimetypes.add_type('image/svg+xml', 'svgz')
mimetypes.add_type('application/postscript','ps')
mimetypes.add_type('application/postscript','ai')
mimetypes.add_type('application/postscript','eps')
mimetypes.add_type('application/vnd.google-earth.kml+xml','kml')
mimetypes.add_type('application/vnd.google-earth.kml+xml','kmz')
mimetypes.add_type('application/rss+xml', 'rss')

from pylons import request, response, session, tmpl_context as c, url, config
from pylons.controllers.util import abort, redirect

from kmldap.lib.base import BaseController, render
from kmldap.lib.helpers import compress_kml, plotproperties
from kmldap.lib.operational.plots import timetable, plot, plot3d

import pydap.client
import pydap.responses.html
import pydap.responses.kml

import numpy as np

import kmldap.model
import kmldap.lib.coords
import datetime

log = logging.getLogger(__name__)

class OperationalController(BaseController):

    def index(self):
        """ create a list of plots of all parameters and ssi's available """
        
        dataset = kmldap.model.opendap(config['operational.url'])
        variables = [key for (key, value) in dataset.variables.items() if len(value.shape) == 3]
        
        return render('/operational.html', extra_vars={'variables':variables})
    def models(self, format="svg"):
        """ create an graphical overview of the available model runs """
        requestproperties = {}
        requestproperties.update(request.params)
        requestproperties.update(request.environ['pylons.routes_dict'])
        properties = plotproperties(requestproperties)
        img = timetable(plotproperties=properties).read()
        response.content_type = mimetypes.types_map.get(format,'application/octet-stream')
        return img
    def plot(self, var=None, format="png"):
        """ create a plot of a specific parameter or ssi at a specific time """
        if var is None:
            var = request.params.get('var', 'zb')
        return self._plot(format, plot=plot, var=var)
    def plot3d(self, format="png"):
         """ create a 3d plot at a specific time """
         return self._plot(format, plot=plot3d)
    def kml(self, var=None):
        """ create a kmz file with overlays of a specific parameter varying in time """
        if var is None:
            var = request.params.get('var', 'zb')
        return self._kml(plot=plot, var=var)


    
    """
            PRIVATE FUNCTIONS
    """
    def _plot(self, format="png", plot=None, var='zb', **kwargs):
        """ create a plot of a specific parameter or ssi at a specific time """
        
        requestproperties = {}
        requestproperties.update(request.params)
        requestproperties.update(request.environ['pylons.routes_dict'])
        properties = plotproperties(requestproperties)
        
        response.content_type = mimetypes.types_map.get(format,'application/octet-stream')
        
        dataset = kmldap.model.opendap(config['operational.url'])
        
        if format == 'kml':
            raise ValueError("Please use the generic KML function 'kmldap.controllers.operational.kml' instead")
        else:
            ti = int(requestproperties.get('t', '0'))
            colorbar = requestproperties.get('colorbar', False) == 'True'
            
            lat, lon = kmldap.lib.coords.get_latlon(dataset)
            dataset.variables['lat'] = lat
            dataset.variables['lon'] = lon
            
            img = plot(dataset, ti, var, colorbar=colorbar, plotproperties=properties,**kwargs)
            
        return img
    def _kml(self, plot=None, var='zb', **kwargs):
        """ create a kmz file with overlays of a specific parameter varying in time """
        
        response.content_type = mimetypes.types_map.get(format,'application/octet-stream')
        response.headers['Content-disposition'] = 'attachment; filename=%s.kml' % (var,)
        
        dataset = kmldap.model.opendap(config['operational.url'])
        
        # define time grid
        refdate = dataset.attributes['PARAMS']['refdate']
        time = [datetime.datetime.strftime(refdate+datetime.timedelta(0,t),'%Y-%m-%dT%H:%M:%S') \
                for t in dataset.variables['globaltime']]
        time_start = time[:-1]
        time_end = time[1:]
        
        # define space grid
        lat, lon = kmldap.lib.coords.get_latlon(dataset)
        west, east = lon.min(), lon.max()
        south, north = lat.min(), lat.max()
        rotation = kmldap.lib.coords.get_rotation(lat,lon)
        
        return compress_kml(render('/plot.kml', extra_vars={'controller': 'operational',
                                                            'action': plot.__name__,
                                                            'time_start': time_start,
                                                            'time_end': time_end,
                                                            'var': var,
                                                            'east': east,
                                                            'south': south,
                                                            'west': west,
                                                            'north': north,
                                                            'rotation':rotation}))


        
