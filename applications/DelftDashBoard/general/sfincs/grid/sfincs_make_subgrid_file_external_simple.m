function [subgrd1] = sfincs_make_subgrid_file_external_simple(dr,bathy,varargin)
% Makes SFINCS subgrid file external of DDB using already merged topobathy struct (can still be from DDB)
%
% E.g.:
%
% dr = pwd;                          % name of output folder where all files will be written
% bathy;                             % struct of merged bathy dataset containing 'x','y' and 'z',
% best practice: avoid NaNs and for speedup make x/y extend bigger than wanted flux grid (extrapolation is expensive), but only as little as possible
% the script can deal with these things but efficiency is reduced
% grid:                              % struct of wanted flux grid containing 'x' and 'y', can be refined or coarsened still
% option to add '.msk' as well if current msk needs to be re-used, should be same size as wanted grid (after refining/coarsening)
% grid cannot be rotated yet when derefine_factor_grid or refine_factor_grid are > 0!
% no coordinate conversion included so bathy and grid should both be in same projected coordinate system
% sfincs_make_subgrid_file_external(dr,bathy,grid)
% sfincs_make_subgrid_file_external(dr,bathy,grid,'derefine_sbg_x',20,'derefine_sbg_y',20,'derefine_factor_grid',2,'zlev',[-2 150]
%,'includepolygon',xy,'excludepolygon)',xy_ex)

% varargin:  % supply as keyword - argument pairs
% nbin=20;                           % Number of bins in subgrid table (default = 20)
% derefine_sbg_x=20;                 % Subgrid refinement factor w.r.t. SFINCS grid in m direction (default = 20)
% derefine_sbg_y=20;                 % Subgrid refinement factor w.r.t. SFINCS grid in n direction (default = 20)
% derefine_factor_grid = 2;          % factor to coarsen the flux grid given in 'grid' (default = 0)
% refine_factor_grid = 2;            % factor to refine the flux grid given in 'grid' (default = 0), use either derefine_factor_grid or refine_factor_grid
% zlev = [-2 50];                    % minimum and maximum bed level used to determine msk-file (default = [-2 50])
% includepolygon = xy;               % struct with include polygon to determine msk-file, e.g.: xy.length=1, xy.x = [0] xy.y = [10];% see sfincs_make_mask.m
% excludepolygon = xy_ex;            % struct with exclude polygon to determine msk-file, e.g.: xy.length=1, xy.x = [0] xy.y = [10];% see sfincs_make_mask.m
% subgrid = 1;                       % turn on (1) or off (0) generation of subgrid tables (default = 1). Can be done if in same function also non-subgrid versions of sfincs are e.g. wanted, with possible coarsening/refinement

% Output:
% script gives back the matrices of x,y,z of the flux grid and the msk, this can be used for visualisation or making the sfincs.inp file

%% Options
nbin                    = 25;
derefine_sbg_x          = 5;
derefine_sbg_y          = 5;
maxdzdv                 = 10;           
uopt                    = 'minmean';
subgridfile             = 'sfincs.sbg';
        
% varagin
for i=1:length(varargin)
    if ischar(varargin{i})
        switch lower(varargin{i})
            case{'nbin'}
                nbin = varargin{i+1};
            case{'derefine_sbg_x'}
                derefine_sbg_x = varargin{i+1};
            case{'derefine_sbg_y'}
                derefine_sbg_y = varargin{i+1};
        end
    end
end
cd(dr)

%% Read SFINCS grid and 
% Read sfincs inputs
inp=sfincs_read_input([dr 'sfincs.inp'],[]);

mmax    = inp.mmax;
nmax    = inp.nmax;
dx      = inp.dx;
dy      = inp.dy;
x0      = inp.x0;
y0      = inp.y0;
rotation= inp.rotation;

cd(dr)
[z,msk] = sfincs_read_binary_inputs(mmax,nmax,inp.indexfile,inp.depfile,inp.mskfile);

di=dy;       % cell size
dj=dx;       % cell size
dif=dy/derefine_sbg_y; % size of subgrid pixel
djf=dx/derefine_sbg_x; % size of subgrid pixel
imax=nmax+1; % add extra cell to compute u and v in the last row/column
jmax=mmax+1; %

cosrot=cos(rotation*pi/180);
sinrot=sin(rotation*pi/180);

nrmax=2000;
nib=floor(nrmax/(di/dif));          % nr of regular cells in a block
njb=floor(nrmax/(dj/djf));          % nr of regular cells in a block
ni=ceil(imax/nib);                  % nr of blocks
nj=ceil(jmax/njb);                  % nr of blocks

% Initialise
subgrd.z_zmin               = zeros(imax,jmax);
subgrd.z_zmax               = zeros(imax,jmax);
subgrd.z_volmax             = zeros(imax,jmax);
subgrd.z_depth              = zeros(imax,jmax,nbin);
subgrd.z_hrep               = zeros(imax,jmax,nbin);
subgrd.z_dhdz               = zeros(imax,jmax);

% Display
disp(['Used grid size of flux grid is dx= ',num2str(dx),' and dy= ',num2str(dy)])
disp(['Used grid size of subgrid pixels is dx= ',num2str(djf),' and dy= ',num2str(dif)])


