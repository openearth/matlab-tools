function ddb_exportTideSignalAllStations(handles)



posx=[];

stations=handles.Toolbox(tb).tideStations;

xg=handles.Model(md).Input(id).gridX;
yg=handles.Model(md).Input(id).gridY;

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
cs.Name='WGS 84';
cs.Type='Geographic';
[x,y]=ddb_coordConvert(x,y,cs,handles.screenParameters.coordinateSystem);

for i=1:ns
    if x(i)>xmin && x(i)<xmax && ...
       y(i)>ymin && y(i)<ymax
       n=n+1;
       posx(n)=x(i);
       posy(n)=y(i);
       name{n}=deblank(stations.Name{i});
       istat(n)=i;
    end
end
wb = waitbox('Finding Stations ...');
if ~isempty(posx)
    [m,n]=findGridCell(posx,posy,xg,yg);
    nobs=handles.Model(md).Input(ad).nrObservationPoints;
    for i=1:length(m)
        if m(i)>0

            k=istat(i);
            cmp=Stations.ComponentSet(k);
            for ii=1:length(cmp.Component)
                comp{ii}=cmp.Component{ii};
                A(ii,1)=cmp.Amplitude(ii);
                G(ii,1)=cmp.Phase(ii);
            end
            t0=handles.Toolbox(tb).startTime;
            t1=handles.Toolbox(tb).stopTime;
            dt=handles.Toolbox(tb).timeStep/60;
            t1=t1+dt/24;

            [prediction,times]=delftPredict2007(comp,A,G,t0,t1,dt);

            blname=deblank(stations.Name{k});
            fname=blname;
            fname=strrep(fname,' ','');
            fname=[fname '.tek'];
            exportTek(prediction(1:end-1)',times(1:end-1)',fname,blname);

        end
    end

end
close(wb);
