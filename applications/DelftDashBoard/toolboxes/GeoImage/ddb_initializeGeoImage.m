function handles=ddb_initializeGeoImage(handles,varargin)

ii=strmatch('GeoImage',{handles.Toolbox(:).name},'exact');

if nargin>1
    switch varargin{1}
        case{'test'}
            return
        case{'veryfirst'}
            handles.Toolbox(ii).longName='Geo Image';
            return
    end
end

handles.Toolbox(ii).Input.imageOutlineHandle=[];
handles.Toolbox(ii).Input.xLim      = [0 0];
handles.Toolbox(ii).Input.yLim      = [0 0];
handles.Toolbox(ii).Input.zoomLevel = 0;
handles.Toolbox(ii).Input.nPix      = 1024;
handles.Toolbox(ii).Input.whatKind  = 'aerial';

handles.Toolbox(ii).Input.zoomLevelStrings{1}  = 'auto';
for i=2:21
    handles.Toolbox(ii).Input.zoomLevelStrings{i}  = num2str(i+2);
end
