function [xg_save,yg_save,zg_save,msk,indices,subgrd] = sfincs_make_subgrid_file_external(dr,bathy,grid,varargin)
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

%%
nbin = 20;
derefine_sbg_x = 20;
derefine_sbg_y = 20;

derefine_factor_grid = 0;
refine_factor_grid = 0;

zlev = [-2 50];
xy.length = 0;
xy_ex.length = 0;

subgrid = 1;

subgridfile = 'sfincs.sbg';
indexfile = 'sfincs.ind';
depfile = 'sfincs.dep';
mskfile = 'sfincs.msk';


for i=1:length(varargin)
    if ischar(varargin{i})
        switch lower(varargin{i})
            case{'nbin'}
                nbin = varargin{i+1};
            case{'derefine_sbg_x'}
                derefine_sbg_x = varargin{i+1};
            case{'derefine_sbg_y'}
                derefine_sbg_y = varargin{i+1};                
            case{'derefine_factor_grid'}
                derefine_factor_grid = varargin{i+1};
            case{'refine_factor_grid'}
                refine_factor_grid = varargin{i+1};   
            case{'zlev'}
                zlev = varargin{i+1};    
            case{'includepolygon'}
                xy = varargin{i+1};
            case{'excludepolygon'}
                xy_ex = varargin{i+1};                 
            case{'subgrid'}
                subgrid = varargin{i+1};                 
        end
    end
end

cd(dr)

%% read flux grid
xg = grid.x;
yg = grid.y;

% Refining for grid for SFINCS, interpolation of current grid -> info will be used as subgrid features
if refine_factor_grid > 0
    disp('start refining flux grid')
    
    nmax= size(xg,1);
    mmax= size(xg,2);
    dx  = nanmedian(diff(xg(1,:)));
    dy  = nanmedian(diff(yg(:,1)));
    x0  = min(min(xg));
    y0  = min(min(yg));
%         x = linspace(0,(mmax-1)*dx,(mmax*refine)-1); x = x + x0;
%         y = linspace(0,(nmax-1)*dy,(nmax*refine)-1); y = y + y0;
    x = 0:dx/refine_factor_grid:dx*(mmax-1); x = x + x0;
    y = 0:dy/refine_factor_grid:dy*(nmax-1); y = y + y0;

    [xg,yg] = meshgrid(x, y); %ignore rotations

    disp('start refining flux grid > done')
    
end

% Coarsening for grid for SFINCS -> info will be used as subgrid features    
if derefine_factor_grid > 0
    disp('start coarsening flux grid')

    xg      = xg([1:derefine_factor_grid:end],[1:derefine_factor_grid:end]);
    yg      = yg([1:derefine_factor_grid:end],[1:derefine_factor_grid:end]);
%     zg      = zg([1:derefine_factor_grid:end],[1:derefine_factor_grid:end]);
    disp('start coarsening flux grid and bathy > done')

end  

%% Compute first scatteredInterpolant without extrapolation
% if exist('F','var') == 0     %(only compute if variable isnt opened yet already to save time)
if ~exist([dr,'\xgygzg.mat']) %load saved file
    disp('Compute F the first time')
    iiend = ceil(size(bathy.x,1)/500);
    jjend = ceil(size(bathy.x,2)/500);
    
    zg = NaN(size(xg));
    count = 0;
    for ii = 1:iiend %do now per 500 cells
        for jj = 1:jjend
            count = count +1;
            disp(count)
            % cell indices
            if ii == iiend
                ic2 = size(bathy.x,1);
                ic1 = ic2- 1;
            else
                ic1=(ii-1)*500+1;                
                ic2=(ii  )*500;
            end      
            if jj == jjend
                jc2 = size(bathy.x,2);
                jc1 = jc2-1;
            else
                jc1=(jj-1)*500+1;                
                jc2=(jj  )*500;
            end        


            xxx = bathy.x(ic1:ic2,jc1:jc2);
            yyy = bathy.y(ic1:ic2,jc1:jc2);
            zzz = bathy.z(ic1:ic2,jc1:jc2);
            clear F
            F   = scatteredInterpolant(xxx(:),yyy(:),zzz(:),'linear','none');   

            zgtmp = F(xg,yg);
            
            zg(isnan(zg)) = zgtmp(isnan(zg)); %only add not filled cells
            
