function handles = ddb_initializeshorelines(handles, varargin)

% This is where all the ShorelineS data is initialized
% Actual ShorelineS input is initialized in ddb_shorelines_initialize_domain.m

handles.model.shorelines.menuview.shoreline=1;

% Just as an example ... (see Physics tab)
handles.model.shorelines.phys_opts_long ={'Option 1','Option 2','Option 3'};
handles.model.shorelines.phys_opts_short={'opt1','opt2','opt3'};

handles.model.shorelines.num_opts_long ={'Circle','Up and down','Spring'};
handles.model.shorelines.num_opts_short={'circle','up_and_down','left_to_right'};

handles.model.shorelines.status='waiting';
handles.model.shorelines.current_time_string=datestr(floor(now));
handles.model.shorelines.time_remaining_string='0';

handles=ddb_shorelines_initialize_domain(handles);
