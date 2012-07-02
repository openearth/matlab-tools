function ddb_Delft3DWAVE_obstacles(varargin)

handles=getHandles;

if isempty(varargin)
    ddb_zoomOff;
    ddb_refreshScreen;
    ddb_Delft3DWAVE_plotObstacles(handles,'update');
else
    opt=varargin{1};
    switch lower(opt)
        case{'addobstacle'}
            drawObstacle;
        case{'selectobstacle'}
            ddb_Delft3DWAVE_plotObstacles(handles,'update');
        case{'changeobstacle'}
            x=varargin{2};
            y=varargin{3};
            h=varargin{4};
            changeObstacle(x,y,h);
        case{'editobstacletable'}
            editObstacleCoordinates;
        case{'loadobsfile'}
            loadObstaclesFile;
        case{'saveobsfile'}
            saveObstaclesFile;
        case{'loadpolylinesfile'}
            loadObstaclePolylinesFile;
        case{'savepolylinesfile'}
            saveObstaclePolylinesFile;
        case{'deleteobstacle'}
            deleteObstacle;
        case{'selecttype'}
            selectObstacleType;
        case{'selectreflections'}
            selectReflections;
        case{'selectreflectioncoefficient'}
            selectReflectionCoefficient;
        case{'selecttransmissioncoefficient'}
            selectTransmissionCoefficient;
        case{'selectheight'}
            selectHeight;
        case{'selectalpha'}
            selectAlpha;
        case{'selectbeta'}
            selectBeta;
        case{'copyfromflow'}
            copyFromFlow;
    end
end

%%
function selectObstacleType
handles=getHandles;
val=handles.Model(md).Input.obstacles(handles.Model(md).Input.activeobstacle).type;
iac=handles.Model(md).Input.activeobstacles;
for ii=1:length(iac)
    n=iac(ii);
    handles.Model(md).Input.obstacles(n).type=val;
end
setHandles(handles);

%%
function selectReflections
handles=getHandles;
val=handles.Model(md).Input.obstacles(handles.Model(md).Input.activeobstacle).reflections;
iac=handles.Model(md).Input.activeobstacles;
for ii=1:length(iac)
    n=iac(ii);
    handles.Model(md).Input.obstacles(n).reflections=val;
end
setHandles(handles);

%%
function selectReflectionCoefficient
handles=getHandles;
val=handles.Model(md).Input.obstacles(handles.Model(md).Input.activeobstacle).refleccoef;
iac=handles.Model(md).Input.activeobstacles;
for ii=1:length(iac)
    n=iac(ii);
    handles.Model(md).Input.obstacles(n).refleccoef=val;
end
setHandles(handles);

%%
function selectTransmissionCoefficient
handles=getHandles;
val=handles.Model(md).Input.obstacles(handles.Model(md).Input.activeobstacle).transmcoef;
iac=handles.Model(md).Input.activeobstacles;
for ii=1:length(iac)
    n=iac(ii);
    handles.Model(md).Input.obstacles(n).transmcoef=val;
end
setHandles(handles);

%%
function selectHeight
handles=getHandles;
val=handles.Model(md).Input.obstacles(handles.Model(md).Input.activeobstacle).height;
iac=handles.Model(md).Input.activeobstacles;
for ii=1:length(iac)
    n=iac(ii);
    handles.Model(md).Input.obstacles(n).height=val;
end
setHandles(handles);

%%
function selectAlpha
handles=getHandles;
val=handles.Model(md).Input.obstacles(handles.Model(md).Input.activeobstacle).alpha;
iac=handles.Model(md).Input.activeobstacles;
for ii=1:length(iac)
    n=iac(ii);
    handles.Model(md).Input.obstacles(n).alpha=val;
end
setHandles(handles);

%%
function selectBeta
handles=getHandles;
val=handles.Model(md).Input.obstacles(handles.Model(md).Input.activeobstacle).beta;
iac=handles.Model(md).Input.activeobstacles;
for ii=1:length(iac)
    n=iac(ii);
    handles.Model(md).Input.obstacles(n).beta=val;
