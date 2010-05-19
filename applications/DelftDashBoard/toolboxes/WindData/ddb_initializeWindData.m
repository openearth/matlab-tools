function handles=ddb_initializeWindData(handles,varargin)

ii=strmatch('WindData',{handles.Toolbox(:).Name},'exact');

if nargin>1
    switch varargin{1}
        case{'veryfirst'}
            handles.Toolbox(ii).LongName='Wind Data';
            return
    end
end

handles.Toolbox(ii).Input.StartTime=floor(now)-5;
handles.Toolbox(ii).Input.StopTime=floor(now);
handles.Toolbox(ii).Input.Source='Weather Underground';
handles.Toolbox(ii).Input.windData=[];
handles.Toolbox(ii).Input.WindDataStations.xy=[];
handles.Toolbox(ii).Input.WindDataStations.id=[];
handles.Toolbox(ii).Input.WindDataStations.name=[];
handles.Toolbox(ii).Input.analyzedWindData=[];