%% Make subgrid file
% Loop through blocks
ib=0;
for ii=1:ni
    for jj=1:nj
        
        %% Loop through blocks
        ib=ib+1;
        disp(['Processing block ' num2str(ib) ' of ' num2str(ni*nj)]);
        
        %% Get indices and grid
        % cell indices
        ic1=(ii-1)*nib+1;
        jc1=(jj-1)*njb+1;
        ic2=(ii  )*nib;
        jc2=(jj  )*njb;
        ic2=min(ic2,imax);
        jc2=min(jc2,jmax);
        
        % Actual number of grid cells in this block (after cutting off irrelevant edges)
        nib1=ic2-ic1+1;
        njb1=jc2-jc1+1;
        
        % Make subgrid
        xx0=(jj-1)*njb*dj;
        yy0=(ii-1)*nib*di;
        xx1=xx0 + njb1*dj - djf;
        yy1=yy0 + nib1*di - dif;
        xx=xx0:djf:xx1;
        yy=yy0:djf:yy1;
        xx=xx+0.5*djf;
        yy=yy+0.5*dif;
        [xx,yy]=meshgrid(xx,yy);
        xg0 = x0 + cosrot*xx - sinrot*yy;
        yg0 = y0 + sinrot*xx + cosrot*yy;
        clear xx yy
        
        %% Determine bathymetry
        % Initialize depth of subgrid at NaN
        zg=zeros(size(xg0));
        zg(zg==0)=NaN;
        mg=zg;              % grid of manning
        
        % Make function to interpolate high resolution bathy to subgrid
        bboxx=[nanmin(nanmin(xg0))-100 nanmax(nanmax(xg0))+100];
        bboxy=[nanmin(nanmin(yg0))-100 nanmax(nanmax(yg0))+100];
        idw  = find(bathy.x > bboxx(1) & bathy.x < bboxx(2) & bathy.y > bboxy(1) & bathy.y < bboxy(2));
        F    = scatteredInterpolant(bathy.x(idw), bathy.y(idw), bathy.z(idw),'natural', 'none');
        zg   = F(xg0,yg0);
        clear F
        
        % now manning too
        F    = scatteredInterpolant(bathy.x(idw), bathy.y(idw), bathy.manning(idw),'natural', 'none');
        mg   = F(xg0,yg0);
        clear F

        % Extrapolate when needed
        if maxmax(isnan(zg)) == 1 % if NaNs then extrapolate with method nearest

            % Bathy first
            disp(' second interpolation method needed to avoid NaNs (is slower)')
            F2  = scatteredInterpolant(bathy.x(idw), bathy.y(idw), bathy.z(idw),'natural', 'nearest');
            zg  = F2(xg0,yg0);
            clear F2

            % now manning too
            F2   = scatteredInterpolant(bathy.x(idw), bathy.y(idw), bathy.manning(idw),'natural', 'nearest');
            mg   = F2(xg0,yg0);
            clear F2 
        end
        
        %% Now compute subgrid properties
        % Get depths
        np=0;
        d=zeros(nib1,njb1,derefine_sbg_x*derefine_sbg_y); % First create 3D matrix (nmax,mmax,refi*refj)
        d(d==0)=NaN;
        n=d;
        for iref=1:derefine_sbg_x
            for jref=1:derefine_sbg_y
                np=np+1;
                i1=iref;
                i2=i1+(nib1-1)*derefine_sbg_x;
                j1=jref;
                j2=j1+(njb1-1)*derefine_sbg_y;
                zg1=zg(i1:derefine_sbg_x:i2,j1:derefine_sbg_y:j2);
                mg1=mg(i1:derefine_sbg_x:i2,j1:derefine_sbg_y:j2);
                d(:,:,np)=zg1;
                n(:,:,np)=mg1;
            end
        end
        
        % Volumes based on depth
        [zmin,zmax,volmax,ddd]              = mx_subgrid_volumes(d,nbin,dx,dy,maxdzdv);
        subgrd.z_zmin(ic1:ic2,jc1:jc2)      = zmin;
        subgrd.z_zmax(ic1:ic2,jc1:jc2)      = zmax;
        subgrd.z_volmax(ic1:ic2,jc1:jc2)    = volmax;
        subgrd.z_depth(ic1:ic2,jc1:jc2,:)   = ddd;
        
        % Do the same for manning (tbd; now constant)
        [zmin,zmax,ddd,dhdz]                = mx_subgrid_depth(d,n,nbin,dx);
        subgrd.z_hrep(ic1:ic2,jc1:jc2,:)    = ddd;
        subgrd.z_dhdz(ic1:ic2,jc1:jc2,:)    = dhdz;
        
    end
end

% subgrd struture for z points has now been created (dimensions: nmax+1,mmax+1,nbin)

% Now let's get subgrd structure for u and v points
switch lower(uopt)
    case{'mean'}
        iopt=0;
    case{'min'}
        iopt=1;
    case{'minmean'}
        iopt=2;
end
[u_zmin,u_zmax,u_dhdz,u_hrep,v_zmin,v_zmax,v_dhdz,v_hrep]=mx_subgrid_uv(subgrd.z_zmin,subgrd.z_zmax,subgrd.z_dhdz,subgrd.z_hrep,iopt);

% Allocate variables
subgrd1.z_zmin   = subgrd.z_zmin(1:nmax,1:mmax,:);
subgrd1.z_zmax   = subgrd.z_zmax(1:nmax,1:mmax,:);
subgrd1.z_volmax = subgrd.z_volmax(1:nmax,1:mmax,:);
subgrd1.z_depth  = subgrd.z_depth(1:nmax,1:mmax,:);

subgrd1.u_zmin   = u_zmin;
subgrd1.u_zmax   = u_zmax;
subgrd1.u_dhdz   = u_dhdz;
subgrd1.u_hrep   = u_hrep;
subgrd1.v_zmin   = v_zmin;
subgrd1.v_zmax   = v_zmax;
subgrd1.v_dhdz   = v_dhdz;
subgrd1.v_hrep   = v_hrep;

% Write subgrid
cd(dr)
sfincs_write_binary_subgrid_tables_v7(subgrd1,msk,nbin,subgridfile,uopt);
fclose('all');
