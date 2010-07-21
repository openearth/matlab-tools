function handles=ddb_initializeTiling(handles,varargin)

ii=strmatch('Tiling',{handles.Toolbox(:).Name},'exact');
if nargin>1
    switch varargin{1}
        case{'test'}
            return
        case{'veryfirst'}
            handles.Toolbox(ii).LongName='Tiling';
            return
    end
end

handles.Toolbox(ii).x0=0;
handles.Toolbox(ii).y0=0;
handles.Toolbox(ii).nx=0;
handles.Toolbox(ii).ny=0;
handles.Toolbox(ii).nrZoom=0;

handles.Toolbox(ii).fileName='';
handles.Toolbox(ii).dataName='';
handles.Toolbox(ii).dataDir=[handles.BathyDir];
