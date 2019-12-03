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

class InterpolateController(BaseController):
    
    def interpolate(self):
        n1,n2,v1,v2,c1,c2 = [request.params[x] for x in ['n1','n2','v1','v2','c1','c2']]
        vin = np.array([float(v1),float(v2)], dtype="double") 
        cin = np.array([float(c1),float(c2)], dtype="double")
        kmlfile = 'kml'
        ncfile = str(n1)
        ncvariable = str(n2)
        #fh, imagefile = tempfile.mkstemp(suffix='.png')
        #temp_str = "%r"%imagefile
        #imagefile = temp_str[1:-1]
        #os.close(fh)
        #lat, lon, z = getinterpolatedata()
        #mlablock.acquire()
        #output = mlab.InterpolateToLine(kmlfile,imagefile,cin,vin)
        outputPng = mlab.InterpolateToLine(ncfile,ncvariable,cin,vin) #,image
        #mlablock.release()
        data = open(outputPng, 'rb').read()
        #os.unlink(imagefile)
        response.headers['content-type'] = 'image/png'
        return data