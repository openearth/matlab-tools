from datetime import datetime

from Libraries.StandardFunctions import *
from Libraries.MapFunctions import CreateLineGeometry, CreatePointGeometry
from Libraries.NetworkFunctions import *
from Libraries.SobekWaterFlowFunctions import *
from Libraries import Shortcuts
import os.path

def GetNormalizedZWTable(crs):
    """normalizes ZW table to a height between 0 and 1"""
    ZWTable = [[row[0], row[1], row[2]] for row in crs.Definition.RawData.Rows]
    ZWTable.sort(key = lambda x:x[0], reverse=True)
    ZW_zLow = ZWTable[-1][0]
    ZW_zHigh = ZWTable[0][0]
    ZWTable = [[round((row[0] - ZW_zLow)/(ZW_zHigh-ZW_zLow),15), row[1], row[2]] for row in ZWTable]
    return ZWTable, ZW_zHigh, ZW_zLow

def AddInterpolatedZToZWTable(ZWTable, Zi):
    """interpolates a ZW table to specified height values in place"""
    ZWTable.sort(key = lambda x:x[0], reverse=True)
    Z1 = [row[0] for row in ZWTable]
    W1 = [row[1] for row in ZWTable]
    S1 = [row[2] for row in ZWTable]
    Zi.sort(reverse=True)
    for Z in Zi:
        for k in range(len(Z1)-1,0,-1):
            if Z == Z1[k]:
                pass
            elif Z == Z1[k-1]:
                pass
            elif Z1[k-1] > Z > Z1[k]:
                alphaZ = (Z1[k-1]-Z)/(Z1[k-1]-Z1[k])
                W = W1[k-1]*(1-alphaZ) + W1[k]*(alphaZ)
                S = S1[k-1]*(1-alphaZ) + S1[k]*(alphaZ)
                ZWTable.append([Z, W, S])
    ZWTable.sort(key = lambda x:x[0], reverse=True)

def GetRoughnessSections(crs):
    sectionTable = []
    for section in crs.Definition.Sections:
        sectionTable.append([section.SectionType.Name, section.MinY, section.MaxY])
    return sectionTable

def InterpolateZWCrossSection(crs1, crs2, dx1, dx2):
    """interpolates ZW table based on defined cross-sections and distance to them"""
    alpha = dx2 / (dx1 + dx2)
    # Interpolate Thalweg
    Thalweg = crs1.Definition.Thalweg*alpha + crs2.Definition.Thalweg*(1-alpha)

    # Interpolate ZW Table
    ZWTable1_norm, ZW_zHigh1, ZW_zLow1 = GetNormalizedZWTable(crs1)
    ZWTable2_norm, ZW_zHigh2, ZW_zLow2 = GetNormalizedZWTable(crs2)
    Z1_norm = [row[0] for row in ZWTable1_norm]
    Z2_norm = [row[0] for row in ZWTable2_norm]
    ZUnique_norm = list(set(Z1_norm + Z2_norm))
    AddInterpolatedZToZWTable(ZWTable1_norm, ZUnique_norm)
    AddInterpolatedZToZWTable(ZWTable2_norm, ZUnique_norm)
    assert len(ZWTable1_norm) == len(ZWTable2_norm)
    ZWTable = []
    for k in range(len(ZUnique_norm)):
        assert ZWTable1_norm[k][0] == ZWTable2_norm[k][0]
        Z1 = ZWTable1_norm[k][0]*(ZW_zHigh1 - ZW_zLow1) + ZW_zLow1
        Z2 = ZWTable2_norm[k][0]*(ZW_zHigh2 - ZW_zLow2) + ZW_zLow2
        Z = Z1*alpha + Z2*(1-alpha)
        W = ZWTable1_norm[k][1]*alpha + ZWTable2_norm[k][1]*(1-alpha)
        S = ZWTable1_norm[k][2]*alpha + ZWTable2_norm[k][2]*(1-alpha)
        ZWTable.append([Z, W, S])
        ZWTable.sort(key = lambda x:x[0], reverse=True)

    # Interpolate summerdikes
    summerDike = []
    summerDike.append(crs1.Definition.SummerDike.Active \
                         or crs2.Definition.SummerDike.Active)
    if summerDike[0]:
        summerDike.append(crs1.Definition.SummerDike.CrestLevel*alpha + crs2.Definition.SummerDike.CrestLevel*(1-alpha))
        summerDike.append(crs1.Definition.SummerDike.FloodPlainLevel*alpha + crs2.Definition.SummerDike.FloodPlainLevel*(1-alpha))
        summerDike.append(crs1.Definition.SummerDike.FloodSurface*alpha + crs2.Definition.SummerDike.FloodSurface*(1-alpha))
        summerDike.append(crs1.Definition.SummerDike.TotalSurface*alpha + crs2.Definition.SummerDike.TotalSurface*(1-alpha))

    # Interpolate roughness sections
    sectionTable1 = GetRoughnessSections(crs1)
    sectionTable2 = GetRoughnessSections(crs2)
    sectionTable = []
    for k in range(len(sectionTable1)):
        assert sectionTable1[k][0] == sectionTable2[k][0] #If code fails here, the approach above could be used
        MinY = sectionTable1[k][1]*alpha + sectionTable2[k][1]*(1-alpha)
        MaxY = sectionTable1[k][2]*alpha + sectionTable2[k][2]*(1-alpha)
        sectionTable.append([sectionTable1[k][0], MinY, MaxY])

    return ZWTable, Thalweg, summerDike, sectionTable

