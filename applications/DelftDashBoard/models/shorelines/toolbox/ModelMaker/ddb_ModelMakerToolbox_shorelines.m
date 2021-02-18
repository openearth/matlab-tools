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

        case{'startshorelines'}
            start_model;
        case{'pauseshorelines'}
            pause_model;
        case{'stopshorelines'}
            stop_model;
    end
    
end

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
        S.num_option1_value=handles.model.shorelines.domain.num_option1_value;        
        S.num_option2_value=handles.model.shorelines.domain.num_option2_value;        
        S.num_option3_value=handles.model.shorelines.domain.num_option3_value;        
        if strcmpi(S.num_opt,'spring')
            S.shoreline.x=handles.model.shorelines.domain.shoreline.x;
            S.shoreline.y=handles.model.shorelines.domain.shoreline.y;
        end
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
