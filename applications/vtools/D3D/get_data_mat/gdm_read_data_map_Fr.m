%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18607 $
%$Date: 2022-12-08 08:02:01 +0100 (do, 08 dec 2022) $
%$Author: chavarri $
%$Id: gdm_read_data_map_umag.m 18607 2022-12-08 07:02:01Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/get_data_mat/gdm_read_data_map_umag.m $
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

parse(parin,varargin{:});

time_dnum=parin.Results.tim;
var_idx=parin.Results.var_idx;
% tol=parin.Results.tol;
layer=parin.Results.layer;
idx_branch=parin.Results.idx_branch;
branch=parin.Results.branch;

%% READ
    
data_var=gdm_read_data_map_umag(fdir_mat,fpath_map,varname,'tim',time_dnum,'var_idx',var_idx,'idx_branch',idx_branch,'branch',branch,'layer',layer); 
data_h=gdm_read_data_map(fdir_mat,fpath_map,'wd','tim',time_dnum,'var_idx',var_idx,'idx_branch',idx_branch,'branch',branch,'layer',layer); 

data_var.val=data_var.val./sqrt(9.81*data_h.val); %ideally gravity is read from mdu

end %function