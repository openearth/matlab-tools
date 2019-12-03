# -*- coding: utf-8 -*-
"""
$Id: server.py 8481 2013-04-22 04:23:19Z heijer $
$Date: 2013-04-21 21:23:19 -0700 (Sun, 21 Apr 2013) $
$Author: heijer $
$Revision: 8481 $
$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/python/applications/KMLtiler/server.py $
"""

import os
import logging
from kmltiler import models

from pyramid.config import Configurator
from pyramid.session import UnencryptedCookieSessionFactoryConfig
from pyramid.view import view_config
from pyramid.response import Response

from wsgiref.simple_server import make_server


logging.basicConfig()
log = logging.getLogger(__file__)

here = os.path.dirname(os.path.abspath(__file__))

@view_config(route_name='kml')
def kml(request):
    code = request.matchdict['code']
    kmltxt = models.code2kml(code).kml()
    response = Response(content_type='application/vnd.google-earth.kml+xml')
    response.text = kmltxt
    return response

@view_config(route_name='png')
def png(request):
    code = request.matchdict['code']
    stream = models.code2png(code)
    response = Response(content_type='image/png')
    response.app_iter = stream
    return response

if __name__ == '__main__':
    
    # configuration settings
    settings = {}
    settings['reload_all'] = True
    settings['debug_all'] = False
    # session factory
    session_factory = UnencryptedCookieSessionFactoryConfig('itsaseekreet')
    # configuration setup
    config = Configurator(settings=settings, session_factory=session_factory)
    # routes setup
    config.add_route('kml', '/{code}.kml')
    config.add_route('png', '/{code}.png')
    # static view setup
    config.add_static_view('static', os.path.join(here, 'static'))
    # scan for @view_config and @subscriber decorators
    config.scan()
    # serve app
    app = config.make_wsgi_app()
    server = make_server('0.0.0.0', 8080, app)
    server.serve_forever()
