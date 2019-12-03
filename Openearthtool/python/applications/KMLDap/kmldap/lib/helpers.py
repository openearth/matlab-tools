"""Helper functions

Consists of functions to typically be used within templates, but also
available to Controllers. This module is available to templates as 'h'.
"""
# Import helpers as desired, or define your own, ie:
#from webhelpers.html.tags import checkbox, password
from pylons import url
def plotproperties(params):
    """extract arguments which can be passed to matplotlib and cast them to the proper type"""
    properties = {}
    for key in ('format', 'dpi', 'orientation', 'facecolor', 'edgecolor', 'transparent', 'papertype'):
        if key in params:
            if key == 'dpi':
                properties[key] = int(params[key])
            elif key == 'transparent':
                properties[key] = bool(params[key])
            else:
                properties[key] = params[key]
    return properties

def compress_kml(kml):
    "Returns compressed KMZ from the given KML string."
    import cStringIO, zipfile
    kmz = cStringIO.StringIO()
    zf = zipfile.ZipFile(kmz, 'a', zipfile.ZIP_DEFLATED)
    zf.writestr('doc.kml', kml)
    zf.close()
    kmz.seek(0)
    return kmz.read()
def textcoordinates(x,y,z=None):
    """print the coordinates so they can be used by kml"""
    import cStringIO
    import numpy
    if z is None:
        z = numpy.zeros(x.shape)
    coordinates = numpy.vstack([x, y, z]).T
    # only write coordinates where none is nan
    filter = numpy.isnan(coordinates).any(1)
    output = cStringIO.StringIO()
    numpy.savetxt(output, coordinates[~filter],delimiter=',' )
    output.seek(0)
    return output.read()
def kmldate(date):
    """print date in kml for"""
    return date.strftime("%Y-%m-%dT%H:%M:%SZ")
