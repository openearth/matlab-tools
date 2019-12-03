# -*- coding: utf-8 -*-
# Copyright notice
#   --------------------------------------------------------------------
#   Copyright (C) 2017 Deltares
#       Gerrit Hendriksen, Joan Sala
#
#       gerrit.hendriksen@deltares.nl, joan.salacalero@deltares.nl
#
#   This library is free software: you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation, either version 3 of the License, or
#   (at your option) any later version.
#
#   This library is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with this library.  If not, see <http://www.gnu.org/licenses/>.
#   --------------------------------------------------------------------
#
# This tool is part of <a href="http://www.OpenEarth.eu">OpenEarthTools</a>.
# OpenEarthTools is an online collaboration to share and manage data and
# programming tools in an open source, version controlled environment.
# Sign up to recieve regular updates of this function, and to contribute
# your own tools.

# $Id: nhimodel.py 15858 2019-10-22 15:18:09Z pronk_mn $
# $Date: 2019-10-22 08:18:09 -0700 (Tue, 22 Oct 2019) $
# $Author: pronk_mn $
# $Revision: 15858 $
# $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/python/applications/wps/nhidataportaal/processes/nhimodel.py $
# $Keywords: $

# core
import os
import logging
import types

# modules
import simplejson as json
import io
from pywps.Process import WPSProcess

# relative
from coords import *
from opendap_nhi import find_spreidingslengte

# Classes
from nhimodel_outputs import nhimodel_IO
from nhimodel_config import nhimodel_CONF
from nhimodel_run import nhimodel_RUN

"""
Waterbodems nhi WPS start script

This is a redesigned WPS for the Waterbodems application, based in infoline_redesigned.

if it runs on localhost then:
getcapabilities:  http://localhost/cgi-bin/pywps.cgi?request=GetCapabilities&service=wps&version=1.0.0
describe process: http://localhost/cgi-bin/pywps.cgi?request=DescribeProcess&service=wps&version=1.0.0&identifier=nhimodel
execute:          http://localhost/cgi-bin/pywps.cgi?&service=wps&request=Execute&version=1.0.0&identifier=nhimodel&datainputs=[layernb=1;absvolume=50;geom={%20%22type%22:%20%22FeatureCollection%22,%20%22features%22:%20[%20{%20%22type%22:%20%22Feature%22,%20%22properties%22:%20{},%20%22geometry%22:%20{%20%22type%22:%20%22Point%22,%20%22coordinates%22:%20[%204.3689751625061035,%2052.01105825338195%20]%20}%20}%20]%20}]
"""

# Default templates (relative path)
TEMPLATE_RUN = os.path.join(os.path.dirname(
    os.path.realpath(__file__)), 'nhi_stationary_WPSTEMPLATE.run')
TEMPLATE_IPF = os.path.join(os.path.dirname(
    os.path.realpath(__file__)), 'nhi_abstraction_WPSTEMPLATE.ipf')
CONFIG_FILE = os.path.join(os.path.dirname(
    os.path.realpath(__file__)), 'NHIconfig.txt')

# WPS process class


