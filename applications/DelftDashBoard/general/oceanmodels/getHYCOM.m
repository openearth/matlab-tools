function getHYCOM(url,outname,outdir,par,xl,yl,dx,dy,t,s,daynum)
% Download Hycom data

fname=url;

%daynum=nc_varget(fname,'MT');
dt=daynum+datenum(1900,12,31);

if length(t)>1
    it1=find(dt==t(1));
    it2=find(dt==t(2));
else
    it1=find(dt==t);
    it2=it1;
    t(2)=t(1);
end

nt=it2-it1+1;
t=t(1):t(2);

d=s.d;

xl1=mod(xl,360);
yl1=yl;
xl1(xl1<74.12)=xl1(xl1<74.12)+360;
[ii,jj]=find(s.lon>xl1(1)&s.lon<xl1(2)&s.lat>yl1(1)&s.lat<yl1(2));

imin=min(ii);
imax=max(ii);
jmin=min(jj);
jmax=max(jj);

imin=max(imin-1,1);
imax=min(imax+1,size(s.lon,1));
jmin=max(jmin-1,1);
jmax=min(jmax+1,size(s.lon,2));

id=imax-imin+1;
jd=jmax-jmin+1;

nd=length(d);

lon=s.lon(imin:imax,jmin:jmax);
lat=s.lat(imin:imax,jmin:jmax);

clear s

lon=double(lon);
lat=double(lat);

[xg,yg]=meshgrid(xl1(1):dx:xl1(2),yl1(1):dy:yl1(2));

s.time=t;
% s.lon=lon;
% s.lat=lat;
s.lon=transpose(xl(1):dx:xl(2));
s.lat=transpose(yl(1):dy:yl(2));
s.levels=d';
s.long_name=par;

nx=size(lon,1);
ny=size(lon,2);
xxx=reshape(lon,nx*ny,1);
yyy=reshape(lat,nx*ny,1);
p = [xxx yyy];
tri=delaunay(xxx,yyy);

switch lower(par)

    case{'temperature'}
        disp('Downloading temperature ...');
        tic
        data=nc_varget(fname,'temperature',[it1-1 0 imin-1 jmin-1],[nt nd id jd]);
        toc
        if ndims(data)==3
            data=permute(data,[2 3 1]);
            data(:,:,:,1)=data;
        else
            data=permute(data,[3 4 2 1]);
        end
        disp('Interpolating ...');      
        tic
        for k=1:nd
            for it=1:nt
                d=squeeze(data(:,:,k,it));
                d=reshape(d,nx*ny,1);
                s.data(:,:,k,it)    = tinterp(p,tri,d,xg,yg,'quadratic');
            end
        end
        toc
        s.data=single(s.data);

    case{'salinity'}
        disp('Downloading salinity ...');
        tic
        data=nc_varget(fname,'salinity',[it1-1 0 imin-1 jmin-1],[nt nd id jd]);
        toc
        if ndims(data)==3
            data=permute(data,[2 3 1]);
            data(:,:,:,1)=data;
        else
            data=permute(data,[3 4 2 1]);
        end
        
        disp('Interpolating ...');      
        tic
        for k=1:nd
            for it=1:nt
                d=squeeze(data(:,:,k,it));
                d=reshape(d,nx*ny,1);
                s.data(:,:,k,it)    = tinterp(p,tri,d,xg,yg,'quadratic');
            end
        end
        toc
        s.data=single(s.data);

    case{'waterlevel'}
        disp('Downloading water level ...');
        tic
        data=nc_varget(fname,'ssh',[it1-1 imin-1 jmin-1],[nt id jd]);
        toc
        if ndims(data)==2
            data(:,:,1)=data;
%            data=permute(data,[1 2 3]);
        else
            data=permute(data,[2 3 1]);
        end
        disp('Interpolating ...');      
        tic
        for it=1:nt
            d=squeeze(data(:,:,it));
            d=reshape(d,nx*ny,1);
            s.data(:,:,it)    = tinterp(p,tri,d,xg,yg,'quadratic');
        end
        toc
        s.data=single(s.data);

    case{'current_u'}

        disp('Downloading u ...');
        tic
        data=nc_varget(fname,'u',[it1-1 0 imin-1 jmin-1],[nt nd id jd]);
        toc
        if ndims(data)==3
            data=permute(data,[2 3 1]);
            data(:,:,:,1)=data;
        else
            data=permute(data,[3 4 2 1]);
        end
        disp('Interpolating ...');      
        tic
        s.data=[];
        for k=1:nd
            for it=1:nt
                d=squeeze(data(:,:,k,it));
                d=reshape(d,nx*ny,1);
                s.data(:,:,k,it)    = tinterp(p,tri,d,xg,yg,'quadratic');
            end
        end
        toc
        s.data=single(s.data);

    case{'current_v'}

        disp('Downloading v ...');
        tic
        data=nc_varget(fname,'v',[it1-1 0 imin-1 jmin-1],[nt nd id jd]);
        toc
        if ndims(data)==3
            data=permute(data,[2 3 1]);
            data(:,:,:,1)=data;
        else
            data=permute(data,[3 4 2 1]);
        end
        disp('Interpolating ...');      
        tic
        s.data=[];
        for k=1:nd
            for it=1:nt
                d=squeeze(data(:,:,k,it));
                d=reshape(d,nx*ny,1);
                s.data(:,:,k,it)    = tinterp(p,tri,d,xg,yg,'quadratic');
            end
        end
        toc
        s.data=single(s.data);
        
end

for it=1:length(s.time)
    fname=[outdir filesep outname '.' lower(par) '.' datestr(s.time(it),'yyyymmddHHMMSS') '.mat'];
    s2=s;
    s2.time=s2.time(it);
    if ndims(s.data)==3
        if length(s.time)==1
            % One timestep, no need to squeeze
        else
            % One level
            s2.data=squeeze(s2.data(:,:,it));
        end
    elseif ndims(s.data)==4
        s2.data=squeeze(s2.data(:,:,:,it));
    end    
    save(fname,'-struct','s2');
end
