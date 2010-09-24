function handles=ddb_initialize(handles,varargin)

switch lower(varargin{1}),

    case{'startup'}

        disp('Finding coordinate systems ...');
        handles=ddb_getCoordinateSystems(handles);

        disp('Finding tide models ...');
        handles=ddb_findTideModels(handles);
        
        disp('Finding bathymetry datasets ...');
        handles=ddb_findBathymetryDatabases(handles);
        
        disp('Finding shorelines ...');
        handles=ddb_findShorelines(handles);
        
        disp('Finding toolboxes ...');
        handles=ddb_findToolboxes(handles);
        handles.activeToolbox.Name='ModelMaker';
        handles.activeToolbox.Nr=1;
        
        disp('Finding models ...');
        handles=ddb_findModels(handles);
        handles.ActiveModel.Name='Delft3DFLOW';
        handles.ActiveModel.Nr=1;

        disp('Initializing screen parameters ...');
        handles=ddb_initializeScreenParameters(handles);
        
        disp('Initializing figure ...');
        handles=ddb_initializeFigure(handles);

        disp('Initializing bathymetry ...');
        handles=ddb_initializeBathymetry(handles);

        setHandles(handles);

        disp('Initializing models ...');
        handles=ddb_initializeModels(handles);
        
        disp('Initializing toolboxes ...');
        handles=ddb_initializeToolboxes(handles);

        disp('Initializing screen ...');
        handles=ddb_initializeScreen(handles);

        setHandles(handles);
        
        ddb_selectModel('Delft3DFLOW');
        % Toolbox is selected in ddb_selectModel        

        handles=getHandles;
        
        try
            set(handles.GUIHandles.MainWindow,'WindowScrollWheelFcn',@ddb_zoomScrollWheel);
        end

        set(handles.GUIHandles.MainWindow,'KeyPressFcn',@ddb_shiftPan);
        set(handles.GUIHandles.MainWindow,'ResizeFcn',@ddb_resize);

        ddb_setWindowButtonUpDownFcn;
        ddb_setWindowButtonMotionFcn;

    case{'all'}
        handles=ddb_initializeModels(handles);
        handles=ddb_initializeToolboxes(handles);
        handles=ddb_refreshFlowDomains(handles);

    otherwise

end

function handles=ddb_initializeModels(handles)
for k=1:length(handles.Model)
    f=handles.Model(k).IniFcn;
    handles=f(handles);
end

function handles=ddb_initializeToolboxes(handles)
for k=1:length(handles.Toolbox)
    f=handles.Toolbox(k).IniFcn;
    handles=f(handles);
end
