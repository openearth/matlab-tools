function [xx,yy,cdata]=ddb_getimagetile(xmin,xmax,ymin,ymax,zmlev)

npix=1200;
zmlev=round(log2(npix*3/(xmax-xmin)));
zmlev=max(zmlev,4);
zmlev=min(zmlev,23);

ymin1=max(-89,ymin);
ymax1=min(89,ymax);
xmin1=max(-179,xmin);
xmax1=min(179,xmax);

[img, lon, lat] = url2image('tile2img',[xmin1 xmax1],[ymin1 ymax1],zmlev,'cache','d:\work\imgcache');
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

tic
disp('interpolating image')
for j=1:size(r,2)
    r(:,j)=interp1(yy,r(:,j),yp);
    g(:,j)=interp1(yy,g(:,j),yp);
    b(:,j)=interp1(yy,b(:,j),yp);
end
toc

cdata=[];
cdata(:,:,1)=r/255;
cdata(:,:,2)=g/255;
cdata(:,:,3)=b/255;