%             figure; pcolor(xg,yg,zg); shading flat;
        end
    end
    clear ic1 jc1 ic2 jc2
    disp('Compute F the first time > done')

    %TL: good idea to limit the size of the matrix
    %into 'F'? e.g. 5000x5000 > thus make F{1} F{2} etc
    %based on location on grid , can also be that if
    %these are 5 areas, the subgrid creation should be
    %done parallelised of these 5 areas at the same
    %time e.g.
    s.xg = xg;
    s.yg = yg;
    s.zg = zg;

    save([dr,'xgygzg.mat'],'s')
    clear s    
else
    load([dr,'\xgygzg.mat'])
    xg = s.xg;
    yg = s.yg;
    zg = s.zg;    
end

%% Topobathy to be used for determining mask and to put in dep-file

% zg = gridcellaveraging2(bathy.x, bathy.y, bathy.z,xg, yg, round(res), 'mean'); %TL: better when coarsening?
clear F % later make F per subblock

%% Read sfincs inputs
mmax=size(xg,2);
nmax=size(yg,1);  %1!
dx = xg(1,2) - xg(1,1);
dy = yg(2,1) - yg(1,1);
x0=xg(1,1);
y0=yg(1,1);
rotation= 0; %TL: could be calculated too, then add warning if refining/coarsening was performed

di=dy;       % cell size
dj=dx;       % cell size
dif=dy/derefine_sbg_y; % size of subgrid pixel
djf=dx/derefine_sbg_x; % size of subgrid pixel
refi = derefine_sbg_y; % refinement factor
refj = derefine_sbg_x; % refinement factor
imax=nmax;
jmax=mmax;

cosrot=cos(rotation*pi/180);
sinrot=sin(rotation*pi/180);

xg_save = xg;
yg_save = yg;    
zg_save = zg;

%% Display
disp(['Used grid size of flux grid is dx= ',num2str(dx),' and dy= ',num2str(dy)])
disp(['Used grid size of subgrid pixels is dx= ',num2str(dif),' and dy= ',num2str(djf)])

%% Create a mask
if isempty(grid.msk)
    msk = sfincs_make_mask(xg,yg,zg,zlev,'includepolygon', xy, 'excludepolygon', xy_ex); % nothing happens if xy.length= 0 (or xy_ex)        
else
    msk = grid.msk;
    if size(msk,1) ~= size(zg_save,1) || size(msk,2) ~= size(zg_save,2)
       error('Supplied msk matrix does not have the same size as wanted grid! > Check grid.msk input ')
    end
end
%% Make subgrid file
if subgrid == 1

nrmax=min(round(2000*dif/di),round(2000*djf/dj)); % maximum number of cells in a block (limit size of subgrid block to 2000x2000)

nib=floor(nrmax/(di/dif)); % nr of cells in a block
njb=floor(nrmax/(dj/djf)); % nr of cells in a block
if nib==0
    nib = 1; % always need 1 cell in a block
end
if njb==0
    njb = 1;
end
ni=ceil(imax/nib); % nr of blocks
nj=ceil(jmax/njb); % nr of blocks

% Initialize arrays
subgrd.z_zmin=zeros(ni*nib,nj*njb);
subgrd.z_zmax=zeros(ni*nib,nj*njb);
subgrd.z_vol=zeros(ni*nib,nj*njb,nbin);

subgrd.u_zmin=zeros(ni*nib,nj*njb);
subgrd.u_zmax=zeros(ni*nib,nj*njb);
subgrd.u_area=zeros(ni*nib,nj*njb,nbin);
subgrd.u_width=zeros(ni*nib,nj*njb,nbin);

subgrd.v_zmin=zeros(ni*nib,nj*njb);
subgrd.v_zmax=zeros(ni*nib,nj*njb);
subgrd.v_area=zeros(ni*nib,nj*njb,nbin);
subgrd.v_width=zeros(ni*nib,nj*njb,nbin);

