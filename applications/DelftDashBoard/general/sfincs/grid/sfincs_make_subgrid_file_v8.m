function sfincs_make_subgrid_file_v8(dr,subgridfile,bathy,manning_input,cs,nbin,refi,refj,uopt,maxdzdv,usemex,varargin)
% Makes SFINCS subgrid file in the folder dr
%
% E.g.:
%
% dr='d:\sfincstest\run01\';         % output folder
% subgridfile='sfincs.sbg';          % name of subgrid file
% bathy(1).name='ncei_new_river_nc'; % first bathy dataset
% bathy(2).name='usgs_ned_coastal';  % second bathy dataset
% bathy(3).name='ngdc_crm';          % third bathy dataset
% cs.name='WGS 84 / UTM zone 18N';   % cs name of model
% cs.type='projected';               % cs type of model
% nbin=5;                            % Number of bins in subgrid table
% refi=20;                           % Subgrid refinement factor w.r.t. SFINCS grid in n direction
% refj=20;                           % Subgrid refinement factor w.r.t. SFINCS grid in m direction
%
% sfincs_make_subgrid_file(dr,subgridfile,bathy,cs,nbin,refi,refj)
%%

polygons=[];

%% Read input arguments
for ii=1:length(varargin)
    if ischar(varargin{ii})
        switch lower(varargin{ii})
            case{'polygons'}
                polygons=varargin{ii+1};
        end
    end
end

if ~isempty(cs)
    
    global bathymetry

    if isempty(bathymetry)
        error('Bathymetry database has not yet been initialized! Please run initialize_bathymetry_database.m first.')
    end
    
    subgridfile=[dr filesep subgridfile];
    
    for ib=1:length(bathy)
        model.bathymetry(ib).name=bathy(ib).name;
        ii=strmatch(lower(bathy(ib).name),lower(bathymetry.datasets),'exact');
        model.bathymetry(ib).csname=bathymetry.dataset(ii).horizontalCoordinateSystem.name;
        model.bathymetry(ib).cstype=bathymetry.dataset(ii).horizontalCoordinateSystem.type;
    end
    
    model.cs.name=cs.name;
    model.cs.type=cs.type;

end

% Read sfincs inputs
inp=sfincs_read_input([dr 'sfincs.inp'],[]);

mmax=inp.mmax;
nmax=inp.nmax;
dx=inp.dx;
dy=inp.dy;
x0=inp.x0;
y0=inp.y0;
rotation=inp.rotation;

indexfile=[dr inp.indexfile];
bindepfile=[dr inp.depfile];
binmskfile=[dr inp.mskfile];
[z,msk]=sfincs_read_binary_inputs(mmax,nmax,indexfile,bindepfile,binmskfile);

di=dy;       % cell size
dj=dx;       % cell size
dif=dy/refi; % size of subgrid pixel
djf=dx/refj; % size of subgrid pixel
imax=nmax+1; % add extra cell to compute u and v in the last row/column
jmax=mmax+1; % 

cosrot=cos(rotation*pi/180);
sinrot=sin(rotation*pi/180);

nrmax=2000;

nib=floor(nrmax/(di/dif)); % nr of regular cells in a block
njb=floor(nrmax/(dj/djf)); % nr of regular cells in a block

ni=ceil(imax/nib); % nr of blocks
nj=ceil(jmax/njb); % nr of blocks

% Initialize temporary arrays
subgrd.z_zmin=zeros(imax,jmax);
subgrd.z_zmax=zeros(imax,jmax);
subgrd.z_volmax=zeros(imax,jmax);
subgrd.z_depth=zeros(imax,jmax,nbin);
subgrd.z_hrep=zeros(imax,jmax,nbin);
subgrd.z_navg=zeros(imax,jmax,nbin);
subgrd.z_dhdz=zeros(imax,jmax);

ib=0;
for ii=1:ni
    for jj=1:nj
