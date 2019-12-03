import tempfile 
import logging
import os
#import httplib
#import urllib
#from urlparse import urlparse

from pylons import request, response, session, tmpl_context as c, url
from pylons.controllers.util import abort, redirect
from pylons.decorators import jsonify

import numpy as np

from openearthtest.lib.base import BaseController, render


log = logging.getLogger(__name__)

from openearthtest.model import getmlab
mlab = getmlab()


class PlottimeseriesController(BaseController):

    def plot(self):
    	v1,v2,v3,v4 = [request.params[x] for x in ['v1','v2','v3','v4']]
	ncfile = str(v1.replace("'","")) #'http://opendap.deltares.nl:8080/thredds/dodsC/opendap/rijkswaterstaat/waterbase/sea_surface_height//id54-Q1.nc' 
        var = str(v2.replace("'","")) #'sea_surface_height' 
        tstart = str(v3.replace("'","")) #'20100403T235000'
        tstop = str(v4.replace("'","")) #'20100410T235000'       
        print str(v1)
        print str(v2)
        print str(v3)
        print str(v4)
	print ncfile
        print var
        print tstart
        print tstop      
        #fh, imagefile = tempfile.mkstemp(suffix='.png')
        #temp_str = "%r"%imagefile
        #imagefile = temp_str[1:-1]
        #os.close(fh)
        outputPng = mlab.PlotTimeSeries(ncfile,var,tstart,tstop)
        data = open(outputPng, 'rb').read()
        #data = open(imagefile, 'rb').read()
        #os.unlink(imagefile)
        response.headers['content-type'] = 'image/png'
        return data