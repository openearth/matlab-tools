function handles = ddb_Delft3DWAVE_readAttributeFiles(handles)

for ib=1:handles.Model(md).Input.nrdomains
    if ~isempty(handles.Model(md).Input.domains(ib).grid)
        [x,y,enc]=ddb_wlgrid('read',handles.Model(md).Input.domains(ib).grid);
        handles.Model(md).Input.domains(ib).gridx=x;
        handles.Model(md).Input.domains(ib).gridy=y;
        nans=zeros(size(handles.Model(md).Input.domains(ib).gridx));
        nans(nans==0)=NaN;
        handles.Model(md).Input.domains(ib).depth=nans;
    end
end

if ~isempty(handles.Model(md).Input.obstaclefile)
    obs=[];
    [obs,plifile]=ddb_Delft3DWAVE_readObstacleFile(obs,handles.Model(md).Input.obstaclefile);
    for ii=1:length(obs)
        handles.Model(md).Input.obstaclenames{ii}=obs(ii).name;
    end
    handles.Model(md).Input.obstaclepolylinesfile=plifile;
    handles.Model(md).Input.obstacles=obs;
    handles.Model(md).Input.nrobstacles=length(obs);    
end
