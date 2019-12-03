from Libraries.Utils.Functions import *
from Libraries.MorphAn.Models import *
from Libraries.MorphAn.TransectOperations import *

erosionModel = GetModel("Erosion model")

erosionResults = erosionModel.ModelResult.ResultList

boundaryConditions = GetComponentByName(erosionModel.CalculationSelection.BoundaryConditions,"MaximumStormSurgeLevel")
for r in erosionResults:
    print "%s (%s)"%(r.Location.Name,r.Year)
    print "   X = %s,Y = %s,Angle = %s degrees"%(r.Location.X, r.Location.Y, r.Location.Angle)
    print "   Maximum retreat: %0.2f [m + RSP]" %(r.OutputPointR.X)
    print "   Maximum storm surge level: %0.2f [m + NAP]" %(boundaryConditions[r.Location])
    fullProfile = CreateExtendedProfile(r.OutputAdditionalErosionProfile,r.Input.InputProfile)
    print "   Remaining volume above MSSL: %0.2f [m^3]" % (CumulativeVolume(fullProfile,boundaryConditions[r.Location]))
