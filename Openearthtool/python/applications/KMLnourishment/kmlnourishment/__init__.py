# -*- coding: utf-8 -*-
"""
$Id: __init__.py 8439 2013-04-12 10:40:43Z heijer $
$Date: 2013-04-12 03:40:43 -0700 (Fri, 12 Apr 2013) $
$Author: heijer $
$Revision: 8439 $
$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/python/applications/KMLnourishment/kmlnourishment/__init__.py $
"""

from pyramid.config import Configurator


def main(global_config, **settings):
    """ This function returns a Pyramid WSGI application.
    """
    config = Configurator(settings=settings)
    config.add_static_view('static', 'static', cache_max_age=3600)
    config.add_route('home', '/')
    config.add_route('kml', '/kml/{code}.kml')
    config.scan()
    return config.make_wsgi_app()
