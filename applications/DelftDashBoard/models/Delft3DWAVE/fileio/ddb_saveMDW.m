function handles=ddb_saveMDW(handles,id)

Wave=handles.Model(md).Input;

ndomains=length(Wave.ComputationalGrids);

MDW.WaveFileInformation.FileVersion.value = '02.00';

%% General
MDW.General.ProjectName.value  = Wave.ProjectName;
MDW.General.ProjectNr.value    = Wave.ProjectNumber;
try
    MDW.General.Description1.value = Wave.Description{1};
    MDW.General.Description2.value = Wave.Description{2};
    MDW.General.Description3.value = Wave.Description{3};
end
if Wave.Verify
    MDW.General.OnlyInputVerify.value = 'input validation only';
else
    MDW.General.OnlyInputVerify.value = 'simulation run';
end
MDW.General.SimMode.value  = Wave.mode;
switch lower(Wave.mode)
    case{'non-stationary'}
        MDW.General.TimeStep.value      = Wave.TimeStep;
end

MDW.General.DirConvention.value = Wave.Domain(1).Coordsyst;
MDW.General.ReferenceDate.value = datestr(Wave.ItDate,29);
MDW.General.ObstacleFile.value  = Wave.PolFile;
MDW.General.TSeriesFile.value   = Wave.TimeDependentQuantitiesFile;
if ~isempty(MDW.General.TSeriesFile)
    MDW.General.TimePntBlock.value  = Wave.NumberQuantities;
end
if ~exist('MDW.General.TimePntBlock')
    MDW.General.TimePoint.value     = Wave.Time;
    MDW.General.TimePoint.type      = 'real';
end
MDW.General.WaterLevel.value    = Wave.WaterLevel;
MDW.General.WaterLevel.type     = 'real';
MDW.General.XVeloc.value        = Wave.Xvelocity;
MDW.General.XVeloc.type         = 'real';
MDW.General.YVeloc.value        = Wave.Yvelocity;
MDW.General.YVeloc.type         = 'real';
MDW.General.WindSpeed.value     = Wave.SpeedW;
MDW.General.WindSpeed.type      = 'real';
MDW.General.WindDir.value       = Wave.DirectionW;
MDW.General.WindDir.type        = 'real';
if Wave.Domain(1).Circle == 1
    MDW.General.DirSpace.value      = 'circle';
elseif Wave.Domain(1).Sector == 1
    MDW.General.DirSpace.value      = 'sector';
end
MDW.General.NDir.value          = Wave.Domain(1).NumberDir;
MDW.General.NDir.type           = 'integer';
MDW.General.StartDir.value      = Wave.Domain(1).StartDir;
MDW.General.StartDir.type       = 'real';
MDW.General.EndDir.value        = Wave.Domain(1).EndDir;
MDW.General.EndDir.type         = 'real';
MDW.General.NFreq.value         = Wave.Domain(1).NumberFreq;
MDW.General.NFreq.type          = 'integer';
MDW.General.FreqMin.value       = Wave.Domain(1).LowFreq;
MDW.General.FreqMin.type        = 'real';
MDW.General.FreqMax.value       = Wave.Domain(1).HighFreq;
MDW.General.FreqMax.type        = 'real';

%% Constants
MDW.Constants.Gravity.value       = Wave.Gravity;
MDW.Constants.Gravity.type        = 'real';
MDW.Constants.WaterDensity.value  = Wave.Waterdensity;
MDW.Constants.WaterDensity.type   = 'real';
MDW.Constants.NorthDir.value      = Wave.Northwaxis;
MDW.Constants.NorthDir.type       = 'real';
MDW.Constants.MinimumDepth.value  = Wave.Mindepth;
MDW.Constants.MinimumDepth.type   = 'real';

%% Processes
MDW.Processes.GenModePhys.value   = Wave.GenerationIval-1;
MDW.Processes.GenModePhys.type    = 'integer';
MDW.Processes.WaveSetup.value     = Wave.Activated;
MDW.Processes.WaveSetup.type      = 'boolean';
MDW.Processes.Breaking.value      = Wave.Breaking;
MDW.Processes.Breaking.type       = 'boolean';
MDW.Processes.BreakAlpha.value    = Wave.Alpha1;
MDW.Processes.BreakAlpha.type     = 'real';
MDW.Processes.BreakGamma.value    = Wave.Gamma;
MDW.Processes.BreakGamma.type     = 'real';
MDW.Processes.Triads.value        = Wave.Triad;
MDW.Processes.Triads.type         = 'boolean';
MDW.Processes.TriadsAlpha.value   = Wave.Alpha2;
MDW.Processes.TriadsAlpha.type    = 'real';
MDW.Processes.TriadsBeta.value    = Wave.Beta;
MDW.Processes.TriadsBeta.type     = 'real';

