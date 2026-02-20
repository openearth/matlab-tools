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

function data_var=gdm_read_data_map_streamfunction(fdir_mat,fpath_map,varname,varargin)

%% PARSE

parin=inputParser;

addOptional(parin,'tim',[]);
% addOptional(parin,'var_idx',[]);
addOptional(parin,'idx_branch',[]);
addOptional(parin,'branch','');
% addOptional(parin,'layer',[]);
addOptional(parin,'do_load',1);
addOptional(parin,'tol_t',5/60/24); %tolerance in days to find the closest time step

parse(parin,varargin{:});

time_dnum=parin.Results.tim;
% var_idx=parin.Results.var_idx;
% layer=parin.Results.layer;
idx_branch=parin.Results.idx_branch;
branch=parin.Results.branch;
do_load=parin.Results.do_load;
tol_t=parin.Results.tol_t;

%% READ

gridInfo=gdm_load_grid(NaN,fdir_mat,fpath_map,'laplacian',true);
data_var=gdm_read_data_map(fdir_mat,fpath_map,'mesh2d_u1','tim',time_dnum,'do_load',do_load,'idx_branch',idx_branch,'branch',branch,'tol_t',tol_t);
val=data_var.val';
switch varname 
    case 'transport_streamfunction'
        data_var_h=gdm_read_data_map(fdir_mat,fpath_map,'mesh2d_hu','tim',time_dnum,'do_load',do_load,'idx_branch',idx_branch,'branch',branch,'tol_t',tol_t);
        data_var_h.val(isnan(data_var_h.val))=0; %set NaNs to zero for transport calculation
        val=data_var_h.val.'.*data_var.val.';
end
psi=D3D_compute_streamfunction(gridInfo.laplacian,gridInfo.edge_length,gridInfo.edge_faces,val);

data_var.val=psi;

end %function