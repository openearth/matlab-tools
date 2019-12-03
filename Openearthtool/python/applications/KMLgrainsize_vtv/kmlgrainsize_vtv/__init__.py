from pyramid.config import Configurator


def main(global_config, **settings):
    """ This function returns a Pyramid WSGI application.
    """
    config = Configurator(settings=settings)
    config.add_static_view('static', 'static', cache_max_age=3600)
    config.add_static_view(name='http://localhost:6543/static',
                       path='kmlgrainsize_vtv:static')
    config.add_route('home', '/')
    config.add_route('cmapkml', '/grainsize_{cmap}.kml')
    config.add_route('cmapkmz', '/grainsize_{cmap}.kmz')
    config.add_route('kml', '/grainsize.kml')
    config.add_route('kmz', '/grainsize.kmz')
    config.add_route('colorbar', '/colorbar_{cmap}.png')
#    config.add_route('icon', '/icon_{cmap}.png')
    config.scan()
    return config.make_wsgi_app()
