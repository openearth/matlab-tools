function ddb_Delft3DWAVE_boundaries(varargin)

handles=getHandles;

if isempty(varargin)
    ddb_zoomOff;
    ddb_refreshScreen;
    ddb_Delft3DWAVE_plotBoundaries(handles,'update');
else
    opt=varargin{1};
    switch lower(opt)
        case{'selectboundary'}
            ddb_Delft3DWAVE_plotBoundaries(handles,'update');
        case{'add'}
            addBoundary;
        case{'delete'}
            deleteBoundary;
        case{'editboundaryconditions'}
            editBoundaryConditions;
        case{'editspectralspace'};
            editSpectralSpace;
        case{'drawxyboundary'}
            drawXYBoundary;
        case{'changexyboundary'}
            h=varargin{2};
            x=varargin{3};
            y=varargin{4};
            nr=varargin{5};
            changeXYBoundary(h,x,y,nr);
        case{'editxycoordinates'}
            editXYCoordinates;
        case{'editmncoordinates'}
            editMNCoordinates;
        case{'selectdefinition'}
            selectDefinition;
    end
end

%%
function addBoundary
clearInstructions;

handles=getHandles;
nr=handles.Model(md).Input.nrboundaries;
nr=nr+1;
handles.Model(md).Input.boundaries=ddb_initializeDelft3DWAVEBoundary(handles.Model(md).Input.boundaries,nr);
handles.Model(md).Input.boundaries(nr).name=['Boundary ' num2str(nr)];
handles.Model(md).Input.boundarynames{nr}=['Boundary ' num2str(nr)];
if nr>1
    % Copy from existing boundary
    handles.Model(md).Input.boundaries(nr).definition=handles.Model(md).Input.boundaries(handles.Model(md).Input.activeboundary).definition;
end
handles.Model(md).Input.nrboundaries=nr;
handles.Model(md).Input.activeboundary=nr;
setHandles(handles);

ddb_Delft3DWAVE_plotBoundaries(handles,'update');

%%
function deleteBoundary
clearInstructions;
handles=getHandles;
if handles.Model(md).Input.nrboundaries>0
    iac=handles.Model(md).Input.activeboundary;
    try
        delete(handles.Model(md).Input.boundaries(iac).plothandle);
    end
    handles.Model(md).Input.boundaries=removeFromStruc(handles.Model(md).Input.boundaries,iac);
    handles.Model(md).Input.boundarynames=removeFromCellArray(handles.Model(md).Input.boundarynames,iac);
    handles.Model(md).Input.nrboundaries=handles.Model(md).Input.nrboundaries-1;
    handles.Model(md).Input.activeboundary=max(min(handles.Model(md).Input.activeboundary,handles.Model(md).Input.nrboundaries),1);
    handles.Model(md).Input.activeboundaries=handles.Model(md).Input.activeboundary;
    if handles.Model(md).Input.nrboundaries==0
        handles.Model(md).Input.boundaries=ddb_initializeDelft3DWAVEBoundary(handles.Model(md).Input.boundaries,1);
    end
    setHandles(handles);
    gui_updateActiveTab;
    ddb_Delft3DWAVE_plotBoundaries(handles,'update');
end

%%
function editBoundaryConditions
clearInstructions;

ddb_zoomOff;
handles=getHandles;

% Make new GUI
h=handles;

iac=handles.Model(md).Input.activeboundary;
switch lower(handles.Model(md).Input.boundaries(iac).periodtype)
    case{'peak'}
        h.Model(md).Input.periodtext='Wave Period Tp (s)';
    case{'mean'}
        h.Model(md).Input.periodtext='Wave Period Tm (s)';
end
switch lower(handles.Model(md).Input.boundaries(iac).dirspreadtype)
    case{'power'}
        h.Model(md).Input.dirspreadtext='Directional Spreading (-)';
    case{'degrees'}
        h.Model(md).Input.dirspreadtext='Directional Spreading (degrees)';
end

