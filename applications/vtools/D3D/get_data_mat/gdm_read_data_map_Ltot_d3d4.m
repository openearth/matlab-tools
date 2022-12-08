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

function data=gdm_read_data_map_Ltot_d3d4(fdir_mat,fpath_map,varargin)

%% PARSE

parin=inputParser;

addOptional(parin,'tim',[]);
addOptional(parin,'idx_branch',[]);
addOptional(parin,'branch','');
addOptional(parin,'var_idx',[]);

parse(parin,varargin{:});

time_dnum=parin.Results.tim;
idx_branch=parin.Results.idx_branch;
branch=parin.Results.branch;
var_idx=parin.Results.var_idx;

%% CALC

data=gdm_read_data_map_thlyr(fdir_mat,fpath_map,'tim',time_dnum,'layer',[],'branch',branch);

if ~isempty(var_idx)
    data_frac=gdm_read_data_map_Fak(fdir_mat,fpath_map,'LYRFRAC','tim',time_dnum,'branch',branch,'layer',[],'var_idx',var_idx); %sum of the fractions in <var_idx>
    data.val=sum(data.val.*data_frac.val,4);
else
    data.val=sum(data.val,4);
end

end %function