%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 16571 $
%$Date: 2020-09-08 14:39:17 +0200 (Tue, 08 Sep 2020) $
%$Author: chavarri $
%$Id: D3D_bc_lateral.m 16571 2020-09-08 12:39:17Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/fcn/D3D_bc_lateral.m $
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