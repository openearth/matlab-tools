import tempfile 
import logging
import os

from threading import Lock
from pylons import request, response, session, tmpl_context as c, url
from pylons.controllers.util import abort, redirect
from pylons.decorators import jsonify

import numpy as np

from openearthtest.lib.base import BaseController, render


log = logging.getLogger(__name__)

from openearthtest.model import getmlab  #,getinterpolatedata
mlab = getmlab()
mlablock = Lock()

class MultitileController(BaseController):
    
    def multitile(self):
        v1,v2,c1,c2 = [request.params[x] for x in ['v1','v2','c1','c2']]
        vin = np.array([float(v1),float(v2)], dtype="double") 
        cin = np.array([float(c1),float(c2)], dtype="double")
        #kml = "d:\Repositories\oetools\python\applications\openearthtest\openearthtest\public\test.kml"
        kml = mlab.transect_multitile_years(vin,cin)
        response.ContentType = "application/kml" #of zoiets
	response.write(kml) # of zoiets
        return