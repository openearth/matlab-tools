%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision$
%$Date$
%$Author$
%$Id$
%$HeadURL$
%
%Create NetCDF file of a 1D grid for Delft3D FM.

function NC_create_1D_grid(filename,network,varargin)

%% PARSE

parin=inputParser;

addOptional(parin,'fid_log',NaN)

parse(parin,varargin{:})

fid_log=parin.Results.fid_log; 

%% UNPACK

v2struct(network); %A bit hidden. It unpacks network data
% network_branch_id=network.network_branch_id; %better to specify each of them?

% network_edge_nodes,network_branch_id,network_edge_length,network_node_id,network_node_x,network_node_y, ...
%                 network_geom_node_count,network_geom_x,network_geom_y,network_branch_order,network_branch_type, ...
%                 mesh1d_node_branch,mesh1d_node_offset,mesh1d_node_x,mesh1d_node_y,mesh1d_edge_branch,mesh1d_edge_offset,mesh1d_edge_x,mesh1d_edge_y,mesh1d_node_id,mesh1d_node_long_name,mesh1d_edge_nodes ...
                

%% Change cell input to char

strLengthIds=40;
strLengthLongNames=80;

network_branch_id=cell2char(network_branch_id,strLengthIds); %!ATTENTION change of type
network_branch_long_name=cell2char(network_branch_long_name,strLengthLongNames); %!ATTENTION change of type
network_node_id=cell2char(network_node_id,strLengthIds); %!ATTENTION change of type
network_node_long_name=cell2char(network_node_long_name,strLengthLongNames); %!ATTENTION change of type
mesh1d_node_id=cell2char(mesh1d_node_id,strLengthIds); %!ATTENTION change of type
mesh1d_node_long_name=cell2char(mesh1d_node_long_name,strLengthLongNames); %!ATTENTION change of type

%% Create NetCDF file

try %in case there is an error, we want to close the file to prevent hanging handles 

% ncid = netcdf.create(filename, 'NETCDF4');
ncid = netcdf.create(filename, 'CLASSIC_MODEL');

%% DEFINITION

%% Define dimensions

network_nEdges=numel(network_branch_type); %i.e., number of branches
network_nNodes=numel(network_node_x);
network_nGeometryNodes=numel(network_geom_x); 
mesh1d_nNodes=numel(mesh1d_node_offset);
mesh1d_nEdges=numel(mesh1d_edge_offset); %first each branch is full

dim_network_nEdges         = netcdf.defDim(ncid, 'network_nEdges', network_nEdges); 
dim_network_nNodes         = netcdf.defDim(ncid, 'network_nNodes', network_nNodes);
dim_network_nGeometryNodes = netcdf.defDim(ncid, 'network_nGeometryNodes', network_nGeometryNodes);
dim_strLengthIds   = netcdf.defDim(ncid, 'strLengthIds', strLengthIds);
dim_strLengthLongNames   = netcdf.defDim(ncid, 'strLengthLongNames', strLengthLongNames);
dim_Two                    = netcdf.defDim(ncid, 'Two', 2);
dim_mesh1d_nNodes          = netcdf.defDim(ncid, 'mesh1d_nNodes', mesh1d_nNodes);
dim_mesh1d_nEdges          = netcdf.defDim(ncid, 'mesh1d_nEdges', mesh1d_nEdges);

%% Define variables and attributes

% | Type Name | NetCDF constant | MATLAB type |
% | --------- | --------------- | ----------- |
% | `byte`    | `NC_BYTE`       | `int8`      |
% | `char`    | `NC_CHAR`       | `char`      |
% | `short`   | `NC_SHORT`      | `int16`     |
% | `int`     | `NC_INT`        | `int32`     |
% | `float`   | `NC_FLOAT`      | `single`    |
% | `double`  | `NC_DOUBLE`     | `double`    |

