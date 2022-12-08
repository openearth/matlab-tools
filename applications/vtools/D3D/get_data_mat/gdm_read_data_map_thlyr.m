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

function data=gdm_read_data_map_thlyr(fdir_mat,fpath_map,varargin)

%% PARSE

parin=inputParser;

addOptional(parin,'tim',[]);
addOptional(parin,'var_idx',[]);
addOptional(parin,'layer',[]);
addOptional(parin,'do_load',1);
addOptional(parin,'tol_t',5/60/24);
addOptional(parin,'idx_branch',[]);
addOptional(parin,'branch','');
% addOptional(parin,'bed_layers',[]); We use <layer> for flow and sediment

parse(parin,varargin{:});

time_dnum=parin.Results.tim;
var_idx=parin.Results.var_idx;
layer=parin.Results.layer;
do_load=parin.Results.do_load;
tol_t=parin.Results.tol_t;
idx_branch=parin.Results.idx_branch;
branch=parin.Results.branch;
% bed_layers=parin.Results.bed_layers;

%% CALC

% [ismor,is1d,str_network1d,issus]=D3D_is(fpath_map);
% if is1d
%     error('make it 1D proof')
% end
data=gdm_read_data_map(fdir_mat,fpath_map,'DP_BEDLYR','tim',time_dnum,'do_load',do_load,'idx_branch',idx_branch,'branch',branch); %we get all layers to make difference

thk=diff(data.val,1,4);

%% layer

if ~isempty(layer)
    %maybe better to search for [layer] in the ones coming from EHY?
    idx_f=D3D_search_index_in_dimension(data,'layer');
    if isnan(idx_f)
        idx_f=D3D_search_index_in_dimension(data,'bed_layers');
    end
    if isnan(idx_f)
        error('do not know where to get the layers index');
    end
    thk=submatrix(thk,idx_f,layer);
end
% 
% if ~isempty(var_idx) %sum over fractions
%     
% end

data.val=thk;


end %function