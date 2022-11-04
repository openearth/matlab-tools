function ddb_sfincs_save_obs_file

% obs file

handles=getHandles;

if handles.model.sfincs.domain(ad).nrobservationpoints>0
    if isempty(handles.model.sfincs.domain(ad).input.obsfile)
        handles.model.sfincs.domain(ad).input.obsfile='sfincs.obs';
        setHandles(handles);
    end
    filename=handles.model.sfincs.domain(ad).input.obsfile;
    sfincs_write_observation_points(filename,handles.model.sfincs.domain(ad).observationpoints,'cstype',handles.screenParameters.coordinateSystem.type);
end
