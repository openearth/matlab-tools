function handles=ddb_readMDW(handles,filename)

MDW = ddb_readDelft3D_keyWordFile(filename);

handles.Model(md).Input.ActiveDomain=1;

handles.Model(md).Input.ItDate=floor(now);

%% General
fldnames=fieldnames(MDW.general);
for ii=1:length(fldnames)
    handles.Model(md).Input.(fldnames{ii})=MDW.general.(fldnames{ii});
end

%% Constants
fldnames=fieldnames(MDW.constants);
for ii=1:length(fldnames)
    handles.Model(md).Input.(fldnames{ii})=MDW.constants.(fldnames{ii});
end

%% Processes
fldnames=fieldnames(MDW.processes);
for ii=1:length(fldnames)
    handles.Model(md).Input.(fldnames{ii})=MDW.processes.(fldnames{ii});
end

%% Numerics
fldnames=fieldnames(MDW.numerics);
for ii=1:length(fldnames)
    handles.Model(md).Input.(fldnames{ii})=MDW.numerics.(fldnames{ii});
end

%% Output
fldnames=fieldnames(MDW.output);
for ii=1:length(fldnames)
    handles.Model(md).Input.(fldnames{ii})=MDW.output.(fldnames{ii});
end

%% Domains
ndomains=length(MDW.domain);
handles.Model(md).Input.ComputationalGrids={''};
handles.Model(md).Input.NrComputationalGrids=ndomains;
handles.Model(md).Input.nrdomains=ndomains;
for id=1:ndomains
    handles=ddb_initializeDelft3DWAVEDomain(handles,md,1,id);
    fldnames=fieldnames(MDW.domain(id));
    for ii=1:length(fldnames)
        handles.Model(md).Input.domains(id).(fldnames{ii})=MDW.domain(id).(fldnames{ii});
    end
end

%% Boundaries
nbnd=length(MDW.boundary);
handles.Model(md).Input.nrBoundaries=nbnd;
for ib=1:nbnd
    handles=ddb_initializeDelft3DWAVEBoundary(handles,md,1,ib);
    fldnames=fieldnames(MDW.boundary(ib));
    for ii=1:length(fldnames)
        handles.Model(md).Input.boundaries(ib).(fldnames{ii})=MDW.boundary(ib).(fldnames{ii});
    end
    handles.Model(md).Input.boundaryNames{ib}=handles.Model(md).Input.boundaries(ib).name;
end

