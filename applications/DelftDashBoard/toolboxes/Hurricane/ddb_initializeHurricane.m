function handles=ddb_initializeHurricane(handles,varargin)

ii=strmatch('Hurricane',{handles.Toolbox(:).name},'exact');

if nargin>1
    switch varargin{1}
        case{'test'}
            return
        case{'veryfirst'}
            return
    end
end

handles.Toolbox(ii).Input.nrPoint   = 0;
handles.Toolbox(ii).Input.name      = '';
handles.Toolbox(ii).Input.holland   = 0;
handles.Toolbox(ii).Input.initSpeed = 0;
handles.Toolbox(ii).Input.initDir   = 0;
% handles.Toolbox(ii).Input.trk_file  = ' ';
% handles.Toolbox(ii).Input.D3d_start = ' ';
% handles.Toolbox(ii).Input.D3d_sttime= 0.;
% handles.Toolbox(ii).Input.D3d_simper= 0.;
handles.Toolbox(ii).Input.startTime=floor(now);
handles.Toolbox(ii).Input.timeStep=6;
handles.Toolbox(ii).Input.vMax=40;
handles.Toolbox(ii).Input.pDrop=1000;
handles.Toolbox(ii).Input.parA=1;
handles.Toolbox(ii).Input.parB=1;
handles.Toolbox(ii).Input.date=[];
handles.Toolbox(ii).Input.trX=[];
handles.Toolbox(ii).Input.trY=[];
handles.Toolbox(ii).Input.par1=[];
handles.Toolbox(ii).Input.par2=[];
handles.Toolbox(ii).Input.showDetails=1;
