function ddb_sfincs_open_thd_file

% Thd file

handles=getHandles;

inp=handles.model.sfincs.domain(ad).input;

% Thd file
if ~isempty(inp.thdfile)
    handles.model.sfincs.domain(ad).thindamnames={''};
    handles.model.sfincs.domain(ad).thindams = sfincs_read_thin_dams(inp.thdfile);
    handles.model.sfincs.domain(ad).nrthindams=length(handles.model.sfincs.domain(ad).thindams);
    handles.model.sfincs.domain(ad).activethindam=1;
    for ib=1:handles.model.sfincs.domain.nrthindams
        handles.model.sfincs.domain(ad).thindamnames{ib}=num2str(ib);
    end
end

setHandles(handles);
