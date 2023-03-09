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

function data_var=gdm_read_data_map_stot(fdir_mat,fpath_map,varname,varargin)

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
    
[ismor,is1d,str_network1d,issus,structure]=D3D_is(fpath_map);
switch structure
    case 1
        error('do')
    case 2
        if is1d
            var_x='mesh1d_sxtot';
            var_y='mesh1d_sytot';
        else
            var_x='mesh2d_sxtot';
            var_y='mesh2d_sytot';
        end
end

data_var_x=gdm_read_data_map(fdir_mat,fpath_map,var_x,'tim',time_dnum,'idx_branch',idx_branch,'branch',branch,'layer',layer);%,'bed_layers',layer); %we load all layers
data_var_y=gdm_read_data_map(fdir_mat,fpath_map,var_y,'tim',time_dnum,'idx_branch',idx_branch,'branch',branch,'layer',layer);%,'bed_layers',layer); %we load all layers

data_var=data_var_x;
data_var.val=hypot(data_var_x.val,data_var_y.val);

end %function