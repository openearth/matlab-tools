function handles=ddb_initializeFlowDomain(handles,opt,id,runid)

handles.Model(md).Input(id).Runid=runid;

switch lower(opt)
    case{'griddependentinput'}
        handles=ddb_initializeGridDependentInput(handles,id);
    case{'all'}
        handles=ddb_initializeGridDependentInput(handles,id);
        handles=ddb_initializeOtherInput(handles,id,runid);
end        

%%
function handles=ddb_initializeGridDependentInput(handles,id)

handles.Model(md).Input(id).NrObservationPoints=0;
handles.Model(md).Input(id).NrOpenBoundaries=0;
handles.Model(md).Input(id).NrDryPoints=0;
handles.Model(md).Input(id).NrThinDams=0;
handles.Model(md).Input(id).NrCrossSections=0;
handles.Model(md).Input(id).NrDischarges=0;
handles.Model(md).Input(id).NrObservationPoints=0;
handles.Model(md).Input(id).NrDrogues=0;

handles.Model(md).Input(id).NrAstro=0;
handles.Model(md).Input(id).NrHarmo=0;
handles.Model(md).Input(id).NrTime=0;
handles.Model(md).Input(id).NrCor=0;

handles.Model(md).Input(id).GrdFile='';
handles.Model(md).Input(id).EncFile='';
handles.Model(md).Input(id).DepFile='';
handles.Model(md).Input(id).DryFile='';
handles.Model(md).Input(id).ThdFile='';
handles.Model(md).Input(id).CrsFile='';
handles.Model(md).Input(id).DroFile='';
handles.Model(md).Input(id).IniFile='';
handles.Model(md).Input(id).RstId='';
handles.Model(md).Input(id).TrimId='';
handles.Model(md).Input(id).BndFile='';
handles.Model(md).Input(id).BchFile='';
handles.Model(md).Input(id).BctFile='';
handles.Model(md).Input(id).BcqFile='';
handles.Model(md).Input(id).BccFile='';
handles.Model(md).Input(id).BcaFile='';
handles.Model(md).Input(id).CorFile='';
handles.Model(md).Input(id).ObsFile='';
handles.Model(md).Input(id).CrsFile='';
handles.Model(md).Input(id).RghFile='';
handles.Model(md).Input(id).EdyFile='';
handles.Model(md).Input(id).SrcFile='';
handles.Model(md).Input(id).DisFile='';

handles.Model(md).Input(id).MMax=0;
handles.Model(md).Input(id).NMax=0;
handles.Model(md).Input(id).KMax=1;
handles.Model(md).Input(id).Depth=[];
handles.Model(md).Input(id).GridX=[];
handles.Model(md).Input(id).GridY=[];

%%
function handles=ddb_initializeOtherInput(handles,id,runid)

handles.Model(md).Input(id).Runid=runid;
handles.Model(md).Input(id).MdfFile=[runid '.mdf'];
handles.Model(md).Input(id).AttName=handles.Model(md).Input(id).Runid;

handles.Model(md).Input(id).NrAstronomicComponentSets=0;

handles.Model(md).Input(id).NrHarmonicComponents=2;
handles.Model(md).Input(id).HarmonicComponents=[0.0 30.0];

handles.Model(md).Input(id).Description='';

handles.Model(md).Input(id).UniformDepth=10;

handles.Model(md).Input(id).FouFile='';
handles.Model(md).Input(id).SedFile='';
handles.Model(md).Input(id).MorFile='';
handles.Model(md).Input(id).WndFile='';
handles.Model(md).Input(id).SpwFile='';
handles.Model(md).Input(id).NrSediments=0;
handles.Model(md).Input(id).NrTracers=0;
handles.Model(md).Input(id).NrConstituents=0;

handles.Model(md).Input(id).Latitude=0.0;
handles.Model(md).Input(id).Orientation=0.0;
handles.Model(md).Input(id).Thick=100;
handles.Model(md).Input(id).InitialConditions='unif';
handles.Model(md).Input(id).UniformRoughness=1;
handles.Model(md).Input(id).UniformViscosity=1;

handles.Model(md).Input(id).Zeta0=0.0;
handles.Model(md).Input(id).U0=0.0;
handles.Model(md).Input(id).V0=0.0;

handles.Model(md).Input(id).ItDate=floor(now);
handles.Model(md).Input(id).StartTime=floor(now);
handles.Model(md).Input(id).StopTime=floor(now)+2;
handles.Model(md).Input(id).TimeStep=1.0;
handles.Model(md).Input(id).MapStartTime=handles.Model(md).Input(id).StartTime;
handles.Model(md).Input(id).MapStopTime=handles.Model(md).Input(id).StopTime;
handles.Model(md).Input(id).MapInterval=60;
handles.Model(md).Input(id).ComStartTime=handles.Model(md).Input(id).StartTime;
handles.Model(md).Input(id).ComStopTime=handles.Model(md).Input(id).StartTime;
handles.Model(md).Input(id).ComInterval=0;
handles.Model(md).Input(id).HisInterval=10*handles.Model(md).Input(id).TimeStep;
handles.Model(md).Input(id).RstInterval=0;
handles.Model(md).Input(id).OnlineVisualisation=0;
handles.Model(md).Input(id).OnlineCoupling=0;
handles.Model(md).Input(id).FourierAnalysis=0;

handles.Model(md).Input(id).Salinity.Include=0;
handles.Model(md).Input(id).Temperature.Include=0;
handles.Model(md).Input(id).Tracers=0;
handles.Model(md).Input(id).Sediments=0;
handles.Model(md).Input(id).Wind=0;
handles.Model(md).Input(id).Waves=0;
handles.Model(md).Input(id).OnlineWave=0;
handles.Model(md).Input(id).Waqmod=0;
handles.Model(md).Input(id).Roller.Include=0;
handles.Model(md).Input(id).SecondaryFlow=0;
handles.Model(md).Input(id).TidalForces=0;
handles.Model(md).Input(id).Dredging=0;

