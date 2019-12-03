import logging

from pylons import request, response, session, tmpl_context as c, url
from pylons.controllers.util import abort, redirect

from pylons.decorators import jsonify

from lol.lib.base import BaseController, render
# from lol.model import Coast
log = logging.getLogger(__name__)

import numpy as np
class StreamtraceController(BaseController):

    def index(self):
        # Return a rendered template
        #return render('/streamtrace.mako')
        # or, return a string
        1/0
        return render('/randomwalk.html')
    @jsonify
    def move(self):
        points = []
        for i in range(10):
            lats = 52.61 + np.cumsum(np.random.random(100))/100.0*0.04
            lons = 4.55 + np.cumsum(np.random.random(100))/100.0*0.08
            points.append({'lat': lats.tolist(), 'lon': lons.tolist()})
        return {'points': points}
    @jsonify
    def trace(self, start = None):
        coast = Coast()
        start = np.c_[np.random.random(20)*400, np.random.random(20)*400, np.zeros(20)]
        result = coast.trace(start=start, t=50)

        # make results json compatible.
        json = {}
        if result['n_streamlines'] > 0:
            json['streamlines'] = [array[:,:2].ravel().tolist() for array in result['streamlines']]
        else:
            json['streamlines'] = []
        json['arrays'] = {}
        if result.has_key('arrays'):
            for array in result['arrays']:
                json['arrays'][array] = result['arrays'][array].tolist()
        return json

    
    
