function ddb_shorelines_output(varargin)

%%
ddb_zoomOff;

if isempty(varargin)

    % New tab selected
    ddb_plotshorelines('update','active',1,'visible',1);
         
else
    
    %Options selected
    
    opt=lower(varargin{1});
    
    switch lower(opt)
        case{'selectoutputinterval'}
            select_output_interval;            
    end
    
end

%% 
function select_output_interval

handles=getHandles;

dt=handles.model.shorelines.domain.output_timestep;

t0=handles.model.shorelines.domain.tstart;
t1=handles.model.shorelines.domain.tstop;

if dt>t1-t0
    ddb_giveWarning('text',['Output interval is greater than simulation period - ' num2str(round(t1-t0)) ' days']);
end

handles.model.shorelines.domain.output_timestep=round(t1-t0);

setHandles(handles);

gui_updateActiveTab;


