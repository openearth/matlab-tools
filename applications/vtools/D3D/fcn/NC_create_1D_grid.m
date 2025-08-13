%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 19659 $
%$Date: 2024-06-03 08:02:18 +0200 (Mon, 03 Jun 2024) $
%$Author: chavarri $
%$Id: writetxt.m 19659 2024-06-03 06:02:18Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/general/writetxt.m $
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
network_node_id=cell2char(network_node_id,strLengthLongNames); %!ATTENTION change of type
network_node_long_name=cell2char(network_node_long_name,strLengthLongNames); %!ATTENTION change of type
mesh1d_node_id=cell2char(mesh1d_node_id,strLengthIds); %!ATTENTION change of type
mesh1d_node_long_name=cell2char(mesh1d_node_long_name,strLengthLongNames); %!ATTENTION change of type

%% Create NetCDF file

ncid = netcdf.create(filename, 'NETCDF4');

%% Define dimensions

network_nEdges=numel(network_branch_id); %i.e., number of branches
network_nNodes=numel(network_node_id);
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

%% Define variables

% | Type Name | NetCDF constant | MATLAB type |
% | --------- | --------------- | ----------- |
% | `byte`    | `NC_BYTE`       | `int8`      |
% | `char`    | `NC_CHAR`       | `char`      |
% | `short`   | `NC_SHORT`      | `int16`     |
% | `int`     | `NC_INT`        | `int32`     |
% | `float`   | `NC_FLOAT`      | `single`    |
% | `double`  | `NC_DOUBLE`     | `double`    |

% var_network = netcdf.defVar(ncid, 'network',netcdf.getConstant('NC_INT'), []);
var_network_edge_nodes = netcdf.defVar(ncid, 'network_edge_nodes',netcdf.getConstant('NC_INT'), [dim_Two dim_network_nEdges]);
var_network_branch_id  = netcdf.defVar(ncid, 'network_branch_id', netcdf.getConstant('NC_CHAR'), [dim_strLengthIds,dim_network_nEdges]);
var_network_branch_long_name  = netcdf.defVar(ncid, 'network_branch_long_name', netcdf.getConstant('NC_CHAR'), [dim_strLengthLongNames,dim_network_nEdges]);
var_network_edge_length  = netcdf.defVar(ncid, 'network_edge_length', netcdf.getConstant('NC_DOUBLE'), dim_network_nEdges);
var_network_node_id = netcdf.defVar(ncid, 'network_node_id', netcdf.getConstant('NC_CHAR'), [dim_strLengthIds,dim_network_nNodes]);
var_network_node_long_name = netcdf.defVar(ncid, 'network_node_long_name', netcdf.getConstant('NC_CHAR'), [dim_strLengthLongNames,dim_network_nNodes]);
var_network_node_x = netcdf.defVar(ncid, 'network_node_x', netcdf.getConstant('NC_DOUBLE'), dim_network_nNodes);
var_network_node_y = netcdf.defVar(ncid, 'network_node_y', netcdf.getConstant('NC_DOUBLE'), dim_network_nNodes);

% var_network_geometry = netcdf.defVar(ncid, 'network_geometry',netcdf.getConstant('NC_INT'), []);
var_network_geom_node_count = netcdf.defVar(ncid, 'network_geom_node_count',netcdf.getConstant('NC_INT'), dim_network_nEdges);
var_network_geom_x = netcdf.defVar(ncid, 'network_geom_x',netcdf.getConstant('NC_DOUBLE'), dim_network_nGeometryNodes);
var_network_geom_y = netcdf.defVar(ncid, 'network_geom_y',netcdf.getConstant('NC_DOUBLE'), dim_network_nGeometryNodes);
var_network_branch_order = netcdf.defVar(ncid, 'network_branch_order',netcdf.getConstant('NC_INT'), dim_network_nEdges);
var_network_branch_type = netcdf.defVar(ncid, 'network_branch_type',netcdf.getConstant('NC_INT'), dim_network_nEdges);

% var_mesh1d = netcdf.defVar(ncid, 'mesh1d',netcdf.getConstant('NC_INT'), []);
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
var_mesh1d_edge_nodes  = netcdf.defVar(ncid, 'mesh1d_edge_nodes', 'double', [dim_Two dim_mesh1d_nEdges]);


%fill values
% netcdf.defVarFill(ncid, var_mesh1d_node_x, false, int32(-9999));

% Define global attributes
netcdf.putAtt(ncid, netcdf.getConstant('NC_GLOBAL'), 'institution', 'Deltares');
netcdf.putAtt(ncid, netcdf.getConstant('NC_GLOBAL'), 'references', 'https://github.com/ugrid-conventions/ugrid-conventions');
netcdf.putAtt(ncid, netcdf.getConstant('NC_GLOBAL'), 'source', 'NC_create_1D_grid.m');
netcdf.putAtt(ncid, netcdf.getConstant('NC_GLOBAL'), 'history', ['Created on ' char(datetime('now','Format','yyyy-MM-dd''T''HH:mm:SS'))]);
netcdf.putAtt(ncid, netcdf.getConstant('NC_GLOBAL'), 'Conventions', 'CF-1.8 UGRID-1.0 Deltares-0.10');

% End definition mode
netcdf.endDef(ncid);

%% WRITE

%network
% netcdf.putVar(ncid, var_network, 1);
netcdf.putVar(ncid, var_network_edge_nodes, network_edge_nodes');
netcdf.putVar(ncid, var_network_branch_id, network_branch_id');
netcdf.putVar(ncid, var_network_branch_long_name, network_branch_long_name');
netcdf.putVar(ncid, var_network_edge_length, network_edge_length);
netcdf.putVar(ncid, var_network_node_id, network_node_id');
netcdf.putVar(ncid, var_network_node_long_name, network_node_long_name');
netcdf.putVar(ncid, var_network_node_x, network_node_x);
netcdf.putVar(ncid, var_network_node_y, network_node_y);

%network geometry
% netcdf.putVar(ncid, var_network_geometry, 1);
netcdf.putVar(ncid, var_network_geom_node_count, network_geom_node_count);
netcdf.putVar(ncid, var_network_geom_x, network_geom_x);
netcdf.putVar(ncid, var_network_geom_y, network_geom_y);
netcdf.putVar(ncid, var_network_branch_order, network_branch_order);
netcdf.putVar(ncid, var_network_branch_type, network_branch_type);

%mesh1d
% netcdf.putVar(ncid, var_mesh1d, 1);
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

end %function
