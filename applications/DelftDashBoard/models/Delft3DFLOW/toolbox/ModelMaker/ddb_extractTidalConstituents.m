function [ampu,phaseu,depth,conList]=ddb_extractTidalConstituents(fname,xx,yy,opt1,varargin)

if ~isempty(varargin)
    comp=varargin{1};
else
    comp=[];
end

ampu=[];
phaseu=[];
depth=[];

x=nc_varget(fname,'lon');
y=nc_varget(fname,'lat');
cl=nc_varget(fname,'tidal_constituents');

nrcons=size(cl,1);

for k=1:nrcons
    conList{k}=squeeze(upper(cl(k,:)));
end

if ~isempty(comp)
    icomp=strmatch(comp,conList,'exact');
end

xmin=min(min(xx));
ymin=min(min(yy));
xmax=max(max(xx));
ymax=max(max(yy));

ix1=find(x<=xmin,1,'last')-1;
if isempty(ix1)
    ix1=1;
end
ix1=max(ix1,1);

ix2=find(x>=xmax,1)+1;
if isempty(ix2)
    ix2=length(x);
end
ix2=min(ix2,length(x));

iy1=find(y<=ymin,1,'last')-1;
if isempty(iy1)
    iy1=1;
end
iy1=max(iy1,1);

iy2=find(y>=ymax,1)+1;
if isempty(iy2)
    iy2=length(y);
end
iy2=min(iy2,length(y));

%for k=1:nrcons
switch lower(opt1)
    case{'h','z'}
        ampstr='tidal_amplitude_h';
        phistr='tidal_phase_h';
    case{'u'}
        ampstr='tidal_amplitude_u';
        phistr='tidal_phase_u';
    case{'v'}
        ampstr='tidal_amplitude_v';
        phistr='tidal_phase_v';
end
    
xv=x(ix1:ix2);
yv=y(iy1:iy2);
[xg,yg]=meshgrid(xv,yv);

xx(isnan(xx))=1e9;
yy(isnan(yy))=1e9;

%fname='F:\DelftDashBoardRawData\tidemodels\scripts\Med\med.nc';
nc_dump(fname);

dpt=nc_varget(fname,'depth',[ix1-1 iy1-1],[ix2-ix1+1 iy2-iy1+1]);
dpt=dpt';
% figure(999);
% pcolor(xg,yg,double(dpt));colorbar;
depth=interp2(xg,yg,dpt,xx,yy);

if isempty(comp)

    % Get all constituents
    amp=nc_varget(fname,ampstr,[ix1-1 iy1-1 0],[ix2-ix1+1 iy2-iy1+1 nrcons]);
    phi=nc_varget(fname,phistr,[ix1-1 iy1-1 0],[ix2-ix1+1 iy2-iy1+1 nrcons]);
    amp=double(amp);
    phi=double(phi);
    amp=permute(amp,[2 1 3]);
    phi=permute(phi,[2 1 3]);

%     figure(800);
%     pcolor(amp(:,:,1));colorbar;
%     figure(900);
%     pcolor(phi(:,:,1));colorbar;
    
    for k=1:nrcons
        
        a=squeeze(amp(:,:,k));
        p=squeeze(phi(:,:,k));
        p(a==0)=NaN;
        a(a==0)=NaN;
        a=ddb_internaldiffusion(a);
        p=ddb_internaldiffusion(p);
        
        ampu(k,:,:)=interp2(xg,yg,a,xx,yy);
        phaseu(k,:,:)=interp2(xg,yg,p,xx,yy);
    end


else
    
    % Get one constituents
    amp=nc_varget(fname,ampstr,[ix1-1 iy1-1 icomp-1],[ix2-ix1+1 iy2-iy1+1 1]);
    phi=nc_varget(fname,phistr,[ix1-1 iy1-1 icomp-1],[ix2-ix1+1 iy2-iy1+1 1]);
    amp=double(amp);
    phi=double(phi);
    amp=permute(amp,[2 1 3]);
    phi=permute(phi,[2 1 3]);
    
    a=squeeze(amp(:,:,1));
    p=squeeze(phi(:,:,1));
    p(a==0)=NaN;
    a(a==0)=NaN;
    a=ddb_internaldiffusion(a);
    p=ddb_internaldiffusion(p);
    
    ampu(:,:)=interp2(xg,yg,squeeze(amp(:,:)),xx,yy);
    phaseu(:,:)=interp2(xg,yg,squeeze(phi(:,:)),xx,yy);

end

ampu=squeeze(ampu);
phaseu=squeeze(phaseu);
