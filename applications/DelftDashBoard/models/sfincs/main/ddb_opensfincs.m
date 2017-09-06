function ddb_opensfincs(opt)

handles=getHandles;

switch lower(opt)
    case{'open'}

        [filename, pathname, filterindex] = uigetfile('sfincs.inp','Select sfincs.inp file');

        if pathname~=0

            pathname=pathname(1:end-1); % Get rid of last file seperator
            if ~strcmpi(pathname,handles.workingDirectory)
                cd(pathname);
                handles.workingDirectory=pathname;
            end

            % Delete all domains
            ddb_plotsfincs('delete','domain',1);
            
            handles.model.sfincs.domain = [];

            handles = ddb_initialize_sfincs_domain(handles, '', ad, 'tst');
            handles.model.sfincs.domain(ad).input=sfincs_read_input(filename,handles.model.sfincs.domain(ad).input);
            inp=handles.model.sfincs.domain(ad).input;
            handles.model.sfincs.domain(ad).tref=datenum(inp.tref,'yyyymmdd HHMMSS');
            handles.model.sfincs.domain(ad).tstart=datenum(inp.tstart,'yyyymmdd HHMMSS');
            handles.model.sfincs.domain(ad).tstop=datenum(inp.tstop,'yyyymmdd HHMMSS');
            
            % Attribute files
            
            % Bnd file
            handles.model.sfincs.domain(ad).flowboundarypoints=sfincs_read_boundary_points(inp.bndfile);
%             % Bzs file
%             [t,val]=sfincs_read_boundary_conditions(inp.bzsfile);
%             handles.model.sfincs.domain(ad).flowboundarypoints=sfincs_read_boundary_points(inp.bndfile);

            % Bwv file
%            handles.model.sfincs.domain(ad).waveboundarypoints=sfincs_read_boundary_points(inp.bwvfile);
            handles.model.sfincs.domain(ad).waveboundarypoints=sfincs_read_boundary_points(inp.bndfile); %% UPDATE!!!

            % Coastline file
            handles.model.sfincs.domain(ad).coastline=sfincs_read_coastline(inp.cstfile);
            
%            handles = ddb_sfincs_read_attribute_files(handles);
                        
%             handles.model.sfincs.domain(ad).tstart=floor(now);
%             handles.model.sfincs.domain(ad).tstop=handles.model.sfincs.domain(ad).tstart + handles.model.sfincs.domain(ad).input.simtime/86400;
                        
            setHandles(handles);
            ddb_plotsfincs('plot','active',0,'visible',1);
            gui_updateActiveTab;
        end        
    otherwise
end
