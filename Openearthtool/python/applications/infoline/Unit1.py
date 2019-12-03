import math
from numba import jit
import fiona
from shapely.geometry import Polygon, MultiPolygon, shape, Point, mapping
from shapely.wkt import loads
from geojson import Polygon as Polygong
from geojson import MultiPolygon as MultiPolygong

# Pascal calls
Sin = math.sin
Cos = math.cos
Tan = math.tan
Power = math.pow
LN = math.log
Ln = math.log
Sqrt = math.sqrt
Pi = math.pi
Abs = abs
Min = min
Max = max
Arctan = math.atan


'''
Translated pascal code for DGeoPipeLine
'''

class Factors_class:
    pass

class GDRGlobals_class:

    def __init__(self):
        self.Factors = Factors_class
        self.Factors.SafetyCuCohesion = 1.4  # cu
        self.Factors.SafetyGamSoil = 1.1  # Gamma
        self.Factors.SafetyPhi = 1.1  # phi
        self.Factors.SafetyEMod = 1.25  # E

        self.Factors.CoversafetyDrained = 1
        self.Factors.CoversafetyUnDrained = 1

        self.MudPressData = Factors_class
        self.MudPressData.DiamProductPipe = 0.3
        self.MudPressData.MuBentonite = 0.000040
        self.MudPressData.TauBentonite = 0.014

GDRGlobals = GDRGlobals_class()


def korrelspanning(Zbuis, Zwater, regislagen):
    """ Sigma_v berekening
    Som van gewicht per laag * dichtheid (gamma) - (Zbuis - GWS)*10
    """
    total_weight = 0
    for laag in regislagen:
        dikte = laag[3]-laag[2]
        total_weight += dikte*grond_properties(laag[1], 'gamma', (0,0))
        if laag[3] > abs(Zbuis):
            dikte = abs(Zbuis) - laag[2]
            total_weight += dikte*grond_properties(laag[1], 'gamma', (0,0))
            #print total_weight, 11*Zbuis
            #print "Korrelspanning {}".format(total_weight - Pore_PressPn(Zbuis, Zwater))
            break
    return total_weight - Pore_PressPn(Zbuis, Zwater)


def get_ahn_wcs(coords):
    # TODO(Maarten) haal echte waarde op.
    return 0


def CalculateAverage(Zbuis, Dbuis, Maaiveldhoogte, regislagen, FXCoor):
    # LAvgGlijdingsModulus, lAvgPhi, LAvgCu, LAvgCoh = 45000, 32.5, 0, 0
    # LAvgGlijdingsModulus, lAvgPhi, LAvgCu, LAvgCoh = 3000, 22.5, 40, 5
    GlijdingsModulus, Phi, Cu, Coh = 0, 0, 0, 0
    H = Zbuis - regislagen[0][2]
    bovenliggend = 0
    tf = 0
    for i, laag in enumerate(regislagen):
        if laag[3] > Zbuis: # buis in this layer
            dikte = laag[3] - laag[2]
            f = (1/(0.5*Dbuis)) - 1/dikte
            #print
            tf += f
            GlijdingsModulus += f * grond_properties(laag[1], 'E', FXCoor)
            Phi += f * grond_properties(laag[1], 'phi', FXCoor)
            Cu += f * grond_properties(laag[1], 'cu', FXCoor)
            Coh += f * grond_properties(laag[1], 'c', FXCoor)
            break
        dikte = laag[3] - laag[2]
        dikte_o = regislagen[i+1][3] - regislagen[i+1][2]
        f = (1/(dikte_o)) - 1/(H-bovenliggend)
        bovenliggend += dikte
        tf += f
        # print f
        GlijdingsModulus += f * grond_properties(laag[1], 'E', FXCoor)
        Phi += f * grond_properties(laag[1], 'phi', FXCoor)
        Cu += f * grond_properties(laag[1], 'cu', FXCoor)
        Coh += f * grond_properties(laag[1], 'c', FXCoor)

    # ft = (1/(0.5*Dbuis))-(1/H)
    ft = tf

    LAvgGlijdingsModulus, lAvgPhi, LAvgCu, LAvgCoh = GlijdingsModulus / ft, Phi / ft, Cu / ft, Coh / ft
    #print "E {}, Phi {}, Cu {}, Coh {}".format(LAvgGlijdingsModulus, lAvgPhi, LAvgCu, LAvgCoh)
    return LAvgGlijdingsModulus, math.radians(lAvgPhi), LAvgCu, LAvgCoh


