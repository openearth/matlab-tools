function ddb_OceanModelsToolbox_download(varargin)

if isempty(varargin)
    % New tab selected
    ddb_zoomOff;
    ddb_refreshScreen;
    ddb_plotOceanModels('activate'); 
    setUIElements('oceanmodelspanel.download');
else
    %Options selected
    opt=lower(varargin{1});
    handles=getHandles;
    switch opt
        case{'nesthd1'}
            nestHD1;
        case{'drawrectangle'}
            setInstructions({'','','Use mouse to model limits on map'});
            UIRectangle(handles.GUIHandles.mapAxis,'draw','Tag','OceanModelOutline','Marker','o','MarkerEdgeColor','k','MarkerSize',6,'rotate',0,'callback',@changeOutlineOnMap,'onstart',@deleteOutline);
        case{'editoutline'}
            editOutline;
        case{'selectoceanmodel'}
            selectOceanModel;
        case{'download'}
            downloadData;
    end    
end

%%
function selectOceanModel
handles=getHandles;
ii=handles.Toolbox(tb).Input.activeModel;
handles.Toolbox(tb).Input.name=handles.Toolbox(tb).Input.oceanModel(ii).name;
handles.Toolbox(tb).Input.folder=handles.Toolbox(tb).Input.oceanModel(ii).name;
handles.Toolbox(tb).Input.URL=handles.Toolbox(tb).Input.oceanModel(ii).URL;
setHandles(handles);
setUIElement('oceanmodelspanel.download.editname');
setUIElement('oceanmodelspanel.download.editfolder');
setUIElement('oceanmodelspanel.download.editurl');

%%
function changeOutlineOnMap(x0,y0,dx,dy,rotation,h)

setInstructions({'','Left-click and drag markers to change corner points','Right-click and drag yellow marker to move entire box'});

handles=getHandles;
handles.Toolbox(tb).Input.outlineHandle=h;
handles.Toolbox(tb).Input.xLim(1)=x0;
handles.Toolbox(tb).Input.yLim(1)=y0;
handles.Toolbox(tb).Input.xLim(2)=x0+dx;
handles.Toolbox(tb).Input.yLim(2)=y0+dy;

cs=handles.screenParameters.coordinateSystem;
dataCoord.name='WGS 84';
dataCoord.type='geographic';

% Find bounding box for data
if ~strcmpi(cs.name,'wgs 84') || ~strcmpi(cs.type,'geographic')
    ddx=dx/10;
    ddy=dy/10;
    [xtmp,ytmp]=meshgrid(x0-ddx:ddx:x0+dx+ddx,y0-ddy:ddy:y0+dy+ddy);
    [xtmp2,ytmp2]=ddb_coordConvert(xtmp,ytmp,cs,dataCoord);
    dx=max(max(xtmp2))-min(min(xtmp2));
end

setHandles(handles);
setUIElement('oceanmodelspanel.download.editxmin');
setUIElement('oceanmodelspanel.download.editxmax');
setUIElement('oceanmodelspanel.download.editymin');
setUIElement('oceanmodelspanel.download.editymax');

%%
function editOutline
handles=getHandles;
if ~isempty(handles.Toolbox(tb).Input.outlineHandle)
    try
        delete(handles.Toolbox(tb).Input.outlineHandle);
    end
end
x0=handles.Toolbox(tb).Input.xLim(1);
y0=handles.Toolbox(tb).Input.yLim(1);
dx=handles.Toolbox(tb).Input.xLim(2)-x0;
dy=handles.Toolbox(tb).Input.yLim(2)-y0;

h=UIRectangle(handles.GUIHandles.mapAxis,'plot','Tag','OceanModelOutline','Marker','o','MarkerEdgeColor','k','MarkerSize',6,'rotate',0,'callback',@changeOutlineOnMap, ...
    'onstart',@deleteOutline,'x0',x0,'y0',y0,'dx',dx,'dy',dy);
