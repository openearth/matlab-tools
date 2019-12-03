from pyramid.view import view_config
from pyramid.response import Response
import os
import re
import io
import json
import pandas
import subprocess
import tempfile
import urllib2
import netCDF4
from datetime import datetime
from lxml import etree
import shutil

from scripts import Script, Python, Matlab, RNcdf4

#
# ROUTES
#

@view_config(route_name='home', renderer='jsonp')
def view_index(request):
    return cdl_index()

@view_config(route_name='templates', renderer='jsonp')
def view_template(request):
    category = request.params.get('category',None)
    tmpl = request.matchdict.get('template',None)
    cdl = cdl_template(tmpl)
    if not category == None and 'category' in cdl.columns:
        cdl = cdl[cdl['category']==category]
    return _serializable(cdl)

@view_config(route_name='variables', renderer='jsonp')
def view_variables(request):
    cdl = create_cdl(request)
    return re.findall('\w+(?=:long_name =)', cdl)

@view_config(route_name='cdl', renderer='string')
def view_cdl(request):
    cdl = create_cdl(request)
    return _download(cdl, '.cdl', request)

@view_config(route_name='python', renderer='string')
def view_python(request):
    cdl = create_cdl(request)
    filename = request.params.get('filename',None)
    py = create_script(cdl, Python(filename))
    return _download(py, '.py', request)

@view_config(route_name='c', renderer='string')
def view_c(request):
    cdl = create_cdl(request)
    filename = request.params.get('filename', None)
    c = create_ncgen_script(cdl, 'C', filename=filename)
    return _download(c, '.c', request)

@view_config(route_name='java', renderer='string')
def view_java(request):
    cdl = create_cdl(request)
    filename = request.params.get('filename', None)
    c = create_ncgen_script(cdl, 'java', filename=filename)
    return _download(c, '.java', request)

@view_config(route_name='f77', renderer='string')
def view_java(request):
    cdl = create_cdl(request)
    filename = request.params.get('filename', None)
    c = create_ncgen_script(cdl, 'f77', filename=filename)
    return _download(c, '.F77', request)

@view_config(route_name='matlab', renderer='string')
def view_matlabnew(request):
    cdl = create_cdl(request)
    filename = request.params.get('filename',None)
    mat = create_script(cdl, Matlab(filename))
    return _download(mat, '.m', request)

@view_config(route_name='rncdf4', renderer='string')
def view_rncdf4(request):
    cdl = create_cdl(request)
    filename = request.params.get('filename',None)
    r = create_script(cdl, RNcdf4(filename))
    return _download(r, '.R', request)

@view_config(route_name='ncml', renderer='string')
def view_ncml(request):
    cdl = create_cdl(request)
    ncml = create_ncml(cdl)
    return _download(ncml, '.xml', request)

@view_config(route_name='netcdf', renderer='string')
def view_netcdf(request):
    cdl = create_cdl(request)
    filename = request.params.get('filename',None)
    nc = create_netcdf(cdl)
    if nc is not None:
        return Response(body=nc,
                        content_disposition='attachment; filename="%s"' % filename,
                        content_type='application/octet-stream')
    else:
        return 'ERROR: generating netCDF file failed'

@view_config(route_name='categories', renderer='jsonp')
def view_categories(request):
    markers = cdl_markers()
    categories = list(markers['category'].unique())
    return filter(lambda x: x not in ('sys','crs'), categories)

@view_config(route_name='standard_names', renderer='jsonp')
def view_standard_names(request):
    return standard_names(request.params.get('search',None),
                          request.params.get('name',None))

@view_config(route_name='coordinatesystems', renderer='jsonp')
def view_coordinate_systems(request):
    return coordinate_systems()

@view_config(route_name='interface', renderer='templates/interface2.pt')
def view_interface(request):
    return {}

#@view_config(route_name='interface2', renderer='templates/interface2.pt')
#def view_interface2(request):
#    return {}

#
# CDL PARSING
#

def cdl_index():
    cdl_path = os.path.join(os.path.dirname(__file__),'cdl') # FIXME
    cdl_templates = []
    cdl_descriptions = []

    json_file = os.path.join(os.path.dirname(__file__), 'cdl', 'templates.json') # FIXME
    if os.path.exists(json_file):
        f = open(json_file,'r')
        markers = json.load(f)
        f.close()
        df = pandas.DataFrame(markers)
        tmpllist = list(df['template'])
    else:
        raise ValueError('File not found [%s]' % json_file)

    if os.path.exists(cdl_path):
        cdl_templates = [re.sub('.cdl$', '', f) for f in os.listdir(cdl_path) if f.endswith('.cdl')]
        cdl_templates.sort()
        for cdl_tmpl in cdl_templates:
            if cdl_tmpl in tmpllist:
                idx = tmpllist.index(cdl_tmpl)
                cdl_descr = df['description'][idx]
            else:
                cdl_descr = ''
            cdl_descriptions.append(cdl_descr)

    return zip(cdl_templates,cdl_descriptions)

