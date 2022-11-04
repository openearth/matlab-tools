function ddb_sfincs_save_src_file

% dis file

handles=getHandles;

if handles.model.sfincs.domain(ad).discharges.number>0
    if isempty(handles.model.sfincs.domain(ad).input.srcfile)
        handles.model.sfincs.domain(ad).input.srcfile='sfincs.src';
        setHandles(handles);
    end
    filename=handles.model.sfincs.domain(ad).input.srcfile;
    sfincs_write_discharge_points(filename,handles.model.sfincs.domain(ad).discharges.point,'cstype',handles.screenParameters.coordinateSystem.type);
end