handles.Toolbox(tb).Input.outlineHandle=h;
setHandles(handles);

%%
function deleteOutline
handles=getHandles;
if ~isempty(handles.Toolbox(tb).Input.outlineHandle)
    try
        delete(handles.Toolbox(tb).Input.outlineHandle);
    end
end

%%
function downloadData

handles=getHandles;

xl=handles.Toolbox(tb).Input.xLim;
yl=handles.Toolbox(tb).Input.yLim;
t0=handles.Toolbox(tb).Input.startTime;
t1=handles.Toolbox(tb).Input.stopTime;

url=handles.Toolbox(tb).Input.URL;
outname=handles.Toolbox(tb).Input.name;
outdir=handles.Toolbox(tb).Input.folder;

if ~isdir(outdir)
    mkdir(outdir);
end

ii=handles.Toolbox(tb).Input.activeModel;

np=0;
if handles.Toolbox(tb).Input.getSSH
    np=np+1;
    pars{np}='waterlevel';
end
if handles.Toolbox(tb).Input.getCurrents
    np=np+1;
    pars{np}='current_u';
    np=np+1;
    pars{np}='current_v';
end
if handles.Toolbox(tb).Input.getSalinity
    np=np+1;
    pars{np}='salinity';
end
if handles.Toolbox(tb).Input.getTemperature
    np=np+1;
    pars{np}='temperature';
end

try
    
    switch lower(handles.Toolbox(tb).Input.oceanModel(ii).type)
        case{'hycom'}
            % First download HYCOM grid if it doesn't exist yet
            localdir=handles.Toolbox(tb).dataDir;
            filename='hycom.mat';
            if ~exist([localdir filename],'file')
                remotedir='http://opendap.deltares.nl/thredds/fileServer/opendap/deltares/delftdashboard/oceanmodels/hycom/';
                try
                    wb = waitbox('Downloading HYCOM grid info. This may take a few minutes...');
                    urlwrite([remotedir filename],[localdir filename]); 
                    close(wb);
                catch
                    close(wb);
                    giveWarning('text','Could not download HYCOM grid info from OPeNDAP server!');
                    return
                end
            end
            load([localdir filename]);
            wb = waitbox('Downloading data ...');
            for ip=1:length(pars)
                getHYCOM(url,outname,outdir,pars{ip},xl,yl,0.1,0.1,[t0 t1],s);
            end
            close(wb);
        case{'ncom'}
            % Get lon, lat, depth
            wb = waitbox('Downloading data ...');
            cycstr=datestr(floor(t0),'yyyymmddHH');
            ireg=str2double(handles.Toolbox(tb).Input.oceanModel(ii).region);
            ncname=['ncom_glb_regp' num2str(ireg,'%0.2i') '_' cycstr '.nc'];
            url=[handles.Toolbox(tb).Input.oceanModel(ii).URL '/' ncname];
            [lon,lat,levels]=getNCOM(url,'salinity',xl,yl,[t0 t1]);
            % Now get the data
            lastCycle=floor(now+10/24);
            for t=floor(t0):min(floor(t1),lastCycle)
                t00=t;
                if t<lastCycle
                    % Not yet in last available cycle
                    t11=min(t00+21/24,t1);
                else
                    t11=t1;
                end
                cycstr=datestr(t,'yyyymmddHH');
                ncname=['ncom_glb_regp' num2str(ireg,'%0.2i') '_' cycstr '.nc'];
                url=[handles.Toolbox(tb).Input.oceanModel(ii).URL '/' ncname];
                for ip=1:length(pars)
                    getNCOM(url,pars{ip},xl,yl,[t00 t11],'outputfile',outname,'outputdir',outdir,'lon',lon,'lat',lat,'depth',levels);
                end
            end
            close(wb);
    end
catch
    close(wb);
    giveWarning('text','An error occured while downloading data');
end
