function fname_out = D3D_extract2ugrid(fname,varname,tstep)
%D3D_EXTRACT2UGRID transfers DFLOWFM simulation results at cell faces to netCDF UGRID file.
%
%$Revision$
%$Date$
%$Author$
%$Id$
%$HeadURL$
%
% Example usage: 
% fname_out = extract2ugrid(fname,varname,tstep); 
%  
% fname_out: path of output file 
% fname:     path of input file (a single partition is enough in case of
%            parallel simulations)
% varname:   which variable name to extract? e.g. mesh2d_s1  
% tstep:     output time index in file  
%
% see also: sim2ugrid
% 
Data = EHY_getMapModelData(fname, 'varName', varname, 't0', '', 'tend', '');
gridInfo = EHY_getGridInfo(fname, 'face_nodes_xy');
Data.times = Data.times(tstep); 
Data.val = Data.val(tstep,:); 

%idx = strcmp({a.Variables.Name},'mesh2d_mor_bl')
xycor_full = [gridInfo.face_nodes_x(:),gridInfo.face_nodes_y(:)]; 
[xycor,ia,ic] = unique(xycor_full,'rows');
idxcor = 1:length(ia); 
mxfn = size(gridInfo.face_nodes_y,1);
facenodeidx = reshape(idxcor(ic),mxfn,[]); 
zb_loc = 'face';
%A = reshape(1:length(xycor_full),mxfn,[])

fname_out = fullfile(fileparts(fname), sprintf('%s_t%i.nc', varname, tstep));
ncid = netcdf.create(fname_out, 'NETCDF4');

total_nnodes = length(ia);
total_nfaces = size(gridInfo.face_nodes_x,2);
xnode = xycor(:,1);
ynode = xycor(:,2);
faces = facenodeidx.';
zb = Data.val(:);

% based on sim2ugrid
% define dimensions, variables and attributes
Err = [];
try
    inodes = netcdf.defDim(ncid, 'mesh2d_nnodes', total_nnodes);
    ifaces = netcdf.defDim(ncid, 'mesh2d_nfaces', total_nfaces);
    imaxfn = netcdf.defDim(ncid, 'mesh2d_nmax_face_nodes', 4);
    %itimes = netcdf.defDim(ncid, 'time', netcdf.getConstant('UNLIMITED'));
    
    mesh = netcdf.defVar(ncid, 'mesh2d', 'NC_DOUBLE', []);
    netcdf.putAtt(ncid, mesh, 'cf_role', 'mesh_topology')
    netcdf.putAtt(ncid, mesh, 'topology_dimension', int32(2))
    netcdf.putAtt(ncid, mesh, 'node_coordinates', 'mesh2d_node_x mesh2d_node_y')
    netcdf.putAtt(ncid, mesh, 'face_node_connectivity', 'mesh2d_face_nodes')
    
    ix = netcdf.defVar(ncid, 'mesh2d_node_x', 'NC_DOUBLE', inodes);
    netcdf.putAtt(ncid, ix, 'standard_name', 'projection_x_coordinate')
    netcdf.putAtt(ncid, ix, 'units', 'm')
    
    iy = netcdf.defVar(ncid, 'mesh2d_node_y', 'NC_DOUBLE', inodes);
    netcdf.putAtt(ncid, iy, 'standard_name', 'projection_y_coordinate')
    netcdf.putAtt(ncid, iy, 'units', 'm')
    
    ifnc = netcdf.defVar(ncid, 'mesh2d_face_nodes', 'NC_INT', [imaxfn, ifaces]);
    netcdf.putAtt(ncid, ifnc, 'cf_role', 'face_node_connectivity')
    netcdf.putAtt(ncid, ifnc, 'start_index', int32(1))
    
    if strcmp(zb_loc,'node')
        idim = inodes;
    else
        idim = ifaces;
    end

    a = ncinfo(fname);

    izb = netcdf.defVar(ncid, varname, 'NC_DOUBLE', idim);
    att_names = {'standard_name', 'long_name', 'units', 'mesh', 'location', '_FillValue'}; 
    for k = 1:length(att_names) 
        att_name = att_names{k};
        netcdf.putAtt(ncid, izb, att_name, get_attribute(a, varname, att_name));
    end

    netcdf.putVar(ncid, ix, xnode)
    netcdf.putVar(ncid, iy, ynode)
    netcdf.putVar(ncid, ifnc, faces')
    netcdf.putVar(ncid, izb, zb)

    netcdf.close(ncid)
catch Err
    % failure --> throw Err again after closing the netCDF file
    netcdf.close(ncid);
    rethrow(Err);
end

    function att_val = get_attribute(a, varname, attname)
        var_idx = find(strcmp({a.Variables(:).Name}, varname));
        att_idx = find(strcmp({a.Variables(var_idx).Attributes(:).Name},attname));
        if (~isempty(att_idx)) 
           att_val = a.Variables(var_idx).Attributes(att_idx).Value; 
        elseif strcmp('_FillValue', attname); 
           att_val = netcdf.getConstant('NC_FILL_DOUBLE');
        else
           att_val = ''; 
        end
    end

end