end
setHandles(handles);

%%
function drawObstacle

ddb_zoomOff;
gui_polyline('draw','tag','delft3dwaveobstacle','Marker','o','createcallback',@addObstacle,'changecallback',@changeObstacle,'closed',0, ...
    'color','r','markeredgecolor','r','markerfacecolor','r');

%%
function addObstacle(h,x,y,nr)

handles=getHandles;
handles.Model(md).Input.nrobstacles=handles.Model(md).Input.nrobstacles+1;
nrobs=handles.Model(md).Input.nrobstacles;
handles.Model(md).Input.obstacles=ddb_initializeDelft3DWAVEObstacle(handles.Model(md).Input.obstacles,nrobs);
handles.Model(md).Input.obstacles(nrobs).name=['Obstacle ' num2str(nrobs)];
handles.Model(md).Input.obstacles(nrobs).handle=h;
handles.Model(md).Input.activeobstacle=nrobs;
handles.Model(md).Input.activeobstacles=handles.Model(md).Input.activeobstacle;
handles.Model(md).Input.obstaclenames{nrobs}=handles.Model(md).Input.obstacles(nrobs).name;
handles.Model(md).Input.obstacles(nrobs).x=x;
handles.Model(md).Input.obstacles(nrobs).y=y;
setHandles(handles);

ddb_Delft3DWAVE_plotObstacles(handles,'update');

gui_updateActiveTab;

%%
function changeObstacle(h,x,y,nr)

iac=[];
handles=getHandles;
for ii=1:length(handles.Model(md).Input.obstacles)
    if handles.Model(md).Input.obstacles(ii).handle==h
        iac=ii;
        break
    end
end
if ~isempty(iac)
    handles.Model(md).Input.activeobstacle=iac;
    handles.Model(md).Input.obstacles(iac).x=x;
    handles.Model(md).Input.obstacles(iac).y=y;
end

setHandles(handles);

ddb_Delft3DWAVE_plotObstacles(handles,'update');

gui_updateActiveTab;

%%
function deleteObstacle

handles=getHandles;
if handles.Model(md).Input.nrobstacles>0
    iac=handles.Model(md).Input.activeobstacle;
    try
        delete(handles.Model(md).Input.obstacles(iac).handle);
    end
    handles.Model(md).Input.obstacles=removeFromStruc(handles.Model(md).Input.obstacles,iac);
    handles.Model(md).Input.obstaclenames=removeFromCellArray(handles.Model(md).Input.obstaclenames,iac);
    handles.Model(md).Input.nrobstacles=handles.Model(md).Input.nrobstacles-1;
    handles.Model(md).Input.activeobstacle=max(min(handles.Model(md).Input.activeobstacle,handles.Model(md).Input.nrobstacles),1);
    handles.Model(md).Input.activeobstacles=handles.Model(md).Input.activeobstacle;
    if handles.Model(md).Input.nrobstacles==0
        handles.Model(md).Input.obstacles=ddb_initializeDelft3DWAVEObstacle(handles.Model(md).Input.obstacles,1);
    end
    setHandles(handles);
    gui_updateActiveTab;
    ddb_Delft3DWAVE_plotObstacles(handles,'update');
end

%% 
function editObstacleCoordinates
handles=getHandles;
% Re-plot all obstacles
handles=ddb_Delft3DWAVE_plotObstacles(handles,'plot');
setHandles(handles);



%%
function loadObstaclePolylinesFile
handles=getHandles;

nrobs=handles.Model(md).Input.nrobstacles;

if nrobs>0
    ButtonName = questdlg('Overwrite existing obstacles?', ...
        'Overwrite existing obstacles', ...
        'No', 'Yes', 'Yes');
    switch ButtonName,
        case 'No'
            nrobs=handles.Model(md).Input.nrobstacles;
        case 'Yes'
            nrobs=0;
            handles=ddb_Delft3DWAVE_plotObstacles(handles,'delete');
    end
end

