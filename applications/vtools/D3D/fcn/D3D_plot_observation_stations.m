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
%Plot observation stations

function D3D_plot_observation_stations(fpath_his,varargin)

%% PARSE

parin=inputParser; 

addOptional(parin,'map',true);
addOptional(parin,'OPT',struct());

parse(parin,varargin{:})

in_p.map=parin.Results.map;
in_p.OPT=parin.Results.OPT;

%% CALC

obs_sta=D3D_observation_stations(fpath_his);

in_p.obs_sta=obs_sta;

D3D_fig_observation_stations(in_p);

end