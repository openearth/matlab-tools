%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 17447 $
%$Date: 2021-08-04 13:03:01 +0200 (Wed, 04 Aug 2021) $
%$Author: chavarri $
%$Id: read_data_stations.m 17447 2021-08-04 11:03:01Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/data_stations/read_data_stations.m $
%

function fname=data_stations_get_file_name(paths_main_folder,idx)
paths=paths_data_stations(paths_main_folder);
fname=fullfile(paths.separate,sprintf('%06d.mat',idx));
