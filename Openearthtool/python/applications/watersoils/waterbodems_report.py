# -*- coding: utf-8 -*-
# Copyright notice
#   --------------------------------------------------------------------
#   Copyright (C) 2016 Deltares
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

# $Id: waterbodems_report.py 12746 2016-05-20 12:35:24Z sala_joan $
# $Date: 2016-08-22 14:35:24 +0200 (Mon, 22 Aug 2016) $
# $Author: sala $
# $Revision: 12746 $
# $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/python/applications/watersoils/waterbodems_report.py $
# $Keywords: $

# modules
import logging
import simplejson as json
import StringIO
from pywps.Process import WPSProcess

# Old tool
from kpp_tool_v1 import profieleffecten, watereffecten
from trees import Tree

"""
Waterbodems report WPS start script

This is a redesigned WPS for the Waterbodems application, based in infoline_redesigned.

if it runs on localhost then:
getcapabilities:  http://localhost/cgi-bin/pywps.cgi?request=GetCapabilities&service=wps&version=1.0.0
describe process: http://localhost/cgi-binpywps.cgi?request=DescribeProcess&service=wps&version=1.0.0&identifier=waterbodems_report
execute:          http://localhost/cgi-binpywps.cgi?&service=wps&request=Execute&version=1.0.0&identifier=waterbodems_report&datainputs=[ingreep=%22a%22;peilverschil=%22b%22;bodem=%22c%22;oever=%22d%22]
"""


class Process(WPSProcess):
    def __init__(self):
        # init process; note: identifier must be same as filename
        WPSProcess.__init__(self,
                            identifier="waterbodems_report",
                            title="waterbodems_report",
                            version="1.0",
                            storeSupported="true",
                            statusSupported="true",
                            abstract="""waterbodems report in txt format""",
                            grassLocation=False)
        
        # Input
        self.ingreep = self.addLiteralInput(identifier="ingreep", title="Ingreep selected value", type=type('string'), default="Verbreding")
        self.peilverschil = self.addLiteralInput(identifier="peilverschil", title="Peilverschil selected value", type=type('string'), default="hoger")
        self.bodem = self.addLiteralInput(identifier="bodem", title="Bodem selected value", type=type('string'), default="Bodem Afdichting")
        self.oever = self.addLiteralInput(identifier="oever", title="Oever selected value", type=type('string'), default="Oever Slib")
                                                    
        # Output
        self.json = self.addComplexOutput(identifier="json",
                                          title="Report analysis",
                                          abstract="""Report of the analysis of the bodem selected parameters""",
                                          formats=[{"mimeType": "text/plain"},  # 1st is default
                                                   {'mimeType': "application/json"}])

    def execute(self):
        
        # Input logging
        ingreep = self.ingreep.getValue()
        peilverschil = self.peilverschil.getValue()
        bodem = self.bodem.getValue()
        oever = self.oever.getValue()
        logging.info("Choice: [" + str(ingreep) + ', ' + str(peilverschil) + ', ' + str(bodem) + ', ' + str(oever) + "]")    
        
        # Output prepare
        json_output = StringIO.StringIO()
              
        # Effecten
        effecten = []

        # Profiel        
        T_profiel = Tree()
        T_profiel.add(bodem)
        T_profiel.add(oever)
        
        # Ingreep
        T_ingreep = Tree()                 
        for piece in ingreep.split(','):
            T_ingreep.add(piece)
            
        # Peilverschil
        if peilverschil == "False": peilverschil = False # stupid but needed
                
        effecten = profieleffecten(peilverschil, T_profiel, T_ingreep, effecten)
        effecten = watereffecten(peilverschil, T_profiel, T_ingreep, effecten)    
        
        logging.info('------------ EFFECTEN ------------')
        logging.info('\n'+str(effecten))
        
        # Report generate        
        tekst = report(effecten, T_ingreep, T_profiel)
        
        # Output write        
        json_str = json.dumps(tekst, use_decimal=True)
        json_output.write(json_str)
        self.json.setValue(json_output) 
        
        return
        
