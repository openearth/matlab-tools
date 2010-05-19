function handles=ddb_saveMDW(handles,id)

Wave=handles.Model(md).Input;

ndomains=length(Wave.ComputationalGrids);

MDW.WaveFileInformation.FileVersion = '02.00';

MDW.General.ProjectName  = Wave.ProjectName;
MDW.General.ProjectNr    = Wave.ProjectNumber;
try
    MDW.General.Description1 = Wave.Description{1};
    MDW.General.Description2 = Wave.Description{2};
    MDW.General.Description3 = Wave.Description{3};
end
if Wave.Verify==0
    MDW.General.OnlyInputVerify = 'simulation run';
elseif Wave.Verify==1
    MDW.General.OnlyInputVerify = 'input validation only';
end
MDW.General.SimMode  = Wave.Mode{Wave.ModeIval};
if Wave.ModeIval==3
    MDW.General.TimeStep      = Wave.TimeStep;
end
MDW.General.DirConvention = Wave.Domain(1).Coordsyst;
MDW.General.ReferenceDate = datestr(Wave.ItDate,29);
MDW.General.ObstacleFile  = Wave.PolFile;
MDW.General.TSeriesFile   = Wave.TimeDependentQuantitiesFile;
if ~isempty(MDW.General.TSeriesFile)
    MDW.General.TimePntBlock  = Wave.NumberQuantities;
end
if ~exist('MDW.General.TimePntBlock')
    MDW.General.TimePoint     = Wave.Time;
end
MDW.General.WaterLevel    = Wave.WaterLevel;
MDW.General.XVeloc        = Wave.Xvelocity;
MDW.General.YVeloc        = Wave.Yvelocity;
MDW.General.WindSpeed     = Wave.SpeedW;
MDW.General.WindDir       = Wave.DirectionW;
if Wave.Domain(1).Circle == 1
    MDW.General.DirSpace      = 'circle';
elseif Wave.Domain(1).Sector == 1
    MDW.General.DirSpace      = 'sector';
end
MDW.General.NDir          = Wave.Domain(1).NumberDir;
MDW.General.StartDir      = Wave.Domain(1).StartDir;
MDW.General.EndDir        = Wave.Domain(1).EndDir;
MDW.General.NFreq         = Wave.Domain(1).NumberFreq;
MDW.General.FreqMin       = Wave.Domain(1).LowFreq;
MDW.General.FreqMax       = Wave.Domain(1).HighFreq;

MDW.Constants.Gravity       = Wave.Gravity;
MDW.Constants.WaterDensity  = Wave.Waterdensity;
MDW.Constants.NorthDir      = Wave.Northwaxis;
MDW.Constants.MinimumDepth  = Wave.Mindepth;

MDW.Processes.GenModePhys   = Wave.GenerationIval-1;
MDW.Processes.WaveSetup     = Wave.Activated;
MDW.Processes.Breaking      = Wave.Breaking;
MDW.Processes.BreakAlpha    = Wave.Alpha1;
MDW.Processes.BreakGamma    = Wave.Gamma;
MDW.Processes.Triads        = Wave.Triad;
MDW.Processes.TriadsAlpha   = Wave.Alpha2;
MDW.Processes.TriadsBeta    = Wave.Beta;
if Wave.Friction == 0
    MDW.Processes.BedFriction   = 'none';
elseif Wave.Friction == 1
    if Wave.Typeval == 1
        MDW.Processes.BedFriction   = 'jonswap';
    elseif Wave.Typeval == 2
        MDW.Processes.BedFriction   = 'collins';
    elseif Wave.Typeval == 3
        MDW.Processes.BedFriction   = 'madsen et al.';
    end
    MDW.Processes.BedFricCoef    = Wave.Coefficient;
end
MDW.Processes.Diffraction    = Wave.Diffraction;
MDW.Processes.DiffracCoef    = Wave.Smoothcoef;
MDW.Processes.DiffracSteps   = Wave.Smoothsteps;
MDW.Processes.DiffracProp    = Wave.Propagation;
MDW.Processes.WindGrowth     = Wave.Acti1;
MDW.Processes.WhiteCapping   = Wave.Acti2;
MDW.Processes.Quadruplets    = Wave.Acti3;
MDW.Processes.Refraction     = Wave.Acti4;
MDW.Processes.FreqShift      = Wave.Acti5;
if Wave.Waveenergy==1
    MDW.Processes.WaveForces = 'dissipation';
elseif Wave.Radiation==1
    MDW.Processes.WaveForces = 'radiation stresses';
