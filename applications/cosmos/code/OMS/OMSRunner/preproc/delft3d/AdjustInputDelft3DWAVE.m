function AdjustInputDelft3DWAVE(hm,m)

Model=hm.Models(m);

tmpdir=hm.TempDir;

%% MDW File
mdwfile=[tmpdir Model.Runid '.mdw'];
writeMDW(hm,m,mdwfile);

%% DIOConfig file 
writeDIOConfig(tmpdir);

%% Nesting
k=0;
n=length(Model.NestedWaveModels);
for i=1:n

    % A model is nested in this Delft3D-WAVE model
    mm=Model.NestedWaveModels(i);
    k=k+1;
    
    locfile=[hm.Models(mm).Dir 'nesting' filesep Model.Name '.loc'];

    % Find boundary points nested grid
    switch lower(hm.Models(mm).Type)
        case{'xbeachcluster','xbeach'}
            d=[];
            for ip=1:hm.Models(mm).NrProfiles
                d(ip,1)=hm.Models(mm).Profile(ip).OriginX;
                d(ip,2)=hm.Models(mm).Profile(ip).OriginY;
            end
            save(locfile,'d','-ascii');
        otherwise
            if ~exist(locfile,'file')
                grdname=[hm.Models(mm).Dir 'input' filesep hm.Models(mm).Name '_swn.grd'];
                [x,y,enc]=wlgrid('read',grdname);
                nstep=10;
                [xb,yb]=getGridOuterCoordinates(x,y,nstep);
                d=[xb yb];
                save(locfile,'d','-ascii');
            end
    end

    locs=load(locfile);
    if ~strcmpi(hm.Models(mm).CoordinateSystem,Model.CoordinateSystem) || ~strcmpi(hm.Models(mm).CoordinateSystemType,Model.CoordinateSystemType)
        % Convert coordinates
        xx=locs(:,1);
        yy=locs(:,2);
        [xx,yy]=ConvertCoordinates(xx,yy,'CS1.name',hm.Models(mm).CoordinateSystem,'CS1.type',hm.Models(mm).CoordinateSystemType,'CS2.name',Model.CoordinateSystem,'CS2.type',Model.CoordinateSystemType);
        locs(:,1)=xx;
        locs(:,2)=yy;
    end
    save([tmpdir hm.Models(mm).Runid '.loc'],'locs','-ascii');
    
    for nn=1:Model.NrStations
        if Model.Stations(nn).StoreSP2
            xy=[Model.Stations(nn).Location(1) Model.Stations(nn).Location(2)];
            locfile=[tmpdir Model.Stations(nn).SP2id '.loc'];
            save(locfile,'xy','-ascii');
        end
    end

end
