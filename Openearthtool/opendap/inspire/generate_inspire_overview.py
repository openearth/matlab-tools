#!/usr/bin/env python
# -*- coding: utf-8 -*-
import re
import urllib # for quoting 
import urlparse
import os.path
import subprocess
import csv
import copy 
import itertools

import mx.DateTime
import Cheetah.Template
from lxml.etree import ElementTree, dump
# read xls files
import xlrd

#why is this required?
import sys
sys.path.append('.')
import magic
import latex
#register latex encoding
latex.register()

COUNTRY = True
HTML = False
LATEX = True
KML = True
SVNLOG = True
MAGIC = True
TEMPLATEDIR = "."
DATADIR = os.path.expanduser("/Users/fedorbaart/opendap/openearth") # /Volumes/OSXDATA/OpenEarthRawData")
ns = {'gmd':'http://www.isotc211.org/2005/gmd',
      'gco':'http://www.isotc211.org/2005/gco',
      'gml':'http://www.opengis.net/gml'}


countries = {"arpa-simc": "it",
             "boskalis":"nl",
             "brgm": "fr",
             "cefas":"nl",
             "deltares": "nl",
             "ecoshape": "nl",
             "fcul": "pt",
             "imdc": "be",
             "io_bas": "bg",
             "knmi": "nl", 
             "nasa":"nl",
             "noaa": "nl",
             "pol": "uk",
             "por":"nl",
             "rijkswaterstaat": "nl",
             "sgss":"it",
             "tno":"nl",
             "tudelft": "nl",
             "ualg": "pt",
             "uca": "es",
             "unife": "it",
             "uop": "uk",
             "usgs":"nl",
             "usz": "pl",
             "vanoordboskalis": "nl",
             "NOAA": "nl"}



def inspireinfo():
    """create a list of inspire files"""
    for root, dirs, files in os.walk(DATADIR):
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

def getdirectorysize(directory):
    """recursively count the directory size""" 
    dir_size = 0
    for (path, dirs, files) in os.walk(directory):
        if '.svn' in dirs:
            dirs.remove('.svn')
        for file in files:
            if file.startswith('.#'): #skip locked files from emacs
                continue
            filename = os.path.join(path, file)
            dir_size += os.path.getsize(filename)
    return dir_size



def getfiletypes(directory, domagic=False):
    """use magic to determine file type"""
    filetypes = {'mime': set(), 'type': set(), 'extension': set()}
    for (path, dirs, files) in os.walk(directory):
        if '.svn' in dirs:
            dirs.remove('.svn')
        for file in files:
            if file.startswith('.#'): #skip locked files from emacs
                continue
            filename = os.path.join(path, file)
            ext = os.path.splitext(filename)[-1] 
            new_ext = (not ext in filetypes['extension'])
            filetypes['extension'].add(ext)
            if domagic and new_ext:
                filetypes['mime'].add(magic.from_file(filename, mime=True))
                filetypes['type'].add(magic.from_file(filename, mime=False))
    info = {
        'Mime types': ", ".join(filetypes["mime"]),
        }
    if domagic:
        info['File types'] = ", ".join(filetypes["type"])
        # if we found more than 1 filetype we assume it's data
        if len(filetypes["type"]) > 1:
            info['Extract'] = True
        else:
            info['Extract'] = False
        info['File extensions'] = ", ".join(filetypes["extension"])

    info['Load'] = False
    return info
    

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

def findscript(directory):
    """find if scripts are available"""
    info = {}
    found_script = False
    found_netcdf = False
    messages = []
    for root, dirs, files in os.walk(directory):
        if '.svn' in dirs:
            dirs.remove('.svn')
        for file in files:
            if file.startswith('.#'): #skip locked files from emacs
                continue
            if os.path.splitext(file.lower())[-1] in (".m", ".py", ".r"):
                filename = os.path.join(root,file)
                found_script = True
                messages.append("Found script: %s." % (filename,))
                for i, line in enumerate(open(filename)):
                    if "nc_" in line or "netcdf" in line or "ncdf" in line:
                        found_netcdf = True
                        messages.append("Found netcdf logic in %s line: %s." % (filename, i+1))
                        break
                else:
                    messages.append("No netcdf logic found in %s." % (filename,))
    if not messages:
        messages.append("No process scripts found")
    info["Script info"] = "\n".join(messages)
    info["Transform read"] = found_script
    info["Transform netcdf"] = found_netcdf
    return info
    
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

    

