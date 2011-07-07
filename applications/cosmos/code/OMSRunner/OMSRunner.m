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

hm.MainWindow=MakeNewWindow('OMSMain',[750 500]);

set(hm.MainWindow,'CloseRequestFcn',@closeOMS);
set(hm.MainWindow,'Tag','OMSMain');

hm.RunSimulation=1;
hm.ExtractData=1;
hm.DetermineHazards=1;
hm.RunPost=1;
hm.MakeWebsite=1;
hm.UploadFTP=1;
hm.ArchiveInput=1;
hm.GetOceanModel=1;

hm.NCyc=0;

hm=MakeGUIMainLoop(hm);
hm=MakeGUIModelLoop(hm);

guidata(hm.MainWindow,hm);

%%
function closeOMS(src,evnt)
delete(timerfind);
fclose all;
closereq;
