from pyramid.config import Configurator


def main(global_config, **settings):
    """ This function returns a Pyramid WSGI application.
    """
    config = Configurator(settings=settings)
    config.include('pyramid_mako')
    config.include('pyramid_beaker')
    config.add_static_view('static', 'static', cache_max_age=3600)
    config.add_route('main', '/')
    config.add_route('map', '/map')
    config.add_route('home', '/home')
    config.add_route('plot', '/plot')
    config.add_route('data', '/data')
    config.add_route('psmsl', '/psmsl*params')
    config.add_route('rscript', '/rscript')
    config.add_route('description', '/description')

    # Add subscribers for adding translators to the request
    config.add_subscriber('sealevel.subscribers.add_renderer_globals',
                          'pyramid.events.BeforeRender')
    config.add_subscriber('sealevel.subscribers.add_localizer',
                          'pyramid.events.NewRequest')
    # Add the translations
    config.add_translation_dirs('sealevel:locale/')

    config.scan()
    return config.make_wsgi_app()
