# -*- coding: utf-8 -*-
"""
$Id: views.py 8447 2013-04-12 20:55:47Z heijer $
$Date: 2013-04-12 13:55:47 -0700 (Fri, 12 Apr 2013) $
$Author: heijer $
$Revision: 8447 $
$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/python/applications/KMLnourishment/kmlnourishment/views.py $
"""

from pyramid.view import view_config
from pyramid.response import Response
from kmlnourishment import models


@view_config(route_name='home', renderer='templates/mytemplate.pt')
def my_view(request):
    return {'project': 'KMLnourishment', 'kml': '/kml/0.kml'}

@view_config(route_name='kml')
def kml_view(request):
    code = request.matchdict['code']
    if code == '0':
        kmltxt = models.createkml_overview(code).kml()
    elif 'nourishment' in code:
        kmltxt = models.createkml_nourishment(int(code[-3:])).kml()
    response = Response(content_type='application/vnd.google-earth.kml+xml')
    response.text = kmltxt
        
    return response