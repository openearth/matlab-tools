function sfincs_build_model(inp,folder,bathy,cs,varargin)

initialize_bathymetry_database;

if ~exist(folder,'dir')
    mkdir(folder);
end

% Defaults
zmin=-2;
zmax=10;

% Sub grid
nbin=5;                               % Number of bins in subgrid table
subgrid_dx=10;                        % Subgrid refinement factor w.r.t. SFINCS grid in n direction
subgrid_uopt='minmean';
maxdzdv=10;
usemex=1;

xy_in=[];
xy_ex=[];
xy_bnd_closed=[];
xy_bnd_open=[];

if isempty(inp)
    inp=sfincs_initialize_input;
    inp.depfile='sfincs.inp';
    inp.mskfile='sfincs.msk';
    inp.indexfile='sfincs.ind';
end

%% Read input arguments
for ii=1:length(varargin)
    if ischar(varargin{ii})
        switch lower(varargin{ii})
            case{'sbgfile'}
                inp.sbgfile=varargin{ii+1};
            case{'subgrid_nbin'}
                nbin=varargin{ii+1};
            case{'subgrid_dx'}
                subgrid_dx=varargin{ii+1};
            case{'subgrid_uopt'}
                subgrid_uopt=varargin{ii+1};
            case{'x0'}
                inp.x0=varargin{ii+1};                
            case{'y0'}
                inp.y0=varargin{ii+1};                
            case{'dx'}
                inp.dx=varargin{ii+1};                
            case{'dy'}
                inp.dy=varargin{ii+1};                
            case{'mmax'}
                inp.mmax=varargin{ii+1};                
            case{'nmax'}
                inp.nmax=varargin{ii+1};                
            case{'rotation'}
                inp.rotation=varargin{ii+1};                
            case{'manning_sea'}
                inp.manning_sea=varargin{ii+1};                
            case{'manning_land'}
                inp.manning_land=varargin{ii+1};                
            case{'rgh_lev_land'}
                inp.rgh_lev_land=varargin{ii+1};                
            case{'zmin'}
                zmin=varargin{ii+1};                
            case{'zmax'}
                zmax=varargin{ii+1};                
            case{'includepolygon'}
                if ~isempty(varargin{ii+1})
                    xy_in=load_polygon(varargin{ii+1});
                end
            case{'excludepolygon'}
                if ~isempty(varargin{ii+1})
                    xy_ex=load_polygon(varargin{ii+1});
                end
            case{'closedboundarypolygon'}
                if ~isempty(varargin{ii+1})
                    xy_bnd_closed=load_polygon(varargin{ii+1});
                end
            case{'openboundarypolygon'}
                if ~isempty(varargin{ii+1})
                    xy_bnd_open=load_polygon(varargin{ii+1});
                end
        end
    end
end

% Create grid
disp('Making grid ...');
[xg,yg,xz,yz]=sfincs_make_grid(inp.x0,inp.y0,inp.dx,inp.dy,inp.mmax,inp.nmax,inp.rotation);

% Create bathymetry
disp('Making bathymetry ...');
zz=interpolate_bathymetry_to_grid(xz,yz,[],bathy,cs,'quiet');

% Create mask
disp('Making mask ...');
msk=sfincs_make_mask(xz,yz,zz,[zmin zmax],'includepolygon',xy_in,'excludepolygon',xy_ex,'closedboundarypolygon',xy_bnd_closed,'openboundarypolygon',xy_bnd_open);
%msk=zeros(size(zz))+1;

% Write grid files
disp('Writing files ...');
sfincs_write_binary_inputs(zz,msk,[folder inp.indexfile],[folder inp.depfile],[folder inp.mskfile]);

% Write input file (this needs to be done before writing the subgrid file)
sfincs_write_input([folder 'sfincs.inp'],inp);

% Create subgrid file
if ~isempty(inp.sbgfile)
    disp('Making subgrid file ...');
    refi=ceil(inp.dx/subgrid_dx);
    refj=refi;
    sfincs_make_subgrid_file_v7(folder,inp.sbgfile,bathy,cs,nbin,refi,refj,subgrid_uopt,maxdzdv,usemex,inp.manning_sea,inp.manning_land,inp.rgh_lev_land);       
end

disp('Done.');

%%
function p=load_polygon(fname)
data=tekal('read',fname,'loaddata');
np=length(data.Field);
for ip=1:np
    x=data.Field(ip).Data(:,1);
    y=data.Field(ip).Data(:,2);
    if x(end)~=x(1) || y(end)~=y(1)
        x=[x;x(1)];
        y=[y;y(1)];
    end
    p(ip).x=x;
    p(ip).y=y;
end