ib=0;
for ii=1:ni
    for jj=1:nj

        %% Loop through blocks

        ib=ib+1;
        
        disp(['Processing block ' num2str(ib) ' of ' num2str(ni*nj)]);
        
        % cell indices
        ic1=(ii-1)*nib+1;
        jc1=(jj-1)*njb+1;
        ic2=(ii  )*nib;
        jc2=(jj  )*njb;
        
        % Make subgrid
        xx0=(jj-1)*njb*dj;
        yy0=(ii-1)*nib*di;
        xx1=jj*njb*dj-djf;
        yy1=ii*nib*di-dif;
        xx1=xx1+dj; % add extra row cuz we need data in u points
        yy1=yy1+di; % add extra row cuz we need data in v points
        xx=xx0:djf:xx1;
        yy=yy0:dif:yy1;
        xx=xx+0.5*djf;
        yy=yy+0.5*dif;
        [xx,yy]=meshgrid(xx,yy);
        xg = x0 + cosrot*xx + sinrot*yy;
        yg = y0 - sinrot*xx + cosrot*yy;
        
        xx=xx0:djf:xx1;
        yy=yy0:dif:yy1;
        xx=xx+0.5*djf;
        yy=yy+0.5*dif;        
        xx = [xx0 - 2*djf, xx, xx1 + 2*djf ];
        yy = [yy0 - 2*dif, yy, yy1 + 2*dif ];
        [xx,yy]=meshgrid(xx,yy); % for determination local F, enlarge box a bit
        xgtmp = x0 + cosrot*xx + sinrot*yy;
        ygtmp = y0 - sinrot*xx + cosrot*yy;
        clear xx yy
        
        % Convert subgrid to WGS 84 (should it not be converted to the coordinate system of the bathymetry dataset? Yes, but let's assume for now that the data are in WGS 84!)
%         [xg,yg]=convertCoordinates(xg,yg,'persistent','CS1.name',model.cs.name,'CS1.type',model.cs.type,'CS2.name','WGS 84','CS2.type','geographic');
        
        % Now get the bathy data for this block
        clear idwanted
        idwanted = inpolygon(bathy.x,bathy.y,[xgtmp(1,1),xgtmp(1,end),xgtmp(end,end),xgtmp(end,1),xgtmp(1,1)],[ygtmp(1,1),ygtmp(1,end),ygtmp(end,end),ygtmp(end,1),ygtmp(1,1)]);
        
        xtmp = bathy.x(idwanted);
        ytmp = bathy.y(idwanted);
        ztmp = bathy.z(idwanted);

        clear F
        F   = scatteredInterpolant(xtmp,ytmp,ztmp,'linear','none');                                         

        % Determine bounding box
        xmin=min(min(xg));
        xmax=max(max(xg));
        ymin=min(min(yg));
        ymax=max(max(yg));
        
        % Initialize depth of subgrid at NaN
        zg=zeros(size(xg));
        zg(zg==0)=NaN;
        
        % Loop through bathymetry datasets        
        
        zg = F(xg,yg);
                
        if maxmax(isnan(zg)) == 1 % if NaNs then extrapolate with method nearest
            disp('Second interpolation method needed to avoid NaNs (is slower)')

            F2 = scatteredInterpolant(xtmp,ytmp,ztmp, 'linear', 'nearest');                                      

            zg = F2(xg,yg);
            clear F2
        end

        clear xg yg zg1 xx yy zz
        
        %% Now compute subgrid properties
        
        % Volumes
        np=0;
        d=zeros(nib,njb,refi*refj); % First create 3D matrix (nmax,mmax,refi*refj)
        d(d==0)=NaN;
        for iref=1:refi
            for jref=1:refj
                np=np+1;
                i1=iref;
                i2=i1+(nib-1)*refi;
                j1=jref;
                j2=j1+(njb-1)*refj;
                zg1=zg(i1:refi:i2,j1:refj:j2);
                d(:,:,np)=zg1;
            end
        end
        [dmin,dmax,vvv]=sfincs_subgrid_volumes(d,nbin,dx,dy);
        
        subgrd.z_zmin(ic1:ic2,jc1:jc2)=dmin;
        subgrd.z_zmax(ic1:ic2,jc1:jc2)=dmax;
        subgrd.z_vol(ic1:ic2,jc1:jc2,:)=vvv;
        
        % U-points
        np=0;
        d=zeros(nib,njb,refi*refj); % First create 3D matrix (nmax,mmax,refi*refj)
        d(d==0)=NaN;
        for iref=1:refi
            for jref=1:refj
                np=np+1;
                i1=iref;
                i2=i1+(nib-1)*refi;
                j1=jref+0.5*refj;
                j2=j1+(njb-1)*refj+0.5*refj;
                zg1=zg(i1:refi:i2,j1:refj:j2);
                d(:,:,np)=zg1;
            end
        end
        [dmin,dmax,aaa,www]=sfincs_subgrid_area_and_depth(d,nbin,dy);
        
        subgrd.u_zmin(ic1:ic2,jc1:jc2)=dmin;
        subgrd.u_zmax(ic1:ic2,jc1:jc2)=dmax;
        subgrd.u_area(ic1:ic2,jc1:jc2,:)=aaa;
        subgrd.u_width(ic1:ic2,jc1:jc2,:)=www;
        
        % V-points
        np=0;
        d=zeros(nib,njb,refi*refj); % First create 3D matrix (nmax,mmax,refi*refj)
        d(d==0)=NaN;
        for iref=1:refi
            for jref=1:refj
                np=np+1;
                i1=iref+0.5*refi;
                i2=i1+(nib-1)*refi+0.5*refi;
                j1=jref;
                j2=j1+(njb-1)*refj;
                zg1=zg(i1:refi:i2,j1:refj:j2);
                d(:,:,np)=zg1;
            end
        end
        [dmin,dmax,aaa,www]=sfincs_subgrid_area_and_depth(d,nbin,dy);
        
        subgrd.v_zmin(ic1:ic2,jc1:jc2)=dmin;
        subgrd.v_zmax(ic1:ic2,jc1:jc2)=dmax;
        subgrd.v_area(ic1:ic2,jc1:jc2,:)=aaa;
        subgrd.v_width(ic1:ic2,jc1:jc2,:)=www;
        
    end
end

subgrd.z_zmin=subgrd.z_zmin(1:nmax,1:mmax,:);
subgrd.z_zmax=subgrd.z_zmax(1:nmax,1:mmax,:);
subgrd.z_vol =subgrd.z_vol(1:nmax,1:mmax,:);

subgrd.u_zmin=subgrd.u_zmin(1:nmax,1:mmax,:);
subgrd.u_zmax=subgrd.u_zmax(1:nmax,1:mmax,:);
subgrd.u_area=subgrd.u_area(1:nmax,1:mmax,:);
subgrd.u_width=subgrd.u_width(1:nmax,1:mmax,:);

subgrd.v_zmin=subgrd.v_zmin(1:nmax,1:mmax,:);
subgrd.v_zmax=subgrd.v_zmax(1:nmax,1:mmax,:);
subgrd.v_area=subgrd.v_area(1:nmax,1:mmax,:);
subgrd.v_width=subgrd.v_width(1:nmax,1:mmax,:);

sfincs_write_binary_subgrid_tables(subgrd,msk,nbin,subgridfile);
fclose('all');
end

%% Also write index, depth and msk-files in binary
% Index file
indices=find(msk>0);    
mskv=msk(msk>0);
fid=fopen(indexfile,'w');
fwrite(fid,length(indices),'integer*4');
fwrite(fid,indices,'integer*4');
fclose(fid);

% Depth file
zg_save(msk==0) = NaN; 
zv=zg_save(indices); 

zv= zv;                      % depth is down!
fid=fopen(depfile,'w');
fwrite(fid,zv,'real*4');
fclose(fid);

% Mask file
fid=fopen(mskfile,'w');
fwrite(fid,mskv,'integer*1');
fclose(fid);    


