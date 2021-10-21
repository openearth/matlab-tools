%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 17522 $
%$Date: 2021-10-18 07:45:10 +0200 (Mon, 18 Oct 2021) $
%$Author: chavarri $
%$Id: D3D_read.m 17522 2021-10-18 05:45:10Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/fcn/D3D_read.m $
%
%Read observation stations name and location

function obs_sta=D3D_observation_stations(path_his)

obs_sta.name=cellstr(ncread(path_his,'station_id')')';
obs_sta.x=ncread(path_his,'station_x_coordinate')';
obs_sta.y=ncread(path_his,'station_y_coordinate')';

end %function
