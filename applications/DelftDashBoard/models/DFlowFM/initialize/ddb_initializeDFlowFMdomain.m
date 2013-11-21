function handles = ddb_initializeDFlowFMdomain(handles, opt, id, runid)

handles.Model(md).Input(id).runid=runid;

switch lower(opt)
    case{'griddependentinput'}
        handles=initializeGridDependentInput(handles,id);
    case{'all'}
        handles=initializeGridDependentInput(handles,id);
        handles=initializeOtherInput(handles,id,runid);
end

%%
function handles=initializeGridDependentInput(handles,id)

% Only the grid dependent input
handles.Model(md).Input(id).grid=[];
handles.Model(md).Input(id).plothandles=[];

%% Geometry
handles.Model(md).Input(id).netfile             = '';
handles.Model(md).Input(id).netstruc            = [];
handles.Model(md).Input(id).bathymetryfile      = '';
handles.Model(md).Input(id).waterlevinifile     = '';                 
handles.Model(md).Input(id).landboundaryfile    = '';                     
handles.Model(md).Input(id).thindamfile         = '';                     
handles.Model(md).Input(id).thindykefile        = '';                    
handles.Model(md).Input(id).proflocfile         = '';                     
handles.Model(md).Input(id).profdeffile         = '';                    
handles.Model(md).Input(id).manholefile         = '';
handles.Model(md).Input(id).waterlevini         = 0;
handles.Model(md).Input(id).botlevuni           = -5;
handles.Model(md).Input(id).botlevtype          = 3;
handles.Model(md).Input(id).anglat              = 0;
handles.Model(md).Input(id).conveyance2d        = 3;

%% Observation points
handles.Model(md).Input(id).obsfile      = '';
handles.Model(md).Input(id).nrobservationpoints=0;
handles.Model(md).Input(id).observationpoints(1).name='';
handles.Model(md).Input(id).observationpoints(1).x=NaN;
handles.Model(md).Input(id).observationpoints(1).y=NaN;
handles.Model(md).Input(id).observationpointshandle='';
handles.Model(md).Input(id).activeobservationpoint=1;
handles.Model(md).Input(id).observationpointnames={''};
handles.Model(md).Input(id).selectobservationpoint=0;
handles.Model(md).Input(id).changeobservationpoint=0;
handles.Model(md).Input(id).deleteobservationpoint=0;
handles.Model(md).Input(id).addobservationpoint=0;

%% Cross sections
handles.Model(md).Input(id).crsfile      = '';
handles.Model(md).Input(id).nrcrosssections=0;
handles.Model(md).Input(id).crosssections(1).name='';
handles.Model(md).Input(id).crosssections(1).x=0;
handles.Model(md).Input(id).crosssections(1).y=0;
handles.Model(md).Input(id).crosssectionshandle='';
handles.Model(md).Input(id).activecrosssection=1;
handles.Model(md).Input(id).crosssectionnames={''};

%% External forcing
handles.Model(md).Input(id).extforcefile        = '';

% Boundaries
handles.Model(md).Input(id).boundaries = [];
handles.Model(md).Input(id).boundaries(1).name = '';
handles.Model(md).Input(id).boundaries(1).type = 'waterlevelbnd';
handles.Model(md).Input(id).boundaries(1).nodenames = {''};
handles.Model(md).Input(id).boundaries(1).activenode = 1;
handles.Model(md).Input(id).boundaries(1).nodes(1).tim = 0;
handles.Model(md).Input(id).boundaries(1).nodes(1).cmp = 1;
handles.Model(md).Input(id).boundaries(1).nodes(1).cmptype = 'astro';
handles.Model(md).Input(id).nrboundaries = 0;
handles.Model(md).Input(id).boundarynames = {''};
handles.Model(md).Input(id).activeboundary=1;

% Meteo
handles.Model(md).Input(id).windufile = '';
handles.Model(md).Input(id).windvfile = '';
handles.Model(md).Input(id).airpressurefile = '';
handles.Model(md).Input(id).spiderwebfile = '';
handles.Model(md).Input(id).rainfile = '';

%%
function handles=initializeOtherInput(handles,id,runid)

% All the other input

handles.Model(md).Input(id).attName=runid;

%% Model
handles.Model(md).Input(id).autostart=0;

%% Description
handles.Model(md).Input(id).description={''};

%% Numerics
handles.Model(md).Input(id).cflmax              = 0.7;
handles.Model(md).Input(id).cflwavefrac         = 0.1;
handles.Model(md).Input(id).advectype           = 3;
handles.Model(md).Input(id).limtypsa            = 0;
handles.Model(md).Input(id).hdam                = 0;

%% Physics
handles.Model(md).Input(id).uniffrictcoef       = 0.023;
handles.Model(md).Input(id).uniffricttype       = 1;
handles.Model(md).Input(id).vicouv              = 1;
handles.Model(md).Input(id).smagorinsky         = 0;
handles.Model(md).Input(id).elder               = 0;
handles.Model(md).Input(id).irov                = 0;
handles.Model(md).Input(id).wall_ks             = 0.01;
handles.Model(md).Input(id).vicoww              = 0;
handles.Model(md).Input(id).tidalforcing        = 0;
handles.Model(md).Input(id).salinity            = 0;

%% Wind
handles.Model(md).Input(id).icdtyp=3;
handles.Model(md).Input(id).cdbreakpoints=[0.00100  0.00300 0.0015];
handles.Model(md).Input(id).windspeedbreakpoints=[0.0 25.0 50.0];

%% Time
handles.Model(md).Input(id).refdate        = floor(now);
handles.Model(md).Input(id).tunit          = 's';
handles.Model(md).Input(id).dtuser         = 60.0;
handles.Model(md).Input(id).dtmax          = 60.0;
handles.Model(md).Input(id).dtinit         = 1.0;
handles.Model(md).Input(id).autotimestep   = 1;
handles.Model(md).Input(id).tstart         = floor(now);
handles.Model(md).Input(id).tstop          = floor(now)+10;

%% Output
handles.Model(md).Input(id).hisfile      = '';
handles.Model(md).Input(id).hisinterval  = 600.0;
handles.Model(md).Input(id).xlsinterval  = 0;
handles.Model(md).Input(id).flowgeomfile = '';
handles.Model(md).Input(id).mapfile      = '';
handles.Model(md).Input(id).mapinterval  = 3600;
handles.Model(md).Input(id).rstinterval  = 0;
handles.Model(md).Input(id).waqfilebase  = '';
handles.Model(md).Input(id).waqinterval  = 0;
handles.Model(md).Input(id).snapshotdir  = '';

