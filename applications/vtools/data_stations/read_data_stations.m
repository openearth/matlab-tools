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
%   varargin = pair-input with token-name and token; e.g. 'location_clear','Rood-9'
%       for loading all data: 'loadall'

function [data_stations,idx]=read_data_stations(paths_main_folder,varargin)

%% parse
loadall=false;
if numel(varargin)==1 
    
    switch varargin{1,1}
        case 'loadall'
            loadall=true;
    end
    
else

    if rem(numel(varargin),2)~=0
        error('Input should be multiple of two')
    end
    var_name=varargin(1:2:end-1);
    var_loc=varargin(2:2:end);

    ni=numel(var_name);
end

paths=paths_data_stations(paths_main_folder);

load(paths.data_stations_index,'data_stations_index');

%% stations to load
ns=numel(data_stations_index);
bol=true(1,ns);
if ~loadall
    for ki=1:ni
    [~,bol_loc]=find_str_in_cell({data_stations_index.(var_name{ki})},var_loc(ki));
    bol=bol & bol_loc;
    end
end

%% load data
idx=find(bol);
nget=numel(idx);
if nget~=0
    for kget=1:nget
        fname=fullfile(paths.separate,sprintf('%06d.mat',idx(kget)));
        load(fname,'data_one_station')
        data_stations(kget)=data_one_station;
    end
else
    data_stations=[];
end

end %function
