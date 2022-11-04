function ddb_sfincs_open_dis_file

% Dis file

handles=getHandles;

inp=handles.model.sfincs.domain(ad).input;

if ~isempty(inp.disfile)
    [t,val]=sfincs_read_boundary_conditions(inp.disfile);
    if size(val,2)==handles.model.sfincs.domain(ad).discharges.number
        handles.model.sfincs.domain(ad).discharges.time=handles.model.sfincs.domain(ad).input.tref + t/86400;
        handles.model.sfincs.domain(ad).discharges.q=val;
    else
        ddb_giveWarning('text','Number of columns in dis file does not match number of discharge points in src file!');
    end
end

setHandles(handles);
