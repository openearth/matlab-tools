function handles=ddb_saveMDW(handles,id)

wave=handles.Model(md).Input;

ndomains=length(Wave.gridnames);

MDW.WaveFileInformation.FileVersion.value = '02.00';

%% General
MDW.General.ProjectName.value  = wave.projectname;
MDW.General.ProjectNr.value    = wave.projectnumber;
try
    MDW.General.Description1.value = wave.description{1};
    MDW.General.Description2.value = wave.description{2};
    MDW.General.Description3.value = wave.description{3};
end
if wave.Verify
    MDW.General.OnlyInputVerify.value = 'input validation only';
else
    MDW.General.OnlyInputVerify.value = 'simulation run';
end
MDW.General.SimMode.value  = wave.simmode;
switch lower(wave.simmodemode)
    case{'non-stationary'}
        MDW.General.TimeStep.value      = wave.timestep;
end

MDW.General.DirConvention.value = wave.domain(1).coordsyst;
MDW.General.ReferenceDate.value = datestr(wave.referencedate,29);
if wave.nrobstacles>0
    MDW.General.ObstacleFile.value  = wave.obstaclefile;
end
if ~isempty(wave.tseriesfile)
    MDW.General.TSeriesFile.value   = wave.tseriesfile;
    if ~isempty(wave.timepntblock)
        MDW.General.TimePntBlock.value  = wave.timepntblock;
        MDW.General.WindSpeed.type      = 'integer';
    end
end
if isempty(wave.timepntblock) && ~isempty(wave.timepoint)
    MDW.General.TimePoint.value     = wave.timepoint;
    MDW.General.TimePoint.type      = 'real';
end
MDW.General.WaterLevel.value    = wave.waterlevel;
MDW.General.WaterLevel.type     = 'real';
MDW.General.XVeloc.value        = wave.xveloc;
MDW.General.XVeloc.type         = 'real';
MDW.General.YVeloc.value        = wave.yveloc;
MDW.General.YVeloc.type         = 'real';
MDW.General.WindSpeed.value     = wave.windspeed;
MDW.General.WindSpeed.type      = 'real';
MDW.General.WindDir.value       = wave.winddir;
MDW.General.WindDir.type        = 'real';
MDW.General.DirSpace.value      = wave.dirspace;
MDW.General.NDir.value          = wave.domain(1).ndir;
MDW.General.NDir.type           = 'integer';
MDW.General.StartDir.value      = wave.domain(1).startdir;
MDW.General.StartDir.type       = 'real';
MDW.General.EndDir.value        = wave.domain(1).enddir;
MDW.General.EndDir.type         = 'real';
MDW.General.NFreq.value         = wave.domain(1).nfreq;
MDW.General.NFreq.type          = 'integer';
MDW.General.FreqMin.value       = wave.domain(1).freqmin;
MDW.General.FreqMin.type        = 'real';
MDW.General.FreqMax.value       = wave.domain(1).freqmax;
MDW.General.FreqMax.type        = 'real';
if ~isempty(wave.hotfileid)
    MDW.General.HotFileID.value       = wave.hotfileid;
end
if ~isempty(wave.meteofile)
    MDW.General.Meteofile.value       = wave.meteofile;
end

%% Constants
MDW.Constants.Gravity.value       = wave.gravity;
MDW.Constants.Gravity.type        = 'real';
MDW.Constants.WaterDensity.value  = wave.waterdensity;
MDW.Constants.WaterDensity.type   = 'real';
MDW.Constants.NorthDir.value      = wave.northdir;
MDW.Constants.NorthDir.type       = 'real';
MDW.Constants.MinimumDepth.value  = wave.minimumdepth;
MDW.Constants.MinimumDepth.type   = 'real';

