function zlim=MakeTidePrediction(hm,stat,fname,t0,t1,dt)

Names=hm.TideStations.Name;
Stations=hm.TideStations;

k=strmatch(stat,Names,'exact');
k=k(1);
cmp=Stations.ComponentSet(k);

for ii=1:length(cmp.Component)
    comp{ii}=cmp.Component{ii};
    A(ii,1)=cmp.Amplitude(ii);
    G(ii,1)=cmp.Phase(ii);
end

dt=dt/60;
t1=t1+dt/24;

[prediction,times]=delftPredict2007(comp,A,G,t0,t1,dt);

zlim(1)=min(prediction);
zlim(2)=max(prediction);

blname=Names{k};
ExportTek(prediction(1:end-1),times(1:end-1),fname,blname);
