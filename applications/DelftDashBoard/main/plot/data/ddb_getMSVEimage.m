function [xx,yy,cdata]=ddb_getMSVEimage(xmin,xmax,ymin,ymax,varargin)

what='aerial';
npix=1200;
zmlev=0;
cachedir='';

for i=1:length(varargin)
    if ischar(varargin{i})
        switch lower(varargin{i})
            case{'npix','nrpixels'}
                npix=varargin{i+1};
            case{'zoomlevel','zl'}
                zmlev=varargin{i+1};
            case{'cachedir'}
                cachedir=varargin{i+1};
            case{'whatkind'}
                what=varargin{i+1};
            case{'cache'}
                cachedir=varargin{i+1};
        end
    end
end

if zmlev==0
    % Automatic zoomlevel
    zmlev=round(log2(npix*3/(xmax-xmin)));
    zmlev=max(zmlev,4);
    zmlev=min(zmlev,23);
end

ymin1=max(-89,ymin);
ymax1=min(89,ymax);
xmin1=max(-179,xmin);
xmax1=min(179,xmax);

[img, lon, lat] = url2image('tile2img',[xmin1 xmax1],[ymin1 ymax1],zmlev,'cache',cachedir,'what',what);
%[img, lon, lat] = url2image('tile2img',[xmin1 xmax1],[ymin1 ymax1],zmlev,'cache',cachedir,'what','roads');

r=double(squeeze(img(:,:,1)));
g=double(squeeze(img(:,:,2)));
b=double(squeeze(img(:,:,3)));
nx=size(img,2);
ny=size(img,1);
dlon=(lon(2)-lon(1))/(nx-1);
dlat=(lat(2)-lat(1))/(ny-1);

xx=lon(1):dlon:lon(2);
yy=lat(1):dlat:lat(2);

ym=yy;
yp=yy;

ymin2=min(yy);
ymax2=max(yy);


% Adjust for mercator projection

% Above the equator
ymin3=max(ymin2,0);
aa=(ymax2-ymin3)/(merc(ymax2)-merc(ymin3));
bb=ymin3-aa*merc(ymin3);
yp(ym>0)=aa*merc(ym(ym>0))+bb;
% Below the equator
ymin3=min(ymax2,0);
aa=(ymin2-ymin3)/(merc(ymin2)-merc(ymin3));
bb=ymin3-aa*merc(ymin3);
yp(ym<0)=aa*merc(ym(ym<0))+bb;

for j=1:size(r,2)
    r(:,j)=interp1(yy,r(:,j),yp);
    g(:,j)=interp1(yy,g(:,j),yp);
    b(:,j)=interp1(yy,b(:,j),yp);
end

cdata=[];
cdata(:,:,1)=r;
cdata(:,:,2)=g;
cdata(:,:,3)=b;
cdata=uint8(cdata);