# Report functions
def report(effecten, Ingreep, Profiel):
   
    # De resulterende effecten in een bericht    
    eff_bot = ''
    
    if len(effecten) == 0:
        eff_bot += "De ingreep zal geen effect hebben op het grondwater in de omgeving \n"
    else:
        for i in effecten:
            eff_bot += "Er komt " + i[2] + ' ' + i[1].lower() + " door ingreep:  '" + i[0].lower() + "'\n"
        eff_bot += "\n \tRaadpleeg een adviseur over de grootte van de effecten en hun schaal. \n"
    
    # De risico's die deze effecten met zich meebrengen in een bericht
    riskdic = {'R1' : 'Grondwateroverlast in de omgeving door hogere grondwaterstanden.',
               'R2' : 'Schade bebouwing in de  omgeving door een verlaging van de grondwaterstand.',
               'R3' : 'Verslechtering waterkwaliteit omgeving.',
               'R4' : 'Verplaatsing van het verspreidingsgebied van een grondwaterverontreiniging in de omgeving.',
               'R5' : 'Extra aanvoer van water naar het kanaal nodig om het peil te handhaven.',
               'R6' : 'Droogte door verlaging van de grondwaterstand, kan schadelijk zijn voor gewassen en/of natuur.'}
        
    riskmes_bot = ''
    
    if len(effecten) == 0:
        riskmes_bot += "Er wordt geen effect van de ingreep verwacht \n"
    else:
        if any(i[1].lower() in ('meer inzijging','minder drainage') for i in effecten):
        # Als er "meer inzijging" of "minder drainage" in effecten staat, doe dan slechts 1 keer:
            riskmes_bot += '-' + riskdic['R1'] + '\n'
        if any(i[1].lower() in ('meer inzijging') for i in effecten):
            riskmes_bot += '-' + riskdic['R3'] + '\n'
            riskmes_bot += '-' + riskdic['R4'] + '\n'
            riskmes_bot += '-' + riskdic['R5'] + '\n'
        if any(i[1].lower() in ('minder inzijging', 'meer drainage') for i in effecten):
            riskmes_bot += '-' + riskdic['R2'] + '\n'
            riskmes_bot += '-' + riskdic['R6'] + '\n'
        if any(i[1].lower() in ('meer drainage') for i in effecten):   
            riskmes_bot += '-' + riskdic['R4'] + '\n'
            if Profiel.check_node('Oever Slib') == True or Profiel.check_node('Bodem Slib') == True or Profiel.check_node("Onbeslagen"):
                riskmes_bot += ' \n \tEr bestaat tevens de kans dat, door de grotere drainage, \n \ter opbarsting van aanwezig slib of de onbeslagen bodemafdichting kan\n \toptreden, wat weer leidt tot een nog grotere drainage. \n'
        
    # De maatregelen die genomen kunnen worden in een bericht          
    miti_bot = ''
    
    if len(effecten) == 0:
        miti_bot += 'Er hoeven geen maatregelen genomen te worden\n'
    else:
        if any(i[1].lower() in ('meer drainage','meer inzijging') for i in effecten) == True and any(i[1].lower() in ('minder drainage','minder inzijging') for i in effecten) == True:
            miti_bot += 'Er worden tegengestelde effecten verwacht. Raadpleeg een adviseur om uit te zoeken welk effect zal domineren. \n'
        
        else:
            if any(i[1].lower() in ('meer inzijging','meer drainage') for i in effecten):
            #Als er "meer inzijging" of "meer drainage" in effecten staat, doe dan slechts 1 keer:
                miti_bot += 'Weerstandsvermeerdering:'
                miti_bot += '\n\t-Schermen plaatsen die reiken tot weerstandslaag in de ondergrond'
                miti_bot += '\n\t-Injectie van een weerstand'
                miti_bot += '\n\t-Dichte bodem- en oeverconstructie aanleggen'
            
            if any(i[1].lower() in ('meer drainage',) for i in effecten):                
                miti_bot += ', let op dat deze beslagen moet zijn vanwege het risico op opbarsting.'
            
            if any(i[1].lower() in ('meer inzijging',) for i in effecten):
                miti_bot += '\n\t-Indien er een sedimentatieregime aanwezig is: slib opbrengen'
            
            if any(i[1].lower() in ('meer inzijging','meer drainage') for i in effecten):             
                miti_bot += '\n\nPeilverschilsvermindering:'
                if Ingreep.check_node("Peil kanaal omhoog") == False and Ingreep.check_node("Peil kanaal omlaag") == False:
                    miti_bot += '\n\t-Peil kanaal aanpassen'
                
                if Ingreep.check_node("Peil omgeving omhoog") == False and Ingreep.check_node("Peil omgeving omlaag") == False:
                    miti_bot += '\n\t-Peil omgeving aanpassen'
                    
            if any(i[1].lower() in ('minder drainage','minder inzijging') for i in effecten):
                miti_bot += 'Weerstandvermindering:'
                if Profiel.check_node("Bodem Kleilaag") == True or Profiel.check_node("Oever Kleilaag") == True:
                    miti_bot += '\n\t-Weerstandslagen afgraven'
                if Profiel.check_node("Bodem Afdichting") == True or Profiel.check_node("Oever Afdichting") == True:
                    miti_bot += '\n\t-Oever- of bodemconstructies verwijderen'
                if Profiel.check_node("Oever Slib") == True or Profiel.check_node("Bodem Slib") == True:
                    miti_bot += '\n\t-Baggeren'
                
                miti_bot += '\n\nPeilverschilvergroting:'
                if Ingreep.check_node("Peil kanaal omhoog") == False and Ingreep.check_node("Peil kanaal omlaag") == False:
                    miti_bot += '\n\t-Peil kanaal aanpassen'
                if Ingreep.check_node("Peil omgeving omhoog") == False and Ingreep.check_node("Peil omgeving omlaag") == False:
                    miti_bot += '\n\t-Peil omgeving aanpassen'
            
    # Voeg alle berichten samen in dit message scherm
    tekst = dict()
    tekst['eff'] = (eff_bot)
    tekst['riskmes'] = (riskmes_bot)
    tekst['miti'] = (miti_bot)
    
    return tekst

