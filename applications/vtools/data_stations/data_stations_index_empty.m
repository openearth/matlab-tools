%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 19958 $
%$Date: 2024-12-14 05:17:46 +0100 (Sat, 14 Dec 2024) $
%$Author: ottevan $
%$Id: add_data_stations.m 19958 2024-12-14 04:17:46Z ottevan $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/data_stations/add_data_stations.m $
%

function data_stations_index=data_stations_index_empty

data_stations_index.location='';
data_stations_index.x='';
data_stations_index.y='';
data_stations_index.raai=[];
data_stations_index.grootheid='';
data_stations_index.parameter='';
data_stations_index.eenheid='';
data_stations_index.time=[];
data_stations_index.waarde=[];
data_stations_index.source={};
data_stations_index.epsg=[];
data_stations_index.bemonsteringshoogte=[];
data_stations_index.location_clear='';
data_stations_index.branch='';
data_stations_index.dist_mouth=[];

end %function