function ddb_sfincs_open_src_file

% Src file

handles=getHandles;

inp=handles.model.sfincs.domain(ad).input;

if ~isempty(inp.srcfile)
    
    points=sfincs_read_discharge_points(inp.srcfile);
    handles.model.sfincs.domain(ad).discharges.point=points;
    for ip=1:length(points)
        handles.model.sfincs.domain(ad).discharges.point(ip).name=['scr' num2str(ip,'%0.3i')];
        handles.model.sfincs.domain(ad).discharges.point(ip).q=0.0;
    end
    handles.model.sfincs.domain(ad).discharges.number=length(points);
    handles.model.sfincs.domain(ad).discharges.activepoint=1;
    handles.model.sfincs.domain(ad).discharges.time=[handles.model.sfincs.domain(ad).input.tstart handles.model.sfincs.domain(ad).input.tstop];
    handles.model.sfincs.domain(ad).discharges.q=zeros(2,handles.model.sfincs.domain(ad).discharges.number);
    
end

setHandles(handles);
