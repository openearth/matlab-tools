function handles=ddb_initializeTsunami(handles,varargin)

ii=strmatch('Tsunami',{handles.Toolbox(:).name},'exact');

if nargin>1
    switch varargin{1}
        case{'test'}
            return
        case{'veryfirst'}
            return
    end
end

handles.Toolbox(ii).Input.nrSegments=0;

handles.Toolbox(ii).Input.magnitude=0.0;
handles.Toolbox(ii).Input.depthFromTop=0.0;
handles.Toolbox(ii).Input.relatedToEpicentre=0;
handles.Toolbox(ii).Input.latitude=0.0;
handles.Toolbox(ii).Input.longitude=0.0;
handles.Toolbox(ii).Input.totalFaultLength=0.0;
handles.Toolbox(ii).Input.totalUserFaultLength=0.0;
handles.Toolbox(ii).Input.faultWidth=0.0;
handles.Toolbox(ii).Input.dislocation=0.0;
handles.Toolbox(ii).Input.segment=0.0;

handles.Toolbox(ii).Input.faultLength=0;
handles.Toolbox(ii).Input.strike=0;
handles.Toolbox(ii).Input.dip=0;
handles.Toolbox(ii).Input.slipRake=0;
handles.Toolbox(ii).Input.focalDepth=0;
