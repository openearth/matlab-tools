function ddb_sfincs_open_obs_file

% Obs file

handles=getHandles;

inp=handles.model.sfincs.domain(ad).input;

if ~isempty(inp.obsfile)
    points=sfincs_read_observation_points(inp.obsfile);
    handles.model.sfincs.domain(ad).observationpointnames={''};
    for ip=1:length(points.x)
        handles.model.sfincs.domain(ad).observationpoints(ip).x=points.x(ip);
        handles.model.sfincs.domain(ad).observationpoints(ip).y=points.y(ip);
        handles.model.sfincs.domain(ad).observationpoints(ip).name=points.names{ip};
        handles.model.sfincs.domain(ad).observationpointnames{ip}=handles.model.sfincs.domain(ad).observationpoints(ip).name;
    end
    handles.model.sfincs.domain(ad).nrobservationpoints=length(points.x);
    handles.model.sfincs.domain(ad).activeobservationpoint=1;
end

setHandles(handles);
