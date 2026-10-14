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
%

function gdm_save_grid_netcdf(fpath_netcdf,gridInfo)

required_fields={'Xcor','Ycor','face_nodes'};
for kf=1:numel(required_fields)
    if ~isfield(gridInfo,required_fields{kf})
        error('gdm_save_grid_netcdf:MissingGridField', ...
            'gridInfo must contain the field "%s".',required_fields{kf});
    end
end

if ~isvector(gridInfo.Xcor) || ~isvector(gridInfo.Ycor) || ...
        isempty(gridInfo.Xcor) || numel(gridInfo.Xcor)~=numel(gridInfo.Ycor)
    error('gdm_save_grid_netcdf:InvalidNodeCoordinates', ...
        'gridInfo.Xcor and gridInfo.Ycor must be vectors of equal length.');
end
if ~ismatrix(gridInfo.face_nodes) || isempty(gridInfo.face_nodes) || ...
        size(gridInfo.face_nodes,1)<3 || size(gridInfo.face_nodes,2)<1
    error('gdm_save_grid_netcdf:InvalidFaceNodes', ...
        'gridInfo.face_nodes must be a matrix with at least three node rows.');
end
has_epsg=isfield(gridInfo,'epsg');
if has_epsg && (~isnumeric(gridInfo.epsg) || ~isscalar(gridInfo.epsg) || ...
        ~isfinite(gridInfo.epsg) || gridInfo.epsg<1 || ...
        gridInfo.epsg~=fix(gridInfo.epsg) || gridInfo.epsg>double(intmax('int32')))
    error('gdm_save_grid_netcdf:InvalidEPSG', ...
        'gridInfo.epsg must be a positive integer within the int32 range.');
end

x_node=gridInfo.Xcor(:);
y_node=gridInfo.Ycor(:);
face_nodes=gridInfo.face_nodes;
n_node=numel(x_node);
n_face=size(face_nodes,2);
fill_value=int32(-1);

is_padding=isnan(face_nodes) | face_nodes==0;
valid_nodes=face_nodes(~is_padding);
if any(~isfinite(valid_nodes)) || any(valid_nodes~=fix(valid_nodes)) || ...
        any(valid_nodes<1) || any(valid_nodes>n_node)
    error('gdm_save_grid_netcdf:InvalidConnectivity', ...
        'gridInfo.face_nodes must contain valid 1-based node indices, with NaN or zero padding.');
end
face_nodes=double(face_nodes);
face_nodes(is_padding)=double(fill_value);

ncid=netcdf.create(fpath_netcdf,'NETCDF4');
try
    dim_node=netcdf.defDim(ncid,'mesh2d_nNodes',n_node);
    dim_face=netcdf.defDim(ncid,'mesh2d_nFaces',n_face);
    dim_max_face_nodes=netcdf.defDim(ncid,'mesh2d_nMax_face_nodes',size(face_nodes,1));

    mesh_var=netcdf.defVar(ncid,'mesh2d','NC_INT',[]);
    netcdf.putAtt(ncid,mesh_var,'cf_role','mesh_topology');
    netcdf.putAtt(ncid,mesh_var,'topology_dimension',int32(2));
    netcdf.putAtt(ncid,mesh_var,'node_coordinates','mesh2d_node_x mesh2d_node_y');
    netcdf.putAtt(ncid,mesh_var,'face_node_connectivity','mesh2d_face_nodes');

    x_var=netcdf.defVar(ncid,'mesh2d_node_x','NC_DOUBLE',dim_node);
    y_var=netcdf.defVar(ncid,'mesh2d_node_y','NC_DOUBLE',dim_node);
    netcdf.putAtt(ncid,x_var,'standard_name','projection_x_coordinate');
    netcdf.putAtt(ncid,x_var,'units','m');
    netcdf.putAtt(ncid,y_var,'standard_name','projection_y_coordinate');
    netcdf.putAtt(ncid,y_var,'units','m');
    if has_epsg
        crs_var=netcdf.defVar(ncid,'projected_coordinate_system','NC_INT',[]);
        netcdf.putAtt(ncid,crs_var,'name','Unknown projected');
        netcdf.putAtt(ncid,crs_var,'epsg',int32(gridInfo.epsg));
        netcdf.putAtt(ncid,crs_var,'grid_mapping_name','Unknown projected');
        netcdf.putAtt(ncid,crs_var,'EPSG_code',sprintf('EPSG:%d',gridInfo.epsg));
        netcdf.putAtt(ncid,crs_var,'value','value is equal to EPSG code');
        netcdf.putAtt(ncid,crs_var,'proj4_params','');
        netcdf.putAtt(ncid,crs_var,'proj_string','');
        netcdf.putAtt(ncid,x_var,'grid_mapping','projected_coordinate_system');
        netcdf.putAtt(ncid,y_var,'grid_mapping','projected_coordinate_system');
    end

    connectivity_var=netcdf.defVar(ncid,'mesh2d_face_nodes','NC_INT', ...
        [dim_max_face_nodes,dim_face]);
    netcdf.putAtt(ncid,connectivity_var,'cf_role','face_node_connectivity');
    netcdf.putAtt(ncid,connectivity_var,'start_index',int32(1));
    netcdf.putAtt(ncid,connectivity_var,'_FillValue',fill_value);

    has_x_face=isfield(gridInfo,'Xcen');
    has_y_face=isfield(gridInfo,'Ycen');
    if has_x_face~=has_y_face
        error('gdm_save_grid_netcdf:IncompleteFaceCoordinates', ...
            'gridInfo must contain both Xcen and Ycen, or neither.');
    end
    write_face_coordinates=has_x_face;
    if write_face_coordinates
        if numel(gridInfo.Xcen)~=n_face || numel(gridInfo.Ycen)~=n_face
            error('gdm_save_grid_netcdf:InvalidFaceCoordinates', ...
                'gridInfo.Xcen and gridInfo.Ycen must contain one coordinate per face.');
        end
        x_face_var=netcdf.defVar(ncid,'mesh2d_face_x','NC_DOUBLE',dim_face);
        y_face_var=netcdf.defVar(ncid,'mesh2d_face_y','NC_DOUBLE',dim_face);
        netcdf.putAtt(ncid,mesh_var,'face_coordinates','mesh2d_face_x mesh2d_face_y');
        netcdf.putAtt(ncid,x_face_var,'standard_name','projection_x_coordinate');
        netcdf.putAtt(ncid,x_face_var,'units','m');
        netcdf.putAtt(ncid,y_face_var,'standard_name','projection_y_coordinate');
        netcdf.putAtt(ncid,y_face_var,'units','m');
        if has_epsg
            netcdf.putAtt(ncid,x_face_var,'grid_mapping','projected_coordinate_system');
            netcdf.putAtt(ncid,y_face_var,'grid_mapping','projected_coordinate_system');
        end
    end
    netcdf.putAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'description', ...
        'UGRID mesh created by gdm_save_grid_netcdf.');

    netcdf.endDef(ncid);
    netcdf.putVar(ncid,x_var,x_node);
    netcdf.putVar(ncid,y_var,y_node);
    netcdf.putVar(ncid,connectivity_var,int32(face_nodes));
    if write_face_coordinates
        netcdf.putVar(ncid,x_face_var,gridInfo.Xcen(:));
        netcdf.putVar(ncid,y_face_var,gridInfo.Ycen(:));
    end
    netcdf.close(ncid);
catch err
    netcdf.close(ncid);
    rethrow(err)
end

messageOut(NaN,sprintf('Finished writing netcdf: %s',fpath_netcdf));
end %function