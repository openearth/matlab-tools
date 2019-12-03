import logging
import tempfile
import subprocess

from pyramid.view import view_config
from pyramid_handlers import action
from pyramid_mailer import get_mailer
from pyramid_mailer.message import Message
from pyramid_mailer.message import Attachment

import models

from . import get_data
log = logging.getLogger(__name__)
@view_config(route_name='home',renderer="index.html")
def index(request):
    # Do some logging.
    log.debug("testing logging; entered Main.index()")
    # Return a dict of template variables for the renderer.
    return {"project":"Safety layar"}
@view_config(renderer="index.html", route_name='action', name='postscreenshot')
def postscreenshot():
    """store uploaded screenshots in the data dir"""
    settings = request.registry.settings
    fname = tempfile.mktemp(dir=settings.get('screenshot.dir'))
    f = open(fname, 'wb')
    f.write(request.POST['screenshot'].file.read())
    f.close()
    return {"project":__name__}
@view_config(renderer="index.html", route_name='action', name='mailscreenshot')
def mailscreenshot(request):
    """mail uploaded screenshot to an email address"""
    mailer = get_mailer(request)
    message = Message(subject="Safety picture",
              recipients=["f.baart@gmail.com"],
              body="hello, Fedor")
    # just pass on the uploaded file.... (assuming it's a jpeg, no time to check)
    attachment = Attachment("photo.jpg", "image/jpg",
                            request.POST['screenshot'].file)
    message.attach(attachment)
    mailer.send(message)            # or send it to a queue
    return {"project": __name__}
@view_config(renderer='json', route_name='view')
def getpois(request):
    result = {}
    p = request.params
    log.debug(request.params)
    result.update(dict(
        layer=p.get("layerName"),
        hotspots=[],
        errorCode=0,
        errorString="ok",
        radius=p.get("radius", 1000),
        refreshInterval=20,
        refreshDistance=50,
        fullRefresh=True,
        showMessage="Please upload your pictures using: Layer action -> screenshot -> use -> share -> post a screenshot",
        deletedHotspots=[]

        ))
    settings = request.registry.settings
    breach = models.Breach(get_data('year_2008extra.nc'))
    lat = float(request.params.get('lat','0'))
    lon = float(request.params.get('lon','0'))
    radius = float(request.params.get('radius','0'))
    d = breach.intersect2(lat,lon,radius)
    for i, (lat, lon, p) in enumerate(zip(d['lat'], d['lon'], d['p'])):
        result["hotspots"].append(dict(
            id=i,
            distance=0,
            title="Probability %s" % (p,), 
            type=0,
            lat=lat*1e6,
            lon=lon*1e6,
            actions=[]
        ))


    return result
    
    
        
