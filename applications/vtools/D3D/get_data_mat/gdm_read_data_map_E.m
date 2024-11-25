%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 19327 $
%$Date: 2023-12-21 14:04:16 +0100 (Thu, 21 Dec 2023) $
%$Author: chavarri $
%$Id: gdm_read_data_map_Fr.m 19327 2023-12-21 13:04:16Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/get_data_mat/gdm_read_data_map_Fr.m $
%
%

function data_var=gdm_read_data_map_E(fdir_mat,fpath_map,varname,varargin)

%% PARSE

parin=inputParser;

addOptional(parin,'tim',[]);
addOptional(parin,'var_idx',[]);
% addOptional(parin,'tol',1.5e-7);
addOptional(parin,'idx_branch',[]);
addOptional(parin,'branch','');
addOptional(parin,'layer',[]);

parse(parin,varargin{:});

time_dnum=parin.Results.tim;
var_idx=parin.Results.var_idx;
% tol=parin.Results.tol;
layer=parin.Results.layer;
idx_branch=parin.Results.idx_branch;
branch=parin.Results.branch;

%% READ
    
data_var=gdm_read_data_map_umag(fdir_mat,fpath_map,varname,'tim',time_dnum,'var_idx',var_idx,'idx_branch',idx_branch,'branch',branch,'layer',layer); 

%not very nice... we need to know the name of the variable, but we do not want to pass `simdef`
% [var_str_read,var_id,var_str_save]=D3D_var_num2str_structure('wl',simdef);
[ismor,is1d,str_network1d,issus,structure,is3d]=D3D_is(fpath_map);
[var_str_read,var_id,var_str_save]=D3D_var_num2str('wl','structure',structure,'ismor',ismor,'is1d',is1d,'is3d',is3d);
data_wl=gdm_read_data_map(fdir_mat,fpath_map,var_id,'tim',time_dnum,'var_idx',var_idx,'idx_branch',idx_branch,'branch',branch,'layer',layer); 

data_var.val=data_wl.val+data_var.val.^2/(2*9.81); %ideally gravity is read from mdu

end %function