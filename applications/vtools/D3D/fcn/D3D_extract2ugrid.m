function fname_out = D3D_extract2ugrid(fname,varname,varargin)
%D3D_EXTRACT2UGRID transfers DFLOWFM simulation results at cell faces to netCDF UGRID file.
%
%$Revision$
%$Date$
%$Author$
%$Id$
%$HeadURL$
%
% Example usage: 
% fname_out = extract2ugrid(fname,varname,varargin); 
%  
% fname_out: path of output file 
% fname:     path of input file (a single partition is enough in case of
%            parallel simulations)
% varname:   which variable name to extract? e.g. mesh2d_s1  
% varargin:  pairwise selection - default is all 
%            'time', tstep
%
% see also: sim2ugrid
% 
disp("Total number of input arguments: " + nargin)
if mod(nargin,2) == 1; 
    error("pairs of indices expected, e.g.  'time', 3, ... ")
end
Data = EHY_getMapModelData(fname, 'varName', varname, 't0', '', 'tend', '');
gridInfo = EHY_getGridInfo(fname, 'face_nodes_xy');

Data.dims = strsplit(Data.dimensions(2:end-1),',');

nd = length(size(Data.val)); 
a = [1,3:nd];
str_append = ''; 
errmsg = "fname2 = D3D_extract2ugrid(fname,'mesh2d_msed'"; 
for k = 1:length(a); 
    errmsg = sprintf("%s, '%s', %i", errmsg, Data.dims{a(k)}, 1); 
end 
errmsg = sprintf('%s)', errmsg); 


while nd > 1; 
    if (sum(strcmp(Data.dims{a(nd-1)}, varargin)) == 0) 
        error(sprintf("Please provide input: '%s'.\n'", errmsg));
    end
    ind = varargin{find(strcmp(Data.dims{a(nd-1)}, varargin))+1}; 
    switch nd;
        case 4
            Data.val = squeeze(Data.val(:,:,:,ind));
        case 3
            Data.val = squeeze(Data.val(:,:,ind));
        case 2    
            Data.val = squeeze(Data.val(ind,:));
        otherwise
            error(sprintf("Please provide input for '%s'.\n'", errmsg));
    end
    str_append = sprintf('_%s%02i%s', Data.dims{a(nd-1)}, ind, str_append);
    nd = nd - 1; 
end
    
%Data.times = Data.times(tstep);
%Data.val = Data.val(tstep,:); 

%idx = strcmp({a.Variables.Name},'mesh2d_mor_bl')
xycor_full = [gridInfo.face_nodes_x(:),gridInfo.face_nodes_y(:)]; 
[xycor,ia,ic] = unique(xycor_full,'rows');
idxcor = 1:length(ia); 
mxfn = size(gridInfo.face_nodes_y,1);
facenodeidx = reshape(idxcor(ic),mxfn,[]); 
zb_loc = 'face';
%A = reshape(1:length(xycor_full),mxfn,[])

fname_out = fullfile(fileparts(fname), sprintf('%s_%s.nc', varname, str_append));
ncid = netcdf.create(fname_out, 'NETCDF4');

total_nnodes = length(ia);
total_nfaces = size(gridInfo.face_nodes_x,2);
max_facenodes = size(gridInfo.face_nodes_x,1);
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
    imaxfn = netcdf.defDim(ncid, 'mesh2d_nmax_face_nodes', max_facenodes);
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