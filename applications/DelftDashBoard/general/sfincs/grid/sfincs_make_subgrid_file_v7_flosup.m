function sfincs_make_subgrid_file_v7_flosup(dr,subgridfile,bathy,cs,nbin,refi,refj,uopt,maxdzdv,usemex,manning)
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


if ~isempty(cs)
    
    global bathymetry

    if isempty(bathymetry)
        error('Bathymetry database has not yet been initialized! Please run initialize_bathymetry_database first.m first.')
    end
    
    subgridfile=[dr filesep subgridfile];
    
    % names of topobathy files    
    for ib=1:length(bathy)
        model.bathymetry(ib).name=bathy(ib).name;
        ii=strmatch(lower(bathy(ib).name),lower(bathymetry.datasets),'exact');
        model.bathymetry(ib).csname=bathymetry.dataset(ii).horizontalCoordinateSystem.name;
        model.bathymetry(ib).cstype=bathymetry.dataset(ii).horizontalCoordinateSystem.type;
    end
    
    model.cs.name=cs.name;
    model.cs.type=cs.type;
    
    % names of manning files
    for ib=1:length(manning)
        model_manning.bathymetry(ib).name=manning(ib).name;
        ii=strmatch(lower(bathy(ib).name),lower(bathymetry.datasets),'exact');
        model_manning.bathymetry(ib).csname=bathymetry.dataset(ii).horizontalCoordinateSystem.name;
        model_manning.bathymetry(ib).cstype=bathymetry.dataset(ii).horizontalCoordinateSystem.type;
    end
    
    model_manning.cs.name=cs.name;
    model_manning.cs.type=cs.type;    

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

%
% % Fine grid
% sout.zgf=zeros(nmax*refi,mmax*refj);
% sout.zgf(sout.zgf==0)=NaN;

% nrmax=min(round(2000*dif/di),round(2000*djf/dj)); % maximum number of subgrid cells in a block (limit size of subgrid block to 2000x2000)
nrmax=2000;

nib=floor(nrmax/(di/dif)); % nr of regular cells in a block
njb=floor(nrmax/(dj/djf)); % nr of regular cells in a block

ni=ceil(imax/nib); % nr of blocks
nj=ceil(jmax/njb); % nr of blocks


% % Initialize arrays

% Initialize temporary arrays
subgrd.z_zmin=zeros(imax,jmax);
subgrd.z_zmax=zeros(imax,jmax);
subgrd.z_volmax=zeros(imax,jmax);
subgrd.z_depth=zeros(imax,jmax,nbin);
subgrd.z_hrep=zeros(imax,jmax,nbin);
subgrd.z_dhdz=zeros(imax,jmax);

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
        
        ic2=min(ic2,imax);
        jc2=min(jc2,jmax);
        
        % Actual number of grid cells in this block (after cutting off irrelevant edges)
        nib1=ic2-ic1+1;
        njb1=jc2-jc1+1;
        
        % Make subgrid
        xx0=(jj-1)*njb*dj;
        yy0=(ii-1)*nib*di;
%        xx1=jj*njb*dj-djf;
%        yy1=ii*nib*di-dif;
        xx1=xx0 + njb1*dj - djf;
        yy1=yy0 + nib1*di - dif;
%         xx1=xx1+dj; % add extra row cuz we need data in u points
%         yy1=yy1+di; % add extra row cuz we need data in v points
        xx=xx0:djf:xx1;
        yy=yy0:djf:yy1;
        xx=xx+0.5*djf;
        yy=yy+0.5*dif;
        [xx,yy]=meshgrid(xx,yy);
        xg0 = x0 + cosrot*xx - sinrot*yy;
        yg0 = y0 + sinrot*xx + cosrot*yy;
        clear xx yy
        
        % x=inp.x0+cos(rot)*xg-sin(rot)*yg;
        % y=inp.y0+sin(rot)*xg+cos(rot)*yg;
        
        % Initialize depth of subgrid at NaN
        zg=zeros(size(xg0));
        zg(zg==0)=NaN;

        manning=zeros(size(xg0));
        manning(manning==0)=NaN;
        
        if ~isempty(cs)
            % Loop through bathymetry datasets
            for ibat=1:length(model.bathymetry)
                
                [xg,yg]=convertCoordinates(xg0,yg0,'persistent','CS1.name',model.cs.name,'CS1.type',model.cs.type,'CS2.name',model.bathymetry(ibat).csname,'CS2.type',model.bathymetry(ibat).cstype);
                
                % Determine bounding box                
