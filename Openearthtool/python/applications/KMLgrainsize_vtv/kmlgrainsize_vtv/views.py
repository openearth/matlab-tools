from pyramid.view import view_config
from pyramid.response import Response
import models
import io
import tempfile,os

@view_config(route_name='home', renderer='templates/mytemplate.pt')
def my_view(request):
    return {'project': 'KMLgrainsize_vtv'}

@view_config(route_name='cmapkmz')
def kmz(request):
    cmap = request.matchdict['cmap']
    kml = models.cmap2kml(cmap, kmz=True)
    cbfile = os.path.join(tempfile.gettempdir(), 'colorbar_%s.png'%cmap)
    kml.addfile(cbfile) # could return the relative file reference inside the kmz
    cmap = request.matchdict['cmap']
    models.cmap2png(cmap, cbfile)

    stream = io.BytesIO()
    kml.savekmz(stream, format=False)
    stream.seek(0)
    response = Response(content_type='application/vnd.google-earth.kmz')
    response.app_iter = stream
    return response

@view_config(route_name='kmz')
def mainkmz(request):
    kml = models.mainkml(kmz=True)
    
    stream = io.BytesIO()
    kml.savekmz(stream, format=False)
    stream.seek(0)
    response = Response(content_type='application/vnd.google-earth.kmz')
    response.app_iter = stream
    return response

@view_config(route_name='kml')
def mainkml(request):
    kmltxt = models.mainkml().kml()
    response = Response(content_type='application/vnd.google-earth.kml+xml')
    response.text = kmltxt
    return response

@view_config(route_name='cmapkml')
def kml(request):
    cmap = request.matchdict['cmap']
    kmltxt = models.cmap2kml(cmap).kml(format=False)
    response = Response(content_type='application/vnd.google-earth.kml+xml')
    response.text = kmltxt
    return response

@view_config(route_name='colorbar')
def colorbar(request):
    cmap = request.matchdict['cmap']
    stream = models.cmap2png(cmap, io.BytesIO())
    stream.seek(0)
    response = Response(content_type='image/png')
    response.app_iter = stream
    return response

#@view_config(route_name='icon')
#def icon(request):
#    cmap = request.matchdict['cmap']
#    stream = models.cmap2icon(cmap, io.BytesIO())
#    stream.seek(0)
#    response = Response(content_type='image/png')
#    response.app_iter = stream
#    return response