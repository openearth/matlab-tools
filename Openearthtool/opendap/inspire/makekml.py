#!/usr/bin/env python
from lxml.etree import ElementTree, dump
import mx.DateTime
import cPickle
# lookup all xml files under the current directory and plot a kml
import os.path
import copy
DATADIR = os.path.expanduser("/Users/fedorbaart/opendap/openearth") # /Volumes/OSXDATA/Open
ns = {'gmd':'http://www.isotc211.org/2005/gmd',
      'gco':'http://www.isotc211.org/2005/gco',
      'gml':'http://www.opengis.net/gml'}
xpaths = {
    'Title': '//gmd:citation//gmd:title',
    'Owner email': '''//gmd:CI_RoleCode[@codeListValue='owner']/../..//gmd:electronicMailAddress''',
    'Owner organization': '''//gmd:CI_RoleCode[@codeListValue='owner']/../..//gmd:organisationName''',
    'Author email': '''//gmd:CI_RoleCode[@codeListValue='author']/../..//gmd:electronicMailAddress''',
    'Author organization': '''//gmd:CI_RoleCode[@codeListValue='author']/../..//gmd:organisationName''',
    'Contact email': '''//gmd:CI_RoleCode[@codeListValue='pointOfContact']/../..//gmd:electronicMailAddress''',
    'Contact organization': '''//gmd:CI_RoleCode[@codeListValue='pointOfContact']/../..//gmd:organisationName''',
    'URL in inspire file': '//gmd:distributionInfo//gmd:URL',
    'Abstract': '//gmd:abstract',
    'EastBoundLongitude': '//gmd:extent//gmd:eastBoundLongitude',
    'WestBoundLongitude': '//gmd:extent//gmd:westBoundLongitude',
    'SouthBoundLatitude': '//gmd:extent//gmd:southBoundLatitude',
    'NorthBoundLatitude': '//gmd:extent//gmd:northBoundLatitude',
    'Start time': '//gmd:extent/gml:TimePeriod//gml:beginPosition',
    'End time': '//gmd:extent/gml:TimePeriod//gml:endPosition',
    'Lineage': '//gmd:dataQualityInfo//gmd:lineage',
    'Other constraints': '//gmd:resourceConstraints//gmd:otherConstraints',
    'Access constraints': '//gmd:resourceConstraints//gmd:accessConstraints',
    'Legal constraints': '//gmd:resourceConstraints//gmd:useLimitation',
    'Resolution': '//gmd:spatialResolution//gmd:distance',
    'Resolution unit': '//gmd:spatialResolution//gmd:distance//@uom',
    'Topic': '//gmd:topicCategory',
    'Keywords': '//gmd:keyword'

    }


def gettext(xml, xpath):
    # bit cryptic, just collect all text
    import string
    textelements = []
    for element in xml.xpath(xpath,namespaces=ns):
        if isinstance(element, str):
            textelements.append(element)
        else:
            textelements.extend(x.strip() for x in element.itertext())
    text = u" ".join(textelements)
    return text

def getinfo(filename, xml):
    info = {}
    for name, xpath in xpaths.items():
        info[name] = gettext(xml, xpath)
    return info
                    

def getcoordinates(info):
    """update the coordinates in a info dictionary"""
    # create a new empty dictionary
    result = {}
    
    # spatial coordinates
    north = info.get('NorthBoundLatitude', '').split()
    south = info.get('SouthBoundLatitude', '').split()
    east = info.get('EastBoundLongitude', '').split()
    west = info.get('WestBoundLongitude', '').split()
    assert len(north) == len(south) == len(east) == len(west), "Found irregalur coordinates"
    coordinates = []
    for i in range(len(north)):
        # construct polygon
        coordinates.append(",".join([east[i], north[i], "0"]))
        coordinates.append(",".join([east[i], south[i], "0"]))
        coordinates.append(",".join([west[i], south[i], "0"]))
        coordinates.append(",".join([west[i], north[i], "0"]))
        coordinates.append(",".join([east[i], north[i], "0"]))
    if coordinates:
        result["Coordinates"] = "\n".join(coordinates)
    

    timespans = []
    starttime = info.get('Start time',"").split()
    endtime = info.get('End time', "").split()
    assert len(starttime) == len(endtime)
    for i in range(len(starttime)):
        try:
            # try to cast to a year first if not be a bit less restrictive
            start = mx.DateTime.strptime(starttime[i], "%Y")
        except ValueError:
            start = mx.DateTime.DateTimeFrom(starttime[i])
        try:
            # try to cast to a year first if not be a bit less restrictive
            end = mx.DateTime.strptime(endtime[i], "%y")
        except ValueError:
            end = mx.DateTime.DateTimeFrom(endtime[i])
        timespans.append((start,end))
    result['Time spans'] = timespans
    return result

def inspireinfo():
    """create a list of inspire files"""
    for root, dirs, files in os.walk(DATADIR):
        print 'entering', root
        if 'geogegevens' in root:
            continue
        if '.svn' in dirs:
            dirs.remove('.svn')
        for file in files:
            if file.startswith('.#'): #skip locked files from emacs
                continue
            if file.lower().endswith("xml"): #extension is xml?
                filename = os.path.join(root,file)
                xml = ElementTree(file=filename)
                if "metadata" in  xml.getroot().tag.lower():
                    yield getinfo(filename, xml)
