%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 17273 $
%$Date: 2021-05-07 21:37:43 +0200 (Fri, 07 May 2021) $
%$Author: chavarri $
%$Id: absolute_limits.m 17273 2021-05-07 19:37:43Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/general/absolute_limits.m $
%
%get value at station for a certain time

function [val,time_diff]=station_data_on_day(paths_main_folder,dtime,varargin)

[data_stations,~]=read_data_stations(paths_main_folder,varargin{:});
[time_diff,idx_get]=min(abs(data_stations.time-dtime));
val=data_stations.waarde(idx_get);

end