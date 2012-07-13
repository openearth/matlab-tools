function handles = ddb_Delft3DWAVE_readAttributeFiles(handles)

for ib=1:handles.Model(md).Input.nrdomains
    if ~isempty(handles.Model(md).Input.domains(ib).grid)
        [x,y,enc]=ddb_wlgrid('read',handles.Model(md).Input.domains(ib).grid);
        handles.Model(md).Input.domains(ib).gridx=x;
        handles.Model(md).Input.domains(ib).gridy=y;
        nans=zeros(size(handles.Model(md).Input.domains(ib).gridx));
        nans(nans==0)=NaN;
        handles.Model(md).Input.domains(ib).depth=nans;
        handles.Model(md).Input.domains(ib).mmax=size(x,1);
        handles.Model(md).Input.domains(ib).nmax=size(x,2);
        if ~isempty(handles.Model(md).Input.domains(ib).bedlevel)
            mmax=handles.Model(md).Input.domains(ib).mmax;
            nmax=handles.Model(md).Input.domains(ib).nmax;
            dp=ddb_wldep('read',handles.Model(md).Input.domains(ib).bedlevel,[mmax+1 nmax+1]);
            handles.Model(md).Input.domains(ib).depth=-dp(1:end-1,1:end-1);
        end
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

if ~isempty(handles.Model(md).Input.locationfile)
    if ~isempty(handles.Model(md).Input.locationfile{1})
        for ii=1:length(handles.Model(md).Input.locationfile)
            xy=load(handles.Model(md).Input.locationfile{ii});
            handles.Model(md).Input.locationsets(ii).x=xy(:,1)';
            handles.Model(md).Input.locationsets(ii).y=xy(:,2)';
            handles.Model(md).Input.locationsets(ii).nrpoints=length(handles.Model(md).Input.locationsets(ii).x);
            handles.Model(md).Input.locationsets(ii).activepoint=1;
            for jj=1:handles.Model(md).Input.locationsets(ii).nrpoints
                handles.Model(md).Input.locationsets(ii).pointtext{jj}=num2str(jj);
            end
        end
        handles.Model(md).Input.activelocationset=1;
        handles.Model(md).Input.nrlocationsets=length(handles.Model(md).Input.locationfile);
    end
end
