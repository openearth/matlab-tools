function handles=ddb_readMDW(handles,filename,id)

MDW=ddb_readMDWText(filename);

handles.Model(md).Input.ActiveDomain=1;
% handles.Model(md).Input.Runid=runid;
handles.Model(md).Input.ItDate=floor(now);
handles.Model(md).Input.StartTime=floor(now);
handles.Model(md).Input.StopTime=floor(now)+2;
handles.Model(md).Input.AttName=handles.Model(md).Input.Runid;
% handles.Model(md).Input.MdwFile=[runid '.mdw'];

handles.Model(md).Input.ProjectName=MDW.General.ProjectName;
handles.Model(md).Input.ProjectNumber=MDW.General.ProjectNr;
handles.Model(md).Input.Description={MDW.General.Description1,MDW.General.Description2,MDW.General.Description3};

handles.Model(md).Input.FlowBedLevel=MDW.Domain(1).FlowBedLevel;
handles.Model(md).Input.FlowWaterLevel=MDW.Domain(1).FlowWaterLevel;
handles.Model(md).Input.FlowVelocity=MDW.Domain(1).FlowVelocity;
handles.Model(md).Input.FlowWind=MDW.Domain(1).FlowWind;
handles.Model(md).Input.MDFFile='';
handles.Model(md).Input.AvailableFlowTimes='';

itot = size(MDW.Domain.Grid,2)

handles.Model(md).Input.ComputationalGrids=MDW.Domain(1:itot).Grid;
for id = 1:itot
    handles.Model(md).Input.Domain(id).PathnameComputationalGrids=MDW.Domain(id).Grid;
    handles.Model(md).Input.Domain(id).Coordsyst=MDW.General.DirConvention;
    handles.Model(md).Input.Domain(id).GrdFile=MDW.Domain(id).Grid;
    handles.Model(md).Input.Domain(id).EncFile='';
    handles.Model(md).Input.Domain(id).DepFile=MDW.Domain(id).BedLevel;
    handles.Model(md).Input.Domain(id).NstFile='';
    handles.Model(md).Input.Domain(id).MMax='';
    handles.Model(md).Input.Domain(id).NMax='';
    
    handles.Model(md).Input.Domain(id).CompGrid=MDW.Domain(id).BedLevelGrid;
    handles.Model(md).Input.Domain(id).OtherGrid='';
    handles.Model(md).Input.Domain(id).CompDep='';
    handles.Model(md).Input.Domain(id).Xorig='';
    handles.Model(md).Input.Domain(id).Yorig='';
    handles.Model(md).Input.Domain(id).Xgridsize='';
    handles.Model(md).Input.Domain(id).Ygridsize='';
    
    if strcmp(MDW.General.DirSpace,'circle')==1
        handles.Model(md).Input.Domain(id).Circle=1;
        handles.Model(md).Input.Domain(id).Sector=0;
    elseif strcmp(MDW.General.DirSpace,'sector')==1
        handles.Model(md).Input.Domain(id).Circle=0;
        handles.Model(md).Input.Domain(id).Sector=1;
    end
    handles.Model(md).Input.Domain(id).StartDir=MDW.General.StartDir;
    handles.Model(md).Input.Domain(id).EndDir=MDW.General.EndDir;
    handles.Model(md).Input.Domain(id).NumberDir=MDW.General.NDir;
    handles.Model(md).Input.Domain(id).LowFreq=MDW.General.FreqMin;
    handles.Model(md).Input.Domain(id).HighFreq=MDW.General.FreqMax;
    handles.Model(md).Input.Domain(id).NumberFreq=MDW.General.NFreq;
    handles.Model(md).Input.Domain(id).GridNested='';
    handles.Model(md).Input.Domain(id).NestedValue='';
end

