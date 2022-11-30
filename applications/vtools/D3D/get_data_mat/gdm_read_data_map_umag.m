%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18496 $
%$Date: 2022-10-28 18:21:27 +0200 (Fri, 28 Oct 2022) $
%$Author: chavarri $
%$Id: gdm_read_data_map_T_max.m 18496 2022-10-28 16:21:27Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/get_data_mat/gdm_read_data_map_T_max.m $
%
%

function data_var=gdm_read_data_map_umag(fdir_mat,fpath_map,varname,varargin)

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
    
data_var=gdm_read_data_map(fdir_mat,fpath_map,'mesh2d_ucmag','tim',time_dnum,'idx_branch',idx_branch,'branch',branch,'layer',layer);%,'bed_layers',layer); %we load all layers

if ~isempty(layer)
    idx_f=D3D_search_index_layer(data_var);
    data_var.val=mean(data_var.val,idx_f);
end

end %function