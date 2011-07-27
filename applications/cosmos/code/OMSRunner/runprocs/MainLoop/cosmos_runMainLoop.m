function cosmos_runMainLoop(hObject, eventdata)

% Clear data, close hidden windows etc.
disp('Clearing memory ...');
ff=findobj(0,'type','figure','Visible','off');
if ~isempty(ff)
    close(ff);
end
fclose all;
figs=findall(0,'Type','figure');
for i=1:length(figs)
    name=get(figs(i),'Name');
    if ~strcmpi(name,'OMSMain')
        close(figs(i));
    end
end

hm=guidata(findobj('Tag','OMSMain'));

disp('Start main loop ...');

%% Reading data
disp('Reading models ...');
set(hm.TextMainLoopStatus,'String','Status : Reading models ...');drawnow;

hm=cosmos_readMeteo(hm);
hm=cosmos_readOceanModels(hm);
hm=cosmos_readParameters(hm);
hm=cosmos_readContinents(hm);
hm=cosmos_readModels(hm);

%% Time Management
hm.NCyc=hm.NCyc+1;

hm.CycStr=[datestr(hm.Cycle,'yyyymmdd') '_' datestr(hm.Cycle,'HH') 'z'];

set(hm.EditCycle,'String',datestr(hm.Cycle,'yyyymmdd HHMMSS'));

%% Set initial durations and what needs to be done for each model
for i=1:hm.NrModels
    hm.Models(i).Status='waiting';
    hm.Models(i).RunSimulation=hm.RunSimulation;
    hm.Models(i).ExtractData=hm.ExtractData;
    hm.Models(i).DetermineHazards=hm.DetermineHazards;
    hm.Models(i).RunPost=hm.RunPost;
    hm.Models(i).MakeWebsite=hm.MakeWebsite;
    hm.Models(i).UploadFTP=hm.UploadFTP;
    hm.Models(i).ArchiveInput=hm.ArchiveInput;
    hm.Models(i).SimStart=datestr(now);
    hm.Models(i).SimStop=datestr(now);
    hm.Models(i).RunDuration=0;
    hm.Models(i).MoveDuration=0;
    hm.Models(i).ProcessDuration=0;
    hm.Models(i).PlotDuration=0;
    hm.Models(i).ExtractDuration=0;
    hm.Models(i).UploadDuration=0;
end

%% Check finished simulations
flist=dir([hm.ScenarioDir 'joblist' filesep 'finished.' datestr(hm.Cycle,'yyyymmdd.HHMMSS') '.*']);
if ~isempty(flist)
%     ButtonName = questdlg(['There are finished simulations for cycle ' datestr(hm.Cycle,'yyyymmdd HHMMSS') '. Delete them?'], ...
%         'Delete finished simulations', ...
%         'No', 'Yes', 'Yes');
    ButtonName='no';
    if strcmpi(ButtonName,'no')
        for i=1:length(flist)
            mdl=flist(i).name(26:end);
            nr=findstrinstruct(hm.Models,'Name',mdl);
            if ~isempty(nr)
                hm.Models(nr).Status='finished';
                hm.Models(nr).RunSimulation=0;
            end
        end
    else
    end
end

for i=1:hm.NrModels
    if hm.Models(i).Priority==0
        hm.Models(i).RunSimulation=0;
    end
end

%% Check which simulations (just the computing part) already ran
for i=1:hm.NrModels
    if strcmpi(hm.Models(i).Status,'waiting') && hm.Models(i).RunSimulation==0 && hm.Models(i).Priority>0
        hm.Models(i).Status='simulationfinished';
    end
end

%% Start and stop times
disp('Getting start and stop times ...');
set(hm.TextModelLoopStatus,'String','Status : Getting start and stop times ...');drawnow;
hm=cosmos_getStartStopTimes(hm);
disp('Finished getting start and stop times');

%% Meteo
hm.GetMeteo=get(hm.ToggleGetMeteo,'Value');
if hm.GetMeteo
    set(hm.TextModelLoopStatus,'String','Status : Getting meteo data ...');drawnow;
    cosmos_getMeteoData(hm);
end

%% Ocean Model data
if hm.GetOceanModel
    set(hm.TextModelLoopStatus,'String','Status : Getting ocean model data ...');drawnow;
    cosmos_getOceanModelData(hm);
end

%% Predictions and Observations
if get(hm.ToggleGetObservations,'Value')
    set(hm.TextModelLoopStatus,'String','Status : Getting observations ...');drawnow;
    cosmos_getObservations(hm);
    set(hm.TextModelLoopStatus,'String','Status : Making predictions ...');drawnow;
    cosmos_getPredictions(hm);
end

%% Restart times (times to generate restart files)
hm=cosmos_getRestartTimes(hm);

%% Run model loop
starttime=now+1/86400;
t = timer;
set(t,'ExecutionMode','fixedRate','BusyMode','drop','period',5);
set(t,'TimerFcn',{@cosmos_runModelLoop},'Tag','ModelLoop');
startat(t,starttime);
set(hm.TextModelLoopStatus,'String','Status : active');drawnow;

set(hm.TextMainLoopStatus,'String','Status : running');drawnow;

guidata(findobj('Tag','OMSMain'),hm);