def RemovePreviouslyInterpolatedZWCrossSections(model):
    """Remove previously interpolated cross-sections"""

    crs_to_forget = []
    for brn in model.Region.Branches:
        for crs in brn.CrossSections:
            if crs.Name.find('_ZWint_')>=0:
                crs_to_forget.append(crs)
        for crs in crs_to_forget:
            brn.BranchFeatures.Remove(crs)
            #print('Removing {:s}:{:s}'.format(brn, crs.Name))
    print ("Removal of interpolated ZW crossSections completed")


def GenerateInterpolatedZWCrossSections(model):
    """Generate interpolated cross-sections"""

    cross_section_index = os.path.join(model.WorkingDirectory,'ZW_Crossections_for_interpolation.txt')
    f = open(cross_section_index,'w')
    f.write('{:s};{:s};{:s};{:s}\n'.format('CrossSectionId','CrossSection name','Chainage','Branch name'))
    crsCount = 0
    for brn in model.Network.Branches:
        crossSectionsOnBranch = []
        for crs in brn.CrossSections:
            crossSectionsOnBranch.append(crs)
            f.write('{};{};{};{}\n'.format(crs.Id,crs.Name,crs.Chainage,brn))

        crossSectionsOnBranch.sort(key = lambda x:x.Chainage)

        for loc in model.NetworkDiscretization.Locations.AllValues:
            if loc.Branch == brn:
                for k in range(len(crossSectionsOnBranch)-1):
                    if loc.Chainage == crossSectionsOnBranch[k].Chainage:
                        #print('Skipping {:s}:{:s}'.format(brn,crossSectionsOnBranch[k].Name))
                        pass
                    elif loc.Chainage == crossSectionsOnBranch[k+1].Chainage:
                        #print('Skipping {:s}:{:s}'.format(brn,crossSectionsOnBranch[k+1].Name))
                        pass
                    elif crossSectionsOnBranch[k].Chainage < loc.Chainage < crossSectionsOnBranch[k+1].Chainage:
                        #print('Generating {:s}:{:s}'.format(brn,crs_interp_name))
                        crsCount += 1
                        crs_interp_name = '{:03d}_ZWint_{}_{}_X{:f}'.format(crsCount, crossSectionsOnBranch[k].Name, crossSectionsOnBranch[k+1].Name, loc.Chainage)
                        assert(len(crs_interp_name) <= 40, 'CrossSection Name too long ({})'.format(crs_interp_name))
                        crs_interp_ZWTable, crs_interp_Thalweg, crs_interp_summerDike, crs_interp_sectionTable = \
                               InterpolateZWCrossSection(crossSectionsOnBranch[k], crossSectionsOnBranch[k+1], loc.Chainage-crossSectionsOnBranch[k].Chainage, crossSectionsOnBranch[k+1].Chainage-loc.Chainage)
                        # Set new cross-section definition on branch
                        crs_new = CreateBranchObjectOnBranchUsingChainage(BranchObjectType.CrossSectionZW, crs_interp_name, brn, loc.Chainage)
                        ## Set new cross-section profile definition
                        SetCrossSectionProfile(crs_new, crs_interp_ZWTable, crs_interp_Thalweg)
                        ## Set new cross-section summerDike definition
                        crs_new.Definition.SummerDike.Active = crs_interp_summerDike[0]
                        if crs_new.Definition.SummerDike.Active:
                            crs_new.Definition.SummerDike.CrestLevel = crs_interp_summerDike[1]
                            crs_new.Definition.SummerDike.FloodPlainLevel = crs_interp_summerDike[2]
                            crs_new.Definition.SummerDike.FloodSurface = crs_interp_summerDike[3]
                            crs_new.Definition.SummerDike.TotalSurface = crs_interp_summerDike[4]
                        ## Set new cross-section sections definition
                        for row in crs_interp_sectionTable:
                    	    sectionType = FindOrCreateCrossSectionSectionType(model.Network, row[0])
                            SetCrossSectionSection(crs_new, row[1], row[2], sectionType)
        print ("Generation of interpolated ZW CrossSections completed")
    f.close()
    print ("Overview of original ZW CrossSections written to " + cross_section_index)

