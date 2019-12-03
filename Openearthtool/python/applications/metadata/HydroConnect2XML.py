from filesync import main as filesync
from uuid import uuid4
from lxml import etree
import os.path


def setns_paths():
    """Set namespace (ns) and xpaths for use in geonetwork."""
    ns_ = {'gmd': 'http://www.isotc211.org/2005/gmd',
           'gco': 'http://www.isotc211.org/2005/gco',
           'gml': 'http://www.opengis.net/gml'}
    xpaths_ = {
        'Dataset_Title': '//gmd:identificationInfo//gmd:citation//gmd:title//gco:CharacterString',
        'Dataset_Abstract': '//gmd:identificationInfo//gmd:abstract//gco:CharacterString',
        'Keywords': '//gmd:descriptiveKeywords//..//gmd:keyword//gco:CharacterString'
    }
    return ns_, xpaths_


def settext(tree, xpaths, ns, dictvalues):
    """Function sets value in xml tree if key is found within xpaths dictionary."""
    for key in dictvalues.keys():
        apath = xpaths.get(key)
        if apath is not None:
            r = tree.xpath(apath, namespaces=ns)
            for i in range(len(r)):
                r[i].text = dictvalues[key]

#####################################################
# First type username and password in the list below.
#####################################################
task = ['-meta_data_pwd', '', '-meta_data_repos', 'https://svn-nhi-data.deltares.nl/repos/nhi-data/',
        '-model_name', 'nhi', '-meta_data_user', 'dts_bos_en', '-action', 'list_params', '-model_release', '3.0',
        '-exclude_tag', ['vistrails', 'metadata']]

_, hc_labels, hc_properties, status_code = filesync(task)
if status_code > 0:
    raise StandardError('Invalid arguments in call to FileSync.')

# {'Dataset_Title': {'Dataset_Abstract': str, 'Keywords': str}}
hc_dict = {}
for label in hc_labels:
    hc_dict[label] = {}
# Fill hc_dict with the descriptions.
for label, description in hc_properties['DESCRIPTION'].iteritems():
    hc_dict[label]['Dataset_Abstract'] = description
# Fill hc_dict with the keywords, converting a list to a string.
for keyword, labels in hc_properties['TAG'].iteritems():
    for label in labels:
        if 'Keywords' in hc_dict[label]:
            hc_dict[label]['Keywords'] += ' ' + keyword
        else:
            hc_dict[label]['Keywords'] = keyword

script_directory = os.path.dirname(__file__)
template_xml_filepath = os.path.join(script_directory, 'basis.xml')
output_directory = os.path.join(script_directory, 'temp')

xml_tree = etree.parse(template_xml_filepath)

'''load xml templates '''
ns, xpaths = setns_paths()

# if uidentifier is filled, a geonetwork record is present, if so delete the record and update,
# if not, create an insert query
for title, data in hc_dict.iteritems():
    axml = os.path.join(output_directory, title + '.xml')
    fxml = open(axml, 'wb')
    dictvalues = {
        'FileID': str(uuid4()),
        'Dataset_Title': title,
        'Dataset_Abstract': data['Dataset_Abstract'],
        'Keywords': data['Keywords']
    }
    settext(xml_tree, xpaths, ns, dictvalues)
    # convert element tree object to text
    dataxml = etree.tostring(xml_tree, pretty_print=True)
    fxml.writelines(dataxml)
    fxml.close()