function handles=ddb_initializeTideStations(handles,varargin)

ii=strmatch('TideStations',{handles.Toolbox(:).name},'exact');

lst=dir([handles.toolBoxDir '\tidestations\*.nc']);

handles.Toolbox(ii).Input.databases={''};

for i=1:length(lst)
    disp(['Loading tide database ' lst(i).name(1:end-3) ' ...']);
    fname=[handles.toolBoxDir 'tidestations\' lst(i).name(1:end-3) '.nc'];
    handles.Toolbox(ii).Input.database(i).longName=nc_attget(fname,nc_global,'title');
    handles.Toolbox(ii).Input.databases{i}=handles.Toolbox(ii).Input.database(i).longName;
    handles.Toolbox(ii).Input.database(i).shortName=lst(i).name(1:end-3);
    handles.Toolbox(ii).Input.database(i).x=nc_varget(fname,'lon');
    handles.Toolbox(ii).Input.database(i).y=nc_varget(fname,'lat');
        
    str=nc_varget(fname,'stations');
    str=str';
    for j=1:size(str,1)
        handles.Toolbox(ii).Input.database(i).stationList{j}=deblank(str(j,:));
    end
    
end

handles.Toolbox(ii).Input.startTime=floor(now);
handles.Toolbox(ii).Input.stopTime=floor(now)+30;
handles.Toolbox(ii).Input.timeStep=10.0;
handles.Toolbox(ii).Input.activeDatabase=1;
handles.Toolbox(ii).Input.activeTideStation=1;
handles.Toolbox(ii).Input.tideStationHandle=[];
handles.Toolbox(ii).Input.activeTideStationHandle=[];
