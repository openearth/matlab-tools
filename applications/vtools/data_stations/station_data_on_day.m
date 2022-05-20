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
%get value at station for a certain time

function [val,time_diff]=station_data_on_day(paths_main_folder,dtime,varargin)

[data_stations,~]=read_data_stations(paths_main_folder,varargin{:});
[time_diff,idx_get]=min(abs(data_stations.time-dtime));
val=data_stations.waarde(idx_get);

end