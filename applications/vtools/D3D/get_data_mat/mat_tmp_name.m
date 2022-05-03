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
addOptional(parin,'station','');
addOptional(parin,'pli','');
addOptional(parin,'pol','');
addOptional(parin,'iso','');

parse(parin,varargin{:});

time_dnum=parin.Results.tim;
layer=parin.Results.layer;
station=parin.Results.station;
pli=parin.Results.pli;
pol=parin.Results.pol;
iso=parin.Results.iso;

%%

% if isempty(time_dnum)
%     error('time missing')
% end

%% CALC

str_add='';

%time
if ~isempty(time_dnum)
    str_add=sprintf('%s%s',str_add,datestr(time_dnum,'yyyymmddHHMMSS'));
end

%station
if ~isempty(station)
    str_add=sprintf('%s%s',str_add,strrep(station,' ','_'));
end

%layer
if ~isempty(layer)
    str_add=sprintf('%s_layer_%04d',str_add,layer);
end

%pli
if ~isempty(pli)
    str_add=sprintf('%s_pli_%s',str_add,strrep(pli,' ',''));
end

%pol
if ~isempty(pol)
    str_add=sprintf('%s_pol_%s',str_add,strrep(pol,' ',''));
end

%iso
if ~isempty(iso)
    str_add=sprintf('%s_iso_%s',str_add,strrep(iso,' ',''));
end

%final
str_add=sprintf('%s_%s.mat',tag,str_add);
str_add=strrep(str_add,'__','_');
str_add=strrep(str_add,'_.mat','.mat');
fpath_mat_tmp=fullfile(fdir_mat,str_add);

end %function