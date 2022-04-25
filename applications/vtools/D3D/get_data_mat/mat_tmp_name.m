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