% if isfield(MDW.general,'projectname')
%     handles.Model(md).Input.ProjectName=MDW.general.projectname;
% end
% if isfield(MDW.general,'projectnr')
%     handles.Model(md).Input.ProjectNumber=MDW.general.projectnr;
% end
% if isfield(MDW.general,'description1')
%     descr1=MDW.general.description1;
% end
% if isfield(MDW.general,'description2')
%     descr2=MDW.general.description2;
% end
% if isfield(MDW.general,'description3')
%     descr3=MDW.general.description3;
% end
% handles.Model(md).Input.Description={descr1,descr2,descr3};
% 
% if isfield(MDW.general,'onlyinputverify')
%     handles.Model(md).Input.OnlyInputVerify=MDW.general.onlyinputverify;
% end
% if isfield(MDW.general,'simmode')
%     handles.Model(md).Input.mode=MDW.general.simmode;
% end
% if isfield(MDW.general,'timestep')
%     handles.Model(md).Input.TimeStep=MDW.general.timestep;
% end
% if isfield(MDW.general,'dirconvention')
%     handles.Model(md).Input.DirConvention=MDW.general.dirconvention;
% end
% if isfield(MDW.general,'referencedate')
%     handles.Model(md).Input.ItDate=datenum(MDW.general.referencedate,'yyyy-mm-dd');
% end
% if isfield(MDW.general,'obstaclefile')
%     handles.Model(md).Input.ObstacleFile=MDW.general.obstaclefile;
% end
% if isfield(MDW.general,'tseriesfile')
%     handles.Model(md).Input.TSeriesFile=MDW.general.tseriesfile;
% end
% if isfield(MDW.general,'timepntblock')
%     handles.Model(md).Input.TimePntBlock=MDW.general.timepntblock;
% end
% if isfield(MDW.general,'timepoint')
%     handles.Model(md).Input.TimePoint=MDW.general.timepoint;
% end
% if isfield(MDW.general,'waterlevel')
%     handles.Model(md).Input.WaterLevel=MDW.general.waterlevel;
% end
% if isfield(MDW.general,'xveloc')
%     handles.Model(md).Input.XVeloc=MDW.general.xveloc;
% end
% if isfield(MDW.general,'yveloc')
%     handles.Model(md).Input.YVeloc=MDW.general.yveloc;
% end
% if isfield(MDW.general,'windspeed')
%     handles.Model(md).Input.WindSpeed=MDW.general.windspeed;
% end
% if isfield(MDW.general,'winddir')
%     handles.Model(md).Input.WindDir=MDW.general.winddir;
% end
% if isfield(MDW.general,'dirspace')
%     handles.Model(md).Input.DirSpace=MDW.general.dirspace;
% end
% if isfield(MDW.general,'ndir')
%     handles.Model(md).Input.NDir=MDW.general.ndir;
% end
% if isfield(MDW.general,'startdir')
%     handles.Model(md).Input.StartDir=MDW.general.startdir;
% end
% if isfield(MDW.general,'enddir')
%     handles.Model(md).Input.EndDir=MDW.general.enddir;
% end
% if isfield(MDW.general,'nfreq')
%     handles.Model(md).Input.NFreq=MDW.general.nfreq;
% end
% if isfield(MDW.general,'freqmin')
%     handles.Model(md).Input.FreqMin=MDW.general.freqmin;
% end
% if isfield(MDW.general,'freqmax')
%     handles.Model(md).Input.FreqMax=MDW.general.freqmax;
% end
% if isfield(MDW.general,'hotfileid')
%     handles.Model(md).Input.HotFileID=MDW.general.hotfileid;
% end
% if isfield(MDW.general,'meteofile')
%     handles.Model(md).Input.MeteoFile=MDW.general.meteofile;
% end
% 
% %% Constants
% if isfield(MDW.general,'gravity')
%     handles.Model(md).Input.gravity=MDW.constants.gravity;
% end
% if isfield(MDW.general,'waterdensity')
%     handles.Model(md).Input.Waterdensity=MDW.constants.waterdensity;
% end
% if isfield(MDW.general,'northdir')
%     handles.Model(md).Input.Northwaxis=MDW.constants.northdir;
% end
% if isfield(MDW.general,'minimumdepth')
%     handles.Model(md).Input.Mindepth=MDW.constants.minimumdepth;
% end
% 
% %% Processes
% if isfield(MDW.general,'genmodephys')
%     handles.Model(md).Input.GenModePhys=MDW.constants.genmodephys;
% end
% if isfield(MDW.general,'wavesetup')
%     handles.Model(md).Input.WaveSetup=MDW.constants.wavesetup;
% end
% if isfield(MDW.general,'breaking')
%     handles.Model(md).Input.Breaking=MDW.constants.breaking;
% end
% if isfield(MDW.general,'breakalpha')
%     handles.Model(md).Input.BreakAlpha=MDW.constants.breakalpha;
% end
% if isfield(MDW.general,'breakgamma')
%     handles.Model(md).Input.BreakGamma=MDW.constants.breakgamma;
% end
% 






