function ddb_sfincs_save_bzs_file

% Bzs file

handles=getHandles;

if handles.model.sfincs.domain(ad).flowboundarypoints.length>0
    if isempty(handles.model.sfincs.domain(ad).input.bzsfile)
        handles.model.sfincs.domain(ad).input.bzsfile='sfincs.bzs';
        setHandles(handles);
    end
    filename=handles.model.sfincs.domain(ad).input.bzsfile;
    t=handles.model.sfincs.domain(ad).flowboundarypoints.time;
    t=86400*(t-handles.model.sfincs.domain(ad).input.tref);
    v=handles.model.sfincs.domain(ad).flowboundarypoints.zs;
    sfincs_write_boundary_conditions_fast(filename,t,v);
end
