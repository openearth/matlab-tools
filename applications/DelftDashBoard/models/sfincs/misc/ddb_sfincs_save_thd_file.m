function ddb_sfincs_save_thd_file

% thd file

handles=getHandles;

if handles.model.sfincs.domain(ad).nrthindams>0
    if isempty(handles.model.sfincs.domain(ad).input.thdfile)
        handles.model.sfincs.domain(ad).input.thdfile='sfincs.thd';
        setHandles(handles);
    end   
    sfincs_write_thin_dams(handles.model.sfincs.domain(ad).input.thdfile, handles.model.sfincs.domain(ad).thindams);
end
