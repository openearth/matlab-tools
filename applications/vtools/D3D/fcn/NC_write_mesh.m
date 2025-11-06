function NC_write_mesh(filename, nodes, faces, elements, values)

% writeQGISMeshNetCDF - Write a NetCDF file for QGIS mesh layer
%
% Inputs:
%   filename - name of the NetCDF file to create (e.g., 'mesh.nc')
%   nodes    - Nx2 array of node coordinates [lon, lat]
%   elements - Mx3 array of triangle connectivity (1-based indices)
%   values   - Nx1 array of scalar values at nodes (optional)

%% Create NetCDF file

try %in case there is an error, we want to close the file to prevent hanging handles 


nNodes = size(nodes, 1);
[nElems,nMax_face_nodes] = size(elements);

ncid = netcdf.create(filename, 'NETCDF4');

% Define dimensions
dimNode = netcdf.defDim(ncid, 'nMesh2d_node', nNodes);
dimElem = netcdf.defDim(ncid, 'nMesh2d_face', nElems);
dimMaxFaceNodes = netcdf.defDim(ncid, 'nMax_face_nodes', nMax_face_nodes);

% Define mesh topology variable
meshVar = netcdf.defVar(ncid, 'mesh2d', 'NC_INT', []);

% Define coordinate variables
xVar = netcdf.defVar(ncid, 'mesh2d_node_x', 'NC_DOUBLE', dimNode);
yVar = netcdf.defVar(ncid, 'mesh2d_node_y', 'NC_DOUBLE', dimNode);

xface = netcdf.defVar(ncid, 'mesh2d_face_x', 'NC_DOUBLE', dimElem);
yface = netcdf.defVar(ncid, 'mesh2d_face_y', 'NC_DOUBLE', dimElem);

% Define connectivity
connVar = netcdf.defVar(ncid, 'mesh2d_face_nodes', 'NC_INT', [dimMaxFaceNodes, dimElem]);

% Optional scalar data
if nargin > 3
    valVar = netcdf.defVar(ncid, 'variable', 'NC_DOUBLE', dimElem);
end

% Add attributes
netcdf.putAtt(ncid, meshVar, 'cf_role', 'mesh_topology');
netcdf.putAtt(ncid, meshVar, 'topology_dimension', 2);
netcdf.putAtt(ncid, meshVar, 'node_coordinates', 'mesh2d_node_x mesh2d_node_y');
netcdf.putAtt(ncid, meshVar, 'face_node_connectivity', 'mesh2d_face_nodes');

netcdf.putAtt(ncid, xVar, 'standard_name', 'projection_x_coordinate');
netcdf.putAtt(ncid, xVar, 'units', 'm');
netcdf.putAtt(ncid, yVar, 'standard_name', 'projection_y_coordinate');
netcdf.putAtt(ncid, yVar, 'units', 'm');

netcdf.putAtt(ncid, xface, 'standard_name', 'projection_x_coordinate');
netcdf.putAtt(ncid, xface, 'units', 'm');
netcdf.putAtt(ncid, yface, 'standard_name', 'projection_y_coordinate');
netcdf.putAtt(ncid, yface, 'units', 'm');

netcdf.putAtt(ncid, connVar, 'start_index', 1); % QGIS supports 1-based indexing

if nargin > 3
    netcdf.putAtt(ncid, valVar, 'location', 'face');
    netcdf.putAtt(ncid, valVar, 'standard_name', 'variable'); % example
    netcdf.putAtt(ncid, valVar, 'coordinates', 'mesh2d_face_x mesh2d_face_y'); % example
end

netcdf.endDef(ncid);

% Write data
netcdf.putVar(ncid, xVar, nodes(:,1));
netcdf.putVar(ncid, yVar, nodes(:,2));
netcdf.putVar(ncid, xface, faces(:,1));
netcdf.putVar(ncid, yface, faces(:,2));
netcdf.putVar(ncid, connVar, elements');

if nargin > 3
    netcdf.putVar(ncid, valVar, values);
end

netcdf.close(ncid);
fprintf('UGRID NetCDF mesh written to %s\n', filename);

%% catch error
catch error
    netcdf.close(ncid);
    rethrow(error)
end %try-catch

end %function