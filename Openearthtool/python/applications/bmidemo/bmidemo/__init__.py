from pyramid.config import Configurator
from pyramid.response import Response

class BinaryRenderer:
    def __init__(self, info):
        """ Constructor: info will be an object having the
        following attributes: name (the renderer name), package
        (the package that was 'current' at the time the
        renderer was registered), type (the renderer type
        name), registry (the current application registry) and
        settings (the deployment settings dictionary). """


    def __call__(self, value, system):
        """ Call the renderer implementation with the value
        and the system value passed in as arguments and return
        the result (a string or unicode object).  The value is
        the return value of a view.  The system value is a
        dictionary containing available system values
        (e.g. view, context, and request). """
        # assuming value is a numpy array
        bytes = value.tostring()
        return bytes


def main(global_config, **settings):
    """ This function returns a Pyramid WSGI application.
    """
    config = Configurator(settings=settings)
    config.add_static_view('assets', 'assets', cache_max_age=0)
    config.add_route('home', '/')
    config.add_route('streamlines', '/streamlines')
    config.add_route('ge', '/ge')
    # config.add_route('get', '/model/{run}/variable/{variable}')
    # config.add_route('grid', '/model/{run}/grid')
    # config.add_route('set', '/model/{run}/variable/{variable}/set/{cell}')
    config.add_renderer(name='binary', factory='bmidemo.BinaryRenderer')
    config.scan()
    return config.make_wsgi_app()
