import tempfile 
import logging
import os

from threading import Lock
from pylons import request, response, session, tmpl_context as c, url
from pylons.controllers.util import abort, redirect
from pylons.decorators import jsonify
from paste.fileapp import FileApp
from os.path import basename

import numpy as np

from openearthtest.lib.base import BaseController, render


log = logging.getLogger(__name__)

from openearthtest.model import getmlab  #,getinterpolatedata
mlab = getmlab()
mlablock = Lock()

class TransformController(BaseController):
    
    def transform(self):
        v1,v2,v3,v4,v5,v6 = [request.params[x] for x in ['v1','v2','v3','v4','v5','v6']]
        v1 = str(v1)
        v2 = str(v2)
        v3 = str(v3)
        v4 = str(v4)
        v5 = float(v5)
        v6 = float(v6)
        #print "hallo"
        mlab.addpath(mlab.genpath('matlab'))
        filename = mlab.WaveTransformationTable(v1,v2,v3,v4,v5,v6)
        #print "tot ziens"
        #print filename
        f1 = filename + '.txt'
        f2 = filename + '_waverose.pdf'
        f3 = filename + '_timeseries.pdf'
        headers1 = [('Content-Disposition', 'filename=%s' % (f2))]
        fapp1 = FileApp(f2, headers1, content_type='application/pdf')
        return fapp1(request.environ, self.start_response)
        
        
        #print filename[1]
        ##filename = 'd:/Repositories/oetools/python/applications/openearthtest/openearthtest/public/matlab/output/sch15a_timeseries.pdf'
        ##response.headers['content-type'] = 'application/pdf'
        ##response.headers['Content-Disposition'] = 'attachment; filename='+fname
        ##response.headers['content-type'] = 'text/html'
        #data = open(filenam, 'rb').read()
        ##response.headers['content-type'] = 'image/png'
        ##return data
        
        ##headers0 = [('Content-Disposition', 'filename=%s' % (filename[0]))]
        
        ##headers2 = [('Content-Disposition', 'filename=%s' % (filename[2]))]
        ##print "tot ziens"
        ##fapp0 = FileApp(filename[0], headers0, content_type='application/pdf')
        
        ###fapp2 = FileApp(filename[2], headers2, content_type='application/pdf')
        ##print fapp
             
        ##return FileApp(filename, headers, content_type='application/octetstream')
        