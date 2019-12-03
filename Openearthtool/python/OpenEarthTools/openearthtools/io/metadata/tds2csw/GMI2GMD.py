#!/usr/bin/env python

""" Python class convert gmi metadata to gmd + abstract/keywords ready to upload to geonetwork via csw """

__author__ = "Joan Sala Calero"
__version__ = "0.1"
__email__ = "joan.salacalero@deltares.nl"
__status__ = "Prototype"

import lxml.etree as ET
import os
import logging

class gmi2gmd:

    # Class init, gmd namespace and input file
    def __init__(self, url_logo_in, url_godiva):
        # Default logo
        self.url_logo=url_logo_in
        # Default ncWMS viewer
        self.url_godiva = url_godiva
        # GMD metadata handling
        self.namespaces_gmd = {
            'gsr': "http://www.isotc211.org/2005/gsr",
            'gss': "http://www.isotc211.org/2005/gss",
            'gts': "http://www.isotc211.org/2005/gts",
            'gml': "http://www.opengis.net/gml/3.2",
            'xs': "http://www.w3.org/2001/XMLSchema",
            'xlink': "http://www.w3.org/1999/xlink",
            'xsi': "http://www.w3.org/2001/XMLSchema-instance",
            'gco': "http://www.isotc211.org/2005/gco",
            'gmd': "http://www.isotc211.org/2005/gmd",
            'gmi': "http://www.isotc211.org/2005/gmi",
            'srv': "http://www.isotc211.org/2005/srv",
            'gmx': "http://www.isotc211.org/2005/gmx",
        }

    # Remove a gmd tag given the xpath
    def remove_tag_gmd(self, xml, xpath_str):
        for elem in xml.xpath(xpath_str, namespaces=self.namespaces_gmd):
            elem.getparent().remove(elem)

    # Append a gmd tag given the xpath
    def append_tag_gmd(self, xml, ins, xpath_father):
        node = ET.fromstring(ins)
        for elem in xml.xpath(xpath_father, namespaces=self.namespaces_gmd):
            elem.append(node)

    # Add standard abstract (automatically gathered product)
    def add_std_abstract(self, xml, xpath_father):
        # Generic descriptive abstract with namespaces
        msg = "This NetCDF dataset has been harvested automatically from a Thredds server. There are multiple ways of accessing the data: using OPeNDAP web services, which can be used to select data from this dataset. The complete file can be downloaded using the \"Download File\" link. More information on working with NetCDF data and OPeNDAP can be found on the OpenEarth Wiki: https://publicwiki.deltares.nl/display/OET/netCDF-CF-OPeNDAP"

        # xml node
        ins = "<gmd:abstract xmlns:gmd=\"" + self.namespaces_gmd['gmd'] + "\""">" \
              "<gco:CharacterString xmlns:gco=\"" + self.namespaces_gmd['gco'] + "\""">" \
                "{}" \
              "</gco:CharacterString>" \
              "</gmd:abstract>".format(msg)

        # Append to father
        self.append_tag_gmd(xml, ins, xpath_father)

    def add_title(self, xml, varkeys, xpath_father):
        # Generic descriptive abstract with namespaces
        title = varkeys[0] # single-var-title

        # xml node
        ins = "<gmd:title xmlns:gmd=\"" + self.namespaces_gmd['gmd'] + "\""">" \
              "<gco:CharacterString xmlns:gco=\"" + self.namespaces_gmd['gco'] + "\""">" \
                "{}" \
              "</gco:CharacterString>" \
              "</gmd:title>".format(title)

        # Append to father
        self.append_tag_gmd(xml, ins, xpath_father)


    # Get existing keywords
    def get_values_xpath(self, xml, xpath_keys):
        ret=[]
        for elem in xml.xpath(xpath_keys, namespaces=self.namespaces_gmd):
            for c in elem.getchildren():
                if c.text != None: ret.append(c.text)
        return ret

    # Add keywords (to the ones already there) and add the tree path keywords
    def add_keywords(self, xml, old_keys, new_keys, varkeys, xpath_father):

        rootag = ET.fromstring(
            "<gmd:descriptiveKeywords xmlns:gmd=\"" + self.namespaces_gmd['gmd'] + "\""">\n" +
            "</gmd:descriptiveKeywords>\n")

        subtag = ET.fromstring(
            "<gmd:MD_Keywords xmlns:gmd=\"" + self.namespaces_gmd['gmd'] + "\""">\n" +
            "</gmd:MD_Keywords>\n" )

        # Let's assume the TDS catalog tree is organized in a smart way
        keys = list(set(new_keys + old_keys + varkeys + ['harvested','tds2csw'])) # iso keys + path keys + standard vars + fixed keys

        # Include them
        exceptions = ['lat','lon','longitude','latitude','time','.']
        fkeys=[]
        for k in keys:
            # Remove unuseful stuff
            if '.xml' in k: k = k.replace('.xml', '')
            if k in exceptions: continue # unuseful keywords

            # Add new keyword
            ins = "<gmd:keyword xmlns:gmd=\"" + self.namespaces_gmd['gmd'] + "\""">\n" \
                                                                        "<gco:CharacterString xmlns:gco=\"" + \
                  self.namespaces_gmd['gco'] + "\""">" \
                  + k + \
                  "</gco:CharacterString>\n" \
                  "</gmd:keyword>\n"
            node = ET.fromstring(ins)
            subtag.append(node)
            fkeys.append(k)

        # Append to rootag
        logging.info('Keywords = ' + str(fkeys))
        rootag.append(subtag)

        # Append to the big XML
        for elem in xml.xpath(xpath_father, namespaces=self.namespaces_gmd):
            elem.append(rootag)

    # Add logo (default tds logo)
    def add_logo(self, xml, xpath_father):
        logostr = "<gmd:graphicOverview xmlns:gmd=\"" + self.namespaces_gmd['gmd'] + "\""">\n" + "<gmd:MD_BrowseGraphic>\n" + "<gmd:fileName>\n" + "<gco:CharacterString xmlns:gco=\"http://www.isotc211.org/2005/gco\">#URLLOGO#</gco:CharacterString>\n" + "</gmd:fileName>\n" + "<gmd:fileDescription>\n" + "<gco:CharacterString xmlns:gco=\"http://www.isotc211.org/2005/gco\">large_thumbnail</gco:CharacterString>\n" + "</gmd:fileDescription>\n" + "<gmd:fileType>\n" + "<gco:CharacterString xmlns:gco=\"http://www.isotc211.org/2005/gco\">png</gco:CharacterString>\n" + "</gmd:fileType>\n" + "</gmd:MD_BrowseGraphic>\n" + "</gmd:graphicOverview>\n"
        rootag = ET.fromstring(logostr.replace("#URLLOGO#", self.url_logo))

        # Append to the big XML
        for elem in xml.xpath(xpath_father, namespaces=self.namespaces_gmd):
            elem.append(rootag)

    # Get xml tag for distribution
    def get_link_tag(self, url, ref, desc):
        url=url.replace('&','&amp;')
        return """<gmd:distributorTransferOptions xmlns:gmd="http://www.isotc211.org/2005/gmd">
            <gmd:MD_DigitalTransferOptions>
               <gmd:onLine>
                  <gmd:CI_OnlineResource>
                     <gmd:linkage>
                        <gmd:URL>{}</gmd:URL>
                     </gmd:linkage>
                     <gmd:name>
                        <gco:CharacterString xmlns:gco="http://www.isotc211.org/2005/gco">{}</gco:CharacterString>
                     </gmd:name>
                     <gmd:description>
                        <gco:CharacterString xmlns:gco="http://www.isotc211.org/2005/gco">{}</gco:CharacterString>
                     </gmd:description>
                     <gmd:function>
                        <gmd:CI_OnLineFunctionCode codeList="http://www.ngdc.noaa.gov/metadata/published/xsd/schema/resources/Codelist/gmxCodelists.xml#CI_OnLineFunctionCode" codeListValue="download">download</gmd:CI_OnLineFunctionCode>
                     </gmd:function>
                  </gmd:CI_OnlineResource>
               </gmd:onLine>
            </gmd:MD_DigitalTransferOptions>
         </gmd:distributorTransferOptions>""".format(url, ref, desc)

    def search_link(self, xml, xpath_search):
        data_link = xml.xpath(xpath_search, namespaces=self.namespaces_gmd)
        if len(data_link) == 0:
            return ""
        else:
            return data_link[0].text

    # Add file link
    def add_file_links(self, xml):
        # Search for the link
        url_file = self.search_link(xml, xpath_search = '//gmd:MD_Metadata/gmd:identificationInfo/srv:SV_ServiceIdentification/srv:containsOperations/srv:SV_OperationMetadata/srv:connectPoint/gmd:CI_OnlineResource/gmd:name/gco:CharacterString[text()=\'THREDDS_HTTP_Service\']/../../gmd:linkage/gmd:URL')
        url_wcs = self.search_link(xml, xpath_search = '//gmd:MD_Metadata/gmd:identificationInfo/srv:SV_ServiceIdentification/srv:containsOperations/srv:SV_OperationMetadata/srv:connectPoint/gmd:CI_OnlineResource/gmd:name/gco:CharacterString[text()=\'OGC-WCS\']/../../gmd:linkage/gmd:URL')
        url_wms = self.search_link(xml, xpath_search='//gmd:MD_Metadata/gmd:identificationInfo/srv:SV_ServiceIdentification/srv:containsOperations/srv:SV_OperationMetadata/srv:connectPoint/gmd:CI_OnlineResource/gmd:name/gco:CharacterString[text()=\'OGC-WMS\']/../../gmd:linkage/gmd:URL')
        url_odap = self.search_link(xml, xpath_search='//gmd:MD_Metadata/gmd:identificationInfo/srv:SV_ServiceIdentification/srv:containsOperations/srv:SV_OperationMetadata/srv:connectPoint/gmd:CI_OnlineResource/gmd:name/gco:CharacterString[text()=\'OPeNDAP\']/../../gmd:linkage/gmd:URL')

        # Append to father
        xpath_father = '//gmd:MD_Metadata/gmd:distributionInfo/gmd:MD_Distribution/gmd:distributor/gmd:MD_Distributor'
        if (url_file != ""):
            ins_direct = self.get_link_tag(url_file, 'Direct Download', 'Direct link for download')
            self.append_tag_gmd(xml, ins_direct, xpath_father)
            logging.info('-> HTTP File access found')
        if (url_wcs != ""):
            ins_wcs = self.get_link_tag(url_wcs, 'WCS service', 'Direct link for OGC-WCS access')
            self.append_tag_gmd(xml, ins_wcs, xpath_father)
            logging.info('-> WCS File access found')
        if (url_wms != ""):
            ins_wms = self.get_link_tag(url_wms, 'WMS service', 'Direct link for OGC-WMS service')
            ins_ncwms = self.get_link_tag(self.url_godiva + '?server=' + url_wms, 'Preview service','Direct link for ncWMS service')
            self.append_tag_gmd(xml, ins_ncwms, xpath_father)
            self.append_tag_gmd(xml, ins_wms, xpath_father)
            logging.info('-> WMS File access found')
        if (url_odap != ""):
            ins_odap = self.get_link_tag(url_odap, 'OpenDAP service', 'Direct link for Opendap service')
            self.append_tag_gmd(xml, ins_odap, xpath_father)
            logging.info('-> OpenDAP File access found')

    # Return path elements
    def os_path_split_asunder(self, path, debug=False):
        parts = []
        while True:
            newpath, tail = os.path.split(path)
            if debug: logging.info(repr(path), (newpath, tail))
            if newpath == path:
                assert not tail
                if path: parts.append(path)
                break
            parts.append(tail)
            path = newpath
        parts.reverse()
        return parts

    # Convert iso GMI to
    def convert(self, xmlpath):
        # Read metadata
        dom = ET.parse(open(xmlpath))

        # Read xslt
        xslt = ET.parse(open('gmiTogmd.xsl'))

        # Parse XML and transform it using stylesheet
        transform = ET.XSLT(xslt)
        newdom = transform(dom)

        # Remove tags
        self.remove_tag_gmd(newdom, '//gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:abstract')
        self.remove_tag_gmd(newdom, '//gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:descriptiveKeywords')
        self.remove_tag_gmd(newdom, '//gmd:MD_Metadata/gmd:distributionInfo/gmd:MD_Distribution/gmd:distributor/gmd:MD_Distributor/gmd:distributorTransferOptions')

        # Get Links
        self.add_file_links(newdom)

        # Get variables information
        varkeys = self.get_values_xpath(dom, '//gmi:MI_Metadata/gmd:contentInfo/gmi:MI_CoverageDescription/gmd:dimension/gmd:MD_Band/gmd:descriptor')

        # Get path informations
        newkeys = self.os_path_split_asunder(xmlpath)

        # Get existing keywords
        oldkeys=self.get_values_xpath(newdom, '//gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:descriptiveKeywords/gmd:MD_Keywords/gmd:keyword')

        # Harvested title
        oldtitle = self.get_values_xpath(newdom, '//gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:citation/gmd:CI_Citation/gmd:title')

        # Change title
        self.remove_tag_gmd(newdom, '//gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:citation/gmd:CI_Citation/gmd:title')
        if (varkeys != None and len(varkeys) == 1):
            self.remove_tag_gmd(newdom, '//gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:citation/gmd:CI_Citation/gmd:title')
            # Add title (if available)
            self.add_title(newdom, varkeys, '//gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:citation/gmd:CI_Citation')
        else:
            dummy = [newkeys[-1].replace('.xml','')]
            self.add_title(newdom, dummy, '//gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:citation/gmd:CI_Citation')

        # Create standard abstract
        self.add_std_abstract(newdom,'//gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification')

        # Create keywords
        self.add_keywords(newdom, oldkeys, newkeys, varkeys, '//gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification')

        # Add default logo
        self.add_logo(newdom, '//gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification')

        # Transform
        xmlcontent = ET.tostring(newdom, pretty_print=True)

        return xmlcontent
