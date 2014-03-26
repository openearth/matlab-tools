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
iac=handles.model.dflowfm.domain.activeboundary;
oriname=handles.model.dflowfm.domain.boundarynames{iac};
name=handles.model.dflowfm.domain.boundaries(iac).name;
% Check for spaces
if isempty(find(name==' ', 1));
    handles.model.dflowfm.domain.boundaries(iac).filename=[name '.pli'];
    handles=updateNames(handles);
else
    ddb_giveWarning('text','Sorry, boundary names cannot contain spaces!');
    handles.model.dflowfm.domain.boundaries(iac).name=oriname;
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

nr=handles.model.dflowfm.domain.nrboundaries;
nr=nr+1;

handles.model.dflowfm.domain.nrboundaries=nr;

handles.model.dflowfm.domain.boundaries=ddb_DFlowFM_initializeBoundary(handles.model.dflowfm.domain.boundaries,x,y,['bnd_' num2str(nr,'%0.3i')],nr, ...
    handles.model.dflowfm.domain.tstart,handles.model.dflowfm.domain.tstop);

handles=updateNames(handles);

handles.model.dflowfm.domain.boundaries(nr).handle=h;

% if nr>1
%     % Copy from existing boundary
%     handles.model.dflowfm.domain.boundaries(nr).definition=handles.model.dflowfm.domain.boundaries(handles.model.dflowfm.domain.activeboundary).definition;
% end
handles.model.dflowfm.domain.activeboundary=nr;

setHandles(handles);

ddb_DFlowFM_plotBoundaries(handles,'update');

gui_updateActiveTab;

%%
function deleteBoundary

clearInstructions;

handles=getHandles;

if handles.model.dflowfm.domain.nrboundaries>0

    iac=handles.model.dflowfm.domain.activeboundary;
    try
        delete(handles.model.dflowfm.domain.boundaries(iac).handle);
    end
    handles.model.dflowfm.domain.boundaries=removeFromStruc(handles.model.dflowfm.domain.boundaries,iac);
    handles.model.dflowfm.domain.nrboundaries=handles.model.dflowfm.domain.nrboundaries-1;
    handles.model.dflowfm.domain.activeboundary=max(min(handles.model.dflowfm.domain.activeboundary,handles.model.dflowfm.domain.nrboundaries),1);
    handles.model.dflowfm.domain.activeboundaries=handles.model.dflowfm.domain.activeboundary;

    if handles.model.dflowfm.domain.nrboundaries==0
        handles.model.dflowfm.domain.boundaries(1).name='';
        handles.model.dflowfm.domain.boundaries(1).type='waterlevelbnd';
        handles.model.dflowfm.domain.boundaries(1).activenode=1;
        handles.model.dflowfm.domain.boundaries(1).nodenames={''};
        handles.model.dflowfm.domain.boundaries(1).nodes(1).tim=0;
        handles.model.dflowfm.domain.boundaries(1).nodes(1).cmp=0;
        handles.model.dflowfm.domain.boundaries(1).nodes(1).cmptype='astro';
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
for ii=1:length(handles.model.dflowfm.domain.boundaries)
    if handles.model.dflowfm.domain.boundaries(ii).handle==h
        iac=ii;
        break
    end
end
if ~isempty(iac)
    handles.model.dflowfm.domain.activeboundary=iac;
    handles.model.dflowfm.domain.boundaries(iac).x=x;
    handles.model.dflowfm.domain.boundaries(iac).y=y;
end

setHandles(handles);

ddb_DFlowFM_plotBoundaries(handles,'update');

gui_updateActiveTab;

%%
function loadBoundary

clearInstructions;

handles=getHandles;
nr=handles.model.dflowfm.domain.nrboundaries;
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

handles.model.dflowfm.domain.nrboundaries=nr;
handles.model.dflowfm.domain.activeboundary=nr;

name=filename(1:end-4);
handles.model.dflowfm.domain.boundaries=ddb_DFlowFM_initializeBoundary(handles.model.dflowfm.domain.boundaries,x,y,name,nr, ...
    handles.model.dflowfm.domain.tstart,handles.model.dflowfm.domain.tstop);

handles=updateNames(handles);