end

MDW.Numerics.DirSpaceCDD   = Wave.CDD;
MDW.Numerics.FreqSpaceCSS  = Wave.CSS;
MDW.Numerics.RChHsTm01     = Wave.HSTM01;
MDW.Numerics.RChMeanHs     = Wave.HSchange;
MDW.Numerics.RChMeanTm01   = Wave.TM01;
MDW.Numerics.PercWet       = Wave.PercWet;
MDW.Numerics.MaxIter       = Wave.MaxIter;

MDW.Output.TestOutputLevel  = Wave.TestOutput;
% MDW.Output.TraceCalls       = Wave.
MDW.Output.UseHotFile       = Wave.Hotstart;
% MDW.Output.MapWriteInterval = Wave.
MDW.Output.WriteCOM         = Wave.OutputFlowGrid;
MDW.Output.COMWriteInterval = Wave.TimeStepOutput;
% MDW.Output.AppendCOM        = Wave.
% MDW.Output.LocationFile     = Wave.LocFileName;
MDW.Output.WriteTable       = Wave.Table;
MDW.Output.WriteSpec1D      = Wave.oneDspectra;
MDW.Output.WriteSpec2D      = Wave.twoDspectra;

for i=1:ndomains
    MDW.Domain(i).Grid           = Wave.Domain(i).CompGrid;
    MDW.Domain(i).BedLevelGrid   = Wave.Domain(i).GrdFile;
    MDW.Domain(i).BedLevel       = Wave.Domain(i).DepFile;
    MDW.Domain(i).DirSpace       = Wave.Domain(i).Circle;
    MDW.Domain(i).NDir           = Wave.Domain(i).NumberDir;
    MDW.Domain(i).StartDir       = Wave.Domain(i).StartDir;
    MDW.Domain(i).EndDir         = Wave.Domain(i).EndDir;
    MDW.Domain(i).NFreq          = Wave.Domain(i).NumberFreq;
    MDW.Domain(i).FreqMin        = Wave.Domain(i).LowFreq;
    MDW.Domain(i).FreqMax        = Wave.Domain(i).HighFreq;
    MDW.Domain(i).NestedInDomain = Wave.Domain(i).NestedValue;
    MDW.Domain(i).FlowBedLevel   = Wave.FlowBedLevel;
    MDW.Domain(i).FlowWaterLevel = Wave.FlowWaterLevel;
    MDW.Domain(i).FlowVelocity   = Wave.FlowVelocity;
    MDW.Domain(i).FlowWind       = Wave.FlowWind;
    MDW.Domain(i).Output         = eval(['Wave.Compgrid' num2str(i)]);
end

for i=1:size(Wave.Boundaries,2)
    MDW.Boundary(i).Name           = Wave.BndName{i};
    if cell2mat(Wave.BndDefbyval{i})==1
        MDW.Boundary(i).Definition = 'orientation';
    elseif cell2mat(Wave.BndDefbyval{i})==2
        MDW.Boundary(i).Definition = 'grid-coordinates';
    elseif cell2mat(Wave.BndDefbyval{i})==3
        MDW.Boundary(i).Definition = 'xy-coordinates';
    end
    MDW.Boundary(i).Orientation    = Wave.BndOrient{cell2mat(Wave.BndOrientval{i})};
