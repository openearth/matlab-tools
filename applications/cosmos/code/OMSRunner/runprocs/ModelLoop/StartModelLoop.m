function StartModelLoop(hm)

for i=1:hm.NrModels
    hm.Models(i).Status='waiting';
    hm.Models(i).RunSimulation=hm.RunSimulation;
    hm.Models(i).ExtractData=hm.ExtractData;
    hm.Models(i).RunPost=hm.RunPost;
    hm.Models(i).MakeWebsite=hm.MakeWebsite;
    hm.Models(i).UploadFTP=hm.UploadFTP;
    hm.Models(i).SimStart=datestr(now);
    hm.Models(i).SimStop=datestr(now);
    hm.Models(i).RunDuration=0;
    hm.Models(i).MoveDuration=0;
    hm.Models(i).ProcessDuration=0;
    hm.Models(i).PlotDuration=0;
    hm.Models(i).ExtractDuration=0;
    hm.Models(i).UploadDuration=0;
end

% Check finished simulations
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

%% Check which simulations already ran
for i=1:hm.NrModels
    if strcmpi(hm.Models(i).Status,'waiting') && hm.Models(i).RunSimulation==0 && hm.Models(i).Priority>0
        hm.Models(i).Status='simulationfinished';
    end
end

%% Start and stop times
disp('Getting start and stop times ...');
set(hm.TextModelLoopStatus,'String','Status : Getting start and stop times ...');drawnow;
hm=GetStartStopTimes(hm);
disp('Finished getting start and stop times');

%% Meteo
hm.GetMeteo=get(hm.ToggleGetMeteo,'Value');
if hm.GetMeteo
    set(hm.TextModelLoopStatus,'String','Status : Getting meteo data ...');drawnow;
    GetMeteoData(hm);
end

%% Predictions and Observations
if get(hm.ToggleGetObservations,'Value')
    set(hm.TextModelLoopStatus,'String','Status : Getting observations ...');drawnow;
    GetObservations(hm);
end

guidata(findobj('Tag','OMSMain'),hm);


if hm.RunSimulation || hm.ExtractData || hm.RunPost || hm.MakeWebsite || hm.UploadFTP || hm.DetermineHazards || hm.ArchiveInput

    starttime=now+1/86400;
    t = timer;
    set(t,'ExecutionMode','fixedRate','BusyMode','drop','period',5);
    set(t,'TimerFcn',{@RunModelLoop},'Tag','ModelLoop');
    startat(t,starttime);
    set(hm.TextModelLoopStatus,'String','Status : active');drawnow;

end
