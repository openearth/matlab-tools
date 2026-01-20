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

function data_var=gdm_read_data_map_vorticity(fdir_mat,fpath_map,varargin)

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

data_ba=gdm_read_data_map(fdir_mat,fpath_map,'mesh2d_flowelem_ba','tim',time_dnum,'do_load',do_load,'idx_branch',idx_branch,'branch',branch,'tol_t',tol_t);
gridInfo=gdm_load_grid(fdir_mat,fpath_map,'idx_branch',idx_branch,'branch',branch);
data_var=gdm_read_data_map(fdir_mat,fpath_map,'mesh2d_u1','tim',time_dnum,'do_load',do_load,'idx_branch',idx_branch,'branch',branch,'tol_t',tol_t);
omega = D3D_vorticity_from_u1(data_var.val, gridInfo.edge_length,gridInfo.face_edges,gridInfo.face_edge_sign,data_ba.val);

data_var.val=omega;

end %function