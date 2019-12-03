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

import itertools
import logging
import csv
import cStringIO 

from pylons import request, response, session, config, tmpl_context as c
from pylons.controllers.util import abort
from pylons.decorators import jsonify
from webhelpers.html import escape

from kmldap.lib.base import BaseController, render
from kmldap.model import makejarkustransect, makejarkusoverview
from kmldap.lib.helpers import compress_kml, plotproperties
from kmldap.lib import plots

log = logging.getLogger(__name__)

class JarkusController(BaseController):

    def index(self):
        # Return a rendered template
        #return render('/jarkus.mako')
        # or, return a response
        return 'Hello World'

    @jsonify
    def transectsinview(self):
        overview = makejarkusoverview()
        bounds = request.params.get('bounds')
        if bounds:
            latmin, lonmin, latmax, lonmax = map(float,bounds.split(',')) # TODO: clean this up
        # look up values in the current view
        index = ( (latmin < overview.lat)  & (overview.lat < latmax)) & ((lonmin < overview.lon) & (overview.lon < lonmax))
        transects = []
        for transect in zip(overview.id[index].tolist(),  overview.lat[index].tolist(), overview.lon[index].tolist()):
            transects.append(dict(id=transect[0], lat=transect[1], lon=transect[2]))
        result = dict(transects=transects)
        return result

    @jsonify
    def transectjson(self, id):
        if not id:
            return
        else:
            transect = makejarkustransect(int(id))
        transects = []
        for i, t in enumerate(transect.t):
            transects.append(dict(year=str(t),z=transect.z[i,:].tolist()))
        result = dict(cross_shore=transect.cross_shore.tolist(), transects=transects)
        return result

    def transect(self, id, format="html"):
        """transect view"""
        if not id:
            transect = None
        else:
            transect = makejarkustransect(int(id))
        response.content_type = mimetypes.types_map.get(format,'text/html')
        if format == 'kml':
            response.headers['Content-disposition'] = 'attachment; filename=fname.kml'
            return compress_kml(render('/transectview.kml', extra_vars={'transect': transect}))
        elif format == 'csv':
            response.headers['Content-disposition'] = 'attachment; filename=%s.csv' % (transect.id,)
            rows = zip(transect.t.repeat(transect.z.shape[1]),
                       itertools.cycle(transect.cross_shore),
                       transect.z.flat)
            text = cStringIO.StringIO()
            writer = csv.writer(text)
            writer.writerows(rows)
            text.seek(0)
            return text.read()
        else:
            return render('/transectview.html', extra_vars={'transect': transect})

    def code(self, id, format='py'):
        """transect view"""
        if not id:
            transect = None
        else:
            transect = makejarkustransect(int(id))
        response.content_type = mimetypes.types_map.get(format,'text/plain')
        response.headers['Content-disposition'] = 'attachment; filename=%s.%s' % (transect.id, format)
        return render('/code.%s' % (format,), extra_vars={'transect': transect, 'url':config.get('jarkus.url')})
        
        
    def overview(self, format="html"):
        """transect overview"""
        overview = makejarkusoverview()
        response.content_type = mimetypes.types_map.get(format,'text/html')
        if format == 'kml':
            response.headers['Content-disposition'] = 'attachment; filename=fname.kml'
            return render('/overview.kml', extra_vars={'overview': overview})
        elif format == 'rss':
            return render('/overview.rss', extra_vars={'overview': overview})
        else:
            return render('/overview.html', extra_vars={'overview': overview, 'googlekey': config['google.key']})

    def transectplot(self, id, format="png"):
        """create a transect plot"""
        if not id:
            transect = None
        else:
            transect = makejarkustransect(int(id))
        requestproperties = {}
        requestproperties.update(request.params)
        requestproperties.update(request.environ['pylons.routes_dict'])
        properties = plotproperties(requestproperties)
        img = plots.jarkustimeseries(transect, plotproperties=properties).read()
        response.content_type = mimetypes.types_map.get(format,'application/octet-stream')
        return img

    def eeg(self, id, format="png"):
        """create a eeg plot"""
        if not id:
            transect = None
        else:
            transect = makejarkustransect(int(id))
        requestproperties = {}
        requestproperties.update(request.params)
        requestproperties.update(request.environ['pylons.routes_dict'])
        properties = plotproperties(requestproperties)
        img = plots.eeg(transect, plotproperties=properties).read()
        response.content_type = mimetypes.types_map.get(format,'application/octet-stream')
        return img

    def alphahistory(self, id, format="png"):
        """create a transect plot"""
        if not id:
            transect = None
        else:
            transect = makejarkustransect(int(id))
        requestproperties = {}
        requestproperties.update(request.params)
        requestproperties.update(request.environ['pylons.routes_dict'])
        properties = plotproperties(requestproperties)
        img = plots.alphahistory(transect, plotproperties=properties).read()
        response.content_type = mimetypes.types_map.get(format,'application/octet-stream')
        return img

    def procrustes(self, id, format="png"):
        """create a transect plot"""
        transect = makejarkustransect(int(id))
        requestproperties = {}
        requestproperties.update(request.params)
        requestproperties.update(request.environ['pylons.routes_dict'])
        properties = plotproperties(requestproperties)
        img = plots.procrustes(transect, plotproperties=properties).read()
        response.content_type = mimetypes.types_map.get(format,'application/octet-stream')
        return img

    def mkl(self, id, format="png"):
        """create a transect plot"""
        transect = makejarkustransect(int(id))
        requestproperties = {}
        requestproperties.update(request.params)
        requestproperties.update(request.environ['pylons.routes_dict'])
        properties = plotproperties(requestproperties)
        log.info('making image')
        img = plots.mkl(transect, plotproperties=properties).read()
        log.info('setting content type')
        response.content_type = mimetypes.types_map.get(format,'application/octet-stream')
        return img
