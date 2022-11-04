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

            % Change some stuff around
            if ~isempty(inp.sbgfile)
                handles.model.sfincs.domain(ad).use_subgrid=1;                
                inp.depfile='';
            else    
                handles.model.sfincs.domain(ad).use_subgrid=0;                
            end
            
            handles.model.sfincs.domain(ad).input=inp;

            if ~isempty(inp.manningfile)
                handles.model.sfincs.domain(ad).roughness_type='file';
            else
                handles.model.sfincs.domain(ad).roughness_type='landsea';
            end
            
            if ~isempty(inp.amufile) && ~isempty(inp.amvfile)
                handles.model.sfincs.domain(ad).wind_type='rectangular';
            elseif ~isempty(inp.spwfile)
                handles.model.sfincs.domain(ad).wind_type='spiderweb';
            else
                handles.model.sfincs.domain(ad).wind_type='uniform';
            end
            
            if ~isempty(inp.amprfile)
                handles.model.sfincs.domain(ad).rain_type='rectangular';
            elseif ~isempty(inp.spwfile)
                handles.model.sfincs.domain(ad).rain_type='spiderweb';
            else
                handles.model.sfincs.domain(ad).rain_type='uniform';
            end
            
            % Grid
            [xg,yg,xz,yz]=sfincs_make_grid(inp.x0,inp.y0,inp.dx,inp.dy,inp.mmax,inp.nmax,inp.rotation);
            handles.model.sfincs.domain(ad).xg=xg;
            handles.model.sfincs.domain(ad).yg=yg;
            handles.model.sfincs.domain(ad).gridx=xz;
            handles.model.sfincs.domain(ad).gridy=yz;
            
            % Attribute files
            msk=zeros(inp.nmax,inp.mmax);
            z=msk;
            if ~isempty(inp.indexfile) || ~isempty(inp.depfile) || ~isempty(inp.mskfile)
                [z,msk]=sfincs_read_binary_inputs(inp.mmax,inp.nmax,inp.indexfile,inp.depfile,inp.mskfile);
                handles.model.sfincs.domain(ad).mask=msk;
                handles.model.sfincs.domain(ad).gridz=z;
            end
            
            setHandles(handles);
            
            % Bnd and bzs file
            ddb_sfincs_open_bnd_file;
            ddb_sfincs_open_bzs_file;

            % Obs file
            ddb_sfincs_open_obs_file;

            % Src and dis file
            ddb_sfincs_open_src_file;
            ddb_sfincs_open_dis_file;
            
            % Thd file
            ddb_sfincs_open_thd_file;
            
            ddb_plotsfincs('plot','active',0,'visible',1);

            gui_updateActiveTab;

        end        
    otherwise
end
