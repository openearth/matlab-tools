import logging
 
from pyramid_handlers import action
from pyramid_mailer import get_mailer
from pyramid_mailer.message import Message
from pyramid_mailer.message import Attachment

import layar.handlers.base as base
import layar.models as model
import tempfile
import subprocess
log = logging.getLogger(__name__)

class Main(base.Handler):
    @action(renderer="index.html")
    def index(self):
        # Do some logging.
        log.debug("testing logging; entered Main.index()")
        # Return a dict of template variables for the renderer.
        return {"project":"Safety layar"}
    @action(renderer="index.html")
    def postscreenshot(self):
        """store uploaded screenshots in the data dir"""
        settings = self.request.registry.settings
        fname = tempfile.mktemp(dir=settings.get('screenshot.dir'))
        f = open(fname, 'wb')
        f.write(self.request.POST['screenshot'].file.read())
        f.close()
        return {"project":__name__}
    @action(renderer="index.html")
    def mailscreenshot(self):
        """mail uploaded screenshot to an email address"""
        mailer = get_mailer(request)
        message = Message(subject="Safety picture",
                  recipients=["f.baart@gmail.com"],
                  body="hello, Fedor")
        # just pass on the uploaded file.... (assuming it's a jpeg, no time to check)
        attachment = Attachment("photo.jpg", "image/jpg",
                                self.request.POST['screenshot'].file)
        message.attach(attachment)
        mailer.send(message)            # or send it to a queue
        return {"project": __name__}
    @action(renderer='json')
    def getpois(self):
        result = {}
        p = self.request.params
        log.debug(self.request.params)
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
        request = self.request
        settings = request.registry.settings
        breach = model.pbreach.Breach(f=settings.get('pbreach.file'))
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
    
    
        
