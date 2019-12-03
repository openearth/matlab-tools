from Libraries.Duros.Duros import *

#region 1. Definieer invoer
x = [ -250.0, -24.375, 5.625, 55.725, 230.625, 2780.625 ]
z = [ 15.0, 15.0, 3.0, 0.0, -3.0, -20.0 ]
waterLevel = 5.0
Hs = 9
Tp = 16
D50 = 0.000250

#endregion


#region 2. Bereken Duros profiel
result = Duros(x,z,waterLevel,Hs,Tp,D50)

#endregion

#region 3. Print belangrijke getallen in Message window
print "============================================================================"
print "A volume : %0.0f [m^3/m]" % (result.OutputErosionVolumeAboveStormSurgeLevel)
print "T volume : %0.0f [m^3/m]" % (result.OutputAdditionalErosionVolume)
print "Xr       : %0.2f [m + RSP]" % (result.OutputPointRDuros.X)
print "Xr*      : %0.2f [m + RSP]" % (result.OutputPointR.X)
print "Duros uitkomsten"
print "============================================================================"

#endregion

#region 4. Toon berekend profiel in de interface
PlotDuros(result)

#endregion


