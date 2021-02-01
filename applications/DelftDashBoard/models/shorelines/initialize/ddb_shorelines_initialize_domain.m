function handles=ddb_shorelines_initialize_domain(handles)

handles.model.shorelines.domain.runid='tst';

handles.model.shorelines.domain.shoreline.handle=[];
handles.model.shorelines.domain.shoreline.filename='';
handles.model.shorelines.domain.shoreline.length=0;
handles.model.shorelines.domain.shoreline.x=[];
handles.model.shorelines.domain.shoreline.y=[];

% I just made this stuff up ...
handles.model.shorelines.domain.tstart=datenum(floor(now));
handles.model.shorelines.domain.tstop =datenum(floor(now))+365;
handles.model.shorelines.domain.tref=handles.model.shorelines.domain.tstart;
handles.model.shorelines.domain.rhow=1024.0;
handles.model.shorelines.domain.phys_opt='opt2';
handles.model.shorelines.domain.option1_value=0.2;
handles.model.shorelines.domain.option2_value=0.3;
handles.model.shorelines.domain.option3_value=0.4;
handles.model.shorelines.domain.num_opt='c';
handles.model.shorelines.domain.num_option1_value=0.2;
handles.model.shorelines.domain.num_option2_value=0.3;
handles.model.shorelines.domain.num_option3_value=0.4;
handles.model.shorelines.domain.output_timestep=100;
handles.model.shorelines.domain.morphology=1;
handles.model.shorelines.domain.theta=0.5;
handles.model.shorelines.domain.alpha=1.0;
handles.model.shorelines.domain.boundary.file='';
