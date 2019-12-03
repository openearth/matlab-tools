from datetime import datetime

from Libraries.StandardFunctions import *
from Libraries.MapFunctions import CreateLineGeometry, CreatePointGeometry
from Libraries.NetworkFunctions import *
from Libraries.SobekWaterFlowFunctions import *

# create flowmodel
flowModel = WaterFlowModel1D()
AddToProject(flowModel)

#region create simple network containing 3 nodes and 2 branches

node1 = HydroNode(Name = "node1", Geometry = CreatePointGeometry(10, 10))
node2 = HydroNode(Name = "node2", Geometry = CreatePointGeometry(20, 20))
node3 = HydroNode(Name = "node3", Geometry = CreatePointGeometry(30, 25))

channel1 = Channel(Name = "channel 1", Source = node1, Target = node2, Geometry = CreateLineGeometry([[10, 10],[20, 20]]))
channel2 = Channel(Name = "channel 2", Source = node2, Target = node3, Geometry = CreateLineGeometry([[20, 20],[30, 25]]))

flowModel.Network.Branches.AddRange([channel1, channel2])
flowModel.Network.Nodes.AddRange([node1, node2, node3])

# create 2 cross sections and set their profile
crossSection1 = CreateBranchObjectOnBranchUsingChainage(BranchObjectType.CrossSectionYZ, "crossSection1", channel1, 7)
crossSection2 = CreateBranchObjectOnBranchUsingChainage(BranchObjectType.CrossSectionZW, "crossSection2", channel2, 7)

crossSectionProfile1 = [[0,0,0], # y, z, storage
                        [2,0,0],
                        [4,-10,0],
                        [6,-10,0],
                        [8,0,0],
                        [10,0,0]]

crossSectionProfile2 = [[0,10,0], # z, width, storage
                        [-2,8,0],
                        [-4, 6,0],
                        [-6, 2,0]]

SetCrossSectionProfile(crossSection1, crossSectionProfile1, 5) # thalweg = 5
SetCrossSectionProfile(crossSection2, crossSectionProfile2, 0) # thalweg = 0
SetCrossSectionSection(crossSection1, 0, 10, "Main")
SetCrossSectionSection(crossSection2, 0, 10, "Main")

# add a lateral
lateral = CreateBranchObjectOnBranchUsingChainage(BranchObjectType.LateralSource, "lateral1", channel2, 5 )

#endregion

#region set boundary conditions

# set boundary condition for node 1 to flow waterlevel table
list = [[1.0, 11.0],
        [2.0, 10.0],
        [3.0, 8.0],
        [4.0, 9.0],
        [5.0, 10.0]]

SetBoundaryCondition(flowModel, "node1", BoundaryConditionType.FlowWaterLevelTable, list)

# set boundary condition for node 3 to waterlevel timeseries
list = [[datetime(2014, 1, 1, 15, 0, 0), 11.0],
        [datetime(2014, 1, 1, 16, 0, 0), 10.0],
        [datetime(2014, 1, 1, 17, 0, 0), 8.0],
        [datetime(2014, 1, 1, 18, 0, 0), 9.0],
        [datetime(2014, 1, 1, 19, 0, 0), 10.0]]

SetBoundaryCondition(flowModel, "node3", BoundaryConditionType.WaterLevelTimeSeries, list)

# set lateral data for lateral1 to constant flow of 2 
SetLateralData(flowModel, "lateral1", LateralDataType.FlowConstant, 2)

#endregion

#region Set roughness

# set general (default) roughness value
SetDefaultRoughness(flowModel, "Main", RoughnessType.Chezy ,45)

AddRoughnessAtLocation(flowModel, "Main", channel1, 4, RoughnessType.Chezy, 42)
AddRoughnessAtLocation(flowModel, "Main", channel1, 8, RoughnessType.Chezy, 40)
AddRoughnessAtLocation(flowModel, "Main", channel1, 12, RoughnessType.Chezy, 45)

AddRoughnessAtLocation(flowModel, "Main", channel2, 4, RoughnessType.Chezy, 45)
AddRoughnessAtLocation(flowModel, "Main", channel2, 8, RoughnessType.Chezy, 45)
AddRoughnessAtLocation(flowModel, "Main", channel2, 12, RoughnessType.Chezy, 45)

# set roughness function for channel 2
locations = [4.0, 8.0, 12.0]
hList = [[10.0, 41.0, 42.0, 43.0], # h, 4, 8, 12
        [20.0, 42.0, 43.0, 45.0]]

SetRoughnessFunctionTypeByChannel(flowModel, "Main", channel2, RoughnessFuntionType.Waterlevel, locations, hList)

#endregion

#region set initial values

# set initial depth
SetInitialConditionType(flowModel, InitialConditionType.Depth)

flowModel.DefaultInitialDepth = 10

AddInitialValueAtLocation(flowModel, channel1, 5.0, 7.0)
AddInitialValueAtLocation(flowModel, channel1, 7.0, 5.0)
AddInitialValueAtLocation(flowModel, channel2, 5.0, 9.0)

#endregion

# create computational grid with calculation points at every 0.5 m
CreateComputationalGrid(flowModel, gridAtFixedLength = True, fixedLength = 0.5)

# enable (add) output for (average)discharge on laterals 
EnableOutput(flowModel, ElementSet.Laterals, QuantityType.Discharge, AggregationOptions.Average )

# run model
RunModel(flowModel)

# get timeseries for discharge at calculation point "channel 2_8.750"
calculationPoint = GetComputationGridLocationByName(flowModel, "channel 2_8.750")
timeSeriesPoint = GetTimeSeriesFromWaterFlowModel(flowModel, calculationPoint, "Discharge")

# get timeseries for discharge at lateral "lateral1"
lateral = GetBranchObjectByType(flowModel.Network, BranchObjectType.LateralSource, "lateral1")
timeSeriesLateral = GetTimeSeriesFromWaterFlowModel(flowModel, lateral, "Discharge (l) (Average)")

# export the timeseries to csv file
ExportListToCsvFile("D:\\dischargeAtPoint.csv", timeSeriesPoint)
ExportListToCsvFile("D:\\dischargeAtLateral.csv", timeSeriesLateral)

