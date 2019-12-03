from pyramid.view import view_config
from pyramid.response import Response

import read_netcdf_uham
import read_netcdf
import read_postgis
import plots
import make_kml

@view_config(route_name='home', renderer='templates/mytemplate.pt')
def my_view(request):
    return {'project': 'vectors'}


@view_config(route_name='species')
def species_view(request):
    #print 'wat is de request',request
    aspecies = str(request.matchdict['species'])
    statsq = str(request.matchdict['statsq'])
    poly = read_postgis.get_ices_polygon(statsq)
    df = read_netcdf.species(apoly=poly, aspecies=aspecies)
    dfu = read_netcdf_uham.species(apoly=poly, aspecies=aspecies)
    dfpg = read_postgis.query_ices(aspecies=aspecies,statsq=statsq)
    labels = ['Delwaq model results','Ecoham model results']
    f = plots.plot_ts_nc_pgm([df,dfu],labels, dfpg,statsq, aspecies, read_netcdf.delwaq_species())
    response = Response(content_type='image/png')
    response.app_iter = f
    return response

@view_config(route_name='kmlspecies')
def kml_species_view(request):
    statsq = str(request.matchdict['statsq'])
    aspecies = str(request.matchdict['species'])
    df2 = read_postgis.get_points_in_ices(statsq)
    # retrieve the kmz of points within the ICES square
    kml = make_kml.pts_ices(df2, statsq)
    response = Response(content_type='application/vnd.google-earth.kml+xml')
    response.text = kml
    return response

@view_config(route_name='kml')
def kml_view(request):
    df = read_postgis.get_ices_squares()
    kml = make_kml.ices(df)
    response = Response(content_type='application/vnd.google-earth.kml+xml')
    response.text = kml
    return response
