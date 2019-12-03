import logging

from pylons import request, response, session, tmpl_context as c, url
from pylons.controllers.util import abort, redirect
from pylons.decorators import jsonify

from kmldap.lib.base import BaseController, render
import kmldap.model.waterbase
log = logging.getLogger(__name__)

class WaterbaseController(BaseController):

    def stations(self):
        # Return a rendered template
        #return render('/waterbase.mako')
        # or, return a string
        return 'Hello World'
    def station(self,id):
        return "station"
    
    @jsonify
    def timeseries(self,id):
        """returns the timeseries of a station"""
        return kmldap.model.waterbase.getseries(id)
