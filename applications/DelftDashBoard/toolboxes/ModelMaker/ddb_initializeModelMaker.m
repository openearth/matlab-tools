function handles=ddb_initializeModelMaker(handles,varargin)

ii=strmatch('ModelMaker',{handles.Toolbox(:).Name},'exact');

if nargin>1
    switch varargin{1}
        case{'test'}
            return
        case{'veryfirst'}
            handles.Toolbox(ii).LongName='Model Maker';
            return
    end
end

handles.Toolbox(ii).Input.nX=1;
handles.Toolbox(ii).Input.dX=0.1;
handles.Toolbox(ii).Input.XOri=1.0;
handles.Toolbox(ii).Input.nY=1;
handles.Toolbox(ii).Input.dY=0.1;
handles.Toolbox(ii).Input.YOri=1.0;
handles.Toolbox(ii).Input.Rotation=0.0;
handles.Toolbox(ii).Input.SectionLength=10;
handles.Toolbox(ii).Input.ZMax=0;
handles.Toolbox(ii).Input.ViewGridOutline=1;

handles.Toolbox(ii).Input.YOffshore=400;
handles.Toolbox(ii).Input.DXCoast=100;
handles.Toolbox(ii).Input.DYMinCoast=10;
handles.Toolbox(ii).Input.DYMaxCoast=50;
handles.Toolbox(ii).Input.CoastSplineX=[];
handles.Toolbox(ii).Input.CoastSplineY=[];
handles.Toolbox(ii).Input.CourantCoast=10;
handles.Toolbox(ii).Input.NSmoothCoast=1.1;
handles.Toolbox(ii).Input.DepthRelCoast=5;
