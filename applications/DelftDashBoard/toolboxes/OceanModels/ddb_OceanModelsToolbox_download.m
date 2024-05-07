function ddb_OceanModelsToolbox_download(varargin)

if isempty(varargin)
    % New tab selected
    ddb_zoomOff;
    ddb_refreshScreen;
    ddb_plotOceanModels('activate'); 
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
ii=handles.toolbox.oceanmodels.activeModel;
handles.toolbox.oceanmodels.name=handles.toolbox.oceanmodels.oceanModel(ii).name;
handles.toolbox.oceanmodels.folder=handles.toolbox.oceanmodels.oceanModel(ii).name;
handles.toolbox.oceanmodels.URL=handles.toolbox.oceanmodels.oceanModel(ii).URL;
setHandles(handles);

%%
function changeOutlineOnMap(x0,y0,dx,dy,rotation,h)

setInstructions({'','Left-click and drag markers to change corner points','Right-click and drag yellow marker to move entire box'});

handles=getHandles;
handles.toolbox.oceanmodels.outlineHandle=h;
handles.toolbox.oceanmodels.xLim(1)=x0;
handles.toolbox.oceanmodels.yLim(1)=y0;
handles.toolbox.oceanmodels.xLim(2)=x0+dx;
handles.toolbox.oceanmodels.yLim(2)=y0+dy;

% cs=handles.screenParameters.coordinateSystem;
% dataCoord.name='WGS 84';
% dataCoord.type='geographic';

% % Find bounding box for data
% if ~strcmpi(cs.name,'wgs 84') || ~strcmpi(cs.type,'geographic')
%     ddx=dx/10;
%     ddy=dy/10;
%     [xtmp,ytmp]=meshgrid(x0-ddx:ddx:x0+dx+ddx,y0-ddy:ddy:y0+dy+ddy);
%     [xtmp2,ytmp2]=ddb_coordConvert(xtmp,ytmp,cs,dataCoord);
%     dx=max(max(xtmp2))-min(min(xtmp2));
% end

setHandles(handles);

gui_updateActiveTab;

%%
function editOutline
handles=getHandles;
if ~isempty(handles.toolbox.oceanmodels.outlineHandle)
    try
        delete(handles.toolbox.oceanmodels.outlineHandle);
    end
end
x0=handles.toolbox.oceanmodels.xLim(1);
y0=handles.toolbox.oceanmodels.yLim(1);
dx=handles.toolbox.oceanmodels.xLim(2)-x0;
dy=handles.toolbox.oceanmodels.yLim(2)-y0;

h=UIRectangle(handles.GUIHandles.mapAxis,'plot','Tag','OceanModelOutline','Marker','o','MarkerEdgeColor','k','MarkerSize',6,'rotate',0,'callback',@changeOutlineOnMap, ...
    'onstart',@deleteOutline,'x0',x0,'y0',y0,'dx',dx,'dy',dy);
handles.toolbox.oceanmodels.outlineHandle=h;
setHandles(handles);

%%
function deleteOutline
handles=getHandles;
if ~isempty(handles.toolbox.oceanmodels.outlineHandle)
    try
        delete(handles.toolbox.oceanmodels.outlineHandle);
    end
end

%%
function downloadData

handles=getHandles;

xl=handles.toolbox.oceanmodels.xLim;
yl=handles.toolbox.oceanmodels.yLim;

cs=handles.screenParameters.coordinateSystem;
dataCoord.name='WGS 84';
dataCoord.type='geographic';

% Find bounding box for data
if ~strcmpi(cs.name,'wgs 84') || ~strcmpi(cs.type,'geographic')
    x0=xl(1);
    y0=yl(1);
    dx=(xl(2)-xl(1));
    dy=(yl(2)-yl(1));
    ddx=(xl(2)-xl(1))/10;
    ddy=(yl(2)-yl(1))/10;
    [xtmp,ytmp]=meshgrid(x0-ddx:ddx:x0+dx+ddx,y0-ddy:ddy:y0+dy+ddy);
    [xtmp2,ytmp2]=ddb_coordConvert(xtmp,ytmp,cs,dataCoord);
    xl(1)=min(min(xtmp2));
    yl(1)=min(min(ytmp2));
    xl(2)=max(max(xtmp2));
    yl(2)=max(max(ytmp2));
end

t0=handles.toolbox.oceanmodels.startTime;
t1=handles.toolbox.oceanmodels.stopTime;

