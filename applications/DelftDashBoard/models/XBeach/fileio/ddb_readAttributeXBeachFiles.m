function handles=ddb_readAttributeXBeachFiles(handles,pathname)

ii=strmatch('XBeach',{handles.Model.Name},'exact');
             
id=handles.ActiveDomain;

if handles.Model(ii).Input(id).vardx==1
    X=load([pathname,handles.Model(ii).Input(id).xfile]);
    handles.Model(ii).Input(id).GridX=X;
    Y=load([pathname,handles.Model(ii).Input(id).yfile]);    
    handles.Model(ii).Input(id).GridY=Y;
    nx = size(X,2)-1;
    ny = size(X,1)-1;
    handles=ddb_determineKCS(handles);
    nans=zeros(size(handles.Model(ii).Input(id).GridX));
    nans(nans==0)=NaN;
    handles.Model(ii).Input(id).Depth=nans;
    handles.Model(ii).Input(id).DepthZ=nans;
elseif handles.Model(ii).Input(id).vardx==0
    % regular grid
    dx = handles.Model(ii).Input(id).dx;
    dy = handles.Model(ii).Input(id).dy;
    nx = handles.Model(ii).Input(id).nx;
    ny = handles.Model(ii).Input(id).ny;
    x = dx*[0:1:nx];
    y = dx*[0:1:ny];
    [X,Y] = meshgrid(x,y);
    handles.Model(ii).Input(id).GridX=X;
    handles.Model(ii).Input(id).GridY=Y;
end

if ~isempty(handles.Model(ii).Input(id).depfile)
    dp=load([pathname,handles.Model(ii).Input(id).depfile]);
    handles.Model(ii).Input(id).Depth = -dp(1:ny+1,1:nx+1)*handles.Model(ii).Input(id).posdwn;
end

% Read boundarylist file and wave conditions...