def cdl_markers():
    json_file = os.path.join(os.path.dirname(__file__),'cdl','markers.json') # FIXME

    if os.path.exists(json_file):
        f = open(json_file,'r')
        markers = json.load(f)
        f.close()

        return pandas.DataFrame(markers)
    else:
        raise ValueError('File not found [%s]' % json_file)

def cdl_template(cdl_file):
    cdl = _read_cdl_file(cdl_file)

    m = zip(*re.findall('\$\{\{(\w+)\.(\w+)\}\}',cdl))
    if len(m) > 0:
        df = pandas.DataFrame(m,index={'category','key'}).transpose().drop_duplicates()
        df = pandas.merge(cdl_markers(),df,how='inner')

        df['value'] = None

        return df
    else:
        return pandas.DataFrame()

#
# THIRD PARTY DATA
#

def standard_names(search=None, name=None):
    #url = 'http://cf-pcmdi.llnl.gov/documents/cf-standard-names/standard-name-table/25/cf-standard-name-table.xml' # FIXME
    url = 'http://cfconventions.org/Data/cf-standard-names/27/src/cf-standard-name-table.xml' # FIXME
    local_file = os.path.join(os.path.dirname(__file__),'cdl','cf-standard-name-table.json')

    if os.path.exists(local_file):
        f = open(local_file,'r')
        standard_names = json.load(f)
        f.close()
    else:
        f = urllib2.urlopen(url)
        xml = etree.XML(f.read())
        f.close()

        standard_names = [{'standard_name':e.attrib['id'],
                           'units':e.find('.//canonical_units').text,
                           'description':e.find('.//description').text}
                          for e in xml.findall('.//entry')]

        # save to local file
        f = open(local_file,'w')
        json.dump(standard_names,f)
        f.close()

    if not name == None:
        standard_names = [x for x in standard_names if x['standard_name'] == name]
    elif not search == None:
        search = re.sub('\s+','.+',search)
        standard_names = [x for x in standard_names if re.search(search,x['standard_name'])]

    return standard_names

def coordinate_systems():
    json_file = os.path.join(os.path.dirname(__file__),'cdl','coordinatesystems.json')

    if os.path.exists(json_file):
        f = open(json_file,'r')
        coordinate_systems = json.load(f)
        f.close()

        return coordinate_systems
    else:
        return None

#
# MARKER FUNCTIONS
#

def replace_markers(cdl_file, values):
    cdl = _read_cdl_file(cdl_file)
    markers = cdl_template(cdl_file)
    if 'category' in markers.columns:
        for cat in markers['category'].unique():

            n = max(1,len(values[cat]))

            cdl_part = re.findall('\$\{\{%s\}\}(.+)\$\{\{%s\}\}' % (cat,cat),
                                  cdl, flags=re.DOTALL)

            if len(cdl_part) > 0:
                cdl_parts = [cdl_part[0] for i in range(n)]
            else:
                cdl_parts = [cdl]

            for i, marker in markers[markers['category']==cat].iterrows():
                key = marker['key']

                for idx in range(n):
                    if len(values[cat]) > idx:
                        if values[cat][idx].has_key(key):
                            val = values[cat][idx][key]
                        else:
                            val = marker['default']
                    else:
                        val = marker['default']

                    val = replace_system_markers(cat,key,val)

                    s = '${{%s.%s}}' % (cat,key)
                    cdl_parts[idx] = cdl_parts[idx].replace(s,str(val))

            if len(cdl_part) > 0:
                cdl = re.sub('\$\{\{%s\}\}.+\$\{\{%s\}\}' % (cat,cat),
                             ''.join(cdl_parts),
                             cdl, flags=re.DOTALL)
            else:
                cdl = cdl_parts[0]

    cdl = re.sub('\$\{\{.+\}\}','0',cdl);

    return cdl

def replace_system_markers(cat,key,val):
    if cat == 'dim':
        if ((type(val) is str or type(val) is unicode) and
            len(val) == 0) or val == None or val <= 0:
            val = 'UNLIMITED'
    elif cat == 'sys':
        if key == 'date_created' or \
           key == 'date_modified' or \
           key == 'date_issued':
            val = datetime.strftime(datetime.utcnow(),
                                    '%Y-%m-%dT%H:%MZ')
        elif key == 'metadata_link':
            val = ''
        else:
            val = '0'

    return val

#
# FILE GENERATION
#

def create_cdl(request):
    tmpl = request.matchdict.get('template',None)

    markers = {x:[] for x in cdl_markers()['category'].unique()}
    for k, v in request.params.iteritems():
        if re.match('^m\[(.+)\.(.+)\]$', k):
            cat, key = re.findall('^m\[(.+)\.(.+)\]$',k)[0]
            idx = len(markers[cat])
            for i in range(len(markers[cat])):
                if not markers[cat][i].has_key(key):
                    idx = i
                    break

            if len(markers[cat]) <= idx:
                markers[cat].append({})

            markers[cat][idx][key] = v

    # add coordinate reference system
    epsg = request.params.get('epsg_code', 'EPSG:28992')
    markers['crs'] = [x for x in coordinate_systems() if x['epsg_code'] == epsg]

    cdl = replace_markers(tmpl,markers)

    return cdl

