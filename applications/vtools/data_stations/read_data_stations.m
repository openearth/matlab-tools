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
%INPUT:
%   paths.main_folder = path to the main folder of the stations; e.g. paths.main_folder='d:\temporal\data_stations';
%   OPTION 1
%   varargin = pair-input with token-name and token; e.g.:
%           -'location_clear','Rood-9'
%           -'grootheid','CONCTTE'
%
%   OPTION 2
%   varargin = 'loadall'; for loading all data
%
%   OPTION 3
%   varargin = boolean with <true> at the indices to load
%
%   OPTION 4
%   varargin = double indices to load

function [data_stations,idx]=read_data_stations(paths_main_folder,varargin)

%% PARSE

if isempty(paths_main_folder)
    paths_main_folder='C:\Users\chavarri\checkouts\riv\data_stations\';
    
end
if ~isfolder(paths_main_folder)
    error('Input folder does not exist: %s',paths_main_folder)
end

%% CALC

%get indices of stations to read
idx=data_stations_stations_to_load(paths_main_folder,varargin{:});

%% load data

nget=numel(idx);
if nget~=0
    for kget=1:nget
        fname=data_stations_get_file_name(paths_main_folder,idx(kget));
        load(fname,'data_one_station')
        data_stations(kget)=data_one_station;
    end
else
    data_stations=[];
    fprintf('No station found \n')
end

end %function
