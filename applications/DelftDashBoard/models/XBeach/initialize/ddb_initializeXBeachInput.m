function handles=ddb_initializeXBeachInput(handles,id,runid,varargin)

ii=strmatch('XBeach',{handles.Model.Name},'exact');

handles.Model(ii).Input(id).Description={''};
handles.Model(ii).Input(id).Runid=runid;
handles.Model(ii).Input(id).AttName=handles.Model(ii).Input(id).Runid;
handles.Model(ii).Input(id).ItDate=floor(now);
handles.Model(ii).Input(id).StartTime=floor(now);
handles.Model(ii).Input(id).StopTime=floor(now)+2;
handles.Model(ii).Input(id).TimeStep=1;
handles.Model(ii).Input(id).ParamsFile=[lower(cd) '\'];

%% initialize arrays for x,y and z
handles.Model(ii).Input(id).Depth=[];
handles.Model(ii).Input(id).GridX=[];
handles.Model(ii).Input(id).GridY=[];

%% general constants
handles.Model(ii).Input(id).rho=1000;
handles.Model(ii).Input(id).g=9.81;

%% grid input
handles.Model(ii).Input(id).nx=0;
handles.Model(ii).Input(id).ny=0;
handles.Model(ii).Input(id).xori=0;
handles.Model(ii).Input(id).yori=0;
handles.Model(ii).Input(id).alfa=0.0;
handles.Model(ii).Input(id).depfile='h.dep';
handles.Model(ii).Input(id).UniformDepth=10;
handles.Model(ii).Input(id).posdwn=-1;
handles.Model(ii).Input(id).vardx=1;
handles.Model(ii).Input(id).dx=0;
handles.Model(ii).Input(id).dy=0;
handles.Model(ii).Input(id).xfile='x.grd';
handles.Model(ii).Input(id).yfile='y.grd';
handles.Model(ii).Input(id).thetamin=-1;
handles.Model(ii).Input(id).thetamax=1;
handles.Model(ii).Input(id).dtheta=2;
handles.Model(ii).Input(id).thetanaut=0;

%% Time input
handles.Model(ii).Input(id).tstop=1000;

%% Numerics input
handles.Model(ii).Input(id).CFL=0.7;
handles.Model(ii).Input(id).scheme=1;
handles.Model(ii).Input(id).thetanum=1;

%% Limiters
handles.Model(ii).Input(id).gammax=5.0;
handles.Model(ii).Input(id).hmin=0.3;
handles.Model(ii).Input(id).eps=0.01;
handles.Model(ii).Input(id).umin=0.01;
handles.Model(ii).Input(id).hwci=0.01;

%% Boundary numerics
handles.Model(ii).Input(id).front=1;
handles.Model(ii).Input(id).back=1;
handles.Model(ii).Input(id).left=1;
handles.Model(ii).Input(id).right=1;

%% Advanced wave boundary options
handles.Model(ii).Input(id).fcutoff=0;
handles.Model(ii).Input(id).sprdthr=0.08;
handles.Model(ii).Input(id).carspan=0;
handles.Model(ii).Input(id).nspr=0;
handles.Model(ii).Input(id).epsi=0;

%% Boundary tide options
handles.Model(ii).Input(id).tideloc=0;
handles.Model(ii).Input(id).zs0=0.0;
handles.Model(ii).Input(id).zs0file='';
handles.Model(ii).Input(id).tidelen=100;
handles.Model(ii).Input(id).paulrevere=0;

%% Wave generating boundaries
handles.Model(ii).Input(id).taper=100;
handles.Model(ii).Input(id).instat=1;
handles.Model(ii).Input(id).tsfile='gen.ezs';
handles.Model(ii).Input(id).ARC=1;
handles.Model(ii).Input(id).order=2;
handles.Model(ii).Input(id).dir0=270;
handles.Model(ii).Input(id).Hrms=1;
handles.Model(ii).Input(id).Trep=10;
handles.Model(ii).Input(id).m=1000;
handles.Model(ii).Input(id).wavint=1;
handles.Model(ii).Input(id).Tlong=7*handles.Model(ii).Input(id).Trep;    
handles.Model(ii).Input(id).bcfile='';
handles.Model(ii).Input(id).rt=1800;
handles.Model(ii).Input(id).dtbc=0.2;
handles.Model(ii).Input(id).dthetaS_XB=0;

%% Wind options
handles.Model(ii).Input(id).rhoa=1.25;
handles.Model(ii).Input(id).Cd=0.002;
handles.Model(ii).Input(id).windv=0;
handles.Model(ii).Input(id).windth=90;

%% Coriolis options
handles.Model(ii).Input(id).lat=0;
handles.Model(ii).Input(id).wearth=1/24;

%% Wave claculation options
handles.Model(ii).Input(id).wci=0;
handles.Model(ii).Input(id).break=3;
handles.Model(ii).Input(id).roller=1;
handles.Model(ii).Input(id).beta=0.1;
handles.Model(ii).Input(id).rfb=0;
handles.Model(ii).Input(id).gamma=0.5;
handles.Model(ii).Input(id).alpha=1;
handles.Model(ii).Input(id).delta=0;
handles.Model(ii).Input(id).n=15;
handles.Model(ii).Input(id).swtable='';

%% Flow calculation options
handles.Model(ii).Input(id).C=65;
handles.Model(ii).Input(id).nuh=0.1;
handles.Model(ii).Input(id).nuhfac=1;
handles.Model(ii).Input(id).nuhv=1;

%% Groundwater options
handles.Model(ii).Input(id).gwflow=0;
handles.Model(ii).Input(id).kx=0.00015;
handles.Model(ii).Input(id).ky=0.00015;
handles.Model(ii).Input(id).kz=0.00050;
handles.Model(ii).Input(id).dwetlayer=0.2;
handles.Model(ii).Input(id).aquiferbot=-999;
handles.Model(ii).Input(id).aquiferbotfile = '';
handles.Model(ii).Input(id).gw0=0.5;
handles.Model(ii).Input(id).gw0file='';

%% Sediment transport calculation options
handles.Model(ii).Input(id).form=1;
handles.Model(ii).Input(id).smax=-1;
handles.Model(ii).Input(id).tsfac=0.1;
handles.Model(ii).Input(id).dico=1;
handles.Model(ii).Input(id).Tsmin=1;
handles.Model(ii).Input(id).facua=0.1;
handles.Model(ii).Input(id).z0=0.006;
handles.Model(ii).Input(id).facsl=1.6;
handles.Model(ii).Input(id).ndg=1;
handles.Model(ii).Input(id).ngd=1;
handles.Model(ii).Input(id).D50=200e-6;
handles.Model(ii).Input(id).D90=300e-6;
handles.Model(ii).Input(id).sedcal=1;
handles.Model(ii).Input(id).rhos=2650;
handles.Model(ii).Input(id).turb=1;

%% Morphological calculation options
handles.Model(ii).Input(id).morfac=1;
handles.Model(ii).Input(id).morstart=0;
handles.Model(ii).Input(id).por=0.4;
handles.Model(ii).Input(id).dryslp=1;
handles.Model(ii).Input(id).wetslp=0.3;
handles.Model(ii).Input(id).hswitch=0.1;
handles.Model(ii).Input(id).dzmax=0.005;

%% Output options
handles.Model(ii).Input(id).tstart=0;
handles.Model(ii).Input(id).tintg=[];
handles.Model(ii).Input(id).tintp=[];
handles.Model(ii).Input(id).tintm=[];
handles.Model(ii).Input(id).tsglobal=[];
handles.Model(ii).Input(id).tspoints=[];
handles.Model(ii).Input(id).tsmean=[];
handles.Model(ii).Input(id).nglobalvar=[];
handles.Model(ii).Input(id).npoints=[];
handles.Model(ii).Input(id).nrugauge=[];
handles.Model(ii).Input(id).nmeanvar=[];


