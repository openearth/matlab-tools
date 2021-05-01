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

function paths=paths_data_stations(paths)

paths.data_stations=fullfile(paths.main_folder,'data_stations.mat');
paths.data_stations_index=fullfile(paths.main_folder,'data_stations_index.mat');
paths.separate=fullfile(paths.main_folder,'separate');

end