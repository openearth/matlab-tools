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
    
[~,is1d,~,~,~,is3d]=D3D_is(fpath_map);
if is1d
    varname='mesh1d_ucmag';
else
    if is3d
        varname='mesh2d_ucmaga';
    else
        varname='mesh2d_ucmag';
    end
end

data_var=gdm_read_data_map(fdir_mat,fpath_map,varname,'tim',time_dnum,'idx_branch',idx_branch,'branch',branch,'layer',layer);%,'bed_layers',layer); %we load all layers

%this is different than taking part of the info. A depth-averaged is made.
if ~isempty(layer)
    idx_f=D3D_search_index_layer(data_var);
    data_var.val=mean(data_var.val,idx_f);
end

end %function