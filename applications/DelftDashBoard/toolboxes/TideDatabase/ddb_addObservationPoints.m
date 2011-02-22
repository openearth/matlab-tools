function handles=ddb_addObservationPoints(handles)

posx=[];

id=handles.activeDomain;
Stations=handles.Toolbox(tb).tideStations;

xg=handles.Model(handles.activeModel.nr).Input(id).gridX;
yg=handles.Model(handles.activeModel.nr).Input(id).gridY;

xmin=min(min(xg));
xmax=max(max(xg));
ymin=min(min(yg));
ymax=max(max(yg));

ns=length(Stations.x);
n=0;

x=Stations.x;
y=Stations.y;
% x=cell2mat(x);
% y=cell2mat(y);
cs.name='WGS 84';
cs.Type='Geographic';
[x,y]=ddb_coordConvert(x,y,cs,handles.screenParameters.coordinateSystem);

for i=1:ns
    if x(i)>xmin && x(i)<xmax && ...
       y(i)>ymin && y(i)<ymax
       n=n+1;
       posx(n)=x(i);
       posy(n)=y(i);
       name{n}=deblank(Stations.name{i});
       name{n}=name{n}(1:min(length(name{n}),20));
       istat(n)=i;
    end
end

wb = waitbox('Finding Stations ...');

if ~isempty(posx)
    [m,n]=FindGridCell(posx,posy,xg,yg);
    [m,n]=CheckDepth(m,n,handles.Model(handles.activeModel.nr).Input(id).depthZ);
    nobs=handles.Model(handles.activeModel.nr).Input(id).nrObservationPoints;
    Names{1}='';
    for k=1:nobs
        Names{k}=handles.Model(handles.activeModel.nr).Input(id).observationPoints(k).name;
    end
    for i=1:length(m)
        if m(i)>0
            if isempty(strmatch(name{i},Names,'exact'))
                nobs=nobs+1;
                handles.Model(handles.activeModel.nr).Input(id).observationPoints(nobs).M=m(i);
                handles.Model(handles.activeModel.nr).Input(id).observationPoints(nobs).N=n(i);
                handles.Model(handles.activeModel.nr).Input(id).observationPoints(nobs).x=posx(i);
                handles.Model(handles.activeModel.nr).Input(id).observationPoints(nobs).y=posy(i);
                handles.Model(handles.activeModel.nr).Input(id).observationPoints(nobs).name=name{i};
                Names{nobs}=name{i};
            end
        end
    end

    handles.Model(handles.activeModel.nr).Input(id).nrObservationPoints=nobs;

    fid=fopen([handles.Model(handles.activeModel.nr).Input(id).runid '.ann'],'w');

    for i=1:nobs
        x=handles.Model(handles.activeModel.nr).Input(id).observationPoints(i).x;
        y=handles.Model(handles.activeModel.nr).Input(id).observationPoints(i).y;
        name=handles.Model(handles.activeModel.nr).Input(id).observationPoints(i).name;
        fprintf(fid,'%s %15.5f %15.5f\n',['"' name '"' repmat(' ',1,23-length(name)) ] ,x,y);
    end
    fclose(fid);


end
close(wb);