%for ii=1:1
%    for jj=1:1
        
        %% Loop through blocks
        
        ib=ib+1;
        
        disp(['Processing block ' num2str(ib) ' of ' num2str(ni*nj)]);
        
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

        if isempty(cs)
            cellareas=repmat(dx*dy,nib1,njb1);
        else
            if strcmpi(cs.type,'projected')
                cellareas=repmat(dx*dy,nib1,njb1);
            else
                xxc = (x0 + (jc1-1)*dx + 0.5*dx):dx: (x0 + jc2*dx - 0.5*dx);
                yyc = (y0 + (ic1-1)*dy + 0.5*dy):dy: (y0 + ic2*dx - 0.5*dy);
                [xc,yc] = meshgrid(xxc,yyc);
                cellareas = (dy*111111.1)*(dx*111111.1)*cos(yc*pi/180);
            end
        end
        
        clear xx yy
        
        % Initialize depth of subgrid at NaN
        zg=zeros(size(xg0));
        zg(zg==0)=NaN;
        
        if ~isempty(cs)
            
            % Loop through bathymetry datasets
            for ibat=1:length(model.bathymetry)
                
                % Convert model grid to bathymetry cs
                
                [xg,yg]=convertCoordinates(xg0,yg0,'persistent','CS1.name',model.cs.name,'CS1.type',model.cs.type,'CS2.name',model.bathymetry(ibat).csname,'CS2.type',model.bathymetry(ibat).cstype);
                
                xmin=nanmin(nanmin(xg));
                xmax=nanmax(nanmax(xg));
                ymin=nanmin(nanmin(yg));
                ymax=nanmax(nanmax(yg));
                ddx=0.05*(xmax-xmin);
                ddy=0.05*(ymax-ymin);
                bboxx=[xmin-ddx xmax+ddx];
                bboxy=[ymin-ddy ymax+ddy];
                
                % Now get the bathy data for this block

                if ~isempty(find(isnan(zg)))
                    
                    [xx,yy,zz,ok]=ddb_getBathymetry(bathymetry,bboxx,bboxy,'bathymetry',model.bathymetry(ibat).name,'maxcellsize',min(dif,djf),'quiet');
                    zz(zz<bathy(ibat).zmin)=NaN;
                    zz(zz>bathy(ibat).zmax)=NaN;
                    if ~isempty(find(~isnan(zz)))
                        zg1=interp2(xx,yy,zz,xg,yg);
                        zg(isnan(zg))=zg1(isnan(zg));
                    end
                end
                
                
            end
            
%             zg = zg - 1.0;
            
            % Adjust bathymetry based on polygon data
            if ~isempty(polygons)
                for ipol=1:length(polygons)
                    if strcmpi(polygons(ipol).type,'bathymetry')

                        [xpol,ypol]=landboundary('read',polygons(ipol).filename);
                        
                        xmin=nanmin(nanmin(xg0));
                        xmax=nanmax(nanmax(xg0));
                        ymin=nanmin(nanmin(yg0));
                        ymax=nanmax(nanmax(yg0));
                        
                        xminp=nanmin(xpol);
                        xmaxp=nanmax(xpol);
                        yminp=nanmin(ypol);
                        ymaxp=nanmax(ypol);
                        
                        if xminp<xmax && xmaxp>xmin && yminp<ymax && ymaxp>ymin 
                            inpol=inpolygon(xg0,yg0,xpol,ypol);
                            switch lower(polygons(ipol).operator)
                                case{'min'}
                                    zg(inpol)=min(zg(inpol),polygons(ipol).value);
                                case{'max'}
                                    zg(inpol)=max(zg(inpol),polygons(ipol).value);
                                case{'add'}
                                    zg(inpol)=zg(inpol)+polygons(ipol).value;
                                case{'eq'}
                                    zg(inpol)=min(zg(inpol),polygons(ipol).value);
                            end
                        end
                        
                    end
                end
            end
            
        else
            
            xx=bathy.x;
            yy=bathy.y;
            zz=bathy.z;
            zg=interp2(xx,yy,zz,xg0,yg0);
            zg(isnan(zg))=0;
            
        end
        
        zg(isnan(zg))=0;
        if ~isempty(find(isnan(zg)))
            error(['NaNs found in bathymetry!!! Block ii = ' num2str(ii) ', jj = ' num2str(jj)]);
        end

        % Now get manning values
        % If manning is a character string, determine it from the NLCD database
        % If manning is a structure, x, y and z 
        % If manning is a numeric, values are determined based on deep,
        % shallow and level
        if ischar(manning_input)
            sn=get_nlcd_values(manning_input,xg0,yg0,model.cs,'manning');
