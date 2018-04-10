function stationNames = EHY_getStationNames(outputfile,modelType)

%% Sobek3
switch modelType
    
    case {'d3dfm','dflow','dflowfm','mdu','dfm'}
        %% Delft3D-Flexible Mesh
        stationNames  = cellstr(strtrim(nc_varget(outputfile,'station_name')));
        
    case {'d3d','d3d4','delft3d4','mdf'}
        %% Delft3D 4
        trih=vs_use(outputfile,'quiet');
        stationNames=cellstr(strtrim(vs_get(trih,'his-const',{1},'NAMST','quiet')));
        
    case {'waqua','simona','siminp'}
        %% SIMONA (WAQUA/TRIWAQ)
        sds= qpfopen(outputfile);
        stationNames  = strtrim(qpread(sds,1,'water level (station)','stations'));
        
    case {'sobek3'}
        %% SOBEK3
        D=read_sobeknc(outputfile);
        stationNames=strtrim(D.feature_name_points.Val);
        
    case {'sobek3_new'}
        %% SOBEK3 new
        D           =read_sobeknc(outputfile);
        stationNames=cellstr(D.observation_id');
        
    case {'implic'}
        %% IMPLIC
        if exist([fileparts(outputfile) filesep 'implic.mat'],'file')
            load([fileparts(outputfile) filesep 'implic.mat']);
        else
            D         = dir2(fileparts(outputfile),'file_incl','\.dat$');
            files     = find(~[D.isdir]);
            filenames = {D(files).name};
            for i_stat = 1: length(filenames)
                [~,name,~] = fileparts(filenames{i_stat});
                stationNames{i_stat} = name;
            end
        end
end