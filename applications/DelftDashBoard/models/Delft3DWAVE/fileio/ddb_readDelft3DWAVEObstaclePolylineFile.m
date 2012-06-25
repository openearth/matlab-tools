function obs=ddb_readDelft3DWAVEObstaclePolylineFile(obs,filename)

info = tekal('open',filename);

nobs=length(obs);

for ii=1:length(info.Field)
    nobs=nobs+1;
    obs(nobs).name=info.Field(ii).Name;
    obs(nobs).x=info.Field(ii).Data(:,1);
    obs(nobs).y=info.Field(ii).Data(:,2);
end
