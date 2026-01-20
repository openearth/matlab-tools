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

function data_var=gdm_read_data_map_ShieldsD(fdir_mat,fpath_map,varname,varargin)

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

rho=1000; %water density kg/m3 
rho_s=2650; %sediment density kg/m3
g=9.81; %gravity m/s2
R=(rho_s - rho)/rho; %submerged specific density

varnames=NC_varnames(fpath_map);
if any(ismember(varnames,'mesh2d_taus'))
    data_taus=gdm_read_data_map_umag(fdir_mat,fpath_map,'mesh2d_taus','tim',time_dnum,'var_idx',var_idx,'idx_branch',idx_branch,'branch',branch,'layer',layer,'tol_t',tol_t); 
else
    data_u=gdm_read_data_map_umag(fdir_mat,fpath_map,varname,'tim',time_dnum,'var_idx',var_idx,'idx_branch',idx_branch,'branch',branch,'layer',layer,'tol_t',tol_t); 
    data_C=gdm_read_data_map(fdir_mat,fpath_map,'mesh2d_czs','tim',time_dnum,'var_idx',var_idx,'idx_branch',idx_branch,'branch',branch,'layer',layer,'tol_t',tol_t); 
    Cf=g/data_C.val.^2;
    data_taus.val=rho*Cf.*data_u.val.^2;
end

data_var.val=data_taus.val./g/rho/R; %ideally gravity, water density, and specific sediment density are read from mdu and sed files

end %function