def CalculatedMaxRadiusInSand():
    pass


def Pore_PressPn(depth, gws):
    #print "Pore_press {}".format(10 * abs(depth - gws))
    return 10 * abs(depth - gws)


def grond_properties(grondsoort, key, coor):
    """Look up properties based on GeoTop lithok klasse."""

    lithok_translation = {
        'antropogeen': 2, # op aanraden van Hans
        'organisch materiaal (veen)': 1,
        'klei': 2,
        'klei zandig, leem, kleiig fijn zand': 3,
        'zand fijn': 5,
        'zand matig grof': 6,
        'zand grof': 7,
        'grind': 8,
        'schelpen': 9
    }

    keys = {
        'gamma': 0,
        'phi': 1,
        'c': 2,
        'cu': 3,
        'E': 6, # E = 4, Glij = 6
        'nu': 5
    }

    properties = {
        5: [20, 30, 0, 0, 30000, 0.3],
        6: [20, 32.5, 0, 0, 45000, 0.3],
        7: [21, 35, 0, 0, 45000, 0.3],
        2: [15, 22.5, 5, None, 3000, 0.35],
        1: [11, 15, 5, 10, 500, 0.4],
        3: [17, 27.5, 0, 40, 6000, 0.35],
        8: [21, 35, 0, 0, 75000, 0.3],
        0: [0, 0, 0, 0, 0, 0]
    }
    for i in properties:
        properties[i].append(properties[i][4]/(2*(1+properties[i][5])))

    if grondsoort in lithok_translation:
        gkey = lithok_translation[grondsoort]
        if key in keys:
            pkey = keys[key]
            value = properties[gkey][pkey]
            if value is None:
                # Read shapefile for reduction factor of cu gebieden.
                shapef = readshapefile("shape_reductie/Kansklassekaart_veen_&_organische_klei_dikker_dan_2m.shp")
                gebied = shapef.intersect(*coor)
                factor = cu_reductie(gebied)
                # print "Reading shapefile, factor = {}".format(factor)
                return 80 * factor
            else:
                return value
        else:
            return None
    else:
        return None

def cu_reductie(gebied):
    "Geeft reductie factor van cu voor elk gebied."
    if gebied == 1:
        return 1.0
    elif gebied == 2:
        return 0.5
    elif gebied == 3:
        return 0.35
    elif gebied == 4:
        return 0.25
    else:
        #print "CU_Reducatie gebied bestaat niet"
        return 1.0

class readshapefile:

    def __init__(self, fn):
        self.fn = fn
        self.data = {}
        self.lookup = {}
        with fiona.open(fn) as source:
            for row in source:
                self.data[row['properties'][u'OBJECTID_1']] = row['geometry']
                self.lookup[row['properties'][u'OBJECTID_1']] = row['properties'][u'Id']
            self.crs = source.crs

    def intersect(self, x, y):
        p = Point(x, y)
        sol = []
        for i, poly in self.data.iteritems():
            if poly['type'] == "Polygon":
                if Polygon(poly['coordinates'][0]).intersects(p):
                    sol.append(self.lookup[i])
            if poly['type'] == "MultiPolygon":
                for pol in poly['coordinates']:
                    if Polygon(pol[0]).intersects(p):
                        sol.append(self.lookup[i])
        return list(set(sol))[0]