%     MDW.Boundary(i).DistanceDir    = 
    if cell2mat(Wave.BndDefbyval{i})==2
        MDW.Boundary(i).StartCoordM    = Wave.BndStart1{i};
        MDW.Boundary(i).EndCoordM      = Wave.BndEnd1{i};
        MDW.Boundary(i).StartCoordN    = Wave.BndStart2{i};
        MDW.Boundary(i).EndCoordN      = Wave.BndEnd2{i};
    elseif cell2mat(Wave.BndDefbyval{i})==3
        MDW.Boundary(i).StartCoordX    = Wave.BndStart1{i};
        MDW.Boundary(i).EndCoordX      = Wave.BndEnd1{i};
        MDW.Boundary(i).StartCoordY    = Wave.BndStart2{i};
        MDW.Boundary(i).EndCoordY      = Wave.BndEnd2{i};
    end
    if cell2mat(Wave.Parametric{i})==1
        MDW.Boundary(i).SpectrumSpec      = 'parametric';
        if cell2mat(Wave.Jonswap{i})==1
            MDW.Boundary(i).SpShapeType   = 'jonswap';
            MDW.Boundary(i).PeakEnhancFac = Wave.Jonswapval{i};
        elseif cell2mat(Wave.Pierson{i})==1
            MDW.Boundary(i).SpShapeType   = 'pierson-moskowitz';
        elseif cell2mat(Wave.Gauss{i})==1
            MDW.Boundary(i).SpShapeType   = 'gauss';
            MDW.Boundary(i).GaussSpread   = Wave.Gaussval{i};
        end 
        if cell2mat(Wave.Peak{i})==1
            MDW.Boundary(i).PeriodType    = 'peak';
        elseif cell2mat(Wave.Mean{i})==1
            MDW.Boundary(i).PeriodType    = 'mean';
        end
        if cell2mat(Wave.Cosine{i})==1
            MDW.Boundary(i).DirSpreadType = 'power';
        elseif cell2mat(Wave.Degrees{i})==1
            MDW.Boundary(i).DirSpreadType = 'degrees';
        end
        if cell2mat(Wave.Spacevarying{i})==1
            for k=1:size(Wave.Sections,2)
                MDW.Boundary(i).List(k).CondSpecAtDist = Wave.SpacevaryingParam(i).Dist{k};
                MDW.Boundary(i).List(k).WaveHeight     = Wave.SpacevaryingParam(i).Hs{k};
                MDW.Boundary(i).List(k).Period         = Wave.SpacevaryingParam(i).Tp{k};
                MDW.Boundary(i).List(k).Direction      = Wave.SpacevaryingParam(i).Dir{k};
                MDW.Boundary(i).List(k).DirSpreading   = Wave.SpacevaryingParam(i).Spread{k};
            end
        else
            MDW.Boundary(i).WaveHeight     = Wave.Hs{i};
            MDW.Boundary(i).Period         = Wave.Tp{i};
            MDW.Boundary(i).Direction      = Wave.Dir{i};
            MDW.Boundary(i).DirSpreading   = Wave.Spread{i};            
        end
    else
        MDW.Boundary(i).SpectrumSpec      = 'from file';
        MDW.Boundary(i).Spectrum          = Wave.BndFile{i};
    end
end

MDW.ObstacleFileInformation.PolygonFile = Wave.PolFile;

for i = 1:size(Wave.Obstacles,2)
    MDW.Obstacle(i).Name         = Wave.Obstacles{i};
    if Wave.Sheet(i)==1
        MDW.Obstacle(i).Type         = 'sheet';
        MDW.Obstacle(i).TransmCoef   = Wave.Transmcoef(i);
    elseif Wave.Dam(i)==1
        MDW.Obstacle(i).Type         = 'dam';
        MDW.Obstacle(i).Height       = Wave.Height(i);
        MDW.Obstacle(i).Alpha        = Wave.Alpha(i);
        MDW.Obstacle(i).Beta         = Wave.Beta(i);
    end
    MDW.Obstacle(i).Reflections  = Wave.Reflections{Wave.Reflectionsval(i)};
    if Wave.Reflectionsval(i)>1
        MDW.Obstacle(i).ReflecCoef   = Wave.Refcoef(i);
    end
end

%%
fname=[handles.WorkingDirectory filesep handles.Model(md).Input(id).Runid '.mdw'];

fid=fopen(fname,'w');

Names = fieldnames(MDW);

for i=1:length(Names)
    name1=Names{i};
    for k=1:length(MDW.(name1))
        fprintf(fid,'%s\n',['[' name1 ']']);
        Names2=fieldnames(MDW.(name1)(k));
        for j=1:length(Names2)
            name2=Names2{j};
            if ~isempty(MDW.(name1)(k).(name2))
                if strcmp(name2,'List')==1
                    Names3=fieldnames(MDW.(name1)(k).(name2));
                    for p=1:size(MDW.(name1)(k).(name2),2)
                        for m=1:length(Names3)
                            name3=Names3{m};
                            str=['   ' name3 ' = ' num2str(cell2mat(MDW.(name1)(k).(name2)(p).(name3){:}))];
                            fprintf(fid,'%s\n',str);
                        end
                    end
                elseif ~iscell(MDW.(name1)(k).(name2))
                    str=['   ' name2 ' = ' num2str(MDW.(name1)(k).(name2))];
                    fprintf(fid,'%s\n',str);
                else
                    try
                        str=['   ' name2 ' = ' num2str(cell2mat(MDW.(name1)(k).(name2)))];
                    catch
                        str=['   ' name2 ' = ' num2str(cell2mat(MDW.(name1)(k).(name2){:}))];
                    end
                    fprintf(fid,'%s\n',str);
                end
            end
        end
    end
end
fclose(fid);


