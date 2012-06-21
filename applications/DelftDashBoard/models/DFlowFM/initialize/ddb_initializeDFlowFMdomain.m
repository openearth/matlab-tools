function handles = ddb_initializeDFlowFMdomain(handles, opt, id, runid)

handles.Model(md).Input(id).grid=[];

handles.Model(md).Input(id).runid=runid;
handles.Model(md).Input(id).attName=runid;

%% Model
handles.Model(md).Input(id).autoStart=0;

handles.Model(md).Input(id).description={''};

%% Geometry
handles.Model(md).Input(id).netFile             = '';
handles.Model(md).Input(id).bathymetryFile      = '';
handles.Model(md).Input(id).waterLevIniFile     = '';                 
handles.Model(md).Input(id).landBoundaryFile    = '';                     
handles.Model(md).Input(id).thinDamFile         = '';                     
handles.Model(md).Input(id).thinDykeFile        = '';                    
handles.Model(md).Input(id).profLocFile         = '';                     
handles.Model(md).Input(id).profDefFile         = '';                    
handles.Model(md).Input(id).manHoleFile         = '';
handles.Model(md).Input(id).waterLevIni         = 0;
handles.Model(md).Input(id).botLevUni           = -5;
handles.Model(md).Input(id).botLevType          = 3;
handles.Model(md).Input(id).angLat              = 0;
handles.Model(md).Input(id).conveyance2D        = 3;

%% Numerics

handles.Model(md).Input(id).CFLMax              = 0.7;
handles.Model(md).Input(id).CFLWaveFrac         = 0.1;
handles.Model(md).Input(id).advecType           = 3;
handles.Model(md).Input(id).limTypSa            = 0;
handles.Model(md).Input(id).hDam                = 0;

%% Physics

handles.Model(md).Input(id).unifFrictCoef       = 0.023;
handles.Model(md).Input(id).unifFrictType       = 1;
handles.Model(md).Input(id).vicoUV              = 0;
handles.Model(md).Input(id).smagorinsky         = 0;
handles.Model(md).Input(id).elder               = 0;
handles.Model(md).Input(id).irov                = 0;
handles.Model(md).Input(id).wallKs              = 0;
handles.Model(md).Input(id).vicoWW              = 0;
handles.Model(md).Input(id).tidalForcing        = 1;
handles.Model(md).Input(id).salinity            = 0;

%% Time

handles.Model(md).Input(id).refDate        = floor(now);
handles.Model(md).Input(id).tUnit          = 's';
handles.Model(md).Input(id).dtUser         = 60.0;
handles.Model(md).Input(id).dtMax          = 60.0;
handles.Model(md).Input(id).dtInit         = 1.0;
handles.Model(md).Input(id).autoTimeStep   = 0;
handles.Model(md).Input(id).tStart         = floor(now);
handles.Model(md).Input(id).tStop          = floor(now)+10;

%% External forcing
handles.Model(md).Input(id).extForceFile        = '';

handles.Model(md).Input(id).boundarySections = [];

%% Output
handles.Model(md).Input(id).obsFile      = '';
handles.Model(md).Input(id).crsFile      = '';
handles.Model(md).Input(id).hisFile      = '';
handles.Model(md).Input(id).hisInterval  = 600.0;
handles.Model(md).Input(id).xlsInterval  = 0;
handles.Model(md).Input(id).flowGeomFile = '';
handles.Model(md).Input(id).mapFile      = '';
handles.Model(md).Input(id).mapInterval  = 3600;
handles.Model(md).Input(id).rstInterval  = 0;
handles.Model(md).Input(id).waqFileBase  = '';
handles.Model(md).Input(id).waqInterval  = 0;
handles.Model(md).Input(id).snapshotDir  = '';
