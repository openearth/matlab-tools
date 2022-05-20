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
%Read observation stations name and location

function obs_sta=D3D_observation_stations(path_his)

nci=ncinfo(path_his);
is_sta=ismember('station_id',{nci.Variables.Name});
if is_sta
    obs_sta.name=cellstr(ncread(path_his,'station_id')')';
    obs_sta.x=ncread(path_his,'station_x_coordinate')';
    obs_sta.y=ncread(path_his,'station_y_coordinate')';
else
    obs_sta.name={''};
    obs_sta.x=[];
    obs_sta.y=[];
end

end %function
