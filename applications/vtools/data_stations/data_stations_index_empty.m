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