var_network = netcdf.defVar(ncid, 'network',netcdf.getConstant('NC_INT'), []);
var_network_edge_nodes = netcdf.defVar(ncid, 'network_edge_nodes',netcdf.getConstant('NC_INT'), [dim_Two dim_network_nEdges]);
var_network_branch_id  = netcdf.defVar(ncid, 'network_branch_id', netcdf.getConstant('NC_CHAR'), [dim_strLengthIds,dim_network_nEdges]);
var_network_branch_long_name  = netcdf.defVar(ncid, 'network_branch_long_name', netcdf.getConstant('NC_CHAR'), [dim_strLengthLongNames,dim_network_nEdges]);
var_network_edge_length  = netcdf.defVar(ncid, 'network_edge_length', netcdf.getConstant('NC_DOUBLE'), dim_network_nEdges);
var_network_node_id = netcdf.defVar(ncid, 'network_node_id', netcdf.getConstant('NC_CHAR'), [dim_strLengthIds,dim_network_nNodes]);
var_network_node_long_name = netcdf.defVar(ncid, 'network_node_long_name', netcdf.getConstant('NC_CHAR'), [dim_strLengthLongNames,dim_network_nNodes]);
var_network_node_x = netcdf.defVar(ncid, 'network_node_x', netcdf.getConstant('NC_DOUBLE'), dim_network_nNodes);
var_network_node_y = netcdf.defVar(ncid, 'network_node_y', netcdf.getConstant('NC_DOUBLE'), dim_network_nNodes);

var_network_geometry = netcdf.defVar(ncid, 'network_geometry',netcdf.getConstant('NC_INT'), []);
var_network_geom_node_count = netcdf.defVar(ncid, 'network_geom_node_count',netcdf.getConstant('NC_INT'), dim_network_nEdges);
var_network_geom_x = netcdf.defVar(ncid, 'network_geom_x',netcdf.getConstant('NC_DOUBLE'), dim_network_nGeometryNodes);
var_network_geom_y = netcdf.defVar(ncid, 'network_geom_y',netcdf.getConstant('NC_DOUBLE'), dim_network_nGeometryNodes);
var_network_branch_order = netcdf.defVar(ncid, 'network_branch_order',netcdf.getConstant('NC_INT'), dim_network_nEdges);
var_network_branch_type = netcdf.defVar(ncid, 'network_branch_type',netcdf.getConstant('NC_INT'), dim_network_nEdges);

var_mesh1d = netcdf.defVar(ncid, 'mesh1d',netcdf.getConstant('NC_INT'), []);
var_mesh1d_node_branch = netcdf.defVar(ncid, 'mesh1d_node_branch',netcdf.getConstant('NC_INT'), dim_mesh1d_nNodes);
var_mesh1d_node_offset = netcdf.defVar(ncid, 'mesh1d_node_offset',netcdf.getConstant('NC_DOUBLE'), dim_mesh1d_nNodes);
var_mesh1d_node_x      = netcdf.defVar(ncid, 'mesh1d_node_x',netcdf.getConstant('NC_DOUBLE'), dim_mesh1d_nNodes);
var_mesh1d_node_y      = netcdf.defVar(ncid, 'mesh1d_node_y',netcdf.getConstant('NC_DOUBLE'), dim_mesh1d_nNodes);
var_mesh1d_edge_branch      = netcdf.defVar(ncid, 'mesh1d_edge_branch',netcdf.getConstant('NC_INT'), dim_mesh1d_nEdges);
var_mesh1d_edge_offset      = netcdf.defVar(ncid, 'mesh1d_edge_offset',netcdf.getConstant('NC_DOUBLE'), dim_mesh1d_nEdges);
var_mesh1d_edge_x      = netcdf.defVar(ncid, 'mesh1d_edge_x',netcdf.getConstant('NC_DOUBLE'), dim_mesh1d_nEdges);
var_mesh1d_edge_y      = netcdf.defVar(ncid, 'mesh1d_edge_y',netcdf.getConstant('NC_DOUBLE'), dim_mesh1d_nEdges);
var_mesh1d_node_id      = netcdf.defVar(ncid, 'mesh1d_node_id',netcdf.getConstant('NC_CHAR'), [dim_strLengthIds,dim_mesh1d_nNodes]);
var_mesh1d_node_long_name      = netcdf.defVar(ncid, 'mesh1d_node_long_name',netcdf.getConstant('NC_CHAR'), [dim_strLengthLongNames,dim_mesh1d_nNodes]);
var_mesh1d_edge_nodes  = netcdf.defVar(ncid, 'mesh1d_edge_nodes',netcdf.getConstant('NC_INT'), [dim_Two dim_mesh1d_nEdges]);

%fill values
% netcdf.defVarFill(ncid, var_mesh1d_node_x, false, int32(-9999));