url=handles.toolbox.oceanmodels.URL;
outname=handles.toolbox.oceanmodels.name;
outdir=handles.toolbox.oceanmodels.folder;

if ~exist(outdir,'dir')
    mkdir(outdir);
end

ii=handles.toolbox.oceanmodels.activeModel;

np=0;
if handles.toolbox.oceanmodels.getSSH
    np=np+1;
    pars{np}='waterlevel';
end
if handles.toolbox.oceanmodels.getCurrents
    np=np+1;
    pars{np}='current_u';
    np=np+1;
    pars{np}='current_v';
end
if handles.toolbox.oceanmodels.getSalinity
    np=np+1;
    pars{np}='salinity';
end
if handles.toolbox.oceanmodels.getTemperature
    np=np+1;
    pars{np}='temperature';
end

try
    
    switch lower(handles.toolbox.oceanmodels.oceanModel(ii).type)
        case{'hycom'}
            % First download HYCOM grid if it doesn't exist yet
            localdir=handles.toolbox.oceanmodels.dataDir;
            filename = 'hycom.nc';
            if ~exist([localdir filename],'file')
                remotedir='http://opendap.deltares.nl/thredds/fileServer/opendap/deltares/delftdashboard/oceanmodels/hycom/';
                try
                    wb = waitbox('Downloading HYCOM grid info. This may take a few minutes...');
%                     urlwrite([remotedir filename],[localdir filename]);
                    urlwrite([remotedir filename],[localdir filename]);
                    close(wb);
                catch
                    close(wb);
                    giveWarning('text','Could not download HYCOM grid info from OPeNDAP server!');
                    return
                end
            end
            %load([localdir filename]);
            s.lat = nc_varget([localdir filename],'lat',[0 0],[2500 3500]);
            s.lon = nc_varget([localdir filename],'lon',[0 0],[2500 3500]);
            s.d = nc_varget([localdir filename],'depth');
            wb = waitbox('Downloading data ...');
            for ip=1:length(pars)
                getHYCOM3(url,outname,outdir,pars{ip},xl,yl,0.1,0.1,[t0 t1],s);
%                getHYCOM_reanalysis(url,outname,outdir,pars{ip},xl,yl,0.1,0.1,[t0 t1],s);
%                getHYCOM4_regular_grid(url,outname,outdir,pars{ip},xl,yl,0.1,0.1,[t0 t1],s);
            end
            close(wb);
        case{'hycom_rectangular'}
            % First download HYCOM grid if it doesn't exist yet
            wb = waitbox('Downloading data ...');
            for ip=1:length(pars)
                getHYCOM4_rectangular_grid(url,outname,outdir,pars{ip},xl,yl,[t0 t1]);
            end
            close(wb);
        case{'ncom'}
            % Get lon, lat, depth
            wb = waitbox('Downloading data ...');
            cycstr=datestr(floor(t0),'yyyymmddHH');
            ireg=str2double(handles.toolbox.oceanmodels.oceanModel(ii).region);
            ncname=['ncom_glb_regp' num2str(ireg,'%0.2i') '_' cycstr '.nc'];
            url=[handles.toolbox.oceanmodels.oceanModel(ii).URL '/' ncname];
            [lon,lat,levels]=getNCOM(url,'salinity',xl,yl,[t0 t0]);
            % Now get the data
            lastCycle=floor(now+10/24);
            for t=floor(t0):min(floor(t1),lastCycle)
%            for t=floor(t0):min(floor(t0),lastCycle)
                t00=t;
                if t<lastCycle
                    % Not yet in last available cycle
%                    t11=min(t00+1+21/24,t1);
                    t11=min(t00+21/24,t1);
%                    t11=t00+1+21/24;
                else
                    t11=t1;
                end
                cycstr=datestr(t,'yyyymmddHH');
                ncname=['ncom_glb_regp' num2str(ireg,'%0.2i') '_' cycstr '.nc'];
                url=[handles.toolbox.oceanmodels.oceanModel(ii).URL '/' ncname];
                try
                    for ip=1:length(pars)
                        getNCOM(url,pars{ip},xl,yl,[t00 t11],'outputfile',outname,'outputdir',outdir,'lon',lon,'lat',lat,'depth',levels);
                    end
                end
            end
            close(wb);
    end
catch
    close(wb);
    ddb_giveWarning('text','An error occured while downloading data');
end
