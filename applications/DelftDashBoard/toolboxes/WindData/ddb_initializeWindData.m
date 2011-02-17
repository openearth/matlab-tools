function handles=ddb_initializeWindData(handles,varargin)

ii=strmatch('WindData',{handles.Toolbox(:).name},'exact');

if nargin>1
    switch varargin{1}
        case{'test'}
            return
        case{'veryfirst'}
            handles.Toolbox(ii).longName='Wind Data';
            return
    end
end

handles.Toolbox(ii).Input.startTime=floor(now)-5;
handles.Toolbox(ii).Input.stopTime=floor(now);
handles.Toolbox(ii).Input.source='Weather Underground';
handles.Toolbox(ii).Input.windData=[];
handles.Toolbox(ii).Input.windDataStations.xy=[];
handles.Toolbox(ii).Input.windDataStations.id=[];
handles.Toolbox(ii).Input.windDataStations.name=[];
handles.Toolbox(ii).Input.analyzedWindData=[];
