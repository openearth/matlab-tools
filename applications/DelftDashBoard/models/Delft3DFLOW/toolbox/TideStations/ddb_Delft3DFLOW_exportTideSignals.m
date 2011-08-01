function ddb_Delft3DFLOW_exportTideSignals
handles=getHandles;

posx=[];

iac=handles.Toolbox(tb).Input.activeDatabase;
names=handles.Toolbox(tb).Input.database(iac).stationShortNames;

xg=handles.Model(md).Input(ad).gridX;
yg=handles.Model(md).Input(ad).gridY;

xmin=min(min(xg));
xmax=max(max(xg));
ymin=min(min(yg));
ymax=max(max(yg));

ns=length(handles.Toolbox(tb).Input.database(iac).xLoc);
n=0;

x=handles.Toolbox(tb).Input.database(iac).xLoc;
y=handles.Toolbox(tb).Input.database(iac).yLoc;

wb = awaitbar(0,'Finding stations...');

% First find points within grid bounding box
for i=1:ns
    if x(i)>xmin && x(i)<xmax && ...
       y(i)>ymin && y(i)<ymax
       n=n+1;
       posx(n)=x(i);
       posy(n)=y(i);
       name{n}=names{i};
       istat(n)=i;
    end
end

% Find stations within grid
nrp=0;
if ~isempty(posx)
    [m,n]=findGridCell(posx,posy,xg,yg);
    for i=1:length(m)
        if m(i)>0
            nrp=nrp+1;
            istation(nrp)=istat(i);
        end
    end
end

for i=1:nrp

    k=istation(i);

    stationName=handles.Toolbox(tb).Input.database(iac).stationList{k};

    str=['Station ' stationName ' - ' num2str(i) ' of ' num2str(nrp) ' ...'];
    [hh,abort2]=awaitbar(i/(nrp),wb,str);

    if abort2 % Abort the process by clicking abort button
        break;
    end;
    if isempty(hh); % Break the process when closing the figure
        break;
    end;
    
    t0=handles.Toolbox(tb).Input.startTime;
    t1=handles.Toolbox(tb).Input.stopTime;
    dt=handles.Toolbox(tb).Input.timeStep/1440;
    tim=t0:dt:t1;
    
    % Read data from nc file
    fname=[handles.Toolbox(tb).miscDir handles.Toolbox(tb).Input.database(iac).shortName '.nc'];
    ncomp=length(handles.Toolbox(tb).Input.database(iac).components);
    amp00=nc_varget(fname,'amplitude',[0 k-1],[ncomp 1]);
    phi00=nc_varget(fname,'phase',[0 k-1],[ncomp 1]);
    
    components=[];
    amplitudes=[];
    phases=[];
    
    % Find non-zero amplitudes
    ii=find(amp00~=0);
    for j=1:length(ii)
        ik=ii(j);
        components{j}=handles.Toolbox(tb).Input.database(iac).components{ik};
        amplitudes(j)=amp00(ik);
        phases(j)=phi00(ik);
    end
    
    latitude=handles.Toolbox(tb).Input.database(iac).y(k);

    wl=makeTidePrediction(tim,components,amplitudes,phases,latitude,'timezone',handles.Toolbox(tb).Input.timeZone);
    
    shortName=handles.Toolbox(tb).Input.database(iac).stationShortNames{k};
    fname=[shortName '.tek'];
    exportTEK(wl',tim',fname,stationName);

end

try
    close(wb);
end
