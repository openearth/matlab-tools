%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 16571 $
%$Date: 2020-09-08 14:39:17 +0200 (Tue, 08 Sep 2020) $
%$Author: chavarri $
%$Id: modify_defstr_4.m 16571 2020-09-08 12:39:17Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/rmm_setup/modify_defstr_4.m $
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