h=gui_polyline('plot','x',x,'y',y,'tag','dflowfmboundary', ...
    'changecallback',@ddb_DFlowFM_boundaries,'changeinput','changeboundary','closed',0, ...
    'Marker','o','color','g','markeredgecolor','r','markerfacecolor','r');

handles.model.dflowfm.domain.boundaries(nr).handle=h;

% if nr>1
%     % Copy from existing boundary
%     handles.model.dflowfm.domain.boundaries(nr).definition=handles.model.dflowfm.domain.boundaries(handles.model.dflowfm.domain.activeboundary).definition;
% end

setHandles(handles);

ddb_DFlowFM_plotBoundaries(handles,'update');

gui_updateActiveTab;

%%
function saveBoundary

clearInstructions;

handles=getHandles;

iac=handles.model.dflowfm.domain.activeboundary;

[filename, pathname, filterindex] = uiputfile('*.pli', 'Save polyline file',handles.model.dflowfm.domain.boundaries(iac).filename);

if pathname~=0

    % Save pli file
    handles.model.dflowfm.domain.boundaries(iac).filename=filename;
    handles.model.dflowfm.domain.boundaries(iac).name=filename(1:end-4);
    handles=updateNames(handles);
    x=handles.model.dflowfm.domain.boundaries(iac).x;
    y=handles.model.dflowfm.domain.boundaries(iac).y;
    landboundary('write',filename,x,y);

    % Save component files
    for jj=1:length(x)
        if handles.model.dflowfm.domain.boundaries(iac).nodes(jj).cmp
            ddb_DFlowFM_saveCmpFile(handles.model.dflowfm.domain.boundaries,iac,jj);
        end
        if handles.model.dflowfm.domain.boundaries(iac).nodes(jj).tim
            ddb_DFlowFM_saveTimFile(handles.model.dflowfm.domain.boundaries,iac,jj,handles.model.dflowfm.domain.refdate);
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

for iac=1:handles.model.dflowfm.domain.nrboundaries

    % Save pli file
    x=handles.model.dflowfm.domain.boundaries(iac).x;
    y=handles.model.dflowfm.domain.boundaries(iac).y;
    landboundary('write',handles.model.dflowfm.domain.boundaries(iac).filename,x,y);

    % Save component files
    for jj=1:length(x)
        if handles.model.dflowfm.domain.boundaries(iac).nodes(jj).cmp
            ddb_DFlowFM_saveCmpFile(handles.model.dflowfm.domain.boundaries,iac,jj);
        end
        if handles.model.dflowfm.domain.boundaries(iac).nodes(jj).tim
            ddb_DFlowFM_saveTimFile(handles.model.dflowfm.domain.boundaries,iac,jj,handles.model.dflowfm.domain.refdate);
        end
    end
end

setHandles(handles);


%%
function openExternalForcing

clearInstructions;

handles=getHandles;

[filename, pathname, filterindex] = uigetfile('*.ext', 'External Forcing File',handles.model.dflowfm.domain.extforcefile);
if ~isempty(pathname)
    handles = ddb_DFlowFM_plotBoundaries(handles,'delete');
    handles.model.dflowfm.domain.extforcefile=filename;
    handles=ddb_DFlowFM_readExternalForcing(handles);
    handles = ddb_DFlowFM_plotBoundaries(handles,'plot','active',1);
    setHandles(handles);
end

%%
function saveExternalForcing

clearInstructions;

handles=getHandles;

[filename, pathname, filterindex] = uiputfile('*.ext', 'External Forcing File',handles.model.dflowfm.domain.extforcefile);
if pathname~=0
    handles.model.dflowfm.domain.extforcefile=filename;
    ddb_DFlowFM_saveExtFile(handles);
    setHandles(handles);
end

%%
function handles=updateNames(handles)
% Change filename of pli file and component files
handles.model.dflowfm.domain.boundarynames=[];
for ib=1:handles.model.dflowfm.domain.nrboundaries
    name=handles.model.dflowfm.domain.boundaries(ib).name;
    handles.model.dflowfm.domain.boundarynames{ib}=name;
    for ip=1:length(handles.model.dflowfm.domain.boundaries(ib).x)
        handles.model.dflowfm.domain.boundaries(ib).nodes(ip).cmpfile=[name '_' num2str(ip,'%0.4i') '.cmp'];
    end
end