%% Define variable attributes

%% ===== Variable attributes =====

% --- network ---
netcdf.putAtt(ncid, var_network, 'cf_role', 'mesh_topology');
netcdf.putAtt(ncid, var_network, 'long_name', 'Topology data of 1D network');
netcdf.putAtt(ncid, var_network, 'edge_dimension', 'network_nEdges');
netcdf.putAtt(ncid, var_network, 'edge_geometry', 'network_geometry');
netcdf.putAtt(ncid, var_network, 'edge_node_connectivity', 'network_edge_nodes');
netcdf.putAtt(ncid, var_network, 'node_coordinates', 'network_node_x network_node_y');
netcdf.putAtt(ncid, var_network, 'node_dimension', 'network_nNodes');
netcdf.putAtt(ncid, var_network, 'topology_dimension', int32(1));
netcdf.putAtt(ncid, var_network, 'node_id', 'network_node_id');
netcdf.putAtt(ncid, var_network, 'node_long_name', 'network_node_long_name');
netcdf.putAtt(ncid, var_network, 'branch_id', 'network_branch_id');
netcdf.putAtt(ncid, var_network, 'branch_long_name', 'network_branch_long_name');
netcdf.putAtt(ncid, var_network, 'edge_length', 'network_edge_length');

% --- network_edge_nodes ---
netcdf.putAtt(ncid, var_network_edge_nodes, 'cf_role', 'edge_node_connectivity');
netcdf.putAtt(ncid, var_network_edge_nodes, 'long_name', 'Start and end nodes of network edges');

% --- network_branch_id ---
netcdf.putAtt(ncid, var_network_branch_id, 'long_name', 'ID of branch geometries');

% --- network_branch_long_name ---
netcdf.putAtt(ncid, var_network_branch_long_name, 'long_name', 'Long name of branch geometries');

% --- network_edge_length ---
netcdf.putAtt(ncid, var_network_edge_length, 'long_name', 'Real length of branch geometries');
netcdf.putAtt(ncid, var_network_edge_length, 'units', 'm');

% --- network_node_id ---
netcdf.putAtt(ncid, var_network_node_id, 'long_name', 'ID of network nodes');

% --- network_node_long_name ---
netcdf.putAtt(ncid, var_network_node_long_name, 'long_name', 'Long name of network nodes');

% --- network_node_x ---
netcdf.putAtt(ncid, var_network_node_x, 'units', 'm');
netcdf.putAtt(ncid, var_network_node_x, 'standard_name', 'projection_x_coordinate');
netcdf.putAtt(ncid, var_network_node_x, 'long_name', 'x-coordinate of network nodes');

% --- network_node_y ---
netcdf.putAtt(ncid, var_network_node_y, 'units', 'm');
netcdf.putAtt(ncid, var_network_node_y, 'standard_name', 'projection_y_coordinate');
netcdf.putAtt(ncid, var_network_node_y, 'long_name', 'y-coordinate of network nodes');

% --- network_geometry ---
netcdf.putAtt(ncid, var_network_geometry, 'geometry_type', 'line');
netcdf.putAtt(ncid, var_network_geometry, 'long_name', '1D Geometry');
netcdf.putAtt(ncid, var_network_geometry, 'node_count', 'network_geom_node_count');
netcdf.putAtt(ncid, var_network_geometry, 'node_coordinates', 'network_geom_x network_geom_y');

% --- network_geom_node_count ---
netcdf.putAtt(ncid, var_network_geom_node_count, 'long_name', 'Number of geometry nodes per branch');

% --- network_geom_x ---
netcdf.putAtt(ncid, var_network_geom_x, 'units', 'm');
netcdf.putAtt(ncid, var_network_geom_x, 'standard_name', 'projection_x_coordinate');
netcdf.putAtt(ncid, var_network_geom_x, 'long_name', 'x-coordinate of branch geometry nodes');

% --- network_geom_y ---
netcdf.putAtt(ncid, var_network_geom_y, 'units', 'm');
netcdf.putAtt(ncid, var_network_geom_y, 'standard_name', 'projection_y_coordinate');
netcdf.putAtt(ncid, var_network_geom_y, 'long_name', 'y-coordinate of branch geometry nodes');

