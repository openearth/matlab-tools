%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 17958 $
%$Date: 2022-04-20 09:27:05 +0200 (Wed, 20 Apr 2022) $
%$Author: chavarri $
%$Id: create_mat_map_sal_mass_01.m 17958 2022-04-20 07:27:05Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/get_data_mat/create_mat_map_sal_mass_01.m $
%
%

function fpath_mat_tmp=mat_tmp_name(fdir_mat,tag,varargin)

%% PARSE

parin=inputParser;

addOptional(parin,'tim',[]);
addOptional(parin,'layer',[]);

parse(parin,varargin{:});

time_dnum=parin.Results.tim;
layer=parin.Results.layer;

%%

if isempty(time_dnum)
    error('time missing')
end

%% CALC

%time
str_add=sprintf('%s',datestr(time_dnum,'yyyymmddHHMMSS'));

%layer
if ~isempty(layer)
    str_add=sprintf('%s_layer_%04d',str_add,layer);
end

%final
fpath_mat_tmp=fullfile(fdir_mat,sprintf('%s_%s.mat',tag,str_add));

end %function