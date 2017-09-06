function varargout = EHY_opendap (varargin)

%% retrieve information availlable on the Deltares opendap server,
%  (a copy of Rijkswaterstaat Waterbase)
%
%  parameters     = EHY_opendap
%                   returns a cell array with the names of the parameters available
%
%  2 <keyword,value> pairs are implemented
%  Stations            = EHY_opendap('Parameter','waterhoogte')
%                        returns a cell array with the names of the stations where this parameter is measured
%  [times,values]      = EHY_opendap('Parameter','waterhoogte','Station','HoekvH')
%                        returns the time series, times and values, of this parameter at this station
%  [times,values,Info] = EHY_opendap('Parameter','waterhoogte','Station','HoekvH')
%                        returns the time series, times and values, of this parameter at this station
%                        in addition, some general Infomation like for instance:
%                        - Full name of the station,
%                        - Location of the station,
%                        - Measurement height, etc
%                        Is returned in the stucture Info 
%

%% Initialisation 
OPT.Parameter = '';
OPT.Station   = '';

OPT = setproperty(OPT,varargin);

%% Retreive list of files available on the opendap server
[path,~,~] = fileparts(mfilename('fullpath'));

if ~exist([path filesep 'list_opendap.mat'],'file')
    url = 'http://opendap.deltares.nl/thredds/catalog/opendap/rijkswaterstaat/waterbase/catalog.xml';
    list = opendap_catalog(url,'disp','','maxlevel',4);
    save([path filesep 'list_opendap.mat'],'list'); 
else
    load([path filesep 'list_opendap.mat']);
end

%% Nothing specified, return list of possible parameters
if isempty(OPT.Parameter)
    i_par = 1;
    for i_data = 1: length(list)
        i_sep = strfind(list{i_data},'/');
        name_tmp = list{i_data}(i_sep(end-2) + 1:i_sep(end-1) - 1);
        if i_data == 1
            name_par{i_par} = name_tmp;
        else
            if ~strcmp(name_tmp,name_par{i_par})
                i_par = i_par + 1;
                name_par{i_par} = name_tmp;
            end
        end
    end
    varargout = {sort(name_par)};
end

%% Parameter name specified
if ~isempty(OPT.Parameter)
    i_stat = find(~cellfun(@isempty,strfind(lower(list),lower(OPT.Parameter))));
    list_stat = list(i_stat);
    if isempty(OPT.Station)
        %% No station name specified, return list of stations
        i_stat = 1;
        for i_data = 1: length(list_stat)
            i_sep = strfind(list_stat{i_data},'/');
            name_tmp = list_stat{i_data}(i_sep(end) + 1:end-3);
            i_id     = strfind(name_tmp,'-');
            name_tmp = name_tmp(i_id+1:end);

            if i_data == 1
                name_stat{i_stat} = name_tmp;
            else
                if ~strcmp(name_tmp,name_stat{i_stat})
                    i_stat            = i_stat + 1;
                    name_stat{i_stat} = name_tmp;
                end
            end
        end
        varargout = {sort(name_stat)};
    else
        %% Station name specified, return time series of the parameter at this station
        %  First find the station
        try
            i_stat = find(~cellfun(@isempty,strfind(lower(list_stat),lower(OPT.Station))));
            
            % Get information on the parameter name on the file
            date_tmp  = [];
            value_tmp = [];
            if ~isempty(i_stat)
                for i_par = 1: length(i_stat)
                    Info       = ncinfo(list_stat{i_stat(i_par)});
                    param_name = Info.Variables(end).Name;
                    
                    %% Retrieve data
                    D           = nc_cf_timeseries(list_stat{i_stat(i_par)},param_name,'plot',0);
                    date_tmp    = [date_tmp  D.datenum'     ];
                    value_tmp   = [value_tmp D.(param_name)'];
                end
                [dates,index]   = sort(date_tmp);
                values          = value_tmp(index);
                varargout{1} = dates;
                varargout{2} = values;
                
                %% Retrieve general information (if requested)
                if nargout == 3
                    for i_var = 1: length(Info.Variables) - 2
                        if i_var <= 2
                            geninf.(Info.Variables(i_var).Name) = ncread(list_stat{i_stat(i_par)},Info.Variables(i_var).Name)';
                        else
                            geninf.(Info.Variables(i_var).Name) = ncread(list_stat{i_stat(i_par)},Info.Variables(i_var).Name);
                        end
                    end
                    varargout{3} = geninf;
                end
            else
                varargout{1} = [datenum(1900,1,1); datenum(now)];
                varargout{2} = [NaN              ; NaN         ];
                if nargout == 3
                    varargout{3} = 'Station not found on Deltares OPENDAP server';
                end
                
            end
            
       catch
             disp(['Problems retrieving OPENDAP data for station : ' OPT.Station]);
             if nargout == 2
                 [dates,values]        = EHY_opendap (varargin{1:end});
             elseif nargout == 3
                 [dates,values,geninf] = EHY_opendap (varargin{1:end});
                 varargout{3}          = geninf;
             end
             varargout{1} = dates;
             varargout{2} = values;
        end
    end
        
end