#@jit(cache=True)
def GetZeroFunction(ADeltaPDeltaZ, AMuBentonite, ATauBentonite, A, B, ARPipe, ARHole):
    LX0 = ARPipe
    LX1 = ARHole + A
    LY0 = GetR0Function(ADeltaPDeltaZ, ATauBentonite, A, B, ARPipe, ARHole, LX0)
    LY1 = GetR0Function(ADeltaPDeltaZ, ATauBentonite, A, B, ARPipe, ARHole, LX1)
    # Test if a zero point lies between RPipe and  RPipe- A
    if (LY0 * LY1 > 0):
        Result = 0
    else:
        while 1:
            LX2 = (LX0 + LX1) * 0.5
            LY2 = GetR0Function(ADeltaPDeltaZ, ATauBentonite, A, B, ARPipe, ARHole, LX2)
            if (((LY0 > 0) and (LY2 < 0)) or ((LY0 < 0) and (LY2 > 0))):
                LX1 = LX2
            else:
                LX0 = LX2
                LY0 = LY2
            if Abs(LX1 - LX0) < 1.E-8:
                Result = LX2
                break
    return Result

# Oplossing r0


#@jit(cache=True)
def GetR0Function(ADeltaPDeltaZ, ATauBentonite, A, B, ARPipe, ARHole, ARValue):
    LTermLn = Ln((2 * ATauBentonite / ADeltaPDeltaZ + ARValue) * ARPipe / (ARValue * ARHole))
    LValue = ATauBentonite * ATauBentonite / ADeltaPDeltaZ + ATauBentonite * ARValue * (1 + LTermLn) - ATauBentonite * (ARPipe + ARHole)
    LValue = LValue + ADeltaPDeltaZ * 0.5 * ARValue * ARValue * LTermLn
    LValue = LValue + ADeltaPDeltaZ * 0.25 * (ARHole * ARHole - ARPipe * ARPipe)
    Result = LValue
    return Result

# Calculated flow rate Q


#@jit(cache=True)
def GetQFunction(ADeltaPDeltaZ, AMuBentonite, ATauBentonite, ARPipe, ARHole, ARPipeVal, ARHoleVal):
    # Constanten, l2, C2, C4
    LLambda = ATauBentonite * 2 * ARPipeVal / (ARHole * ARHole * ADeltaPDeltaZ) + (ARPipeVal / ARHole) * (ARPipeVal / ARHole)
    LC2 = 4 * ATauBentonite / (ARHole * ARHole * ADeltaPDeltaZ) * (ARPipeVal * Ln(ARPipe / ARHole) - ARPipe) - (ARPipe / ARHole) * (ARPipe / ARHole) + 2 * (ARPipeVal / ARHole) * (ARPipeVal / ARHole) * LN(ARPipe / ARHole)
    LC4 = 4. * ATauBentonite / (ARHole * ADeltaPDeltaZ) - 1

    # Bepaal het debiet Q
    LQ11 = -1. * GetFunctionQ(ADeltaPDeltaZ, -ATauBentonite, AMuBentonite, ARHole, LLambda, LC2, ARPipe)
    LQ12 = GetFunctionQ(ADeltaPDeltaZ, -ATauBentonite, AMuBentonite, ARHole, LLambda, LC2, ARPipeVal)
    LQ31 = -1. * GetFunctionQ(ADeltaPDeltaZ, ATauBentonite, AMuBentonite, ARHole, LLambda, LC4, ARHoleVal)
    LQ32 = GetFunctionQ(ADeltaPDeltaZ, ATauBentonite, AMuBentonite, ARHole, LLambda, LC4, ARHole)
    LQ2 = (ARPipeVal / ARHole) * (ARPipeVal / ARHole) - 2 * LLambda * Ln(ARPipeVal / ARHole) + LC2
    LQ2 = ADeltaPDeltaZ * ARHole * ARHole * 0.25 / AMuBentonite * LQ2
    LQ2 = Pi * (ARHoleVal * ARHoleVal - ARPipeVal * ARPipeVal) * (-ATauBentonite / AMuBentonite * ARPipeVal - LQ2)

    Result = LQ11 + LQ12 + LQ2 + LQ31 + LQ32
    return Result


