# -*- coding: utf-8 -*-
# Copyright notice
#   --------------------------------------------------------------------
#   Copyright (C) 2015 Deltares
#       Gerrit Hendriksen, Maarten Pronk, Edwin Bos
#
#       gerrit.hendriksen@deltares.nl, maarten.pronk@deltares.nl, edwin.bos@deltares.nl
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

# $Id: infoline_redesigned.py 12746 2016-05-20 12:35:24Z pronk_mn $
# $Date: 2016-05-20 05:35:24 -0700 (Fri, 20 May 2016) $
# $Author: pronk_mn $
# $Revision: 12746 $
# $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/python/applications/infoline/infoline_redesigned.py $
# $Keywords: $

# core
import logging
import operator

# modules
import simplejson as json
import StringIO
from pywps.Process import WPSProcess

# relative
from GeoTop import GeoTopOnOpendap
from ahn2 import ahn
from opendap_nhi import nhi_invoer, zoetzout
from regis import regiswps


"""
Infoline WPS start script

This is a redesigned WPS for the InfoLine application.
    - Instead of returning multiple values we return one json.
    - Each external call is inside a try/except loop.
    - Only JSON formatting is done inside this function.

if it runs on localhost then:
getcapabilities:  http://localhost/cgi-bin/pywps.cgi?request=GetCapabilities&service=wps&version=1.0.0
describe process: http://localhost/cgi-bin/pywps.cgi?request=DescribeProcess&service=wps&version=1.0.0&identifier=infoline_wps_ol2
execute:          http://localhost/cgi-bin/pywps.cgi?request=Execute&service=wps&version=1.0.0&identifier=infoline_wps_ol2&datainputs=[project='Infoline';x_rd=148879;y_rd=456710;z_depth=47.5]
"""


