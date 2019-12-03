from System import Type

from Libraries.MapFunctions import CreatePointGeometry as _CreatePointGeometry
from Libraries.StandardFunctions import GetItemByName as _GetItemByName

from DelftTools.Hydro import HydroNetwork, Channel, HydroNode, LateralSource, ObservationPoint, Retention, IStructure
from DelftTools.Hydro.Structures import Pump, Weir, Bridge, ExtraResistance, Culvert, BridgeType, BridgeFrictionType
from DelftTools.Hydro.CrossSections import CrossSection, CrossSectionType
from DelftTools.Hydro.CrossSections import CrossSectionDefinitionZW as _CrossSectionDefinitionZW
from DelftTools.Hydro.CrossSections import CrossSectionDefinitionYZ as _CrossSectionDefinitionYZ
from DelftTools.Hydro.CrossSections import CrossSectionSection, CrossSectionSectionType
from DelftTools.Hydro.Helpers.HydroNetworkHelper import AddStructureToExistingCompositeStructureOrToANewOne as _AddStructureToExistingCompositeStructureOrToANewOne
from DelftTools.Hydro.Helpers.HydroNetworkHelper import RemoveStructure as _RemoveStructure

from NetTopologySuite.Extensions.Coverages import NetworkLocation as _NetworkLocation
from NetTopologySuite.Extensions.Networks.NetworkHelper import AddBranchFeatureToBranch as _AddBranchFeatureToBranch

class CrossSectionDefinitionType:
    """Type of crossSection definition"""
    ZW = 0
    YZ = 1

class BranchObjectType:
    """Defines the type of the network object"""
    ObservationPoint = 0
    LateralSource = 1
    Pump = 4
    Retention = 5
    Weir = 6
    Culvert = 7
    Bridge = 8
    ExtraResistance = 9
    CrossSectionYZ = 10
    CrossSectionZW = 11    

def CreateBranchObjectOnBranchUsingXY(BranchObjectType, name, branch, x, y):
    """Creates an network object and adds it to a specific branch using x,y location"""
    networkObject = CreateBranchObjectFromType(BranchObjectType)
    return AddToBranch(networkObject ,name, branch, x, _CreatePointGeometry(x,y))

def CreateBranchObjectOnBranchUsingChainage(BranchObjectType, name, branch, chainage):
    """Creates an network object and adds it to a specific branch using chainage"""
    networkObject = CreateBranchObjectFromType(BranchObjectType)
    return AddToBranch(networkObject, name, branch, chainage, _NetworkLocation(branch, chainage).Geometry)

def RemoveBranchObject(branchFeature):
    """Remove a network object"""
    print "removing", branchFeature.Name, branchFeature.Geometry, branchFeature.Chainage
    _RemoveStructure(branchFeature)

def AddToBranch(branchFeature, name, branch, chainage, geometry):
    """Creates the branchfeature to the the branch and updates the geometry of the branchfeature"""
    branchFeature.Name = name
    branchFeature.Geometry = geometry

    if (isinstance(branchFeature, IStructure)):
        branchFeature.Chainage = chainage
        _AddStructureToExistingCompositeStructureOrToANewOne(branchFeature,branch)
    else :
        _AddBranchFeatureToBranch(branchFeature, branch, chainage)
    return branchFeature

def CreateBranchObjectFromType(branchObjectType):
    """Gets a branch object using branch object type"""
    if (branchObjectType == BranchObjectType.Retention):
        return Retention()
    elif (branchObjectType == BranchObjectType.Bridge):
        return Bridge()
    elif (branchObjectType == BranchObjectType.LateralSource):
        return LateralSource()
    elif (branchObjectType == BranchObjectType.CrossSectionYZ):
        return CrossSection(_CrossSectionDefinitionYZ())
    elif (branchObjectType == BranchObjectType.CrossSectionZW):
        return CrossSection(_CrossSectionDefinitionZW())
    elif (branchObjectType == BranchObjectType.ExtraResistance):
        return ExtraResistance()
    elif (branchObjectType == BranchObjectType.Pump):
        return Pump()
    elif (branchObjectType == BranchObjectType.Weir):
        return Weir()
    elif (branchObjectType == BranchObjectType.ObservationPoint):
        return ObservationPoint()
    elif (branchObjectType == BranchObjectType.Culvert):
        return Culvert()

