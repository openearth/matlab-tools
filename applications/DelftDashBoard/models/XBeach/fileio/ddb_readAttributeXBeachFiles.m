function handles=ddb_readAttributeXBeachFiles(handles,pathname)

ii=strmatch('XBeach',{handles.Model.name},'exact');
             
id=handles.activeDomain;

% Grid file % NEED TO INCLUDE DELFT3D-TYPE GRIDS
if handles.Model(ii).Input(id).vardx==1
    % Irregular grid
    X=load([pathname,handles.Model(ii).Input(id).xfile]);
    handles.Model(ii).Input(id).GridX=X;
    Y=load([pathname,handles.Model(ii).Input(id).yfile]);    
    handles.Model(ii).Input(id).GridY=Y;
    nx = size(X,2)-1;
    ny = size(X,1)-1;
%     handles=ddb_determineKCS(handles,id);
    nans=zeros(size(handles.Model(ii).Input(id).GridX));
    nans(nans==0)=NaN;
    handles.Model(ii).Input(id).Depth=nans;
    handles.Model(ii).Input(id).DepthZ=nans;
elseif handles.Model(ii).Input(id).vardx==0
    % Regular grid
    dx = handles.Model(ii).Input(id).dx;
    dy = handles.Model(ii).Input(id).dy;
    nx = handles.Model(ii).Input(id).nx;
    ny = handles.Model(ii).Input(id).ny;
    x = dx*[0:1:nx];
    y = dx*[0:1:ny];
    [X,Y] = meshgrid(x,y);
    handles.Model(ii).Input(id).GridX=X;
    handles.Model(ii).Input(id).GridY=Y;
    
    nans=zeros(size(handles.Model(ii).Input(id).GridX));
    nans(nans==0)=NaN;
    handles.Model(ii).Input(id).Depth=nans;
    handles.Model(ii).Input(id).DepthZ=nans;
end

% % Depfile
if ~strcmp(handles.Model(ii).Input(id).depfile,'file')
    dp=load([pathname,handles.Model(ii).Input(id).depfile]);
    handles.Model(ii).Input(id).Depth = -dp(1:ny+1,1:nx+1);
end

% % NE-file
if ~strcmp(handles.Model(ii).Input(id).ne_layer,'file')
    ne=load([pathname,handles.Model(ii).Input(id).ne_layer]);
    handles.Model(ii).Input(id).SedThick = ne(1:ny+1,1:nx+1);
end

% Friction file % TODO

% Vegetation file % TODO

% Water level boundary condition
if ~strcmp(handles.Model(ii).Input(id).zs0file,'file')
    zsdat=load([pathname,handles.Model(ii).Input(id).zs0file]);
    
    handles.Model(ii).Input(id).zs0file.time = zsdat(:,1);
    handles.Model(ii).Input(id).zs0file.data = zsdat(:,2:end);
end

% Read boundarylist file and wave conditions...
xbs = xb_read_waves([pathname handles.Model(md).Input(handles.activeDomain).bcfile]);
ddb_xbmi.bcfile.filename = handles.Model(md).Input(handles.activeDomain).bcfile;
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
