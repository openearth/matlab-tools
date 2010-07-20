function handles=ddb_initializeHurricane(handles,varargin)

ii=strmatch('Hurricane',{handles.Toolbox(:).Name},'exact');

if nargin>1
    switch varargin{1}
        case{'test'}
            return
        case{'veryfirst'}
            return
    end
end

handles.Toolbox(ii).Input.NrPoint   = 0;
handles.Toolbox(ii).Input.Name      = '';
handles.Toolbox(ii).Input.Holland   = 0;
handles.Toolbox(ii).Input.InitSpeed = 0;
handles.Toolbox(ii).Input.InitDir   = 0;
% handles.Toolbox(ii).Input.trk_file  = ' ';
% handles.Toolbox(ii).Input.D3d_start = ' ';
% handles.Toolbox(ii).Input.D3d_sttime= 0.;
% handles.Toolbox(ii).Input.D3d_simper= 0.;
handles.Toolbox(ii).Input.StartTime=floor(now);
handles.Toolbox(ii).Input.TimeStep=6;
handles.Toolbox(ii).Input.VMax=40;
handles.Toolbox(ii).Input.PDrop=1000;
handles.Toolbox(ii).Input.ParA=1;
handles.Toolbox(ii).Input.ParB=1;
handles.Toolbox(ii).Input.Date=[];
handles.Toolbox(ii).Input.TrX=[];
handles.Toolbox(ii).Input.TrY=[];
handles.Toolbox(ii).Input.Par1=[];
handles.Toolbox(ii).Input.Par2=[];
handles.Toolbox(ii).Input.ShowDetails=1;
