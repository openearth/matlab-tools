function ddb_sfincs_save_bnd_file

% Bnd file

handles=getHandles;

if handles.model.sfincs.domain(ad).flowboundarypoints.length>0
    if isempty(handles.model.sfincs.domain(ad).input.bndfile)
        handles.model.sfincs.domain(ad).input.bndfile='sfincs.bnd';
        setHandles(handles);
    end
    filename=handles.model.sfincs.domain(ad).input.bndfile;
    cstype=handles.screenParameters.coordinateSystem.type;
    sfincs_write_boundary_points(filename,handles.model.sfincs.domain(ad).flowboundarypoints,'cstype',cstype);
end