handles.Model(md).Input(id).Latitude=0.0;
handles.Model(md).Input(id).Orientation=0.0;
handles.Model(md).Input(id).G=9.81;
handles.Model(md).Input(id).RhoW=1000.0;
%Alph0 = [.]
handles.Model(md).Input(id).TempW=15;
handles.Model(md).Input(id).SalW=31;
handles.Model(md).Input(id).RouWav='FR84';
handles.Model(md).Input(id).WindStress=[6.3000000e-004  0.0000000e+000  7.2300000e-003  3.0000000e+001];
handles.Model(md).Input(id).WindType='Uniform';
handles.Model(md).Input(id).WndInt='Y';
handles.Model(md).Input(id).RhoAir=1.0;
handles.Model(md).Input(id).BetaC=0.5;
handles.Model(md).Input(id).Equili=0;
handles.Model(md).Input(id).VerticalTurbulenceModel='K-epsilon   ';
handles.Model(md).Input(id).KTemp=0;
handles.Model(md).Input(id).FClou=0;
handles.Model(md).Input(id).SArea=0;
handles.Model(md).Input(id).Temint=0;
handles.Model(md).Input(id).RoughnessType='C';
handles.Model(md).Input(id).URoughness=65;
handles.Model(md).Input(id).VRoughness=65;
handles.Model(md).Input(id).Xlo=0;
handles.Model(md).Input(id).VicoUV=1;
handles.Model(md).Input(id).DicoUV=1;
handles.Model(md).Input(id).HLES=0;
handles.Model(md).Input(id).VicoWW=1.0e-6;
handles.Model(md).Input(id).DicoWW=1.0e-6;
handles.Model(md).Input(id).Irov=0;
handles.Model(md).Input(id).Z0v=0.0;
handles.Model(md).Input(id).SedFile='';
handles.Model(md).Input(id).MorFile='';
handles.Model(md).Input(id).Iter=2;
handles.Model(md).Input(id).DryFlp=1;
handles.Model(md).Input(id).DpsOpt='MAX';
handles.Model(md).Input(id).DpuOpt='MEAN';
handles.Model(md).Input(id).DryFlc=0.1;
handles.Model(md).Input(id).Dco=-999.0;
handles.Model(md).Input(id).Dgcuni=1000.0;
handles.Model(md).Input(id).SmoothingTime=60.0;
handles.Model(md).Input(id).ThetQH=0;
handles.Model(md).Input(id).ForresterHor=0;
handles.Model(md).Input(id).ForresterVer=0;
handles.Model(md).Input(id).SigmaCorrection=0;
handles.Model(md).Input(id).TraSol='Cyclic-method';
handles.Model(md).Input(id).MomSol='Cyclic';
handles.Model(md).Input(id).OnlineVisualisation=0;
handles.Model(md).Input(id).WaveOnline=0;

handles.Model(md).Input(id).Filwp='';
handles.Model(md).Input(id).Filwu='';
handles.Model(md).Input(id).Filwv='';
handles.Model(md).Input(id).Wndgrd='';
handles.Model(md).Input(id).MNmaxw=[];

% HLES stuff
handles.Model(md).Input(id).Htural=1.6666660e+000;
handles.Model(md).Input(id).Hturnd=2;
handles.Model(md).Input(id).Hturst=7.0000000e-001;
handles.Model(md).Input(id).Hturlp=3.3333330e-001;
handles.Model(md).Input(id).Hturrt=6.0000000e+001;
handles.Model(md).Input(id).Hturdm=0.0000000e+000;
handles.Model(md).Input(id).Hturel=1;

% Initial Condition Options
handles.Model(md).Input(id).WaterLevel.ICOpt=handles.TideModels.ActiveTideModelIC;
handles.Model(md).Input(id).WaterLevel.ICConst=0;
handles.Model(md).Input(id).WaterLevel.ICPar=0;
handles.Model(md).Input(id).Velocity.ICOpt='Constant';
handles.Model(md).Input(id).Velocity.ICPar=[0 0 ; 100 0];
handles.Model(md).Input(id).Velocity.ICConst=0;

% Wind
handles=ddb_initializeWind(handles,id);

% Constituents
handles=ddb_initializeSalinity(handles,id);
handles=ddb_initializeTemperature(handles,id);

handles.Model(md).Input(id).Tracer=[];
for i=1:handles.Model(md).Input(id).NrTracers
    handles=ddb_initializeTracer(handles,i);
end
handles.Model(md).Input(id).Sediment=[];
for i=1:handles.Model(md).Input(id).NrSediments
    handles=ddb_initializeSediment(handles,i);
end

handles.Model(md).Input(id).Snellius=0;
handles.Model(md).Input(id).CstBnd=0;

% Roller Model
handles.Model(md).Input(id).Snellius=0;
handles.Model(md).Input(id).Roller.GamDis=0.7;
handles.Model(md).Input(id).Roller.BetaRo=0.05;
handles.Model(md).Input(id).Roller.FLam=-2;
handles.Model(md).Input(id).Roller.Thr=0.01;

% Trachytopes
handles.Model(md).Input(id).Trachy.TraFrm='';
handles.Model(md).Input(id).Trachy.Trtrou=0;
handles.Model(md).Input(id).Trachy.Trtdef='';
handles.Model(md).Input(id).Trachy.Trtu='';
handles.Model(md).Input(id).Trachy.Trtv='';
handles.Model(md).Input(id).Trachy.TrtDt=0;