# Main (test)
if __name__ == "__main__":
    # Effecten
    effecten = []

    # Inputs
    ingdic=["Permanent>Profiel>Oever>Verbreding","Permanent>Profiel>Bodem>Verdieping","Permanent>Water>Peilwijziging>Peil kanaal omhoog", "Permanent>Water>Peilwijziging>Peil kanaal omlaag"]
    oevdic=['','Oever>Oever Kleilaag','Oever>Oever Slib','Oever>Oever Afdichting']
    bodic=['', 'Bodem>Bodem Kleilaag', 'Bodem>Bodem Slib','Bodem>Bodem Afdichting']
    peildic=["hoger","lager", False]
    
    # Profil selection   
    T_profiel = Tree()
    T_profiel.add(bodic[0])
    T_profiel.add(oevdic[0])

    # Peilverschil selection    
    peilverschil = peildic[0]
    
    # Ingreep
    ingreep = ingdic[2]
    T_ingreep = Tree()                 
    for piece in ingreep.split(','):
        T_ingreep.add(piece)

    print('------------ PROFIEL ------------')
    print('\n'+str(T_profiel))  
    print('------------ INGREEP ------------')
    print('\n'+str(T_ingreep))
    print('------------ peilverschil ------------')
    print('\n'+str(peilverschil))
   
    effecten = profieleffecten(peilverschil, T_profiel, T_ingreep, effecten)
    print('\n'+str(effecten))    
    effecten = watereffecten(peilverschil, T_profiel, T_ingreep, effecten)    
    print('\n'+str(effecten))
  
    print('------------------------')
    tekst = report(effecten, T_ingreep, T_profiel)
    print tekst
        