xmldir=handles.Model(md).xmlDir;
switch lower(handles.Model(md).Input.boundaries(iac).alongboundary)
    case{'uniform'}
        xmlfile='Delft3DWAVE.editboundaryconditionsuniform.xml';
        [h,ok]=gui_newWindow(h,'xmldir',xmldir,'xmlfile',xmlfile,'iconfile',[handles.settingsDir filesep 'icons' filesep 'deltares.gif']);
    case{'varying'}
        xmlfile='Delft3DWAVE.editboundaryconditionsvarying.xml';
        [h,ok]=gui_newWindow(h,'xmldir',xmldir,'xmlfile',xmlfile,'iconfile',[handles.settingsDir filesep 'icons' filesep 'deltares.gif'],'modal',0);
end


if ok
    handles=h;
    setHandles(handles);
end

%% 
function editSpectralSpace
clearInstructions;

ddb_zoomOff;
handles=getHandles;

% Make new GUI
h=handles;

xmldir=handles.Model(md).xmlDir;
% switch lower(handles.Model(md).Input.boundaries(iac).alongboundary)
%     case{'uniform'}
        xmlfile='Delft3DWAVE.editspectralspace.xml';
        [h,ok]=gui_newWindow(h,'xmldir',xmldir,'xmlfile',xmlfile,'iconfile',[handles.settingsDir filesep 'icons' filesep 'deltares.gif']);
%     case{'varying'}
%         xmlfile='Delft3DWAVE.editboundaryconditionsvarying.xml';
%         [h,ok]=gui_newWindow(h,'xmldir',xmldir,'xmlfile',xmlfile,'iconfile',[handles.settingsDir filesep 'icons' filesep 'deltares.gif'],'modal',0);
% end

if ok
    handles=h;
    setHandles(handles);
end

%%
function drawXYBoundary
setInstructions({'','','Draw boundary section on grid'});
ddb_zoomOff;
handles=getHandles;
xg=handles.Model(md).Input.domains(1).gridx;
yg=handles.Model(md).Input.domains(1).gridy;
gui_dragLine('callback',@addXYBoundary,'method','alonggridline','gridx',xg,'gridy',yg);

%%
function addXYBoundary(x,y,m,n)
clearInstructions;
handles=getHandles;
h=gui_polyline('plot','x',x,'y',y,'tag','delft3dwaveboundary','Marker','o','changecallback',@changeXYBoundary,'closed',0, ...
    'color','r','markeredgecolor','r','markerfacecolor','r');
iac=handles.Model(md).Input.activeboundary;
% Delete existing plot handle
if isfield(handles.Model(md).Input.boundaries(iac),'plothandle')
    if ~isempty(handles.Model(md).Input.boundaries(iac).plothandle)
        try
            delete(handles.Model(md).Input.boundaries(iac).plothandle);
        end
    end
end

handles.Model(md).Input.boundaries(iac).plothandle=h;
handles.Model(md).Input.boundaries(iac).startcoordx=x(1);
handles.Model(md).Input.boundaries(iac).endcoordx=x(2);
handles.Model(md).Input.boundaries(iac).startcoordy=y(1);
handles.Model(md).Input.boundaries(iac).endcoordy=y(2);
handles.Model(md).Input.boundaries(iac).startcoordm=m(1)-1;
handles.Model(md).Input.boundaries(iac).endcoordm=m(2)-1;
handles.Model(md).Input.boundaries(iac).startcoordn=n(1)-1;
handles.Model(md).Input.boundaries(iac).endcoordn=n(2)-1;
setHandles(handles);

ddb_Delft3DWAVE_plotBoundaries(handles,'update');

gui_updateActiveTab;