handles.Model(md).Input.WaterlevelCor=0;
handles.Model(md).Input.Timepoints=MDW.General.TimePoint;
handles.Model(md).Input.Time=MDW.General.TimePoint;
handles.Model(md).Input.WaterLevel=MDW.General.WaterLevel;
handles.Model(md).Input.Xvelocity=MDW.General.XVeloc;
handles.Model(md).Input.Yvelocity=MDW.General.YVeloc;
handles.Model(md).Input.TimeTemp='';
handles.Model(md).Input.WaterLevelTemp='';
handles.Model(md).Input.XvelocityTemp='';
handles.Model(md).Input.YvelocityTemp='';
handles.Model(md).Input.TimepointsIval='';
handles.Model(md).Input.TimeDependentQuantitiesFile='';
handles.Model(md).Input.NumberQuantities='';

itot = size(MDW.Boundary.Name,2);

handles.Model(md).Input.BndDefby={'Orientation';'Grid coordinates';'XY coordinates'};
handles.Model(md).Input.BndOrient={'North';'Northwest';'West';'Southwest';'South';'Southeast';'East';'Northeast'};
handles.Model(md).Input.Boundaries=MDW.Boundary(1:itot).Name;
for i=1:itot
    handles.Model(md).Input.BndName{i}=MDW.Boundary(i).Name;
    if strcmp(MDW.Boundary(i).Definition,'orientation')==1
        handles.Model(md).Input.BndDefbyval{i}=1;
        if strcmp(MDW.Boundary(i).Orientation,'North')==1
            handles.Model(md).Input.BndOrientval{i}=1;
        elseif strcmp(MDW.Boundary(i).Orientation,'Northwest')==1
            handles.Model(md).Input.BndOrientval{i}=2;
        elseif strcmp(MDW.Boundary(i).Orientation,'West')==1
            handles.Model(md).Input.BndOrientval{i}=3;
        elseif strcmp(MDW.Boundary(i).Orientation,'Southwest')==1
            handles.Model(md).Input.BndOrientval{i}=4;
        elseif strcmp(MDW.Boundary(i).Orientation,'South')==1
            handles.Model(md).Input.BndOrientval{i}=5;
        elseif strcmp(MDW.Boundary(i).Orientation,'Southeast')==1
            handles.Model(md).Input.BndOrientval{i}=6;
        elseif strcmp(MDW.Boundary(i).Orientation,'East')==1
            handles.Model(md).Input.BndOrientval{i}=7;
        elseif strcmp(MDW.Boundary(i).Orientation,'Northeast')==1
            handles.Model(md).Input.BndOrientval{i}=8;
        end            
    elseif strcmp(MDW.Boundary(i).Definition,'grid-coordinates')==1
        handles.Model(md).Input.BndDefbyval{i}=2;
        handles.Model(md).Input.BndStart1{i}=MDW.Boundary(i).StartCoordM;
        handles.Model(md).Input.BndEnd1{i}=MDW.Boundary(i).EndCoordM;
        handles.Model(md).Input.BndStart2{i}=MDW.Boundary(i).StartCoordN;
        handles.Model(md).Input.BndEnd2{i}=MDW.Boundary(i).EndCoordN;
    elseif strcmp(MDW.Boundary(i).Definition,'xy-coordinates')==1
        handles.Model(md).Input.BndDefbyval{i}=3
        handles.Model(md).Input.BndStart1{i}=MDW.Boundary(i).StartCoordX;
        handles.Model(md).Input.BndEnd1{i}=MDW.Boundary(i).EndCoordX;
        handles.Model(md).Input.BndStart2{i}=MDW.Boundary(i).StartCoordY;
        handles.Model(md).Input.BndEnd2{i}=MDW.Boundary(i).EndCoordY;        
    end
    if strcmp(MDW.Boundary(i).SpectrumSpec,'parametric')==1
        handles.Model(md).Input.Parametric{i}=1;
        handles.Model(md).Input.FromFile{i}=0;
        if strcmp(MDW.Boundary(i).SpShapeType,'jonswap')==1
            handles.Model(md).Input.Jonswap{i}=1;
            handles.Model(md).Input.Jonswapval{i}=MDW.Boundary(i).PeakEnhancFac;
        elseif strcmp(MDW.Boundary(i).SpShapeType,'pierson-moskowitz')==1
            handles.Model(md).Input.Pierson{i}=1;
        elseif strcmp(MDW.Boundary(i).SpShapeType,'gauss')==1
            handles.Model(md).Input.Gauss{i}=1;           
            handles.Model(md).Input.Gaussval{i}=MDW.Boundary(i).GaussSpread;
        end
        if strcmp(MDW.Boundary(i).PeriodType,'peak')==1
            handles.Model(md).Input.Peak{i}=1;
            handles.Model(md).Input.Mean{i}=0;
        elseif strcmp(MDW.Boundary(i).PeriodType,'mean')==1
            handles.Model(md).Input.Peak{i}=0;
            handles.Model(md).Input.Mean{i}=1;
        end
        if strcmp(MDW.Boundary(i).DirSpreadType,'power')==1
            handles.Model(md).Input.Cosine{i}=1;
            handles.Model(md).Input.Degrees{i}=0;
        elseif strcmp(MDW.Boundary(i).DirSpreadType,'degrees')==1
            handles.Model(md).Input.Cosine{i}=0;
            handles.Model(md).Input.Degrees{i}=1;
        end
        if size(MDW.Boundary(i).List,2)>0
            handles.Model(md).Input.Uniform{i}=0;
            handles.Model(md).Input.Spacevarying{i}=1;
            ktot = size(MDW.Boundary(i).List,2);
            for k=1:ktot
                handles.Model(md).Input.Sections(k)=['Section ' num2str(k)];
                handles.Model(md).Input.SpacevaryingParam(i).Dist{k}=MDW.Boundary(i).List(k).CondSpecAtDist;
                handles.Model(md).Input.SpacevaryingParam(i).Hs{k}=MDW.Boundary(i).List(k).WaveHeight;
                handles.Model(md).Input.SpacevaryingParam(i).Tp{k}=MDW.Boundary(i).List(k).Period;
                handles.Model(md).Input.SpacevaryingParam(i).Dir{k}=MDW.Boundary(i).List(k).Direction;
                handles.Model(md).Input.SpacevaryingParam(i).Spread{k}=MDW.Boundary(i).List(k).DirSpreading;
            end
        else
            handles.Model(md).Input.Uniform{i}=1;
            handles.Model(md).Input.Spacevarying{i}=0;            
            handles.Model(md).Input.Hs{i}=MDW.Boundary(i).WaveHeight;
            handles.Model(md).Input.Tp{i}=MDW.Boundary(i).Period;
            handles.Model(md).Input.Dir{i}=MDW.Boundary(i).Direction;
            handles.Model(md).Input.Spread{i}=MDW.Boundary(i).DirSpreading;
        end
    else
        handles.Model(md).Input.Parametric{i}=0;
        handles.Model(md).Input.FromFile{i}=1;
        handles.Model(md).Input.BndFile{i}=MDW.Boundary(i).Spectrum;
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

