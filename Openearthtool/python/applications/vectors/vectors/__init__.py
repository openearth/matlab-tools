from pyramid.config import Configurator


def main(global_config, **settings):
    """ This function returns a Pyramid WSGI application.
    """
    config = Configurator(settings=settings)
    config.add_static_view('static', 'static', cache_max_age=3600)
    config.add_route('home', '/')
    config.add_route('kml', '/kml')
    config.add_route('kmlspecies','/kml/{species}/{statsq}')
    config.add_route('species','/species/{species}/{statsq}')
    config.scan()
    return config.make_wsgi_app()
