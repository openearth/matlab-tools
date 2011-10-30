function handles=ddb_initializeTideStations(handles,varargin)

ii=strmatch('TideStations',{handles.Toolbox(:).name},'exact');

dr=handles.Toolbox(ii).dataDir;
lst=dir([dr '*.nc']);

handles.Toolbox(ii).Input.databases={''};

for i=1:length(lst)
    disp(['Loading tide database ' lst(i).name(1:end-3) ' ...']);
    fname=[dr lst(i).name(1:end-3) '.nc'];
    handles.Toolbox(ii).Input.database(i).longName=nc_attget(fname,nc_global,'title');
    handles.Toolbox(ii).Input.databases{i}=handles.Toolbox(ii).Input.database(i).longName;
    handles.Toolbox(ii).Input.database(i).shortName=lst(i).name(1:end-3);
    handles.Toolbox(ii).Input.database(i).x=nc_varget(fname,'lon');
    handles.Toolbox(ii).Input.database(i).y=nc_varget(fname,'lat');
    handles.Toolbox(ii).Input.database(i).xLoc=handles.Toolbox(ii).Input.database(i).x;
    handles.Toolbox(ii).Input.database(i).yLoc=handles.Toolbox(ii).Input.database(i).y;
    
    handles.Toolbox(ii).Input.database(i).coordinateSystem='WGS 84';
    handles.Toolbox(ii).Input.database(i).coordinateSystemType='geographic';

    str=nc_varget(fname,'components');
    str=str';
    for j=1:size(str,1)
        handles.Toolbox(ii).Input.database(i).components{j}=deblank(str(j,:));
    end

    str=nc_varget(fname,'stations');
    str=str';
    for j=1:size(str,1)
        handles.Toolbox(ii).Input.database(i).stationList{j}=deblank(str(j,:));
        % Short names
        name=deblank(str(j,:));
        name=strrep(name,' ','');
        name=strrep(name,'#','');
        name=strrep(name,'\','');
        name=strrep(name,'/','');
        name=strrep(name,'.','');
        name=strrep(name,',','');
        name=strrep(name,'(','');
        name=strrep(name,')','');
        name=name(double(name)<1000);
        handles.Toolbox(ii).Input.database(i).stationShortNames{j}=name;
    end

    str=nc_varget(fname,'idcodes');
    str=str';
    for j=1:size(str,1)
        handles.Toolbox(ii).Input.database(i).idCodes{j}=deblank(str(j,:));
    end
    

end

handles.Toolbox(ii).Input.startTime=floor(now);
handles.Toolbox(ii).Input.stopTime=floor(now)+30;
handles.Toolbox(ii).Input.timeStep=30.0;
handles.Toolbox(ii).Input.activeDatabase=1;
handles.Toolbox(ii).Input.activeTideStation=1;
handles.Toolbox(ii).Input.tideStationHandle=[];
handles.Toolbox(ii).Input.activeTideStationHandle=[];

handles.Toolbox(ii).Input.components={''};
handles.Toolbox(ii).Input.amplitudes=0;
handles.Toolbox(ii).Input.phases=0;
handles.Toolbox(ii).Input.timeZone=0;