%                 bboxx=[nanmin(nanmin(xg)) nanmax(nanmax(xg))];
%                 bboxy=[nanmin(nanmin(yg)) nanmax(nanmax(yg))];
                bboxx=[nanmin(nanmin(xg0))-dx nanmax(nanmax(xg0))+dx];
                bboxy=[nanmin(nanmin(yg0))-dy nanmax(nanmax(yg0))+dy];
                
                % Now get the bathy data for this block
                if ~isempty(find(isnan(zg)))
                    
                    %                [xx,yy,zz,ok]=ddb_getBathymetry(bathymetry,[xmin xmax],[ymin ymax],'bathymetry',model.bathymetry(ibat).name,'maxcellsize',min(dif,djf),'quiet');
                    [xx,yy,zz,ok]=ddb_getBathymetry(bathymetry,bboxx,bboxy,'bathymetry',model.bathymetry(ibat).name,'maxcellsize',min(dif,djf),'quiet');
                    
                    if ~isempty(find(~isnan(zz)))
                        zg1=interp2(xx,yy,zz,xg,yg);
                        zg(isnan(zg))=zg1(isnan(zg));
                    end
                end                
            end
            
            % same for manning
            for ibat=1:length(model_manning.bathymetry)
                
                [xg,yg]=convertCoordinates(xg0,yg0,'persistent','CS1.name',model_manning.cs.name,'CS1.type',model_manning.cs.type,'CS2.name',model_manning.bathymetry(ibat).csname,'CS2.type',model_manning.bathymetry(ibat).cstype);
                
                % Determine bounding box                
                bboxx=[nanmin(nanmin(xg0))-dx nanmax(nanmax(xg0))+dx];
                bboxy=[nanmin(nanmin(yg0))-dy nanmax(nanmax(yg0))+dy];
                
                % Now get the bathy data for this block
                if ~isempty(find(isnan(manning)))
                    
                    [xx,yy,manning1,ok]=ddb_getBathymetry(bathymetry,bboxx,bboxy,'bathymetry',model_manning.bathymetry(ibat).name,'maxcellsize',min(dif,djf),'quiet');
                    
                    if ~isempty(find(~isnan(manning1)))
                        manning2=interp2(xx,yy,manning1,xg,yg);
                        manning(isnan(manning))=manning2(isnan(manning));
                    end
                end                
            end
            
        else
            
            xx=bathy.x;
            yy=bathy.y;
            zz=bathy.z;
            manning1 = bathy.manning;
            
            zg=interp2(xx,yy,zz,xg0,yg0);
            zg(isnan(zg))=0;

            manning=interp2(xx,yy,manning1,xg0,yg0);
            manning(isnan(manning))=0.02;  %if NaN then give 0.02 of open water          
        end
        
        
        if ~isempty(find(isnan(zg)))
            close all
            A4fig; pcolor(xg,yg,zg); shading flat; 
            plot(xg(1,:),yg(1,:),'r','linewidth',0.5); plot(xg(end,:),yg(end,:),'r','linewidth',0.5);
            plot(xg(:,1),yg(:,1),'r','linewidth',0.5); plot(xg(:,end),yg(:,end),'r','linewidth',0.5);
            
            printpng(['bathy_tmp_',num2str(ib, '%03d')])
            disp(['NaNs found in bathymetry!!! Block ii = ' num2str(ii) ', jj = ' num2str(jj)]);
            zg(isnan(zg)) = 0;
        end
                
        clear xg yg zg1 xx yy zz
        
        %% Now compute subgrid properties
        
        % Volumes
        np=0;
        d=zeros(nib1,njb1,refi*refj); % First create 3D matrix (nmax,mmax,refi*refj)
        d(d==0)=NaN;
        dmanning=zeros(nib1,njb1,refi*refj); % First create 3D matrix (nmax,mmax,refi*refj)
        dmanning(dmanning==0)=NaN;
        for iref=1:refi
            for jref=1:refj
                np=np+1;
                i1=iref;
                i2=i1+(nib1-1)*refi;
                j1=jref;
                j2=j1+(njb1-1)*refj;
                zg1=zg(i1:refi:i2,j1:refj:j2);
                d(:,:,np)=zg1;
                manning3=manning(i1:refi:i2,j1:refj:j2);
                dmanning(:,:,np)=manning3;                
            end
        end
        
        if usemex
            [zmin,zmax,volmax,ddd]=mx_subgrid_volumes(d,nbin,dx,dy,maxdzdv);
        else
            % Should get rid of this option
            [zmin,zmax,volmax,ddd]=sfincs_subgrid_volumes_ddd(d,nbin,dx,dy);
        end
        subgrd.z_zmin(ic1:ic2,jc1:jc2)=zmin;
        subgrd.z_zmax(ic1:ic2,jc1:jc2)=zmax;
        subgrd.z_volmax(ic1:ic2,jc1:jc2)=volmax;
        subgrd.z_depth(ic1:ic2,jc1:jc2,:)=ddd;
         

        if usemex
