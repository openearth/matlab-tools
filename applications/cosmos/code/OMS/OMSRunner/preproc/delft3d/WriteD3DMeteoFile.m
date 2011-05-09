function WriteD3DMeteoFile(meteodir,meteoname,rundir,xlim,ylim,dx,dy,coordsys,coordsystype,reftime,tstart,tstop,dt,prcorr,CoordinateSystems,Operations)

dt=dt/24;

nt=(tstop-tstart)/dt+1;

xlimg=xlim;ylimg=ylim;

xlim(2)=max(xlim(2),xlim(1)+dx);
ylim(2)=max(ylim(2),ylim(1)+dy);

if ~strcmpi(coordsystype,'geographic')
    [xg,yg]=meshgrid(xlim(1):dx:xlim(2),ylim(1):dy:ylim(2));
    [xgeo,ygeo]=ConvertCoordinates(xg,yg,coordsys,coordsystype,'WGS 84','geographic',CoordinateSystems,Operations);
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
    if exist(fstr,'file')
        s=load(fstr);
    else
        % find first available file
        for n=1:1000
            t0=t+n*dt;
            tstr=datestr(t0,'yyyymmddHHMMSS');
            fstr=[meteodir meteoname '_' tstr '.mat'];
            if exist(fstr,'file')
                s=load(fstr);
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
        
        % Correct vector direction
        csrc.Name='WGS 84';
        csrc.Type='geographic';
        ctar.Name=coordsys;
        ctar.Type=coordsystype;
        alfa=computeAngleCorrection(xgeo,ygeo,csrc,ctar,CoordinateSystems,Operations);
        [u,v]=correctAngle(u,v,alfa);
    end

    s2.time(it)=t;
    
    if ~strcmpi(coordsystype,'geographic')
        s2.x=xlim(1):dx:xlim(2);
        s2.y=ylim(1):dy:ylim(2);
        s2.dx=dx;
        s2.dy=dy;
    else
        if isfield(s,'dLon')
            csz(1)=s.dLon;
            csz(2)=s.dLat;
        else
            csz(1)=abs(s.lon(2)-s.lon(1));
            csz(2)=abs(s.lat(2)-s.lat(1));
        end
        s2.x=lon;
        s2.y=lat;
        s2.dx=csz(1);
        s2.dy=csz(2);
    end

    s2.u(:,:,it)=u;
    s2.v(:,:,it)=v;
    s2.p(:,:,it)=p;

end

writeD3Dmeteo([rundir 'meteo.amu'],s2,'u','x_wind','m s-1',unit,reftime);
writeD3Dmeteo([rundir 'meteo.amv'],s2,'v','y_wind','m s-1',unit,reftime);
writeD3Dmeteo([rundir 'meteo.amp'],s2,'p','air_pressure','Pa',unit,reftime);
