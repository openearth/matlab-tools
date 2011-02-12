function ddb_initialize(varargin)

switch lower(varargin{1}),

    case{'startup'}

        disp('Finding coordinate systems ...');
        ddb_getCoordinateSystems;

        disp('Finding tide models ...');
        ddb_findTideModels;
        
        disp('Finding bathymetry datasets ...');
        ddb_findBathymetryDatabases;
        
        disp('Finding shorelines ...');
        ddb_findShorelines;
        
        disp('Finding toolboxes ...');
        ddb_findToolboxes;
        
        disp('Finding models ...');
        ddb_findModels;

        disp('Initializing screen parameters ...');
        ddb_initializeScreenParameters;
        
        disp('Initializing figure ...');
        ddb_initializeFigure;

%         disp('Initializing bathymetry ...');
%         handles=ddb_initializeBathymetry(handles);

        disp('Initializing models ...');
        ddb_initializeModels;

        disp('Initializing toolboxes ...');
        ddb_initializeToolboxes;

        disp('Adding model tabpanels ...');
        ddb_addModelTabPanels;

        disp('Loading additional map data ...');
        ddb_loadMapData;

        disp('Initializing screen ...');
        ddb_makeMapPanel;

        disp('Updating data in screen ...');
        ddb_updateDataInScreen;
                
        % Toolbox is selected in ddb_selectModel        
        ddb_selectModel('Delft3DFLOW','toolbox');

        handles=getHandles;
        
        try
            set(handles.GUIHandles.MainWindow,'WindowScrollWheelFcn',@ddb_zoomScrollWheel);
        end

        set(handles.GUIHandles.MainWindow,'KeyPressFcn',@ddb_shiftPan);
        set(handles.GUIHandles.MainWindow,'ResizeFcn',@ddb_resize);

        ddb_setWindowButtonUpDownFcn;
        ddb_setWindowButtonMotionFcn;
        
    case{'all'}
        ddb_initializeModels;
        ddb_initializeToolboxes;
        ddb_refreshFlowDomains;

    otherwise

end
