function handles=ddb_initializeTsunami(handles,varargin)

ii=strmatch('Tsunami',{handles.Toolbox(:).Name},'exact');

if nargin>1
    switch varargin{1}
        case{'veryfirst'}
            return
    end
end

handles.Toolbox(ii).Input.NrSegments=0;

handles.Toolbox(ii).Input.Magnitude=0.0;
handles.Toolbox(ii).Input.DepthFromTop=0.0;
handles.Toolbox(ii).Input.RelatedToEpicentre=0;
handles.Toolbox(ii).Input.Latitude=0.0;
handles.Toolbox(ii).Input.Longitude=0.0;
handles.Toolbox(ii).Input.TotalFaultLength=0.0;
handles.Toolbox(ii).Input.TotalUserFaultLength=0.0;
handles.Toolbox(ii).Input.FaultWidth=0.0;
handles.Toolbox(ii).Input.Dislocation=0.0;
handles.Toolbox(ii).Input.Segment=0.0;

handles.Toolbox(ii).Input.FaultLength=0;
handles.Toolbox(ii).Input.Strike=0;
handles.Toolbox(ii).Input.Dip=0;
handles.Toolbox(ii).Input.SlipRake=0;
handles.Toolbox(ii).Input.FocalDepth=0;
