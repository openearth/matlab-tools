function handles=ddb_generateInitialConditionsDelft3DFLOW(handles,id,fname,varargin)

if ~isempty(varargin)
    % Check if routine exists
    if strcmpi(varargin{1},'ddb_test')
        return
    end
end

wb = waitbox('Generating Initial Conditions ...');%pause(0.1);

%% Water Level

xz=handles.Model(md).Input(id).GridXZ;
yz=handles.Model(md).Input(id).GridYZ;

mmax=size(xz,1);
nmax=size(xz,2);
kmax=handles.Model(md).Input(id).KMax;

if ~strcmpi(handles.Model(md).Input(id).WaterLevel.ICOpt,'constant')

    % Tide Model

    cs.Name='WGS 84';
    cs.Type='Geographic';
    [xz,yz]=ddb_coordConvert(xz,yz,handles.ScreenParameters.CoordinateSystem,cs);

    for i=1:mmax
        for j=1:nmax
            if xz(i,j)<0
                xz(i,j)=xz(i,j)+360;
            end
        end
    end

    x00=reshape(xz,mmax*nmax,1);
    y00=reshape(yz,mmax*nmax,1);

    
    if length(x00)>100000
        % Limitation in delftPredict.mexw32
        disp('Too many grid points (>100000)! Cannot continue operation.');
        close(wb);
        GiveWarning('Warning','Number of grid points exceeds 100000! Cannot continue this operation.'); 
        return
    end
    
    x00(x00<0.125 & x00>0)=360;
    x00(x00<0.250 & x00>0.125)=0.25;
    x00(x00>360)=360;

    t0=handles.Model(md).Input(id).StartTime;
    
    ii=strmatch(handles.TideModels.ActiveTideModelIC,handles.TideModels.Name,'exact');
    if strcmpi(handles.TideModels.Model(ii).URL(1:4),'http')
        tidefile=[handles.TideModels.Model(ii).URL '/' handles.TideModels.ActiveTideModelIC '.nc'];
    else
        tidefile=[handles.TideModels.Model(ii).URL filesep handles.TideModels.ActiveTideModelIC '.nc'];
    end
    [ampz,phasez,depth,conList]=ddb_extractTidalConstituents(tidefile,x00,y00,'z');
    
    % TODO this does not work yet for large grids
    % delftPredict2007 must be updated    
    
    [prediction,tdummy]=delftPredict2007(conList,ampz,phasez,t0,t0+2/24,1);
    h=squeeze(prediction(:,1));

    h0=zeros(mmax+1,nmax+1);
    h=reshape(h,mmax,nmax);
    h0(1:end-1,1:end-1)=h;
    h=h0;
    h(isnan(h))=0;

else
    % Constant
    h=zeros(mmax+1,nmax+1)+handles.Model(md).Input(id).WaterLevel.ICConst;
end

if exist(fname,'file')
    delete(fname);
end

ddb_wldep('append',fname,h,'negate','n','bndopt','n');

%% Velocities

u=zeros(size(h));

for i=1:kmax
    ddb_wldep('append',fname,u,'negate','n','bndopt','n');
    ddb_wldep('append',fname,u,'negate','n','bndopt','n');
end

mmax=mmax+1;
nmax=nmax+1;

dp=zeros(mmax,nmax);
dp(dp==0)=NaN;
dp(1:end-1,1:end-1)=-handles.Model(md).Input(id).DepthZ;
thick=handles.Model(md).Input(id).Thick;

%% Salinity
if handles.Model(md).Input(id).Salinity.Include
    switch lower(handles.Model(md).Input(id).Salinity.ICOpt)
        case{'constant'}
            s=zeros(mmax,nmax,kmax)+handles.Model(md).Input(id).Salinity.ICConst;
        case{'linear'}
            pars=handles.Model(md).Input(id).Salinity.ICPar;
            s=ddb_interpolateInitialConditions(dp,thick,pars,'linear');
        case{'block'}
            pars=handles.Model(md).Input(id).Salinity.ICPar;
            s=ddb_interpolateInitialConditions(dp,thick,pars,'block');
        case{'per layer'}
            for k=1:kmax
                s(:,:,k)=zeros(mmax,nmax)+handles.Model(md).Input(id).Salinity.ICPar(k,1);
            end
    end
    for k=1:kmax
        ddb_wldep('append',fname,squeeze(s(:,:,k)),'negate','n','bndopt','n');
    end
end

%% Temperature
if handles.Model(md).Input(id).Temperature.Include
    switch lower(handles.Model(md).Input(id).Temperature.ICOpt)
        case{'constant'}
            s=zeros(mmax,nmax,kmax)+handles.Model(md).Input(id).Temperature.ICConst;
        case{'linear'}
            pars=handles.Model(md).Input(id).Temperature.ICPar;
            s=ddb_interpolateInitialConditions(dp,thick,pars,'linear');
        case{'block'}
            pars=handles.Model(md).Input(id).Temperature.ICPar;
            s=ddb_interpolateInitialConditions(dp,thick,pars,'block');
        case{'per layer'}
            for k=1:kmax
                s(:,:,k)=zeros(mmax,nmax)+handles.Model(md).Input(id).Temperature.ICPar(k,1);
            end
    end
    for k=1:kmax
        ddb_wldep('append',fname,squeeze(s(:,:,k)),'negate','n','bndopt','n');
    end
end

%% Sediments
if handles.Model(md).Input(id).Sediments
    for i=1:handles.Model(md).Input(id).NrSediments
        switch lower(handles.Model(md).Input(id).Sediment(i).ICOpt)
            case{'constant'}
                s=zeros(mmax,nmax,kmax)+handles.Model(md).Input(id).Sediment(i).ICConst;
            case{'linear'}
                pars=handles.Model(md).Input(id).Sediment(i).ICPar;
                s=ddb_interpolateInitialConditions(dp,thick,pars,'linear');
            case{'block'}
                pars=handles.Model(md).Input(id).Sediment(i).ICPar;
                s=ddb_interpolateInitialConditions(dp,thick,pars,'block');
            case{'per layer'}
                for k=1:kmax
                    s(:,:,k)=zeros(mmax,nmax)+handles.Model(md).Input(id).Sediment(i).ICPar(k,1);
                end
        end
        for k=1:kmax
            ddb_wldep('append',fname,squeeze(s(:,:,k)),'negate','n','bndopt','n');
        end
    end
end

%% Tracers
if handles.Model(md).Input(id).Tracers
    for i=1:handles.Model(md).Input(id).NrTracers
        switch lower(handles.Model(md).Input(id).Tracer(i).ICOpt)
            case{'constant'}
                s=zeros(mmax,nmax,kmax)+handles.Model(md).Input(id).Tracer(i).ICConst;
            case{'linear'}
                pars=handles.Model(md).Input(id).Tracer(i).ICPar;
                s=ddb_interpolateInitialConditions(dp,thick,pars,'linear');
            case{'block'}
                pars=handles.Model(md).Input(id).Tracer(i).ICPar;
                s=ddb_interpolateInitialConditions(dp,thick,pars,'block');
            case{'per layer'}
                for k=1:kmax
                    s(:,:,k)=zeros(mmax,nmax)+handles.Model(md).Input(id).Tracer(i).ICPar(k,1);
                end
        end
        for k=1:kmax
            ddb_wldep('append',fname,squeeze(s(:,:,k)),'negate','n','bndopt','n');
        end
    end
end

close(wb);