%% Processes
MDW.Processes.GenModePhys.value   = wave.genmodephys;
MDW.Processes.GenModePhys.type    = 'integer';
MDW.Processes.WaveSetup.value     = wave.wavesetup;
MDW.Processes.WaveSetup.type      = 'boolean';
MDW.Processes.Breaking.value      = wave.breaking;
MDW.Processes.Breaking.type       = 'boolean';
MDW.Processes.BreakAlpha.value    = wave.breakalpha;
MDW.Processes.BreakAlpha.type     = 'real';
MDW.Processes.BreakGamma.value    = wave.breakgamma;
MDW.Processes.BreakGamma.type     = 'real';
MDW.Processes.Triads.value        = wave.triads;
MDW.Processes.Triads.type         = 'boolean';
MDW.Processes.TriadsAlpha.value   = wave.triadsalpha;
MDW.Processes.TriadsAlpha.type    = 'real';
MDW.Processes.TriadsBeta.value    = wave.triadsbeta;
MDW.Processes.TriadsBeta.type     = 'real';

MDW.Processes.BedFriction.value   = wave.bedfriction;
switch wave.bedfriction
    case{'jonswap'}
        MDW.Processes.BedFricCoef.value    = wave.input.bedfriccoefjonswap;
        MDW.Processes.BedFricCoef.type     = 'real';
    case{'collins'}
        MDW.Processes.BedFricCoef.value    = wave.input.bedfriccoefcollins;
        MDW.Processes.BedFricCoef.type     = 'real';
    case{'madsen'}
        MDW.Processes.BedFricCoef.value    = wave.input.bedfriccoefmadsen;
        MDW.Processes.BedFricCoef.type     = 'real';
end

MDW.Processes.Diffraction.value    = wave.diffraction;
MDW.Processes.Diffraction.type     = 'boolean';
if wave.diffraction
    MDW.Processes.DiffracCoef.value    = wave.diffractioncoef;
    MDW.Processes.DiffracCoef.type     = 'real';
    MDW.Processes.DiffracSteps.value   = wave.diffracsteps;
    MDW.Processes.DiffracSteps.type    = 'integer';
    MDW.Processes.DiffracProp.value    = wave.diffracprop;
    MDW.Processes.DiffracProp.type     = 'boolean';
end
MDW.Processes.WindGrowth.value     = wave.windgrowth;
MDW.Processes.WindGrowth.type      = 'boolean';
MDW.Processes.WhiteCapping.value   = wave.whitecapping;
MDW.Processes.WhiteCapping.type    = 'boolean';
MDW.Processes.Quadruplets.value    = wave.quadruplets;
MDW.Processes.Quadruplets.type     = 'boolean';
MDW.Processes.Refraction.value     = wave.refraction;
MDW.Processes.Refraction.type      = 'boolean';
MDW.Processes.FreqShift.value      = wave.freqshift;
MDW.Processes.FreqShift.type       = 'boolean';
MDW.Processes.WaveForces.value     = wave.waveforces;

%% Numerics
MDW.Numerics.DirSpaceCDD.value   = wave.dirspacecdd;
MDW.Numerics.DirSpaceCDD.type    = 'real';
MDW.Numerics.FreqSpaceCSS.value  = wave.freqspacecss;
MDW.Numerics.FreqSpaceCSS.type   = 'real';
MDW.Numerics.RChHsTm01.value     = wave.rchhstm01;
MDW.Numerics.RChHsTm01.type      = 'real';
MDW.Numerics.RChMeanHs.value     = wave.rchmeanhse;
MDW.Numerics.RChMeanHs.type      = 'real';
MDW.Numerics.RChMeanTm01.value   = wave.rchmeantm01;
MDW.Numerics.RChMeanTm01.type    = 'real';
MDW.Numerics.PercWet.value       = wave.percwet;
MDW.Numerics.PercWet.type        = 'real';
MDW.Numerics.MaxIter.value       = wave.maxiter;
MDW.Numerics.MaxIter.type        = 'integer';

%% Output
MDW.Output.TestOutputLevel.value  = wave.testoutputlevel;
MDW.Output.TestOutputLevel.type   = 'integer';
MDW.Output.TraceCalls.value       = wave.tracecalls;
MDW.Output.TraceCalls.type        = 'boolean';
MDW.Output.UseHotFile.value       = wave.usehotfile;
MDW.Output.UseHotFile.type        = 'boolean';
MDW.Output.MapWriteInterval.value = wave.mapwriteinterval;
MDW.Output.MapWriteInterval.type  = 'real';
MDW.Output.WriteCOM.value         = wave.writecom;
MDW.Output.WriteCOM.type          = 'boolean';
MDW.Output.COMWriteInterval.value = wave.comwriteinterval;
MDW.Output.COMWriteInterval.type  = 'real';
MDW.Output.Int2KeepHotfile.value  = wave.int2keephotfile;
MDW.Output.Int2KeepHotfile.type   = 'real';
MDW.Output.AppendCOM.value        = wave.appendcom;
MDW.Output.AppendCOM.type         = 'boolean';
for ii=1:length(wave.locationfile)
    MDW.Output.LocationFile(ii).value     = wave.locationfile{ii};