def ZWProfileInterpolation():
    # Select active model
    model = GetModelByName("Flow1D")
    #RemovePreviouslyInterpolatedZWCrossSections(model)
    GenerateInterpolatedZWCrossSections(model)

def DeleteZWProfileInterpolation():
    # Select active model
    model = GetModelByName("Flow1D")
    RemovePreviouslyInterpolatedZWCrossSections(model)

#Shortcuts.CreateShortcutButton("ZWi","Riverlab","Map",ZWProfileInterpolation,"globe.png")
Shortcuts._RemoveGroup("River Lab","Map")
pathdir = os.path.join('c:\\','Program Files (x86)','Deltares','SOBEK (3.7.13.40404)','plugins','DeltaShell.Plugins.Toolbox','Scripts','Libraries','images')
print(pathdir)
print(os.path.join(pathdir,"AddInterpolatedCrossSections.png"))
print(os.path.exists(os.path.join(pathdir,"AddInterpolatedCrossSections.png")))
Shortcuts.CreateShortcutButton("ZW Interp.","River Lab","Map",ZWProfileInterpolation,os.path.join(pathdir,"AddInterpolatedCrossSections.png"))
Shortcuts.CreateShortcutButton("Delete ZW Int.","River Lab","Map",DeleteZWProfileInterpolation,os.path.join(pathdir,"DeleteInterpolatedCrossSections.png"))

#TO DO: Add unit tests

#region List cross section + chainage
def getChainage(crs):
        return crs.Chainage

"""
model = GetModelByName("Flow1D")
for brn in model.Network.Branches:
    crossSectionsOnBranch = []
    for crs in brn.CrossSections:
        crossSectionsOnBranch = []
        #crossSectionsOnBranchChainage = []
        for crs in brn.CrossSections:
            crossSectionsOnBranch.append(crs)
            #crossSectionsOnBranchChainage.append(crs.Chainage)
    crossSectionsOnBranch.sort(key=getChainage)
    for crs in crossSectionsOnBranch:
    	print crs.Name, crs.Chainage
"""
#endregion