% --- network_branch_order ---
netcdf.putAtt(ncid, var_network_branch_order, 'long_name', 'Order of branches for interpolation');
netcdf.putAtt(ncid, var_network_branch_order, 'mesh', 'network');
netcdf.putAtt(ncid, var_network_branch_order, 'location', 'edge');

% --- network_branch_type ---
netcdf.putAtt(ncid, var_network_branch_type, 'long_name', 'Type of branches');
netcdf.putAtt(ncid, var_network_branch_type, 'mesh', 'network');
netcdf.putAtt(ncid, var_network_branch_type, 'location', 'edge');

% --- mesh1d ---
netcdf.putAtt(ncid, var_mesh1d, 'cf_role', 'mesh_topology');
netcdf.putAtt(ncid, var_mesh1d, 'long_name', 'Topology data of 1D mesh');
netcdf.putAtt(ncid, var_mesh1d, 'topology_dimension', int32(1));
netcdf.putAtt(ncid, var_mesh1d, 'coordinate_space', 'network');
netcdf.putAtt(ncid, var_mesh1d, 'edge_node_connectivity', 'mesh1d_edge_nodes');
netcdf.putAtt(ncid, var_mesh1d, 'node_dimension', 'mesh1d_nNodes');
netcdf.putAtt(ncid, var_mesh1d, 'edge_dimension', 'mesh1d_nEdges');
netcdf.putAtt(ncid, var_mesh1d, 'node_coordinates', 'mesh1d_node_branch mesh1d_node_offset mesh1d_node_x mesh1d_node_y');
netcdf.putAtt(ncid, var_mesh1d, 'edge_coordinates', 'mesh1d_edge_branch mesh1d_edge_offset mesh1d_edge_x mesh1d_edge_y');
netcdf.putAtt(ncid, var_mesh1d, 'node_id', 'mesh1d_node_id');
netcdf.putAtt(ncid, var_mesh1d, 'node_long_name', 'mesh1d_node_long_name');

% --- mesh1d_node_branch ---
netcdf.putAtt(ncid, var_mesh1d_node_branch, 'long_name', 'Index of branch on which mesh nodes are located');
netcdf.putAtt(ncid, var_mesh1d_node_branch, 'start_index', int32(0));

% --- mesh1d_node_offset ---
netcdf.putAtt(ncid, var_mesh1d_node_offset, 'long_name', 'Offset along branch of mesh nodes');
netcdf.putAtt(ncid, var_mesh1d_node_offset, 'units', 'm');

% --- mesh1d_node_x ---
netcdf.putAtt(ncid, var_mesh1d_node_x, 'units', 'm');
netcdf.putAtt(ncid, var_mesh1d_node_x, 'standard_name', 'projection_x_coordinate');
netcdf.putAtt(ncid, var_mesh1d_node_x, 'long_name', 'x-coordinate of mesh nodes');

% --- mesh1d_node_y ---
netcdf.putAtt(ncid, var_mesh1d_node_y, 'units', 'm');
netcdf.putAtt(ncid, var_mesh1d_node_y, 'standard_name', 'projection_y_coordinate');
netcdf.putAtt(ncid, var_mesh1d_node_y, 'long_name', 'y-coordinate of mesh nodes');

% --- mesh1d_edge_branch ---
netcdf.putAtt(ncid, var_mesh1d_edge_branch, 'long_name', 'Index of branch on which mesh edges are located');
netcdf.putAtt(ncid, var_mesh1d_edge_branch, 'start_index', int32(0));

% --- mesh1d_edge_offset ---
netcdf.putAtt(ncid, var_mesh1d_edge_offset, 'long_name', 'Offset along branch of mesh edges');
netcdf.putAtt(ncid, var_mesh1d_edge_offset, 'units', 'm');

% --- mesh1d_edge_x ---
netcdf.putAtt(ncid, var_mesh1d_edge_x, 'units', 'm');
netcdf.putAtt(ncid, var_mesh1d_edge_x, 'standard_name', 'projection_x_coordinate');
netcdf.putAtt(ncid, var_mesh1d_edge_x, 'long_name', 'Characteristic x-coordinate of the mesh edge (e.g. midpoint)');

% --- mesh1d_edge_y ---
netcdf.putAtt(ncid, var_mesh1d_edge_y, 'units', 'm');
netcdf.putAtt(ncid, var_mesh1d_edge_y, 'standard_name', 'projection_y_coordinate');
netcdf.putAtt(ncid, var_mesh1d_edge_y, 'long_name', 'Characteristic y-coordinate of the mesh edge (e.g. midpoint)');

