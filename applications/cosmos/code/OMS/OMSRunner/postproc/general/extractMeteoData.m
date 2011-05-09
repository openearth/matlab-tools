function s2=extractMeteoData(meteodir,Model,dt,par)

coordsys=Model.CoordinateSystem;
coordsystype=Model.CoordinateSystemType;
meteoname=Model.UseMeteo;

xlim=Model.XLim;
ylim=Model.YLim;

ylim(1)=max(ylim(1),-80);
ylim(2)=min(ylim(2),80);


if ~strcmpi(coordsystype,'geographic')
    dx=Model.dXMeteo;
    dy=Model.dXMeteo;
else
    dx=0;
    dy=0;
end

tstart=Model.TFlowStart;
tstop=Model.TStop;

dt=dt/24;

nt=(tstop-tstart)/dt+1;

xlimg=xlim;
ylimg=ylim;

xlim(2)=max(xlim(2),xlim(1)+dx);
ylim(2)=max(ylim(2),ylim(1)+dy);

if ~strcmpi(coordsystype,'geographic')
    [xg,yg]=meshgrid(xlim(1):dx:xlim(2),ylim(1):dy:ylim(2));
    [xgeo,ygeo]=ConvertCoordinates(xg,yg,'CS1.name',coordsys,'CS1.type',coordsystype,'CS2.name','WGS 84','CS2.type','geographic');
    xlimg(1)=min(min(xgeo));
    xlimg(2)=max(max(xgeo));
    ylimg(1)=min(min(ygeo));
    ylimg(2)=max(max(ygeo));
    unit='m';
else
    unit='degree';
end

for it=1:nt

    t=tstart+(it-1)*dt;
    tstr=datestr(t,'yyyymmddHHMMSS');
    fstr=[meteodir meteoname '_' tstr '.mat'];
    fstr2=[meteodir meteoname '.' tstr '.mat'];
    if exist(fstr,'file')
        s=load(fstr);
    elseif exist(fstr2,'file')
        s=load(fstr2);
    else
        % find first available file
        for n=1:1000
            t0=t+n*dt;
            tstr=datestr(t0,'yyyymmddHHMMSS');
            fstr=[meteodir meteoname '_' tstr '.mat'];
            fstr2=[meteodir meteoname '.' tstr '.mat'];
            if exist(fstr,'file')
                s=load(fstr);
                break
            elseif exist(fstr2,'file')
                s=load(fstr2);
                break
            end
        end
    end

    [u,lon,lat]=getMeteoMatrix(s.u,s.lon,s.lat,xlimg,ylimg);
    [v,lon,lat]=getMeteoMatrix(s.v,s.lon,s.lat,xlimg,ylimg);
    [p,lon,lat]=getMeteoMatrix(s.p,s.lon,s.lat,xlimg,ylimg);
    
    if ~strcmpi(coordsystype,'geographic')
        u=interp2(lon,lat,u,xgeo,ygeo);
        v=interp2(lon,lat,v,xgeo,ygeo);
        p=interp2(lon,lat,p,xgeo,ygeo);
    end

    s2.Parameter=par;   

    s2.Time(it)=t;

    if ~strcmpi(coordsystype,'geographic')
        s2.X=xlim(1):dx:xlim(2);
        s2.Y=ylim(1):dy:ylim(2);
    else
        s2.X=lon;
        s2.Y=lat;
    end

    switch(par)
        case{'windvel'}
            s2.XComp(it,:,:)=u;
            s2.YComp(it,:,:)=v;
        case{'airp'}
            s2.Val(it,:,:)=p;
    end

end