#@jit(cache=True)
def GetFunctionQ(ADeltaPDeltaZ, ATauBentonite, AMuBentonite, ARHole, ALambda, AC, ARadius):
    LValue = -ALambda * (ARadius * ARadius * Ln(ARadius / ARHole) - 0.5 * ARadius * ARadius)
    LValue = LValue + 0.5 * AC * ARadius * ARadius
    LValue = LValue + 0.25 * Power(ARadius, 4) / (ARHole * ARHole)
    LValue = ADeltaPDeltaZ * ARHole * ARHole * 0.25 / AMuBentonite * LValue
    LValue = 2. * Pi * (ATauBentonite / 3 / AMuBentonite * Power(ARadius, 3) - LValue)

    Result = LValue
    return Result


#@jit(cache=True)
def GetRatioPressureDepth(ARequestedQ, ARPipe, ARHole, LMuBentonite, LTauBentonite):

    LDeltaPDeltaZA = 0
    LQA = 0

    # Calculate starting value
    LDeltaPDeltaZ = 2.0 * LTauBentonite / (ARHole - ARPipe) * 1.001
    if (Abs(LDeltaPDeltaZ) < 1.E-6):
        LDeltaPDeltaZ = 1.E-6

    # Start iteratieloop
    while 1:
        A = 2 * LTauBentonite / LDeltaPDeltaZ
        B = LDeltaPDeltaZ * ARHole * ARHole / LMuBentonite * 0.25
        LRPipeVal = GetZeroFunction(LDeltaPDeltaZ, LMuBentonite, LTauBentonite, A, B, ARPipe, ARHole)
        LRHoleVal = LRPipeVal + A
        LQ = GetQFunction(LDeltaPDeltaZ, LMuBentonite, LTauBentonite, ARPipe, ARHole, LRPipeVal, LRHoleVal)
        LReady = (LQ > ARequestedQ)
        if (not LReady):
            LQA = LQ
            LDeltaPDeltaZA = LDeltaPDeltaZ
            LDeltaPDeltaZ = 1.001 * LDeltaPDeltaZ
        if LReady:
            break

    LDeltaPDeltaZB = LDeltaPDeltaZ
    LQB = LQ
    # Requested discharge reached for LDeltaPDeltaZ between LDeltaPDeltaZA and DPDZB
    Result = LDeltaPDeltaZA + (LDeltaPDeltaZB - LDeltaPDeltaZA) * (ARequestedQ - LQA) / (LQB - LQA)
    return Result


###############################################################
# Berekening sterkte R
###############################################################

#@jit(cache=True)
def DetermineMaxMudPressure(ASigma, ARHole, AMaxRHole, APhiAvg, ACohAvg, AGlijAvg):
    CTol = 0.001
    if (APhiAvg <= CTol):
        # Cu material
        AMaxMudDef, AMaxMudCover = CuMaxMudPressurelCalculation(CTol, ASigma, ARHole, AGlijAvg, AMaxRHole, ACohAvg)
    else:
        # Phi material
        AMaxMudDef, AMaxMudCover = PhiMaxMudPressureCalculation(ASigma, APhiAvg, ACohAvg, AGlijAvg, ARHole, AMaxRHole)

    # negative values are not possible
    AMaxMudCover = max(0, AMaxMudCover)
    AMaxMudDef = max(0, AMaxMudDef)
    return AMaxMudDef, AMaxMudCover

################
#  alleen cover !
###############


#@jit(cache=True)
def CuMaxMudPressurelCalculation(CTol, ASigma, ARHole, AGlijAvg, AMaxRHole, ACohAvg):
    """Undrained"""
    #print "Using Undrained!"
    if (ACohAvg > CTol) and (AGlijAvg > CTol):
        LValue = ACohAvg * \
            (1 - LN(ACohAvg / AGlijAvg +
                    (ARHole / AMaxRHole) * (ARHole / AMaxRHole)))
        LValue = LValue + ASigma
    else:
        LValue = 0

    AMaxMudCover = LValue
    # deformation is 0 because phi =0. AMaxMudDef gets the value of a maxmud
    # cover
    AMaxMudDef = AMaxMudCover
    return AMaxMudDef, AMaxMudCover


