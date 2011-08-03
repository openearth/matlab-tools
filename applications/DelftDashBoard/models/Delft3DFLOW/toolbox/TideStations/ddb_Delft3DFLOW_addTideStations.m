function ddb_Delft3DFLOW_addTideStations

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

x=handles.Toolbox(tb).Input.database(iac).xLocLocal;
y=handles.Toolbox(tb).Input.database(iac).yLocLocal;

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
    [m,n]=CheckDepth(m,n,handles.Model(md).Input(ad).depthZ);
    for i=1:length(m)
        if m(i)>0
            nrp=nrp+1;
            istation(nrp)=istat(i);
            mm(nrp)=m(i);
            nn(nrp)=n(i);
            posx2(nrp)=posx(i);
            posy2(nrp)=posy(i);
        end
    end
end

for i=1:nrp

    k=istation(i);
    
    shortName=handles.Toolbox(tb).Input.database(iac).stationShortNames{k};
    nobs=handles.Model(md).Input(ad).nrObservationPoints;
    Names{1}='';
    for k=1:nobs
        Names{k}=handles.Model(md).Input(ad).observationPoints(k).name;
    end

    if isempty(strmatch(shortName,Names,'exact'))
        nobs=nobs+1;
        handles.Model(md).Input(ad).observationPoints(nobs).M=mm(i);
        handles.Model(md).Input(ad).observationPoints(nobs).N=nn(i);
        handles.Model(md).Input(ad).observationPoints(nobs).x=posx2(i);
        handles.Model(md).Input(ad).observationPoints(nobs).y=posy2(i);
        lname=length(shortName);
        shortName=shortName(1:min(lname,21));
        handles.Model(md).Input(ad).observationPoints(nobs).name=shortName;
        handles.Model(md).Input(ad).observationPointNames{nobs}=shortName;
        Names{nobs}=shortName;
    end

    handles.Model(md).Input(ad).nrObservationPoints=nobs;

end

if nrp>0
    handles=ddb_Delft3DFLOW_plotAttributes(handles,'plot','observationpoints','domain',ad,'visible',1,'active',0);
end

setHandles(handles);

