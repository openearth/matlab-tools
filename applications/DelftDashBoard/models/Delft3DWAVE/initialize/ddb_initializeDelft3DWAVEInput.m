function handles=ddb_initializeDelft3DWAVEInput(handles,id,runid,varargin)

ii=strmatch('Delft3DWAVE',{handles.Model.name},'exact');

handles.Model(ii).Input(id).ActiveDomain       = 1;
handles.Model(ii).Input(id).activeNest         = 1;
handles.Model(ii).Input(id).Runid              =  runid;
handles.Model(ii).Input(id).ItDate             =  floor(now);
handles.Model(ii).Input(id).StartTime          =  floor(now);
handles.Model(ii).Input(id).StopTime           =  floor(now)+2;
handles.Model(ii).Input(id).TimeStep           =  1.0;
handles.Model(ii).Input(id).attName            =  handles.Model(ii).Input(id).Runid;
handles.Model(ii).Input(id).MdwFile            =  [runid '.mdw'];
				             
handles.Model(ii).Input(id).ProjectName        = '';
handles.Model(ii).Input(id).ProjectNumber      = '';
handles.Model(ii).Input(id).Description        = {'','',''};
				             
handles.Model(ii).Input(id).FlowBedLevel       = 0;
handles.Model(ii).Input(id).FlowWaterLevel     = 0;
handles.Model(ii).Input(id).FlowVelocity       = 0;
handles.Model(ii).Input(id).FlowWind           = 0;
handles.Model(ii).Input(id).MDFFile            = '';
handles.Model(ii).Input(id).AvailableFlowTimes = '';
handles.Model(ii).Input(id).NrAvailableFlowTimes = 0;

handles.Model(ii).Input(id).newGrid = '';
handles.Model(ii).Input(id).NestGrids = {''};
handles.Model(ii).Input(id).ComputationalGrids={''};
handles.Model(ii).Input(id).NrComputationalGrids=0;

handles=ddb_initializeDelft3DWAVEDomain(handles,ii,id,1);

handles.Model(ii).Input(id).WaterlevelCor=0;
handles.Model(ii).Input(id).Timepoints={''};
handles.Model(ii).Input(id).NrTimepoints=0;
handles.Model(ii).Input(id).Time=floor(now);
handles.Model(ii).Input(id).WaterLevel=0;
handles.Model(ii).Input(id).Xvelocity=0;
handles.Model(ii).Input(id).Yvelocity=0;
handles.Model(ii).Input(id).TimeTemp='';
handles.Model(ii).Input(id).WaterLevelTemp='';
handles.Model(ii).Input(id).XvelocityTemp='';
handles.Model(ii).Input(id).YvelocityTemp='';
handles.Model(ii).Input(id).TimepointsIval='';
handles.Model(ii).Input(id).TimeDependentQuantitiesFile='';
handles.Model(ii).Input(id).NumberQuantities='';

%% Boundaries
handles.Model(ii).Input(id).nrBoundaries=0;
handles.Model(ii).Input(id).boundaryNames={''};
handles.Model(ii).Input(id).activeBoundary=1;

handles.Model(ii).Input(id).boundaries=[];
handles=ddb_initializeDelft3DWAVEBoundary(handles,ii,id,1);

handles.Model(ii).Input(id).boundaryDefinitions={'orientation','grid-coordinates','xy-coordinates','fromsp2file','fromwwfile'};
handles.Model(ii).Input(id).boundaryDefinitionsText={'Orientation','Grid coordinates','XY coordinates','SP2 file','WW3 file'};

handles.Model(ii).Input(id).boundaryOrientations={'north','northwest','west','southwest','south','southeast','east','northeast'};
handles.Model(ii).Input(id).boundaryOrientationsText={'North','Northwest','West','Southwest','South','Southeast','East','Northeast'};

handles.Model(ii).Input(id).boundaryDistanceDirs={'clockwise','counter-clockwise'};
handles.Model(ii).Input(id).boundaryDistanceDirsText={'Clockwise','Counter-clockwise'};

handles.Model(ii).Input(id).boundaryDistanceDirs={'fromfile','parametric'};
handles.Model(ii).Input(id).boundaryDistanceDirsText={'From file','Parametric'};

handles.Model(ii).Input(id).boundarySpShapeTypes={'jonswap','pierson-moskowitz','gauss'};
handles.Model(ii).Input(id).boundarySpShapeTypesText={'JONSWAP','Pierson-Moskowitz','Gauss'};

handles.Model(ii).Input(id).boundaryPeriodTypes={'peak','mean'};

handles.Model(ii).Input(id).boundaryDirSpreadTypes={'power','degrees'};

