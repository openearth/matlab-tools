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
%This does A and B
%
%INPUT:
%
%OUTPUT:
%

function goVgo(varargin)

%% PARSE

parin=inputParser;

addOptional(parin,'music',true);
parse(parin,varargin{:});
play_music=parin.Results.music;

%% INPUT

web_data='https://waterberichtgeving.rws.nl/wbviewer/maak_grafiek.php?loc=H-RN-0001&set=ecmwf_ens&nummer=2&format=wbcharts';
sisu_path='sisu.mat';

%% CALC

web(web_data);
if play_music
load(sisu_path,'sisu');
sound(sisu.y,sisu.Fs);
end

end %function