def getinfo(filename, xml):
    """look up all info we can find about a file and it's inspire xml"""
    info = {}
    # get information from filename
    directory, inspirefile = os.path.split(filename)
    filere = re.compile(r'((OpenEarthRawData/(?!trunk))|(trunk/))(?P<Organization>[^/]+)/(?P<Dataset>[^/]+)')
    if filere.search(filename):
        info.update(filere.search(filename).groupdict())
    info['Country'] = countries.get(info.get('Organization'))
    info['Inspirefile'] = inspirefile
    # get information from subversion
    proc = subprocess.Popen('svn info "%s"' % directory, shell=True, stdout=subprocess.PIPE)
    proc.wait()
    svntext = proc.stdout.read()
    svninfo = map(lambda x:x.split(':',1), svntext.strip().split('\n'))
    if len(svninfo) > 1:
        for key, val in svninfo:
            info[key.strip()] = val.strip()
    # look up the subversion url
    if "URL" in info:
        info['Inspire URL'] = normalizeurl("%s/%s" % (info['URL'], inspirefile))
    # or use the local one
    else:
        info['Inspire URL'] = filename
    # get log information from subversion
    if SVNLOG:
        proc = subprocess.Popen('svn log "%s"' % directory, shell=True, stdout=subprocess.PIPE)
        proc.wait()
        svnlog = proc.stdout.read()
        info['SVN Log'] = svnlog
    # check if people added scripts
    info.update(findscript(directory))

    # get the directory size
    info['Size'] = getdirectorysize(directory)
    
    # get the mimes etc...
    info.update(getfiletypes(directory, domagic=MAGIC))
    
    for name, xpath in xpaths.items():
        info[name] = gettext(xml, xpath)
    
    #update with coordinates info
    info.update(getcoordinates(info))
    return info


# now for parsing the csv file
def updatewithcsv(inspireinfo, filename='datasetstiny.csv'):
    """update an inspireinfoset with information from filename"""
    allinfo = {}
    # create an index on url
    for info in inspireinfo:
        allinfo[info["Inspire URL"]] = info
    # update with information from Marije    
    f = open(filename)
    reader = csv.DictReader(f)
    for record in reader:
        # records with a inspire file
        # disect 
        url = normalizeurl(record['Inspire URL'])
        if url in allinfo:
            # we found a url of which we already have data. Overwrite with Marije's info
            info = allinfo[url]
            info.update(record)
            print "Url", url, "updated"
        else:
            # records without an inspire file
            if not url or url == 'none':
                # check if alternative url is available.
                url = normalizeurl(record["No Inspire URL"])
                if url:
                    print "using", url, "instead"
                    record["URL"] = url # also store it in url so we can reference it
                    allinfo[url] = dict(record) # downcast to dict
                else:
                    #skip this one
                    continue
            # records extra in Marije's overzicht
            else:
                print "Extra in overzicht Marije", url
                info = dict(record)
                allinfo[url] = info
        #update title
        info = allinfo[url]
        info['Title'] = info.get('Title', 'Unknown')
        allinfo[url] = info
    f.close()
    return allinfo.values()




