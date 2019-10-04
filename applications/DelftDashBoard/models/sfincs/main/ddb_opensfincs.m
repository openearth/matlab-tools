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

            % Grid
            rot=inp.rotation*pi/180;
            [xg0,yg0]=meshgrid(0:inp.dx:inp.mmax*inp.dx,0:inp.dy:inp.nmax*inp.dy);
            x = inp.x0 + xg0* cos(rot) + yg0*-sin(rot);
            y = inp.y0 + xg0* sin(rot) + yg0*cos(rot);
            
            % Cell centres!
            [xz,yz]=getXZYZ(x,y);
            handles.model.sfincs.domain(ad).gridx=xz(2:end,2:end);
            handles.model.sfincs.domain(ad).gridy=yz(2:end,2:end);
            
            % Attribute files
            msk=zeros(inp.nmax,inp.mmax);
            z=msk;
            if ~isempty(inp.indexfile) && ~isempty(inp.depfile) && ~isempty(inp.mskfile)
                [z,msk]=sfincs_read_binary_inputs(inp.mmax,inp.nmax,inp.indexfile,inp.depfile,inp.mskfile);
                handles.model.sfincs.domain(ad).mask=msk;
                handles.model.sfincs.domain(ad).gridz=z;
            end
                        
            % Coastline file
            if ~isempty(inp.cstfile)
                handles.model.sfincs.domain(ad).coastline=sfincs_read_coastline(inp.cstfile);
            end
            
            % Bnd file
            if ~isempty(inp.bndfile)
                handles.model.sfincs.domain(ad).flowboundarypoints=sfincs_read_boundary_points(inp.bndfile);
                % Bzs file
                [t,val]=sfincs_read_boundary_conditions(inp.bzsfile);
                handles.model.sfincs.domain(ad).flowboundaryconditions.time=inp.tref+t/86400;
                handles.model.sfincs.domain(ad).flowboundaryconditions.zs=val;
            end

            % Bwv file
            if ~isempty(inp.bwvfile)
                handles.model.sfincs.domain(ad).waveboundarypoints=sfincs_read_boundary_points(inp.bwvfile);
                % Bhs file
                [t,val]=sfincs_read_boundary_conditions(inp.bhsfile);
                handles.model.sfincs.domain(ad).waveboundarypoints.time=inp.tref+t/86400;
                handles.model.sfincs.domain(ad).waveboundarypoints.hs=val;
                [t,val]=sfincs_read_boundary_conditions(inp.btpfile);
                handles.model.sfincs.domain(ad).waveboundarypoints.tp=val;
                [t,val]=sfincs_read_boundary_conditions(inp.bwdfile);
                handles.model.sfincs.domain(ad).waveboundarypoints.wd=val;                
            end

            % Obs file
            if ~isempty(inp.obsfile)
                handles.model.sfincs.domain(ad).obspoints=sfincs_read_boundary_points(inp.obsfile);
            end

            % Obs file
            if ~isempty(inp.srcfile)
                handles.model.sfincs.domain(ad).sourcepoints=sfincs_read_boundary_points(inp.srcfile);
                [t,val]=sfincs_read_boundary_conditions(inp.disfile);
                handles.model.sfincs.domain(ad).sourcepoints.time=inp.tref+t/86400;
                handles.model.sfincs.domain(ad).sourcepoints.q=val;                
            end
            
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
            
            setHandles(handles);
            ddb_plotsfincs('plot','active',0,'visible',1);
            gui_updateActiveTab;
        end        
    otherwise
end