% --- mesh1d_node_id ---
netcdf.putAtt(ncid, var_mesh1d_node_id, 'long_name', 'ID of mesh nodes');

% --- mesh1d_node_long_name ---
netcdf.putAtt(ncid, var_mesh1d_node_long_name, 'long_name', 'Long name of mesh nodes');

% --- mesh1d_edge_nodes ---
netcdf.putAtt(ncid, var_mesh1d_edge_nodes, 'cf_role', 'edge_node_connectivity');
netcdf.putAtt(ncid, var_mesh1d_edge_nodes, 'long_name', 'Start and end nodes of mesh edges');
netcdf.putAtt(ncid, var_mesh1d_edge_nodes, 'start_index', int32(0));

%% Define global attributes
netcdf.putAtt(ncid, netcdf.getConstant('NC_GLOBAL'), 'institution', 'Deltares');
netcdf.putAtt(ncid, netcdf.getConstant('NC_GLOBAL'), 'references', 'https://github.com/ugrid-conventions/ugrid-conventions');
netcdf.putAtt(ncid, netcdf.getConstant('NC_GLOBAL'), 'source', 'NC_create_1D_grid.m');
netcdf.putAtt(ncid, netcdf.getConstant('NC_GLOBAL'), 'history', ['Created on ' char(datetime('now','Format','yyyy-MM-dd''T''HH:mm:SS'))]);
netcdf.putAtt(ncid, netcdf.getConstant('NC_GLOBAL'), 'Conventions', 'CF-1.8 UGRID-1.0 Deltares-0.10');

%% End definition mode
netcdf.endDef(ncid);

%% WRITE

%network
netcdf.putVar(ncid, var_network, 1);
netcdf.putVar(ncid, var_network_edge_nodes, network_edge_nodes');
netcdf.putVar(ncid, var_network_branch_id, network_branch_id');
netcdf.putVar(ncid, var_network_branch_long_name, network_branch_long_name');
netcdf.putVar(ncid, var_network_edge_length, network_edge_length);
netcdf.putVar(ncid, var_network_node_id, network_node_id');
netcdf.putVar(ncid, var_network_node_long_name, network_node_long_name');
netcdf.putVar(ncid, var_network_node_x, network_node_x);
netcdf.putVar(ncid, var_network_node_y, network_node_y);

%network geometry
netcdf.putVar(ncid, var_network_geometry, 1);
netcdf.putVar(ncid, var_network_geom_node_count, network_geom_node_count);
netcdf.putVar(ncid, var_network_geom_x, network_geom_x);
netcdf.putVar(ncid, var_network_geom_y, network_geom_y);
netcdf.putVar(ncid, var_network_branch_order, network_branch_order);
netcdf.putVar(ncid, var_network_branch_type, network_branch_type);

%mesh1d
netcdf.putVar(ncid, var_mesh1d, 1);
netcdf.putVar(ncid, var_mesh1d_node_branch, mesh1d_node_branch);
netcdf.putVar(ncid, var_mesh1d_node_offset, mesh1d_node_offset);
netcdf.putVar(ncid, var_mesh1d_node_x, mesh1d_node_x);
netcdf.putVar(ncid, var_mesh1d_node_y, mesh1d_node_y);
netcdf.putVar(ncid, var_mesh1d_edge_branch, mesh1d_edge_branch);
netcdf.putVar(ncid, var_mesh1d_edge_offset, mesh1d_edge_offset);
netcdf.putVar(ncid, var_mesh1d_edge_x, mesh1d_edge_x);
netcdf.putVar(ncid, var_mesh1d_edge_y, mesh1d_edge_y);
netcdf.putVar(ncid, var_mesh1d_node_id, mesh1d_node_id);
netcdf.putVar(ncid, var_mesh1d_node_long_name, mesh1d_node_long_name);
netcdf.putVar(ncid, var_mesh1d_edge_nodes, mesh1d_edge_nodes);

%% CLOSE

netcdf.close(ncid);

messageOut(fid_log,sprintf('Created NetCDF file: %s\n', filename));

%% catch error
catch error
    netcdf.close(ncid);
    rethrow(error)
end %try-catch

end %function
