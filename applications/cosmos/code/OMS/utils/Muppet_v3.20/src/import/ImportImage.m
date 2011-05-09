function DataProperties=ImportImage(DataProperties,j)

frm=DataProperties(j).FileName(end-2:end);
switch lower(frm),
    case{'jpg','epg','bmp'}
        jpgcol=imread([DataProperties(j).PathName DataProperties(j).FileName]);
    case{'png'}
        jpgcol=imread([DataProperties(j).PathName DataProperties(j).FileName],'BackgroundColor','none');
    case{'gif'}
        jpgcol=imread([DataProperties(j).PathName DataProperties(j).FileName],1);
end
sz=size(jpgcol);
step=1;
jpgcol=jpgcol(1:step:sz(1),1:step:sz(2),:);
col=double(jpgcol)/255;

if length(DataProperties(j).GeoReferenceFile)>0

    [x,y]=meshgrid(1:step:sz(2),1:step:sz(1));

    txt=ReadTextFile(DataProperties(j).GeoReferenceFile);
    k=1;
    dx=str2num(txt{k});
    k=k+1;
    roty=str2num(txt{k});
    k=k+1;
    rotx=str2num(txt{k});
    k=k+1;
    dy=str2num(txt{k});
    k=k+1;
    x0=str2num(txt{k});
    k=k+1;
    y0=str2num(txt{k});
 
    a=dx*step;
    d=roty;
    b=rotx;
    e=dy*step;
    c=x0;
    f=y0;
    
    x0=x;
    y0=y;
    
    x=a*x0+b*y0+c;
    y=d*x0+e*y0+f;    
    
    DataProperties(j).Type = 'GeoImage';
else
    [x,y]=meshgrid(1:step:sz(2),sz(1):-step:1);

    DataProperties(j).Type = 'Image';
end
 
z=zeros(size(x));

DataProperties(j).x    = x;
DataProperties(j).y    = y;
DataProperties(j).z    = z;
DataProperties(j).c    = col;

DataProperties(j).TC='c';

clear x y z x y x0 y0 col jpgcol
