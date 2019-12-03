import logging

from pylons import request, response, session, tmpl_context as c
from pylons.controllers.util import abort

from kmldap.lib.base import BaseController, render

log = logging.getLogger(__name__)

class DeltaresController(BaseController):

    def index(self):
        # Return a rendered template
        #return render('/deltares.mako')
        # or, return a response
        result = render('/deltares.html')
        return result