def create_netcdf(cdl):
    ncfile,_ = _write_nc_file(cdl)

    if not ncfile == None:
        f = open(ncfile,'rb');
        nc = f.read()
        f.close()

        os.remove(ncfile)

        return nc
    else:
        return None

def create_script(cdl, obj):
    varnames = re.findall('\w+(?=:long_name =)', cdl)
    dupl = list(set([x for x in varnames if varnames.count(x) > 1]))
    ncfile,mess = _write_nc_file(cdl)

    if not mess is None:
        obj._add_line(mess)
        return obj.get_contents()

    obj.add_header()

    if not ncfile == None:
        with netCDF4.Dataset(ncfile,'r') as nc:
            for part in obj.order:
                if part == 'create':
                    obj.add_cell('CREATE A NEW FILE')
                    obj.add_create()
                    obj.add_empty()
                elif part == 'dimensions':
                    obj.add_cell('ADD DIMENSIONS')
                    for dim,val in nc.dimensions.iteritems():
                        obj.add_dimension(dim, len(val))
                    obj.add_dimensionfunction()
                    obj.add_empty()
                elif part == 'attributes_global':
                    obj.add_cell('ADD GLOBAL ATTRIBUTES')
                    obj.add_comment('see http://www.unidata.ucar.edu/software/thredds/current/netcdf-java/formats/DataDiscoveryAttConvention.html')
                    for att in nc.ncattrs():
                        obj.add_attribute(att, nc.getncattr(att))
                    obj.add_empty()
                elif part == 'variables':
                    obj.add_cell('ADD VARIABLES')
                    for var,val in nc.variables.iteritems():
                        obj.add_variable(var, str(val.dtype), val.dimensions)
                        for att in val.ncattrs():
                            # Skip virtual attributes.
                            if not att.startswith('_'):
                                obj.add_attribute(att, val.getncattr(att), var)
                        obj.add_empty()
                elif part == 'data':
                    obj.add_cell('ADD DATA')

        os.remove(ncfile)

    obj.add_footer()

    return obj.get_contents()

def create_ncml(cdl):
    ncfile,_ = _write_nc_file(cdl, nc_format='classic')

    if not ncfile == None:
        call = ['ncdump','-x',ncfile]
        p = subprocess.Popen(call, stdout=subprocess.PIPE)
        ncml, err = p.communicate()

        os.remove(ncfile)

        return ncml
    else:
        return None


def create_ncgen_script(cdl, output_language='C', filename=None):

    # Write cdl file.
    _, tmpdir = tempfile.mkstemp()
    # remove temporary file "tmpdir"
    os.remove(tmpdir)
    # create a temporary directory with the name of the just removed file
    os.mkdir(tmpdir)
    # write the cdl file inside this temporary directory
    tmpfile = os.path.join(tmpdir, filename)
    with open(tmpfile, 'w') as f:
        f.write(cdl)

    # Convert cdl to script file.
    cmd = ['ncgen', '-l', output_language, tmpfile]
    p = subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    output, msg = p.communicate()
    if p.returncode > 0:
        output = "ERROR OCCURRED, the output language %s does not work for the selected template.\n\n%s" \
                 % (output_language, msg)

    shutil.rmtree(tmpdir)

    return output


#
# PRIVATE FUNCTIONS
#

def _read_cdl_file(cdl_file):
    cdl_path = os.path.join(os.path.dirname(__file__),'cdl') # FIXME
    cdl_file = os.path.join(cdl_path, cdl_file)
    if os.path.exists(cdl_file):
        f = open(cdl_file,'r')
        cdl = f.read()
        f.close()

        return cdl
    else:
        raise ValueError('File not found [%s]' % cdl_file)

def _write_nc_file(cdl, nc_format='netCDF-4'):
    varnames = re.findall('\w+(?=:long_name =)', cdl)
    dupl = list(set([x for x in varnames if varnames.count(x) > 1]))
    if not dupl == []:
        mess = 'WARNING: netcdf cannot be created because of duplicate variable(s): %s'%', '.join(dupl)
    else:
        mess = None

    # Write cdl file.
    f, tmpfile = tempfile.mkstemp()
    f = open(tmpfile, 'w')
    f.write(cdl)
    f.close()

    # Convert cdl to nc file.
    cmd = ['ncgen', '-k', nc_format, '-o', '%s.nc' % tmpfile, tmpfile]
    subprocess.call(cmd)

    # Remove cdl file.
    os.remove(tmpfile)

    ncfile = '%s.nc' % tmpfile
    if os.path.exists(ncfile):
        return ncfile,mess
    else:
        return None,mess

def _download(data, ext, request):
    if bool(int(request.params.get('download','0'))):
        filename = request.params.get('filename','kickstarter')
        filename = re.sub('\.nc$','',filename) + ext
        return Response(body=data,
                        content_disposition='attachment; filename="%s"' % filename,
                        content_type='text/plain')
    else:
        return data

def _serializable(v):
    if type(v) is pandas.DataFrame:
        s = []
        for i, item in v.iterrows():
            s.append(item.to_dict())
    else:
        raise ValueError('Unknown data type [%s]' % type(v))

    return s
