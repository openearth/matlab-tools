function writeMDW(hm,m,fname)

Model=hm.Models(m);

inpdir=[Model.Dir 'input' filesep];

fid=fopen(fname,'wt');

itdate=D3DTimeString(Model.RefTime,'itdatemdf');

dtmap=num2str(Model.MapTimeStep);
dtcom=num2str(Model.ComTimeStep);
%dthot=num2str(hm.RunInterval*60);
dthot=num2str(12*60);

k=0;
for i=1:length(Model.NestedWaveModels)
    % A model is nested in this Delft3D-WAVE model
    mm=Model.NestedWaveModels(i);
    k=k+1;
    locfile{k}=[hm.Models(mm).Runid '.loc'];
end
for i=1:Model.NrStations
    if Model.Stations(i).StoreSP2
        k=k+1;
        locfile{k}=[Model.Stations(i).SP2id '.loc'];
    end
end
nloc=k;

fprintf(fid,'%s\n','[WaveFileInformation]');
fprintf(fid,'%s\n','   FileVersion = 02.00');
fprintf(fid,'%s\n','[General]');
fprintf(fid,'%s\n','   ProjectName      = ');
fprintf(fid,'%s\n','   ProjectNr        = ');
fprintf(fid,'%s\n','   Description1     = ');
fprintf(fid,'%s\n','   Description2     = ');
fprintf(fid,'%s\n','   Description3     = ');
fprintf(fid,'%s\n',['   ReferenceDate    = ' itdate]);
fprintf(fid,'%s\n','   DirConvention    = nautical');
fprintf(fid,'%s\n','   SimMode          = non-stationary');
fprintf(fid,'%s\n',['   TimeStep         = ' num2str(Model.WaveTimeStep)]);
fprintf(fid,'%s\n','   OnlyInputVerify  = false');
fprintf(fid,'%s\n','   DirSpace         = circle');
fprintf(fid,'%s\n','   NDir             = 36');
fprintf(fid,'%s\n','   FreqMin          = 5.0000001e-002');
fprintf(fid,'%s\n','   FreqMax          = 1.0000000e+000');
fprintf(fid,'%s\n','   NFreq            = 24');
fprintf(fid,'%s\n','   TimePoint        = 0.0000000e+000');
fprintf(fid,'%s\n','   WaterLevel       = 0.0000000e+000');
fprintf(fid,'%s\n','   XVeloc           = 0.0000000e+000');
fprintf(fid,'%s\n','   YVeloc           = 0.0000000e+000');
fprintf(fid,'%s\n','   WindSpeed        = 6.0000000e+000');
fprintf(fid,'%s\n','   WindDir          = 3.3000000e+002');
if ~isempty(Model.WaveRstFile)
    starttime=datestr(Model.TWaveStart,'yyyymmdd.HHMMSS');
    fprintf(fid,'%s\n',['   HotFileID        = ' starttime]);
end
if exist([inpdir Model.Name '.obw'],'file')
    fprintf(fid,'%s\n',['   ObstacleFile      = ' Model.Name '.obw']);