% handles.Model(ii).Input(id).Hs='';
% handles.Model(ii).Input(id).Tp='';
% handles.Model(ii).Input(id).Dir='';
% handles.Model(ii).Input(id).Spread='';
% handles.Model(ii).Input(id).DistTemp=0;
% handles.Model(ii).Input(id).HsTemp=0;
% handles.Model(ii).Input(id).TpTemp=0;
% handles.Model(ii).Input(id).DirTemp=0;
% handles.Model(ii).Input(id).SpreadTemp=0;
% handles.Model(ii).Input(id).ClockTemp=1;
% handles.Model(ii).Input(id).CounterClockTemp=0;
% handles.Model(ii).Input(id).BndFileTemp='';
% handles.Model(ii).Input(id).Sections='';
% handles.Model(ii).Input(id).SectionsIval='';
% handles.Model(ii).Input(id).SecOrient='';
% handles.Model(ii).Input(id).SecDist='';
% handles.Model(ii).Input(id).SecHs='';
% handles.Model(ii).Input(id).SecTp='';
% handles.Model(ii).Input(id).SecDir='';
% handles.Model(ii).Input(id).SecSpread='';
% handles.Model(ii).Input(id).BndFile='';
% handles.Model(ii).Input(id).SpacevaryingParam(1).Sections='';
% handles.Model(ii).Input(id).SpacevaryingParam(1).Dist='';
% handles.Model(ii).Input(id).SpacevaryingParam(1).Hs='';
% handles.Model(ii).Input(id).SpacevaryingParam(1).Tp='';
% handles.Model(ii).Input(id).SpacevaryingParam(1).Dir='';
% handles.Model(ii).Input(id).SpacevaryingParam(1).Spread='';
% handles.Model(ii).Input(id).SpacevaryingParam(1).Clock='';
% handles.Model(ii).Input(id).SpacevaryingParam(1).CounterClock='';
% handles.Model(ii).Input(id).SpacevaryingParam(1).BndFile='';
% 
% handles.Model(ii).Input(id).Jonswap ='';
% handles.Model(ii).Input(id).Jonswapval='';
% handles.Model(ii).Input(id).Pierson ='';
% handles.Model(ii).Input(id).Gauss   ='';
% handles.Model(ii).Input(id).Gaussval='';
% handles.Model(ii).Input(id).Peak    ='';
% handles.Model(ii).Input(id).Mean    ='';
% handles.Model(ii).Input(id).Cosine  ='';
% handles.Model(ii).Input(id).Degrees ='';
% handles.Model(ii).Input(id).JonswapTemp=1;
% handles.Model(ii).Input(id).JonswapvalTemp=3.3;
% handles.Model(ii).Input(id).PiersonTemp=0;
% handles.Model(ii).Input(id).GaussTemp  =0;
% handles.Model(ii).Input(id).GaussvalTemp=0.01;
% handles.Model(ii).Input(id).PeakTemp   =1;
% handles.Model(ii).Input(id).MeanTemp   =0;
% handles.Model(ii).Input(id).CosineTemp =1;
% handles.Model(ii).Input(id).DegreesTemp=0;
% 
handles.Model(ii).Input(id).Obstacles={''};%'';
handles.Model(ii).Input(id).NrObstacles=0;%1
handles.Model(ii).Input(id).ObstaclesIval=1;%'';
handles.Model(ii).Input(id).ObstacleType='dam';
handles.Model(ii).Input(id).Sheet=1;
handles.Model(ii).Input(id).Dam=0;
handles.Model(ii).Input(id).Reflections={'No';'Specular';'Diffuse'};
handles.Model(ii).Input(id).Reflectionsval='No';%1;
handles.Model(ii).Input(id).Refcoef=0;
handles.Model(ii).Input(id).Transmcoef=1;
handles.Model(ii).Input(id).Height=0;
handles.Model(ii).Input(id).Alpha=2.6;
handles.Model(ii).Input(id).Beta=0.15;
handles.Model(ii).Input(id).ObstaclesNb(1).Segments={};%'';
handles.Model(ii).Input(id).ObstaclesNb(1).SegmentsIval=1;%'';%
handles.Model(ii).Input(id).ObstaclesNb(1).Xstart=0;
handles.Model(ii).Input(id).ObstaclesNb(1).Ystart=0;
handles.Model(ii).Input(id).ObstaclesNb(1).Xend=0;
handles.Model(ii).Input(id).ObstaclesNb(1).Yend=0;
handles.Model(ii).Input(id).PolFile='';

handles.Model(ii).Input(id).Gravity        = 9.81;
handles.Model(ii).Input(id).Waterdensity   = 1000;
handles.Model(ii).Input(id).Northwaxis     = 90;
handles.Model(ii).Input(id).Mindepth       = 0.05;
handles.Model(ii).Input(id).Convention     = 'Nautical';
handles.Model(ii).Input(id).Nautical       = 0;
handles.Model(ii).Input(id).Cartesian      = 0;
handles.Model(ii).Input(id).WaveSetup      = 'None';
handles.Model(ii).Input(id).None           = 0;
handles.Model(ii).Input(id).Activated      = 0;
handles.Model(ii).Input(id).Forces         = 'Waveenergy';
handles.Model(ii).Input(id).Waveenergy     = 0;
handles.Model(ii).Input(id).Radiation      = 0;
handles.Model(ii).Input(id).Wind           = 'Uniform';
handles.Model(ii).Input(id).UniformW       = 1;
handles.Model(ii).Input(id).SpacevaryingW  = 0;
handles.Model(ii).Input(id).WindGrid       = 'Asbathy';
handles.Model(ii).Input(id).Asbathy        = 0;
handles.Model(ii).Input(id).Tospecify      = 0;
handles.Model(ii).Input(id).SpeedW         = 0;
handles.Model(ii).Input(id).DirectionW     = 0;
handles.Model(ii).Input(id).WindFile       = '';
handles.Model(ii).Input(id).XoriginW       = 0;
handles.Model(ii).Input(id).YoriginW       = 0;
handles.Model(ii).Input(id).AngleW         = 0;
handles.Model(ii).Input(id).XcellsW        = 0;
handles.Model(ii).Input(id).YcellsW        = 0;
handles.Model(ii).Input(id).XsizeW         = 0;
handles.Model(ii).Input(id).YsizeW         = 0;
handles.Model(ii).Input(id).Generation     = {'None';'1st generation';'2nd generation';'3rd generation'};
handles.Model(ii).Input(id).GenerationIval = 'None';%4;
handles.Model(ii).Input(id).GenerationIval = '3rd generation';%4;

