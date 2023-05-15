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

function data_var=gdm_read_data_map_Fak(fdir_mat,fpath_map,varname,varargin)

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

%% CALC
    
data_lyrfrac=gdm_read_data_map(fdir_mat,fpath_map,varname,'tim',time_dnum,'idx_branch',idx_branch,'branch',branch);%,'bed_layers',layer); %we load all layers

% sum(data_Fak.val,
% %% BEGIN DEBUG
% 
% % END DEBUG
            
%% sum fractions 

data_var=data_lyrfrac;

%get fractions in the desired layer
if ~isempty(layer)
%     idx_l=D3D_search_index_in_dimension(data_lyrfrac,'bed_layers'); 
    idx_l=D3D_search_index_layer(data_lyrfrac);
    data_var.val=submatrix(data_var.val,idx_l,layer); %take submatrix along dimension
end

%get desired fractions
if ~isempty(var_idx)
%     idx_f=D3D_search_index_in_dimension(data_lyrfrac,'sedimentFraction'); 
    idx_f=D3D_search_index_fraction(data_lyrfrac); 
    data_var.val=submatrix(data_var.val,idx_f,var_idx); %take submatrix along dimension
    %sum over sediment dimension
    data_var.val=sum(data_var.val,idx_f);
end

end %function