% %% Domains
% handles.Model(md).Input.FlowBedLevel=MDW.Domain(1).flowbedlevel;
% handles.Model(md).Input.FlowWaterLevel=MDW.Domain(1).FlowWaterLevel;
% handles.Model(md).Input.FlowVelocity=MDW.Domain(1).FlowVelocity;
% handles.Model(md).Input.FlowWind=MDW.Domain(1).FlowWind;
% 
% 
% itot = size(MDW.Domain.Grid,2)
% 
% 
% 
% handles.Model(md).Input.ComputationalGrids=MDW.Domain(1:itot).Grid;
% for id = 1:itot
%     handles.Model(md).Input.Domain(id).PathnameComputationalGrids=MDW.Domain(id).Grid;
%     handles.Model(md).Input.Domain(id).Coordsyst=MDW.general.DirConvention;
%     handles.Model(md).Input.Domain(id).GrdFile=MDW.Domain(id).Grid;
%     handles.Model(md).Input.Domain(id).EncFile='';
%     handles.Model(md).Input.Domain(id).DepFile=MDW.Domain(id).BedLevel;
%     handles.Model(md).Input.Domain(id).NstFile='';
%     handles.Model(md).Input.Domain(id).MMax='';
%     handles.Model(md).Input.Domain(id).NMax='';
%     
%     handles.Model(md).Input.Domain(id).CompGrid=MDW.Domain(id).BedLevelGrid;
%     handles.Model(md).Input.Domain(id).OtherGrid='';
%     handles.Model(md).Input.Domain(id).CompDep='';
%     handles.Model(md).Input.Domain(id).Xorig='';
%     handles.Model(md).Input.Domain(id).Yorig='';
%     handles.Model(md).Input.Domain(id).Xgridsize='';
%     handles.Model(md).Input.Domain(id).Ygridsize='';
%     
%     if strcmp(MDW.general.DirSpace,'circle')==1
%         handles.Model(md).Input.Domain(id).Circle=1;
%         handles.Model(md).Input.Domain(id).Sector=0;
%     elseif strcmp(MDW.general.DirSpace,'sector')==1
%         handles.Model(md).Input.Domain(id).Circle=0;
%         handles.Model(md).Input.Domain(id).Sector=1;
%     end
%     handles.Model(md).Input.Domain(id).StartDir=MDW.general.StartDir;
%     handles.Model(md).Input.Domain(id).EndDir=MDW.general.EndDir;
%     handles.Model(md).Input.Domain(id).NumberDir=MDW.general.NDir;
%     handles.Model(md).Input.Domain(id).LowFreq=MDW.general.FreqMin;
%     handles.Model(md).Input.Domain(id).HighFreq=MDW.general.FreqMax;
%     handles.Model(md).Input.Domain(id).NumberFreq=MDW.general.NFreq;
%     handles.Model(md).Input.Domain(id).GridNested='';
%     handles.Model(md).Input.Domain(id).NestedValue='';
% end
% 
% handles.Model(md).Input.WaterlevelCor=0;
% handles.Model(md).Input.Timepoints=MDW.general.TimePoint;
% handles.Model(md).Input.Time=MDW.general.TimePoint;
% handles.Model(md).Input.WaterLevel=MDW.general.WaterLevel;
% handles.Model(md).Input.Xvelocity=MDW.general.XVeloc;
% handles.Model(md).Input.Yvelocity=MDW.general.YVeloc;
% handles.Model(md).Input.TimeTemp='';
% handles.Model(md).Input.WaterLevelTemp='';
% handles.Model(md).Input.XvelocityTemp='';
% handles.Model(md).Input.YvelocityTemp='';
% handles.Model(md).Input.TimepointsIval='';
% handles.Model(md).Input.TimeDependentQuantitiesFile='';
% handles.Model(md).Input.NumberQuantities='';
% 
% itot = size(MDW.Boundary.Name,2);
% 
% handles.Model(md).Input.BndDefby={'Orientation';'Grid coordinates';'XY coordinates'};
% handles.Model(md).Input.BndOrient={'North';'Northwest';'West';'Southwest';'South';'Southeast';'East';'Northeast'};
% handles.Model(md).Input.Boundaries=MDW.Boundary(1:itot).Name;
% for i=1:itot
%     handles.Model(md).Input.BndName{i}=MDW.Boundary(i).Name;
%     if strcmp(MDW.Boundary(i).Definition,'orientation')==1
%         handles.Model(md).Input.BndDefbyval{i}=1;
%         if strcmp(MDW.Boundary(i).Orientation,'North')==1
%             handles.Model(md).Input.BndOrientval{i}=1;
%         elseif strcmp(MDW.Boundary(i).Orientation,'Northwest')==1
%             handles.Model(md).Input.BndOrientval{i}=2;
%         elseif strcmp(MDW.Boundary(i).Orientation,'West')==1
%             handles.Model(md).Input.BndOrientval{i}=3;
%         elseif strcmp(MDW.Boundary(i).Orientation,'Southwest')==1
%             handles.Model(md).Input.BndOrientval{i}=4;
%         elseif strcmp(MDW.Boundary(i).Orientation,'South')==1
%             handles.Model(md).Input.BndOrientval{i}=5;
%         elseif strcmp(MDW.Boundary(i).Orientation,'Southeast')==1
%             handles.Model(md).Input.BndOrientval{i}=6;
%         elseif strcmp(MDW.Boundary(i).Orientation,'East')==1
%             handles.Model(md).Input.BndOrientval{i}=7;
%         elseif strcmp(MDW.Boundary(i).Orientation,'Northeast')==1
%             handles.Model(md).Input.BndOrientval{i}=8;
%         end            
%     elseif strcmp(MDW.Boundary(i).Definition,'grid-coordinates')==1
%         handles.Model(md).Input.BndDefbyval{i}=2;
%         handles.Model(md).Input.BndStart1{i}=MDW.Boundary(i).StartCoordM;
%         handles.Model(md).Input.BndEnd1{i}=MDW.Boundary(i).EndCoordM;
%         handles.Model(md).Input.BndStart2{i}=MDW.Boundary(i).StartCoordN;
%         handles.Model(md).Input.BndEnd2{i}=MDW.Boundary(i).EndCoordN;
%     elseif strcmp(MDW.Boundary(i).Definition,'xy-coordinates')==1
%         handles.Model(md).Input.BndDefbyval{i}=3
%         handles.Model(md).Input.BndStart1{i}=MDW.Boundary(i).StartCoordX;
%         handles.Model(md).Input.BndEnd1{i}=MDW.Boundary(i).EndCoordX;
%         handles.Model(md).Input.BndStart2{i}=MDW.Boundary(i).StartCoordY;
%         handles.Model(md).Input.BndEnd2{i}=MDW.Boundary(i).EndCoordY;        
%     end
%     if strcmp(MDW.Boundary(i).SpectrumSpec,'parametric')==1
%         handles.Model(md).Input.Parametric{i}=1;
%         handles.Model(md).Input.FromFile{i}=0;
%         if strcmp(MDW.Boundary(i).SpShapeType,'jonswap')==1
%             handles.Model(md).Input.Jonswap{i}=1;
%             handles.Model(md).Input.Jonswapval{i}=MDW.Boundary(i).PeakEnhancFac;
%         elseif strcmp(MDW.Boundary(i).SpShapeType,'pierson-moskowitz')==1
%             handles.Model(md).Input.Pierson{i}=1;
%         elseif strcmp(MDW.Boundary(i).SpShapeType,'gauss')==1
%             handles.Model(md).Input.Gauss{i}=1;           
%             handles.Model(md).Input.Gaussval{i}=MDW.Boundary(i).GaussSpread;
%         end
%         if strcmp(MDW.Boundary(i).PeriodType,'peak')==1
%             handles.Model(md).Input.Peak{i}=1;
%             handles.Model(md).Input.Mean{i}=0;
%         elseif strcmp(MDW.Boundary(i).PeriodType,'mean')==1
%             handles.Model(md).Input.Peak{i}=0;
%             handles.Model(md).Input.Mean{i}=1;
%         end
%         if strcmp(MDW.Boundary(i).DirSpreadType,'power')==1
%             handles.Model(md).Input.Cosine{i}=1;
%             handles.Model(md).Input.Degrees{i}=0;
%         elseif strcmp(MDW.Boundary(i).DirSpreadType,'degrees')==1
%             handles.Model(md).Input.Cosine{i}=0;
%             handles.Model(md).Input.Degrees{i}=1;
%         end
%         if size(MDW.Boundary(i).List,2)>0
%             handles.Model(md).Input.Uniform{i}=0;
%             handles.Model(md).Input.Spacevarying{i}=1;
%             ktot = size(MDW.Boundary(i).List,2);
%             for k=1:ktot
%                 handles.Model(md).Input.Sections(k)=['Section ' num2str(k)];
%                 handles.Model(md).Input.SpacevaryingParam(i).Dist{k}=MDW.Boundary(i).List(k).CondSpecAtDist;
%                 handles.Model(md).Input.SpacevaryingParam(i).Hs{k}=MDW.Boundary(i).List(k).WaveHeight;
%                 handles.Model(md).Input.SpacevaryingParam(i).Tp{k}=MDW.Boundary(i).List(k).Period;
%                 handles.Model(md).Input.SpacevaryingParam(i).Dir{k}=MDW.Boundary(i).List(k).Direction;
%                 handles.Model(md).Input.SpacevaryingParam(i).Spread{k}=MDW.Boundary(i).List(k).DirSpreading;
%             end
%         else
%             handles.Model(md).Input.Uniform{i}=1;
%             handles.Model(md).Input.Spacevarying{i}=0;            
%             handles.Model(md).Input.Hs{i}=MDW.Boundary(i).WaveHeight;
%             handles.Model(md).Input.Tp{i}=MDW.Boundary(i).Period;
%             handles.Model(md).Input.Dir{i}=MDW.Boundary(i).Direction;
%             handles.Model(md).Input.Spread{i}=MDW.Boundary(i).DirSpreading;
%         end
%     else
%         handles.Model(md).Input.Parametric{i}=0;
%         handles.Model(md).Input.FromFile{i}=1;
%         handles.Model(md).Input.BndFile{i}=MDW.Boundary(i).Spectrum;
%     end
% end
% handles.Model(md).Input.UniformTemp=0;
% handles.Model(md).Input.SpacevaryingTemp=0;
% handles.Model(md).Input.ParametricTemp=0;
% handles.Model(md).Input.FromFileTemp=0;
% handles.Model(md).Input.BndNameTemp=0;
% handles.Model(md).Input.BndDefbyTemp=1;
% handles.Model(md).Input.BndOrientTemp=1;
% handles.Model(md).Input.BndStart1Temp=0;
% handles.Model(md).Input.BndStart2Temp=0;
% handles.Model(md).Input.BndEnd1Temp=0;
% handles.Model(md).Input.BndEnd2Temp=0;
% handles.Model(md).Input.DistTemp=0;
% handles.Model(md).Input.HsTemp=0;
% handles.Model(md).Input.TpTemp=0;
% handles.Model(md).Input.DirTemp=0;
% handles.Model(md).Input.SpreadTemp=0;
% handles.Model(md).Input.ClockTemp=1;
% handles.Model(md).Input.CounterClockTemp=0;
% handles.Model(md).Input.BndFileTemp='';
% handles.Model(md).Input.JonswapTemp=1;
% handles.Model(md).Input.JonswapvalTemp=3.3;
% handles.Model(md).Input.PiersonTemp=0;
% handles.Model(md).Input.GaussTemp=0;
% handles.Model(md).Input.GaussvalTemp=0.01;
% handles.Model(md).Input.PeakTemp=1;
% handles.Model(md).Input.MeanTemp=0;
% handles.Model(md).Input.CosineTemp=1;
% handles.Model(md).Input.DegreesTemp=0;
% 
% handles.Model(md).Input.Nautical=0;
% handles.Model(md).Input.Cartesian=0;
% handles.Model(md).Input.None=0;
% handles.Model(md).Input.Activated=MDW.Processes.WaveSetup;
% if strcmp(MDW.Processes.WaveForces,'dissipation') == 1
%     handles.Model(md).Input.Waveenergy=1;
%     handles.Model(md).Input.Radiation=0;
% elseif strcmp(MDW.Processes.WaveForces,'radiation stresses') == 1
%     handles.Model(md).Input.Waveenergy=0;
%     handles.Model(md).Input.Radiation=1;
% end
% 
% handles.Model(md).Input.UniformW=1;
% handles.Model(md).Input.SpacevaryingW=0;
% handles.Model(md).Input.Asbathy=0;
% handles.Model(md).Input.Tospecify=0;
% handles.Model(md).Input.SpeedW=MDW.general.WindSpeed;
% handles.Model(md).Input.DirectionW=MDW.general.WindDir;
% handles.Model(md).Input.WindFile='';
% handles.Model(md).Input.XoriginW='';
% handles.Model(md).Input.YoriginW='';
% handles.Model(md).Input.AngleW='';
% handles.Model(md).Input.XcellsW='';
% handles.Model(md).Input.YcellsW='';
% handles.Model(md).Input.XsizeW='';
% handles.Model(md).Input.YsizeW='';
% handles.Model(md).Input.Generation={'None';'1-st generation';'2-nd generation';'3-rd generation'};
% if MDW.Processes.GenModePhys == 1
%     handles.Model(md).Input.GenerationIval=2;
% elseif MDW.Processes.GenModePhys == 2
%     handles.Model(md).Input.GenerationIval=3;
% elseif MDW.Processes.GenModePhys == 3
%     handles.Model(md).Input.GenerationIval=4;
% end
% handles.Model(md).Input.Breaking=MDW.Processes.Breaking;
% handles.Model(md).Input.Triad=MDW.Processes.Triads;
% if strcmp(MDW.Processes.BedFriction,'none') == 1
%     handles.Model(md).Input.Friction=0;
% else
%     handles.Model(md).Input.Friction=1;
% end
% handles.Model(md).Input.Diffraction=MDW.Processes.Diffraction;
% handles.Model(md).Input.Alpha1=MDW.Processes.BreakAlpha;
% handles.Model(md).Input.Gamma=MDW.Processes.BreakGamma;
% handles.Model(md).Input.Alpha2=MDW.Processes.TriadsAlpha;
% handles.Model(md).Input.Beta=MDW.Processes.TriadsBeta;
% handles.Model(md).Input.Type={'JONSWAP';'Collins';'Madsen et al.'};
% if strcmp(MDW.Processes.BedFriction,'jonswap')==1
%     handles.Model(md).Input.Typeval=1;
% elseif strcmp(MDW.Processes.BedFriction,'collins')==1
%     handles.Model(md).Input.Typeval=2;
% elseif strcmp(MDW.Processes.BedFriction,'madsen et al.')==1
%     handles.Model(md).Input.Typeval=3;
% end
% handles.Model(md).Input.Coefficient=MDW.Processes.BedFricCoef;
% handles.Model(md).Input.Smoothcoef=MDW.Processes.DiffracCoef;
% handles.Model(md).Input.Smoothsteps=MDW.Processes.DiffracSteps;
% handles.Model(md).Input.Propagation=MDW.Processes.DiffracProp;
% 
% handles.Model(md).Input.Acti1=MDW.Processes.WindGrowth;
% if MDW.Processes.WindGrowth == 0
%     handles.Model(md).Input.DeActi1=1;
% elseif MDW.Processes.WindGrowth == 1
%     handles.Model(md).Input.DeActi1=0;
% end
% handles.Model(md).Input.Acti2=MDW.Processes.WhiteCapping;
% if MDW.Processes.WhiteCapping == 0
%     handles.Model(md).Input.DeActi2=1;
% elseif MDW.Processes.WhiteCapping == 1
%     handles.Model(md).Input.DeActi2=0;
% end
% handles.Model(md).Input.Acti3=MDW.Processes.Quadruplets;
% if MDW.Processes.Quadruplets == 0
%     handles.Model(md).Input.DeActi3=1;
% elseif MDW.Processes.Quadruplets == 1
%     handles.Model(md).Input.DeActi3=0;
% end
% handles.Model(md).Input.Acti4=MDW.Processes.Refraction;
% if MDW.Processes.Refraction == 0
%     handles.Model(md).Input.DeActi4=1;
% elseif MDW.Processes.Refraction == 1
%     handles.Model(md).Input.DeActi4=0;
% end
% handles.Model(md).Input.Acti5=MDW.Processes.FreqShift;
% if MDW.Processes.FreqShift == 0
%     handles.Model(md).Input.DeActi5=1;
% elseif MDW.Processes.FreqShift == 1
%     handles.Model(md).Input.DeActi5=0;
% end
% 
% handles.Model(md).Input.First=1;
% handles.Model(md).Input.Third=0;
% handles.Model(md).Input.CDD=MDW.Numerics.DirSpaceCDD;
% handles.Model(md).Input.CSS=MDW.Numerics.DirSpaceCDD;
% 
% handles.Model(md).Input.HSTM01=MDW.Numerics.RChHsTm01;
% handles.Model(md).Input.HSchange=MDW.Numerics.RChMeanHs;
% handles.Model(md).Input.TM01=MDW.Numerics.RChMeanTm01;
% handles.Model(md).Input.PercWet=MDW.Numerics.PercWet;
% handles.Model(md).Input.MaxIter=MDW.Numerics.MaxIter;
% 
% handles.Model(md).Input.TestOutput=MDW.Output.TestOutputLevel;
% handles.Model(md).Input.Debug=0;
% handles.Model(md).Input.TimeStepOutput=MDW.Output.COMWriteInterval;
% handles.Model(md).Input.Interval=10;
% handles.Model(md).Input.Mode={'stationnary';'quasi-stationary';'non-stationnary'};
% if strcmp(MDW.general.SimMode,'stationnary') == 1
%    handles.Model(md).Input.ModeIval=1;
% elseif strcmp(MDW.general.SimMode,'quasi-stationnary') == 1
%     handles.Model(md).Input.ModeIval=1;
% elseif strcmp(MDW.general.SimMode,'non-stationnary') == 1
%     handles.Model(md).Input.ModeIval=1;
%     handles.Model(md).Input.TimeStep=MDW.general.TimeStep;
% end
% handles.Model(md).Input.Hotstart=MDW.Output.UseHotFile;
% if strcmp(MDW.general.OnlyInputVerify,'simulation run') == 1
%     handles.Model(md).Input.Verify=0;
% elseif strcmp(MDW.general.OnlyInputVerify,'input validation only') == 1
%     handles.Model(md).Input.Verify=1;
% end
% handles.Model(md).Input.Verify=0;
% handles.Model(md).Input.OutputFlowGrid=MDW.Output.WriteCOM;
% handles.Model(md).Input.OutputFlowGridFile='';
% for id = 1:itot
%     handles.Model(md).Input.Compgrid
%     eval(['' num2str(id)])=MDW.Domain(id).Output;
% end
% handles.Model(md).Input.OutputSpecific=0;
% handles.Model(md).Input.Table=MDW.Output.WriteTable;
% handles.Model(md).Input.oneDspectra=MDW.Output.WriteSpec1D;
% handles.Model(md).Input.twoDspectra=MDW.Output.WriteSpec2D;
% handles.Model(md).Input.LocFromFile=1;
% handles.Model(md).Input.LocFileName='';
% handles.Model(md).Input.LocSpecified=0;
% handles.Model(md).Input.Locations='';
% handles.Model(md).Input.LocationsIval='';
% handles.Model(md).Input.LocXTemp=0;
% handles.Model(md).Input.LocYTemp=0;
% handles.Model(md).Input.LocX=0;
% handles.Model(md).Input.LocY=0;
% 
% handles.Model(md).Input.PolFile = MDW.ObstacleFileInformation.PolygonFile;
% 
% itot =size(MDW.Obstacle.Name,2)
% handles.Model(md).Input.Reflections={'No';'Specular';'Diffuse'};
% handles.Model(md).Input.Obstacles=MDW.Obstacle(1:itot).Name;
% for i = 1:itot
%     if strcmp(MDW.Obstacle(i).Type,'sheet')==1
%         handles.Model(md).Input.Sheet{i}=1;
%         handles.Model(md).Input.Dam{i}=0;
%         handles.Model(md).Input.Transmcoef{i}=MDW.Obstacle(i).TransmCoef;
%     elseif strcmp(MDW.Obstacle(i).Type,'dam')==1
%         handles.Model(md).Input.Sheet{i}=0;
%         handles.Model(md).Input.Dam{i}=1;
%         handles.Model(md).Input.Height{i}=MDW.Obstacle(i).Height;
%         handles.Model(md).Input.Alpha{i}=MDW.Obstacle(i).Alpha;
%         handles.Model(md).Input.Beta{i}=MDW.Obstacle(i).Beta;
%     end
%     handles.Model(md).Input.Refcoef{i}=MDW.Obstacle(i).ReflecCoef;
% end
% 
% handles.Model(md).Input.ObstaclesNb(id).Segments='';
% handles.Model(md).Input.ObstaclesNb(id).SegmentsIval='';
% handles.Model(md).Input.ObstaclesNb(id).Xstart=0;
% handles.Model(md).Input.ObstaclesNb(id).Ystart=0;
% handles.Model(md).Input.ObstaclesNb(id).Xend=0;
% handles.Model(md).Input.ObstaclesNb(id).Yend=0;
% 