switch Wave.Friction
    case 0
        MDW.Processes.BedFriction.value   = 'none';
    otherwise
        if Wave.Typeval == 1
            MDW.Processes.BedFriction.value   = 'jonswap';
        elseif Wave.Typeval == 2
            MDW.Processes.BedFriction.value   = 'collins';
        elseif Wave.Typeval == 3
            MDW.Processes.BedFriction.value   = 'madsen et al.';
        end
        MDW.Processes.BedFricCoef.value    = Wave.Coefficient;
        MDW.Processes.BedFricCoef.type     = 'real';
end

MDW.Processes.Diffraction.value    = Wave.Diffraction;
MDW.Processes.Diffraction.type     = 'boolean';
MDW.Processes.DiffracCoef.value    = Wave.Smoothcoef;
MDW.Processes.DiffracCoef.value    = Wave.Smoothcoef;
MDW.Processes.DiffracSteps.value   = Wave.Smoothsteps;
MDW.Processes.DiffracSteps.type    = 'integer';
MDW.Processes.DiffracProp.value    = Wave.Propagation;
MDW.Processes.DiffracProp.value    = Wave.Propagation;
MDW.Processes.WindGrowth.value     = Wave.Acti1;
MDW.Processes.WindGrowth.type      = 'boolean';
MDW.Processes.WhiteCapping.value   = Wave.Acti2;
MDW.Processes.Quadruplets.value    = Wave.Acti3;
MDW.Processes.Quadruplets.type     = 'boolean';
MDW.Processes.Refraction.value     = Wave.Acti4;
MDW.Processes.Refraction.type      = 'boolean';
MDW.Processes.FreqShift.value      = Wave.Acti5;
MDW.Processes.FreqShift.type       = 'boolean';
if Wave.Waveenergy==1
    MDW.Processes.WaveForces.value = 'dissipation';
elseif Wave.Radiation==1
    MDW.Processes.WaveForces.value = 'radiation stresses';
end

%% Numerics
MDW.Numerics.DirSpaceCDD.value   = Wave.CDD;
MDW.Numerics.DirSpaceCDD.type    = 'real';
MDW.Numerics.FreqSpaceCSS.value  = Wave.CSS;
MDW.Numerics.FreqSpaceCSS.type   = 'real';
MDW.Numerics.RChHsTm01.value     = Wave.HSTM01;
MDW.Numerics.RChHsTm01.type      = 'real';
MDW.Numerics.RChMeanHs.value     = Wave.HSchange;
MDW.Numerics.RChMeanHs.type      = 'real';
MDW.Numerics.RChMeanTm01.value   = Wave.TM01;
MDW.Numerics.RChMeanTm01.type    = 'real';
MDW.Numerics.PercWet.value       = Wave.PercWet;
MDW.Numerics.PercWet.type        = 'real';
MDW.Numerics.MaxIter.value       = Wave.MaxIter;
MDW.Numerics.MaxIter.type        = 'integer';

%% Output
MDW.Output.TestOutputLevel.value  = Wave.TestOutput;
MDW.Output.TestOutputLevel.type   = 'integer';
MDW.Output.TraceCalls.value       = 0;
MDW.Output.TraceCalls.type        = 'boolean';
MDW.Output.UseHotFile.value       = Wave.Hotstart;
MDW.Output.UseHotFile.type        = 'boolean';
MDW.Output.MapWriteInterval.value = 60.0;
MDW.Output.MapWriteInterval.type  = 'real';
MDW.Output.WriteCOM.value         = Wave.OutputFlowGrid;
MDW.Output.WriteCOM.type          = 'boolean';
MDW.Output.COMWriteInterval.value = Wave.TimeStepOutput;
MDW.Output.COMWriteInterval.type  = 'real';
MDW.Output.Int2KeepHotfile.value  = 720;
MDW.Output.Int2KeepHotfile.type   = 'real';
MDW.Output.AppendCOM.value        = 0;
MDW.Output.AppendCOM.type         = 'boolean';
MDW.Output.LocationFile.value     = Wave.LocFileName;
MDW.Output.WriteTable.value       = Wave.Table;
MDW.Output.WriteTable.type         = 'boolean';
MDW.Output.WriteSpec1D.value      = Wave.oneDspectra;
MDW.Output.WriteSpec1D.type         = 'boolean';
MDW.Output.WriteSpec2D.value      = Wave.twoDspectra;
MDW.Output.WriteSpec2D.type         = 'boolean';