end
MDW.Output.WriteTable.value       = wave.writetable;
MDW.Output.WriteTable.type         = 'boolean';
MDW.Output.WriteSpec1D.value      = wave.writespec1d;
MDW.Output.WriteSpec1D.type         = 'boolean';
MDW.Output.WriteSpec2D.value      = wave.writespec2d;
MDW.Output.WriteSpec2D.type         = 'boolean';

%% Domains
for i=1:ndomains
    MDW.Domain(i).Grid.value           = wave.domains(i).grid;
    MDW.Domain(i).BedLevelGrid.value   = wave.domains(i).GrdFile;
    MDW.Domain(i).BedLevel.value       = wave.domains(i).DepFile;
    MDW.Domain(i).DirSpace.value       = wave.domains(i).Circle;
    MDW.Domain(i).NDir.value           = wave.domains(i).NumberDir;
    MDW.Domain(i).NDir.type            = 'integer';
    MDW.Domain(i).StartDir.value       = wave.domains(i).StartDir;
    MDW.Domain(i).StartDir.type        = 'real';
    MDW.Domain(i).EndDir.value         = wave.domains(i).EndDir;
    MDW.Domain(i).EndDir.type          = 'real';
    MDW.Domain(i).NFreq.value          = wave.domains(i).NumberFreq;
    MDW.Domain(i).NFreq.type           = 'integer';
    MDW.Domain(i).FreqMin.value        = wave.domains(i).LowFreq;
    MDW.Domain(i).FreqMin.type         = 'real';
    MDW.Domain(i).FreqMax.value        = wave.domains(i).HighFreq;
    MDW.Domain(i).FreqMax.type         = 'real';
    MDW.Domain(i).NestedInDomain.value = wave.domains(i).NestedValue;
    MDW.Domain(i).NestedInDomain.type  = 'integer';
    MDW.Domain(i).FlowBedLevel.value   = wave.FlowBedLevel;
    MDW.Domain(i).FlowBedLevel.type    = 'integer';
    MDW.Domain(i).FlowWaterLevel.value = wave.FlowWaterLevel;
    MDW.Domain(i).FlowWaterLevel.type  = 'integer';
    MDW.Domain(i).FlowVelocity.value   = wave.FlowVelocity;
    MDW.Domain(i).FlowVelocity.type    = 'integer';
    MDW.Domain(i).FlowWind.value       = wave.FlowWind;
    MDW.Domain(i).FlowWind.type        = 'integer';
    MDW.Domain(i).Output.value         = eval(['wave.Compgrid' num2str(i)]);
end

