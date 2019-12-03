from pyramid.view import view_config
from netCDF4 import Dataset
import script
import re
import os
import inspect
from pyramid.response import Response
import datetime


@view_config(route_name='home', renderer='templates/mytemplate.pt')
def my_view(request):
    return {'project': 'netCDFreadersguide', 'year': datetime.datetime.today().strftime('%Y')}


@view_config(route_name='checknc', renderer='jsonp')
def view_checknc(request):
    url = request.params.get('url', None)
    ds, status = open_nc(url)
    if status:
        ds.close()
        response = 'true'
    else:
        response = 'false'
    return response


@view_config(route_name='variables', renderer='jsonp')
def view_variables(request):
    url = request.params.get('url', None)

    ds, status = open_nc(url)
    variables = []
    if status:
        ds = Dataset(url)
        varnames = ds.variables.keys()

        for varname in varnames:
            variables.append({'name': varname,
                              'dimensions': ', '.join(ds.variables[varname].dimensions)})
        ds.close()

    return variables


@view_config(route_name='dimensions', renderer='jsonp')
def view_dimensions(request):
    url = request.params.get('url', None)
    variable = request.params.get('variable', None)
    format = request.params.get('format', u'list')

    ds, status = open_nc(url)
    if status:
        if variable is not None and variable in ds.variables.keys():
            keys = ds.variables[variable].dimensions
        else:
            keys = ds.dimensions.keys()
        dimensions = [{'name': key, 'length': ds.dimensions[key].__len__()} for key in keys]
        ds.close()
    else:
        dimensions = []

    return dimensions


@view_config(route_name='attributes', renderer='jsonp')
def view_attributes(request):
    url = request.params.get('url', None)
    variable = request.params.get('variable', None)

    ds = Dataset(url)
    if variable is not None and variable in ds.variables.keys():
        base = ds.variables[variable]
    else:
        base = ds
    attributes = [{key: str(getattr(base, key))} for key in base.ncattrs()]
    ds.close()

    return attributes


@view_config(route_name='script', renderer='string')
def view_script(request):
    lang = request.matchdict.get('language', 'python')
    url = request.params.get('url', None)
    download = request.params.get('download', False)
    keys = request.params.keys()
    print ','+','.join(keys)
    dimnames = [re.sub('^dim_', '', item) for item in keys if item.startswith('dim_')]
    print dimnames
    dims = {}
    for dimname in dimnames:
        dimval = request.params.get('dim_'+dimname, None)
        dims[dimname] = map(int, dimval.split(':'))
    variables = request.params.get('variables', '')
    if not hasattr(script, lang.capitalize()):
        return 'Warning: %s not supported'%lang
    S = getattr(script, lang.capitalize())(url=url, variables=variables, dimensions=dims)
    txt = S.write()
    return _download(txt, S.ext, request)


@view_config(route_name='languages', renderer='jsonp')
def view_languages(request):
    items = dir(script)
    def islang(s):
        obj = getattr(script, s)
        if inspect.isclass(obj) and hasattr(obj, '__islang__') and obj.__islang__:
            return True
        else:
            return False
    # TODO: ordering of languages
    languages = [{'value': item, 'label': getattr(script, item).__label__} for item in items if islang(item)]
    return languages


def open_nc(url):
    try:
        ds = Dataset(url)
        status = True
    except:
        ds = None
        status = False
    return ds, status


def _download(data, ext, request):
    if request.params.get('download', 'true'):
        url = request.params.get('url', 'netcdfreadersguide.nc')
        filename = 'ncread_' + re.sub('\.nc$', '', os.path.split(url)[-1]) + ext
        print filename
        return Response(body=data,
                        content_disposition='attachment; filename="%s"' % filename,
                        content_type='text/plain')
    else:
        return data