%% Domains
for i=1:ndomains
    MDW.Domain(i).Grid.value           = Wave.Domain(i).CompGrid;
    MDW.Domain(i).BedLevelGrid.value   = Wave.Domain(i).GrdFile;
    MDW.Domain(i).BedLevel.value       = Wave.Domain(i).DepFile;
    MDW.Domain(i).DirSpace.value       = Wave.Domain(i).Circle;
    MDW.Domain(i).NDir.value           = Wave.Domain(i).NumberDir;
    MDW.Domain(i).NDir.type            = 'integer';
    MDW.Domain(i).StartDir.value       = Wave.Domain(i).StartDir;
    MDW.Domain(i).StartDir.type        = 'real';
    MDW.Domain(i).EndDir.value         = Wave.Domain(i).EndDir;
    MDW.Domain(i).EndDir.type          = 'real';
    MDW.Domain(i).NFreq.value          = Wave.Domain(i).NumberFreq;
    MDW.Domain(i).NFreq.type           = 'integer';
    MDW.Domain(i).FreqMin.value        = Wave.Domain(i).LowFreq;
    MDW.Domain(i).FreqMin.type         = 'real';
    MDW.Domain(i).FreqMax.value        = Wave.Domain(i).HighFreq;
    MDW.Domain(i).FreqMax.type         = 'real';
    MDW.Domain(i).NestedInDomain.value = Wave.Domain(i).NestedValue;
    MDW.Domain(i).NestedInDomain.type  = 'integer';
    MDW.Domain(i).FlowBedLevel.value   = Wave.FlowBedLevel;
    MDW.Domain(i).FlowBedLevel.type    = 'integer';
    MDW.Domain(i).FlowWaterLevel.value = Wave.FlowWaterLevel;
    MDW.Domain(i).FlowWaterLevel.type  = 'integer';
    MDW.Domain(i).FlowVelocity.value   = Wave.FlowVelocity;
    MDW.Domain(i).FlowVelocity.type    = 'integer';
    MDW.Domain(i).FlowWind.value       = Wave.FlowWind;
    MDW.Domain(i).FlowWind.type        = 'integer';
    MDW.Domain(i).Output.value         = eval(['Wave.Compgrid' num2str(i)]);
end

%% Boundaries
for i=1:Wave.nrBoundaries
    
    MDW.Boundary(i).Name.value           = Wave.boundaries(i).name;
    MDW.Boundary(i).Definition.value     = Wave.boundaries(i).definition;
    
    switch lower(Wave.boundaries(i).definition)
        case{'orientation'}
            MDW.Boundary(i).Orientation.value    = Wave.boundaries(i).orientation;
        case{'grid-coordinates'}
            MDW.Boundary(i).StartCoordM.value    = Wave.boundaries(i).startCoordM;
            MDW.Boundary(i).StartCoordM.type     = 'integer';
            MDW.Boundary(i).EndCoordM.value      = Wave.boundaries(i).endCoordM;
            MDW.Boundary(i).EndCoordM.type       = 'integer';
            MDW.Boundary(i).StartCoordN.value    = Wave.boundaries(i).startCoordN;
            MDW.Boundary(i).StartCoordN.type     = 'integer';
            MDW.Boundary(i).EndCoordN.value      = Wave.boundaries(i).endCoordN;
            MDW.Boundary(i).EndCoordN.type       = 'integer';
        case{'xy-coordinates'}
            MDW.Boundary(i).StartCoordX.value    = Wave.boundaries(i).startCoordX;
            MDW.Boundary(i).StartCoordX.type     = 'real';
            MDW.Boundary(i).EndCoordX.value      = Wave.boundaries(i).endCoordX;
            MDW.Boundary(i).EndCoordX.type       = 'real';
            MDW.Boundary(i).StartCoordY.value    = Wave.boundaries(i).startCoordY;
            MDW.Boundary(i).StartCoordY.type     = 'real';
            MDW.Boundary(i).EndCoordY.value      = Wave.boundaries(i).endCoordY;
            MDW.Boundary(i).EndCoordY.type       = 'real';
    end
    
    switch lower(Wave.boundaries(i).spectrumSpec)
        case{'parametric'}
            MDW.Boundary(i).SpShapeType.value   = Wave.boundaries(i).spShapeType;
            switch lower(Wave.boundaries(i).spShapeType)
                case{'jonswap'}
                    MDW.Boundary(i).PeakEnhancFac.value = Wave.boundaries(i).peakEnhancFac;
                    MDW.Boundary(i).PeakEnhancFac.type  = 'real';
                case{'pierson-moskowitz'}
                case{'gauss'}
                    MDW.Boundary(i).GaussSpread.value = Wave.boundaries(i).gaussSpread;
                    MDW.Boundary(i).GaussSpread.type  = 'real';
            end
            MDW.Boundary(i).PeriodType.value    = Wave.boundaries(i).periodType;
            MDW.Boundary(i).DirSpreadType.value = Wave.boundaries(i).dirSpreadType;
            switch lower(Wave.boundaries(i).alongBoundary)
                case{'uniform'}
                    MDW.Boundary(i).WaveHeight.value     = Wave.boundaries(i).waveHeight;
                    MDW.Boundary(i).WaveHeight.type      = 'real';
                    MDW.Boundary(i).Period.value         = Wave.boundaries(i).period;
                    MDW.Boundary(i).Period.type          = 'real';
                    MDW.Boundary(i).Direction.value      = Wave.boundaries(i).direction;
                    MDW.Boundary(i).Direction.type       = 'real';
                    MDW.Boundary(i).DirSpreading.value   = Wave.boundaries(i).dirSpreading;
                    MDW.Boundary(i).DirSpreading.type    = 'real';
                otherwise
                    %                                 for k=1:size(Wave.Sections,2)
                    %                 MDW.Boundary(i).List(k).CondSpecAtDist = Wave.SpacevaryingParam(i).Dist{k};
                    %                 MDW.Boundary(i).List(k).WaveHeight     = Wave.SpacevaryingParam(i).Hs{k};
                    %                 MDW.Boundary(i).List(k).Period         = Wave.SpacevaryingParam(i).Tp{k};
                    %                 MDW.Boundary(i).List(k).Direction      = Wave.SpacevaryingParam(i).Dir{k};
                    %                 MDW.Boundary(i).List(k).DirSpreading   = Wave.SpacevaryingParam(i).Spread{k};
                    %             end
            end
            
        otherwise
            MDW.Boundary(i).SpectrumSpec.value      = 'from file';
            MDW.Boundary(i).Spectrum.value          = Wave.boundaries(i).spectrumFile;
    end
