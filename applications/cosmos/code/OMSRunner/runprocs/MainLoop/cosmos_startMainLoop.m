function cosmos_startMainLoop(hm)

delay=8;

if now>hm.Cycle+delay/24
    starttime=now+1/86400;
else
    starttime=hm.Cycle+delay/24;
    disp(['Execution of cycle ' datestr(hm.Cycle,'yyyymmdd.HHMMSS') ' will start at ' datestr(starttime)]);
end

t = timer;
set(t,'ExecutionMode','singleShot','BusyMode','drop');
set(t,'TimerFcn',{@cosmos_runMainLoop},'Tag','MainLoop');
startat(t,starttime);
