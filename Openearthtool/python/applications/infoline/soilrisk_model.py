#!/usr/bin/env python
# -*- coding: utf-8 -*-
# @Author: pronk_mn
# @Date:   2015-12-01 13:17:30
# @Last Modified by:   pronk_mn
# @Last Modified time: 2015-12-03 14:28:38

import math
from Unit1 import *
from GeoTop import GeoTopOnOpendap
import logging

def risk1(l_coord=(2, 2), Zbuis=15, Dbuis=0.4, Mbuis="Staal", Lbuis=300, Zwater=3):
    """
    E benodigde druk
    R weerstand grond
    Classificatie op basis van R/E."""

    # invoer gebruiker
    l_coord = 88122, 446171  # x, y in NL, via kaart
    lx, ly = l_coord
    Zbuis = -18  # meter onder maaiveld
    Dbuis = 0.3  # m diameter
    Mbuis = "Staal"  # Materiaal, staal, PE, overig
    Lbuis = 300  # lengte van buis in m
    Zwater = -1  # grondwaterstand onder maaiveld in m

    # vaste invoer
    Gamma_df = 11.1
    Yieldpoint_df = 0.014
    LTauBentonite = Yieldpoint_df
    Viscosity_df = 0.000040
    LMuBentonite = Viscosity_df
    Qann = 300
    Qann = 0.05  # M^3 / s instead of L/m
    F_loss = 0.3

    # afgeleide parameters

    # Alpha, intredehoek
    if Dbuis < 0.4:
        Alpha = math.radians(10)
    else:
        Alpha = math.radians(15)

    # R, boogstraal bocht
    if Mbuis == "Staal":
        R = 1000 * Dbuis
    elif Mbuis == "PE":
        R = 100 * Dbuis
    else:
        R = 10 * Dbuis

    # Z_0, afhankelijk van geotop en grond
    if Lbuis < 500:
        Dpilot = .114
        Dpilothole = .250
    else:
        Dpilot = .165
        Dpilothole = .350

    #logging.info( "Dpilot, Dpilothole {} {}".format(Dpilot, Dpilothole)
    # Maaiveldhoogte
    Z_MV = get_ahn_wcs(l_coord)

    # Gecorrigeerde hoogte
    Z_0 = Zbuis - Z_MV

    # ???
    # sigma_v = 1
    # F_gamma = 1
    # Rb = Dpilothole * 0.5
    # Sigma_0 = 0.75 * sigma_v / F_gamma

    # Grondopbouw from GeoTOP
    # TODO(Maarten) haal geotop hier

    url, x, y = "http://opendap.dinoservices.nl/GeoTOP/geotop.nc", lx, ly
    # url, x, y = "/media/epta/data/geodata/geotop.nc", lx, ly
    logging.info(url)
    regislagen = GeoTopOnOpendap(url).get_all_layers(x, y)

    # regislagen = [[1, 'klei', 0, 15.5], [2, 'zand matig grof', 15.5, 30]]

    # for laag in regislagen:
        # logging.info( laag[1],laag[2],laag[3]-laag[2]
    # GWS
    # GWS = Zwater  # ?!

    ##############################
    # berekening belasting E

    # P1 diepste punt leiding
    p1 = Gamma_df * abs(Zbuis)
    #logging.info( "P1 {}".format(p1)

    # L = L1, 2, 3
    #logging.info( "z_0 {} ".format(Z_0)
    L1 = Z_0 / math.sin(Alpha)
    L2 = Lbuis - (2 * Z_0 / math.tan(Alpha))
    L3 = R * math.tan(0.5 * Alpha)
    L = L1 + L2 - L3
    #logging.info( "L is {}".format(L)
    # logging.info( Alpha, R

    # dp/dz flow resistance
    # minimale druk om liquid te laten teruglopen
    # pressure Q is gelijk aan Q_reg
    R0 = 0.5 * Dpilot  # ARadius & ARPipe
    R1 = 0.5 * Dpilothole   # ARHole
    #logging.info( "R0 {}, R1 {}".format(R0, R1)

    Q_req = Qann * (1 - F_loss)
    #logging.info( "Q_req {}".format(Q_req)

    dpdz = GetRatioPressureDepth(Q_req, R0, R1, LMuBentonite, LTauBentonite)
    #logging.info( "dpdz {}".format(dpdz)

    # P2 Grootste druk (net voor terug omhoog)
    p2 = dpdz * L
    #logging.info( "P1 {}, P2 {}, p_min {}".format(p1, p2, p1+p2)
    # minimaal benodigde muddruk
    p_min = p1 + p2

    ##############################
    # berekening sterkte R

    # leiding in pakket x:
    # als x is zand -> grens met klei erboven
    # als x klei is -> grens met zand beneden

    # logging.info( regislagen
    laag_i = 0
    up = 1
    for i, laag in enumerate(regislagen):
        if laag[3] > Zbuis:  # current stuff
            laag_i = i
            #logging.info( laag
            if laag[1] == 'klei' or laag[1] == 'organisch materiaal (veen)':
                # logging.info( laag
                up = 0
            else:
                up = 1
            break

    border = Z_MV
    if up == 1:
        #logging.info( "Going up"
        for laag in regislagen[:laag_i][::-1]:
            if laag[1] == 'klei' or laag[1] == 'organisch materiaal (veen)':
                border = laag[3]
                break
    else:
        #logging.info( "Going down"
        for laag in regislagen[laag_i:]:
            if laag[1] != 'klei' and laag[1] != 'organisch materiaal (veen)':
                border = laag[2]
                break


    #logging.info( "Border {}".format(border)
    # border boven leiding = gedraineerd!

    p_max, p_def = CalculateMaxMudPressure(Z_MV, -border, Zbuis, R1, korrelspanning(Zbuis, Zwater, regislagen), True, l_coord, regislagen, Zwater)
    #logging.info( "P_max {}, P_def {}".format(p_max, p_def)

    ################################
    # Resultaat en verhouding

    def risk_class(sf):
        """Geeft kans en kleur terug adhv safetyfactor invoer."""
        if sf > 1.5:
            return "Zeer gering", "Groen"
        elif sf > 1.3:
            return "Klein", "Geel"
        elif sf > 1.1:
            return "Matig", "Oranje"
        elif sf > 1.0:
            return "Groot", "Rood"
        else:
            return "Zeer groot", "Donkerrood"

    SF = p_max / p_min

    return(p_min, p_max, SF, risk_class(SF),regislagen)

if __name__ == "__main__":
    logging.info(risk1())
    #s = shape("D:/svn/SoilRisk/shape_reductie/Kansklassekaart_veen_&_organische_klei_dikker_dan_2m.shp")
    # logging.info( s.intersect(79541, 456266)
    # logging.info( s.intersect(84585, 445598)
