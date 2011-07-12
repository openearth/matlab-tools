function handles=ddb_initializeTropicalCyclone(handles,varargin)

ii=strmatch('TropicalCyclone',{handles.Toolbox(:).name},'exact');

if nargin>1
    switch varargin{1}
        case{'test'}
            return
        case{'veryfirst'}
            return
    end
end

handles.Toolbox(ii).Input.nrTrackPoints   = 0;
handles.Toolbox(ii).Input.name      = '';
handles.Toolbox(ii).Input.holland   = 0;
handles.Toolbox(ii).Input.initSpeed = 0;
handles.Toolbox(ii).Input.initDir   = 0;
handles.Toolbox(ii).Input.startTime=floor(now);
handles.Toolbox(ii).Input.timeStep=6;
handles.Toolbox(ii).Input.vMax=120;
handles.Toolbox(ii).Input.pDrop=5000;
handles.Toolbox(ii).Input.parA=1;
handles.Toolbox(ii).Input.parB=1;
handles.Toolbox(ii).Input.trackT=floor(now);
handles.Toolbox(ii).Input.trackX=0;
handles.Toolbox(ii).Input.trackY=0;
handles.Toolbox(ii).Input.trackVMax=0;
handles.Toolbox(ii).Input.trackPDrop=0;
handles.Toolbox(ii).Input.par1=[];
handles.Toolbox(ii).Input.par2=[];
handles.Toolbox(ii).Input.showDetails=1;
handles.Toolbox(ii).Input.name='Hurricane Deepak';
handles.Toolbox(ii).Input.radius=1000;
handles.Toolbox(ii).Input.nrRadialBins=500;
handles.Toolbox(ii).Input.nrDirectionalBins=36;
