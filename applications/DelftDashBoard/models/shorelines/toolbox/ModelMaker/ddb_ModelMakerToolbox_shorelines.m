function ddb_ModelMakerToolbox_shorelines(varargin)

%%

ddb_zoomOff;

if isempty(varargin)

    % New tab selected
    ddb_refreshScreen;
    ddb_plotModelMaker('activate');
    % Make shoreline visible
    ddb_plotshorelines('update','active',1,'visible',1);

else
    
    %Options selected
    
    opt=lower(varargin{1});
    
    switch opt
        case{'drawshoreline'}
            draw_shoreline;
        case{'deleteshoreline'}
            delete_shoreline;
        case{'loadshoreline'}
            load_shoreline;
        case{'saveshoreline'}
            save_shoreline;
        case{'startshorelines'}
            start_model;
        case{'pauseshorelines'}
            pause_model;
        case{'stopshorelines'}
            stop_model;
    end
    
end

%%
function draw_shoreline

handles=getHandles;

% First delete existing shoreline
handles = ddb_shorelines_plot_shoreline(handles, 'delete');
handles.model.shorelines.domain.shoreline.x=[];
handles.model.shorelines.domain.shoreline.y=[];
handles.model.shorelines.domain.shoreline.length=0;

gui_polyline('draw','axis',handles.GUIHandles.mapAxis,'tag','shorelines_tmp','marker','o', ...
    'createcallback',@create_shoreline, ...
    'linecolor','g','closed',0);

setInstructions({'','Click on map to draw coastline','Use right-click to end coastline'});

setHandles(handles);

%%
function create_shoreline(h,x,y)

handles=getHandles;

% Delete temporary shoreline
delete(h);

handles.model.shorelines.domain.shoreline.x=x;
handles.model.shorelines.domain.shoreline.y=y;
handles.model.shorelines.domain.shoreline.length=length(x);

handles = ddb_shorelines_plot_shoreline(handles, 'plot');

handles.model.shorelines.status='waiting';

setHandles(handles);

clearInstructions;

gui_updateActiveTab;

%%
function delete_shoreline

handles=getHandles;

% First delete existing shoreline
handles = ddb_shorelines_plot_shoreline(handles, 'delete');
handles.model.shorelines.domain.shoreline.x=[];
handles.model.shorelines.domain.shoreline.y=[];
handles.model.shorelines.domain.shoreline.length=0;

setHandles(handles);

gui_updateActiveTab;

%%
function load_shoreline

handles=getHandles;

[x,y]=landboundary('read',handles.model.shorelines.domain.shoreline.filename);

handles.model.shorelines.domain.shoreline.x=x;
handles.model.shorelines.domain.shoreline.y=y;
handles.model.shorelines.domain.shoreline.length=length(x);
handles = ddb_shorelines_plot_shoreline(handles, 'plot');

setHandles(handles);

gui_updateActiveTab;

%%
function save_shoreline

handles=getHandles;

x=handles.model.shorelines.domain.shoreline.x;
y=handles.model.shorelines.domain.shoreline.y;
landboundary('write',handles.model.shorelines.domain.shoreline.filename,x,y);

setHandles(handles);

%%
function start_model

handles=getHandles;

% This is where you execute the shorelines model
disp('Running ShorelineS !!!');

inp=handles.model.shorelines.domain;

S=inp;

S=ShorelineS(S,'initialize');

handles.model.shorelines.S=S;

handles.model.shorelines.status='running';

setHandles(handles);

gui_updateActiveTab;

next_time_step;


%%
function next_time_step

handles=getHandles;

S=handles.model.shorelines.S;

disp(S.it);

switch handles.model.shorelines.status
    case{'running'}
        
        if S.it<=S.nt
            
            % Continue running
            
            % do something
            S=ShorelineS(S,'timestep');
            
            handles.model.shorelines.S=S;
            
            handles.model.shorelines.current_time_string=['Date: ' datestr(S.tstart+S.it,'yyyy-mm-dd')];
            handles.model.shorelines.time_remaining_string=[num2str(round(S.tstop-S.tstart)-S.it) ' days remaining ...'];

            setHandles(handles);

            gui_updateActiveTab;
            
            % Change shoreline on the map
            
            x=S.shoreline.x;
            y=S.shoreline.y;
            h=handles.model.shorelines.domain.shoreline.handle;
            gui_polyline(h,'change','x',x,'y',y);
            
            drawnow;
            
            
            % And on the the next time step
            next_time_step;

        else
            stop_model;
        end
        
    case{'paused'}
        % Don't do anything
    case{'stopped'}
        stop_model;
        
end

%%
function pause_model

handles=getHandles;

switch handles.model.shorelines.status
    case{'running'}
        % Pause it, not need to do anything
        handles.model.shorelines.status='paused';
        setHandles(handles);
        disp('Model paused');
    case{'paused'}
        % Continue on
        handles.model.shorelines.status='running';
        % First copy some stuff (new structures?) to the S structure
        S=handles.model.shorelines.S;
        S.rhow=handles.model.shorelines.domain.rhow;
        S.num_opt=handles.model.shorelines.domain.num_opt;
        handles.model.shorelines.S=S;        
        setHandles(handles);
        next_time_step;
        disp('Model started again');
end

gui_updateActiveTab;

%%
function stop_model

handles=getHandles;
S=handles.model.shorelines.S;
S=ShorelineS(S,'finalize'); 
x=S.shoreline.x;
y=S.shoreline.y;
h=handles.model.shorelines.domain.shoreline.handle;
gui_polyline(h,'change','x',x,'y',y);
handles.model.shorelines.S=S;
handles.model.shorelines.status='waiting';
setHandles(handles);
disp('Model stopped');

gui_updateActiveTab;
