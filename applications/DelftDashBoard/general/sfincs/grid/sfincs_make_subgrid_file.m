function sfincs_make_subgrid_file(dr,subgridfile,bathy,cs,nbin,refi,refj)
% Makes SFINCS subgrid file
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

global bathymetry
% Initialize bathymetry datasets (must run oetsettings for this to work, and also have delftdashboard directory)
if isempty(bathymetry)
    bathymetry.dir='d:\delftdashboard\data\bathymetry\';
    bathymetry=ddb_findBathymetryDatabases(bathymetry);
end

subgridfile=[dr filesep subgridfile];

for ib=1:length(bathy)
    model.bathymetry(ib).name=bathy(ib).name;
end

model.cs.name=cs.name;
model.cs.type=cs.type;

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
imax=nmax;
jmax=mmax;

cosrot=cos(rotation*pi/180);
sinrot=sin(rotation*pi/180);

% 
% % Fine grid
% sout.zgf=zeros(nmax*refi,mmax*refj);
% sout.zgf(sout.zgf==0)=NaN;

nrmax=min(round(2000*dif/di),round(2000*djf/dj)); % maximum number of cells in a block (limit size of subgrid block to 2000x2000)

nib=floor(nrmax/(di/dif)); % nr of cells in a block
njb=floor(nrmax/(dj/djf)); % nr of cells in a block

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


% % Polygons
% flist=dir('*.pli');
% npol=length(flist);
% for ii=1:npol
%     fname=flist(ii).name;
%     [x,y]=landboundary('read',fname);
%     [x,y]=convertCoordinates(x,y,'persistent','CS1.name',model.cs.name,'CS1.type',model.cs.type,'CS2.name','WGS 84','CS2.type','geographic');
%     pol(ii).x=x;
%     pol(ii).y=y;
%     pol(ii).zmin=-4;
% end

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
        yy=yy0:djf:yy1;
        xx=xx+0.5*djf;
        yy=yy+0.5*dif;
        [xx,yy]=meshgrid(xx,yy);
        xg = x0 + cosrot*xx + sinrot*yy;
        yg = y0 - sinrot*xx + cosrot*yy;
        clear xx yy
        
        % Convert subgrid to WGS 84 (should it not be converted to the coordinate system of the bathymetry dataset? Yes, but let's assume for now that the data are in WGS 84!)
        [xg,yg]=convertCoordinates(xg,yg,'persistent','CS1.name',model.cs.name,'CS1.type',model.cs.type,'CS2.name','WGS 84','CS2.type','geographic');
        
        % Now get the bathy data for this block
        
        % Determine bounding box
        xmin=min(min(xg));
        xmax=max(max(xg));
        ymin=min(min(yg));
        ymax=max(max(yg));
        
        % Initialize depth of subgrid at NaN
        zg=zeros(size(xg));
        zg(zg==0)=NaN;
        
        % Loop through bathymetry datasets        
        for ibat=1:length(model.bathymetry)
            
            %         ibathy=strmatch(model.bathymetry(ibat).name,bathymetry.datasets,'exact');
            if ~isempty(find(isnan(zg)))
                
                [xx,yy,zz,ok]=ddb_getBathymetry(bathymetry,[xmin xmax],[ymin ymax],'bathymetry',model.bathymetry(ibat).name,'maxcellsize',min(dif,djf));
                
                if ~isempty(find(~isnan(zz)))
                    zg1=interp2(xx,yy,zz,xg,yg);
                    zg(isnan(zg))=zg1(isnan(zg));
                end
            end
            
        end
        
%         % Adjust the bathymetries in polygons (commented out for now)
%         for ipol=1:npol
%             xminp=min(pol(ipol).x);
%             xmaxp=max(pol(ipol).x);
%             yminp=min(pol(ipol).y);
%             ymaxp=max(pol(ipol).y);
%             if (xminp<xmin && xmaxp<xmin) || (xminp>xmax && xmaxp>xmax) || (yminp<ymin && ymaxp<ymin) || (yminp>ymax && ymaxp>ymax)
%                 break
%             end
%             inpol=inpolygon(xg,yg,pol(ipol).x,pol(ipol).y);
%             zg(inpol)=min(zg(inpol),pol(ipol).zmin);                
%         end
        
%         % Fill the fine grid ()
%         if1=(ic1-1)*refi+1;
%         if2=(ic2  )*refi  ;
%         jf1=(jc1-1)*refj+1;
%         jf2=(jc2  )*refj  ;
%         sout.zgf(if1:if2,jf1:jf2)=zg(1:end-refi,1:end-refj); % Don't need the row for velocity points here
        
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

% sout.zgf=sout.zgf(1:nmax*refi,1:mmax*refj);
% save('finegrid.mat','-struct','sout');

%%
function [dmin,dmax,vvv]=sfincs_subgrid_volumes(d,nbin,dx,dy)

nmax=size(d,1);
mmax=size(d,2);
nrd=size(d,3);

dmin=min(d,[],3);
dmax=max(d,[],3);
a=dx*dy/nrd; % pixel area

dbin=(dmax-dmin)/nbin;

vvv=zeros(nmax,mmax,nbin);

for ibin=1:nbin
    zb=dmin+ibin*dbin;
    zb=repmat(zb,[1 1 nrd]);
    vvv(:,:,ibin)=sum(a*max(zb-d,0),3);
end

%%
function [dmin,dmax,aaa,www]=sfincs_subgrid_area_and_depth(d,nbin,dx)

nmax=size(d,1);
mmax=size(d,2);
nrd=size(d,3);

dmin=min(d,[],3);
dmax=max(d,[],3);

dbin=(dmax-dmin)/nbin;

aaa=zeros(nmax,mmax,nbin);
www=aaa;

% First bin
zb=dmin+dbin;
zb=repmat(zb,[1 1 nrd]);
ibelow=d<=zb;
nbelow=sum(ibelow,3);
www(:,:,1)=dx*nbelow/nrd;
aaa(:,:,1)=0.5*www(:,:,1).*dbin;

% Next bins
for ibin=2:nbin
    zb=dmin+ibin*dbin;
    zb=repmat(zb,[1 1 nrd]);
    ibelow=d<=zb;
    nbelow=sum(ibelow,3);
    www(:,:,ibin)=dx*nbelow/nrd;
    aaa(:,:,ibin)=aaa(:,:,ibin-1)+0.5*(www(:,:,ibin)+www(:,:,ibin-1)).*dbin;
end

