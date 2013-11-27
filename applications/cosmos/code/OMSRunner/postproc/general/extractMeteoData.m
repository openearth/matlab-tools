function s2=extractMeteoData(meteodir,model,dt,par)

coordsys=model.coordinateSystem;
coordsystype=model.coordinateSystemType;
meteowind=model.meteowind;
meteopressure=model.meteopressure;

xlim=model.xLim;
ylim=model.yLim;

% ylim(1)=max(ylim(1),-80);
% ylim(2)=min(ylim(2),80);

if ~strcmpi(coordsystype,'geographic')
    dx=model.dXMeteo;
    dy=model.dXMeteo;
else
    dx=0;
    dy=0;
end

tstart=model.tFlowStart;
tstop=model.tStop;

dt=dt/24;

nt=(tstop-tstart)/dt+1;

xlimg=xlim;
ylimg=ylim;

xlim(2)=max(xlim(2),xlim(1)+dx);
ylim(2)=max(ylim(2),ylim(1)+dy);

if ~strcmpi(coordsystype,'geographic')
    [xg,yg]=meshgrid(xlim(1):dx:xlim(2),ylim(1):dy:ylim(2));
    [xgeo,ygeo]=convertCoordinates(xg,yg,'persistent','CS1.name',coordsys,'CS1.type',coordsystype,'CS2.name','WGS 84','CS2.type','geographic');
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
    fstru=[meteodir meteowind '.u.' tstr '.mat'];
    fstrv=[meteodir meteowind '.v.' tstr '.mat'];
%    fstrp=[meteodir meteoname '.p.' tstr '.mat'];
    if exist(fstru,'file')
        su=load(fstru);
        sv=load(fstrv);
%        sp=load(fstrp);
    else
        % find first available file
        for n=1:1000
            t0=t+n*dt;
            tstr=datestr(t0,'yyyymmddHHMMSS');
            fstru=[meteodir meteowind '.u.' tstr '.mat'];
            fstrv=[meteodir meteowind '.v.' tstr '.mat'];
%            fstrp=[meteodir meteoname '.p.' tstr '.mat'];
            if exist(fstru,'file')
                su=load(fstru);
                sv=load(fstrv);
%                sp=load(fstrp);
                break
            end
        end
    end

    [u,lon,lat]=getMeteoMatrix(su.u,su.lon,su.lat,xlimg,ylimg);
    [v,lon,lat]=getMeteoMatrix(sv.v,sv.lon,sv.lat,xlimg,ylimg);
%    [p,lon,lat]=getMeteoMatrix(sp.p,sp.lon,sp.lat,xlimg,ylimg);
    
    if ~strcmpi(coordsystype,'geographic')
        u=interp2(lon,lat,u,xgeo,ygeo);
        v=interp2(lon,lat,v,xgeo,ygeo);
%        p=interp2(lon,lat,p,xgeo,ygeo);
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