%% Boundaries
for i=1:wave.nrBoundaries
    
    MDW.Boundary(i).Name.value           = wave.boundaries(i).name;
    MDW.Boundary(i).Definition.value     = wave.boundaries(i).definition;
    
    switch lower(wave.boundaries(i).definition)
        case{'orientation'}
            MDW.Boundary(i).Orientation.value    = wave.boundaries(i).orientation;
        case{'grid-coordinates'}
            MDW.Boundary(i).StartCoordM.value    = wave.boundaries(i).startCoordM;
            MDW.Boundary(i).StartCoordM.type     = 'integer';
            MDW.Boundary(i).EndCoordM.value      = wave.boundaries(i).endCoordM;
            MDW.Boundary(i).EndCoordM.type       = 'integer';
            MDW.Boundary(i).StartCoordN.value    = wave.boundaries(i).startCoordN;
            MDW.Boundary(i).StartCoordN.type     = 'integer';
            MDW.Boundary(i).EndCoordN.value      = wave.boundaries(i).endCoordN;
            MDW.Boundary(i).EndCoordN.type       = 'integer';
        case{'xy-coordinates'}
            MDW.Boundary(i).StartCoordX.value    = wave.boundaries(i).startCoordX;
            MDW.Boundary(i).StartCoordX.type     = 'real';
            MDW.Boundary(i).EndCoordX.value      = wave.boundaries(i).endCoordX;
            MDW.Boundary(i).EndCoordX.type       = 'real';
            MDW.Boundary(i).StartCoordY.value    = wave.boundaries(i).startCoordY;
            MDW.Boundary(i).StartCoordY.type     = 'real';
            MDW.Boundary(i).EndCoordY.value      = wave.boundaries(i).endCoordY;
            MDW.Boundary(i).EndCoordY.type       = 'real';
    end
    
    switch lower(wave.boundaries(i).spectrumSpec)
        case{'parametric'}
            MDW.Boundary(i).SpShapeType.value   = wave.boundaries(i).spShapeType;
            switch lower(wave.boundaries(i).spShapeType)
                case{'jonswap'}
                    MDW.Boundary(i).PeakEnhancFac.value = wave.boundaries(i).peakEnhancFac;
                    MDW.Boundary(i).PeakEnhancFac.type  = 'real';
                case{'pierson-moskowitz'}
                case{'gauss'}
                    MDW.Boundary(i).GaussSpread.value = wave.boundaries(i).gaussSpread;
                    MDW.Boundary(i).GaussSpread.type  = 'real';
            end
            MDW.Boundary(i).PeriodType.value    = wave.boundaries(i).periodType;
            MDW.Boundary(i).DirSpreadType.value = wave.boundaries(i).dirSpreadType;
            switch lower(wave.boundaries(i).alongBoundary)
                case{'uniform'}
                    MDW.Boundary(i).WaveHeight.value     = wave.boundaries(i).waveHeight;
                    MDW.Boundary(i).WaveHeight.type      = 'real';
                    MDW.Boundary(i).Period.value         = wave.boundaries(i).period;
                    MDW.Boundary(i).Period.type          = 'real';
                    MDW.Boundary(i).Direction.value      = wave.boundaries(i).direction;
                    MDW.Boundary(i).Direction.type       = 'real';
                    MDW.Boundary(i).DirSpreading.value   = wave.boundaries(i).dirSpreading;
                    MDW.Boundary(i).DirSpreading.type    = 'real';
                otherwise
                    %                                 for k=1:size(wave.Sections,2)
                    %                 MDW.Boundary(i).List(k).CondSpecAtDist = wave.SpacevaryingParam(i).Dist{k};
                    %                 MDW.Boundary(i).List(k).WaveHeight     = wave.SpacevaryingParam(i).Hs{k};
                    %                 MDW.Boundary(i).List(k).Period         = wave.SpacevaryingParam(i).Tp{k};
                    %                 MDW.Boundary(i).List(k).Direction      = wave.SpacevaryingParam(i).Dir{k};
                    %                 MDW.Boundary(i).List(k).DirSpreading   = wave.SpacevaryingParam(i).Spread{k};
                    %             end
            end
            
        otherwise
            MDW.Boundary(i).SpectrumSpec.value      = 'from file';
            MDW.Boundary(i).Spectrum.value          = wave.boundaries(i).spectrumFile;
    end
end

% MDW.ObstacleFileInformation.PolygonFile = wave.PolFile;
% 
% for i = 1:size(wave.Obstacles,2)
%     MDW.Obstacle(i).Name         = wave.Obstacles{i};
%     if wave.Sheet(i)==1
%         MDW.Obstacle(i).Type         = 'sheet';
%         MDW.Obstacle(i).TransmCoef   = wave.Transmcoef(i);
%     elseif wave.Dam(i)==1
%         MDW.Obstacle(i).Type         = 'dam';
%         MDW.Obstacle(i).Height       = wave.Height(i);
%         MDW.Obstacle(i).Alpha        = wave.Alpha(i);
%         MDW.Obstacle(i).Beta         = wave.Beta(i);
%     end
%     MDW.Obstacle(i).Reflections  = wave.Reflections{wave.Reflectionsval(i)};
%     if wave.Reflectionsval(i)>1
%         MDW.Obstacle(i).ReflecCoef   = wave.Refcoef(i);
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


