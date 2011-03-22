function ddb_Delft3DFLOW_grid(varargin)

if isempty(varargin)
    ddb_zoomOff;
    ddb_refreshScreen;
    setUIElements('delft3dflow.domain.domainpanel.grid');
else
    opt=varargin{1};
    switch lower(opt)
        case{'selectgrid'}
            selectGrid;
        case{'selectenclosure'}
            selectEnclosure;
        case{'generatelayers'}
            generateLayers;
        case{'editkmax'}
            editKMax;
        case{'changelayers'}
            changeLayers;
        case{'loadlayers'}
            loadLayers;
        case{'savelayers'}
            saveLayers;
    end
end

%%
function selectGrid
handles=getHandles;
filename=handles.Model(md).Input(ad).grdFile;
[x,y,enc]=ddb_wlgrid('read',filename);
handles.Model(md).Input(ad).gridX=x;
handles.Model(md).Input(ad).gridY=y;
handles.Model(md).Input(ad).MMax=size(x,1)+1;
handles.Model(md).Input(ad).NMax=size(x,2)+1;
[handles.Model(md).Input(ad).gridXZ,handles.Model(md).Input(ad).gridYZ]=GetXZYZ(x,y);
handles=ddb_determineKCS(handles,ad);
nans=zeros(size(handles.Model(md).Input(ad).gridX));
nans(nans==0)=NaN;
handles.Model(md).Input(ad).depth=nans;
handles.Model(md).Input(ad).depthZ=nans;
setHandles(handles);
setUIElement('delft3dflow.domain.domainpanel.grid.textgridm');
setUIElement('delft3dflow.domain.domainpanel.grid.textgridn');
handles=getHandles;
handles=ddb_Delft3DFLOW_plotGrid(handles,'plot');
setHandles(handles);

%%
function selectEnclosure
handles=getHandles;
mn=ddb_enclosure('read',handles.Model(md).Input(ad).encFile);
[handles.Model(md).Input(ad).gridX,handles.Model(md).Input(ad).gridY]=ddb_enclosure('apply',mn,handles.Model(md).Input(ad).gridX,handles.Model(md).Input(ad).gridY);
[handles.Model(md).Input(ad).gridXZ,handles.Model(md).Input(ad).gridYZ]=GetXZYZ(handles.Model(md).Input(ad).gridX,handles.Model(md).Input(ad).gridY);
setHandles(handles);

%%
function generateLayers

%%
function changeLayers
handles=getHandles;
handles.Model(md).Input(ad).sumLayers=sum(handles.Model(md).Input(ad).thick);
setHandles(handles);
setUIElement('delft3dflow.domain.domainpanel.grid.sumlayers');

%%
function loadLayers

%%
function saveLayers

%%
function editKMax
handles=getHandles;
kmax0=handles.Model(md).Input(ad).lastKMax;
kmax=handles.Model(md).Input(ad).KMax;
if kmax~=kmax0
    handles.Model(md).Input(ad).lastKMax=kmax;
    handles.Model(md).Input(ad).thick=[];
    if kmax==1
        handles.Model(md).Input(ad).thick=100;
    else
        for i=1:kmax
            thick(i)=0.01*round(100*100/kmax);
        end
        sumlayers=sum(thick);
        dif=sumlayers-100;
        thick(kmax)=thick(kmax)-dif;
        for i=1:kmax
            handles.Model(md).Input(ad).thick(i)=thick(i);
        end
    end
    setHandles(handles);
    handles.Model(md).Input(ad).sumLayers=sum(handles.Model(md).Input(ad).thick);
    setUIElement('delft3dflow.domain.domainpanel.grid.sumlayers');
    setUIElement('delft3dflow.domain.domainpanel.grid.layertable');
end