class Process(WPSProcess):
    def __init__(self):
        # init process; note: identifier must be same as filename
        WPSProcess.__init__(self,
                            identifier="infoline_redesigned",
                            title="Infoline",
                            version="1.0",
                            storeSupported="true",
                            statusSupported="true",
                            abstract="""Infoline WPS gets data from various online subsurface resources in order to give information
                                        about status of subsurface in the Netherlands.
                                        Contributing to Infoline and Soilrisk are NHI (http://nhi.nu), Dinoloket (http://www.dinoloket.nl).
                                        See describeprocess for input and output parameters""",
                            grassLocation=False)

        self.x = self.addLiteralInput(identifier="x_rd",
                                      title="X coordinate in RD-New (EPSG28992)",
                                      type=type(0.0),
                                      default=93762)
        self.y = self.addLiteralInput(identifier="y_rd",
                                      title="Y coordinate in RD-New (EPSG28992)",
                                      type=type(0.0),
                                      default=450204)
        self.z = self.addLiteralInput(identifier="z_depth",
                                      title="Depth below surface layer",
                                      type=type(0.0),
                                      default=47.5)

        self.json = self.addComplexOutput(identifier="json",
                                          title="Returns list of values (lithology in case of Geotop in m below surface level) for specified xy",
                                          abstract="""For every geotop lithology top, bottom, lithology and hex colour is given. Origin of Geotop is http://www.dinodata.nl/opendap/""",
                                          formats=[{"mimeType": "text/plain"},  # 1st is default
                                                   {'mimeType': "text/html"}])

    def execute(self):

        x = self.x.getValue()
        y = self.y.getValue()
        z = self.z.getValue()

        json_output = StringIO.StringIO()
        values = {}

        # AHN
        try:
            hoogte = ahn(x, y)
            values['maaiveldhoogte'] = float(hoogte)
        except:
            hoogte = 0.0
            values['maaiveldhoogte'] = hoogte

        # Regis
        try:
            regis = regiswps(x, y)
            minv = regis[0][1]
            maxv = regis[-1][2]
            # regis runs from NAP, not maaiveld
            maaiveldverschil = regis[0][1]
            values['regis'] = {}
            values['regis']['min'] = float(maxv) - maaiveldverschil
            values['regis']['max'] = float(minv) - maaiveldverschil
            values['regis']['layers'] = []
            for layer in regis:
                fromv = float(layer[1]) - maaiveldverschil
                tov = float(layer[2]) - maaiveldverschil
                typev = layer[0]
                values['regis']['layers'].append(
                    {
                        "top": fromv, "bottom": tov, "type": typev
                    })
            values['regis']['layers'] = values['regis']['layers'][::-1]
        except:
            pass

        # Stenen

        try:
            grootrisico = ['Kreftenheye zand', 'Beegden zand', 'Drente zand', 'Drente Gieten klei',
                           'Urk zand', 'Sterksel zand', 'Appelscha zand', 'Oosterhout klei', 'Heyenrath complex']
            matigrisico = ['Tongeren Goudsberg klei', 'Rupel zand', 'Kiezeloliet klei', 'Kiezeloliet zand',
                           'Maassluis klei', 'Maassluis zand', 'Peize zand', 'Waalre zand', 'Urk klei', 'Drente Uitdam klei']

            # Top layer
            layer = values['regis']['layers'][-1]

            if layer in grootrisico:
                stonerisk = [
                    "Groot. Er is hier een grote kans op (grote) stenen in de grond."]

            elif layer in matigrisico:
                stonerisk = [
                    "Matig. Er is hier een matige kans op (grote) stenen in de grond."]

            else:
                stonerisk = [
                    "Klein. Er is hier weinig tot geen kans op (grote) stenen in de grond."]

        except:
            stonerisk = ["Geen data beschikbaar"]
            if 'regis' in values:
                values["regis"]["stoneRisk"] = stonerisk

        # Zoetzout grens
        try:
            zz = zoetzout(x, y)
            values['regis']['zoetzoutgrens'] = -float(zz)
            risk = ["Diepte zoutzoutgrens tov maaiveld (1000 mg/l Chloride-grens) ligt rond de {} meter.".format(zz),
                    "(Let op: hoe ondieper de zoet-zoutgrens, hoe nauwkeuriger de inschatting is.)"]
            values['zoetzoutrisico'] = risk
        except:
            pass

        # GeoTOP
        try:
            geotop = GeoTopOnOpendap(
                'd:\\data\\geotop.nc').get_all_layers(x, y)
            logging.info(geotop)
            minv = geotop[0][2]
            maxv = geotop[-1][3]
            values['geotop'] = {}
            values['geotop']['min'] = -float(maxv)
            values['geotop']['max'] = -float(minv)
            values['geotop']['layers'] = []
            for layer in geotop:
                fromv = -float(layer[2])
                tov = -float(layer[3])
                typev = layer[1]
                namev = layer[0]
                values['geotop']['layers'].append(
                    {
                        "top": fromv, "bottom": tov,
                        "type": typev, "name": namev
                    })

        except:
            pass

        # NHI
        try:
            values['nhi'] = {}
            ranges = [hoogte]
            fluxes = []
            values['nhi']['layers'] = []

            nhi = nhi_invoer(x, y)
            prev = float(hoogte)
            nhi_sort = sorted(nhi.items(), key=operator.itemgetter(0))

            for item in nhi_sort:
                key, value = item
                value = [float(x) if x is not None else None for x in value]
                flf, ghg, glg, top, base = value

                if not base or not top:
                    continue

                if base is not None:
                    ranges.append(base)
                if top is not None:
                    ranges.append(top)
                if flf is not None:
                    fluxes.append(flf)

                layer_fer = {"top": prev, "bottom": top,
                             "type": "aquifer", "GLG": glg, "GHG": ghg}
                layer_tar = {"flux": flf, "top": top,
                             "bottom": base, "type": "aquitard"}
                values['nhi']['layers'].append(layer_fer)
                values['nhi']['layers'].append(layer_tar)

                prev = base

            maaiveldhoogte = float(max(ranges))

            # Correction for maaiveld
            for layer in values['nhi']['layers']:
                layer['top'] -= maaiveldhoogte
                layer['bottom'] -= maaiveldhoogte

            # because we've corrected with maaiveldhoogte
            values['nhi']['max'] = 0
            values['nhi']['min'] = float(min(ranges)) - maaiveldhoogte
            values['nhi']['maxFlux'] = float(max(fluxes))
            values['nhi']['minFlux'] = float(max(fluxes))

        except:
            pass

        # Risk
        dictrisks = {}
        dictrisks['kleirisico'] = {True: ['Op deze locatie is er grote kans op 1 of meerdere slecht doorlatende lagen (klei of veen).'], False: [' Er is weinig tot geen kans op een slecht doorlatende laag (klei of veen) in de ondergrond.',
                                 ' Er is daardoor weinig tot geen kans op grondwateroverlast, perforatiestroming of verzilting.',
                                 ' Wanneer er sprake is van een stenenrisico is het mogelijk een spoelboring als een zuigboring uit te voeren, omdat de boor veelal groter is dan de stenen. Spoelboringen en zuigboringen zijn beide tevens zich geschikt voor het boren door grindbanken. Met behulp van pulsboren kunnen kleine stenen door de boorbuis omhoog worden gehaald, dit geldt ook voor grind.']}
        dictrisks['kleidiepte'] = {False: ['Er bevindt zich een slecht doorlatende laag direct aan het maaiveld (binnen 1 meter aan het maaiveld.'], True: [
                                                                                                                     'Er bevinden zich 1 of meerdere slecht doorlatende lagen dieper in de grond, niet direct aan het maaiveld.']}
        dictrisks['grondwater'] = {True: [' De stijghoogte van het water ligt boven de grondwaterstand.',
                                           ' Er is daarom hier een risico op grondwateroverlast.',
                                           ' Wanneer er sprake is van grondwateroverlast is zuigboren een schikte boormethode. Ook is het mogelijk een spoelboring uit te voeren. Let op: deze boormethoden hebben beide een  een grote diameter en daarbij risico op achterblijven wateroverspaningen door spuiten en transport van grond bij retourstroom. Wanneer er sprake is van grondwateroverlast is pulsboren een minder geschikte methode. Let erop dat het boorgat voldoende afgedicht wordt. Wanneer de grondwaterdruk boven maaiveld ligt, let er dan op dat u zich bij het boren verhoogd opgesteld heeft, op een platvorm. Dit is bij een handboring niet nodig.'], False: [' De stijghoogte van het water ligt waarschijnlijk onder de grondwaterstand.',
                                       ' Er is hier weinig tot geen risico op grondwateroverlast.']}
        dictrisks['perforatieomhoog'] = {True: ['Bij de slecht doorlatende laag/lagen dieper in de ondergrond ligt de stijghoogte van het water boven de grondwaterstand.',
                                         ' Er is daardoor een risico op opwaartse perforatiestroming (performatiestroming omhoog).',
                                         ' Wanneer er sprake is van perforatiestroming is zuigboren een schikte boormethode. Ook is het mogelijk een spoelboring uit te voeren. Let op: deze boormethoden hebben beide een  een grote diameter en daarbij risico op achterblijven wateroverspaningen door spuiten en transport van grond bij retourstroom. Wanneer er sprake is van perforatiestroming is pulsboren een minder geschikte methode. Let erop dat het boorgat voldoende afgedicht wordt.'],
                                         False: [' Er is hier geen sprake van opwaartse perforatiestoming.']}
        dictrisks['perforatieomlaag'] = {True: ['Bij de slecht doorlatende laag/lagen dieper in de ondergrond ligt de stijghoogte van het water onder de grondwaterstand.',
                                         ' Er is daardoor een risico op neerwaartse perforatiestroming (perforatiestroming omlaag).',
                                         ' Wanneer er sprake is van perforatiestroming is zuigboren een schikte boormethode. Ook is het mogelijk een spoelboring uit te voeren. Let op: deze boormethoden hebben beide een  een grote diameter en daarbij risico op achterblijven wateroverspaningen door spuiten en transport van grond bij retourstroom. Wanneer er sprake is van perforatiestroming is pulsboren een minder geschikte methode. Let erop dat het boorgat voldoende afgedicht wordt.'],
                                          False: [' Er is hier geen sprake van neerwaartse perforatiestoming.']}
        dictrisks['verzilting'] = {True: ['Wannner je dieper gaat boren dan de zoetzoutgrens is er kans op verzilting.',
                                   ' Wanneer er sprake is van verzilting is zuigboren een schikte boormethode. Ook is het mogelijk een spoelboring uit te voeren. Let op: deze boormethoden hebben beide een  een grote diameter en daarbij risico op achterblijven wateroverspaningen door spuiten en transport van grond bij retourstroom. Wanneer er sprake is van verzilting is pulsboren een minder geschikte methode. Let erop dat het boorgat voldoende afgedicht wordt.']}

        risks = {'kleirisico': None, 
                 'kleidiepte': None,
                 'grondwater': None,
                 'perforatieomhoog': None,
                 'perforatieomlaag': None,
                 'verzilting': True  # Always true
                }

        # Use regis for risks (if available)
        if 'regis' in values:
            for layer in values['regis']['layers']:
                if 'klei' in layer['type'] or 'Woudenberg veen' in layer['type']:
                    risks['kleirisico'] = True
                    if layer['bottom'] < 1:
                        risks['kleidiepte'] = False
                    else:
                        risks['kleidiepte'] = True
                    break
                else:
                    risks['kleirisico'] = False

        # Use geotop for risks (if available)
        elif 'geotop' in values:
            for layer in values['geotop']['layers']:
                if layer['type'] in ['klei zandig, leem, kleiig fijn zand', 'klei', 'organisch materiaal (veen)']:
                    risks['kleirisico'] = True
                    if layer['bottom'] < 1:
                        risks['kleidiepte'] = False
                    else:
                        risks['kleidiepte'] = True
                    break
                else:
                    risks['kleirisico'] = False

        # Use nhi for risks (if available)
        if 'nhi' in values:
            prev = None
            for layer in values['nhi']['layers']:
                # Only aquifers have glg & ghg
                if layer['type'] == 'aquifer':

                    # Only valid on first layer
                    if prev and not risks['grondwater']:
                        if prev['GHG'] < layer['GLG']:
                            risks['grondwater'] = True
                        else:
                            risks['grondwater'] = False

                    if prev:
                        if prev['GLG'] < layer['GHG']:
                            risks['perforatieomhoog'] = True
                        if prev['GHG'] > layer['GLG']:
                            risks['perforatieomlaag'] = True

                    prev = layer

        risktext = []
        for key, value in risks.iteritems():
            if value:
                risktext += dictrisks[key][value]

        values['risk'] = risktext

        logging.info(json.dumps(values, use_decimal=True))
        json_output.write(json.dumps(values, use_decimal=True))
        self.json.setValue(json_output)

        return

#if __name__ == "__main__":
#     logging.basicConfig(level=logging.INFO)
#     x = 86284.77925709795
#     y = 444435.04594442615
#    
#     p = Process()
#     p.execute()