%%
function changeXYBoundary(h,x,y,nr)
clearInstructions;
handles=getHandles;
% First find boundary that was changed 
for ii=1:handles.Model(md).Input.nrboundaries
    if handles.Model(md).Input.boundaries(ii).plothandle==h
        
        % Find nearest grid points
        xg=handles.Model(md).Input.domains(1).gridx;
        yg=handles.Model(md).Input.domains(1).gridy;
        [m1,n1]=findcornerpoint(x(1),y(1),xg,yg);
        [m2,n2]=findcornerpoint(x(2),y(2),xg,yg);
        if strcmpi(handles.Model(md).Input.boundaries(ii).definition,'grid-coordinates')
            handles.Model(md).Input.boundaries(ii).startcoordx=xg(m1,n1);
            handles.Model(md).Input.boundaries(ii).endcoordx=xg(m2,n2);
            handles.Model(md).Input.boundaries(ii).startcoordy=yg(m1,n1);
            handles.Model(md).Input.boundaries(ii).endcoordy=yg(m2,n2);
            
            x(1)=handles.Model(md).Input.boundaries(ii).startcoordx;
            x(2)=handles.Model(md).Input.boundaries(ii).endcoordx;
            y(1)=handles.Model(md).Input.boundaries(ii).startcoordy;
            y(2)=handles.Model(md).Input.boundaries(ii).endcoordy;
            h=handles.Model(md).Input.boundaries(ii).plothandle;
            gui_polyline(h,'change','x',x,'y',y);

        else
            handles.Model(md).Input.boundaries(ii).startcoordx=x(1);
            handles.Model(md).Input.boundaries(ii).endcoordx=x(2);
            handles.Model(md).Input.boundaries(ii).startcoordy=y(1);
            handles.Model(md).Input.boundaries(ii).endcoordy=y(2);
        end
        handles.Model(md).Input.boundaries(ii).startcoordm=m1-1;
        handles.Model(md).Input.boundaries(ii).endcoordm=m2-1;
        handles.Model(md).Input.boundaries(ii).startcoordn=n1-1;
        handles.Model(md).Input.boundaries(ii).endcoordn=n2-1;

        handles.Model(md).Input.activeboundary=ii;
        break
    end
end
setHandles(handles);
ddb_Delft3DWAVE_plotBoundaries(handles,'update');
gui_updateActiveTab;

%%
function editXYCoordinates
clearInstructions;
handles=getHandles;
iac=handles.Model(md).Input.activeboundary;
h=handles.Model(md).Input.boundaries(iac).plothandle;
x(1)=handles.Model(md).Input.boundaries(iac).startcoordx;
x(2)=handles.Model(md).Input.boundaries(iac).endcoordx;
y(1)=handles.Model(md).Input.boundaries(iac).startcoordy;
y(2)=handles.Model(md).Input.boundaries(iac).endcoordy;
gui_polyline(h,'change','x',x,'y',y);

%%
function editMNCoordinates
clearInstructions;

handles=getHandles;

iac=handles.Model(md).Input.activeboundary;
xg=handles.Model(md).Input.domains(1).gridx;
yg=handles.Model(md).Input.domains(1).gridy;
m1=handles.Model(md).Input.boundaries(iac).startcoordm;
m2=handles.Model(md).Input.boundaries(iac).endcoordm;
n1=handles.Model(md).Input.boundaries(iac).startcoordn;
n2=handles.Model(md).Input.boundaries(iac).endcoordn;

x(1)=xg(m1+1,n1+1);
x(2)=xg(m2+1,n2+1);
y(1)=yg(m1+1,n1+1);
y(2)=yg(m2+1,n2+1);

handles.Model(md).Input.boundaries(iac).startcoordx=x(1);
handles.Model(md).Input.boundaries(iac).endcoordx=x(2);
handles.Model(md).Input.boundaries(iac).startcoordy=y(1);
handles.Model(md).Input.boundaries(iac).endcoordy=y(2);

h=handles.Model(md).Input.boundaries(iac).plothandle;
gui_polyline(h,'change','x',x,'y',y);

setHandles(handles);

%%
function selectDefinition
clearInstructions;
handles=getHandles;
iac=handles.Model(md).Input.activeboundary;
% Delete existing plot handles
if ~isempty(handles.Model(md).Input.boundaries(iac).plothandle)
    if ishandle(handles.Model(md).Input.boundaries(iac).plothandle)
        delete(handles.Model(md).Input.boundaries(iac).plothandle);
        handles.Model(md).Input.boundaries(iac).plothandle=[];
    end
end
switch handles.Model(md).Input.boundaries(iac).definition
    case{'xy-coordinates','grid-coordinates'}
        x(1)=handles.Model(md).Input.boundaries(iac).startcoordx;
        x(2)=handles.Model(md).Input.boundaries(iac).endcoordx;
        y(1)=handles.Model(md).Input.boundaries(iac).startcoordy;
        y(2)=handles.Model(md).Input.boundaries(iac).endcoordy;        
        h=gui_polyline('plot','x',x,'y',y,'tag','delft3dwaveboundary','Marker','o','changecallback',@changeXYBoundary,'closed',0, ...
            'color','r','markeredgecolor','r','markerfacecolor','r');
        handles.Model(md).Input.boundaries(iac).plothandle=h;        
end
setHandles(handles);
