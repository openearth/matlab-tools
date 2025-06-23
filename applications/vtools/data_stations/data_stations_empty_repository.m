%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 19684 $
%$Date: 2024-06-21 22:39:59 +0200 (Fri, 21 Jun 2024) $
%$Author: chavarri $
%$Id: paths_data_stations.m 19684 2024-06-21 20:39:59Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/data_stations/paths_data_stations.m $
%

function data_stations_empty_repository(paths_main_folder)

paths=paths_data_stations(paths_main_folder);

mkdir_check(paths.separate);
mkdir_check(paths.figures);
mkdir_check(paths.csv);

data_stations_index=data_stations_index_empty;
save(paths.data_stations_index,'data_stations_index')

end %function