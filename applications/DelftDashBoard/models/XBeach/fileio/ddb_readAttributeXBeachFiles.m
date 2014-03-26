function handles=ddb_readAttributeXBeachFiles(handles,pathname)
            
id=handles.activeDomain;

% Grid file % NEED TO INCLUDE DELFT3D-TYPE GRIDS
if handles.model.xbeach.domain(id).vardx==1
    % Irregular grid
    X=load([pathname,handles.model.xbeach.domain(id).xfile]);
    handles.model.xbeach.domain(id).GridX=X;
    Y=load([pathname,handles.model.xbeach.domain(id).yfile]);    
    handles.model.xbeach.domain(id).GridY=Y;
    nx = size(X,2)-1;
    ny = size(X,1)-1;
%     handles=ddb_determineKCS(handles,id);
    nans=zeros(size(handles.model.xbeach.domain(id).GridX));
    nans(nans==0)=NaN;
    handles.model.xbeach.domain(id).Depth=nans;
    handles.model.xbeach.domain(id).DepthZ=nans;
elseif handles.model.xbeach.domain(id).vardx==0
    % Regular grid
    dx = handles.model.xbeach.domain(id).dx;
    dy = handles.model.xbeach.domain(id).dy;
    nx = handles.model.xbeach.domain(id).nx;
    ny = handles.model.xbeach.domain(id).ny;
    x = dx*[0:1:nx];
    y = dx*[0:1:ny];
    [X,Y] = meshgrid(x,y);
    handles.model.xbeach.domain(id).GridX=X;
    handles.model.xbeach.domain(id).GridY=Y;
    
    nans=zeros(size(handles.model.xbeach.domain(id).GridX));
    nans(nans==0)=NaN;
    handles.model.xbeach.domain(id).Depth=nans;
    handles.model.xbeach.domain(id).DepthZ=nans;
end

% % Depfile
if ~strcmp(handles.model.xbeach.domain(id).depfile,'file')
    dp=load([pathname,handles.model.xbeach.domain(id).depfile]);
    handles.model.xbeach.domain(id).Depth = -dp(1:ny+1,1:nx+1);
end

% % NE-file
if ~strcmp(handles.model.xbeach.domain(id).ne_layer,'file')
    ne=load([pathname,handles.model.xbeach.domain(id).ne_layer]);
    handles.model.xbeach.domain(id).SedThick = ne(1:ny+1,1:nx+1);
end

% Friction file % TODO

% Vegetation file % TODO

% Water level boundary condition
if ~strcmp(handles.model.xbeach.domain(id).zs0file,'file')
    zsdat=load([pathname,handles.model.xbeach.domain(id).zs0file]);
    
    handles.model.xbeach.domain(id).zs0file.time = zsdat(:,1);
    handles.model.xbeach.domain(id).zs0file.data = zsdat(:,2:end);
end

% Read boundarylist file and wave conditions...
xbs = xb_read_waves([pathname handles.model.xbeach.domain(handles.activeDomain).bcfile]);
ddb_xbmi.bcfile.filename = handles.model.xbeach.domain(handles.activeDomain).bcfile;
noCon = 0;
for j = 1:length(xbs.data)% check how many wave conditions are specified
    noCon = max(noCon,length(xbs.data(j).value));
end
for j = 1:length(xbs.data)
    ddb_xbmi.bcfile.(xbs.data(j).name) = xbs.data(j).value;
    if isnumeric(ddb_xbmi.bcfile.(xbs.data(j).name))
        ddb_xbmi.bcfile.(xbs.data(j).name) = ones(1,noCon).*ddb_xbmi.bcfile.(xbs.data(j).name);
    end
end

%CONTINUE HER
% Replace default values with model input
fieldNames = fieldnames(ddb_xbmi);
for i = 1:size(fieldNames,1)
    handles.Model(handles.activeModel.nr).Input(handles.activeDomain).(fieldNames{i}) = ddb_xbmi.(fieldNames{i});
end
