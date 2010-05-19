function handles=ddb_initializeGeoImage(handles,varargin)

ii=strmatch('GeoImage',{handles.Toolbox(:).Name},'exact');

if nargin>1
    switch varargin{1}
        case{'veryfirst'}
            handles.Toolbox(ii).LongName='Geo Image';
            return
    end
end

handles.Toolbox(ii).Input.XLim      = [0 0];
handles.Toolbox(ii).Input.YLim      = [0 0];
handles.Toolbox(ii).Input.ZoomLevel = 0;
handles.Toolbox(ii).Input.NPix      = 1024;