class Process(WPSProcess):
    def __init__(self):
        # init process; note: identifier must be same as filename
        WPSProcess.__init__(self,
                            identifier="nhimodel",
                            title="LHM - effecten van onttrekkingen",
                            version="1.0",
                            storeSupported="true",
                            statusSupported="true",
                            abstract="""Deze LHM tool maakt het mogelijk de effecten van een onttrekking (negatieve waarde) of een injectie (positief waarde)
                            		door te rekenen met het stationaire model van LHM3.3. voor een op te geven straal. De straal wordt gebruik om het interesse gebied rondom de gekozen lokatie te bepalen.
                            		De uitkomst is het verschil tussen de grondwaterstand van het huidige model minus de berekende grondwaterstand.""",
                            grassLocation=False)

        # INPUTS
        self.layernb = self.addLiteralInput(identifier="layernb",
                                            title="Selecteer een model laag waarin onttrekking wordt geplaatst [laagnummers LHM liggen in de range van 1 tot 7, alleen gehele getallen gebruiken]",
                                            type=int, default=2)

        self.layernv = self.addLiteralInput(identifier="layernv",
                                            title="Selecteer evaluatie laag [laagnummers LHM liggen in de range van 1 tot 7, alleen gehele getallen gebruiken]",
                                            type=int, default=1)

        self.absvolume = self.addLiteralInput(identifier="absvolume",
                                              title="Specifeer het volume van de onttrekking (negatieve waarde)/injectie (positieve waarde) (m3/dag)",
                                              type=int, default=-7000)

        # Calculated with spreidingslengte if input is -1
        self.margin = self.addLiteralInput(identifier="margin",
                                           title="Specificeer de straal van de modelleeromgeving (in meter). Het model resultaat zal worden weergegeven in een vierkant met zijden van 2 maal de opgegeven straal.",
                                           type=int, default=5000)

        self.location = self.addLiteralInput(identifier="location",
                                             title="Plaats de onttrekking/injectie door op de groene knop hieronder te klikken en dan een locatie te 'prikken'",
                                             abstract="input=mapselection",
                                             type=type(""),
                                             uoms=["point"],
                                             default="Select a location on the map")

        # OUTPUTS
        self.json = self.addComplexOutput(identifier="json",
                                          title="Returns list of values for specified xy",
                                          abstract="""Returns list of values for specified xy""",
                                          formats=[{"mimeType": "text/plain"},  # 1st is default
                                                   {'mimeType': "application/json"}])

    # Parameters check
    def check_inputs(self, IO, layernb, layernv, absvolume, margin, location, epsgin='epsg:3857'):
        # Valid JSON
        try:
            # Input (coordinates)
            location_info = json.loads(location)
            (xin, yin) = location_info['x'], location_info['y']
            (x, y) = change_coords(xin, yin, epsgin=epsgin, epsgout='epsg:28992')
            x, y = round(x), round(y)
            logging.info('''Input Coordinates {} {}'''.format(xin, yin))
            xe, ye = getCoords250(x, y)
            logging.info(
                '''INPUT [nhimodel]: coordinates_250_rdnew={},{}'''.format(x, y))
        except:
            return False, '''<p>Selecteer eerst een locatie met de 'Select on map' knop</p>'''.format(layernb), -1, -1, -1, -1

        # Layer, abstraction volumne and and availability of data
        ok_layer = isinstance(layernb, int) and (layernb > 0) and (layernb < 8)
        v_layer = isinstance(layernv, int) and (layernv > 0) and (layernv < 8)
        maxabs = 100000  # Maximum threshold
        maxmargin = 15000  # Maximum margin
        minmargin = 250  # cannot be smaller than the cellsize
        ok_abs = abs(absvolume) <= maxabs
        ok_margin = abs(margin) <= maxmargin
        if margin == 0:
            ok_margin_min = True
        else:
            ok_margin_min = abs(margin) >= minmargin
        ok_abs_z = absvolume != 0
        ok_margin_z = margin != 0
        inside = False

        if not(ok_layer):
            return False, '''<p>Het LHM bestaat uit 7 modellagen. Laag {} is opgegeven. Allen laagenummers tussen 1 en 7 en gehele waarden kunnen worden verwerkt. Probeer het nog eens.</p>'''.format(layernb), -1, -1, -1, -1
        elif not(v_layer):
            return False, '''<p>Het LHM bestaat uit 7 modellagen. Laag {} is opgegeven. Allen laagenummers tussen 1 en 7 en gehele waarden kunnen worden verwerkt. Probeer het nog eens.</p>'''.format(layernv), -1, -1, -1, -1
        elif not(ok_abs):
            return False, '''<p>Het volume van de onttrekking ({} m3/dag) is groter dan het maximale volume ({} m3/dag). Probeer het nog eens.</p>'''.format(absvolume, maxabs), -1, -1, -1, -1
        elif not(ok_abs_z):
            return False, '''<p>Het volume van de onttrekking is nul. Probeer het nog eens.</p>''', -1, -1, -1, -1
        elif not(ok_margin):
            return False, '''<p>De grootte van de modelleeromgeving ({} meters) is groter dan het maximum van ({} meter). Probeer het nog eens.</p>'''.format(margin, maxmargin), -1, -1, -1, -1
        elif not(ok_margin_min):
            return False, '''<p>De grootte van de modelleeromgeving ({} meters) dient een veelvoud van de cellgrootte te zijn ({} meter). Probeer het nog eens.</p>'''.format(margin, minmargin), -1, -1, -1, -1
        elif not(ok_margin_z):
            return False, '''<p>De grootte van de modelleeromgeving is nul. Probeer het nog eens.</p>''', -1, -1, -1, -1
        else:
            inside = IO.insideLayer(x, y, layernb)
            if not(inside):
                return False, '''<p>Opgegeven locatie {} {} valt niet binnen het domein van het LHM. Het LHM is een model wat toepasbaar is binnen Nederland.</p>'''.format(xin, yin), -1, -1, -1, -1

        # Parameters check OK
        return True, '', x, y, xe, ye

    # ----------------------------------- #
    # MAIN: Execute WPS function
    # ----------------------------------- #
    def execute(self):
        # Read Config file
        CONF = nhimodel_CONF(CONFIG_FILE)
        self.config = CONF.readConfig()

        # Outputs prepare
        outdata = io.StringIO()
        values = {}

        # Output prepare
        IO = nhimodel_IO(self.config)

        # Inputs check
        absvolume = self.absvolume.getValue()
        margin = self.margin.getValue()
        layernb = self.layernb.getValue()
        layernv = self.layernv.getValue()
        location = self.location.getValue()
        logging.info('''INPUT [nhimodel]: absvolume={}, layernb={}, layernv={}, location={}'''.format(
            absvolume, layernb, layernv, str(self.location.getValue)))

        # Error messaging
        okparams, msg, x, y, xe, ye = self.check_inputs(
            IO, layernb, layernv, absvolume, margin, location)
        if not(okparams):
            logging.info(msg)
            values['error_html'] = msg
            json_str = json.dumps(values, use_decimal=True)
            outdata.write(json_str)
            self.json.setValue(outdata)
            return

        # Run model prepare
        RUN = nhimodel_RUN(self.config, TEMPLATE_RUN, TEMPLATE_IPF)

        # Get temporary directory
        tmpdir = RUN.getTempDir()
        name = os.path.basename(tmpdir)

        # Decide margin (if margin is -1, automatic)
        if margin == 0:
            margin = find_spreidingslengte(x, y)

        # Run model, get outputs
        ipffile = RUN.setupAbstractionIPF(tmpdir, x, y, absvolume)
        runfile, bbox_rdnew, bbox = RUN.setupModelRUN(
            tmpdir, ipffile, layernb, xe, ye, margin)
        RUN.runModel(runfile, tmpdir)
        logging.info('''evaluation layer {}'''.format(layernv))
        outputgtif = RUN.produceOutput(tmpdir, layernv)
        outputgtifrd = changeProjRaster28992(outputgtif)  # gtif rd_new
        outputshpiso = raster2isolines(outputgtifrd, 0.25)  # shp rd_new

        # Upload to GeoServer [geotiff + isolines] and get wms url
        wmslayer = IO.geoserverUploadGtif(outputgtifrd, tmpdir)
        zipshp = IO.zipShp(outputshpiso)
        wmslayeriso = IO.geoserverUploadShp(zipshp, tmpdir)
        IO.geoserverGroupLayers(name, wmslayer, wmslayeriso)

        # Setup outputs
        values = {}
        values['outputgtif'] = outputgtif
        values['wmslayer'] = wmslayer
        values['wmslayer_isolines'] = wmslayeriso
        values['bbox_rdnew'] = bbox_rdnew
        values['bbox'] = bbox

        # Send back JSON
        json_str = json.dumps(values, use_decimal=True)
        logging.info('''OUTPUT [nhimodel]: {}'''.format(json_str))
        outdata.write(json_str)
        self.json.setValue(outdata)

        return
