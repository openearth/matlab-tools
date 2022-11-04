function ddb_sfincs_open_bzs_file

% Bzs file

handles=getHandles;

inp=handles.model.sfincs.domain(ad).input;

if ~isempty(inp.bzsfile)
    [t,val]=sfincs_read_boundary_conditions(inp.bzsfile);
    handles.model.sfincs.domain(ad).flowboundaryconditions.time=inp.tref+t/86400;
    handles.model.sfincs.domain(ad).flowboundaryconditions.zs=val;
end

setHandles(handles);
