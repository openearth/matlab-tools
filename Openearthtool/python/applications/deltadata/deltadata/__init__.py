import os
from pyramid.config import Configurator
import pyramid.mako_templating
_ROOT = os.path.abspath(os.path.dirname(__file__))
def get_data(path):
    return os.path.join(_ROOT, 'data', path)
from pyramid.session import UnencryptedCookieSessionFactoryConfig

my_session_factory = UnencryptedCookieSessionFactoryConfig('itsaseekreet')

def main(global_config, **settings):
    """ This function returns a Pyramid WSGI application.
    """
    config = Configurator(settings=settings, session_factory = my_session_factory)
    config.add_renderer(".html", "pyramid.mako_templating.renderer_factory")
    config.add_static_view('static', 'static', cache_max_age=3600)
    config.add_route('home', '/')
    config.add_route('view', '/view/*traverse')
    config.add_route('action', '/action/*traverse')
    config.scan()
    return config.make_wsgi_app()
