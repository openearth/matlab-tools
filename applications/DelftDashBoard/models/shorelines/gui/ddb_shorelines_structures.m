function ddb_shorelines_structures(varargin)

%%

ddb_zoomOff;

if isempty(varargin)

    % New tab selected
    %ddb_refreshScreen;
    % Make shoreline visible
    ddb_plotstructures('update','active',1,'visible',1);

else
    
    %Options selected
    
    opt=lower(varargin{1});
    
    switch opt
        case{'selectfromlist'}
            select_from_list;
        case{'drawstructure'}
            draw_structure;
        case{'deletestructure'}
            delete_structure;
        case{'loadstructures'}
            load_structures;
        case{'savestructures'}
            save_structures;
        case{'editname'}
            edit_name;
    end
    
end

%%
function select_from_list

handles=getHandles;

% First delete existing structure
%handles = ddb_shorelines_plot_shoreline(handles, 'delete');
% handles.model.shorelines.domain.shoreline.x=[];
% handles.model.shorelines.domain.shoreline.y=[];
% handles.model.shorelines.domain.shoreline.length=0;

handles = ddb_shorelines_plot_structure(handles, 'plot');
% as=handles.model.shorelines.domain.activestructure;
% xp=handles.model.shorelines.domain.structures(as).x;
% yp=handles.model.shorelines.domain.structures(as).y;
% gui_polyline('plot','axis',handles.GUIHandles.mapAxis,'tag','structures_tmp','marker','o', ...
%     'x',xp,'y',yp, ...
%     'changecallback',@modify_structure, ...
%     'linecolor','g','closed',1);

setInstructions({'','Click on map to draw structure','Use right-click to end structure'});

setHandles(handles);

%%
function draw_structure

handles=getHandles;

% First delete existing structure
%handles = ddb_shorelines_plot_shoreline(handles, 'delete');
% handles.model.shorelines.domain.shoreline.x=[];
% handles.model.shorelines.domain.shoreline.y=[];
% handles.model.shorelines.domain.shoreline.length=0;

gui_polyline('draw','axis',handles.GUIHandles.mapAxis,'tag','structures_tmp','marker','o', ...
    'createcallback',@create_structure, ...
    'linecolor','g','closed',1);

setInstructions({'','Click on map to draw structure','Use right-click to end structure'});

setHandles(handles);

%%
function create_structure(h,x,y)

handles=getHandles;

% Delete temporary structure

delete(h);
handles.model.shorelines.domain.nrstructures=handles.model.shorelines.domain.nrstructures+1;
handles.model.shorelines.domain.activestructure=handles.model.shorelines.domain.nrstructures;
as=handles.model.shorelines.domain.activestructure;
handles.model.shorelines.domain.structures(as).x=x;
handles.model.shorelines.domain.structures(as).y=y;
handles.model.shorelines.domain.structurenames{as}=['structure ',num2str(as)];
handles.model.shorelines.domain.structures(as).name=['structure ',num2str(as)];
handles.model.shorelines.domain.structure_transmission(as)=0;
handles.model.shorelines.domain.structures(as).length=length(handles.model.shorelines.domain.structures(as).x);
handles = ddb_shorelines_plot_structure(handles, 'plot');

handles.model.shorelines.status='waiting';

setHandles(handles);

clearInstructions;

gui_updateActiveTab;

draw_structure;

%%
function delete_structure

handles=getHandles;

% First delete existing structure
as=handles.model.shorelines.domain.activestructure;
nr=handles.model.shorelines.domain.nrstructures;
delete (handles.model.shorelines.domain.structures(as).handle);
handles.model.shorelines.domain.structures=handles.model.shorelines.domain.structures([1:as-1,as+1:nr]);
handles.model.shorelines.domain.nrstructures=handles.model.shorelines.domain.nrstructures-1;
handles.model.shorelines.domain.activestructure=handles.model.shorelines.domain.nrstructures;
handles=update_structure_names(handles);
handles.model.shorelines.domain.activestructure=min(as,handles.model.shorelines.domain.nrstructures);
handles = ddb_shorelines_plot_structure(handles, 'plot');
setHandles(handles);

gui_updateActiveTab;

%%
function load_structures

handles=getHandles;

%[x,y]=landboundary('read',handles.model.shorelines.domain.structure.filename);
[x,y]=read_xy_columns(handles.model.shorelines.domain.LDBstructures);
matname=handles.model.shorelines.domain.LDBstructures;
matname(end-2:end)='mat';
load(matname);
handles.model.shorelines.domain.structures=structures;

[xi,yi,nrstructures,i1,i2]= get_one_polygon(x,y,1);
for as=1:nrstructures
    [xi,yi,nrstructures,i1,i2]= get_one_polygon(x,y,as);
    handles.model.shorelines.domain.structures(as).x=xi;
    handles.model.shorelines.domain.structures(as).y=yi;
    handles.model.shorelines.domain.structures(as).length=length(xi);
    handles.model.shorelines.domain.structurenames{as}=['structure ',num2str(as)];
    handles.model.shorelines.domain.structures(as).name=['structure ',num2str(as)];
end
handles.model.shorelines.domain.nrstructures=nrstructures;
handles.model.shorelines.domain.activestructure=1;

handles = ddb_shorelines_plot_structure(handles, 'plot');

%set(handles.model.shorelines.domain.structure.handle,'HitTest','off');
% ch=get(handles.model.shorelines.domain.structure.handle,'Children');
% set(ch,'HitTest','off');

setHandles(handles);

gui_updateActiveTab;

%%
function save_structures

handles=getHandles;

x=handles.model.shorelines.domain.structures(1).x;
y=handles.model.shorelines.domain.structures(1).y;
for as=2:handles.model.shorelines.domain.nrstructures
    x=[x,NaN,handles.model.shorelines.domain.structures(as).x];
    y=[y,NaN,handles.model.shorelines.domain.structures(as).y];
end
%landboundary('write',handles.model.shorelines.domain.structure.filename,x,y);
out=[x;y]';
save(handles.model.shorelines.domain.LDBstructures,'out','-ascii');
setHandles(handles);

gui_updateActiveTab;

matname=handles.model.shorelines.domain.LDBstructures;
matname(end-2:end)='mat';
structures=handles.model.shorelines.domain.structures;
structures=rmfield(structures,'handle');
save(matname,'structures');
%%
function edit_name

handles=getHandles;
handles=update_structure_names(handles)
setHandles(handles);

%%
function handles=update_structure_names(handles)
handles.model.shorelines.domain.structurenames={''};
for as=1:handles.model.shorelines.domain.nrstructures
    handles.model.shorelines.domain.structurenames{as}=handles.model.shorelines.domain.structures(as).name;
end

gui_updateActiveTab;
