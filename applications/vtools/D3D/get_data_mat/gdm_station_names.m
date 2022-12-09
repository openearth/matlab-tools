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
%Read name of stations. 
%
%From file by providing:
%   -str_flg_path

function stations=gdm_station_names(fid_log,flg_loc,fpath_his,varargin)

%% PARSE

parin=inputParser;

addOptional(parin,'obs_type',1); %1=stations, 2=cross-section
addOptional(parin,'model_type',2); 

parse(parin,varargin{:});

obs_type=parin.Results.obs_type;
model_type=parin.Results.model_type;

%%

switch model_type
    case {1,5}
        model_type_str='d3d';
    case {2,4}
        model_type_str='dfm';
    case 3
        model_type_str='sobek3';
end

%% CHOSE

switch obs_type
    case 1
        str_flg='stations';
    case 2
        str_flg='crs';
    otherwise
        error('Add')
end
str_flg_path=sprintf('fpath_%s',str_flg);

if ~isfield(flg_loc,str_flg)
    if isfield(flg_loc,str_flg_path)
        messageOut(fid_log,sprintf('Reading stations from file: %s',flg_loc.(str_flg_path)));
        if exist(flg_loc.(str_flg_path),'file')~=2
            error('File with stations does not exist %s',flg_loc.(str_flg_path))
        else
            stations_raw=readcell(flg_loc.(str_flg_path));
            flg_loc.(str_flg)=stations_raw(:,1)';
        end
    else
        flg_loc.(str_flg)=NaN; 
    end
end

%% CALC

if ~iscell(flg_loc.(str_flg))
    if obs_type==1
        stations=EHY_getStationNames(fpath_his,model_type_str);
    elseif obs_type==2
        stations=EHY_getStationNames(fpath_his,model_type_str,'varName','cross_section_*');
    else
        error('')
    end
else
    stations=flg_loc.(str_flg);
end

end %function