end
fprintf(fid,'%s\n','[Constants]');
fprintf(fid,'%s\n','   Gravity          = 9.8100004e+000');
fprintf(fid,'%s\n','   WaterDensity     = 1.0250000e+003');
fprintf(fid,'%s\n','   NorthDir         = 9.0000000e+001');
fprintf(fid,'%s\n','   MinimumDepth     = 5.0000001e-002');
fprintf(fid,'%s\n','[Processes]');
fprintf(fid,'%s\n','   GenModePhys      = 3');
fprintf(fid,'%s\n','   WaveSetup        = false');
fprintf(fid,'%s\n','   WaveForces       = dissipation');
fprintf(fid,'%s\n','   Breaking         = true');
fprintf(fid,'%s\n','   BreakAlpha       = 1.0000000e+000');
fprintf(fid,'%s\n','   BreakGamma       = 7.3000002e-001');
fprintf(fid,'%s\n',['   BedFriction      = ' Model.WaveBedFric]);
fprintf(fid,'%s\n',['   BedFricCoef      = ' num2str(Model.WaveBedFricCoef)]);
fprintf(fid,'%s\n','   Triads           = false');
fprintf(fid,'%s\n','   Diffraction      = false');
fprintf(fid,'%s\n','   WindGrowth       = true');
% fprintf(fid,'%s\n','   WhiteCapping     = Westhuysen');
fprintf(fid,'%s\n','   WhiteCapping     = Komen');
fprintf(fid,'%s\n','   Quadruplets      = true');
fprintf(fid,'%s\n','   Refraction       = true');
fprintf(fid,'%s\n','   FreqShift        = true');
fprintf(fid,'%s\n','[Numerics]');
fprintf(fid,'%s\n','   DirSpaceCDD      = 5.0000000e-001');
fprintf(fid,'%s\n','   FreqSpaceCSS     = 5.0000000e-001');
fprintf(fid,'%s\n','   RChHsTm01        = 2.0000000e-002');
fprintf(fid,'%s\n','   RChMeanHs        = 2.0000000e-002');
fprintf(fid,'%s\n','   RChMeanTm01      = 2.0000000e-002');
fprintf(fid,'%s\n','   PercWet          = 9.8000000e+001');
fprintf(fid,'%s\n',['   MaxIter          = ' num2str(Model.MaxIter)]);
% if exist([inpdir Model.Name '.obw'],'file')
%     fprintf(fid,'%s\n','[ObstacleFileInformation]');
%     fprintf(fid,'%s\n',['   PolygonFile      = ' Model.Name '.pol']);
%     fprintf(fid,'%s\n','[Obstacle]');
%     fprintf(fid,'%s\n','   Name             = L001');
%     fprintf(fid,'%s\n','   Type             = sheet');
%     fprintf(fid,'%s\n','   TransmCoef       = 0.0');
%     fprintf(fid,'%s\n','   Reflections      = no');
% end
fprintf(fid,'%s\n','[Output]');
fprintf(fid,'%s\n','   TestOutputLevel  = 0');
fprintf(fid,'%s\n','   TraceCalls       = false');
fprintf(fid,'%s\n','   UseHotFile       = true');
fprintf(fid,'%s\n',['   MapWriteInterval = ' dtmap]);
fprintf(fid,'%s\n','   WriteCOM         = true');
fprintf(fid,'%s\n',['   COMWriteInterval = ' dtcom]);
fprintf(fid,'%s\n',['   Int2KeepHotfile  = ' dthot]);
fprintf(fid,'%s\n',['   FlowGrid         = ' Model.Name '.grd']);
for i=1:nloc
    fprintf(fid,'%s\n',['   LocationFile     = ' locfile{i}]);
end
% fprintf(fid,'%s\n','   WriteSpec1D      = true');
fprintf(fid,'%s\n','   WriteSpec2D      = true');
fprintf(fid,'%s\n','[Domain]');
fprintf(fid,'%s\n',['   Grid             = ' Model.Name '_swn.grd']);
fprintf(fid,'%s\n',['   BedLevel         = ' Model.Name '_swn.dep']);

if Model.FlowWaterLevel
    fprintf(fid,'%s\n','   FlowWaterLevel   = 1');
else
    fprintf(fid,'%s\n','   FlowWaterLevel   = 0');
end
if Model.FlowBedLevel
    fprintf(fid,'%s\n','   FlowBedLevel     = 1');
else
    fprintf(fid,'%s\n','   FlowBedLevel     = 0');
end
if Model.FlowVelocity
    fprintf(fid,'%s\n','   FlowVelocity     = 1');
else
    fprintf(fid,'%s\n','   FlowVelocity     = 0');
end
if Model.FlowWind
    fprintf(fid,'%s\n','   FlowWind         = 1');
else
    fprintf(fid,'%s\n','   FlowWind         = 0');
end

fprintf(fid,'%s\n','[Boundary]');
% switch lower(hm.Models(Model.WaveNestModelNr).Type)
%     case{'ww3'}
%         fprintf(fid,'%s\n','   Definition = fromWWfile');
%         fprintf(fid,'%s\n','   WWspecfile = ww3.spc');
%     case{'delft3dflowwave'}
%         fprintf(fid,'%s\n','   Definition       = fromsp2file');
%         fprintf(fid,'%s\n',['   OverallSpecFile  = ' Model.Name '.sp2']);
% end

fprintf(fid,'%s\n','   Definition       = fromsp2file');
fprintf(fid,'%s\n',['   OverallSpecFile  = ' Model.Name '.sp2']);

fclose(fid);
