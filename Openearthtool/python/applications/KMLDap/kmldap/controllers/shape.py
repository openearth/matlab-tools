import logging

from pylons import request, response, session, tmpl_context as c
from pylons.controllers.util import abort

from kmldap.lib.base import BaseController, render

log = logging.getLogger(__name__)

import shapely.geometry
import numpy
class ShapeController(BaseController):

    def index(self):
        # Return a rendered template
        #return render('/shape.mako')
        # or, return a response
        poly = shapely.geometry.Polygon(numpy.asarray([[0,0], [0,1], [1,1], [1,0], [0,0.0]]))
        poly.intersection(poly)
        return 'the area of this polygon is %s' % poly.area