def expected_datasets(countrycode):
    """look up the expected datatypes in the excel document"""
    book = xlrd.open_workbook("datasets.xls")
    countrysheetnames = {'be':u'belgium', 'bg':u'bulgary', 'fr':u'france', 'it':u'italy', 'nl':u'netherlands', 'pl':u'poland', 'pt':u'portugal', 'es':u'spain', 'uk':u'united kingdom'}
    sheetname = countrysheetnames[countrycode]
    sheet = book.sheet_by_name(sheetname)
    assert sheet.cell_value(0,0) == u'Type of data:'
    datatypes = sheet.col(0)[1:]
    return set([x.value for x in datatypes if x.value])

def observed_datasets(inspireinfo):
    '''Lookup all datatypes which are available'''
    return set(info.get('Datatype') for info in inspireinfo if info.get('Datatype'))
    

# now for the formatting

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
        
def latexinspireinfo():
    """apply latex formatting to info"""
    # used to fix an issue where double \\ appear
    return [format(info,'latex') for info in updatewithcsv(inspireinfo())]
    
def normalizeurl(url):
    """remove inconsistencies in paths"""
    (scheme, netloc, path, params, query, fragment) = urlparse.urlparse(url) 
    #normalize the url by not using quotes (%20 for space etc)
    path = urllib.unquote(path)
    url = urlparse.urlunparse((scheme, netloc, path, params, query, fragment))
    return url

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
    # don't call it namespace here cause we already have xml namespaces
    allinfo =  sorted(updatewithcsv(inspireinfo()), key=lambda x: x.get('Country'))
    if HTML:
        htmlinspireinfo = [format(info,'html') for info in allinfo]
        searchList = dict(inspireinfo=htmlinspireinfo, columns=columns, headings=headings, order=order) 
        template = Cheetah.Template.Template(file=os.path.join(TEMPLATEDIR, "template.html"), searchList=searchList)
        f = open('overview.html','w')
        f.write(template.respond())
        f.close()
        import webbrowser
        webbrowser.open(url=os.path.abspath('overview.html'))
    if LATEX:
        latexinspireinfo = [format(info,'latex') for info in allinfo]
        searchList = dict(inspireinfo=latexinspireinfo, columns=columns) 
        template = Cheetah.Template.Template(file=os.path.join(TEMPLATEDIR, "template.tex"), searchList=searchList)
        f = open('overview.tex','w')
        result = template.respond()
        f.write(result)
        f.close()
    if KML:
        kmlinspireinfo = [format(info,'kml') for info in allinfo]
        searchList = dict(inspireinfo=kmlinspireinfo, columns=columns, headings=headings, order=order) 
        template = Cheetah.Template.Template(file=os.path.join(TEMPLATEDIR, "template.kml"), searchList=searchList)
        f = open('overview.kml','w')
        result = template.respond()
        f.write(result)
        f.close()
    if COUNTRY:
        if HTML:
            htmlinspireinfo = [format(info,'html') for info in allinfo]
            for country, inspireinfo in itertools.groupby(htmlinspireinfo, key=lambda x:x.get('Country')):
                print "generating overview for", country
                inspireinfo = list(inspireinfo)
                searchList = dict(inspireinfo=inspireinfo, columns=columns, headings=headings, order=order) 
                searchList['expected'] = expected_datasets(country)
                searchList['observed'] = observed_datasets(inspireinfo)
                template = Cheetah.Template.Template(file=os.path.join(TEMPLATEDIR, "template.html"), searchList=searchList)
                f = open('datasets_%s.html' % country,'w')
                f.write(template.respond())
                f.close()
                import webbrowser
                webbrowser.open(url=os.path.abspath('datasets_%s.html' % country))
        if KML:
            kmlinspireinfo = [format(info,'kml') for info in allinfo]
            for country, inspireinfo in itertools.groupby(kmlinspireinfo, key=lambda x:x.get('Country', 'Unknown')):
                searchList = dict(inspireinfo=kmlinspireinfo, columns=columns, headings=headings, order=order) 
                template = Cheetah.Template.Template(file=os.path.join(TEMPLATEDIR, "template.kml"), searchList=searchList)
                f = open('datasets_%s.kml' % country,'w')
                result = template.respond()
                f.write(result)
                f.close()


