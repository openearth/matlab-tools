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

%% parse

loadall=false;
loadbol=false;
loadidx=false;

if numel(varargin)==1 
    if ischar(varargin{1,1})
        switch varargin{1,1}
            case 'loadall'
                loadall=true;
        end
    elseif islogical(varargin{1,1})
        loadbol=true;
        bol=varargin{1,1};
    else
        loadidx=true;
        idx=varargin{1,1};
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
if ~loadidx
    if ~loadbol
        ns=numel(data_stations_index);
        bol=true(1,ns);
        if ~loadall
            for ki=1:ni
                bol_loc=true(1,ns);
                if ischar(var_loc{ki}) && ~isempty(var_loc{ki})
                    [~,bol_loc]=find_str_in_cell({data_stations_index.(var_name{ki})},var_loc(ki));
                elseif isa(var_loc{ki},'double') && ~isnan(var_loc{ki})
                    bol_loc=[data_stations_index.(var_name{ki})]==var_loc{ki};
                end
                bol=bol & bol_loc;
            end
        end
    end %loadbol
    idx=find(bol);
end %loadidx

%% load data

nget=numel(idx);
if nget~=0
    for kget=1:nget
        fname=fullfile(paths.separate,sprintf('%06d.mat',idx(kget)));
        load(fname,'data_one_station')
        data_stations(kget)=data_one_station;
    end
else
    data_stations=[];
    fprintf('No station found \n')
end

end %function
