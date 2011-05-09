function OMSRunner

delete(timerfind);

hm=ReadOMSConfigFile;
hm=readScenario(hm);

% Read all data
wb = waitbox('Loading tide database ...');
hm=getTideStations(hm);
close(wb);

wb = waitbox('Loading observations database ...');
hm=getObservationStations(hm);
close(wb);

% wb = waitbox('Loading coordinate conversion libraries ...');
% load('CoordinateSystems.mat');
% load('Operations.mat');
% hm.CoordinateSystems=CoordinateSystems;
% hm.Operations=Operations;
% clear CoordinateSystems Operations;
% close(wb);

wb = waitbox('Loading muppet defaults ...');
hm.muppethandles.MuppetVersion='3.20';
hm.muppethandles.SessionName='dummy';
hm.muppethandles.MuppetDir=hm.MainDir;
hm.muppethandles=ReadDefaults(hm.muppethandles);
hm.muppethandles.ColorMaps=ImportColorMaps;
hm.muppethandles.DefaultColors=ReadDefaultColors;
hm.muppethandles.Frames=ReadFrames;
hm.muppethandles.DataProperties=[];
hm.muppethandles.Figure=[];
hm.muppethandles.NrAvailableDatasets=0;
close(wb);

hm.MainWindow=MakeNewWindow('OMSMain',[750 500]);

set(hm.MainWindow,'CloseRequestFcn',@closeOMS);
set(hm.MainWindow,'Tag','OMSMain');

% hm.RunInterval=12; % hours
% hm.RunTime=72; % hours

hm.RunSimulation=1;
hm.ExtractData=1;
hm.DetermineHazards=1;
hm.RunPost=1;
hm.MakeWebsite=1;
hm.UploadFTP=1;
hm.ArchiveInput=1;
hm.GetOceanModel=1;

hm.NCyc=0;
% hm.CycleMode='continuous';

hm=MakeGUIMainLoop(hm);
hm=MakeGUIModelLoop(hm);

guidata(hm.MainWindow,hm);

%%
function closeOMS(src,evnt)
delete(timerfind);
fclose all;
closereq;