obs=[];
obs=ddb_Delft3DWAVE_readObstaclePolylineFile(obs,handles.Model(md).Input.obstaclepolylinesfile);
handles.Model(md).Input.nrobstacles=nrobs+length(obs);
if nrobs==0
    handles.Model(md).Input.obstacles=[];
    handles.Model(md).Input.obstaclenames={''};
end
handles.Model(md).Input.activeobstacle=1;
handles.Model(md).Input.activeobstacles=1;
for ii=1:length(obs)
    handles.Model(md).Input.obstacles=ddb_initializeDelft3DWAVEObstacle(handles.Model(md).Input.obstacles,nrobs+ii);
    handles.Model(md).Input.obstacles(nrobs+ii).name=obs(ii).name;
    handles.Model(md).Input.obstacles(nrobs+ii).x=obs(ii).x;
    handles.Model(md).Input.obstacles(nrobs+ii).y=obs(ii).y;
    handles.Model(md).Input.obstaclenames{nrobs+ii}=obs(ii).name;
end
handles=ddb_Delft3DWAVE_plotObstacles(handles,'plot');
setHandles(handles);

%%
function loadObstaclesFile

handles=getHandles;

obs=[];
[obs,plifile]=ddb_Delft3DWAVE_readObstacleFile(obs,handles.Model(md).Input.obstaclefile);
handles.Model(md).Input.obstaclepolylinesfile=plifile;
handles.Model(md).Input.obstacles=obs;
handles.Model(md).Input.nrobstacles=length(obs);
handles.Model(md).Input.activeobstacle=1;
for ii=1:length(obs)
    handles.Model(md).Input.obstaclenames{ii}=obs(ii).name;
end
handles=ddb_Delft3DWAVE_plotObstacles(handles,'plot');

setHandles(handles);
gui_updateActiveTab;

%%
function saveObstaclesFile
handles=getHandles;
[filename, pathname, filterindex] = uiputfile('*.pli','Select Obstacles Polylines File',handles.Model(md).Input.obstaclepolylinesfile);
if pathname~=0
    curdir=[lower(cd) '\'];
    if ~strcmpi(curdir,pathname)
        filename=[pathname filename];
    end
    handles.Model(md).Input.obstaclepolylinesfile=filename;
    setHandles(handles);
else
    return
end
ddb_Delft3DWAVE_saveObstacleFile(handles);

%%
function copyFromFlow

handles=getHandles;

if length(handles.Model(1).Input(1).thinDams)>0

    xg=handles.Model(1).Input(1).gridX;
    yg=handles.Model(1).Input(1).gridY;
    for ii=1:length(handles.Model(1).Input(1).thinDams)
        
        m1=handles.Model(1).Input(1).thinDams(ii).M1;
        m2=handles.Model(1).Input(1).thinDams(ii).M2;
        n1=handles.Model(1).Input(1).thinDams(ii).N1;
        n2=handles.Model(1).Input(1).thinDams(ii).N2;
        x(1)=xg(m1,n1);
        x(2)=xg(m2,n2);
        y(1)=yg(m1,n1);
        y(2)=yg(m2,n2);
        
        nrobs=handles.Model(md).Input.nrobstacles;
        handles.Model(md).Input.nrobstacles=nrobs+1;
        if nrobs==0
            handles.Model(md).Input.obstacles=[];
            handles.Model(md).Input.obstaclenames={''};
        end
        handles.Model(md).Input.activeobstacle=1;
        handles.Model(md).Input.activeobstacles=1;
        
        handles.Model(md).Input.obstacles=ddb_initializeDelft3DWAVEObstacle(handles.Model(md).Input.obstacles,nrobs+1);
        handles.Model(md).Input.obstacles(nrobs+1).name=['Obstacle from FLOW ' num2str(ii)];
        handles.Model(md).Input.obstacles(nrobs+1).x=x;
        handles.Model(md).Input.obstacles(nrobs+1).y=y;
        handles.Model(md).Input.obstaclenames{nrobs+1}=handles.Model(md).Input.obstacles(nrobs+1).name;
        
    end
    
    handles=ddb_Delft3DWAVE_plotObstacles(handles,'plot');
    
    setHandles(handles);

end

