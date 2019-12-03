from pyramid.config import Configurator
from pyramid.renderers import JSON, JSONP


def main(global_config, **settings):
    """ This function returns a Pyramid WSGI application.
    """

    config = Configurator(settings=settings)
    # renderers
    config.add_renderer('jsonp', JSONP(param_name='callback'))
    config.include('pyramid_chameleon')
    config.add_static_view('static', 'static', cache_max_age=3600)
    config.add_route('home', '/')
    config.add_route('attributes', '/json/attributes')
    config.add_route('dimensions', '/json/dimensions')
    config.add_route('variables', '/json/variables')
    config.add_route('checknc', '/json/checknc')
    config.add_route('languages', '/json/languages')
    config.add_route('script', '/script/{language}')
    config.scan()
    return config.make_wsgi_app()
