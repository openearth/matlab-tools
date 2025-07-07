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

function data_stations_empty_repository(paths_main_folder)

paths=paths_data_stations(paths_main_folder);

mkdir_check(paths.separate);
mkdir_check(paths.figures);
mkdir_check(paths.csv);

data_stations_index=data_stations_index_empty;
save(paths.data_stations_index,'data_stations_index')

end %function