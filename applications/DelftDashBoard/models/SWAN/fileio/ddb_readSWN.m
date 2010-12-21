function handles=ddb_readSWN(handles,filename,id)

% DEBUG
% filename = 'dif90.swn'; % tets case from swan.tudelft.nl
% md       = 1;
% DEBUG

SWN=swan_io_input(filename);

handles.Model(md).Input.ActiveDomain      =1;
% handles.Model(md).Input.Runid=runid;
handles.Model(md).Input.ItDate            = floor(now);
handles.Model(md).Input.StartTime         = floor(now);
handles.Model(md).Input.StopTime          = floor(now)+2;
handles.Model(md).Input.AttName           = [];
% handles.Model(md).Input.SWNFile=[runid '.SWN'];

handles.Model(md).Input.ProjectName       = SWN.project.name;
handles.Model(md).Input.ProjectNumber     = SWN.project.nr;
handles.Model(md).Input.Description       ={SWN.project.title1,SWN.project.title2,SWN.project.title3};

handles.Model(md).Input.FlowBedLevel      = []; %.Domain(1).FlowBedLevel;
handles.Model(md).Input.FlowWaterLevel    = []; %SWN.Domain(1).FlowWaterLevel;
handles.Model(md).Input.FlowVelocity      = []; %SWN.Domain(1).FlowVelocity;
handles.Model(md).Input.FlowWind          = []; %SWN.Domain(1).FlowWind;
handles.Model(md).Input.MDFFile           = '';
handles.Model(md).Input.AvailableFlowTimes='';

itot = 1;

handles.Model(md).Input.ComputationalGrids = [];
for id = 1:itot
    handles.Model(md).Input.Domain(id).PathnameComputationalGrids=fileparts(SWN.fullfilename);
    handles.Model(md).Input.Domain(id).Coordsyst   = []; %SWN.General.DirConvention;
    handles.Model(md).Input.Domain(id).GrdFile     = []; %SWN.Domain(id).Grid;
    handles.Model(md).Input.Domain(id).EncFile     = '';
    handles.Model(md).Input.Domain(id).DepFile     = []; %SWN.Domain(id).BedLevel;
    handles.Model(md).Input.Domain(id).NstFile     = '';
    handles.Model(md).Input.Domain(id).MMax        = '';
    handles.Model(md).Input.Domain(id).NMax        = '';
    
    handles.Model(md).Input.Domain(id).CompGrid    = []; %SWN.Domain(id).BedLevelGrid;
    handles.Model(md).Input.Domain(id).OtherGrid   = '';
    handles.Model(md).Input.Domain(id).CompDep     = '';
    handles.Model(md).Input.Domain(id).Xorig       = SWN.cgrid.xpc;
    handles.Model(md).Input.Domain(id).Yorig       = SWN.cgrid.ypc;
    handles.Model(md).Input.Domain(id).Xgridsize   = SWN.cgrid.xlenc/SWN.cgrid.mxc;
    handles.Model(md).Input.Domain(id).Ygridsize   = SWN.cgrid.ylenc/SWN.cgrid.myc;
    
    handles.Model(md).Input.Domain(id).Circle      = SWN.cgrid.circle;
    handles.Model(md).Input.Domain(id).Sector      = SWN.cgrid.sector;
    
    handles.Model(md).Input.Domain(id).StartDir    = SWN.cgrid.dir1;
    handles.Model(md).Input.Domain(id).EndDir      = SWN.cgrid.dir2;
    handles.Model(md).Input.Domain(id).NumberDir   = SWN.cgrid.mdc;
    handles.Model(md).Input.Domain(id).LowFreq     = SWN.cgrid.flow;
    handles.Model(md).Input.Domain(id).HighFreq    = SWN.cgrid.fhigh;
    handles.Model(md).Input.Domain(id).NumberFreq  = SWN.cgrid.msc;
    handles.Model(md).Input.Domain(id).GridNested  = '';
    handles.Model(md).Input.Domain(id).NestedValue = '';
end

handles.Model(md).Input.WaterlevelCor               = 0;
handles.Model(md).Input.Timepoints                  = SWN.compute.datenum;
handles.Model(md).Input.Time                        = SWN.compute.datenum;
handles.Model(md).Input.WaterLevel                  = [];
handles.Model(md).Input.Xvelocity                   = [];
handles.Model(md).Input.Yvelocity                   = [];
handles.Model(md).Input.TimeTemp                    = '';
handles.Model(md).Input.WaterLevelTemp              = '';
handles.Model(md).Input.XvelocityTemp               = '';
handles.Model(md).Input.YvelocityTemp               = '';
handles.Model(md).Input.TimepointsIval              = '';
handles.Model(md).Input.TimeDependentQuantitiesFile ='';
handles.Model(md).Input.NumberQuantities            = '';

