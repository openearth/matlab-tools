function ddb_DFlowFM_boundaries(varargin)

handles=getHandles;

if isempty(varargin)
    ddb_zoomOff;
    ddb_refreshScreen;
    ddb_DFlowFM_plotBoundaries(handles,'update','active',1);
else
    opt=varargin{1};
    switch lower(opt)
        case{'selectboundary'}
            ddb_DFlowFM_plotBoundaries(handles,'update');
        case{'changeboundary'}
            h=varargin{2};
            x=varargin{3};
            y=varargin{4};
            nr=varargin{5};
            changeBoundary(h,x,y,nr);
        case{'editname'}
            editName;
        case{'add'}
            drawBoundary;
        case{'delete'}
            deleteBoundary;
        case{'load'}
            loadBoundary;
        case{'save'}
            saveBoundary;
        case{'saveall'}
            saveAllBoundaries;
        case{'openexternalforcing'}
            openExternalForcing;
        case{'saveexternalforcing'}
            saveExternalForcing;
    end
end

%%
function editName
handles=getHandles;
iac=handles.Model(md).Input.activeboundary;
oriname=handles.Model(md).Input.boundarynames{iac};
name=handles.Model(md).Input.boundaries(iac).name;
% Check for spaces
if isempty(find(name==' ', 1));
    handles.Model(md).Input.boundaries(iac).filename=[name '.pli'];
    handles=updateNames(handles);
else
    ddb_giveWarning('text','Sorry, boundary names cannot contain spaces!');
    handles.Model(md).Input.boundaries(iac).name=oriname;
end
setHandles(handles);

%%
function drawBoundary
ddb_zoomOff;
setInstructions({'','','Draw boundary polyline'});
gui_polyline('draw','tag','dflowfmboundary','Marker','o','createcallback',@addBoundary,'changecallback',@changeBoundary,'closed',0, ...
    'color','g','markeredgecolor','r','markerfacecolor','r');

%%
function addBoundary(h,x,y,nr)
clearInstructions;

handles=getHandles;

nr=handles.Model(md).Input.nrboundaries;
nr=nr+1;

handles.Model(md).Input.nrboundaries=nr;

handles.Model(md).Input.boundaries=ddb_DFlowFM_initializeBoundary(handles.Model(md).Input.boundaries,x,y,['bnd_' num2str(nr,'%0.3i')],nr, ...
    handles.Model(md).Input.tstart,handles.Model(md).Input.tstop);

handles=updateNames(handles);

handles.Model(md).Input.boundaries(nr).handle=h;

% if nr>1
%     % Copy from existing boundary
%     handles.Model(md).Input.boundaries(nr).definition=handles.Model(md).Input.boundaries(handles.Model(md).Input.activeboundary).definition;
% end
handles.Model(md).Input.activeboundary=nr;

setHandles(handles);

ddb_DFlowFM_plotBoundaries(handles,'update');

gui_updateActiveTab;

%%
function deleteBoundary

clearInstructions;

handles=getHandles;

if handles.Model(md).Input.nrboundaries>0

    iac=handles.Model(md).Input.activeboundary;
    try
        delete(handles.Model(md).Input.boundaries(iac).handle);
    end
    handles.Model(md).Input.boundaries=removeFromStruc(handles.Model(md).Input.boundaries,iac);
    handles.Model(md).Input.nrboundaries=handles.Model(md).Input.nrboundaries-1;
    handles.Model(md).Input.activeboundary=max(min(handles.Model(md).Input.activeboundary,handles.Model(md).Input.nrboundaries),1);
    handles.Model(md).Input.activeboundaries=handles.Model(md).Input.activeboundary;

    if handles.Model(md).Input.nrboundaries==0
        handles.Model(md).Input.boundaries(1).name='';
        handles.Model(md).Input.boundaries(1).type='waterlevelbnd';
        handles.Model(md).Input.boundaries(1).activenode=1;
        handles.Model(md).Input.boundaries(1).nodenames={''};
        handles.Model(md).Input.boundaries(1).nodes(1).tim=0;
        handles.Model(md).Input.boundaries(1).nodes(1).cmp=0;
        handles.Model(md).Input.boundaries(1).nodes(1).cmptype='astro';
    end
    
    % Rename boundaries
    handles=updateNames(handles);
    
    setHandles(handles);
    
    gui_updateActiveTab;

    ddb_DFlowFM_plotBoundaries(handles,'update');

end

%%
function changeBoundary(h,x,y,nr)

iac=[];
handles=getHandles;
% Find which boundary this is
for ii=1:length(handles.Model(md).Input.boundaries)
    if handles.Model(md).Input.boundaries(ii).handle==h
        iac=ii;
        break
    end
end
if ~isempty(iac)
    handles.Model(md).Input.activeboundary=iac;
    handles.Model(md).Input.boundaries(iac).x=x;
    handles.Model(md).Input.boundaries(iac).y=y;
end

setHandles(handles);

ddb_DFlowFM_plotBoundaries(handles,'update');

gui_updateActiveTab;