#@jit(cache=True)
def PhiMaxMudPressureCalculation(ASigma, APhiAvg, ACohAvg, AGlijAvg, ARHole, AMaxRHole):
    """Drained"""
    #print "Using Drained!"
    # ASigma mag niet negatief zijn!! want dan wordt LQ ook negatief
    #print "ASigma {}".format(ASigma)
    LPf = ASigma * (1 + Sin(APhiAvg)) + ACohAvg * Cos(APhiAvg)
    LQ = (ASigma * Sin(APhiAvg) + ACohAvg * Cos(APhiAvg)) / AGlijAvg
    #print "LQ {}".format(LQ)
    # Dat heeft weer tot gevolg dat wordt getracht de wortel uit een negatief
    # getal te trekken!!
    # LocRMaxHole = Sqrt(ARHole * ARHole / LQ * 2 * CRekBoorgatWand) # don't use!
    # LBasis = (ARHole / LocRMaxHole) * (ARHole / LocRMaxHole) + LQ # dont't use!
    LBasis = LBasisOld = (ARHole / AMaxRHole) * (ARHole / AMaxRHole) + LQ
    LExponent = -Sin(APhiAvg) / (1 + Sin(APhiAvg))
    #print "LExponent {}".format(LExponent)
    #print "LBasisOld {}".format(LBasisOld)
    LPMaxOld = Power(LBasisOld, LExponent)
    if (AMaxRHole > 1E+29):
        # limit stress
        # by removing Rb/Rp ^ 2, only Q
        #print "LQ {}".format(LQ)
        LPMax = Power(LQ, LExponent)
        LPMaxOld = LPMax
    else:
        #print "LBasis {}".format(LBasis)
        LPMax = Power(LBasis, LExponent)
    AMaxMudCover = (LPf + ACohAvg / Tan(APhiAvg)) * LPMaxOld - ACohAvg / Tan(APhiAvg)
    AMaxMudDef = (LPf + ACohAvg / Tan(APhiAvg)) * LPMax - ACohAvg / Tan(APhiAvg)
    return AMaxMudDef, AMaxMudCover


