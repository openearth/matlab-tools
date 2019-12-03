from datetime import datetime

from Libraries.StandardFunctions import *
from Libraries.MapFunctions import CreateLineGeometry, CreatePointGeometry
from Libraries.NetworkFunctions import *
from Libraries.SobekWaterFlowFunctions import *

# create flowmodel
flowModel = WaterFlowModel1D()
AddToProject(flowModel)

#region create simple network containing 3 nodes and 2 branches

node1 = HydroNode(Name = "node1", Geometry = CreatePointGeometry(130000, 462000))
node2 = HydroNode(Name = "node2", Geometry = CreatePointGeometry(180000, 462000))
node3 = HydroNode(Name = "node3", Geometry = CreatePointGeometry(228000, 475000))
node4 = HydroNode(Name = "node4", Geometry = CreatePointGeometry(228000, 449000))

channel1 = Channel(Name = "channel1", Source = node1, Target = node2, Geometry = CreateLineGeometry([[130000, 462000],[180000, 462000]]))
channel2 = Channel(Name = "channel2", Source = node2, Target = node3, Geometry = CreateLineGeometry([[180000, 462000],[228000, 475000]]))
channel3 = Channel(Name = "channel3", Source = node2, Target = node4, Geometry = CreateLineGeometry([[180000, 462000],[228000, 449000]]))

flowModel.Network.Branches.AddRange([channel1, channel2, channel3])
flowModel.Network.Nodes.AddRange([node1, node2, node3, node4])

# create 6 cross sections and set their profile
crossSection1 = CreateBranchObjectOnBranchUsingChainage(BranchObjectType.CrossSectionZW, "Cs1", channel1, 0)
crossSection2 = CreateBranchObjectOnBranchUsingChainage(BranchObjectType.CrossSectionZW, "Cs2", channel1, 50000)
crossSection3 = CreateBranchObjectOnBranchUsingChainage(BranchObjectType.CrossSectionZW, "Cs3", channel2, 0)
crossSection4 = CreateBranchObjectOnBranchUsingChainage(BranchObjectType.CrossSectionZW, "Cs4", channel2, 49729.27)
crossSection5 = CreateBranchObjectOnBranchUsingChainage(BranchObjectType.CrossSectionZW, "Cs5", channel3, 0)
crossSection6 = CreateBranchObjectOnBranchUsingChainage(BranchObjectType.CrossSectionZW, "Cs6", channel3, 49729.27)

crossSectionProfile1 = [[8.36,300,0], # z, width, storage
                        [3.36,300,0]]

crossSectionProfile2 = [[3.36,300,0], # z, width, storage
                        [-1.64,300,0]]

crossSectionProfile3 = [[3.62,150,0], # z, width, storage
                        [-1.38,150,0]]

crossSectionProfile4 = [[-1.36,150,0], # z, width, storage
                        [-6.36,150,0]]

crossSectionProfile5 = [[0.44,100,0], # z, width, storage
                        [-4.56,100,0]]

crossSectionProfile6 = [[-4.359,100,0], # z, width, storage
                        [-9.359,100,0]]

SetCrossSectionProfile(crossSection1, crossSectionProfile1, 0) # thalweg = 0
SetCrossSectionProfile(crossSection2, crossSectionProfile2, 0) # thalweg = 0
SetCrossSectionProfile(crossSection3, crossSectionProfile3, 0) # thalweg = 0
SetCrossSectionProfile(crossSection4, crossSectionProfile4, 0) # thalweg = 0
SetCrossSectionProfile(crossSection5, crossSectionProfile5, 0) # thalweg = 0
SetCrossSectionProfile(crossSection6, crossSectionProfile6, 0) # thalweg = 0

st = FindOrCreateCrossSectionSectionType(flowModel.Network, "Main")

SetCrossSectionSection(crossSection1, 0, 300./2, st)
SetCrossSectionSection(crossSection2, 0, 300./2, st)
SetCrossSectionSection(crossSection3, 0, 150./2, st)
SetCrossSectionSection(crossSection4, 0, 150./2, st)
SetCrossSectionSection(crossSection5, 0, 100./2, st)
SetCrossSectionSection(crossSection6, 0, 100./2, st)

# add a lateral
#lateral = CreateBranchObjectOnBranchUsingChainage(BranchObjectType.LateralSource, "lateral1", channel2, 5 )

#endregion

#region set boundary conditions

# set boundary condition for node 1 to constant discharge 
SetBoundaryCondition(flowModel, "node1", BoundaryConditionType.FlowConstant, 2500)
# set boundary condition for node 3 and 4 to constant water level
SetBoundaryCondition(flowModel, "node3", BoundaryConditionType.WaterLevelConstant, 0)
SetBoundaryCondition(flowModel, "node4", BoundaryConditionType.WaterLevelConstant, 0)

# set lateral data for lateral1 to constant flow of 2
#SetLateralData(flowModel, "lateral1", LateralDataType.FlowConstant, 2)

#endregion

#region Set roughness

# set general (default) roughness value
SetDefaultRoughness(flowModel, "Main", RoughnessType.Chezy, 50)

AddRoughnessAtLocation(flowModel, "Main", channel1, 0, RoughnessType.Chezy, 50)
AddRoughnessAtLocation(flowModel, "Main", channel1, 50000, RoughnessType.Chezy, 50)
AddRoughnessAtLocation(flowModel, "Main", channel2, 0, RoughnessType.Chezy, 50)
AddRoughnessAtLocation(flowModel, "Main", channel2, 49729.27, RoughnessType.Chezy, 50)
AddRoughnessAtLocation(flowModel, "Main", channel3, 0, RoughnessType.Chezy, 50)
AddRoughnessAtLocation(flowModel, "Main", channel3, 49729.27, RoughnessType.Chezy, 50)

#SetRoughnessFunctionTypeByChannel(flowModel, "Main", channel2, RoughnessFuntionType.Waterlevel, locations, hList)

#endregion

#region set initial values

# set initial depth
#SetInitialConditionType(flowModel, InitialConditionType.Depth)

#flowModel.DefaultInitialDepth = 10

#AddInitialValueAtLocation(flowModel, channel1, 5.0, 7.0)
#AddInitialValueAtLocation(flowModel, channel1, 7.0, 5.0)
#AddInitialValueAtLocation(flowModel, channel2, 5.0, 9.0)

#endregion

# create computational grid with calculation points at every 0.5 m
CreateComputationalGrid(flowModel, gridAtFixedLength = True, fixedLength = 500)

# enable (add) output for (average)discharge on laterals
#EnableOutput(flowModel, ElementSet.Laterals, QuantityType.Discharge, AggregationOptions.Average )

# run model
#RunModel(flowModel)

# get timeseries for discharge at calculation point "channel 2_8.750"
#calculationPoint = GetComputationGridLocationByName(flowModel, "channel 2_8.750")
#timeSeriesPoint = GetTimeSeriesFromWaterFlowModel(flowModel, calculationPoint, "Discharge")

# get timeseries for discharge at lateral "lateral1"
#lateral = GetBranchObjectByType(flowModel.Network, BranchObjectType.LateralSource, "lateral1")
#timeSeriesLateral = GetTimeSeriesFromWaterFlowModel(flowModel, lateral, "Discharge (l) (Average)")

# export the timeseries to csv file
#ExportListToCsvFile("D:\\dischargeAtPoint.csv", timeSeriesPoint)
#ExportListToCsvFile("D:\\dischargeAtLateral.csv", timeSeriesLateral)

Application.SaveProjectAs("c:\\temp\\test_bif2.dsproj");
