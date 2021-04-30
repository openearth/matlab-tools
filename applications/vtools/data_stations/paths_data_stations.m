%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 17162 $
%$Date: 2021-04-08 11:02:29 +0200 (Thu, 08 Apr 2021) $
%$Author: chavarri $
%$Id: figure_layout.m 17162 2021-04-08 09:02:29Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/general/figure_layout.m $
%

function paths=paths_data_stations(paths)

paths.data_stations=fullfile(paths.main_folder,'data_stations.mat');
paths.data_stations_index=fullfile(paths.main_folder,'data_stations_index.mat');
paths.separate=fullfile(paths.main_folder,'separate');

end