#@jit(cache=True)
def CalculateMaxMudPressure(AYGroundLevel, AYBorderHoloceenPleistoceen, AYPipeCentre, ARHole, APipeCentreStress, AUseLineairAverage, FXCoor, regislagen, Zwater):
    """
    LSigma: Double # initial effective stress }
    LHeightPipeToGroundLevel: Double
    LHeightPipeToBorderHolPlei: Double # Heigth above pipe }
    LAvgCoh: Double # Average cohesion }
    LAvgCu: Double # Average cu }
    LAvgPhi: Double # Average angle of internal friction}
    LAvgGlijdingsModulus: Double # Average shear modulus      }
    LCohAvg: Double
    LCuAvg: Double
    LPhiAvg: Double
    LGlijAvg: Double
    LDRLimitCover: Double # Maximum and limit pressure }
    LDRLimitDeformation: Double # Maximum and limit pressure }
    LUMaxMudCover: Double
    LUMaxMudDeformation: Double
    LMaxRadiusBoreHole: Double # Maximal radius bore hole   }
    LCorrectedPhiGem: Double
    LIsUndrainedPresent: Boolean
    LMaxMudCover: Double
    LMaxMudDeformation: Double
    LPU: Double
    LFCu: Double
    LFPhi: Double
    LFGamma: Double
    LFGlij: Double
    LIsLineairCalculation: Boolean
    LTanPhi: Double
    """

    LIsLineairCalculation = AUseLineairAverage

    # Initialize
    LMaxMudCover = 0
    LMaxMudDeformation = 0

    # Safety factors
    LFCu = GDRGlobals.Factors.SafetyCuCohesion  # cu
    LFGamma = GDRGlobals.Factors.SafetyGamSoil  # Gamma
    LFPhi = GDRGlobals.Factors.SafetyPhi  # phi
    LFGlij = GDRGlobals.Factors.SafetyEMod  # E

    LIsUndrainedPresent = Abs(AYGroundLevel - AYBorderHoloceenPleistoceen) > 0.01
    #print "LIsUndrainedPresent {}".format(LIsUndrainedPresent)
    LSigma = 0.75 * APipeCentreStress  # s0' .75 * sv' / fy

    LHeightPipeToGroundLevel = AYGroundLevel - AYPipeCentre

    # Als de pijp onder de grond ligt:
    #print LHeightPipeToGroundLevel, 0.5 * GDRGlobals.MudPressData.DiamProductPipe
    if (LHeightPipeToGroundLevel > 0.5 * GDRGlobals.MudPressData.DiamProductPipe):

        if (AYBorderHoloceenPleistoceen <= AYPipeCentre):
            # Pipe in holoceen pakket
            # ... Calculate max mud pressure holoceen ...
            LAvgGlijdingsModulus, lAvgPhi, LAvgCu, LAvgCoh = CalculateAverage(AYPipeCentre, GDRGlobals.MudPressData.DiamProductPipe, AYGroundLevel, regislagen, FXCoor)

            # force cu material
            LPhiAvg = 0.000000000001  # zet op 0 => ongedraineerd
            LCohAvg = LAvgCu / LFCu
            LGlijAvg = LAvgGlijdingsModulus / LFGlij

            LMaxRadiusBoreHole = 0.5 * LHeightPipeToGroundLevel  # Rpmax = .5 * H
            LMaxMudDeformation, LMaxMudCover = DetermineMaxMudPressure(LSigma / LFGamma, ARHole, LMaxRadiusBoreHole, LPhiAvg, LCohAvg, LGlijAvg)

            # Calculate limit pressure
            LMaxRadiusBoreHole = 1.0E30
            LDRLimitDeformation, LDRLimitCover = DetermineMaxMudPressure(LSigma / LFGamma, ARHole, LMaxRadiusBoreHole, LPhiAvg, LCohAvg, LGlijAvg)

            LMaxMudCover = Min(0.9 * LDRLimitCover, LMaxMudCover)
            LMaxMudDeformation = Min(0.9 * LDRLimitDeformation, LMaxMudDeformation)
        else:
            # Pipe in pleistocene sand
            # ... Calculate max mud pressure pleistoceen ...
            LHeightPipeToBorderHolPlei = abs(AYBorderHoloceenPleistoceen - AYPipeCentre)
            #print "LHeightPipeToBorderHolPlei {}".format(LHeightPipeToBorderHolPlei)

            if (LHeightPipeToBorderHolPlei < 0.5 * GDRGlobals.MudPressData.DiamProductPipe):
                # if pipe is only part in pleistoceen only lineair calculation
                LIsLineairCalculation = True

            LAvgGlijdingsModulus, lAvgPhi, LAvgCu, LAvgCoh = CalculateAverage(AYPipeCentre, GDRGlobals.MudPressData.DiamProductPipe, AYGroundLevel, regislagen, FXCoor)

            # Eerst met de cu methode voor rpmax = 0.5 LHeightPipeToGroundLevel
            # LMaxRadiusBoreHole = GDRGlobals.Factors.CoversafetyUnDrained * LHeightPipeToGroundLevel
            LMaxRadiusBoreHole = 0.5 * LHeightPipeToGroundLevel

            # LMaxRadiusBoreHole = Min(LMaxRadiusBoreHole, LMaxRadiusBoreHole)  #, CalculatedMaxRadiusInSand(AYPipeCentre, LAvgGlijdingsModulus, lAvgPhi, LAvgCoh, APipeCentreStress, ARHole))

            LPhiAvg = 0.0000000001
            LCuAvg = LAvgCu / LFCu
            LGlijAvg = LAvgGlijdingsModulus / LFGlij

            LUMaxMudDeformation, LUMaxMudCover = DetermineMaxMudPressure(LSigma / LFGamma, ARHole, LMaxRadiusBoreHole, LPhiAvg, LCuAvg, LGlijAvg)

            # Reset LIsLineairCalculation
            # LIsLineairCalculation = AUseLineairAverage
            # TODO - okruse: klopt dit of moet het lineair blijven

            # Determine limit Pressure
            LMaxRadiusBoreHole = 1.0E30
            LDRLimitDeformation, LDRLimitCover = DetermineMaxMudPressure(LSigma / LFGamma, ARHole, LMaxRadiusBoreHole, LPhiAvg, LCuAvg, LGlijAvg)
            LUMaxMudCover = Min(0.9 * LDRLimitCover, LUMaxMudCover)
            LUMaxMudDeformation = Min(0.9 * LDRLimitDeformation, LUMaxMudDeformation)

            # TODO - okruse: factor op dekking Deze is dus vervangen
            # Vervolgens voor RpMax = 2 / 3 h
            # //   LMaxRadiusBoreHole = 2 / 3 * LHeightPipeToBorderHolPlei
            # LMaxRadiusBoreHole = GDRGlobals.Factors.CoversafetyDrained * LHeightPipeToBorderHolPlei
            LMaxRadiusBoreHole = 0.5 * LHeightPipeToBorderHolPlei

            # LAvgGlijdingsModulus, LAvgPhi, LAvgCu, LAvgCoh = CalculateAverage(AYPipeCentre, AYBorderHoloceenPleistoceen)
            LAvgGlijdingsModulus, LAvgPhi, LAvgCu, LAvgCoh = CalculateAverage(AYPipeCentre, GDRGlobals.MudPressData.DiamProductPipe, AYBorderHoloceenPleistoceen, regislagen, FXCoor)

            LCohAvg = LAvgCoh / LFCu
            LGlijAvg = LAvgGlijdingsModulus / LFGlij
            LTanPhi = Tan(LAvgPhi)
            #print "LTanPhi {} door LavGPhi {}".format(LTanPhi,LAvgPhi)
            LTanPhi = LTanPhi / LFPhi
            LCorrectedPhiGem = Arctan(LTanPhi)
            if (LCorrectedPhiGem < 0):
                LCorrectedPhiGem = LCorrectedPhiGem + Pi

            LMaxMudDeformation, LMaxMudCover = DetermineMaxMudPressure(LSigma / LFGamma, ARHole, LMaxRadiusBoreHole, LCorrectedPhiGem, LCohAvg, LGlijAvg)

            # Bereken de Limietdruk
            LMaxRadiusBoreHole = 1.0E30
            LDRLimitDeformation, LDRLimitCover = DetermineMaxMudPressure(LSigma / LFGamma, ARHole, LMaxRadiusBoreHole, LCorrectedPhiGem, LCohAvg, LGlijAvg)

            LMaxMudCover = Min(0.9 * LDRLimitCover, LMaxMudCover)
            LMaxMudDeformation = Min(0.9 * LDRLimitDeformation, LMaxMudDeformation)

            #print LUMaxMudCover, LMaxMudCover

            if LIsUndrainedPresent:
                LMaxMudCover = Max(LUMaxMudCover, LMaxMudCover)
                LMaxMudDeformation = Max(LUMaxMudDeformation, LMaxMudDeformation)

        # De eventuele waterspanning moet er nog bij
        LPU = Pore_PressPn(AYPipeCentre, Zwater)
        #print LPU, LMaxMudCover, LMaxMudDeformation
        AMaxMudCover = LMaxMudCover + LPU
        CNearZero = 0.000001
        if (LMaxMudDeformation > CNearZero):
            AMaxMudDeformation = LMaxMudDeformation + LPU
        else:
            AMaxMudDeformation = LMaxMudDeformation
    else:
        logging.info("Pijp bovengronds.")
    return AMaxMudCover, AMaxMudDeformation