%            sn=get_nlcd_values_usace(manning_input,xg0,yg0,model.cs,'manning');
            manning=sn.manning;
            clear sn
        elseif isstruct(manning_input) % x and y must be in the same coordinate system as the model !!!
            manning=interp2(manning_input.x,manning_input.y,manning_input.val,xg,yg);            
        else
            manning_deep    = manning_input(1);
            manning_shallow = manning_input(2);
            manning_level   = manning_input(3);
            manning         = zeros(size(zg));
            manning(zg<manning_level)=manning_deep;
            manning(zg>=manning_level)=manning_shallow;
        end
        
        % Set all roughness values below 0.0 m to 0.028
        ideep=find(zg<=0);
        manning(ideep)=min(manning(ideep), 0.024);
%        manning=max(manning,0.028);
%        manning=min(manning,0.040);
        
        clear zg1 xx yy zz
        
        %% Now compute subgrid properties
        
        % Volumes
        np=0;
        d=zeros(nib1,njb1,refi*refj); % First create 3D matrix (nmax,mmax,refi*refj)
        d(d==0)=NaN;
        manning1=d;
        for iref=1:refi
            for jref=1:refj
                np=np+1;
                i1=iref;
                i2=i1+(nib1-1)*refi;
                j1=jref;
                j2=j1+(njb1-1)*refj;
                zg1=zg(i1:refi:i2,j1:refj:j2);
                d(:,:,np)=zg1;
                manning1(:,:,np)=manning(i1:refi:i2,j1:refj:j2);
            end
        end
        
        if usemex
            [zmin,zmax,volmax,ddd]=mx_subgrid_volumes(d,cellareas,nbin,dx,dy,maxdzdv);
%            [zmin,zmax,volmax,ddd]=mx_subgrid_volumes(d,nbin,dx,dy,maxdzdv);
        else
            % Should get rid of this option
            [zmin,zmax,volmax,ddd]=sfincs_subgrid_volumes_ddd(d,nbin,dx,dy);
        end
        subgrd.z_zmin(ic1:ic2,jc1:jc2)=zmin;
        subgrd.z_zmax(ic1:ic2,jc1:jc2)=zmax;
        subgrd.z_volmax(ic1:ic2,jc1:jc2)=volmax;
        subgrd.z_depth(ic1:ic2,jc1:jc2,:)=ddd;
         
        if usemex
            
%            [zmin,zmax,ddd,dhdz]=mx_subgrid_depth(d,manning1,nbin,dx);
            [zmin,zmax,ddd,dhdz,navg]=mx_subgrid_depth_02(d,manning1,nbin,100.0);

        else
            
            % Should get rid of this option
            [zmin,zmax,ddd]=sfincs_subgrid_area_and_depth_v5(d,nbin,dy);
            dhdz=zeros(size(ddd))+1;

        end

        subgrd.z_hrep(ic1:ic2,jc1:jc2,:)=ddd;
        subgrd.z_dhdz(ic1:ic2,jc1:jc2,:)=dhdz;
        subgrd.z_navg(ic1:ic2,jc1:jc2,:)=navg;
                
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

[u_zmin,u_zmax,u_dhdz,u_hrep,u_navg,v_zmin,v_zmax,v_dhdz,v_hrep,v_navg]=mx_subgrid_uv_02(subgrd.z_zmin,subgrd.z_zmax,subgrd.z_dhdz,subgrd.z_hrep,subgrd.z_navg,iopt);

subgrd1.z_zmin   = subgrd.z_zmin(1:nmax,1:mmax,:);
subgrd1.z_zmax   = subgrd.z_zmax(1:nmax,1:mmax,:);
subgrd1.z_volmax = subgrd.z_volmax(1:nmax,1:mmax,:);
subgrd1.z_depth  = subgrd.z_depth(1:nmax,1:mmax,:);

