function handles=ddb_initializeModelMaker(handles,varargin)

ii=strmatch('ModelMaker',{handles.Toolbox(:).name},'exact');

if nargin>1
    switch varargin{1}
        case{'test'}
            return
        case{'veryfirst'}
            handles.Toolbox(ii).longName='Model Maker';
            return
    end
end

handles.Toolbox(ii).Input.nX=1;
handles.Toolbox(ii).Input.dX=0.1;
handles.Toolbox(ii).Input.xOri=0.0;
handles.Toolbox(ii).Input.nY=1;
handles.Toolbox(ii).Input.dY=0.1;
handles.Toolbox(ii).Input.yOri=1.0;
handles.Toolbox(ii).Input.rotation=0.0;
handles.Toolbox(ii).Input.sectionLength=10;
handles.Toolbox(ii).Input.zMax=0;
handles.Toolbox(ii).Input.viewGridOutline=1;

handles.Toolbox(ii).Input.yOffshore=400;
handles.Toolbox(ii).Input.dxCoast=100;
handles.Toolbox(ii).Input.dyMinCoast=10;
handles.Toolbox(ii).Input.dyMaxCoast=50;
handles.Toolbox(ii).Input.coastSplineX=[];
handles.Toolbox(ii).Input.coastSplineY=[];
handles.Toolbox(ii).Input.courantCoast=10;
handles.Toolbox(ii).Input.nSmoothCoast=1.1;
handles.Toolbox(ii).Input.depthRelCoast=5;

handles.Toolbox(ii).Input.activeTideModelBC=1;
handles.Toolbox(ii).Input.activeTideModelIC=1;
