import logging

from pylons import request, response, session, tmpl_context as c
from pylons.controllers.util import abort

from kmldap.lib.base import BaseController, render

log = logging.getLogger(__name__)

class UsgsController(BaseController):

    def index(self):
        # Return a rendered template
        #return render('/usgs.mako')
        # or, return a response
        return 'Hello World'
    def overview(self):
        return render('/overview.html')
