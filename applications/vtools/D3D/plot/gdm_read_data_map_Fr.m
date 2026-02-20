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

function data_var=gdm_read_data_map_Fr(fdir_mat,fpath_map,varname,varargin)

%% PARSE

parin=inputParser;

addOptional(parin,'tim',[]);
addOptional(parin,'var_idx',[]);
% addOptional(parin,'tol',1.5e-7);
addOptional(parin,'idx_branch',[]);
addOptional(parin,'branch','');
addOptional(parin,'layer',[]);
addOptional(parin,'tol_t',5/60/24); %tolerance in days to find the closest time step

parse(parin,varargin{:});

tol_t=parin.Results.tol_t;
time_dnum=parin.Results.tim;
var_idx=parin.Results.var_idx;
% tol=parin.Results.tol;
layer=parin.Results.layer;
idx_branch=parin.Results.idx_branch;
branch=parin.Results.branch;

%% READ

data_var=gdm_read_data_map_umag(fdir_mat,fpath_map,varname,'tim',time_dnum,'var_idx',var_idx,'idx_branch',idx_branch,'branch',branch,'layer',layer,'tol_t',tol_t); 
data_h=gdm_read_data_map(fdir_mat,fpath_map,'wd','tim',time_dnum,'var_idx',var_idx,'idx_branch',idx_branch,'branch',branch,'layer',layer,'tol_t',tol_t); 

data_var.val=data_var.val./sqrt(9.81*data_h.val); %ideally gravity is read from mdu

end %function