subgrd1.u_zmin   = u_zmin;
subgrd1.u_zmax   = u_zmax;
subgrd1.u_dhdz   = u_dhdz;
subgrd1.u_hrep   = u_hrep;
subgrd1.u_navg   = u_navg;
subgrd1.v_zmin   = v_zmin;
subgrd1.v_zmax   = v_zmax;
subgrd1.v_dhdz   = v_dhdz;
subgrd1.v_hrep   = v_hrep;
subgrd1.v_navg   = v_navg;


sfincs_write_binary_subgrid_tables_v7(subgrd1,msk,nbin,subgridfile,uopt);

%%
function [dmin,dmax,volmax,ddd]=sfincs_subgrid_volumes_ddd(d,nbin,dx,dy)

nmax=size(d,1);
mmax=size(d,2);
nrd=size(d,3);

d=sort(d,3);

dmin=min(d,[],3);
dmax=max(d,[],3);
a=dx*dy/nrd; % pixel area

vol=zeros(nmax,mmax,nrd);

% Loop through depths
for j=2:nrd
    lev=squeeze(d(:,:,j));
    lev=repmat(lev,[1 1 nrd]);
    vvv=sum(max(lev-d,0)*a,3);
    vvv=max(vvv,squeeze(vol(:,:,j-1))+1e-9);
    vol(:,:,j)=vvv;
end
ddd=zeros(nmax,mmax,nbin);

volmax=squeeze(vol(:,:,end));
volbin=volmax/nbin;

for ibin=1:nbin-1
    vvv=ibin*volbin;
    for n=1:nmax
        for m=1:mmax
            ddd(n,m,ibin)=interp1(squeeze(vol(n,m,:)),squeeze(d(n,m,:)),vvv(n,m));
        end
    end
end
ddd(:,:,nbin)=dmax;

%%
function [dmin,dmax,ddd]=sfincs_subgrid_area_and_depth_v5(d,nbin,dx)

nmax=size(d,1);
mmax=size(d,2);
nrd=size(d,3);

dmin=min(d,[],3);
dmax=max(d,[],3);

dmax(dmax<dmin+0.01)=dmax(dmax<dmin+0.01)+0.01;
% if dmax<dmin+0.01
%     dmax=dmax+0.01;
% end

dbin=(dmax-dmin)/nbin;
dbin=max(dbin,1e-9);

ddd=zeros(nmax,mmax,nbin);

dw=dx/nrd;

% Next bins
for ibin=1:nbin    
    zb=dmin+ibin*dbin;
    zb=repmat(zb,[1 1 nrd]);
    h=zb-d;
    h=max(h,0);
    q=h.^(5/3)*dw;
    qtot=sum(q,3);
    hrep=(qtot./dx).^(3/5);
    ddd(:,:,ibin)=hrep;    
end

%%
function [volmax,dep,iok]=adjust_zvol_slope(zmin,volmax,dep,dx,mxsteep)

iok=1;

nbin=length(dep);
volmax=volmax/dx^2;

dep=[zmin;dep];
dz=[dep(2:end)-dep(1:end-1)];
dv=volmax/nbin;
dzdv=dz./dv;
vvr=0:dv:volmax;

if max(dzdv)>mxsteep
    
    iok=0;
    
    % need to adjust
    for ibin=1:nbin
        % Set vvru in this bin to be higher than in bin below
        vvru=max(vvr(ibin+1),vvr(ibin)+1e-9);
        dzdv1=dz(ibin)/(vvru - vvr(ibin)); % slope
        if dzdv1>mxsteep
            vvr(ibin+1)=vvr(ibin)+dz(ibin)/mxsteep;
        end
    end
    
    % Now re-interpolate
    vvr=vvr*dx^2;
    volmax=vvr(end);
    dv=volmax/nbin;
    vv=dv:dv:volmax;
    dep=interp1(vvr,dep,vv);
    
end