handles.Model(md).Input.Gravity=MDW.Constants.Gravity;
handles.Model(md).Input.Waterdensity=MDW.Constants.WaterDensity;
handles.Model(md).Input.Northwaxis=MDW.Constants.NorthDir;
handles.Model(md).Input.Mindepth=MDW.Constants.MinimumDepth;
handles.Model(md).Input.Nautical=0;
handles.Model(md).Input.Cartesian=0;
handles.Model(md).Input.None=0;
handles.Model(md).Input.Activated=MDW.Processes.WaveSetup;
if strcmp(MDW.Processes.WaveForces,'dissipation') == 1
    handles.Model(md).Input.Waveenergy=1;
    handles.Model(md).Input.Radiation=0;
elseif strcmp(MDW.Processes.WaveForces,'radiation stresses') == 1
    handles.Model(md).Input.Waveenergy=0;
    handles.Model(md).Input.Radiation=1;
end

handles.Model(md).Input.UniformW=1;
handles.Model(md).Input.SpacevaryingW=0;
handles.Model(md).Input.Asbathy=0;
handles.Model(md).Input.Tospecify=0;
handles.Model(md).Input.SpeedW=MDW.General.WindSpeed;
handles.Model(md).Input.DirectionW=MDW.General.WindDir;
handles.Model(md).Input.WindFile='';
handles.Model(md).Input.XoriginW='';
handles.Model(md).Input.YoriginW='';
handles.Model(md).Input.AngleW='';
handles.Model(md).Input.XcellsW='';
handles.Model(md).Input.YcellsW='';
handles.Model(md).Input.XsizeW='';
handles.Model(md).Input.YsizeW='';
handles.Model(md).Input.Generation={'None';'1-st generation';'2-nd generation';'3-rd generation'};
if MDW.Processes.GenModePhys == 1
    handles.Model(md).Input.GenerationIval=2;