%%
function loadBoundary

clearInstructions;

handles=getHandles;
nr=handles.Model(md).Input.nrboundaries;
nr=nr+1;

[filename, pathname, filterindex] = uigetfile('*.pli', 'Load polyline file','');
if pathname~=0
    curdir=[lower(cd) '\'];
    if ~strcmpi(curdir,pathname)
        filename=[pathname filename];
    end    
    [x,y]=landboundary('read',filename);
else
    return
end

handles.Model(md).Input.nrboundaries=nr;
handles.Model(md).Input.activeboundary=nr;

name=filename(1:end-4);
handles.Model(md).Input.boundaries=ddb_DFlowFM_initializeBoundary(handles.Model(md).Input.boundaries,x,y,name,nr, ...
    handles.Model(md).Input.tstart,handles.Model(md).Input.tstop);

handles=updateNames(handles);

h=gui_polyline('plot','x',x,'y',y,'tag','dflowfmboundary', ...
    'changecallback',@ddb_DFlowFM_boundaries,'changeinput','changeboundary','closed',0, ...
    'Marker','o','color','g','markeredgecolor','r','markerfacecolor','r');

handles.Model(md).Input.boundaries(nr).handle=h;

% if nr>1
%     % Copy from existing boundary
%     handles.Model(md).Input.boundaries(nr).definition=handles.Model(md).Input.boundaries(handles.Model(md).Input.activeboundary).definition;
% end

setHandles(handles);

ddb_DFlowFM_plotBoundaries(handles,'update');

gui_updateActiveTab;

%%
function saveBoundary

clearInstructions;

handles=getHandles;

iac=handles.Model(md).Input.activeboundary;

[filename, pathname, filterindex] = uiputfile('*.pli', 'Save polyline file',handles.Model(md).Input.boundaries(iac).filename);

if pathname~=0

    % Save pli file
    handles.Model(md).Input.boundaries(iac).filename=filename;
    handles.Model(md).Input.boundaries(iac).name=filename(1:end-4);
    handles=updateNames(handles);
    x=handles.Model(md).Input.boundaries(iac).x;
    y=handles.Model(md).Input.boundaries(iac).y;
    landboundary('write',filename,x,y);

    % Save component files
    for jj=1:length(x)
        if handles.Model(md).Input.boundaries(iac).nodes(jj).cmp
            ddb_DFlowFM_saveCmpFile(handles.Model(md).Input.boundaries,iac,jj);
        end
        if handles.Model(md).Input.boundaries(iac).nodes(jj).tim
            ddb_DFlowFM_saveTimFile(handles.Model(md).Input.boundaries,iac,jj,handles.Model(md).Input.refdate);
        end        
    end

else
    return
end

setHandles(handles);

%%
function saveAllBoundaries

clearInstructions;

handles=getHandles;

for iac=1:handles.Model(md).Input.nrboundaries

    % Save pli file
    x=handles.Model(md).Input.boundaries(iac).x;
    y=handles.Model(md).Input.boundaries(iac).y;
    landboundary('write',handles.Model(md).Input.boundaries(iac).filename,x,y);

    % Save component files
    for jj=1:length(x)
        if handles.Model(md).Input.boundaries(iac).nodes(jj).cmp
            ddb_DFlowFM_saveCmpFile(handles.Model(md).Input.boundaries,iac,jj);
        end
        if handles.Model(md).Input.boundaries(iac).nodes(jj).tim
            ddb_DFlowFM_saveTimFile(handles.Model(md).Input.boundaries,iac,jj,handles.Model(md).Input.refdate);
        end
    end
end

setHandles(handles);


%%
function openExternalForcing

clearInstructions;

handles=getHandles;

[filename, pathname, filterindex] = uigetfile('*.ext', 'External Forcing File',handles.Model(md).Input.extforcefile);
if ~isempty(pathname)
    handles = ddb_DFlowFM_plotBoundaries(handles,'delete');
    handles.Model(md).Input.extfile=filename;
    handles=ddb_DFlowFM_readExternalForcing(handles);
    handles = ddb_DFlowFM_plotBoundaries(handles,'plot','active',1);
    setHandles(handles);
end

%%
function saveExternalForcing

clearInstructions;

handles=getHandles;

[filename, pathname, filterindex] = uiputfile('*.ext', 'External Forcing File',handles.Model(md).Input.extforcefile);
if pathname~=0
    handles.Model(md).Input.extfile=filename;
    ddb_DFlowFM_saveExtFile(handles);
    setHandles(handles);
end

%%
function handles=updateNames(handles)
% Change filename of pli file and component files
handles.Model(md).Input.boundarynames=[];
for ib=1:handles.Model(md).Input.nrboundaries
    name=handles.Model(md).Input.boundaries(ib).name;
    handles.Model(md).Input.boundarynames{ib}=name;
    for ip=1:length(handles.Model(md).Input.boundaries(ib).x)
        handles.Model(md).Input.boundaries(ib).nodes(ip).cmpfile=[name '_' num2str(ip,'%0.4i') '.cmp'];
    end
end

