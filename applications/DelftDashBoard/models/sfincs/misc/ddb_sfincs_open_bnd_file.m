function ddb_sfincs_open_bnd_file

% Bnd file

handles=getHandles;

inp=handles.model.sfincs.domain(ad).input;

if ~isempty(inp.bndfile)
    handles.model.sfincs.domain(ad).flowboundarypoints=sfincs_read_boundary_points(inp.bndfile);
    handles.model.sfincs.domain(ad).flowboundaryconditions.time=[inp.tstart inp.tstop];
    handles.model.sfincs.domain(ad).flowboundaryconditions.zs=zeros(2,handles.model.sfincs.domain(ad).flowboundarypoints.length);
end

setHandles(handles);