elseif MDW.Processes.GenModePhys == 2
    handles.Model(md).Input.GenerationIval=3;
elseif MDW.Processes.GenModePhys == 3
    handles.Model(md).Input.GenerationIval=4;
end
handles.Model(md).Input.Breaking=MDW.Processes.Breaking;
handles.Model(md).Input.Triad=MDW.Processes.Triads;
if strcmp(MDW.Processes.BedFriction,'none') == 1
    handles.Model(md).Input.Friction=0;
else
    handles.Model(md).Input.Friction=1;
end
handles.Model(md).Input.Diffraction=MDW.Processes.Diffraction;
handles.Model(md).Input.Alpha1=MDW.Processes.BreakAlpha;
handles.Model(md).Input.Gamma=MDW.Processes.BreakGamma;
handles.Model(md).Input.Alpha2=MDW.Processes.TriadsAlpha;
handles.Model(md).Input.Beta=MDW.Processes.TriadsBeta;
handles.Model(md).Input.Type={'JONSWAP';'Collins';'Madsen et al.'};
if strcmp(MDW.Processes.BedFriction,'jonswap')==1
    handles.Model(md).Input.Typeval=1;
elseif strcmp(MDW.Processes.BedFriction,'collins')==1
    handles.Model(md).Input.Typeval=2;
elseif strcmp(MDW.Processes.BedFriction,'madsen et al.')==1
    handles.Model(md).Input.Typeval=3;
end
handles.Model(md).Input.Coefficient=MDW.Processes.BedFricCoef;
handles.Model(md).Input.Smoothcoef=MDW.Processes.DiffracCoef;
handles.Model(md).Input.Smoothsteps=MDW.Processes.DiffracSteps;
handles.Model(md).Input.Propagation=MDW.Processes.DiffracProp;

handles.Model(md).Input.Acti1=MDW.Processes.WindGrowth;
if MDW.Processes.WindGrowth == 0
    handles.Model(md).Input.DeActi1=1;
elseif MDW.Processes.WindGrowth == 1
    handles.Model(md).Input.DeActi1=0;
end
handles.Model(md).Input.Acti2=MDW.Processes.WhiteCapping;
if MDW.Processes.WhiteCapping == 0
    handles.Model(md).Input.DeActi2=1;
elseif MDW.Processes.WhiteCapping == 1
    handles.Model(md).Input.DeActi2=0;
end
handles.Model(md).Input.Acti3=MDW.Processes.Quadruplets;
if MDW.Processes.Quadruplets == 0
    handles.Model(md).Input.DeActi3=1;
elseif MDW.Processes.Quadruplets == 1
    handles.Model(md).Input.DeActi3=0;
end
handles.Model(md).Input.Acti4=MDW.Processes.Refraction;
if MDW.Processes.Refraction == 0
    handles.Model(md).Input.DeActi4=1;
elseif MDW.Processes.Refraction == 1
    handles.Model(md).Input.DeActi4=0;
end
handles.Model(md).Input.Acti5=MDW.Processes.FreqShift;
if MDW.Processes.FreqShift == 0
    handles.Model(md).Input.DeActi5=1;
elseif MDW.Processes.FreqShift == 1
    handles.Model(md).Input.DeActi5=0;
end

handles.Model(md).Input.First=1;
handles.Model(md).Input.Third=0;
handles.Model(md).Input.CDD=MDW.Numerics.DirSpaceCDD;
handles.Model(md).Input.CSS=MDW.Numerics.DirSpaceCDD;

handles.Model(md).Input.HSTM01=MDW.Numerics.RChHsTm01;
handles.Model(md).Input.HSchange=MDW.Numerics.RChMeanHs;
handles.Model(md).Input.TM01=MDW.Numerics.RChMeanTm01;
handles.Model(md).Input.PercWet=MDW.Numerics.PercWet;
handles.Model(md).Input.MaxIter=MDW.Numerics.MaxIter;

