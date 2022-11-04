function ddb_sfincs_save_dis_file

% dis file

handles=getHandles;

if handles.model.sfincs.domain(ad).discharges.number>0
    if isempty(handles.model.sfincs.domain(ad).input.disfile)
        handles.model.sfincs.domain(ad).input.disfile='sfincs.dis';
        setHandles(handles);
    end
    filename=handles.model.sfincs.domain(ad).input.disfile;
    sfincs_write_discharge_points(filename,handles.model.sfincs.domain(ad).discharges.point,'cstype',handles.screenParameters.coordinateSystem.type);
    t=(handles.model.sfincs.domain(ad).discharges.time - handles.model.sfincs.domain(ad).input.tref)*86400;
    v=handles.model.sfincs.domain(ad).discharges.q;
    sfincs_write_boundary_conditions(filename,t,v)
end
