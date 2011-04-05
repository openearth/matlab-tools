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

% handles.Toolbox(ii).Input.magnitude=0.0;
% handles.Toolbox(ii).Input.depthFromTop=0.0;
% handles.Toolbox(ii).Input.relatedToEpicentre=0;
% handles.Toolbox(ii).Input.latitude=0.0;
% handles.Toolbox(ii).Input.longitude=0.0;
% handles.Toolbox(ii).Input.totalFaultLength=0.0;
% handles.Toolbox(ii).Input.totalUserFaultLength=0.0;
% handles.Toolbox(ii).Input.faultWidth=0.0;
% handles.Toolbox(ii).Input.dislocation=0.0;
% handles.Toolbox(ii).Input.segment=0.0;
% 
% handles.Toolbox(ii).Input.faultLength=0;
% handles.Toolbox(ii).Input.strike=0;
% handles.Toolbox(ii).Input.dip=0;
% handles.Toolbox(ii).Input.slipRake=0;
% handles.Toolbox(ii).Input.focalDepth=0;


% Overall info
handles.Toolbox(ii).Input.relatedToEpicentre=0;
handles.Toolbox(ii).Input.updateTable=0;

% Earthquake info
handles.Toolbox(ii).Input.Mw=0.0;
handles.Toolbox(ii).Input.depth=0.0;
handles.Toolbox(ii).Input.length=0.0;
handles.Toolbox(ii).Input.width=0.0;
handles.Toolbox(ii).Input.slip=0.0;
handles.Toolbox(ii).Input.strike=0.0;
handles.Toolbox(ii).Input.slipRake=0.0;
handles.Toolbox(ii).Input.lonEpicentre=0.0;
handles.Toolbox(ii).Input.latEpicentre=0.0;

% Segment info (for table)
handles.Toolbox(ii).Input.segmentLon=0.0;
handles.Toolbox(ii).Input.segmentLat=0.0;
handles.Toolbox(ii).Input.segmentX=0.0;
handles.Toolbox(ii).Input.segmentY=0.0;
handles.Toolbox(ii).Input.segmentStrike=0;
handles.Toolbox(ii).Input.segmentDip=0;
handles.Toolbox(ii).Input.segmentSlipRake=0;
handles.Toolbox(ii).Input.segmentDepth=0;
handles.Toolbox(ii).Input.segmentWidth=0;
handles.Toolbox(ii).Input.segmentFocalDepth=0;
handles.Toolbox(ii).Input.segmentSlip=0.0;
