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

function data_stations=read_data_stations(paths,varargin)

% parin=inputParser;
% 
% addOptional(parin,'location_clear',NaN);
% addOptional(parin,'grootheid',NaN);
% 
% parse(parin,varargin{:});
% 
% var_name=parin.Results;
% str_fields=fieldnames(var_name);

if rem(numel(varargin),2)~=0
    error('Input should be multiple of two')
end
var_name=varargin(1:2:end-1);
var_loc=varargin(2:2:end);

ni=numel(var_name);

paths=paths_data_stations(paths);

load(paths.data_stations_index,'data_stations_index');

ns=numel(data_stations_index);

bol=true(1,ns);
for ki=1:ni
[~,bol_loc]=find_str_in_cell({data_stations_index.(var_name{ki})},var_loc(ki));
bol=bol & bol_loc;
end

idx=find(bol);

nget=numel(idx);
for kget=1:nget
    fname=fullfile(paths.separate,sprintf('%06d.mat',idx(kget)));
    load(fname,'data_one_station')
    data_stations(kget)=data_one_station;
end

end %function