end

% MDW.ObstacleFileInformation.PolygonFile = Wave.PolFile;
% 
% for i = 1:size(Wave.Obstacles,2)
%     MDW.Obstacle(i).Name         = Wave.Obstacles{i};
%     if Wave.Sheet(i)==1
%         MDW.Obstacle(i).Type         = 'sheet';
%         MDW.Obstacle(i).TransmCoef   = Wave.Transmcoef(i);
%     elseif Wave.Dam(i)==1
%         MDW.Obstacle(i).Type         = 'dam';
%         MDW.Obstacle(i).Height       = Wave.Height(i);
%         MDW.Obstacle(i).Alpha        = Wave.Alpha(i);
%         MDW.Obstacle(i).Beta         = Wave.Beta(i);
%     end
%     MDW.Obstacle(i).Reflections  = Wave.Reflections{Wave.Reflectionsval(i)};
%     if Wave.Reflectionsval(i)>1
%         MDW.Obstacle(i).ReflecCoef   = Wave.Refcoef(i);
%     end
% end

fname=[handles.Model(md).Input(id).Runid '.mdw'];

ddb_saveDelft3D_keyWordFile(fname, MDW);

%%

% fid=fopen(fname,'w');
% 
% Names = fieldnames(MDW);
% 
% for i=1:length(Names)
%     name1=Names{i};
%     for k=1:length(MDW.(name1))
%         fprintf(fid,'%s\n',['[' name1 ']']);
%         Names2=fieldnames(MDW.(name1)(k));
%         for j=1:length(Names2)
%             name2=Names2{j};
%             if ~isempty(MDW.(name1)(k).(name2))
%                 if strcmp(name2,'List')==1
%                     Names3=fieldnames(MDW.(name1)(k).(name2));
%                     for p=1:size(MDW.(name1)(k).(name2),2)
%                         for m=1:length(Names3)
%                             name3=Names3{m};
%                             str=['   ' name3 ' = ' num2str(cell2mat(MDW.(name1)(k).(name2)(p).(name3){:}))];
%                             fprintf(fid,'%s\n',str);
%                         end
%                     end
%                 elseif ~iscell(MDW.(name1)(k).(name2))
%                     str=['   ' name2 ' = ' num2str(MDW.(name1)(k).(name2))];
%                     fprintf(fid,'%s\n',str);
%                 else
%                     try
%                         str=['   ' name2 ' = ' num2str(cell2mat(MDW.(name1)(k).(name2)))];
%                     catch
%                         str=['   ' name2 ' = ' num2str(cell2mat(MDW.(name1)(k).(name2){:}))];
%                     end
%                     fprintf(fid,'%s\n',str);
%                 end
%             end
%         end
%     end
% end
% fclose(fid);


