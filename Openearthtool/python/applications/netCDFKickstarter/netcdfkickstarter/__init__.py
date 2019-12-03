from pyramid.config import Configurator
from pyramid.renderers import JSON, JSONP
from pyramid.httpexceptions import HTTPNotFound

def not_found(request):
    return HTTPNotFound()

def main(global_config, **settings):
    """ This function returns a Pyramid WSGI application.
    """

    config = Configurator(settings=settings)

    # renderers
    config.add_renderer('jsonp', JSONP(param_name='callback'))
    config.include('pyramid_chameleon')

    config.add_static_view('static', 'static', cache_max_age=3600)
    config.add_route('home', '/json/templates/')
    config.add_route('categories', '/json/categories/')
    config.add_route('standard_names', '/json/standardnames/')
    config.add_route('coordinatesystems', '/json/coordinatesystems/')
    config.add_route('variables', '/json/variables/{template}')
    config.add_route('templates', '/json/templates/{template}')
    config.add_route('netcdf', '/netcdf/{template}')
    config.add_route('cdl','/cdl/{template}')
    config.add_route('ncml','/ncml/{template}')
    config.add_route('python','/python/{template}')
    config.add_route('matlab','/matlab/{template}')
    config.add_route('rncdf4','/rncdf4/{template}')
    config.add_route('c','/c/{template}')
    config.add_route('java','/java/{template}')
    config.add_route('f77','/f77/{template}')
    config.add_route('interface', '/')
#    config.add_route('interface2', '/i')
    config.add_notfound_view(not_found, append_slash=True)
    config.scan()
    return config.make_wsgi_app()