itot = length(SWN.boundspec);

handles.Model(md).Input.BndDefby   = {'Orientation';'Grid coordinates';'XY coordinates'};
handles.Model(md).Input.BndOrient  = {'North';'Northwest';'West';'Southwest';'South';'Southeast';'East';'Northeast'};
handles.Model(md).Input.Boundaries = cellstr(num2str([1:itot]'));
for i=1:itot
    handles.Model(md).Input.BndName{i}=[];
    if strcmp(SWN.boundspec(i).specification,'side')==1
        handles.Model(md).Input.BndDefbyval{i}=1;
        if     strcmp(SWN.boundspec(i).winddir(1:1),'N' )==1;handles.Model(md).Input.BndOrientval{i}=1;
        elseif strcmp(SWN.boundspec(i).winddir(1:1),'W' )==1;handles.Model(md).Input.BndOrientval{i}=3;
        elseif strcmp(SWN.boundspec(i).winddir(1:1),'S' )==1;handles.Model(md).Input.BndOrientval{i}=5;
        elseif strcmp(SWN.boundspec(i).winddir(1:1),'E' )==1;handles.Model(md).Input.BndOrientval{i}=7;

        elseif strcmp(SWN.boundspec(i).winddir(1:2),'NW')==1;handles.Model(md).Input.BndOrientval{i}=2;
        elseif strcmp(SWN.boundspec(i).winddir(1:2),'SW')==1;handles.Model(md).Input.BndOrientval{i}=4;
        elseif strcmp(SWN.boundspec(i).winddir(1:2),'SE')==1;handles.Model(md).Input.BndOrientval{i}=6;
        elseif strcmp(SWN.boundspec(i).winddir(1:2),'NE')==1;handles.Model(md).Input.BndOrientval{i}=8;
        end            
    elseif strcmp(SWN.boundspec(i).specification,'segment')==1 & isfield()
        handles.Model(md).Input.BndDefbyval{i}=2;
        handles.Model(md).Input.BndStart1{i}=SWN.boundspec(i).i(1);
        handles.Model(md).Input.BndEnd1  {i}=SWN.boundspec(i).i(2);
        handles.Model(md).Input.BndStart2{i}=SWN.boundspec(i).j(1);
        handles.Model(md).Input.BndEnd2  {i}=SWN.boundspec(i).j(2);
    elseif strcmp(SWN.boundspec(i).specification,'segment')==1 & isfield()
        handles.Model(md).Input.BndDefbyval{i}=3
        handles.Model(md).Input.BndStart1{i}=SWN.boundspec(i).x(1);
        handles.Model(md).Input.BndEnd1  {i}=SWN.boundspec(i).x(2);
        handles.Model(md).Input.BndStart2{i}=SWN.boundspec(i).y(1);
        handles.Model(md).Input.BndEnd2  {i}=SWN.boundspec(i).y(2);        
    end
error('progress of impleneting SWAN into ddb only finished untill here')
    if strcmp(SWN.boundspec(i).SpectrumSpec,'parametric')==1
        handles.Model(md).Input.Parametric{i}=1;
        handles.Model(md).Input.FromFile{i}=0;
        if strcmp(SWN.boundspec(i).SpShapeType,'jonswap')==1
            handles.Model(md).Input.Jonswap{i}=1;
            handles.Model(md).Input.Jonswapval{i}=SWN.boundspec(i).PeakEnhancFac;
        elseif strcmp(SWN.boundspec(i).SpShapeType,'pierson-moskowitz')==1
            handles.Model(md).Input.Pierson{i}=1;
        elseif strcmp(SWN.boundspec(i).SpShapeType,'gauss')==1
            handles.Model(md).Input.Gauss{i}=1;           
            handles.Model(md).Input.Gaussval{i}=SWN.boundspec(i).GaussSpread;
        end
        if strcmp(SWN.boundspec(i).PeriodType,'peak')==1
            handles.Model(md).Input.Peak{i}=1;
            handles.Model(md).Input.Mean{i}=0;
        elseif strcmp(SWN.boundspec(i).PeriodType,'mean')==1
            handles.Model(md).Input.Peak{i}=0;
            handles.Model(md).Input.Mean{i}=1;
        end
        if strcmp(SWN.boundspec(i).DirSpreadType,'power')==1
            handles.Model(md).Input.Cosine{i}=1;
            handles.Model(md).Input.Degrees{i}=0;
        elseif strcmp(SWN.boundspec(i).DirSpreadType,'degrees')==1
            handles.Model(md).Input.Cosine{i}=0;
            handles.Model(md).Input.Degrees{i}=1;
        end
        if size(SWN.boundspec(i).List,2)>0
            handles.Model(md).Input.Uniform{i}=0;
            handles.Model(md).Input.Spacevarying{i}=1;
            ktot = size(SWN.boundspec(i).List,2);
            for k=1:ktot
                handles.Model(md).Input.Sections(k)=['Section ' num2str(k)];
                handles.Model(md).Input.SpacevaryingParam(i).Dist{k}   = SWN.boundspec(i).List(k).CondSpecAtDist;
                handles.Model(md).Input.SpacevaryingParam(i).Hs{k}     = SWN.boundspec(i).List(k).WaveHeight;
                handles.Model(md).Input.SpacevaryingParam(i).Tp{k}     = SWN.boundspec(i).List(k).Period;
                handles.Model(md).Input.SpacevaryingParam(i).Dir{k}    = SWN.boundspec(i).List(k).Direction;
                handles.Model(md).Input.SpacevaryingParam(i).Spread{k} = SWN.boundspec(i).List(k).DirSpreading;
            end
        else
            handles.Model(md).Input.Uniform{i}      = 1;
            handles.Model(md).Input.Spacevarying{i} = 0;            
            handles.Model(md).Input.Hs{i}           = SWN.boundspec(i).WaveHeight;
            handles.Model(md).Input.Tp{i}           = SWN.boundspec(i).Period;
            handles.Model(md).Input.Dir{i}          = SWN.boundspec(i).Direction;
            handles.Model(md).Input.Spread{i}       = SWN.boundspec(i).DirSpreading;
        end
    else
        handles.Model(md).Input.Parametric{i}=0;
        handles.Model(md).Input.FromFile{i}=1;
        handles.Model(md).Input.BndFile{i}=SWN.boundspec(i).Spectrum;
    end
end
handles.Model(md).Input.UniformTemp=0;
handles.Model(md).Input.SpacevaryingTemp=0;
handles.Model(md).Input.ParametricTemp=0;
handles.Model(md).Input.FromFileTemp=0;
handles.Model(md).Input.BndNameTemp=0;
handles.Model(md).Input.BndDefbyTemp=1;
handles.Model(md).Input.BndOrientTemp=1;
handles.Model(md).Input.BndStart1Temp=0;
handles.Model(md).Input.BndStart2Temp=0;
handles.Model(md).Input.BndEnd1Temp=0;
handles.Model(md).Input.BndEnd2Temp=0;
handles.Model(md).Input.DistTemp=0;
handles.Model(md).Input.HsTemp=0;
handles.Model(md).Input.TpTemp=0;
handles.Model(md).Input.DirTemp=0;
handles.Model(md).Input.SpreadTemp=0;
handles.Model(md).Input.ClockTemp=1;
handles.Model(md).Input.CounterClockTemp=0;
handles.Model(md).Input.BndFileTemp='';
handles.Model(md).Input.JonswapTemp=1;
handles.Model(md).Input.JonswapvalTemp=3.3;
handles.Model(md).Input.PiersonTemp=0;
handles.Model(md).Input.GaussTemp=0;
handles.Model(md).Input.GaussvalTemp=0.01;
handles.Model(md).Input.PeakTemp=1;
handles.Model(md).Input.MeanTemp=0;
handles.Model(md).Input.CosineTemp=1;
handles.Model(md).Input.DegreesTemp=0;

handles.Model(md).Input.Gravity=SWN.Constants.Gravity;
handles.Model(md).Input.Waterdensity=SWN.Constants.WaterDensity;
handles.Model(md).Input.Northwaxis=SWN.Constants.NorthDir;
handles.Model(md).Input.Mindepth=SWN.Constants.MinimumDepth;
handles.Model(md).Input.Nautical =  SWN.set.naut;
handles.Model(md).Input.Cartesian= ~SWN.set.naut;
handles.Model(md).Input.None=0;
handles.Model(md).Input.Activated=SWN.Processes.WaveSetup;
if strcmp(SWN.Processes.WaveForces,'dissipation') == 1
    handles.Model(md).Input.Waveenergy=1;
    handles.Model(md).Input.Radiation=0;
elseif strcmp(SWN.Processes.WaveForces,'radiation stresses') == 1
    handles.Model(md).Input.Waveenergy=0;
    handles.Model(md).Input.Radiation=1;
end

handles.Model(md).Input.UniformW=1;
handles.Model(md).Input.SpacevaryingW=0;
handles.Model(md).Input.Asbathy=0;
handles.Model(md).Input.Tospecify=0;
handles.Model(md).Input.SpeedW=SWN.General.WindSpeed;
handles.Model(md).Input.DirectionW=SWN.General.WindDir;
handles.Model(md).Input.WindFile='';
handles.Model(md).Input.XoriginW='';
handles.Model(md).Input.YoriginW='';
handles.Model(md).Input.AngleW='';
handles.Model(md).Input.XcellsW='';
handles.Model(md).Input.YcellsW='';
handles.Model(md).Input.XsizeW='';
handles.Model(md).Input.YsizeW='';
handles.Model(md).Input.Generation={'None';'1-st generation';'2-nd generation';'3-rd generation'};
if SWN.Processes.GenModePhys == 1
    handles.Model(md).Input.GenerationIval=2;
elseif SWN.Processes.GenModePhys == 2
    handles.Model(md).Input.GenerationIval=3;
elseif SWN.Processes.GenModePhys == 3
    handles.Model(md).Input.GenerationIval=4;
end
handles.Model(md).Input.Breaking=SWN.Processes.Breaking;
handles.Model(md).Input.Triad=SWN.Processes.Triads;
if strcmp(SWN.Processes.BedFriction,'none') == 1
    handles.Model(md).Input.Friction=0;
else
    handles.Model(md).Input.Friction=1;
end
handles.Model(md).Input.Diffraction=SWN.Processes.Diffraction;
handles.Model(md).Input.Alpha1=SWN.Processes.BreakAlpha;
handles.Model(md).Input.Gamma=SWN.Processes.BreakGamma;
handles.Model(md).Input.Alpha2=SWN.Processes.TriadsAlpha;
handles.Model(md).Input.Beta=SWN.Processes.TriadsBeta;
handles.Model(md).Input.Type={'JONSWAP';'Collins';'Madsen et al.'};
if strcmp(SWN.Processes.BedFriction,'jonswap')==1
    handles.Model(md).Input.Typeval=1;
elseif strcmp(SWN.Processes.BedFriction,'collins')==1
    handles.Model(md).Input.Typeval=2;
elseif strcmp(SWN.Processes.BedFriction,'madsen et al.')==1
    handles.Model(md).Input.Typeval=3;
end
handles.Model(md).Input.Coefficient=SWN.Processes.BedFricCoef;
handles.Model(md).Input.Smoothcoef=SWN.Processes.DiffracCoef;
handles.Model(md).Input.Smoothsteps=SWN.Processes.DiffracSteps;
handles.Model(md).Input.Propagation=SWN.Processes.DiffracProp;

handles.Model(md).Input.Acti1=SWN.Processes.WindGrowth;
if SWN.Processes.WindGrowth == 0
    handles.Model(md).Input.DeActi1=1;
elseif SWN.Processes.WindGrowth == 1
    handles.Model(md).Input.DeActi1=0;
end
handles.Model(md).Input.Acti2=SWN.Processes.WhiteCapping;
if SWN.Processes.WhiteCapping == 0
    handles.Model(md).Input.DeActi2=1;
elseif SWN.Processes.WhiteCapping == 1
    handles.Model(md).Input.DeActi2=0;
end
handles.Model(md).Input.Acti3=SWN.Processes.Quadruplets;
if SWN.Processes.Quadruplets == 0
    handles.Model(md).Input.DeActi3=1;
elseif SWN.Processes.Quadruplets == 1
    handles.Model(md).Input.DeActi3=0;
end
handles.Model(md).Input.Acti4=SWN.Processes.Refraction;
if SWN.Processes.Refraction == 0
    handles.Model(md).Input.DeActi4=1;
elseif SWN.Processes.Refraction == 1
    handles.Model(md).Input.DeActi4=0;
end
handles.Model(md).Input.Acti5=SWN.Processes.FreqShift;
if SWN.Processes.FreqShift == 0
    handles.Model(md).Input.DeActi5=1;
elseif SWN.Processes.FreqShift == 1
    handles.Model(md).Input.DeActi5=0;
end

handles.Model(md).Input.First=1;
handles.Model(md).Input.Third=0;
handles.Model(md).Input.CDD=SWN.Numerics.DirSpaceCDD;
handles.Model(md).Input.CSS=SWN.Numerics.DirSpaceCDD;

handles.Model(md).Input.HSTM01=SWN.Numerics.RChHsTm01;
handles.Model(md).Input.HSchange=SWN.Numerics.RChMeanHs;
handles.Model(md).Input.TM01=SWN.Numerics.RChMeanTm01;
handles.Model(md).Input.PercWet=SWN.Numerics.PercWet;
handles.Model(md).Input.MaxIter=SWN.Numerics.MaxIter;

handles.Model(md).Input.TestOutput=SWN.Output.TestOutputLevel;
handles.Model(md).Input.Debug=0;
handles.Model(md).Input.TimeStepOutput=SWN.Output.COMWriteInterval;
handles.Model(md).Input.Interval=10;
handles.Model(md).Input.Mode={'stationnary';'quasi-stationary';'non-stationnary'};
if strcmp(SWN.General.SimMode,'stationnary') == 1
   handles.Model(md).Input.ModeIval=1;
elseif strcmp(SWN.General.SimMode,'quasi-stationnary') == 1
    handles.Model(md).Input.ModeIval=1;
elseif strcmp(SWN.General.SimMode,'non-stationnary') == 1
    handles.Model(md).Input.ModeIval=1;
    handles.Model(md).Input.TimeStep=SWN.General.TimeStep;
end
handles.Model(md).Input.Hotstart=SWN.Output.UseHotFile;
if strcmp(SWN.General.OnlyInputVerify,'simulation run') == 1
    handles.Model(md).Input.Verify=0;
elseif strcmp(SWN.General.OnlyInputVerify,'input validation only') == 1
    handles.Model(md).Input.Verify=1;
end
handles.Model(md).Input.Verify=0;
handles.Model(md).Input.OutputFlowGrid=SWN.Output.WriteCOM;
handles.Model(md).Input.OutputFlowGridFile='';
for id = 1:itot
    handles.Model(md).Input.Compgrid
    eval(['' num2str(id)])=SWN.Domain(id).Output;
end
handles.Model(md).Input.OutputSpecific=0;
handles.Model(md).Input.Table=SWN.Output.WriteTable;
handles.Model(md).Input.oneDspectra=SWN.Output.WriteSpec1D;
handles.Model(md).Input.twoDspectra=SWN.Output.WriteSpec2D;
handles.Model(md).Input.LocFromFile=1;
handles.Model(md).Input.LocFileName='';
handles.Model(md).Input.LocSpecified=0;
handles.Model(md).Input.Locations='';
handles.Model(md).Input.LocationsIval='';
handles.Model(md).Input.LocXTemp=0;
handles.Model(md).Input.LocYTemp=0;
handles.Model(md).Input.LocX=0;
handles.Model(md).Input.LocY=0;

handles.Model(md).Input.PolFile = SWN.ObstacleFileInformation.PolygonFile;

itot =size(SWN.Obstacle.Name,2)
handles.Model(md).Input.Reflections={'No';'Specular';'Diffuse'};
handles.Model(md).Input.Obstacles=SWN.Obstacle(1:itot).Name;
for i = 1:itot
    if strcmp(SWN.Obstacle(i).Type,'sheet')==1
        handles.Model(md).Input.Sheet{i}=1;
        handles.Model(md).Input.Dam{i}=0;
        handles.Model(md).Input.Transmcoef{i}=SWN.Obstacle(i).TransmCoef;
    elseif strcmp(SWN.Obstacle(i).Type,'dam')==1
        handles.Model(md).Input.Sheet{i}=0;
        handles.Model(md).Input.Dam{i}=1;
        handles.Model(md).Input.Height{i}=SWN.Obstacle(i).Height;
        handles.Model(md).Input.Alpha{i}=SWN.Obstacle(i).Alpha;
        handles.Model(md).Input.Beta{i}=SWN.Obstacle(i).Beta;
    end
    handles.Model(md).Input.Refcoef{i}=SWN.Obstacle(i).ReflecCoef;
end

handles.Model(md).Input.ObstaclesNb(id).Segments='';
handles.Model(md).Input.ObstaclesNb(id).SegmentsIval='';
handles.Model(md).Input.ObstaclesNb(id).Xstart=0;
handles.Model(md).Input.ObstaclesNb(id).Ystart=0;
handles.Model(md).Input.ObstaclesNb(id).Xend=0;
handles.Model(md).Input.ObstaclesNb(id).Yend=0;