handles.Model(md).Input.TestOutput=MDW.Output.TestOutputLevel;
handles.Model(md).Input.Debug=0;
handles.Model(md).Input.TimeStepOutput=MDW.Output.COMWriteInterval;
handles.Model(md).Input.Interval=10;
handles.Model(md).Input.Mode={'stationnary';'quasi-stationary';'non-stationnary'};
if strcmp(MDW.General.SimMode,'stationnary') == 1
   handles.Model(md).Input.ModeIval=1;
elseif strcmp(MDW.General.SimMode,'quasi-stationnary') == 1
    handles.Model(md).Input.ModeIval=1;
elseif strcmp(MDW.General.SimMode,'non-stationnary') == 1
    handles.Model(md).Input.ModeIval=1;
    handles.Model(md).Input.TimeStep=MDW.General.TimeStep;
end
handles.Model(md).Input.Hotstart=MDW.Output.UseHotFile;
if strcmp(MDW.General.OnlyInputVerify,'simulation run') == 1
    handles.Model(md).Input.Verify=0;
elseif strcmp(MDW.General.OnlyInputVerify,'input validation only') == 1
    handles.Model(md).Input.Verify=1;
end
handles.Model(md).Input.Verify=0;
handles.Model(md).Input.OutputFlowGrid=MDW.Output.WriteCOM;
handles.Model(md).Input.OutputFlowGridFile='';
for id = 1:itot
    handles.Model(md).Input.Compgrid
    eval(['' num2str(id)])=MDW.Domain(id).Output;
end
handles.Model(md).Input.OutputSpecific=0;
handles.Model(md).Input.Table=MDW.Output.WriteTable;
handles.Model(md).Input.oneDspectra=MDW.Output.WriteSpec1D;
handles.Model(md).Input.twoDspectra=MDW.Output.WriteSpec2D;
handles.Model(md).Input.LocFromFile=1;
handles.Model(md).Input.LocFileName='';
handles.Model(md).Input.LocSpecified=0;
handles.Model(md).Input.Locations='';
handles.Model(md).Input.LocationsIval='';
handles.Model(md).Input.LocXTemp=0;
handles.Model(md).Input.LocYTemp=0;
handles.Model(md).Input.LocX=0;
handles.Model(md).Input.LocY=0;

handles.Model(md).Input.PolFile = MDW.ObstacleFileInformation.PolygonFile;

itot =size(MDW.Obstacle.Name,2)
handles.Model(md).Input.Reflections={'No';'Specular';'Diffuse'};
handles.Model(md).Input.Obstacles=MDW.Obstacle(1:itot).Name;
for i = 1:itot
    if strcmp(MDW.Obstacle(i).Type,'sheet')==1
        handles.Model(md).Input.Sheet{i}=1;
        handles.Model(md).Input.Dam{i}=0;
        handles.Model(md).Input.Transmcoef{i}=MDW.Obstacle(i).TransmCoef;
    elseif strcmp(MDW.Obstacle(i).Type,'dam')==1
        handles.Model(md).Input.Sheet{i}=0;
        handles.Model(md).Input.Dam{i}=1;
        handles.Model(md).Input.Height{i}=MDW.Obstacle(i).Height;
        handles.Model(md).Input.Alpha{i}=MDW.Obstacle(i).Alpha;
        handles.Model(md).Input.Beta{i}=MDW.Obstacle(i).Beta;
    end
    handles.Model(md).Input.Refcoef{i}=MDW.Obstacle(i).ReflecCoef;
end

handles.Model(md).Input.ObstaclesNb(id).Segments='';
handles.Model(md).Input.ObstaclesNb(id).SegmentsIval='';
handles.Model(md).Input.ObstaclesNb(id).Xstart=0;
handles.Model(md).Input.ObstaclesNb(id).Ystart=0;
handles.Model(md).Input.ObstaclesNb(id).Xend=0;
handles.Model(md).Input.ObstaclesNb(id).Yend=0;

