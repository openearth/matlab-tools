function ddb_savesfincs(opt)

handles=getHandles;

switch lower(opt)
    case{'save'}
        sfincs_write_input('sfincs.inp',handles.model.sfincs.domain(ad).input);
    case{'saveall'}
        
        sfincs_write_input('sfincs.inp',handles.model.sfincs.domain(ad).input);
        
        % Attribute files
        
        % Bnd file
        sfincs_write_boundary_points(handles.model.sfincs.domain(ad).input.bndfile,handles.model.sfincs.domain(ad).flowboundarypoints);
        %             % Bzs file
        %             [t,val]=sfincs_read_boundary_conditions(inp.bzsfile);
        %             handles.model.sfincs.domain(ad).flowboundarypoints=sfincs_read_boundary_points(inp.bndfile);
        
        % Bwv file
        sfincs_write_boundary_points(handles.model.sfincs.domain(ad).input.bwvfile,handles.model.sfincs.domain(ad).waveboundarypoints);
        
        % Coastline file
        sfincs_write_coastline(handles.model.sfincs.domain(ad).input.cstfile,handles.model.sfincs.domain(ad).coastline);
        
end

%ddb_Delft3DWAVE_checkInput(handles);

setHandles(handles);