handles.Model(ii).Input(id).Breaking    = 1;
handles.Model(ii).Input(id).Triad       = 0;
handles.Model(ii).Input(id).Friction    = 1;
handles.Model(ii).Input(id).Diffraction = 0;
handles.Model(ii).Input(id).Alpha1      = 1;
handles.Model(ii).Input(id).Gamma       = 0.8;
handles.Model(ii).Input(id).Alpha2      = 0.1;
handles.Model(ii).Input(id).Beta        = 2.2;
handles.Model(ii).Input(id).Type        = {'JONSWAP';'Collins';'Madsen et al.'};
handles.Model(ii).Input(id).Typeval     = 'JONSWAP';%1;
handles.Model(ii).Input(id).Coefficient = 0.067;
handles.Model(ii).Input(id).Smoothcoef  = 0.2;
handles.Model(ii).Input(id).Smoothsteps = 5;
handles.Model(ii).Input(id).Propagation = 1;

handles.Model(ii).Input(id).WindGrowth = 'De-activated';
handles.Model(ii).Input(id).Acti1   = 0;
handles.Model(ii).Input(id).DeActi1 = 1;
handles.Model(ii).Input(id).Whitecapping = 'Activated';
handles.Model(ii).Input(id).Acti2   = 1;
handles.Model(ii).Input(id).DeActi2 = 0;
handles.Model(ii).Input(id).Quadruplets = 'De-activated';
handles.Model(ii).Input(id).Acti3   = 0;
handles.Model(ii).Input(id).DeActi3 = 1;
handles.Model(ii).Input(id).Refraction = 'Activated';
handles.Model(ii).Input(id).Acti4   = 1;
handles.Model(ii).Input(id).DeActi4 = 0;
handles.Model(ii).Input(id).Freqshift = 'Activated';
handles.Model(ii).Input(id).Acti5   = 1;
handles.Model(ii).Input(id).DeActi5 = 0;

handles.Model(ii).Input(id).Order = 'First';
handles.Model(ii).Input(id).First = 1;
handles.Model(ii).Input(id).Third = 0;
handles.Model(ii).Input(id).CDD   = 0.5;
handles.Model(ii).Input(id).CSS   = 0.5;

handles.Model(ii).Input(id).HSTM01   = 0.02;
handles.Model(ii).Input(id).HSchange = 0.02;
handles.Model(ii).Input(id).TM01     = 0.02;
handles.Model(ii).Input(id).PercWet  = 98;
handles.Model(ii).Input(id).MaxIter  = 15;

handles.Model(ii).Input(id).TestOutput=0;
handles.Model(ii).Input(id).Debug=0;
handles.Model(ii).Input(id).TimeStepOutput=10;
handles.Model(ii).Input(id).Interval=10;
handles.Model(ii).Input(id).modes={'stationary','non-stationary'};
handles.Model(ii).Input(id).mode='stationary';
handles.Model(ii).Input(id).Hotstart=0;
handles.Model(ii).Input(id).Verify=0;
handles.Model(ii).Input(id).OutputFlowGrid=0;
handles.Model(ii).Input(id).OutputFlowGridFile='';
handles.Model(ii).Input(id).OutputComputationalGrids=[];
handles.Model(ii).Input(id).Compgrid1=1;
handles.Model(ii).Input(id).Compgrid2=0;
handles.Model(ii).Input(id).Compgrid3=0;
handles.Model(ii).Input(id).OutputSpecific=0;
handles.Model(ii).Input(id).Table=0;
handles.Model(ii).Input(id).oneDspectra=0;
handles.Model(ii).Input(id).twoDspectra=0;
handles.Model(ii).Input(id).LocFromFile=1;
handles.Model(ii).Input(id).LocFileName='';
handles.Model(ii).Input(id).LocSpecified=0;
handles.Model(ii).Input(id).Locations='';
handles.Model(ii).Input(id).LocationsIval='';
handles.Model(ii).Input(id).LocXTemp=0;
handles.Model(ii).Input(id).LocYTemp=0;
handles.Model(ii).Input(id).LocX=0;
handles.Model(ii).Input(id).LocY=0;