%             manning=zeros(size(d));
%             manning(d<manning_level)=manning_deep;
%             manning(d>=manning_level)=manning_shallow;
            [zmin,zmax,ddd,dhdz]=mx_subgrid_depth(d,dmanning,nbin,dx);
        else
            % Should get rid of this option
            [zmin,zmax,ddd]=sfincs_subgrid_area_and_depth_v5(d,nbin,dy);
            dhdz=zeros(size(ddd))+1;
        end

        subgrd.z_hrep(ic1:ic2,jc1:jc2,:)=ddd;
        subgrd.z_dhdz(ic1:ic2,jc1:jc2,:)=dhdz;
                
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

% if ~usemex
%     % Should get rid of this option
%     % Smooth very steep slopes
%     for n=1:nmax
%         for m=1:mmax
%             [volmax,dep,iok]=adjust_zvol_slope(subgrd.z_zmin(n,m),subgrd.z_volmax(n,m),squeeze(subgrd.z_depth(n,m,:)),dx,maxdzdv);
%             if ~iok
%                 subgrd1.z_volmax(n,m)=volmax;
%                 subgrd1.z_depth(n,m,:)=dep;
%             end
%         end
%     end
% end

% switch uopt
%     
%     case{'mean'}
%         
%         subgrd1.u_zmin=0.5*(subgrd.z_zmin(1:nmax,1:mmax)+subgrd.z_zmin(1:nmax,2:mmax+1));
%         subgrd1.u_zmax=0.5*(subgrd.z_zmax(1:nmax,1:mmax)+subgrd.z_zmax(1:nmax,2:mmax+1));
%         subgrd1.u_dhdz=0.5*(subgrd.z_dhdz(1:nmax,1:mmax)+subgrd.z_dhdz(1:nmax,2:mmax+1));
%         
%         for ibin=1:nbin
%             subgrd1.u_hrep(1:nmax,1:mmax,ibin)=0.5*(subgrd.z_hrep(1:nmax,1:mmax,ibin)+subgrd.z_hrep(1:nmax,2:mmax+1,ibin));
%         end
%         
%         subgrd1.v_zmin=0.5*(subgrd.z_zmin(1:nmax,1:mmax)+subgrd.z_zmin(2:nmax+1,1:mmax));
%         subgrd1.v_zmax=0.5*(subgrd.z_zmax(1:nmax,1:mmax)+subgrd.z_zmax(2:nmax+1,1:mmax));
%         subgrd1.v_dhdz=0.5*(subgrd.z_dhdz(1:nmax,1:mmax)+subgrd.z_dhdz(2:nmax+1,1:mmax));
%         for ibin=1:nbin
%             subgrd1.v_hrep(1:nmax,1:mmax,ibin)=0.5*(subgrd.z_hrep(1:nmax,1:mmax,ibin)+subgrd.z_hrep(2:nmax+1,1:mmax,ibin));
%         end
%         
%     case{'min'}
% 
%         % Should get rid of this option ???
%         
%         hh=max(max(subgrd.z_zmax))+1; % Maximum elevation in the model
%         
%         % U points
%         
%         subgrd1.u_zmin=max(subgrd.z_zmin(1:nmax,1:mmax),subgrd.z_zmin(1:nmax,2:mmax+1));
%         subgrd1.u_zmax=max(subgrd.z_zmax(1:nmax,1:mmax),subgrd.z_zmax(1:nmax,2:mmax+1));
%         
%         zu=zeros(nmax,mmax,nbin);
%         for ibin=1:nbin
%             zu(:,:,ibin)=subgrd1.u_zmin+ibin*(subgrd1.u_zmax-subgrd1.u_zmin)/nbin;
%         end
%         
%         % Left
%         z_zmin=subgrd.z_zmin(1:nmax,1:mmax);
%         z_zmax=subgrd.z_zmax(1:nmax,1:mmax);
%         zmaxmin=z_zmax-z_zmin;
%         zmaxmin=max(zmaxmin,1e-4);
%         z_left=zeros(nmax,mmax,nbin+1);
%         for ibin=1:nbin+1
%             z_left(:,:,ibin)=z_zmin+(ibin-1)*zmaxmin/nbin;
%         end
%         h_left=zeros(nmax,mmax,nbin+1);
%         h_left(:,:,2:nbin+1)=subgrd.z_hrep(1:nmax,1:mmax,:);
%         % Add extra point
%         z_left(:,:,nbin+2)=zeros(nmax,mmax) + hh;
%         h_left(:,:,nbin+2)=h_left(:,:,nbin+1) + hh - z_zmax;
%         
%         % Right
%         z_zmin=subgrd.z_zmin(1:nmax,2:mmax+1);
%         z_zmax=subgrd.z_zmax(1:nmax,2:mmax+1);
%         zmaxmin=z_zmax-z_zmin;
%         zmaxmin=max(zmaxmin,1e-4);
%         z_right=zeros(nmax,mmax,nbin+1);
%         for ibin=1:nbin+1
%             z_right(:,:,ibin)=z_zmin+(ibin-1)*zmaxmin/nbin;
%         end
%         h_right=zeros(nmax,mmax,nbin+1);
%         h_right(:,:,2:nbin+1)=subgrd.z_hrep(1:nmax,2:mmax+1,:);        
%         % Add extra point
%         z_right(:,:,nbin+2)=zeros(nmax,mmax) + hh;
%         h_right(:,:,nbin+2)=h_right(:,:,nbin+1) + hh - z_zmax;
%         
%         for n=1:nmax
%             for m=1:mmax
%                 
%                 % Pick smallest width
%                 
%                 h1=interp1(squeeze(z_left(n,m,:)),squeeze(h_left(n,m,:)),squeeze(zu(n,m,:)));
%                 h2=interp1(squeeze(z_right(n,m,:)),squeeze(h_right(n,m,:)),squeeze(zu(n,m,:)));
%                 i1=find(h1<h2);
%                 i2=find(h1>=h2);
%                 subgrd1.u_hrep(n,m,i1)=h1(i1);
%                 subgrd1.u_hrep(n,m,i2)=h2(i2);
%             end
%         end
%         
%         
%         % V points
%         
%         subgrd1.v_zmin=max(subgrd.z_zmin(1:nmax,1:mmax),subgrd.z_zmin(2:nmax+1,1:mmax));
%         subgrd1.v_zmax=max(subgrd.z_zmax(1:nmax,1:mmax),subgrd.z_zmax(2:nmax+1,1:mmax));
%         
%         zu=zeros(nmax,mmax,nbin);
%         for ibin=1:nbin
%             zu(:,:,ibin)=subgrd1.v_zmin+ibin*(subgrd1.v_zmax-subgrd1.v_zmin)/nbin;
%         end
%         
%         % Left
%         z_zmin=subgrd.z_zmin(1:nmax,1:mmax);
%         z_zmax=subgrd.z_zmax(1:nmax,1:mmax);
%         zmaxmin=z_zmax-z_zmin;
%         zmaxmin=max(zmaxmin,1e-4);
%         z_left=zeros(nmax,mmax,nbin+1);
%         for ibin=1:nbin+1
%             z_left(:,:,ibin)=z_zmin+(ibin-1)*zmaxmin/nbin;
%         end
%         h_left=zeros(nmax,mmax,nbin+1);
%         h_left(:,:,2:nbin+1)=subgrd.z_hrep(1:nmax,1:mmax,:);
%         % Add extra point
%         z_left(:,:,nbin+2)=zeros(nmax,mmax) + hh;
%         h_left(:,:,nbin+2)=h_left(:,:,nbin+1) + hh - z_zmax;
%         
%         % Right
%         z_zmin=subgrd.z_zmin(2:nmax+1,1:mmax);
%         z_zmax=subgrd.z_zmax(2:nmax+1,1:mmax);
%         zmaxmin=z_zmax-z_zmin;
%         zmaxmin=max(zmaxmin,1e-4);
%         z_right=zeros(nmax,mmax,nbin+1);
%         for ibin=1:nbin+1
%             z_right(:,:,ibin)=z_zmin+(ibin-1)*zmaxmin/nbin;
%         end
%         h_right=zeros(nmax,mmax,nbin+1);
%         h_right(:,:,2:nbin+1)=subgrd.z_hrep(2:nmax+1,1:mmax,:);        
%         % Add extra point
%         z_right(:,:,nbin+2)=zeros(nmax,mmax) + hh;
%         h_right(:,:,nbin+2)=h_right(:,:,nbin+1) + hh - z_zmax;
%         
%         for n=1:nmax
%             for m=1:mmax
%                 
%                 % Pick smallest width
%                 
%                 h1=interp1(squeeze(z_left(n,m,:)),squeeze(h_left(n,m,:)),squeeze(zu(n,m,:)));
%                 h2=interp1(squeeze(z_right(n,m,:)),squeeze(h_right(n,m,:)),squeeze(zu(n,m,:)));
%                 i1=find(h1<h2);
%                 i2=find(h1>=h2);
%                 subgrd1.v_hrep(n,m,i1)=h1(i1);
%                 subgrd1.v_hrep(n,m,i2)=h2(i2);
% 
%             end
%         end
%         
%     case{'minmean'}
% 
% %        hh=max(max(subgrd.z_zmax))+1; % Maximum elevation in the model
%         zadd=max(max(subgrd.z_zmax)) + 1; % Elevation added to each point for extrapolation
%         hadd=zadd - subgrd.z_zmax; % Elevation added to each point for extrapolation
%         
%         % U points
%         
%         subgrd1.u_zmin=max(subgrd.z_zmin(1:nmax,1:mmax),subgrd.z_zmin(1:nmax,2:mmax+1));
%         subgrd1.u_zmax=max(subgrd.z_zmax(1:nmax,1:mmax),subgrd.z_zmax(1:nmax,2:mmax+1));
%         
%         zu=zeros(nmax,mmax,nbin);
%         for ibin=1:nbin
%             zu(:,:,ibin)=subgrd1.u_zmin+ibin*(subgrd1.u_zmax-subgrd1.u_zmin)/nbin;
%         end
%         
%         % Left
%         z_zmin=subgrd.z_zmin(1:nmax,1:mmax);
%         z_zmax=subgrd.z_zmax(1:nmax,1:mmax);
%         zmaxmin=z_zmax-z_zmin;
%         zmaxmin=max(zmaxmin,1e-4);
%         z_left=zeros(nmax,mmax,nbin+1);
%         for ibin=1:nbin+1
%             z_left(:,:,ibin)=z_zmin+(ibin-1)*zmaxmin/nbin;
%         end
%         h_left=zeros(nmax,mmax,nbin+1);
%         h_left(:,:,2:nbin+1)=subgrd.z_hrep(1:nmax,1:mmax,:);
%         % Add extra point
%         dhdz_left=subgrd.z_dhdz(1:nmax,1:mmax);
%         z_left(:,:,nbin+2)=zeros(nmax,mmax) + zadd;
%         h_left(:,:,nbin+2)=h_left(:,:,nbin+1) + hadd(1:nmax,1:mmax).*dhdz_left;
%         
%         % Right
%         z_zmin=subgrd.z_zmin(1:nmax,2:mmax+1);
%         z_zmax=subgrd.z_zmax(1:nmax,2:mmax+1);
%         zmaxmin=z_zmax-z_zmin;
%         zmaxmin=max(zmaxmin,1e-4);
%         z_right=zeros(nmax,mmax,nbin+1);
%         for ibin=1:nbin+1
%             z_right(:,:,ibin)=z_zmin+(ibin-1)*zmaxmin/nbin;
%         end
%         h_right=zeros(nmax,mmax,nbin+1);
%         h_right(:,:,2:nbin+1)=subgrd.z_hrep(1:nmax,2:mmax+1,:);        
%         % Add extra point
% %        z_right(:,:,nbin+2)=zeros(nmax,mmax) + hh;
% %        h_right(:,:,nbin+2)=h_right(:,:,nbin+1) + hh - z_zmax;
%         dhdz_right=subgrd.z_dhdz(1:nmax,2:mmax+1);
%         z_right(:,:,nbin+2)=zeros(nmax,mmax) + zadd;
%         h_right(:,:,nbin+2)=h_right(:,:,nbin+1) + hadd(1:nmax,2:mmax+1).*dhdz_right;
%         
%         for n=1:nmax
%             for m=1:mmax                
%                 
%                 try
%                 h1=interp1(squeeze(z_left(n,m,:)),squeeze(h_left(n,m,:)),squeeze(zu(n,m,:)));
%                 catch
%                     shiet=1
%                 end
%                 h2=interp1(squeeze(z_right(n,m,:)),squeeze(h_right(n,m,:)),squeeze(zu(n,m,:)));
% 
%                 f=1/nbin:1/nbin:1;                
%                 f=f*0.5;
%                 f=f';
%                 if z_left(n,m,1)>z_right(n,m,1)
%                     % left shallower than right
%                     f=1-f;
%                 else
%                     % right shallower than left
%                 end
%                 h=f.*h1 + (1-f).*h2;
% 
%                 subgrd1.u_hrep(n,m,:)=h;
%                 subgrd1.u_dhdz(n,m)  = 0.5*(dhdz_left(n,m) + dhdz_right(n,m));                
% 
%             end
%         end
%         
%         
%         % V points
%         
%         subgrd1.v_zmin=max(subgrd.z_zmin(1:nmax,1:mmax),subgrd.z_zmin(2:nmax+1,1:mmax));
%         subgrd1.v_zmax=max(subgrd.z_zmax(1:nmax,1:mmax),subgrd.z_zmax(2:nmax+1,1:mmax));
%         
%         zu=zeros(nmax,mmax,nbin);
%         for ibin=1:nbin
%             zu(:,:,ibin)=subgrd1.v_zmin+ibin*(subgrd1.v_zmax-subgrd1.v_zmin)/nbin;
%         end
%         
%         % Left
%         z_zmin=subgrd.z_zmin(1:nmax,1:mmax);
%         z_zmax=subgrd.z_zmax(1:nmax,1:mmax);
%         zmaxmin=z_zmax-z_zmin;
%         zmaxmin=max(zmaxmin,1e-4);
%         z_left=zeros(nmax,mmax,nbin+1);
%         for ibin=1:nbin+1
%             z_left(:,:,ibin)=z_zmin+(ibin-1)*zmaxmin/nbin;
%         end
%         h_left=zeros(nmax,mmax,nbin+1);
%         h_left(:,:,2:nbin+1)=subgrd.z_hrep(1:nmax,1:mmax,:);
%         % Add extra point
%         dhdz_left=subgrd.z_dhdz(1:nmax,1:mmax);
%         z_left(:,:,nbin+2)=zeros(nmax,mmax) + zadd;
%         h_left(:,:,nbin+2)=h_left(:,:,nbin+1) + hadd(1:nmax,1:mmax).*dhdz_left;
%         
%         % Right
%         z_zmin=subgrd.z_zmin(2:nmax+1,1:mmax);
%         z_zmax=subgrd.z_zmax(2:nmax+1,1:mmax);
%         zmaxmin=z_zmax-z_zmin;
%         zmaxmin=max(zmaxmin,1e-4);
%         z_right=zeros(nmax,mmax,nbin+1);
%         for ibin=1:nbin+1
%             z_right(:,:,ibin)=z_zmin+(ibin-1)*zmaxmin/nbin;
%         end
%         h_right=zeros(nmax,mmax,nbin+1);
%         h_right(:,:,2:nbin+1)=subgrd.z_hrep(2:nmax+1,1:mmax,:);        
%         % Add extra point
%         dhdz_right=subgrd.z_dhdz(2:nmax+1,1:mmax);
%         z_right(:,:,nbin+2)=zeros(nmax,mmax) + zadd;
%         h_right(:,:,nbin+2)=h_right(:,:,nbin+1) + hadd(2:nmax+1,1:mmax).*dhdz_right;
%         
%         for n=1:nmax
%             for m=1:mmax
%                 
%                 if n==24 && m==2
%                     shite=1';
%                 end
%                 h1=interp1(squeeze(z_left(n,m,:)),squeeze(h_left(n,m,:)),squeeze(zu(n,m,:)));
%                 h2=interp1(squeeze(z_right(n,m,:)),squeeze(h_right(n,m,:)),squeeze(zu(n,m,:)));
% 
% %                f=0:(1/(nbin-1)):1;                
%                 f=1/nbin:1/nbin:1;                
%                 f=f*0.5;
%                 f=f';
%                 if z_left(n,m,1)>z_right(n,m,1)
%                     % left shallower than right
%                     f=1-f;
%                 else
%                     % right shallower than left
%                 end
%                 h=f.*h1 + (1-f).*h2;
% 
%                 subgrd1.v_hrep(n,m,:)=h;
%                 subgrd1.v_dhdz(n,m)  = 0.5*(dhdz_left(n,m) + dhdz_right(n,m));                
%                                 
%             end
%         end
%         
% end

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