def aslatex(x):
    """transform a unicode string to a latex encoded and escaped ascii text"""
    # replace all \ followed by numbers or words by two \\ 
    if not isinstance(x, (str, unicode)):
        return x
    x = re.compile(r'\\[\d\w]').sub(lambda x: '\\'+x.group(0),x)
    x = x.encode('latex')
    x = x.replace('_','\\_')
    x = x.replace('%','\\%')
    return x
def ashtml(x):
    """try and replace non ascii characters by xml entities"""
    if isinstance(x, (unicode,)):
        return x.encode('ascii', "xmlcharrefreplace")
    elif isinstance(x, (str,)):
        return unicode(x,'latin-1').encode('ascii', "xmlcharrefreplace")
    else:
        return x

def sizeof_fmt(num):
    """return number in human readable form"""
    num = float(num)
    # from http://blogmag.net/blog/read/38/Print_human_readable_file_size
    for x in ['bytes','KB','MB','GB','TB']:
        if num < 1024.0:
            return "%3.1f%s" % (num, x)
        num /= 1024.0

def getformatfun(format="html"):
    """get decorators for the format"""
    colors = {'True': 'green', 'False': 'red', 
              'Script missing': 'red', 'loaded': 'green', 
              'Not loaded':'red', 'Data included':'green', 
              'Data missing':'red', True:'green', False:'red',
              'Loaded': 'green', 'Script found': 'green'}
    if format == 'latex':
        # use r so \b doesn't become a backspace character
        make_email = lambda x: r'''\href{mailto:%(x)s}{%(x)s}''' % {'x': (x or "unknown").strip()}
        make_url = lambda x: r'''\href{%(x)s}{%(x)s}''' % {'x': (x or "http://unknown").strip()}
        make_pre = lambda x: '''\\begin{verbatim}\n%(x)s\n\\end{verbatim}''' % {'x': x}
        make_color = lambda x: r'''\textcolor{%(color)s}{%(x)s}''' % {'x': x, 'color': colors.get(x,'blue')}
        default = aslatex
    else:
        make_email = lambda x: '''<a href="mailto:%(x)s">%(x)s</a>''' % {'x': (x or "unknown").strip()}
        make_url = lambda x: '''<a href="%(x)s">%(x)s</a>''' % {'x': (x or "http://unknown").strip()}
        make_pre = lambda x: '''<pre>%(x)s</pre>''' % {'x': x}
        make_color = lambda x: '''<span style="color: %(color)s">%(x)s</span>''' % {'x': x, 'color': colors.get(x,'blue')}
        # assume 256 bits to be latin 1
        default = ashtml
    format_fun = {
        'default': default,
        'URL in inspire file': make_url, #should be the same as URL
        'Inspire URL': make_url, # the url to the inspire metadata xml file
        'URL': make_url, # url of dataset
        'Contact email': make_email,
        'Author email': make_email,
        'Owner email': make_email,
        'Repository Root': make_url,
        'SVN Log': make_pre,
        'Extract': make_color,
        'Transform read': make_color,
        'Transform netcdf': make_color,
        'Load': make_color,
        'Size': sizeof_fmt
        }
    return format_fun


def format(info, format="html"):
    """apply formatting functions to the info"""
    # create a copy so we don't do things twice
    info = copy.copy(info)
    format_fun = getformatfun(format)
    for key, val in info.items():
        val = format_fun['default'](val)
        if key in format_fun:
            val = format_fun[key](val)
        info[key] = val
    return info

# columns for overview table
columns = ['Title', 'Contact email', 'Contact organization', 'Datatype', 'Extract','Transform read', 'Transform netcdf', 'Load', 'Size', 'Legal constraints', 'Country', 'Remarks', 'URL']

headings = ['Description', 'Location and time', 'Contact and authors', 'Restrictions', 'History of dataset', 'Status', 'Files', 'Links', 'Subversion', 'Remarks']
order = {'Description': ['Title','Dataset','Abstract','Topic','Keywords','Datatype'],
            'Location and time': ['WestBoundLongitude','SouthBoundLatitude','EastBoundLongitude','NorthBoundLatitude','Coordinates','Resolution unit','Resolution','Start time','End time','Time spans','period included'],
            'Contact and authors': ['Contact email','Owner organization','Contact organization','Country','Organization','Author organization','Author email','Last Changed Author','Last Changed Date','Owner email'],
            'Restrictions': ['Access constraints','Legal constraints','Other constraints'],
            'History of dataset': ['SVN Log','Lineage'],
            'Status' : ['Extract', 'Transform read', 'Transform netcdf', 'Load'],
            'Files': ['File extensions','Mime types','File types','Script info','Size'],
            'Links': ['URL in inspire file','Inspirefile','URL','Inspire URL'],
            'Subversion': ['Path','Repository Root','Repository UUID','Node Kind','Schedule','Last Changed Rev','Revision'],
            'Remarks': ['Remarks'],
            }

if __name__ == '__main__':
    allinfo = inspireinfo()
    kmlinspireinfo = [format(info,'kml') for info in allinfo]
    kmlinspireinfo2 = []
    for info in kmlinspireinfo:
        info2 = {}
        info2.update(info)
        info2.update(getcoordinates(info))
        kmlinspireinfo2.append(info2)
    searchList = dict(inspireinfo=kmlinspireinfo2, columns=columns, headings=headings, order=order) 
    template = Cheetah.Template.Template(file=os.path.join(TEMPLATEDIR, "template.kml"), searchList=searchList)
    f = open('overview.kml','w')
    result = template.respond()
    f.write(result)
    f.close()