def GetBranchObjectByType(network, branchObjectType, objectName):
    """Gets a branch object using branch object type and name"""
    if (branchObjectType == BranchObjectType.Retention):
        return _GetItemByName(network.Retentions, objectName)
    elif (branchObjectType == BranchObjectType.Bridge):
        return _GetItemByName(network.Bridges, objectName)
    elif (branchObjectType == BranchObjectType.LateralSource):
        return _GetItemByName(network.LateralSources, objectName)
    elif (branchObjectType == BranchObjectType.CrossSectionYZ or
          branchObjectType == BranchObjectType.CrossSectionZW):
        return _GetItemByName(network.CrossSections, objectName)
    elif (branchObjectType == BranchObjectType.ExtraResistance):
        return GetItemByName(network.ExtraResistances, objectName)
    elif (branchObjectType == BranchObjectType.Pump):
        return _GetItemByName(network.Pumps, objectName)
    elif (branchObjectType == BranchObjectType.Weir):
        return _GetItemByName(network.Weirs, objectName)
    elif (branchObjectType == BranchObjectType.ObservationPoint):
        return _GetItemByName(network.ObservationPoints, objectName)
    elif (branchObjectType == BranchObjectType.Culvert):
        return _GetItemByName(network.Culverts, objectName)

def SetCrossSectionProfile(crossSection, crossSectionProfileList, thalweg):
    """Sets the profile for the provided crossSection
    (Works for YZ and ZW crossSections)"""
    if (crossSection.CrossSectionType == CrossSectionType.YZ):
        crossSection.Definition.YZDataTable.Clear()
        for item in crossSectionProfileList:
            crossSection.Definition.YZDataTable.AddCrossSectionYZRow(item[0], item[1], item[2])
        crossSection.Definition.Thalweg = thalweg
    elif(crossSection.CrossSectionType == CrossSectionType.ZW):
        crossSection.Definition.ZWDataTable.Clear()
        for item in crossSectionProfileList:
            crossSection.Definition.ZWDataTable.AddCrossSectionZWRow(item[0], item[1], item[2])
        crossSection.Definition.Thalweg = thalweg
    else:
        print "Can not set profile for cross section"

def MergeNodesWithSameGeometry(network):
    """Merges nodes that have the same geometry"""
    nodeDictionary = {}
    nodeList = list(network.Nodes)
    for node in nodeList:
        if (nodeDictionary.has_key(node.Geometry)):
            for branch in network.Branches:
                if (branch.Source == node):
                    branch.Source = nodeDictionary[node.Geometry]
                elif (branch.Target == node):
                    branch.Target = nodeDictionary[node.Geometry]
            network.Nodes.Remove(node)
            print "Merged nodes " + node.Name + " and " +  nodeDictionary[node.Geometry].Name
        else:
            nodeDictionary[node.Geometry] = node

def FindOrCreateCrossSectionSectionType(network, sectionTypeName):
    sectionType = _GetItemByName(network.CrossSectionSectionTypes, sectionTypeName)
    if (sectionType == None):
    	sectionType = CrossSectionSectionType(Name = sectionTypeName)
    	network.CrossSectionSectionTypes.Add(sectionType)
    return sectionType

def SetCrossSectionSection(crossSection, MinY, MaxY, sectionType):
    section = CrossSectionSection(MinY = MinY, MaxY = MaxY, SectionType = sectionType)
    crossSection.Definition.Sections.Add(section)
