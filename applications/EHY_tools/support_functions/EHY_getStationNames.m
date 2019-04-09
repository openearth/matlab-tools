function stationNames = EHY_getStationNames(inputFile,modelType,varargin)
%% stationNames = EHY_getStationNames(outputfile,modelType,varargin)
%
% This function returns the station names based on a model output file
%
% Example1: 	stationNames=EHY_getStationNames('D:\trih-r01.dat','d3d')
% Example2: 	stationNames=EHY_getStationNames('D:\r01_his.nc','dflowfm')
% Example3: 	stationNames=EHY_getStationNames('D:\SDS-run1','simona','varName','uv')
%
% Note that SIMONA models can have different water level vs. velocity stations 
%
% support function of the EHY_tools
% Julien Groenenboom - E: Julien.Groenenboom@deltares.nl

OPT.varName = 'wl'; % 'wl','uv','crs'

OPT         = setproperty(OPT,varargin);

%% modify user input
if ~isempty(strfind(OPT.varName,'cross_section_'))
    % if cross-section data is requested, get the names of the cross-sections
    OPT.varName='crs';
end

%%
switch modelType
    
    case {'d3dfm','dflow','dflowfm','mdu','dfm'}
        %% Delft3D-Flexible Mesh
        if strcmp(lower(OPT.varName),'crs')
            stationNames  = cellstr(strtrim(nc_varget(inputFile,'cross_section_name')));
        else % 'wl' or 'uv'
            stationNames  = cellstr(strtrim(nc_varget(inputFile,'station_name'))); 
        end
    case {'d3d','d3d4','delft3d4','mdf'}
        %% Delft3D 4
        trih=vs_use(inputFile,'quiet');
        stationNames=cellstr(strtrim(vs_get(trih,'his-const',{1},'NAMST','quiet')));
        
    case {'waqua','simona','siminp','triwaq'}
        %% SIMONA (WAQUA/TRIWAQ)
        sds= qpfopen(inputFile);
        if strcmpi(OPT.varName,'uv')
            stationNames  = strtrim(waquaio(sds,[],'flowstat-uv'));
        elseif strcmpi(OPT.varName,'wl') || strcmpi(OPT.varName,'dps')
            stationNames  = strtrim(waquaio(sds,[],'flowstat-wl'));
        elseif strcmpi(OPT.varName,'salinity') || strcmpi(OPT.varName,'temperature')
            stationNames  = strtrim(waquaio(sds,[],'transtat'));
        end
        
    case {'sobek3' 'sobek3_new'}
        
        %% SOBEK3
        D=read_sobeknc(inputFile);
        % Old format
        try
            stationNames=cellstr(strtrim(D.feature_name'));
        % New format
        catch
             stationNames=cellstr(D.observation_id');
        end
    case {'implic'}
        %% IMPLIC
        D         = dir2(inputFile,'file_incl','\.dat$');
        files     = find(~[D.isdir]);
        filenames = {D(files).name};
        for i_stat = 1: length(filenames)
            [~,name,~] = fileparts(filenames{i_stat});
            stationNames{i_stat} = name;
        end      
end